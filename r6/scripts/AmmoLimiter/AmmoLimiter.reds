module AmmoLimiter.Core
import AmmoLimiter.Config.*

// ≡ UTILITY CACHE
public struct ALData{
	public let ammoTDBID:TweakDBID;
	public let limit:Int32;
	public let ammoBox:Int32;
	public let handLimit:Int32;
	public let handMin:Int32;
	public let handMax:Int32;
	public let ammoWeight:Float;
	public let priceMult:Float;
	public let ammoConv:Float;
	public let ammoCraft:Int32;
}

// ≡ UTILITIES
public class ALUtils{
	// CORE HELPERS
	public static func GetAmmoTypeNames()->array<String>{return ["Handgun","Rifle","Shotgun","SniperRifle"];}

	public static func GetAmmoTDBID(ammoType:String)->TweakDBID{return TDBID.Create("Ammo."+ammoType+"Ammo");}

	public static func GetAmmoTypeFromID(ammoID:ItemID)->String{
		let tdbid=ItemID.GetTDBID(ammoID);
		// Standard=Handgun alias & SlaughtomaticPlatinum support
		if Equals(tdbid,t"Ammo.Standard") || Equals(tdbid,t"Ammo.SlaughtomaticPlatinum"){return "Handgun";}

		for ammoType in ALUtils.GetAmmoTypeNames(){if Equals(tdbid,ALUtils.GetAmmoTDBID(ammoType)){return ammoType;}}

		return "";
	}

	public static func GetActiveWeaponAmmoType(player:ref<PlayerPuppet>)->String{
		let weapon=ScriptedPuppet.GetActiveWeapon(player) as WeaponObject;
		// Check validity and ensure weapon is not melee to prevent false ammo warnings
		if !IsDefined(weapon) || weapon.IsMelee(){return "";}

		return ALUtils.GetAmmoTypeFromID(WeaponObject.GetAmmoType(weapon));
	}

	// CONFIG DATA LOADER
	public static func GetALData(ammoType:String)->ALData{
		let cfg:ref<AmmoLimiterConfig>=ALSystem.GetConfig();
		let data:ALData;
		data.ammoTDBID=ALUtils.GetAmmoTDBID(ammoType);
		let convBase:Float=Cast<Float>(cfg.craftingCompForAmmo)*Cast<Float>(cfg.ammoConvRate);
		switch ammoType{
			case "Handgun":
				data.limit=cfg.ammoLimitHandgun;
				data.ammoBox=cfg.ammoBoxHandgun;
				data.handLimit=cfg.handLimitHandgun;
				data.handMin=cfg.handMinHandgun;
				data.handMax=cfg.handMaxHandgun;
				data.ammoWeight=cfg.ammoWeightHandgun;
				data.priceMult=cfg.ammoPriceHandgun;
				data.ammoCraft=cfg.ammoCraftHandgun;
				data.ammoConv=convBase/Cast<Float>(data.ammoCraft);
				break;
			case "Rifle":
				data.limit=cfg.ammoLimitRifle;
				data.ammoBox=cfg.ammoBoxRifle;
				data.handLimit=cfg.handLimitRifle;
				data.handMin=cfg.handMinRifle;
				data.handMax=cfg.handMaxRifle;
				data.ammoWeight=cfg.ammoWeightRifle;
				data.priceMult=cfg.ammoPriceRifle;
				data.ammoCraft=cfg.ammoCraftRifle;
				data.ammoConv=convBase/Cast<Float>(data.ammoCraft);
				break;
			case "Shotgun":
				data.limit=cfg.ammoLimitShotgun;
				data.ammoBox=cfg.ammoBoxShotgun;
				data.handLimit=cfg.handLimitShotgun;
				data.handMin=cfg.handMinShotgun;
				data.handMax=cfg.handMaxShotgun;
				data.ammoWeight=cfg.ammoWeightShotgun;
				data.priceMult=cfg.ammoPriceShotgun;
				data.ammoCraft=cfg.ammoCraftShotgun;
				data.ammoConv=convBase/Cast<Float>(data.ammoCraft);
				break;
			case "SniperRifle":
				data.limit=cfg.ammoLimitSniper;
				data.ammoBox=cfg.ammoBoxSniper;
				data.handLimit=cfg.handLimitSniper;
				data.handMin=cfg.handMinSniper;
				data.handMax=cfg.handMaxSniper;
				data.ammoWeight=cfg.ammoWeightSniper;
				data.priceMult=cfg.ammoPriceSniper;
				data.ammoCraft=cfg.ammoCraftSniper;
				data.ammoConv=convBase/Cast<Float>(data.ammoCraft);
				break;
		}
		return data;
	}

	// AMMO TYPE FROM RECORD
	public static func GetAmmoTypeFromRecord(itemRecord:ref<Item_Record>)->String{
		if !IsDefined(itemRecord){return "";}

		if NotEquals(itemRecord.ItemType().Type(),gamedataItemType.Con_Ammo){return "";}

		let tdbid=itemRecord.GetID();
		// Standard=Handgun alias & SlaughtomaticPlatinum support
		if Equals(tdbid,t"Ammo.Standard") || Equals(tdbid,t"Ammo.SlaughtomaticPlatinum"){return "Handgun";}

		for ammoType in ALUtils.GetAmmoTypeNames(){if Equals(tdbid,ALUtils.GetAmmoTDBID(ammoType)){return ammoType;}}

		let tdbidString=TDBID.ToStringDEBUG(tdbid);
		if StrContains(tdbidString,"Handgun"){return "Handgun";}
		if StrContains(tdbidString,"Shotgun"){return "Shotgun";}
		if StrContains(tdbidString,"Sniper"){return "SniperRifle";}
		if StrContains(tdbidString,"Rifle"){return "Rifle";}

		return "";
	}

	// LIMIT ACTION COMPUTE
	public static func ComputeLimitAction(currentQty:Int32,limit:Int32,convRate:Int32,smartEnabled:Bool)->Vector2{
		let excess:Int32=currentQty-limit;
		if excess<=0{return new Vector2(0.0,0.0);}

		if convRate<=0{return new Vector2(Cast<Float>(excess),0.0);}

		let qtyToRemove:Int32;
		let rewardCount:Int32;
		if smartEnabled{
			let packs:Int32=(excess+convRate-1)/convRate;
			qtyToRemove=packs*convRate;
			rewardCount=packs;
			if qtyToRemove>currentQty{
				qtyToRemove=currentQty;
				rewardCount=currentQty/convRate;
			}
		}
		else{
			rewardCount=excess/convRate;
			qtyToRemove=rewardCount*convRate;
		}
		return new Vector2(Cast<Float>(qtyToRemove),Cast<Float>(rewardCount));
	}

	// COMPUTE SMART CONV
	public static func ComputeSmartConv(amount:Int32,convRate:Int32,smart:Bool)->Vector2{
		if convRate<=0 || amount<=0{return new Vector2(0.0,0.0);}

		let usable:Int32;
		if smart{usable=(amount/convRate)*convRate;}
		else{usable=amount;}
		let reward=usable/convRate;
		return new Vector2(Cast<Float>(usable),Cast<Float>(reward));
	}

