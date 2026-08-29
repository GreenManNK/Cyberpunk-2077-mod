module AmmoLimiter.Config

public enum ammoCategory{RangedWeapons=0,Attachments=1,Consumables=2}

public class AmmoLimiterConfig{
	// GENERAL SETTINGS
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-MessageDisplay-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-MessageDisplay-Desc")
	public let messageDisplay:Bool=false;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-LowAmmoWarning-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-LowAmmoWarning-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","50")
	public let ammoLowWarning:Int32=15;

	// Immersive Cyberware Compatibility
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-LowAmmoWarningICCompat-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-LowAmmoWarningICCompat-Desc")
	public let ammoLowWarningICCompat:Bool=true;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-AmmoDisassDisabled-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-AmmoDisassDisabled-Desc")
	public let ammoDisassDisabled:Bool=false;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-AmmoCategory-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-AmmoCategory-Desc")
	@runtimeProperty("ModSettings.displayValues.RangedWeapons","AmmoLimiter-Settings-AmmoCategory-RangedWeapons")
	@runtimeProperty("ModSettings.displayValues.Attachments","AmmoLimiter-Settings-AmmoCategory-Attachments") 
	@runtimeProperty("ModSettings.displayValues.Consumables","AmmoLimiter-Settings-AmmoCategory-Consumables")
	public let ammoCategorySelected:ammoCategory=ammoCategory.RangedWeapons;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-AmmoFromWeapDisass-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-AmmoFromWeapDisass-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","100")
	public let ammoFromWeapDisass:Int32=60;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options") 
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-BrokenOnly-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-BrokenOnly-Desc")
	public let ammoFromBrokenOnly:Bool=false;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-AddCompFromWeapDisass-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-AddCompFromWeapDisass-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","30")
	public let addCompFromWeapDisass:Int32=3;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-AutoSell-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-AutoSell-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","100")
	public let autoSell:Int32=0;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-AmmoConvRate-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-AmmoConvRate-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","100")
	public let ammoConvRate:Int32=85;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Options")
	@runtimeProperty("ModSettings.category.order","1")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-SmartConv-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-SmartConv-Desc")
	public let smartConv:Bool=true;

