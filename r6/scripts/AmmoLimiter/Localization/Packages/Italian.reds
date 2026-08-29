module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Italian extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === OPZIONI GENERALI ===
		this.Text("AmmoLimiter-Settings-Title","Limitatore Munizioni");
		this.Text("AmmoLimiter-Settings-Options","• Opzioni generali");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Visualizza messaggi");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Visualizza messaggi di conversione, deposito o recupero munizioni.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Limitazione rigorosa munizioni nell'inventario");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Consente di limitare rigorosamente i trasferimenti nell'inventario, gli acquisti e la fabbricazione di munizioni, a differenza della limitazione morbida predefinita.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Avviso munizioni scarse (soglia in %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Quando la soglia è superiore a 0%, consente di avvisare quando la quantità rimanente di munizioni dell'arma estratta è sotto la soglia.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Disabilita smontaggio manuale munizioni");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Consente di disabilitare la possibilità di smontare manualmente le munizioni, senza disabilitare gli altri meccanismi del mod.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Recupero da smontaggio (% del caricatore)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Consente di ottenere munizioni quando si smonta un'arma, anche rotta. Quantità casuale tra 0 e questa % della capacità massima del suo caricatore. Complementa il sistema di handicap.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Categoria visualizzazione munizioni");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Scegli in quale categoria di inventario visualizzare munizioni e ricette.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Armi a distanza");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Accessori armi");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Consumabili da combattimento");

		// === LIMITI MUNIZIONI ===
		this.Text("AmmoLimiter-Settings-Limits","• Limiti munizioni nell'inventario");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Controllo munizioni dormienti");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Impedisce l'accumulo raccogliendo munizioni che non corrispondono all'arma attiva, direttamente convertite o lasciate cadere a terra.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Bonus limite arma attiva (in %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Consente di superare il limite per le munizioni corrispondenti all'arma equipaggiata.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Massimo munizioni pistola nell'inventario, si applica solo a raccolta e fabbricazione.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Massimo munizioni arma pesante nell'inventario, si applica solo a raccolta e fabbricazione.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Massimo munizioni fucile a pompa nell'inventario, si applica solo a raccolta e fabbricazione.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Massimo munizioni cecchino nell'inventario, si applica solo a raccolta e fabbricazione.");

		// === SCATOLE MUNIZIONI ===
		this.Text("AmmoLimiter-Settings-Box","• Quantità massime trovate nelle scatole");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Quantità massima di munizioni pistola in ogni scatola nel mondo.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Quantità massima di munizioni arma pesante in ogni scatola nel mondo.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Quantità massima di munizioni fucile a pompa in ogni scatola nel mondo.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Quantità massima di munizioni cecchino in ogni scatola nel mondo.");

		// === SISTEMA HANDICAP ===
		this.Text("AmmoLimiter-Settings-Hand","• Sistema handicap");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Modalità handicap");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Regola il recupero munizioni dai nemici secondo la tua quantità attuale. La modalità \"Ottimizzata\" è calcolata dalle tue impostazioni ed è bilanciata.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Ottimizzata (raccomandato)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Disabilitato");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Personalizzato");

		// === HANDICAP PERSONALIZZATO PER MUNIZIONI ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Handicap personalizzato per munizioni");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Pistola - soglia handicap");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Pistola - minimo");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Pistola - massimo");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Arma pesante - soglia handicap");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Arma pesante - minimo");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Arma pesante - massimo");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Fucile a pompa - soglia handicap");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Fucile a pompa - minimo");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Fucile a pompa - massimo");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Cecchino - soglia handicap");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Cecchino - minimo");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Cecchino - massimo");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Soglia di attivazione handicap sotto la quale il loot può nascondere munizioni.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Minimo di munizioni recuperabili se l'handicap è attivo.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Massimo di munizioni recuperabili se l'handicap è attivo.");

		// === PESO MUNIZIONI ===
		this.Text("AmmoLimiter-Settings-Weight","• Peso munizioni");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Peso di una munizione pistola.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Peso di una munizione arma pesante.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Peso di una munizione fucile a pompa.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Peso di una munizione cecchino.");

		// === MOLTIPLICATORI PREZZO MUNIZIONI ===
		this.Text("AmmoLimiter-Settings-Eddies","• Moltiplicatori prezzo munizioni");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Moltiplicatore prezzo d'acquisto per una munizione pistola in eddies.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Moltiplicatore prezzo d'acquisto per una munizione arma pesante in eddies.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Moltiplicatore prezzo d'acquisto per una munizione fucile a pompa in eddies.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Moltiplicatore prezzo d'acquisto per una munizione cecchino in eddies.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Vendita automatica eccesso (in % del prezzo d'acquisto)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Percentuale del prezzo di vendita automatica basata sul prezzo d'acquisto lordo (senza sconto) per munizioni eccedenti (0 = disabilitato).");

		// === FABBRICAZIONE & CONVERSIONE ===
		this.Text("AmmoLimiter-Settings-Craft","• Fabbricazione lotti munizioni");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Quantità di munizioni pistola per fabbricazione lotto.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Quantità di munizioni arma pesante per fabbricazione lotto.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Quantità di munizioni fucile a pompa per fabbricazione lotto.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Quantità di munizioni cecchino per fabbricazione lotto.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Componenti richiesti per fabbricazione");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Quantità di componenti necessari per fabbricare 1 lotto di munizioni.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Conversione automatica munizioni (in %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Percentuale di conversione automatica delle munizioni in componenti.");

		// === TESTI IN GIOCO ===
		this.Text("AmmoLimiter-Message-Dropped","lasciato cadere a terra");
		this.Text("AmmoLimiter-Message-Crafted","convertito in");
		this.Text("AmmoLimiter-Message-Recovered","Recuperato:");
		this.Text("AmmoLimiter-Message-From","da");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Limite munizioni raggiunto!");
		// Per favore rispettate il mio umorismo non modificando MAI la parola "PROUTS":
		this.Text("AmmoLimiter-UI-LowAmmoWarning","RISERVA INSUFFICIENTE DI PROUTS!");
		this.Text("AmmoLimiter-UI-Total","totale");
		this.Text("AmmoLimiter-UI-Unit","unità");
	}
}