	// PICKER ENHANCEMENT
	public static func UpdatePickerAmmoDisplay(picker:ref<ItemQuantityPickerController>,quantity:Int32,itemRecord:ref<Item_Record>)->Void{
		if !IsDefined(itemRecord){return;}

		let ammoType=ALUtils.GetAmmoTypeFromRecord(itemRecord);
		if Equals(ammoType,""){return;}

		let ammoData=ALUtils.GetALData(ammoType);
		let cfg=ALSystem.GetConfig();
		// Clean name
		let originalName=inkTextRef.GetText(picker.m_itemNameText);
		let parenPos=StrFindFirst(originalName," (");
		let cleanName=parenPos>0 ? StrLeft(originalName,parenPos) : originalName;
		let suffix:String="";
		let totalWeight:Float;
		switch picker.m_actionType{
			case QuantityPickerActionType.Craft:
				let totalAmmo=quantity*ammoData.ammoCraft;
				suffix="("+IntToString(totalAmmo)+" "+GetLocalizedTextByKey(n"AmmoLimiter-UI-Total")+")";
				totalWeight=Cast<Float>(totalAmmo)*ammoData.ammoWeight;
				break;
			case QuantityPickerActionType.Disassembly:
				let convRate=(ammoData.ammoCraft*100)/(cfg.craftingCompForAmmo*cfg.ammoConvRate);
				let res=ALUtils.ComputeSmartConv(quantity,convRate,true);
				let compResult=RoundF(res.Y);
				suffix="("+IntToString(compResult)+" "+GetLocalizedTextByKey(n"AmmoLimiter-UI-Total")+")";
				totalWeight=Cast<Float>(quantity)*ammoData.ammoWeight;
				break;
			default:totalWeight=Cast<Float>(quantity)*ammoData.ammoWeight;
		}
		// Apply title
		if NotEquals(suffix,""){inkTextRef.SetText(picker.m_itemNameText,cleanName+" "+suffix);}

		// Apply weight precision
		inkTextRef.SetText(picker.m_weightText,FloatToStringPrec(totalWeight,3));
	}

	public static func ALMessage(gI:GameInstance,message:String)->Void{
		let bB=GameInstance.GetBlackboardSystem(gI).Get(GetAllBlackboardDefs().UI_Notifications);
		let msg:SimpleScreenMessage;
		msg.isShown=true;
		msg.message=message;
		bB.SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage,ToVariant(msg),true);
	}
}

// ≡ MAIN SYSTEM & INIT CLASS
public class ALSystem extends ScriptableSystem{
	public let g_AmmoLimiter:Bool=true;
	private let m_cfgCache:ref<AmmoLimiterConfig>;
	private let m_cacheValidUntil:Float=0.0;
	private let CONFIG_CACHE_DURATION:Float=1.5;
	private let m_ammoCache:ref<ALAmmoCache>;
	private let m_lastWarningTime:array<Float>;

	private func OnAttach()->Void{
		let delaySys=GameInstance.GetDelaySystem(this.GetGameInstance());
		let callback=new ALInitCallback();
		ArrayResize(this.m_lastWarningTime,4);
		let i=0;while i<4{this.m_lastWarningTime[i]=0.0;i+=1;}
		callback.system=this;
		delaySys.DelayCallback(callback,0.125);
	}

	public static func GetInstance()->ref<ALSystem>{
		let container=GameInstance.GetScriptableSystemsContainer(GetGameInstance());
		if !IsDefined(container){return null;}

		return container.Get(n"ALSystem") as ALSystem;
	}

	// STATIC GETTERS
	public static func GetConfig()->ref<AmmoLimiterConfig>{
		let sys=ALSystem.GetInstance();
		if IsDefined(sys){return sys.GetConfigCache();}

		return new AmmoLimiterConfig();
	}

