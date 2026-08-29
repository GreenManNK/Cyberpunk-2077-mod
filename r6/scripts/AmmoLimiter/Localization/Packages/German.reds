module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class German extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === ALLGEMEINE OPTIONEN ===
		this.Text("AmmoLimiter-Settings-Title","Munitionsbegrenzer");
		this.Text("AmmoLimiter-Settings-Options","• Allgemeine Optionen");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Nachrichten anzeigen");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Nachrichten über Munitionskonvertierung, -lagerung oder -wiederherstellung anzeigen.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Strenge Munitionsbegrenzung im Inventar");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Ermöglicht strenge Begrenzung von Transfers ins Inventar, Käufen und Munitionsherstellung, im Gegensatz zur standardmäßigen weichen Begrenzung.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Warnung bei wenig Munition (Schwellenwert in %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Wenn der Schwellenwert größer als 0% ist, ermöglicht es zu warnen, wenn die verbleibende Munitionsmenge der gezogenen Waffe unter dem Schwellenwert liegt.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Manuelles Munitionsdemontieren deaktivieren");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Ermöglicht das Deaktivieren der Möglichkeit, Munition manuell zu demontieren, ohne andere Mod-Mechanismen zu deaktivieren.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Wiederherstellung aus Demontage (% des Magazins)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Ermöglicht es, Munition beim Demontieren einer Waffe zu erhalten, auch wenn sie kaputt ist. Zufällige Menge zwischen 0 und diesem % der maximalen Kapazität ihres Magazins. Ergänzt das Handicap-System.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Munitionsanzeigekatsgorie");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Wählen Sie, in welcher Inventarkategorie Munition und Rezepte angezeigt werden sollen.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Fernkampfwaffen");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Waffenaufsätze");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Kampfverbrauchsgegenstände");

		// === MUNITIONSGRENZEN ===
		this.Text("AmmoLimiter-Settings-Limits","• Munitionsgrenzen im Inventar");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Schlafende Munitionskontrolle");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Verhindert Ansammlung durch Aufheben von Munition, die nicht zur aktiven Waffe passt, direkt konvertiert oder zu Boden fallen gelassen.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Aktive Waffe Grenzbonus (in %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Ermöglicht es, die Grenze für Munition zu überschreiten, die zur ausgerüsteten Waffe gehört.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Maximale Handfeuerwaffen-Munition im Inventar, gilt nur für Aufheben und Herstellung.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Maximale schwere Waffen-Munition im Inventar, gilt nur für Aufheben und Herstellung.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Maximale Schrotflinten-Munition im Inventar, gilt nur für Aufheben und Herstellung.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Maximale Scharfschützen-Munition im Inventar, gilt nur für Aufheben und Herstellung.");

		// === MUNITIONSKISTEN ===
		this.Text("AmmoLimiter-Settings-Box","• Maximale Mengen in Kisten gefunden");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Maximale Menge an Handfeuerwaffen-Munition in jeder Kiste in der Welt.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Maximale Menge an schweren Waffen-Munition in jeder Kiste in der Welt.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Maximale Menge an Schrotflinten-Munition in jeder Kiste in der Welt.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Maximale Menge an Scharfschützen-Munition in jeder Kiste in der Welt.");

		// === HANDICAP-SYSTEM ===
		this.Text("AmmoLimiter-Settings-Hand","• Handicap-System");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Handicap-Modus");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Reguliert die Munitionswiederherstellung von Feinden entsprechend Ihrer aktuellen Menge. Der \"Optimierte\" Modus wird aus Ihren Einstellungen berechnet und ist ausgewogen.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Optimiert (empfohlen)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Deaktiviert");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Benutzerdefiniert");

		// === BENUTZERDEFINIERTES HANDICAP NACH MUNITION ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Benutzerdefiniertes Handicap nach Munition");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Handfeuerwaffe - Handicap-Schwellenwert");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Handfeuerwaffe - Minimum");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Handfeuerwaffe - Maximum");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Schwere Waffe - Handicap-Schwellenwert");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Schwere Waffe - Minimum");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Schwere Waffe - Maximum");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Schrotflinte - Handicap-Schwellenwert");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Schrotflinte - Minimum");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Schrotflinte - Maximum");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Scharfschütze - Handicap-Schwellenwert");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Scharfschütze - Minimum");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Scharfschütze - Maximum");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Handicap-Auslöseschwelle, unter der Beute Munition verstecken kann.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Minimum an wiederherstellbarer Munition, wenn Handicap aktiv ist.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Maximum an wiederherstellbarer Munition, wenn Handicap aktiv ist.");

		// === MUNITIONSGEWICHT ===
		this.Text("AmmoLimiter-Settings-Weight","• Munitionsgewicht");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Gewicht einer Handfeuerwaffen-Munition.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Gewicht einer schweren Waffen-Munition.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Gewicht einer Schrotflinten-Munition.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Gewicht einer Scharfschützen-Munition.");

		// === MUNITIONSPREISMULTIPLIKATOREN ===
		this.Text("AmmoLimiter-Settings-Eddies","• Munitionspreismultiplikatoren");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Kaufpreismultiplikator für eine Handfeuerwaffen-Munition in Eddies.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Kaufpreismultiplikator für eine schwere Waffen-Munition in Eddies.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Kaufpreismultiplikator für eine Schrotflinten-Munition in Eddies.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Kaufpreismultiplikator für eine Scharfschützen-Munition in Eddies.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Automatischer Überschussverkauf (in % des Kaufpreises)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Prozentsatz des automatischen Verkaufspreises basierend auf dem Rohkaufpreis (ohne Rabatt) für überschüssige Munition (0 = deaktiviert).");

		// === HERSTELLUNG & KONVERTIERUNG ===
		this.Text("AmmoLimiter-Settings-Craft","• Munitions-Batch-Herstellung");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Menge an Handfeuerwaffen-Munition pro Batch-Herstellung.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Menge an schweren Waffen-Munition pro Batch-Herstellung.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Menge an Schrotflinten-Munition pro Batch-Herstellung.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Menge an Scharfschützen-Munition pro Batch-Herstellung.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Für Herstellung erforderliche Komponenten");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Menge an Komponenten, die benötigt werden, um 1 Batch Munition herzustellen.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Automatische Munitionskonvertierung (in %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Prozentsatz der automatischen Munitionskonvertierung zu Komponenten.");

		// === IN-GAME TEXTE ===
		this.Text("AmmoLimiter-Message-Dropped","zu Boden fallen gelassen");
		this.Text("AmmoLimiter-Message-Crafted","konvertiert zu");
		this.Text("AmmoLimiter-Message-Recovered","Wiederhergestellt:");
		this.Text("AmmoLimiter-Message-From","von");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Munitionsgrenze erreicht!");
		// Bitte respektieren Sie meinen Humor, indem Sie das Wort "PROUTS" NIEMALS ändern:
		this.Text("AmmoLimiter-UI-LowAmmoWarning","UNZUREICHENDE PROUTS RESERVE!");
		this.Text("AmmoLimiter-UI-Total","insgesamt");
		this.Text("AmmoLimiter-UI-Unit","Einheit");
	}
}
