// Статичные методы

@if(ModuleExists("ExistingConsumableModule"))
public final func ExistingConsumableModule() -> Bool {

	return true;
}

@if(!ModuleExists("ExistingConsumableModule"))
public final func ExistingConsumableModule() -> Bool {

	return false;
}

public final static func GetItemWeight(itemData: wref<gameItemData>) -> Float {

	let settings: ref<SurvivalSystemSettings> = new SurvivalSystemSettings();

	if ExistingConsumableModule() {

		if itemData.HasTag(n"Grenade") {

			return settings.grenadeWeightEC;
		};

		if itemData.HasTag(n"Injector") {

			return settings.injectorWeightEC;
		};

		if itemData.HasTag(n"Inhaler") {

			return settings.inhalerWeightEC;
		};
	};

	if itemData.HasTag(n"Consumable") && !(itemData.HasTag(n"Injector") || itemData.HasTag(n"Inhaler")) {

		let consumableName: CName = TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(itemData.GetID())).ConsumableBaseName().EnumName();

		switch consumableName {

			case n"Edible":

				return settings.foodlWeight;
			break;

			case n"Drinkable":

				return settings.drinklWeight;
			break;

			case n"Alcohol":

				return settings.alcoholWeight;
			break;
		};

		return settings.drugsWeight;
	};

	if itemData.HasTag(n"Ammo") {

		let itemID: TweakDBID = ItemID.GetTDBID(itemData.GetID());

		switch itemID {

			case t"Ammo.HandgunAmmo":

				return settings.handgunAmmoWeight;
			break;

			case t"Ammo.ShotgunAmmo":

				return settings.shotgunAmmoWeight;
			break;

			case t"Ammo.RifleAmmo":

				return settings.rifleAmmodWeight;
			break;

			case t"Ammo.SniperRifleAmmo":

				return settings.sniperAmmoWeight;
			break;
		};
	};

	return 0.0;
}

