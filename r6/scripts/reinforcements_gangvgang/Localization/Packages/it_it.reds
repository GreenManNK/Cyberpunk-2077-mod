module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_it_it extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Abilitato");
        this.Text("GibbonGR-EnabledInCombat-Name", "Abilitato quando il giocatore è in combattimento");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Abilitato quando il giocatore è passeggero");
        this.Text("GibbonGR-GracePeriodMin-Name", "Periodo di grazia minimo");
        this.Text("GibbonGR-GracePeriodMin-Description", "Tempo minimo prima che una gang possa chiamare rinforzi per la prima volta in un combattimento");
        this.Text("GibbonGR-GracePeriodMax-Name", "Periodo di grazia massimo");
        this.Text("GibbonGR-GracePeriodMax-Description", "Tempo massimo prima che una gang possa chiamare rinforzi per la prima volta in un combattimento");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Cooldown chiamata minimo");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Tempo minimo che una gang deve aspettare prima di chiamare rinforzi di nuovo nello stesso combattimento");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Cooldown chiamata massimo");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Tempo massimo che una gang deve aspettare prima di chiamare rinforzi di nuovo nello stesso combattimento");
        this.Text("GibbonGR-InitialHeat-Name", "Calore iniziale");
        this.Text("GibbonGR-InitialHeat-Description", "Quanto forte sarà la prima chiamata di rinforzi");
        this.Text("GibbonGR-HeatEscalation-Name", "Escalation del calore");
        this.Text("GibbonGR-HeatEscalation-Description", "Di quanto aumenta il calore per gang per chiamata");
        this.Text("GibbonGR-CallsLimit-Name", "Limite chiamate");
        this.Text("GibbonGR-CallsLimit-Description", "Il numero di chiamate che una gang può fare prima di dover aspettare il cooldown limite");
        this.Text("GibbonGR-StrongCallChance-Name", "Probabilità chiamata forte");
        this.Text("GibbonGR-StrongCallChance-Description", "Probabilità che la prossima chiamata di rinforzi sia più forte del livello di calore attuale");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Bonus calore chiamata forte");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Quanto calore extra avrà la chiamata forte");
        this.Text("GibbonGR-GracePeriod-Category", "Periodo di grazia");
        this.Text("GibbonGR-Cooldowns-Category", "Cooldown");
        this.Text("GibbonGR-Heat-Category", "Calore");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Modalità Preset");
        this.Text("GibbonGR-PresetMode-Description", "Scegli tra modalità predefinite per esperienze di gioco diverse");
        this.Text("GibbonGR-PresetMode-Limited", "Leggera");
        this.Text("GibbonGR-PresetMode-Balanced", "Bilanciata");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Rara e Drammatica");
        this.Text("GibbonGR-PresetMode-Chaos", "Caos");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Mostra Impostazioni Avanzate");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Mostra impostazioni avanzate per regolare i singoli parametri. Sostituisce la modalità preset.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Veicoli Minimi Per Chiamata");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Numero minimo di veicoli che appaiono in una singola chiamata di rinforzi");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Veicoli Massimi Per Chiamata");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Numero massimo di veicoli che possono apparire in una singola chiamata di rinforzi");
	}
}
