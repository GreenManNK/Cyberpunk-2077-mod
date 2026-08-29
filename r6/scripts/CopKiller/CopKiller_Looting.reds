module CopKiller

public class CopKillerLootingSS extends ScriptableSystem {

	public let stateAssetForfeitureList: array<wref<VehicleObject>>;

	public func GiveAmmoByMagazineItem(ts: ref<TransactionSystem>, player: ref<PlayerPuppet>, magTDBID: TweakDBID) -> Bool {
		switch (magTDBID) {
			// Handguns
			case t"Items.NCPD_HandgunMag_Chao":				ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(5, 16)); break;
			case t"Items.NCPD_HandgunMag_Grit":				ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(8, 23)); break;
			case t"Items.NCPD_HandgunMag_Kappa":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(8, 23)); break;
			case t"Items.NCPD_HandgunMag_Kenshin":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(5, 15)); break;
			case t"Items.NCPD_HandgunMag_Lexington":		ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(5, 15)); break;
			case t"Items.NCPD_HandgunMag_Liberty":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(4, 11)); break;
			case t"Items.NCPD_HandgunMag_Nue":				ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(3, 8)); break;
			case t"Items.NCPD_HandgunMag_Omaha":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(2, 7)); break;
			case t"Items.NCPD_HandgunMag_Slaughtomatic":	ts.GiveItemByTDBID(player, t"Items.CommonMaterial1", 1); break;
			case t"Items.NCPD_HandgunMag_Tamayura":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(2, 6)); break;
			case t"Items.NCPD_HandgunMag_Ticon":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(5, 16)); break;
			case t"Items.NCPD_HandgunMag_Unity":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(3, 9)); break;
			case t"Items.NCPD_HandgunMag_Yukimura":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(8, 23)); break;
			// Revolvers
			case t"Items.NCPD_RevolverMag_Burya":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(1, 3)); break;
			case t"Items.NCPD_RevolverMag_Metel":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(2, 6)); break;
			case t"Items.NCPD_RevolverMag_Nova":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(2, 5)); break;
			case t"Items.NCPD_RevolverMag_Overture":		ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(2, 5)); break;
			case t"Items.NCPD_RevolverMag_Quasar":			ts.GiveItemByTDBID(player, t"Ammo.HandgunAmmo", RandRange(4, 12)); break;
			// SMGs
			case t"Items.NCPD_SMGMag_Dian":					ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(11, 34)); break;
			case t"Items.NCPD_SMGMag_Guillotine":			ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(11, 34)); break;
			case t"Items.NCPD_SMGMag_Pulsar":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(10, 30)); break;
			case t"Items.NCPD_SMGMag_Saratoga":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(10, 30)); break;
			case t"Items.NCPD_SMGMag_Senkoh":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(8, 23)); break;
			case t"Items.NCPD_SMGMag_Shigure":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(13, 38)); break;
			case t"Items.NCPD_SMGMag_Shingen":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(8, 23)); break;
			case t"Items.NCPD_SMGMag_Warden":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(10, 30)); break;
			// Assault Rifles
			case t"Items.NCPD_RifleMag_Ajax":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(8, 23)); break;
			case t"Items.NCPD_RifleMag_Copperhead":			ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(8, 23)); break;
			case t"Items.NCPD_RifleMag_Kyubi":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(5, 15)); break;
			case t"Items.NCPD_RifleMag_Masamune":			ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(6, 18)); break;
			case t"Items.NCPD_RifleMag_Nowaki":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(5, 16)); break;
			case t"Items.NCPD_RifleMag_Sidewinder":			ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(8, 23)); break;
			case t"Items.NCPD_RifleMag_Umbra":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(13, 30)); break;
			// LMGs
			case t"Items.NCPD_LMGMag_Defender":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(20, 60)); break;
			case t"Items.NCPD_LMGMag_MA70HB":				ts.GiveItemByTDBID(player, t"Ammo.RifleAmmo", RandRange(15, 45)); break;
			// Shotguns
			case t"Items.NCPD_ShotgunMag_Carnage":			ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(1, 3)); break;
			case t"Items.NCPD_ShotgunMag_Crusher":			ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(3, 9)); break;
			case t"Items.NCPD_ShotgunMag_Igla":				ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(1, 2)); break;
			case t"Items.NCPD_ShotgunMag_Palica":			ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(1, 2)); break;
			case t"Items.NCPD_ShotgunMag_Pozhar":			ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(3, 9)); break;
			case t"Items.NCPD_ShotgunMag_Satara":			ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(1, 2)); break;
			case t"Items.NCPD_ShotgunMag_Tactician":		ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(2, 6)); break;
			case t"Items.NCPD_ShotgunMag_Testera":			ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(1, 2)); break;
			case t"Items.NCPD_ShotgunMag_Zhuo":				ts.GiveItemByTDBID(player, t"Ammo.ShotgunAmmo", RandRange(1, 3)); break;
			// Precision Rifles
			case t"Items.NCPD_PrecisionMag_Achilles":		ts.GiveItemByTDBID(player, t"Ammo.SniperRifleAmmo", RandRange(2, 7)); break;
			case t"Items.NCPD_PrecisionMag_Kolac":			ts.GiveItemByTDBID(player, t"Ammo.SniperRifleAmmo", RandRange(2, 5)); break;
			case t"Items.NCPD_PrecisionMag_SOR22":			ts.GiveItemByTDBID(player, t"Ammo.SniperRifleAmmo", RandRange(3, 8)); break;
			// Sniper Rifles
			case t"Items.NCPD_SniperMag_Ashura":			ts.GiveItemByTDBID(player, t"Ammo.SniperRifleAmmo", 1); break;
			case t"Items.NCPD_SniperMag_Grad":				ts.GiveItemByTDBID(player, t"Ammo.SniperRifleAmmo", RandRange(1, 3)); break;
			case t"Items.NCPD_SniperMag_Nekomata":			ts.GiveItemByTDBID(player, t"Ammo.SniperRifleAmmo", RandRange(1, 3)); break;
			// Failsafe
			default:										return false;
		};
		return true;
	}

	public func GiveMagazineByWeapon(cm: ref<ContainerManager>, entityID: EntityID, wRecord: ref<WeaponItem_Record>) -> Bool {
		switch (GetLocalizedText(LocKeyToString(wRecord.DisplayName()))) {
			// Handguns
			case "A-22B Chao":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Chao"), 1u); break;
			case "HA-4 Grit":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Grit"), 1u); break;
			case "Kappa":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Kappa"), 1u); break;
			case "JKE-X2 Kenshin":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Kenshin"), 1u); break;
			case "M-10AF Lexington":						cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Lexington"), 1u); break;
			case "Liberty":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Liberty"), 1u); break;
			case "Nue":										cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Nue"), 1u); break;
			case "M-76e Omaha":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Omaha"), 1u); break;
			case "Slaught-O-Matic":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.CommonMaterial1"), 1u); break;
			case "Tamayura":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Tamayura"), 1u); break;
			case "Militech Ticon":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Ticon"), 1u); break;
			case "Unity":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Unity"), 1u); break;
			case "HJKE-11 Yukimura":						cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_HandgunMag_Yukimura"), 1u); break;
			// Revolvers
			case "RT-46 Burya":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RevolverMag_Burya"), 1u); break;
			case "Metel":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RevolverMag_Metel"), 1u); break;
			case "DR5 Nova":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RevolverMag_Nova"), 1u); break;
			case "Overture":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RevolverMag_Overture"), 1u); break;
			case "DR-12 Quasar":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RevolverMag_Quasar"), 1u); break;
			// SMGs
			case "G-58 Dian":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SMGMag_Dian"), 1u); break;
			case "Guillotine":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SMGMag_Guillotine"), 1u); break;
			case "DS1 Pulsar":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SMGMag_Pulsar"), 1u); break;
			case "M221 Saratoga":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SMGMag_Saratoga"), 1u); break;
			case "Senkoh LX":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SMGMag_Senkoh"), 1u); break;
			case "Shigure":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SMGMag_Shigure"), 1u); break;
			case "TKI-20 Shingen":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SMGMag_Shingen"), 1u); break;
			case "Warden":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SMGMag_Warden"), 1u); break;
			// Assault Rifles
			case "M251s Ajax":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RifleMag_Ajax"), 1u); break;
			case "D5 Copperhead":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RifleMag_Copperhead"), 1u); break;
			case "Kyubi":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RifleMag_Kyubi"), 1u); break;
			case "HJSH-18 Masamune":						cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RifleMag_Masamune"), 1u); break;
			case "Nowaki":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RifleMag_Nowaki"), 1u); break;
			case "D5 Sidewinder":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RifleMag_Sidewinder"), 1u); break;
			case "DA8 Umbra":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_RifleMag_Umbra"), 1u); break;
			// LMGs
			case "M2067 Defender":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_LMGMag_Defender"), 1u); break;
			case "MA70 HB":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_LMGMag_MA70HB"), 1u); break;
			// Shotguns
			case "Carnage":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Carnage"), 1u); break;
			case "Crusher":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Crusher"), 1u); break;
			case "DB-4 Igla":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Igla"), 1u); break;
			case "DB-4 Palica":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Palica"), 1u); break;
			case "VST-37 Pozhar":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Pozhar"), 1u); break;
			case "DB-2 Satara":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Satara"), 1u); break;
			case "M2038 Tactician":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Tactician"), 1u); break;
			case "DB-2 Testera":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Testera"), 1u); break;
			case "L-69 Zhuo":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_ShotgunMag_Zhuo"), 1u); break;
			// Precision Rifles
			case "M-179e Achilles":							cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_PrecisionMag_Achilles"), 1u); break;
			case "Kolac":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_PrecisionMag_Kolac"), 1u); break;
			case "SOR-22":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_PrecisionMag_SOR22"), 1u); break;
			// Sniper Rifles
			case "Ashura":									cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SniperMag_Ashura"), 1u); break;
			case "SPT32 Grad":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SniperMag_Grad"), 1u); break;
			case "Nekomata":								cm.InjectLoot(entityID, ItemID.FromTDBID(t"Items.NCPD_SniperMag_Nekomata"), 1u); break;
			// Failsafe
			default:										return false;
		};
		return true;
	}

	public func HasPoliceMagazine(npc: wref<GameObject>) -> Bool {
		let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(npc.GetGame());
		return IsDefined(ts) ? ts.GetItemQuantityByTag(npc, n"PoliceMag") > 0 : false;
	}

	public func InjectMagazineByWeapon(npc: wref<NPCPuppet>) -> Bool {
		let game: GameInstance = GetGameInstance();
		let cm: ref<ContainerManager> = GameInstance.GetContainerManager(game);
		if !IsDefined(cm) || this.HasPoliceMagazine(npc) {
			return false;
		};
		let weapon: ref<WeaponObject> = GameObject.GetActiveWeapon(npc);
		let wRecord: ref<WeaponItem_Record>;
		if IsDefined(weapon) {
			wRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID()));
			if IsDefined(wRecord) {
				return CopKillerLootingSS.GetSS().GiveMagazineByWeapon(cm, npc.GetEntityID(), wRecord);
			};
		}
		let es: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"EquipmentSystem") as EquipmentSystem;
		if IsDefined(es) {
			weapon = es.GetActiveWeaponObject(npc, gamedataEquipmentArea.RightArm) as WeaponObject;
			if !IsDefined(weapon) {
				weapon = es.GetActiveWeaponObject(npc, gamedataEquipmentArea.Weapon) as WeaponObject;
			};
			if IsDefined(weapon) {
				wRecord = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID()));
				if IsDefined(wRecord) {
					return CopKillerLootingSS.GetSS().GiveMagazineByWeapon(cm, npc.GetEntityID(), wRecord);
				};
			};
		};
		let cRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(npc.GetRecordID());
		if IsDefined(cRecord) {
			let primaryItems: array<wref<NPCEquipmentItem_Record>>;
			AIActionTransactionSystem.CalculateEquipmentItems(npc, cRecord.PrimaryEquipment(), primaryItems, -1);
			for item in primaryItems {
				if IsDefined(item.Item()) {
					wRecord = TweakDBInterface.GetWeaponItemRecord(item.Item().GetRecordID());
					if IsDefined(wRecord) { break; };
				};
			};
			if !IsDefined(wRecord) {
				let secondaryItems: array<wref<NPCEquipmentItem_Record>>;
				AIActionTransactionSystem.CalculateEquipmentItems(npc, cRecord.SecondaryEquipment(), secondaryItems, -1);
				for item in secondaryItems {
					if IsDefined(item.Item()) {
						wRecord = TweakDBInterface.GetWeaponItemRecord(item.Item().GetRecordID());
						if IsDefined(wRecord) { break; };
					};
				};
			};
			if IsDefined(wRecord) {
				return CopKillerLootingSS.GetSS().GiveMagazineByWeapon(cm, npc.GetEntityID(), wRecord);
			};
		};
		return false;
	}

	public func ForfeitureListCleanUp() -> Void {
		for veh in this.stateAssetForfeitureList {
			if !IsDefined(veh) || !veh.IsAttached() || veh.GetVehiclePS().GetHasExploded() {
				ArrayRemove(this.stateAssetForfeitureList, veh);
			};
		};
	}

	public func GivePoliceTrunkItems(veh: ref<VehicleObject>) -> Void {
		if !IsDefined(veh) {
			return;
		};
		let game: GameInstance = GetGameInstance();
		let player: ref<PlayerPuppet> = GetPlayer(game);
		let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
		if !IsDefined(ts) || !IsDefined(player) || veh.IsPlayerVehicle() || ArrayContains(this.stateAssetForfeitureList, veh) || !IsTargetPolice(veh) {
			return;
		};
		let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
		let tssx: ref<CopKillerTweaksSSX> = CopKillerTweaksSSX.GetSSX();
		let nJackpot: Int32 = RandRange(0, 250) == 0 ? RandRange(1, 4) : 0; // 0 = None, 1 = Eddies, 2 = Junk, 3 = Drugs
		let nMoneyGiven: Int32 = 0;
		let nItemsGiven: Int32 = 0;
		if RandRange(0, 100) < 25 { // Cash: 25% Chance
			let nMoneyChance: Int32 = RandRange(0, 100);
			if nJackpot == 1 {
				nMoneyGiven = 10000;
			} else if nMoneyChance < 75 {
				nMoneyGiven = RandRange(25, 101);		// 75% Chance: 25-100 Eddies
			} else if nMoneyChance < 95 {
				nMoneyGiven = RandRange(250, 1001);		// 20% Chance: 250-1,000 Eddies
			} else {
				nMoneyGiven = RandRange(2500, 10001);	// 5% Chance: 2,500-10,000 Eddies
			};
			let msg: SimpleScreenMessage;
			msg.message = GetLocalizedText(LocKeyToString(n"CopKiller_Looting_EddiesUnconfiscated")) + ": " + CopKiller_CommaFormatUint64ToString(Cast<Uint64>(nMoneyGiven));
			if !ssx.bMS_ActivityLogReports {
				msg.isShown		= true;
				msg.isInstant	= true;
				msg.duration	= 3.5;
				msg.type		= SimpleMessageType.Money;
				GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
			} else {
				GameInstance.GetActivityLogSystem(game).AddLog(msg.message);
			};
			ts.GiveMoney(player, nMoneyGiven, n"money");
		};
		if RandRange(0, 100) < 15 { // Junk: 15% Chance
			let itemTotal: Int32 = nJackpot == 2 ? RandRange(10, 21) : RandRange(1, 3);
			let itemListTIDs: array<TweakDBID> = ArrayShuffle(nJackpot == 2 ? tssx.ItemList_PervDrops_Trunks() : tssx.ItemList_JunkDrops_Trunks());
			let itemListSize: Int32 = ArraySize(itemListTIDs);
			let itemListQtys: array<Int32>;
			ArrayResize(itemListQtys, itemListSize);
			let i: Int32 = 0;
			while i < itemTotal {
				itemListQtys[RandRange(0, itemListSize)] += 1;
				i += 1;
			};
			i = 0;
			while i < itemListSize {
				if TDBID.IsValid(itemListTIDs[i]) && itemListQtys[i] > 0 {
					ts.GiveItemByTDBID(player, itemListTIDs[i], itemListQtys[i]);
					nItemsGiven += itemListQtys[i];
				};
				i += 1;
			};
		};
		if ssx.bThreadscape && ssx.bMS_Threadscape && RandRange(0, 100) < 10 { // Modded Clothing Item: 10% Chance
			let itemListTIDs: array<TweakDBID> = Threadscape_GetRandomModClothing_Reflected(1);
			if ArraySize(itemListTIDs) > 0 && TDBID.IsValid(itemListTIDs[0]) {
				ts.GiveItemByTDBID(player, itemListTIDs[0], 1);
				nItemsGiven += 1;
			};
		} else if ssx.bMS_BadgeArmorDrops && RandRange(0, 100) < 2 { // Badge Armor Set Piece: 2% Chance
			let itemListTIDs: array<TweakDBID> = tssx.ItemList_BadgeArmorSet();
			ts.GiveItemByTDBID(player, itemListTIDs[RandRange(0, 4)], 1);
			nItemsGiven += 1;
		} else if RandRange(0, 100) < 1 { // Radio: 1% Chance (if no clothing)
			ts.GiveItemByTDBID(player, t"Items.i1_100_ma_slot__radio_left_player_black", 1);
			nItemsGiven += 1;
		};
		if RandRange(0, 100) < 5 { // Drugs: 5% Chance
			if nJackpot == 3 {
				let itemListTIDs: array<TweakDBID> = ArrayShuffle(tssx.ItemList_AddictDrops());
				let itemListSize: Int32 = ArraySize(itemListTIDs);
				let itemQty: Int32 = 0;
				let i: Int32 = 0;
				while i < itemListSize {
					itemQty = RandRange(0, 3); // 0-2 of each Alcohol/Drug
					if TDBID.IsValid(itemListTIDs[i]) && itemQty > 0 {
						ts.GiveItemByTDBID(player, itemListTIDs[i], itemQty);
						nItemsGiven += itemQty;
					};
					i += 1;
				};
			} else {
				let nDrugChance: Int32 = RandRange(0, 100);
				if nDrugChance < 40 {
					ts.GiveItemByTDBID(player, t"Items.Blackmarket_HealthBooster", 1);			// 40% Chance: AssKick
				} else if nDrugChance < 80 {
					ts.GiveItemByTDBID(player, t"Items.Blackmarket_StaminaBooster", 1);			// 40% Chance: Jellytricity
				} else if nDrugChance < 90 {
					ts.GiveItemByTDBID(player, t"Items.Blackmarket_CarryCapacityBooster", 1);	// 10% Chance: Ol' Donkey
				} else {
					ts.GiveItemByTDBID(player, t"Items.Blackmarket_MemoryBooster", 1);			// 10% Chance: RAM Nugs
				};
				nItemsGiven += 1;
			};
		};
		if nMoneyGiven == 0 && nItemsGiven == 0 {
			if RandRange(0, 200) == 0 { // Datashard: 0.5% Chance
				ts.GiveItemByTDBID(player, t"Items.CopKiller_Confiscated_Datashard_01", 1);
				GameInstance.GetActivityLogSystem(game).AddLog("Looted: " + GetLocalizedText("LocKey#999999999000"));
			};
		} else if nMoneyGiven > 0 {
			GameObject.PlaySoundEvent(player, nItemsGiven > 0 ? n"ui_loot_take_all" : n"ui_loot_money");
		} else if nItemsGiven > 0 {
			GameObject.PlaySoundEvent(player, nItemsGiven > 1 ? n"ui_loot_take_all" : n"ui_loot_generic");
		};
		ArrayPush(this.stateAssetForfeitureList, veh);
		let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
		if IsDefined(ps) && EnumInt(ps.GetHeatStage()) < 1 && !StatusEffectSystem.ObjectHasStatusEffectWithTag(player, n"Cloak") {
			ps.ChangeHeatStage(EPreventionHeatStage.Heat_1, "EnterCombat");
		};
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		if !ss.bShowLooted {
			ss.nPrevCopCarsLooted = ss.nCopCarsLooted;
		};
		ss.nCopCarsLooted += 1u;
		ss.bShowLooted = true;
		let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);
		if ssx.bMS_ActivityLogReports && IsDefined(ds) {
			ds.DelayCallback(new CopCarsLootedMessageCallback(), 0.0);
		};
	}

	public static func GetSS() -> ref<CopKillerLootingSS> {
		return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"CopKiller.CopKillerLootingSS") as CopKillerLootingSS;
	}

}