	// CONFIG CACHE (instance)
	private func GetConfigCache()->ref<AmmoLimiterConfig>{
		let now=EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance()));
		if !IsDefined(this.m_cfgCache) || now>=this.m_cacheValidUntil{
			this.m_cfgCache=new AmmoLimiterConfig();
			this.m_cacheValidUntil=now+this.CONFIG_CACHE_DURATION;
		}
		return this.m_cfgCache;
	}

	// AMMO CACHE
	public func GetAmmoCache()->ref<ALAmmoCache>{
		if !IsDefined(this.m_ammoCache){this.m_ammoCache=ALAmmoCache.Create();}
		return this.m_ammoCache;
	}

	// WARNING SYSTEM
	public func CanWarn(index:Int32,currentTime:Float,cooldown:Float)->Bool{
		if index<0 || index>=ArraySize(this.m_lastWarningTime){return false;}

		return currentTime-this.m_lastWarningTime[index]>=cooldown;
	}

	public func SetLastWarning(index:Int32,time:Float)->Void{if index>=0 && index<ArraySize(this.m_lastWarningTime){this.m_lastWarningTime[index]=time;}}


	public func ApplyTweaks()->Void{
		let cfg=this.GetConfigCache();
		let ammoTypes=ALUtils.GetAmmoTypeNames();
		this.ApplyCraftingBaseAmount(cfg);
		this.CreateAndApplyAmmoMods(cfg,ammoTypes);
		this.ApplyHandSys(cfg,ammoTypes);
		this.ApplyAmmoBoxQties(cfg);
	}

	private final func ApplyCraftingBaseAmount(cfg:ref<AmmoLimiterConfig>)->Void{
		let baseCraftPath=t"Ammo.AmmoBase_inline1";
		TweakDBManager.SetFlat(baseCraftPath+t".amount",cfg.craftingCompForAmmo);
		TweakDBManager.UpdateRecord(baseCraftPath);
	}

	private final func CreateAndApplyAmmoMods(cfg:ref<AmmoLimiterConfig>,ammoTypes:array<String>)->Void{
		for ammoType in ammoTypes{
			let ammoData=ALUtils.GetALData(ammoType);
			let basePath="AmmoLimiter."+ammoType;

			// Bypass Vanilla Quantity Limit
			let vanillaInline=ammoData.ammoTDBID+t"_inline0";
			TweakDBManager.SetFlat(vanillaInline+t".value",9999.0);
			TweakDBManager.UpdateRecord(vanillaInline);

			let weightBaseModID:TweakDBID;
			let weightMultModID:TweakDBID;
			let useWeight=ammoData.ammoWeight>0.0;
			if useWeight{
				weightBaseModID=TDBID.Create(basePath+"_WeightBase");
				TweakDBManager.CreateRecord(StringToName(basePath+"_WeightBase"),n"gamedataConstantStatModifier_Record");
				TweakDBManager.SetFlat(weightBaseModID+t".modifierType",n"Additive");
				TweakDBManager.SetFlat(weightBaseModID+t".statType",t"BaseStats.Weight");
				TweakDBManager.SetFlat(weightBaseModID+t".value",1.0);

				weightMultModID=TDBID.Create(basePath+"_WeightMult");
				TweakDBManager.CreateRecord(StringToName(basePath+"_WeightMult"),n"gamedataConstantStatModifier_Record");
				TweakDBManager.SetFlat(weightMultModID+t".modifierType",n"Multiplier");
				TweakDBManager.SetFlat(weightMultModID+t".statType",t"BaseStats.Weight");
				TweakDBManager.SetFlat(weightMultModID+t".value",ammoData.ammoWeight);
			}

			let buyModID=TDBID.Create(basePath+"_BuyMult");
			TweakDBManager.CreateRecord(StringToName(basePath+"_BuyMult"),n"gamedataConstantStatModifier_Record");
			TweakDBManager.SetFlat(buyModID+t".modifierType",n"Multiplier");
			TweakDBManager.SetFlat(buyModID+t".statType",t"BaseStats.Price");
			TweakDBManager.SetFlat(buyModID+t".value",ammoData.priceMult);

			let sellModID=TDBID.Create(basePath+"_SellMult");
			TweakDBManager.CreateRecord(StringToName(basePath+"_SellMult"),n"gamedataConstantStatModifier_Record");
			TweakDBManager.SetFlat(sellModID+t".modifierType",n"Multiplier");
			TweakDBManager.SetFlat(sellModID+t".statType",t"BaseStats.Price");
			TweakDBManager.SetFlat(sellModID+t".value",ammoData.priceMult*cfg.ammoSellMult);

			let statMods:array<TweakDBID>=[vanillaInline];
			if useWeight{
				ArrayPush(statMods,weightBaseModID);
				ArrayPush(statMods,weightMultModID);
			}

			let buyPrices:array<TweakDBID>=[t"Price.Ammo",t"Price.BuyPrice_StreetCred_Discount",t"Price.PowerAmmo",buyModID];
			let sellPrices:array<TweakDBID>=[t"Price.Ammo",t"Price.PowerAmmo",sellModID];

			TweakDBManager.SetFlat(ammoData.ammoTDBID+t".statModifiers",statMods);
			TweakDBManager.SetFlat(ammoData.ammoTDBID+t".buyPrice",buyPrices);
			TweakDBManager.SetFlat(ammoData.ammoTDBID+t".sellPrice",sellPrices);
			TweakDBManager.SetFlat(ammoData.ammoTDBID+t".objectActions",[t"ItemAction.Drop",t"ItemAction.Disassemble"]);

			// Crafting Recipe
			let recipeID=TDBID.Create("Ammo.Recipe"+ammoType+"Ammo_inline0");
			TweakDBManager.SetFlat(recipeID+t".amount",ammoData.ammoCraft);

			// Records Update
			if useWeight{
				TweakDBManager.UpdateRecord(weightBaseModID);
				TweakDBManager.UpdateRecord(weightMultModID);
			}
			TweakDBManager.UpdateRecord(buyModID);
			TweakDBManager.UpdateRecord(sellModID);
			TweakDBManager.UpdateRecord(recipeID);
			TweakDBManager.UpdateRecord(ammoData.ammoTDBID);
		}

		// STANDARD ALIASES (Handgun alias @ custom Slaught-O-Matic price)
		let handgunData=ALUtils.GetALData("Handgun");
		let aliases:array<TweakDBID>=[t"Ammo.Standard",t"Ammo.SlaughtomaticPlatinum"];
		let bases:array<String>=["AmmoLimiter.Standard","AmmoLimiter.SlaughtomaticPlatinum"];
		let stdPriceMult=cfg.ammoPriceSlaughtomatic;
		let idx:Int32=0;
		while idx<ArraySize(aliases){
			let stdTDBID=aliases[idx];
			let stdBase=bases[idx];

			// Bypass Vanilla
			let stdVanillaInline=stdTDBID+t"_inline0";
			TweakDBManager.SetFlat(stdVanillaInline+t".value",9999.0);
			TweakDBManager.UpdateRecord(stdVanillaInline);

			// Weight (same as Handgun)
			let stdWeightBaseID:TweakDBID;
			let stdWeightMultID:TweakDBID;
			let stdUseWeight=handgunData.ammoWeight>0.0;
			if stdUseWeight{
				stdWeightBaseID=TDBID.Create(stdBase+"_WeightBase");
				TweakDBManager.CreateRecord(StringToName(stdBase+"_WeightBase"),n"gamedataConstantStatModifier_Record");
				TweakDBManager.SetFlat(stdWeightBaseID+t".modifierType",n"Additive");
				TweakDBManager.SetFlat(stdWeightBaseID+t".statType",t"BaseStats.Weight");
				TweakDBManager.SetFlat(stdWeightBaseID+t".value",1.0);

				stdWeightMultID=TDBID.Create(stdBase+"_WeightMult");
				TweakDBManager.CreateRecord(StringToName(stdBase+"_WeightMult"),n"gamedataConstantStatModifier_Record");
				TweakDBManager.SetFlat(stdWeightMultID+t".modifierType",n"Multiplier");
				TweakDBManager.SetFlat(stdWeightMultID+t".statType",t"BaseStats.Weight");
				TweakDBManager.SetFlat(stdWeightMultID+t".value",handgunData.ammoWeight);
			}

			// Price Mult
			let stdBuyModID=TDBID.Create(stdBase+"_BuyMult");
			TweakDBManager.CreateRecord(StringToName(stdBase+"_BuyMult"),n"gamedataConstantStatModifier_Record");
			TweakDBManager.SetFlat(stdBuyModID+t".modifierType",n"Multiplier");
			TweakDBManager.SetFlat(stdBuyModID+t".statType",t"BaseStats.Price");
			TweakDBManager.SetFlat(stdBuyModID+t".value",stdPriceMult);

			let stdSellModID=TDBID.Create(stdBase+"_SellMult");
			TweakDBManager.CreateRecord(StringToName(stdBase+"_SellMult"),n"gamedataConstantStatModifier_Record");
			TweakDBManager.SetFlat(stdSellModID+t".modifierType",n"Multiplier");
			TweakDBManager.SetFlat(stdSellModID+t".statType",t"BaseStats.Price");
			TweakDBManager.SetFlat(stdSellModID+t".value",stdPriceMult*cfg.ammoSellMult);

			// Apply
			let stdStatMods:array<TweakDBID>=[stdVanillaInline];
			if stdUseWeight{
				ArrayPush(stdStatMods,stdWeightBaseID);
				ArrayPush(stdStatMods,stdWeightMultID);
			}

			let stdBuyPrices:array<TweakDBID>=[t"Price.Ammo",t"Price.BuyPrice_StreetCred_Discount",t"Price.PowerAmmo",stdBuyModID];
			let stdSellPrices:array<TweakDBID>=[t"Price.Ammo",t"Price.PowerAmmo",stdSellModID];

			TweakDBManager.SetFlat(stdTDBID+t".statModifiers",stdStatMods);
			TweakDBManager.SetFlat(stdTDBID+t".buyPrice",stdBuyPrices);
			TweakDBManager.SetFlat(stdTDBID+t".sellPrice",stdSellPrices);
			TweakDBManager.SetFlat(stdTDBID+t".objectActions",[t"ItemAction.Drop",t"ItemAction.Disassemble"]);

			// Records Update
			if stdUseWeight{
				TweakDBManager.UpdateRecord(stdWeightBaseID);
				TweakDBManager.UpdateRecord(stdWeightMultID);
			}
			TweakDBManager.UpdateRecord(stdBuyModID);
			TweakDBManager.UpdateRecord(stdSellModID);
			TweakDBManager.UpdateRecord(stdTDBID);
			
			idx+=1;
		}
	}

	private final func ApplyHandSys(cfg:ref<AmmoLimiterConfig>,ammoTypes:array<String>)->Void{
		for ammoType in ammoTypes{
			let ammoData=ALUtils.GetALData(ammoType);
			let recordID=TDBID.Create("Ammo.Handicap"+ammoType+"AmmoPreset");
			let limit=!cfg.isHandicapEnabled ? 9999 : cfg.isCustomHandMode ? ammoData.handLimit : ammoData.limit;
			let min=!cfg.isHandicapEnabled ? 0 : cfg.isCustomHandMode ? ammoData.handMin : 0;
			let max=!cfg.isHandicapEnabled ? 0 : cfg.isCustomHandMode ? ammoData.handMax : ammoData.limit/10;

			TweakDBManager.SetFlat(recordID+t".handicapLimit",limit);
			TweakDBManager.SetFlat(recordID+t".handicapMinQty",min);
			TweakDBManager.SetFlat(recordID+t".handicapMaxQty",max);
			TweakDBManager.UpdateRecord(recordID);
		}
	}

	private final func ApplyAmmoBoxQties(cfg:ref<AmmoLimiterConfig>)->Void{
		let mappings=[["Handgun","AmmoLootTable_inline0"],["Shotgun","AmmoLootTable_inline1"],["Rifle","AmmoLootTable_inline2"],["SniperRifle","AmmoLootTable_inline3"]];
		let i:Int32=0;
		while i<ArraySize(mappings){
			let ammoType=mappings[i][0];
			let lootTableID=mappings[i][1];
			let ammoData=ALUtils.GetALData(ammoType);
			let recordID=TDBID.Create("Ammo."+lootTableID);

			TweakDBManager.SetFlat(recordID+t".dropCountMin",ammoData.ammoBox/2);
			TweakDBManager.SetFlat(recordID+t".dropCountMax",ammoData.ammoBox);
			TweakDBManager.UpdateRecord(recordID);

			i+=1;
		}
	}
}

