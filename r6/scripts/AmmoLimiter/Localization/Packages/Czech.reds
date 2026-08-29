module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Czech extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === OBECNÉ MOŽNOSTI ===
		this.Text("AmmoLimiter-Settings-Title","Omezovač munice");
		this.Text("AmmoLimiter-Settings-Options","• Obecné možnosti");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Zobrazit zprávy");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Zobrazit zprávy o konverzi, uložení nebo obnovení munice.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Striktní omezení munice v inventáři");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Umožňuje striktně omezit převody do inventáře, nákupy a výrobu munice, na rozdíl od výchozího měkkého omezení.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Upozornění na nízkou munici (prahová hodnota v %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Když je prahová hodnota větší než 0%, umožňuje varovat, když zbývající množství munice vytažené zbraně je pod prahovou hodnotou.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Zakázat ruční rozmontování munice");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Umožňuje zakázat možnost ručního rozmontování munice, aniž by se zakázaly ostatní mechanismy modu.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Obnovení z rozmontování (% z zásobníku)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Umožňuje získat munici při rozmontování zbraně, i poškozené. Náhodné množství mezi 0 a tímto % z maximální kapacity jejího zásobníku. Doplňuje systém handicapu.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Kategorie zobrazení munice");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Vyberte, ve které kategorii inventáře zobrazit munici a recepty.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Zbraně na dálku");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Příslušenství zbraní");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Bojové spotřební předměty");

		// === LIMITY MUNICE ===
		this.Text("AmmoLimiter-Settings-Limits","• Limity munice v inventáři");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Kontrola spící munice");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Zabraňuje hromadění sběrem munice neodpovídající aktivní zbrani, přímo převedené nebo vyhozené na zem.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Bonus limitu aktivní zbraně (v %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Umožňuje překročit limit pro munici odpovídající vybavené zbrani.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Maximum munice pistole v inventáři, platí pouze pro sběr a výrobu.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Maximum munice těžké zbraně v inventáři, platí pouze pro sběr a výrobu.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Maximum munice brokovnice v inventáři, platí pouze pro sběr a výrobu.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Maximum munice odstřelovače v inventáři, platí pouze pro sběr a výrobu.");

		// === KRABICE S MUNICÍ ===
		this.Text("AmmoLimiter-Settings-Box","• Maximální množství nalezené v krabicích");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Maximální množství munice pistole v každé krabici ve světě.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Maximální množství munice těžké zbraně v každé krabici ve světě.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Maximální množství munice brokovnice v každé krabici ve světě.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Maximální množství munice odstřelovače v každé krabici ve světě.");

		// === SYSTÉM HANDICAPU ===
		this.Text("AmmoLimiter-Settings-Hand","• Systém handicapu");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Režim handicapu");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Reguluje obnovení munice z nepřátel podle vašeho současného množství. Režim \"Optimalizovaný\" je vypočítán z vašich nastavení a je vyvážený.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Optimalizovaný (doporučeno)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Zakázáno");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Vlastní");

		// === VLASTNÍ HANDICAP PO MUNICI ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Vlastní handicap po munici");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Pistole - práh handicapu");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Pistole - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Pistole - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Těžká zbraň - práh handicapu");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Těžká zbraň - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Těžká zbraň - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Brokovnice - práh handicapu");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Brokovnice - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Brokovnice - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Odstřelovač - práh handicapu");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Odstřelovač - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Odstřelovač - maximum");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Práh spuštění handicapu, pod kterým může loot skrývat munici.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Minimum obnovitelné munice, pokud je handicap aktivní.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Maximum obnovitelné munice, pokud je handicap aktivní.");

		// === HMOTNOST MUNICE ===
		this.Text("AmmoLimiter-Settings-Weight","• Hmotnost munice");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Hmotnost jedné munice pistole.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Hmotnost jedné munice těžké zbraně.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Hmotnost jedné munice brokovnice.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Hmotnost jedné munice odstřelovače.");

		// === NÁSOBKY CEN MUNICE ===
		this.Text("AmmoLimiter-Settings-Eddies","• Násobky cen munice");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Násobek nákupní ceny jedné munice pistole v eddies.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Násobek nákupní ceny jedné munice těžké zbraně v eddies.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Násobek nákupní ceny jedné munice brokovnice v eddies.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Násobek nákupní ceny jedné munice odstřelovače v eddies.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Automatický prodej přebytku (v % z nákupní ceny)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Procento automatické prodejní ceny založené na hrubé nákupní ceně (bez slevy) pro přebytečnou munici (0 = zakázáno).");

		// === VÝROBA A KONVERZE ===
		this.Text("AmmoLimiter-Settings-Craft","• Výroba dávek munice");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Množství munice pistole na výrobu dávky.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Množství munice těžké zbraně na výrobu dávky.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Množství munice brokovnice na výrobu dávky.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Množství munice odstřelovače na výrobu dávky.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Komponenty potřebné k výrobě");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Množství komponentů potřebných k výrobě 1 dávky munice.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Automatická konverze munice (v %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Procento automatické konverze munice na komponenty.");

		// === TEXTY VE HŘE ===
		this.Text("AmmoLimiter-Message-Dropped","vyhozeno na zem");
		this.Text("AmmoLimiter-Message-Crafted","převedeno na");
		this.Text("AmmoLimiter-Message-Recovered","Obnoveno:");
		this.Text("AmmoLimiter-Message-From","z");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Dosažen limit munice!");
		// Prosím respektujte můj humor tím, že NIKDY nebudete měnit slovo "PROUTS":
		this.Text("AmmoLimiter-UI-LowAmmoWarning","NEDOSTATEČNÁ ZÁSOBA PROUTS!");
		this.Text("AmmoLimiter-UI-Total","celkem");
		this.Text("AmmoLimiter-UI-Unit","jednotka");
	}
}