@wrapMethod(PlayerPuppet)
protected cb func OnCombatStateChanged(newState: Int32) -> Bool {
	if !Equals(newState, EnumInt(PlayerCombatState.InCombat)) {
		CopKillerLootingSS.GetSS().ForfeitureListCleanUp();
	};
	return wrappedMethod(newState);
}

public func DropHeldWeapon(npc: wref<NPCPuppet>) -> Void {
	if !IsDefined(npc) { return; }
	let game: GameInstance = npc.GetGame();
	let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
	let lm: ref<LootManager> = GameInstance.GetLootManager(game);
	if !IsDefined(ts) || !IsDefined(lm) { return; }
	let WeaponRgt: ref<WeaponObject> = ts.GetItemInSlot(npc, t"AttachmentSlots.WeaponRight") as WeaponObject;
	let WeaponRgtID: ItemID = IsDefined(WeaponRgt) ? WeaponRgt.GetItemID() : ItemID.None();
	let WeaponRgtRecord: ref<WeaponItem_Record> = !Equals(WeaponRgtID, ItemID.None()) ? WeaponRgt.GetWeaponRecord() : null;
	if !Equals(WeaponRgtRecord, null) && WeaponRgtRecord.CanDrop() && IsNameValid(WeaponRgtRecord.DropObject()) &&
		!WeaponRgt.WeaponHasTag(n"UnequipBlocked") && !WeaponRgt.WeaponHasTag(n"Grenade") && !WeaponRgt.WeaponHasTag(n"Cyberware") &&
		!WeaponRgt.WeaponHasTag(n"HideInBackpackUI") && !WeaponRgt.WeaponHasTag(n"HideInUI") && !WeaponRgt.WeaponHasTag(n"Quest") {
		if RandRange(0, 100) < CopKillerSSX.GetSSX().nMS_BrokenWeaponDropChance || WeaponRgt.WeaponHasTag(n"SmartWeapon") {
			npc.DropWeapons();
		} else {
			npc.m_droppedWeapons = lm.SpawnItemDrop(npc, WeaponRgtID, WeaponRgt.GetWorldPosition(), WeaponRgt.GetWorldOrientation());
		};
	};
}