// ≡ MINIMAL CALLBACK
public class ALInitCallback extends DelayCallback{
	public let system:wref<ALSystem>;
	protected cb func Call()->Bool{if IsDefined(this.system){this.system.ApplyTweaks();}return true;}
}

// ≡ AMMO LIMITER SYSTEM
public class ALAmmoCache{
	private let m_data:ref<inkHashMap>;
	private let m_dropGuard:ref<inkHashMap>;

	public static func Create()->ref<ALAmmoCache>{
		let self=new ALAmmoCache();
		self.m_data=new inkHashMap();
		self.m_dropGuard=new inkHashMap();
		return self;
	}

	public func Get(hash:Uint64)->Int32{
		if this.m_data.KeyExist(hash){
			let val=this.m_data.Get(hash) as IntRef;
			return IsDefined(val) ? val.GetValue() : 0;
		}
		return 0;
	}

	public func Set(hash:Uint64,qty:Int32)->Void{
		if this.m_data.KeyExist(hash){this.m_data.Remove(hash);}
		this.m_data.Insert(hash,IntRef.Create(qty));
	}

	public func SetDropGuard(hash:Uint64,qty:Int32)->Void{
		if this.m_dropGuard.KeyExist(hash){this.m_dropGuard.Remove(hash);}
		this.m_dropGuard.Insert(hash,IntRef.Create(qty));
	}

	public func ConsumeDropGuard(hash:Uint64,diff:Int32)->Bool{
		if !this.m_dropGuard.KeyExist(hash){return false;}
		let val=this.m_dropGuard.Get(hash) as IntRef;
		if !IsDefined(val){return false;}
		let guard=val.GetValue();
		if diff<=guard{
			this.m_dropGuard.Remove(hash);
			if diff<guard{this.SetDropGuard(hash,guard-diff);}
			return true;
		}
		return false;
	}

	public func HasDropGuard(hash:Uint64)->Bool{
		return this.m_dropGuard.KeyExist(hash);
	}
}

public class IntRef extends IScriptable{
	private let m_value:Int32;

	public static func Create(v:Int32)->ref<IntRef>{
		let self=new IntRef();
		self.m_value=v;
		return self;
	}

	public func GetValue()->Int32{return this.m_value;}
}

