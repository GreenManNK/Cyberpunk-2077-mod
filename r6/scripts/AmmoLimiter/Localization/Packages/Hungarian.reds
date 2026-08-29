module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Hungarian extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === ÁLTALÁNOS OPCIÓK ===
		this.Text("AmmoLimiter-Settings-Title","Lőszer korlátozó");
		this.Text("AmmoLimiter-Settings-Options","• Általános opciók");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Üzenetek megjelenítése");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Lőszer konverzió, tárolás vagy visszanyerés üzeneteinek megjelenítése.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Szigorú lőszer korlátozás a készletben");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Lehetővé teszi a készletbe való átvitelek, vásárlások és lőszer készítés szigorú korlátozását, ellentétben az alapértelmezett puha korlátozással.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Alacsony lőszer figyelmeztetés (küszöb %-ban)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Amikor a küszöb nagyobb mint 0%, lehetővé teszi a figyelmeztetést, amikor a kihúzott fegyver fennmaradó lőszer mennyisége a küszöb alatt van.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Kézi lőszer szétszerelés letiltása");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Lehetővé teszi a lőszer kézi szétszerelésének letiltását, anélkül hogy a mod egyéb mechanizmusait letiltaná.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Helyreállítás szétszerelésből (tár %-a)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Lehetővé teszi lőszer szerzését fegyver szétszerelésekor, még ha törött is. Véletlenszerű mennyiség 0 és a tár maximális kapacitásának ezen %-a között. Kiegészíti a hátrány rendszert.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Lőszer megjelenítési kategória");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Válassza ki, hogy melyik készlet kategóriában jelenjenek meg a lőszerek és receptek.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Távolsági fegyverek");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Fegyver kiegészítők");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Harci fogyóeszközök");

		// === LŐSZER KORLÁTOK ===
		this.Text("AmmoLimiter-Settings-Limits","• Lőszer korlátok a készletben");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Alvó lőszer ellenőrzés");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Megakadályozza a felhalmozást olyan lőszer felvételével, ami nem illeszkedik az aktív fegyverhez, közvetlenül konvertálva vagy a földre dobva.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Aktív fegyver korlát bónusz (%-ban)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Lehetővé teszi a korlát túllépését a felszerelt fegyverhez tartozó lőszernél.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Maximális kézifegyver lőszer a készletben, csak felvételre és készítésre vonatkozik.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Maximális nehéz fegyver lőszer a készletben, csak felvételre és készítésre vonatkozik.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Maximális sörétes puska lőszer a készletben, csak felvételre és készítésre vonatkozik.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Maximális mesterlövész lőszer a készletben, csak felvételre és készítésre vonatkozik.");

		// === LŐSZER DOBOZOK ===
		this.Text("AmmoLimiter-Settings-Box","• Dobozokban található maximális mennyiségek");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Maximális kézifegyver lőszer mennyiség minden dobozban a világban.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Maximális nehéz fegyver lőszer mennyiség minden dobozban a világban.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Maximális sörétes puska lőszer mennyiség minden dobozban a világban.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Maximális mesterlövész lőszer mennyiség minden dobozban a világban.");

		// === HÁTRÁNY RENDSZER ===
		this.Text("AmmoLimiter-Settings-Hand","• Hátrány rendszer");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Hátrány mód");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Szabályozza a lőszer visszanyerését az ellenségektől a jelenlegi mennyiségének megfelelően. Az \"Optimalizált\" mód a beállításokból van kiszámítva és kiegyensúlyozott.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Optimalizált (ajánlott)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Letiltva");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Egyéni");

		// === EGYÉNI HÁTRÁNY LŐSZER SZERINT ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Egyéni hátrány lőszer szerint");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Kézifegyver - hátrány küszöb");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Kézifegyver - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Kézifegyver - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Nehéz fegyver - hátrány küszöb");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Nehéz fegyver - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Nehéz fegyver - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Sörétes puska - hátrány küszöb");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Sörétes puska - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Sörétes puska - maximum");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Mesterlövész - hátrány küszöb");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Mesterlövész - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Mesterlövész - maximum");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Hátrány kiváltó küszöb, amely alatt a zsákmány elrejtheti a lőszert.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Minimum visszanyerhető lőszer, ha a hátrány aktív.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Maximum visszanyerhető lőszer, ha a hátrány aktív.");

		// === LŐSZER SÚLY ===
		this.Text("AmmoLimiter-Settings-Weight","• Lőszer súly");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Egy kézifegyver lőszer súlya.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Egy nehéz fegyver lőszer súlya.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Egy sörétes puska lőszer súlya.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Egy mesterlövész lőszer súlya.");

		// === LŐSZER ÁR SZORZÓK ===
		this.Text("AmmoLimiter-Settings-Eddies","• Lőszer ár szorzók");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Vásárlási ár szorzó egy kézifegyver lőszerre eddyben.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Vásárlási ár szorzó egy nehéz fegyver lőszerre eddyben.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Vásárlási ár szorzó egy sörétes puska lőszerre eddyben.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Vásárlási ár szorzó egy mesterlövész lőszerre eddyben.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Automatikus többlet eladás (vásárlási ár %-ában)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Automatikus eladási ár százaléka nyers vásárlási ár alapján (kedvezmény nélkül) többlet lőszerre (0 = letiltva).");

		// === KÉSZÍTÉS & KONVERZIÓ ===
		this.Text("AmmoLimiter-Settings-Craft","• Lőszer adag készítés");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Kézifegyver lőszer mennyiség adag készítésenként.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Nehéz fegyver lőszer mennyiség adag készítésenként.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Sörétes puska lőszer mennyiség adag készítésenként.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Mesterlövész lőszer mennyiség adag készítésenként.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Készítéshez szükséges komponensek");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Komponensek mennyisége 1 adag lőszer készítéséhez.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Automatikus lőszer átalakítás (%-ban)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","A lőszer automatikus átalakításának százaléka összetevőkre.");

		// === JÁTÉKBELI SZÖVEGEK ===
		this.Text("AmmoLimiter-Message-Dropped","földre dobva");
		this.Text("AmmoLimiter-Message-Crafted","konvertálva");
		this.Text("AmmoLimiter-Message-Recovered","Visszanyerve:");
		this.Text("AmmoLimiter-Message-From","től");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Lőszer korlát elérve!");
		// Kérjük, tiszteljék a humoromat azzal, hogy SOHA ne módosítsák a "PROUTS" szót:
		this.Text("AmmoLimiter-UI-LowAmmoWarning","ELÉGTELEN PROUTS TARTALÉK!");
		this.Text("AmmoLimiter-UI-Total","összesen");
		this.Text("AmmoLimiter-UI-Unit","egység");
	}
}