@wrapMethod(NPCDeathListener)
protected cb func OnStatPoolCustomLimitReached(value: Float) -> Bool {
	let npc: wref<NPCPuppet> = this.npc;
	let bWasAlive: Bool = IsDefined(npc) ? !npc.m_wasJustKilledOrDefeated : false;
	let bResult: Bool = wrappedMethod(value); // Always false, sets npc.m_wasJustKilledOrDefeated to true
	if bWasAlive && IsTargetPolice(npc) && npc.IsHuman() {
		let game: GameInstance = npc.GetGame();
		let cID: TweakDBID = npc.GetRecordID();
		let cRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(cID);
		let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
		let tssx: ref<CopKillerTweaksSSX> = CopKillerTweaksSSX.GetSSX();
		if ssx.bMS_AmmunitionForCopsKilled {
			CopKillerLootingSS.GetSS().InjectMagazineByWeapon(npc);
			let cm: ref<ContainerManager> = GameInstance.GetContainerManager(game);
			if IsDefined(cm) {
				if RandRange(0, 100) < 5 { // 5% Chance of junk item
					let junkDrops: array<TweakDBID> = tssx.ItemList_JunkDrops();
					cm.InjectLoot(npc.GetEntityID(), ItemID.FromTDBID(junkDrops[RandRange(0, ArraySize(junkDrops))]), 1u);
				} else if IsTargetABeatCop(npc) && RandRange(0, 100) < 1 { // 1% Chance of radio (if no junk)
					cm.InjectLoot(npc.GetEntityID(), ItemID.FromTDBID(t"Items.i1_100_ma_slot__radio_left_player_black"), 1u);
				};
			};
		};
		if !IsDefined(cRecord) { return bResult; }
		let tMaxTac_Ranged: array<TweakDBID> = tssx.CharList_MaxTac_Ranged();
		let bMaxTac: Bool = npc.IsMaxTac() && ArrayContains(tMaxTac_Ranged, cID);
		let tElite_Enforcers_Ranged: array<TweakDBID> = tssx.CharList_Enforcers_Ranged();
		let tElite_Enforcers_Cyberware: array<TweakDBID> = tssx.CharList_Enforcers_Cyberware();
		let tElite_Netwatch: array<TweakDBID> = tssx.CharList_Netwatch();
		let bElite: Bool = !bMaxTac && 
			(ArrayContains(tElite_Enforcers_Ranged, cID) || ArrayContains(tElite_Enforcers_Cyberware, cID) || ArrayContains(tElite_Netwatch, cID));
		if cRecord.DropsWeaponOnDeath() && !npc.m_droppedWeapons {
			let shouldDropWeapon: Bool = false;
			if bMaxTac {
				shouldDropWeapon = ssx.bMS_MaxTacDropHeldWeapon;
			} else if bElite {
				shouldDropWeapon = ssx.bMS_EliteCopsDropHeldWeapon;
			} else {
				shouldDropWeapon = ssx.bMS_CopsDropHeldWeapon;
			};
			if shouldDropWeapon {
				DropHeldWeapon(npc);
			};
		};
		if ssx.bLootingQoL && ssx.bMS_LootingQoL && !npc.IsScanned() {
			if IsTargetABountyHunter(npc) {
				LootingQoL_SetCustomDisplayName_Reflected(npc, GetLocalizedText(LocKeyToString(n"Story-base-gameplay-static_data-database-characters-npcs-records-gameplay-prevenetion_system-prevention_bounty_hunter_displayName"))); // 48946 // Bounty Hunter
			} else {
				let newDisplayName: String = StrContains(TDBID.ToStringDEBUG(cID), "hazmat") ? GetLocalizedText(LocKeyToString(n"CopKiller_NCPD_HazmatRank")) : GetNCPDRank(); // Evidence Tech
				if IsDefined(cRecord.ArchetypeData()) && IsDefined(cRecord.ArchetypeData().TypeHandle()) {
					let archetypeName: String = GetLocalizedText(NameToString(cRecord.ArchetypeData().TypeHandle().LocalizedName()));
					if  Equals(archetypeName, GetLocalizedText(LocKeyToString(n"Gameplay-RPG-Archetypes-NPCDMaxTac-GenericRangedT1Male"))) || // 22675 // Beat Cop
						Equals(archetypeName, GetLocalizedText(LocKeyToString(n"Gameplay-RPG-Archetypes-NPCDMaxTac-GenericRangedT2Female"))) || // 22676 // Patrol Officer
						Equals(archetypeName, GetLocalizedText(LocKeyToString(n"Gameplay-RPG-Archetypes-NPCDMaxTac-GenericMeleeT1Male"))) || // 22677 // Beat Cop
						Equals(archetypeName, GetLocalizedText(LocKeyToString(n"Gameplay-RPG-Archetypes-NPCDMaxTac-GenericMeleeT2Female"))) || // 22678 // Patrol Officer
						Equals(archetypeName, GetLocalizedText(LocKeyToString(n"Gameplay-RPG-Archetypes-NPCDMaxTac-GenericRangedT2Male"))) || // 42635 // Patrol Officer
						Equals(archetypeName, "") {
						LootingQoL_SetCustomFactionName_Reflected(npc, "NCPD");
						LootingQoL_SetCustomDisplayName_Reflected(npc, newDisplayName);
					};
				};
				if Equals(npc.GetName(), n"") || Equals(npc.GetName(), n"LocKey#0") {
					LootingQoL_SetCustomDisplayName_Reflected(npc, newDisplayName);
				};
			};
		};
	};
	return bResult;
}