@wrapMethod(UIInventoryScriptableInventoryListenerCallback)
public func OnItemQuantityChanged(_itemID:ItemID,diff:Int32,total:Uint32,flaggedAsSilent:Bool)->Void{
	let itemRecord=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(_itemID));
	if itemRecord.TagsContains(n"Ammo"){
		let gI=GetGameInstance();
		if !GameInstance.IsValid(gI){wrappedMethod(_itemID,diff,total,flaggedAsSilent);return;}

		let sys=ALSystem.GetInstance();
		let hash=ItemID.GetCombinedHash(_itemID);
		if IsDefined(sys){
			sys.GetAmmoCache().Set(hash,Cast<Int32>(total));
		}
		let bbSys=GameInstance.GetBlackboardSystem(gI);
		let uiBB=bbSys.Get(GetAllBlackboardDefs().UI_System);
		let isInMenu=uiBB.GetBool(GetAllBlackboardDefs().UI_System.IsInMenu);
		if isInMenu || diff<=0{
			wrappedMethod(_itemID,diff,total,flaggedAsSilent);return;
		}

		// Anti-loop: re-pickup of dropped ammo → re-drop immediately
		if IsDefined(sys) && sys.GetAmmoCache().ConsumeDropGuard(hash,diff){
			let player=GetPlayer(gI);
			let dropInstr:array<DropInstruction>;
			ArrayPush(dropInstr,DropInstruction.Create(_itemID,diff));
			GameInstance.GetLootManager(gI).SpawnItemDropOfManyItems(player,dropInstr,n"playerDropBag",player.GetWorldPosition());
			sys.GetAmmoCache().SetDropGuard(hash,diff);
			let tS=GameInstance.GetTransactionSystem(gI);
			let newQty=tS.GetItemQuantity(player,_itemID);
			sys.GetAmmoCache().Set(hash,newQty);
			wrappedMethod(_itemID,diff,total,false);return;
		}

		let ammoType=ALUtils.GetAmmoTypeFromID(_itemID);
		if NotEquals(ammoType,""){
			let cfg=ALSystem.GetConfig();
			let ammoData=ALUtils.GetALData(ammoType);
			let player=GetPlayer(gI);
			let totalInt=Cast<Int32>(total);
			let activeAmmoType=ALUtils.GetActiveWeaponAmmoType(player);
			let isActiveAmmo=Equals(ammoType,activeAmmoType);
			let effectLimit:Int32;
			if cfg.sleepingAmmoControl && !isActiveAmmo{effectLimit=totalInt-diff;}
			else if isActiveAmmo && cfg.activeWeapBonus!=100{effectLimit=(ammoData.limit*cfg.activeWeapBonus)/100;}
			else{effectLimit=ammoData.limit;}
			if totalInt>effectLimit{
				let convRate=(ammoData.ammoCraft*100)/(cfg.craftingCompForAmmo*cfg.ammoConvRate);
				let res=ALUtils.ComputeLimitAction(totalInt,effectLimit,convRate,cfg.smartConv);
				let removeQty=Cast<Int32>(res.X);
				let rewardQty=Cast<Int32>(res.Y);
				let excess=totalInt-effectLimit;
				let wasted=excess-removeQty;
				if removeQty>0 || wasted>0{
					let tS=GameInstance.GetTransactionSystem(gI);
					let actualQty=tS.GetItemQuantity(player,_itemID);
					let safeRemove=Min(removeQty,actualQty);
					let safeWasted=Min(wasted,actualQty-safeRemove);
					let totalRemove=safeRemove+safeWasted;
					if totalRemove>0{
						let safeReward=safeRemove!=removeQty && removeQty>0 ? (rewardQty*safeRemove)/removeQty : rewardQty;
						let totalEddies=cfg.autoSell>0 ? (RPGManager.CalculateSellPrice(gI,player,_itemID)*safeRemove*cfg.autoSell)/100 : 0;
						let dispName=GetLocalizedTextByKey(itemRecord.DisplayName());
						let didAction=false;
						if safeReward<=0 && totalEddies<=0{
							let dropInstr:array<DropInstruction>;
							ArrayPush(dropInstr,DropInstruction.Create(_itemID,totalRemove));
							GameInstance.GetLootManager(gI).SpawnItemDropOfManyItems(player,dropInstr,n"playerDropBag",player.GetWorldPosition());
							didAction=true;
							if IsDefined(sys){sys.GetAmmoCache().SetDropGuard(hash,totalRemove);}
							if cfg.messageDisplay{
								let dropMsg=GetLocalizedTextByKey(n"AmmoLimiter-Message-Dropped");
								ALUtils.ALMessage(gI,s"\(totalRemove) \(dispName) \(dropMsg).");
							}
						}
						else{
							let itemData=tS.GetItemData(player,_itemID);
							if IsDefined(itemData){itemData.SetDynamicTag(n"SkipActivityLog");}
							tS.RemoveItem(player,_itemID,safeRemove);
							didAction=true;
							if safeWasted>0{
								let dropInstr:array<DropInstruction>;
								ArrayPush(dropInstr,DropInstruction.Create(_itemID,safeWasted));
								let dropPos=player.GetWorldPosition();
								let forward=player.GetWorldForward();
								dropPos.X+=forward.X*0.5;
								dropPos.Y+=forward.Y*0.5;
								dropPos.Z+=0.5;
								GameInstance.GetLootManager(gI).SpawnItemDropOfManyItems(player,dropInstr,n"playerDropBag",dropPos);
								if IsDefined(sys){sys.GetAmmoCache().SetDropGuard(hash,safeWasted);}
								if cfg.messageDisplay{
									let dropMsg=GetLocalizedTextByKey(n"AmmoLimiter-Message-Dropped");
									ALUtils.ALMessage(gI,s"\(safeWasted) \(dispName) \(dropMsg).");
								}
							}
							let msgParts="";
							if safeReward>0{
								let matID=t"Items.CommonMaterial1";
								tS.GiveItem(player,ItemID.FromTDBID(matID),safeReward);
								if cfg.messageDisplay{
									let matName=GetLocalizedTextByKey(TweakDBInterface.GetItemRecord(matID).DisplayName());
									msgParts=s"\(safeReward) \(matName)";
								}
							}
							if totalEddies>0{
								tS.GiveItem(player,ItemID.FromTDBID(t"Items.money"),totalEddies);
								if cfg.messageDisplay{
									if NotEquals(msgParts,""){msgParts+="\n+ ";}
									msgParts+=s"\(totalEddies) €$";
								}
							}
							if cfg.messageDisplay && NotEquals(msgParts,""){
								let craftMsg=GetLocalizedTextByKey(n"AmmoLimiter-Message-Crafted");
								ALUtils.ALMessage(gI,s"\(safeRemove) \(dispName) \(craftMsg) \(msgParts)");
							}
						}
						if IsDefined(sys){
							let newQty=tS.GetItemQuantity(player,_itemID);
							sys.GetAmmoCache().Set(hash,newQty);
						}
						if didAction{wrappedMethod(_itemID,diff,total,false);return;}
					}
				}
			}
		}
	}

	wrappedMethod(_itemID,diff,total,flaggedAsSilent);
}

// ≡ BUY SYSTEM LIMIT
@wrapMethod(FullscreenVendorGameController)
private final func GetMaxQuantity(item:wref<UIInventoryItem>,opt isPlayerItem:Bool,opt isBuybackStack:Bool)->Int32{
	let tags=item.GetItemRecord().Tags();
	if !ArrayContains(tags,n"Ammo"){return wrappedMethod(item,isPlayerItem,isBuybackStack);}

	if isPlayerItem{return wrappedMethod(item,isPlayerItem,isBuybackStack);}

	let cfg=ALSystem.GetConfig();
	let ammoData=ALUtils.GetALData(ALUtils.GetAmmoTypeFromID(item.GetID()));
	let player=GetPlayer(this.m_VendorDataManager.GetVendorInstance().GetGame());
	let tS=GameInstance.GetTransactionSystem(player.GetGame());
	let currentQty=tS.GetItemQuantity(player,item.GetID());
	let vendorQty=item.GetQuantity();
	if cfg.strictLimit{
		let space=Max(0,ammoData.limit-currentQty);
		return Min(space,vendorQty);
	}

	else{
		if currentQty<ammoData.limit{
			let space=ammoData.limit-currentQty;
			return Min(space,vendorQty);
		}

		else{return vendorQty;}
	}
}

@wrapMethod(VendorDataManager)
public final func BuyItemFromVendor(itemData:wref<gameItemData>,amount:Int32,opt requestId:Int32)->Void{
	if itemData.HasTag(n"Ammo"){
		let cfg=ALSystem.GetConfig();
		let ammoData=ALUtils.GetALData(ALUtils.GetAmmoTypeFromID(itemData.GetID()));
		let player=this.GetLocalPlayer();
		let tS=GameInstance.GetTransactionSystem(player.GetGame());
		let current=tS.GetItemQuantity(player,itemData.GetID());
		if cfg.strictLimit{
			let maxBuy=Max(0,ammoData.limit-current);
			amount=Min(amount,maxBuy);
			if amount<=0{return;}
		}

		else{
			if current<ammoData.limit{
				let maxBuy=ammoData.limit-current;
				amount=Min(amount,maxBuy);
			}
		}
	}
	wrappedMethod(itemData,amount,requestId);
}

// ≡ CRAFTING SYSTEM
@wrapMethod(CraftingSystem)
public final static func GetAmmoBulletAmount(ammoId:TweakDBID)->Int32{
	let ammoType=ALUtils.GetAmmoTypeFromID(ItemID.FromTDBID(ammoId));
	return !Equals(ammoType,"") ? ALUtils.GetALData(ammoType).ammoCraft : wrappedMethod(ammoId);
}