	// LIMITS
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Limits")
	@runtimeProperty("ModSettings.category.order","2")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-StrictLimit-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-StrictLimit-Desc")
	public let strictLimit:Bool=false;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Limits")
	@runtimeProperty("ModSettings.category.order","2")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-SleepingAmmoControl-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-SleepingAmmoControl-Desc")
	public let sleepingAmmoControl:Bool=false;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Limits")
	@runtimeProperty("ModSettings.category.order","2")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-ActiveWeapBonus-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-ActiveWeapBonus-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","50")
	@runtimeProperty("ModSettings.max","200")
	public let activeWeapBonus:Int32=100;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Limits")
	@runtimeProperty("ModSettings.category.order","2")
	@runtimeProperty("ModSettings.displayName","LocKey#50354")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandgunAmmoLimit-Desc")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","2250")
	public let ammoLimitHandgun:Int32=225;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Limits")
	@runtimeProperty("ModSettings.category.order","2")
	@runtimeProperty("ModSettings.displayName","LocKey#50358")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-RifleAmmoLimit-Desc")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","2250")
	public let ammoLimitRifle:Int32=225;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Limits")
	@runtimeProperty("ModSettings.category.order","2")
	@runtimeProperty("ModSettings.displayName","LocKey#50356")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-ShotgunAmmoLimit-Desc")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","900")
	public let ammoLimitShotgun:Int32=90;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Limits")
	@runtimeProperty("ModSettings.category.order","2")
	@runtimeProperty("ModSettings.displayName","LocKey#50360")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-SniperAmmoLimit-Desc")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","450")
	public let ammoLimitSniper:Int32=45;

	// BOXES
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Box")
	@runtimeProperty("ModSettings.category.order","3")
	@runtimeProperty("ModSettings.displayName","LocKey#50354")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-BoxHandgunAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","750")
	public let ammoBoxHandgun:Int32=75;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Box")
	@runtimeProperty("ModSettings.category.order","3")
	@runtimeProperty("ModSettings.displayName","LocKey#50358")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-BoxRifleAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","750")
	public let ammoBoxRifle:Int32=75;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Box")
	@runtimeProperty("ModSettings.category.order","3")
	@runtimeProperty("ModSettings.displayName","LocKey#50356")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-BoxShotgunAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","300")
	public let ammoBoxShotgun:Int32=30;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Box")
	@runtimeProperty("ModSettings.category.order","3")
	@runtimeProperty("ModSettings.displayName","LocKey#50360")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-BoxSniperAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","150")
	public let ammoBoxSniper:Int32=15;

	// HANDICAP SYSTEM
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Hand")
	@runtimeProperty("ModSettings.category.order","4")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-EnableHandicap-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-EnableHandicap-Desc")
	public let isHandicapEnabled:Bool=true;

	// CUSTOMIZED HANDICAP
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-UseCustomHandMode-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-UseCustomHandMode-Desc")
	@runtimeProperty("ModSettings.dependency","isHandicapEnabled")
	public let isCustomHandMode:Bool=false;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandLimitHandgunAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandLimit-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","1200")
	public let handLimitHandgun:Int32=120;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandMinHandgunAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandMin-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","900")
	public let handMinHandgun:Int32=90;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandMaxHandgunAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandMax-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","1500")
	public let handMaxHandgun:Int32=150;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandLimitRifleAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandLimit-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","1200")
	public let handLimitRifle:Int32=120;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandMinRifleAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandMin-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","900")
	public let handMinRifle:Int32=90;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandMaxRifleAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandMax-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","1500")
	public let handMaxRifle:Int32=150;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandLimitShotgunAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandLimit-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","500")
	public let handLimitShotgun:Int32=50;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandMinShotgunAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandMin-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","250")
	public let handMinShotgun:Int32=25;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandMaxShotgunAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandMax-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","500")
	public let handMaxShotgun:Int32=50;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandLimitSniperAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandLimit-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","400")
	public let handLimitSniper:Int32=40;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandMinSniperAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandMin-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","400")
	public let handMinSniper:Int32=40;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-CustomHand")
	@runtimeProperty("ModSettings.category.order","5")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-HandMaxSniperAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-HandMax-Desc")
	@runtimeProperty("ModSettings.dependency","isCustomHandMode")
	@runtimeProperty("ModSettings.step","5")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","800")
	public let handMaxSniper:Int32=80;

	// WEIGHTS
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Weight")
	@runtimeProperty("ModSettings.category.order","7")
	@runtimeProperty("ModSettings.displayName","LocKey#50354")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-WeightHandgunAmmo-Desc")
	@runtimeProperty("ModSettings.step","0.003")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","0.3")
	public let ammoWeightHandgun:Float=0.033;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Weight")
	@runtimeProperty("ModSettings.category.order","7")
	@runtimeProperty("ModSettings.displayName","LocKey#50358")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-WeightRifleAmmo-Desc")
	@runtimeProperty("ModSettings.step","0.003")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","0.3")
	public let ammoWeightRifle:Float=0.027;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Weight")
	@runtimeProperty("ModSettings.category.order","7")
	@runtimeProperty("ModSettings.displayName","LocKey#50356")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-WeightShotgunAmmo-Desc")
	@runtimeProperty("ModSettings.step","0.003")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","0.3")
	public let ammoWeightShotgun:Float=0.054;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Weight")
	@runtimeProperty("ModSettings.category.order","7")
	@runtimeProperty("ModSettings.displayName","LocKey#50360")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-WeightSniperAmmo-Desc")
	@runtimeProperty("ModSettings.step","0.003")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","0.3")
	public let ammoWeightSniper:Float=0.051;

	// PRICES
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Eddies")
	@runtimeProperty("ModSettings.category.order","8")
	@runtimeProperty("ModSettings.displayName","LocKey#50354")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-PriceHandgunAmmo-Desc")
	@runtimeProperty("ModSettings.step","0.05")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","4.0")
	public let ammoPriceHandgun:Float=2.0;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Eddies")
	@runtimeProperty("ModSettings.category.order","8")
	@runtimeProperty("ModSettings.displayName","LocKey#50358")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-PriceRifleAmmo-Desc")
	@runtimeProperty("ModSettings.step","0.05")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","3.6")
	public let ammoPriceRifle:Float=1.8;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Eddies")
	@runtimeProperty("ModSettings.category.order","8")
	@runtimeProperty("ModSettings.displayName","LocKey#50356")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-PriceShotgunAmmo-Desc")
	@runtimeProperty("ModSettings.step","0.05")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","10.0")
	public let ammoPriceShotgun:Float=5.0;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Eddies")
	@runtimeProperty("ModSettings.category.order","8")
	@runtimeProperty("ModSettings.displayName","LocKey#50360")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-PriceSniperAmmo-Desc")
	@runtimeProperty("ModSettings.step","0.05")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","20.0")
	public let ammoPriceSniper:Float=10.0;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Eddies")
	@runtimeProperty("ModSettings.category.order","8")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-PriceSlaughtomatic-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-PriceSlaughtomatic-Desc")
	@runtimeProperty("ModSettings.step","0.05")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","2.0")
	public let ammoPriceSlaughtomatic:Float=1.0;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Eddies")
	@runtimeProperty("ModSettings.category.order","8")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-ResellMult-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-ResellMult-Desc")
	@runtimeProperty("ModSettings.step","0.05")
	@runtimeProperty("ModSettings.min","0.0")
	@runtimeProperty("ModSettings.max","1.0")
	public let ammoSellMult:Float=0.25;

	// CRAFTING
	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Craft")
	@runtimeProperty("ModSettings.category.order","9")
	@runtimeProperty("ModSettings.displayName","LocKey#50354")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-CraftHandgunAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","120")
	public let ammoCraftHandgun:Int32=12;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Craft")
	@runtimeProperty("ModSettings.category.order","9")
	@runtimeProperty("ModSettings.displayName","LocKey#50358")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-CraftRifleAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","150")
	public let ammoCraftRifle:Int32=15;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Craft")
	@runtimeProperty("ModSettings.category.order","9")
	@runtimeProperty("ModSettings.displayName","LocKey#50356")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-CraftShotgunAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","60")
	public let ammoCraftShotgun:Int32=6;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Craft")
	@runtimeProperty("ModSettings.category.order","9")
	@runtimeProperty("ModSettings.displayName","LocKey#50360")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-CraftSniperAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","30")
	public let ammoCraftSniper:Int32=3;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Craft")
	@runtimeProperty("ModSettings.category.order","9")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-CraftingCompForAmmo-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-CraftingCompForAmmo-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","10")
	public let craftingCompForAmmo:Int32=1;

	@runtimeProperty("ModSettings.mod","Ammo Limiter")
	@runtimeProperty("ModSettings.category","AmmoLimiter-Settings-Craft")
	@runtimeProperty("ModSettings.category.order","9")
	@runtimeProperty("ModSettings.displayName","AmmoLimiter-Settings-CraftingAmmoXP-Name")
	@runtimeProperty("ModSettings.description","AmmoLimiter-Settings-CraftingAmmoXP-Desc")
	@runtimeProperty("ModSettings.step","1")
	@runtimeProperty("ModSettings.min","0")
	@runtimeProperty("ModSettings.max","100")
	public let craftingAmmoXP:Int32=3;
}