public func GetNCPDRank() -> String {
	let r: Int32 = RandRange(0, 100);
	// 30% Chance of a high rank
	if r < 1  { GetLocalizedText(LocKeyToString(n"CopKiller_NCPD_HighRank_1")); }; // Captain // 0, 1%
	if r < 4  { GetLocalizedText(LocKeyToString(n"CopKiller_NCPD_HighRank_2")); }; // Lieutenant // 1-3, 3%
	if r < 10 { GetLocalizedText(LocKeyToString(n"CopKiller_NCPD_HighRank_3")); }; // Sergeant // 4-9, 6%
	if r < 17 { GetLocalizedText(LocKeyToString(n"CopKiller_NCPD_HighRank_4")); }; // Corporal // 10-16, 7%
	if r < 30 { GetLocalizedText(LocKeyToString(n"CopKiller_NCPD_HighRank_5")); }; // Senior Officer // 17-29, 13%
	// 30-99, 70% Chance of a low rank: Detective, Inspector, Investigator, Patrol Officer, Recruit
	return GetLocalizedText(LocKeyToString(StringToName("CopKiller_NCPD_LowRank_" + ToString(RandRange(1, 6)))));
}

@wrapMethod(NPCDeathListener)
protected cb func OnStatPoolMinValueReached(value: Float) -> Bool {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bMS_AmmunitionForCopsKilled {
		return wrappedMethod(value);
	};
	let npc: wref<NPCPuppet> = this.npc;
	let bWasAlive: Bool = IsDefined(npc) ? !npc.m_wasJustKilledOrDefeated : false;
	let bResult: Bool = wrappedMethod(value); // Always false, sets npc.m_wasJustKilledOrDefeated to true
	if bWasAlive && IsTargetPolice(npc) && npc.IsMechanical() {
		let bAndroid: Bool = npc.IsAndroid();
		if bAndroid {
			CopKillerLootingSS.GetSS().InjectMagazineByWeapon(npc);
			let cRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(npc.GetRecordID());
			if ssx.bMS_EliteCopsDropHeldWeapon && IsDefined(cRecord) && cRecord.DropsWeaponOnDeath() && !npc.m_droppedWeapons {
				let tElite_Androids: array<TweakDBID> = CopKillerTweaksSSX.GetSSX().CharList_Androids();
				if ArrayContains(tElite_Androids, npc.GetRecordID()) {
					DropHeldWeapon(npc);
				};
			};
		};
		let cm: ref<ContainerManager> = GameInstance.GetContainerManager(GetGameInstance());
		if IsDefined(cm) {
			cm.InjectLoot(npc.GetEntityID(), ItemID.FromTDBID(t"Items.CommonMaterial1"), Cast<Uint32>(bAndroid ? RandRange(1, 4) : RandRange(2, 5)));
		};
	};
	return bResult;
}