@wrapMethod(CraftingSystem)
public final const func CanItemBeCrafted(itemData:wref<gameItemData>)->Bool{
	let itemRecord=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemData.GetID()));
	if !itemRecord.TagsContains(n"Ammo"){return wrappedMethod(itemData);}

	if !this.HasIngredients(this.GetItemCraftingCost(itemData)){return false;}

	let cfg=ALSystem.GetConfig();
	if !cfg.strictLimit{return true;}

	let tS=GameInstance.GetTransactionSystem(this.GetGameInstance());
	let owner=this.m_playerCraftBook.GetOwner();
	let ammoData=ALUtils.GetALData(ALUtils.GetAmmoTypeFromID(itemData.GetID()));
	let currentQty=tS.GetItemQuantity(owner,itemData.GetID());
	return currentQty+ammoData.ammoCraft<=ammoData.limit;
}

@wrapMethod(CraftingSystem)
public final const func GetMaxCraftingAmount(itemData:wref<gameItemData>)->Int32{
	let itemRecord=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemData.GetID()));
	if !itemRecord.TagsContains(n"Ammo"){return wrappedMethod(itemData);}

	let cfg=ALSystem.GetConfig();
	let ammoData=ALUtils.GetALData(ALUtils.GetAmmoTypeFromID(itemData.GetID()));
	let owner=this.m_playerCraftBook.GetOwner();
	let tS=GameInstance.GetTransactionSystem(this.GetGameInstance());
	let matQty=tS.GetItemQuantity(owner,ItemID.FromTDBID(t"Items.CommonMaterial1"));
	if matQty<cfg.craftingCompForAmmo{return 0;}

	let matLimit=matQty/cfg.craftingCompForAmmo;
	let currentQty=tS.GetItemQuantity(owner,itemData.GetID());
	if cfg.strictLimit{
		let space=ammoData.limit-currentQty;
		if space<=0{return 0;}

		let ammoLimit=space/ammoData.ammoCraft;
		return Min(matLimit,ammoLimit);
	}

	else{
		if currentQty<ammoData.limit{
			let space=ammoData.limit-currentQty;
			let ammoLimit=(space+ammoData.ammoCraft-1)/ammoData.ammoCraft;
			return Min(matLimit,ammoLimit);
		}

		else{return matLimit;}
	}
}

@wrapMethod(CraftingSystem)
private final func CraftItem(target:wref<GameObject>,itemRecord:ref<Item_Record>,amount:Int32,opt ammoBulletAmount:Int32)->wref<gameItemData>{
	if !itemRecord.TagsContains(n"Ammo"){return wrappedMethod(target,itemRecord,amount,ammoBulletAmount);}

	let cfg=ALSystem.GetConfig();
	let ammoData=ALUtils.GetALData(ALUtils.GetAmmoTypeFromID(ItemID.FromTDBID(itemRecord.GetID())));
	let tS=GameInstance.GetTransactionSystem(this.GetGameInstance());
	let craftedItemID=ItemID.FromTDBID(itemRecord.GetID());
	let currentQty=tS.GetItemQuantity(target,craftedItemID);
	let finalAmmoAmount=amount*ammoData.ammoCraft;
	if cfg.strictLimit{
		let space=Max(0,ammoData.limit-currentQty);
		if space<=0{return tS.GetItemData(target,craftedItemID);}

		finalAmmoAmount=Min(finalAmmoAmount,space);
		amount=Max(1,(finalAmmoAmount+ammoData.ammoCraft-1)/ammoData.ammoCraft);
	}
	else{
		if currentQty<ammoData.limit{
			let space=ammoData.limit-currentQty;
			finalAmmoAmount=Min(finalAmmoAmount,space);
			amount=Max(1,(finalAmmoAmount+ammoData.ammoCraft-1)/ammoData.ammoCraft);
		}
	}
	tS.RemoveItemByTDBID(target,t"Items.CommonMaterial1",cfg.craftingCompForAmmo*amount,true);
	tS.GiveItem(target,craftedItemID,finalAmmoAmount);
	let player=target as PlayerPuppet;
	if IsDefined(player){player.EvaluateEncumbrance();}
	if cfg.craftingAmmoXP>0{this.ProcessCraftSkill(Cast<Float>(cfg.craftingAmmoXP*amount));}
	let itemData=tS.GetItemData(target,craftedItemID);
	this.SetItemLevel(itemData);
	CraftingSystem.MarkItemAsCrafted(target,itemData);
	this.SendItemCraftedDataTrackingRequest(craftedItemID,finalAmmoAmount);
	return itemData;
}

@wrapMethod(CraftingSystem)
public final const func GetDisassemblyResultItems(target:wref<GameObject>,itemID:ItemID,amount:Int32,restoredAttachments:script_ref<[ItemAttachments]>,opt calledFromUI:Bool)->[IngredientData]{
	let cfg=ALSystem.GetConfig();
	let record=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
	// AMMO (ONLY FOR UI PREVIEW)
	if record.TagsContains(n"Ammo") && calledFromUI{
		let result:array<IngredientData>;
		let ammoType=ALUtils.GetAmmoTypeFromID(itemID);
		if NotEquals(ammoType,""){
			let realAmount=GameInstance.GetTransactionSystem(target.GetGame()).GetItemQuantity(target,itemID);
			let ammoData=ALUtils.GetALData(ammoType);
			let convRate=(ammoData.ammoCraft*100)/(cfg.craftingCompForAmmo*cfg.ammoConvRate);
			let res=ALUtils.ComputeSmartConv(realAmount,convRate,true);
			let compQty=Cast<Int32>(res.Y);
			if compQty>0{
				let bonusIngredient:IngredientData;
				bonusIngredient.id=TweakDBInterface.GetItemRecord(t"Items.CommonMaterial1");
				bonusIngredient.quantity=compQty;
				ArrayPush(result,bonusIngredient);
			}
		}
		return result;
	}
	// WEAPONS
	let result=wrappedMethod(target,itemID,amount,restoredAttachments,calledFromUI);
	if cfg.addCompFromWeapDisass<=0{return result;}

	if !Equals(record.ItemCategory().Type(),gamedataItemCategory.Weapon){return result;}

	let bonusQty=cfg.addCompFromWeapDisass*amount;
	let targetTDBID=t"Items.CommonMaterial1";
	let i=0;
	while i<ArraySize(result){
		if Equals(result[i].id.GetID(),targetTDBID){
			result[i].quantity+=bonusQty;
			return result;
		}
		i+=1;
	}

	let bonusIngredient:IngredientData;
	bonusIngredient.id=TweakDBInterface.GetItemRecord(targetTDBID);
	bonusIngredient.quantity=bonusQty;
	ArrayPush(result,bonusIngredient);
	return result;
}

// ≡ DISASS SYSTEM
@wrapMethod(RPGManager)
public final static func CanItemBeDisassembled(gI:GameInstance,itemData:wref<gameItemData>)->Bool{
	let cfg=ALSystem.GetConfig();
	if itemData.HasTag(n"Ammo"){
		if cfg.ammoDisassDisabled{return false;}

		let ammoType=ALUtils.GetAmmoTypeFromID(itemData.GetID());
		if NotEquals(ammoType,""){
			let ammoData=ALUtils.GetALData(ammoType);
			let convRate=(ammoData.ammoCraft*100)/(cfg.craftingCompForAmmo*cfg.ammoConvRate);
			let res=ALUtils.ComputeSmartConv(itemData.GetQuantity(),convRate,true);
			if Cast<Int32>(res.Y)<1{return false;}
		}
	}

	return wrappedMethod(gI,itemData);
}

