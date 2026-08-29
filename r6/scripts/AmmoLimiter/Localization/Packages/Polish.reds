module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Polish extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === OPCJE OGÓLNE ===
		this.Text("AmmoLimiter-Settings-Title","Ogranicznik Amunicji");
		this.Text("AmmoLimiter-Settings-Options","• Opcje ogólne");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Wyświetlaj wiadomości");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Wyświetlaj wiadomości o konwersji, przechowywaniu lub odzyskiwaniu amunicji.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Ścisłe ograniczenie amunicji w ekwipunku");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Pozwala na ścisłe ograniczenie transferów do ekwipunku, zakupów i wytwarzania amunicji, w przeciwieństwie do domyślnego miękkiego ograniczenia.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Ostrzeżenie o małej ilości amunicji (próg w %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Gdy próg jest większy niż 0%, pozwala ostrzegać, gdy pozostała ilość amunicji dobytej broni jest poniżej progu.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Wyłącz ręczny demontaż amunicji");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Pozwala wyłączyć możliwość ręcznego demontażu amunicji, bez wyłączania innych mechanizmów moda.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Odzyskiwanie z demontażu (% magazynka)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Pozwala uzyskać amunicję podczas demontażu broni, nawet zepsutej. Losowa ilość między 0 a tym % maksymalnej pojemności jej magazynka. Uzupełnia system handicapu.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Kategoria wyświetlania amunicji");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Wybierz w której kategorii ekwipunku wyświetlać amunicję i przepisy.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Broń dystansowa");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Dodatki do broni");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Materiały bojowe");

		// === LIMITY AMUNICJI ===
		this.Text("AmmoLimiter-Settings-Limits","• Limity amunicji w ekwipunku");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Kontrola śpiącej amunicji");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Zapobiega gromadzeniu przez podnoszenie amunicji niepasującej do aktywnej broni, bezpośrednio konwertowanej lub upuszczonej na ziemię.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Bonus limitu aktywnej broni (w %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Pozwala przekroczyć limit dla amunicji odpowiadającej wyposażonej broni.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Maksimum amunicji do pistoletu w ekwipunku, dotyczy tylko podnoszenia i wytwarzania.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Maksimum amunicji do ciężkiej broni w ekwipunku, dotyczy tylko podnoszenia i wytwarzania.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Maksimum amunicji do strzelby w ekwipunku, dotyczy tylko podnoszenia i wytwarzania.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Maksimum amunicji snajperskiej w ekwipunku, dotyczy tylko podnoszenia i wytwarzania.");

		// === SKRZYNKI Z AMUNICJĄ ===
		this.Text("AmmoLimiter-Settings-Box","• Maksymalne ilości znalezione w skrzynkach");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Maksymalna ilość amunicji do pistoletu w każdej skrzynce na świecie.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Maksymalna ilość amunicji do ciężkiej broni w każdej skrzynce na świecie.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Maksymalna ilość amunicji do strzelby w każdej skrzynce na świecie.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Maksymalna ilość amunicji snajperskiej w każdej skrzynce na świecie.");

		// === SYSTEM HANDICAPU ===
		this.Text("AmmoLimiter-Settings-Hand","• System handicapu");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Tryb handicapu");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Reguluje odzyskiwanie amunicji z wrogów zgodnie z twoją obecną ilością. Tryb \"Zoptymalizowany\" jest obliczany z twoich ustawień i jest zrównoważony.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Zoptymalizowany (zalecany)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Wyłączony");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Niestandardowy");

		// === NIESTANDARDOWY HANDICAP WG AMUNICJI ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Niestandardowy handicap wg amunicji");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Pistolet - próg handicapu");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Pistolet - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Pistolet - maksimum");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Ciężka broń - próg handicapu");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Ciężka broń - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Ciężka broń - maksimum");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Strzelba - próg handicapu");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Strzelba - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Strzelba - maksimum");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Snajper - próg handicapu");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Snajper - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Snajper - maksimum");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Próg wyzwalania handicapu, poniżej którego łup może ukryć amunicję.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Minimum odzyskiwalnej amunicji, jeśli handicap jest aktywny.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Maksimum odzyskiwalnej amunicji, jeśli handicap jest aktywny.");

		// === WAGA AMUNICJI ===
		this.Text("AmmoLimiter-Settings-Weight","• Waga amunicji");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Waga jednej amunicji do pistoletu.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Waga jednej amunicji do ciężkiej broni.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Waga jednej amunicji do strzelby.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Waga jednej amunicji snajperskiej.");

		// === MNOŻNIKI CEN AMUNICJI ===
		this.Text("AmmoLimiter-Settings-Eddies","• Mnożniki cen amunicji");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Mnożnik ceny zakupu jednej amunicji do pistoletu w eddies.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Mnożnik ceny zakupu jednej amunicji do ciężkiej broni w eddies.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Mnożnik ceny zakupu jednej amunicji do strzelby w eddies.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Mnożnik ceny zakupu jednej amunicji snajperskiej w eddies.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Automatyczna sprzedaż nadmiaru (w % ceny zakupu)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Procent automatycznej ceny sprzedaży oparty na surowej cenie zakupu (bez zniżki) dla nadmiarowej amunicji (0 = wyłączony).");

		// === WYTWARZANIE I KONWERSJA ===
		this.Text("AmmoLimiter-Settings-Craft","• Wytwarzanie partii amunicji");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Ilość amunicji do pistoletu na wytworzenie partii.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Ilość amunicji do ciężkiej broni na wytworzenie partii.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Ilość amunicji do strzelby na wytworzenie partii.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Ilość amunicji snajperskiej na wytworzenie partii.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Komponenty wymagane do wytwarzania");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Ilość komponentów potrzebnych do wytworzenia 1 partii amunicji.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Automatyczna konwersja amunicji (w %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Procent automatycznej konwersji amunicji na komponenty.");

		// === TEKSTY W GRZE ===
		this.Text("AmmoLimiter-Message-Dropped","upuszczone na ziemię");
		this.Text("AmmoLimiter-Message-Crafted","przekonwertowane na");
		this.Text("AmmoLimiter-Message-Recovered","Odzyskano:");
		this.Text("AmmoLimiter-Message-From","z");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Osiągnięto limit amunicji!");
		// Proszę szanować mój humor, NIGDY nie modyfikując słowa "PROUTS":
		this.Text("AmmoLimiter-UI-LowAmmoWarning","NIEWYSTARCZAJĄCA REZERWA PROUTS!");
		this.Text("AmmoLimiter-UI-Total","łącznie");
		this.Text("AmmoLimiter-UI-Unit","jednostka");
	}
}