public class AddMagEffector extends Effector {

	public func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
		super.Initialize(record, game, parentRecord);
	}

	public func Uninitialize(game: GameInstance) -> Void {
		super.Uninitialize(game);
	}

	public func ActionOn(owner: ref<GameObject>) -> Void {
		let game: GameInstance = GetGameInstance();
		let player: ref<PlayerPuppet> = owner as PlayerPuppet;
		let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
		if IsDefined(player) && IsDefined(ts) {
			let playerMags: array<wref<gameItemData>>;
			ts.GetItemListByTag(player, n"PoliceMag", playerMags);
			let itemID: ItemID = IsDefined(playerMags[0]) ? playerMags[0].GetID() : ItemID.None();
			if ItemID.IsValid(itemID) && itemID != ItemID.None() {
				if CopKillerLootingSS.GetSS().GiveAmmoByMagazineItem(ts, player, ItemID.GetTDBID(itemID)) {
					ts.RemoveItem(player, itemID, 1);
				};
			};	
		};
	}
	
}

@wrapMethod(Inventory)
protected final cb func OnInteractionUsed(evt: ref<InteractionChoiceEvent>) -> Bool {
	let game: GameInstance = GetGameInstance();
	let lootActionWrapper: LootChoiceActionWrapper = LootChoiceActionWrapper.Unwrap(evt);
	let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
	if IsDefined(ts) && (Equals(lootActionWrapper.action, n"Loot") || Equals(lootActionWrapper.action, n"Take")) {
		if CopKillerLootingSS.GetSS().GiveAmmoByMagazineItem(ts, GetPlayer(game), ItemID.GetTDBID(lootActionWrapper.itemId)) {
			let gameObject: ref<GameObject> = this.GetEntity() as GameObject;
			GameInstance.GetAudioSystem(game).PlayItemActionSound(lootActionWrapper.action, RPGManager.GetItemData(game, gameObject, lootActionWrapper.itemId));
			ts.RemoveItem(gameObject, lootActionWrapper.itemId, 1);
			return true;
		};
	};
	return wrappedMethod(evt);
}

@wrapMethod(VehicleComponent)
protected cb func OnOpenTrunk(evt: ref<VehicleOpenTrunk>) -> Bool {
	let bResult: Bool = wrappedMethod(evt);
	if CopKillerSSX.GetSSX().bMS_StateAssetForfeiture {
		CopKillerLootingSS.GetSS().GivePoliceTrunkItems(this.GetVehicle());
	};
	return bResult;
}