@wrapMethod(CraftingSystem)
private final const func DisassembleItem(target:wref<GameObject>,itemID:ItemID,amount:Int32)->Void{
	let tS=GameInstance.GetTransactionSystem(this.GetGameInstance());
	let itemData=tS.GetItemData(target,itemID);
	let cfg=ALSystem.GetConfig();
	// AMMO DISASSEMBLY
	if IsDefined(itemData) && itemData.HasTag(n"Ammo"){
		let ammoType=ALUtils.GetAmmoTypeFromID(itemID);
		if NotEquals(ammoType,""){
			let ammoData=ALUtils.GetALData(ammoType);
			let convRate=(ammoData.ammoCraft*100)/(cfg.craftingCompForAmmo*cfg.ammoConvRate);
			let res=ALUtils.ComputeSmartConv(amount,convRate,cfg.smartConv);
			let usableAmount=Cast<Int32>(res.X);
			let corrComp=Cast<Int32>(res.Y);
			if corrComp>0{
				GameInstance.GetTelemetrySystem(this.GetGameInstance()).LogItemDisassembled(target,itemID);
				tS.RemoveItem(target,itemID,usableAmount);

				let restoredAttachments:array<ItemAttachments>;
				let vanillaResults=this.GetDisassemblyResultItems(target,itemID,1,restoredAttachments);
				if ArraySize(vanillaResults)>0{
					tS.GiveItem(target,ItemID.FromTDBID(vanillaResults[0].id.GetID()),corrComp);

					let listOfIngredients:array<IngredientData>;
					let ingredient:IngredientData;
					ingredient.id=vanillaResults[0].id;
					ingredient.quantity=corrComp;
					ArrayPush(listOfIngredients,ingredient);
					this.UpdateBlackboard(CraftingCommands.DisassemblingFinished,itemID,listOfIngredients);
				}
			}
			let player=target as PlayerPuppet;
			if IsDefined(player){player.EvaluateEncumbrance();}
			return;
		}
	}
	// WEAPON AMMO RECOVERY
	let ammoToGive:ItemID;
	let ammoAmount:Int32=0;
	let ammoType:String="";
	if cfg.ammoFromWeapDisass>0{
		let record=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID)) as WeaponItem_Record;
		if IsDefined(record) && (!cfg.ammoFromBrokenOnly || RPGManager.IsItemBroken(itemData)){
			let magCap=Cast<Int32>(GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatValue(Cast<StatsObjectID>(itemID),gamedataStatType.MagazineCapacityBase));
			let maxAmmo=magCap*cfg.ammoFromWeapDisass/100;
			if maxAmmo>0{
				let ammoTDBID=record.Ammo().GetID();
				if NotEquals(ammoTDBID,TDBID.None()){
					ammoToGive=ItemID.FromTDBID(ammoTDBID);
					ammoType=ALUtils.GetAmmoTypeFromID(ammoToGive);
					ammoAmount=Max(1,RandRange(1,maxAmmo+1));
				}
			}
		}
	}
	wrappedMethod(target,itemID,amount);

	// Post-vanilla ammo giver
	if ammoAmount>0 && NotEquals(ammoType,""){
		tS.GiveItem(target,ammoToGive,ammoAmount);

		if cfg.messageDisplay{
			let player=target as PlayerPuppet;
			if IsDefined(player){
				let ammoName=GetLocalizedTextByKey(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(ammoToGive)).DisplayName());
				ALUtils.ALMessage(player.GetGame(),GetLocalizedTextByKey(n"AmmoLimiter-Message-Recovered")+" "+ToString(ammoAmount)+" "+ammoName+".");
			}
		}
		let playerFinal=target as PlayerPuppet;
		if IsDefined(playerFinal){playerFinal.EvaluateEncumbrance();}
	}
}

// ≡ PICKER SYSTEM (Unified Ammo Display)
@wrapMethod(ItemQuantityPickerController)
private final func SetData()->Void{
	wrappedMethod();

	let itemRecord:ref<Item_Record>;
	if IsDefined(this.m_inventoryItem){itemRecord=this.m_inventoryItem.GetItemRecord();}
	else{itemRecord=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_gameData)));}

	ALUtils.UpdatePickerAmmoDisplay(this,this.m_choosenQuantity,itemRecord);
}

@wrapMethod(ItemQuantityPickerController)
protected final func UpdateWeight()->Void{
	let itemRecord:ref<Item_Record>;
	if IsDefined(this.m_inventoryItem){itemRecord=this.m_inventoryItem.GetItemRecord();}
	else{itemRecord=TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(this.m_gameData)));}
	let ammoType=ALUtils.GetAmmoTypeFromRecord(itemRecord);
	if Equals(ammoType,""){wrappedMethod();return;}

	ALUtils.UpdatePickerAmmoDisplay(this,this.m_choosenQuantity,itemRecord);
}

// ≡ TOOLTIPS (Weight Precision Tweak)
@wrapMethod(ItemTooltipBottomModule)
private final func UpdateWeightVisibility(data:wref<UIInventoryItem>)->Void{
	wrappedMethod(data);

	if IsDefined(data) && Equals(data.GetItemType(),gamedataItemType.Con_Ammo){inkTextRef.SetText(this.m_weightText,FloatToStringPrec(data.GetWeight(),3));}
}

@wrapMethod(ItemTooltipBottomModule)
public func Update(data:ref<MinimalItemTooltipData>)->Void{
	wrappedMethod(data);

	if IsDefined(data.itemData) && data.itemData.HasTag(n"Ammo"){inkTextRef.SetText(this.m_weightText,FloatToStringPrec(data.weight,3));}
}

@wrapMethod(ItemTooltipController)
protected final func UpdateWeight()->Void{
	wrappedMethod();

	let itemData=InventoryItemData.GetGameItemData(this.m_data.inventoryItemData);
	if IsDefined(itemData) && itemData.HasTag(n"Ammo"){
		let weight=itemData.GetStatValueByType(gamedataStatType.Weight);
		inkTextRef.SetText(this.m_requireLevelText,FloatToStringPrec(weight,3));
	}
}

// ≡ INVENTORY FILTERS
@wrapMethod(ItemCategoryFliter)
public final static func FilterItem(filter:ItemFilterCategory,wrappedData:ref<WrappedInventoryItemData>)->Bool{
	if Equals(wrappedData.Item.GetItemType(),gamedataItemType.Con_Ammo){
		let cfg=ALSystem.GetConfig();
		let ammoCat=cfg.ammoCategorySelected;
		return(Equals(ammoCat,ammoCategory.RangedWeapons) && (Equals(filter,ItemFilterCategory.RangedWeapons) || Equals(filter,ItemFilterCategory.AllItems))) || (Equals(ammoCat,ammoCategory.Attachments) && (Equals(filter,ItemFilterCategory.Attachments) || Equals(filter,ItemFilterCategory.AllItems))) || (Equals(ammoCat,ammoCategory.Consumables) && (Equals(filter,ItemFilterCategory.Consumables) || Equals(filter,ItemFilterCategory.Grenades) || Equals(filter,ItemFilterCategory.AllItems)));
	}

	return wrappedMethod(filter,wrappedData);
}

