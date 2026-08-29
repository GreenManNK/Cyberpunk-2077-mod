module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class English extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === GENERAL OPTIONS ===
		this.Text("AmmoLimiter-Settings-Title","Ammo Limiter");
		this.Text("AmmoLimiter-Settings-Options","• General options");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Display messages");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Display ammo conversion, storage or recovery messages.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Strict ammo limitation in inventory");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Allows to strictly limit transfers to inventory, purchases and ammo crafting, unlike the default soft limitation.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Low ammo warning (threshold in %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","When threshold is greater than 0%, allows to warn when remaining ammo quantity of drawn weapon is below threshold.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Disable manual ammo disassembly");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Allows to disable the possibility of manually disassembling ammo, without disabling other mod mechanisms.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Recover from disassembly (% of magazine)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Allows to get ammo when disassembling a weapon, even broken. Random quantity between 0 and this % of its magazine maximum capacity. Complements the handicap system.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Ammo display category");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Choose in which inventory category to display ammo and recipes.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Ranged weapons");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Weapon attachments");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Combat consumables");

		// === AMMO LIMITS ===
		this.Text("AmmoLimiter-Settings-Limits","• Ammo limits in inventory");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Sleeping ammo control");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Prevents accumulation by picking up ammo not matching active weapon, directly converted or dropped to ground.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Active weapon limit bonus (in %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Allows to exceed the limit for ammo corresponding to equipped weapon.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Maximum handgun ammo in inventory, only applies to pickup and crafting.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Maximum heavy weapon ammo in inventory, only applies to pickup and crafting.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Maximum shotgun ammo in inventory, only applies to pickup and crafting.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Maximum sniper ammo in inventory, only applies to pickup and crafting.");

		// === AMMO BOXES ===
		this.Text("AmmoLimiter-Settings-Box","• Maximum quantities found in boxes");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Maximum quantity of handgun ammo in each box in the world.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Maximum quantity of heavy weapon ammo in each box in the world.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Maximum quantity of shotgun ammo in each box in the world.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Maximum quantity of sniper ammo in each box in the world.");

		// === HANDICAP SYSTEM ===
		this.Text("AmmoLimiter-Settings-Hand","• Handicap system");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Handicap mode");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Regulates ammo recovery from enemies according to your current quantity. \"Optimized\" mode is calculated from your settings and is balanced.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Optimized (recommended)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Disabled");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Custom");

		// === CUSTOM HANDICAP BY AMMO ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Custom handicap by ammo");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Handgun - handicap threshold");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Handgun - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Handgun - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Heavy weapon - handicap threshold");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Heavy weapon - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Heavy weapon - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Shotgun - handicap threshold");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Shotgun - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Shotgun - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Sniper - handicap threshold");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Sniper - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Sniper - maximum");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Handicap trigger threshold below which loot can hide ammo.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Minimum recoverable ammo if handicap is active.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Maximum recoverable ammo if handicap is active.");

		// === AMMO WEIGHT ===
		this.Text("AmmoLimiter-Settings-Weight","• Ammo weight");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Weight of one handgun ammo.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Weight of one heavy weapon ammo.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Weight of one shotgun ammo.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Weight of one sniper ammo.");

		// === AMMO PRICE MULTIPLIERS ===
		this.Text("AmmoLimiter-Settings-Eddies","• Ammo price multipliers");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Purchase price multiplier for one handgun ammo in eddies.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Purchase price multiplier for one heavy weapon ammo in eddies.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Purchase price multiplier for one shotgun ammo in eddies.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Purchase price multiplier for one sniper ammo in eddies.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Automatic excess sale (in % of purchase price)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Percentage of automatic sale price based on raw purchase price (no discount) for excess ammo (0 = disabled).");

		// === CRAFTING & CONVERSION ===
		this.Text("AmmoLimiter-Settings-Craft","• Ammo batch crafting");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Quantity of handgun ammo per batch crafting.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Quantity of heavy weapon ammo per batch crafting.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Quantity of shotgun ammo per batch crafting.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Quantity of sniper ammo per batch crafting.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Components required for crafting");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Quantity of components needed to craft 1 batch of ammo.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Automatic ammo conversion (in %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Percentage of automatic ammo conversion to components.");

		// === IN-GAME TEXTS ===
		this.Text("AmmoLimiter-Message-Dropped","dropped to ground");
		this.Text("AmmoLimiter-Message-Crafted","converted to");
		this.Text("AmmoLimiter-Message-Recovered","Recovered:");
		this.Text("AmmoLimiter-Message-From","from");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Ammo limit reached!");
		// Please respect my humor by NEVER modifying the word "PROUTS":
		this.Text("AmmoLimiter-UI-LowAmmoWarning","INSUFFICIENT PROUTS RESERVE!");
		this.Text("AmmoLimiter-UI-Total","total");
		this.Text("AmmoLimiter-UI-Unit","unit");
	}
}