public final static func GetNutritionVector(itemData: wref<gameItemData>) -> Vector3 {

	let settings = new SurvivalSystemSettings();
	let nutritionValue: Vector3 = new Vector3(0.0, 0.0, 0.0);

	let itemID: TweakDBID = ItemID.GetTDBID(itemData.GetID());
	let itemQality: CName = UIItemsHelper.QualityEnumToName(RPGManager.GetItemDataQuality(itemData));
	let consumableName: CName = TweakDBInterface.GetConsumableItemRecord(ItemID.GetTDBID(itemData.GetID())).ConsumableBaseName().EnumName();

	switch itemID {

		case t"Items.SSStimulatorUncommon":

			nutritionValue = new Vector3(-18.0, -8.0, -10.0);
			return nutritionValue;
		break;

		case t"Items.SSStimulatorRare":

			nutritionValue = new Vector3(-16.0, -6.0, -8.0);
			return nutritionValue;
		break;

		case t"Items.SSStimulatorEpic":

			nutritionValue = new Vector3(-14.0, -4.0, -6.0);
			return nutritionValue;
		break;
	};

	if Equals(consumableName, n"Edible") {

		switch itemQality {

			case n"Common":

				nutritionValue.Y = 2.0;
			break;

			case n"Uncommon":

				switch itemID {

					case t"Items.LowQualityFood1":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.LowQualityFood3":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.LowQualityFood5":

						nutritionValue = new Vector3(0.0, 4.0, 0.0);
					break;

					case t"Items.LowQualityFood6":

						nutritionValue = new Vector3(1.0, 4.0, 0.0);
					break;

					case t"Items.LowQualityFood7":

						nutritionValue = new Vector3(0.0, 4.0, 0.0);
					break;

					case t"Items.LowQualityFood8":

						nutritionValue = new Vector3(0.0, 4.0, -1.0);
					break;

					case t"Items.LowQualityFood9":

						nutritionValue = new Vector3(0.0, 4.0, -1.0);
					break;

					case t"Items.LowQualityFood10":

						nutritionValue = new Vector3(0.0, 6.0, 0.0);
					break;

					case t"Items.LowQualityFood11":

						nutritionValue = new Vector3(0.0, 3.0, 0.0);
					break;

					case t"Items.LowQualityFood12":

						nutritionValue = new Vector3(0.0, 3.0, 2.0);
					break;

					case t"Items.LowQualityFood13":

						nutritionValue = new Vector3(0.0, 3.0, 2.0);
					break;

					case t"Items.LowQualityFood14":

						nutritionValue = new Vector3(0.0, 3.0, 2.0);
					break;

					case t"Items.LowQualityFood15":

						nutritionValue = new Vector3(0.0, 4.0, 0.0);
					break;

					case t"Items.LowQualityFood16":

						nutritionValue = new Vector3(0.0, 4.0, 0.0);
					break;

					case t"Items.LowQualityFood17":

						nutritionValue = new Vector3(0.0, 4.0, 0.0);
					break;

					case t"Items.LowQualityFood18":

						nutritionValue = new Vector3(0.0, 4.0, 0.0);
					break;

					case t"Items.LowQualityFood19":

						nutritionValue = new Vector3(0.0, 4.0, 0.0);
					break;

					case t"Items.LowQualityFood20":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.LowQualityFood21":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.LowQualityFood22":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.LowQualityFood23":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.LowQualityFood24":

						nutritionValue = new Vector3(0.0, 4.0, -1.0);
					break;

					case t"Items.LowQualityFood25":

						nutritionValue = new Vector3(0.0, 4.0, -1.0);
					break;

					case t"Items.LowQualityFood26":

						nutritionValue = new Vector3(0.0, 4.0, -1.0);
					break;

					case t"Items.LowQualityFood27":

						nutritionValue = new Vector3(0.0, 4.0, -1.0);
					break;

					case t"Items.LowQualityFood28":

						nutritionValue = new Vector3(0.0, 4.0, -1.0);
					break;

					case t"Items.NomadsFood1":

						nutritionValue = new Vector3(0.0, 6.0, 0.0);
					break;

					case t"Items.NomadsFood2":

						nutritionValue = new Vector3(0.0, 8.0, -2.0);
					break;
				};

			break;

			case n"Rare":

				switch itemID {

					case t"Items.MediumQualityFood1":

						nutritionValue = new Vector3(0.0, 7.0, 0.0);
					break;

					case t"Items.MediumQualityFood2":

						nutritionValue = new Vector3(0.0, 6.0, 0.0);
					break;

					case t"Items.MediumQualityFood3":

						nutritionValue = new Vector3(0.0, 8.0, -1.0);
					break;

					case t"Items.MediumQualityFood4":

						nutritionValue = new Vector3(0.0, 7.0, 0.0);
					break;

					case t"Items.MediumQualityFood5":

						nutritionValue = new Vector3(0.0, 7.0, 0.0);
					break;

					case t"Items.MediumQualityFood6":

						nutritionValue = new Vector3(0.0, 5.0, 1.0);
					break;

					case t"Items.MediumQualityFood7":

						nutritionValue = new Vector3(0.0, 8.0, -1.0);
					break;

					case t"Items.MediumQualityFood8":

						nutritionValue = new Vector3(0.0, 6.0, 0.0);
					break;

					case t"Items.MediumQualityFood9":

						nutritionValue = new Vector3(0.0, 6.0, 0.0);
					break;

					case t"Items.MediumQualityFood10":

						nutritionValue = new Vector3(0.0, 8.0, 0.0);
					break;

					case t"Items.MediumQualityFood11":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.MediumQualityFood12":

						nutritionValue = new Vector3(0.0, 7.0, 0.0);
					break;

					case t"Items.MediumQualityFood13":

						nutritionValue = new Vector3(0.0, 7.0, 0.0);
					break;

					case t"Items.MediumQualityFood14":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.MediumQualityFood15":

						nutritionValue = new Vector3(1.0, 6.0, -1.0);
					break;

					case t"Items.MediumQualityFood16":

						nutritionValue = new Vector3(0.0, 5.0, 0.0);
					break;

					case t"Items.MediumQualityFood17":

						nutritionValue = new Vector3(0.0, 6.0, 0.0);
					break;

					case t"Items.MediumQualityFood18":

						nutritionValue = new Vector3(0.0, 6.0, 0.0);
					break;

					case t"Items.MediumQualityFood19":

						nutritionValue = new Vector3(0.0, 6.0, 0.0);
					break;

					case t"Items.MediumQualityFood20":

						nutritionValue = new Vector3(0.0, 5.0, 1.0);
					break;
				};

			break;

			case n"Epic":

				switch itemID {

					case t"Items.GoodQualityFood1":

						nutritionValue = new Vector3(0.0, 6.0, 3.0);
					break;

					case t"Items.GoodQualityFood2":

						nutritionValue = new Vector3(0.0, 9.0, 1.0);
					break;

					case t"Items.GoodQualityFood3":

						nutritionValue = new Vector3(1.0, 7.0, 0.0);
					break;

					case t"Items.GoodQualityFood4":

						nutritionValue = new Vector3(1.0, 7.0, 0.0);
					break;

					case t"Items.GoodQualityFood5":

						nutritionValue = new Vector3(0.0, 8.0, 0.0);
					break;

					case t"Items.GoodQualityFood6":

						nutritionValue = new Vector3(0.0, 8.0, 0.0);
					break;

					case t"Items.GoodQualityFood7":

						nutritionValue = new Vector3(0.0, 7.0, 0.0);
					break;

					case t"Items.GoodQualityFood8":

						nutritionValue = new Vector3(0.0, 9.0, 0.0);
					break;

					case t"Items.GoodQualityFood9":

						nutritionValue = new Vector3(0.0, 9.0, 0.0);
					break;

					case t"Items.GoodQualityFood10":

						nutritionValue = new Vector3(0.0, 8.0, 0.0);
					break;

					case t"Items.GoodQualityFood11":

						nutritionValue = new Vector3(0.0, 8.0, 0.0);
					break;

					case t"Items.GoodQualityFood12":

						nutritionValue = new Vector3(0.0, 8.0, 0.0);
					break;

					case t"Items.GoodQualityFood13":

						nutritionValue = new Vector3(0.0, 10.0, -1.0);
					break;
				};

			break;

			case n"Legendary":

				nutritionValue.Y = 10.0;
			break;
		};

		nutritionValue.X *= settings.foodMultiplier;
		nutritionValue.Y *= settings.foodMultiplier;
		nutritionValue.Z *= settings.foodMultiplier;
		
		return nutritionValue;
	};

	if Equals(consumableName, n"Drinkable") {

		switch itemQality {

			case n"Common":

				nutritionValue = new Vector3(0.0, 0.0, 4.0);
			break;

			case n"Uncommon":

				switch itemID {

					case t"Items.LowQualityDrink1":

						nutritionValue = new Vector3(2.0, 0.0, 5.0);
					break;

					case t"Items.LowQualityDrink2":

						nutritionValue = new Vector3(0.0, 0.0, 6.0);
					break;

					case t"Items.LowQualityDrink3":

						nutritionValue = new Vector3(0.0, 3.0, 4.0);
					break;

					case t"Items.LowQualityDrink4":

						nutritionValue = new Vector3(0.0, 2.0, 5.0);
					break;

					case t"Items.LowQualityDrink5":

						nutritionValue = new Vector3(0.0, 1.0, 6.0);
					break;

					case t"Items.LowQualityDrink6":

						nutritionValue = new Vector3(0.0, 1.0, 6.0);
					break;

					case t"Items.LowQualityDrink7":

						nutritionValue = new Vector3(0.0, 1.0, 5.0);
					break;

					case t"Items.LowQualityDrink8":

						nutritionValue = new Vector3(0.0, 1.0, 5.0);
					break;

					case t"Items.LowQualityDrink9":

						nutritionValue = new Vector3(0.0, 1.0, 6.0);
					break;

					case t"Items.LowQualityDrink10":

						nutritionValue = new Vector3(0.0, 1.0, 7.0);
					break;

					case t"Items.LowQualityDrink11":

						nutritionValue = new Vector3(2.0, 0.0, 5.0);
					break;

					case t"Items.LowQualityDrink12":

						nutritionValue = new Vector3(1.0, 2.0, 5.0);
					break;

					case t"Items.LowQualityDrink13":

						nutritionValue = new Vector3(1.0, 2.0, 5.0);
					break;
				};

			break;

			case n"Rare":

				switch itemID {

					case t"Items.MediumQualityDrink1":

						nutritionValue = new Vector3(0.0, 1.0, 8.0);
					break;

					case t"Items.MediumQualityDrink2":

						nutritionValue = new Vector3(0.0, 1.0, 8.0);
					break;

					case t"Items.MediumQualityDrink3":

						nutritionValue = new Vector3(0.0, 0.0, 10.0);
					break;

					case t"Items.MediumQualityDrink4":

						nutritionValue = new Vector3(0.0, 0.0, 10.0);
					break;

					case t"Items.MediumQualityDrink5":

						nutritionValue = new Vector3(0.0, 1.0, 7.0);
					break;

					case t"Items.MediumQualityDrink6":

						nutritionValue = new Vector3(0.0, 0.0, 7.0);
					break;

					case t"Items.MediumQualityDrink7":

						nutritionValue = new Vector3(2.0, 1.0, 7.0);
					break;

					case t"Items.MediumQualityDrink8":

						nutritionValue = new Vector3(0.0, 0.0, 8.0);
					break;

					case t"Items.MediumQualityDrink9":

						nutritionValue = new Vector3(0.0, 0.0, 8.0);
					break;

					case t"Items.MediumQualityDrink10":

						nutritionValue = new Vector3(2.0, 2.0, 10.0);
					break;

					case t"Items.MediumQualityDrink11":

						nutritionValue = new Vector3(1.0, 0.0, 8.0);
					break;

					case t"Items.MediumQualityDrink12":

						nutritionValue = new Vector3(0.0, 0.0, 8.0);
					break;

					case t"Items.MediumQualityDrink13":

						nutritionValue = new Vector3(0.0, 0.0, 8.0);
					break;

					case t"Items.MediumQualityDrink14":

						nutritionValue = new Vector3(0.0, 4.0, 6.0);
					break;
				};

			break;

			case n"Epic":

				switch itemID {

					case t"Items.GoodQualityDrink1":

						nutritionValue = new Vector3(0.0, 0.0, 11.0);
					break;

					case t"Items.GoodQualityDrink2":

						nutritionValue = new Vector3(2.0, 0.0, 10.0);
					break;

					case t"Items.GoodQualityDrink3":

						nutritionValue = new Vector3(0.0, 1.0, 9.0);
					break;

					case t"Items.GoodQualityDrink4":

						nutritionValue = new Vector3(2.0, 1.0, 9.0);
					break;

					case t"Items.GoodQualityDrink5":

						nutritionValue = new Vector3(1.0, 0.0, 10.0);
					break;

					case t"Items.GoodQualityDrink6":

						nutritionValue = new Vector3(1.0, 0.0, 10.0);
					break;

					case t"Items.GoodQualityDrink7":

						nutritionValue = new Vector3(1.0, 0.0, 10.0);
					break;

					case t"Items.GoodQualityDrink8":

						nutritionValue = new Vector3(0.0, 0.0, 11.0);
					break;

					case t"Items.GoodQualityDrink9":

						nutritionValue = new Vector3(0.0, 0.0, 11.0);
					break;

					case t"Items.GoodQualityDrink10":

						nutritionValue = new Vector3(0.0, 0.0, 12.0);
					break;

					case t"Items.GoodQualityDrink11":

						nutritionValue = new Vector3(0.0, 5.0, 8.0);
					break;

					case t"Items.NomadsDrink1":

						nutritionValue = new Vector3(0.0, 0.0, 12.0);
					break;

					case t"Items.NomadsDrink2":

						nutritionValue = new Vector3(0.0, 2.0, 8.0);
					break;
				};

			break;

			case n"Legendary":

				nutritionValue = new Vector3(0.0, 0.0, 12.0);
			break;
		};

		nutritionValue.X *= settings.drinkMultiplier;
		nutritionValue.Y *= settings.drinkMultiplier;
		nutritionValue.Z *= settings.drinkMultiplier;

		return nutritionValue;
	};

	if Equals(consumableName, n"Alcohol") {

		switch itemQality {

			case n"Common":

				nutritionValue.X = -12.0;
				nutritionValue.Z = 2.0;
			break;

			case n"Uncommon":

				nutritionValue.X = -10.0;
				nutritionValue.Z = 4.0;
			break;

			case n"Rare":

				nutritionValue.X = -8.0;
				nutritionValue.Z = 6.0;
			break;

			case n"Epic":

				nutritionValue.X = -6.0;
				nutritionValue.Z = 8.0;
			break;

			case n"Legendary":

				nutritionValue.X = -4.0;
				nutritionValue.Z = 10.0;
			break;
		};

		nutritionValue.X *= settings.alcoholPenalty;
		nutritionValue.Z *= settings.alcoholMultiplier;
		
		return nutritionValue;
	};

	return nutritionValue;
}