@wrapMethod(CraftingDataView)
public func FilterItem(data:ref<IScriptable>)->Bool{
	let shouldShow=wrappedMethod(data);
	if shouldShow{return true;}

	let recipeData=data as RecipeData;
	if !IsDefined(recipeData){return false;}

	let itemType=TweakDBInterface.GetItemRecord(recipeData.id.GetID()).ItemType().Type();
	if !Equals(itemType,gamedataItemType.Con_Ammo){return false;}

	let cfg=ALSystem.GetConfig();
	let ammoCat=cfg.ammoCategorySelected;
	let currFilter=this.GetFilterType();
	return (Equals(ammoCat,ammoCategory.RangedWeapons) && (Equals(currFilter,ItemFilterCategory.RangedWeapons) || Equals(currFilter,ItemFilterCategory.AllItems))) || (Equals(ammoCat,ammoCategory.Attachments) && (Equals(currFilter,ItemFilterCategory.Attachments) || Equals(currFilter,ItemFilterCategory.AllItems))) || (Equals(ammoCat,ammoCategory.Consumables) && (Equals(currFilter,ItemFilterCategory.Consumables) || Equals(currFilter,ItemFilterCategory.AllItems)));
}

@wrapMethod(CraftingMainLogicController)
protected func SetupFilters()->Void{
	wrappedMethod();

	let ammoCat=ALSystem.GetConfig().ammoCategorySelected;
	let targetInt:Int32;
	if Equals(ammoCat,ammoCategory.RangedWeapons){targetInt=EnumInt(ItemFilterCategory.RangedWeapons);}else if Equals(ammoCat,ammoCategory.Attachments){targetInt=EnumInt(ItemFilterCategory.Attachments);}else if Equals(ammoCat,ammoCategory.Consumables){targetInt=EnumInt(ItemFilterCategory.Consumables);}
	if !ArrayContains(this.m_filters,targetInt){ArrayPush(this.m_filters,targetInt);}
}

// ≡ INVENTORY DISPLAY
@wrapMethod(UIInventoryItemsManager)
public final static func GetBlacklistedTags()->array<CName>{
	let filteredTags=wrappedMethod();
	ArrayRemove(filteredTags,n"Ammo");
	return filteredTags;
}

// ≡ WARNING HELPERS
public static func ALWarning_GetAmmoIndex(ammoType:String)->Int32{
	switch ammoType{
		case "Handgun":return 0;
		case "Rifle":return 1;
		case "Shotgun":return 2;
		case "SniperRifle":return 3;
		default:return -1;
	}
}

public static func ALWarning_GetAmmoIndexFromID(ammoID:ItemID)->Int32{return ALWarning_GetAmmoIndex(ALUtils.GetAmmoTypeFromID(ammoID));}

public static func ALWarning_CheckAndNotify(player:ref<PlayerPuppet>,weapon:ref<WeaponObject>)->Bool{
	if !IsDefined(player) || !IsDefined(weapon){return false;}

	let cfg=ALSystem.GetConfig();
	if cfg.ammoLowWarning==0{return false;}

	// Immersive Cyberware Compatibility
	if cfg.ammoLowWarningICCompat{
		let ammoCounterEnumVal:Int64=EnumValueFromName(n"gamedataStatType",n"AmmoCounterConnected");
		if ammoCounterEnumVal!=-1l{
			let statsSystem:ref<StatsSystem>=GameInstance.GetStatsSystem(player.GetGame());
			let hasAimThing:Float=statsSystem.GetStatValue(Cast<StatsObjectID>(player.GetEntityID()),IntEnum<gamedataStatType>(ammoCounterEnumVal));
			let inVehicle:Bool=VehicleComponent.IsMountedToVehicle(player.GetGame(),player);
			if hasAimThing<=0.0 && !inVehicle{return false;}
		}
	}

	let ammoID=WeaponObject.GetAmmoType(weapon);
	let ammoType=ALUtils.GetAmmoTypeFromID(ammoID);
	if Equals(ammoType,""){return false;}

	let ammoData=ALUtils.GetALData(ammoType);
	let warnThresh=(ammoData.limit*cfg.ammoLowWarning)/100;
	let tS=GameInstance.GetTransactionSystem(player.GetGame());
	let totalAmmo=tS.GetItemQuantity(player,ammoID)+Cast<Int32>(WeaponObject.GetMagazineAmmoCount(weapon));
	if totalAmmo<=warnThresh && totalAmmo>0{
		let ammoName=GetLocalizedTextByKey(TweakDBInterface.GetItemRecord(ItemID.GetTDBID(ammoID)).DisplayName());
		let finalMsg=StrReplace(GetLocalizedTextByKey(n"AmmoLimiter-UI-LowAmmoWarning"),"PROUTS",ammoName);
		let msg:SimpleScreenMessage;
		msg.isShown=true;
		msg.duration=2.25;
		msg.message=finalMsg;
		msg.isInstant=true;
		GameInstance.GetBlackboardSystem(player.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage,ToVariant(msg),true);
		return true;
	}

	return false;
}

// ≡ WARNING HOOKS
@wrapMethod(WeaponObject)
protected cb func OnAmmoStateChangeEvent(evt:ref<AmmoStateChangeEvent>)->Bool{
	let result=wrappedMethod(evt);
	let player=evt.weaponOwner as PlayerPuppet;
	if IsDefined(player){
		let ammoIndex=ALWarning_GetAmmoIndexFromID(WeaponObject.GetAmmoType(this));
		if ammoIndex>=0{
			let gI=player.GetGame();
			let sys=GameInstance.GetScriptableSystemsContainer(gI).Get(n"AmmoLimiter.Core.ALSystem") as ALSystem;
			if IsDefined(sys){
				let time=EngineTime.ToFloat(GameInstance.GetEngineTime(gI));
				if sys.CanWarn(ammoIndex,time,12.0) && ALWarning_CheckAndNotify(player,this){sys.SetLastWarning(ammoIndex,time);}
			}
		}
	}
	return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnItemAddedToSlot(evt:ref<ItemAddedToSlot>)->Bool{
	let result=wrappedMethod(evt);
	if evt.GetSlotID()==t"AttachmentSlots.WeaponRight"{
		let gI=this.GetGame();
		let weapon=GameInstance.GetTransactionSystem(gI).GetItemInSlot(this,evt.GetSlotID()) as WeaponObject;
		if IsDefined(weapon){
			let ammoIndex=ALWarning_GetAmmoIndexFromID(WeaponObject.GetAmmoType(weapon));
			if ammoIndex>=0{
				let sys=GameInstance.GetScriptableSystemsContainer(gI).Get(n"AmmoLimiter.Core.ALSystem") as ALSystem;
				if IsDefined(sys){
					let time=EngineTime.ToFloat(GameInstance.GetEngineTime(gI));
					if sys.CanWarn(ammoIndex,time,12.0) && ALWarning_CheckAndNotify(this,weapon){sys.SetLastWarning(ammoIndex,time);}
				}
			}
		}
	}
	return result;
}
