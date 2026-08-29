module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_de_de extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Aktiviert");
        this.Text("GibbonGR-EnabledInCombat-Name", "Aktiviert wenn Spieler im Kampf ist");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Aktiviert wenn Spieler Beifahrer ist");
        this.Text("GibbonGR-GracePeriodMin-Name", "Minimale Schonfrist");
        this.Text("GibbonGR-GracePeriodMin-Description", "Minimale Zeit bevor ein Gang das erste Mal in einem Kampf Verstärkung rufen kann");
        this.Text("GibbonGR-GracePeriodMax-Name", "Maximale Schonfrist");
        this.Text("GibbonGR-GracePeriodMax-Description", "Maximale Zeit bevor ein Gang das erste Mal in einem Kampf Verstärkung rufen kann");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Minimale Anruf-Abklingzeit");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Minimale Zeit die ein Gang warten muss bevor er im selben Kampf wieder Verstärkung rufen kann");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Maximale Anruf-Abklingzeit");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Maximale Zeit die ein Gang warten muss bevor er im selben Kampf wieder Verstärkung rufen kann");
        this.Text("GibbonGR-InitialHeat-Name", "Anfängliche Hitze");
        this.Text("GibbonGR-InitialHeat-Description", "Wie stark der erste Verstärkungsanruf sein wird");
        this.Text("GibbonGR-HeatEscalation-Name", "Hitze-Eskalation");
        this.Text("GibbonGR-HeatEscalation-Description", "Um wie viel die Hitze pro Gang pro Anruf steigt");
        this.Text("GibbonGR-CallsLimit-Name", "Anruf-Limit");
        this.Text("GibbonGR-CallsLimit-Description", "Die Anzahl der Anrufe die ein Gang machen kann bevor er die Limit Abklingzeit warten muss");
        this.Text("GibbonGR-StrongCallChance-Name", "Starker Anruf Chance");
        this.Text("GibbonGR-StrongCallChance-Description", "Chance dass der nächste Verstärkungsanruf stärker als das aktuelle Hitze-Level sein wird");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Starker Anruf Hitze-Bonus");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Wie viel extra Hitze der starke Anruf haben wird");
        this.Text("GibbonGR-GracePeriod-Category", "Schonfrist");
        this.Text("GibbonGR-Cooldowns-Category", "Abklingzeiten");
        this.Text("GibbonGR-Heat-Category", "Hitze");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Voreinstellungs-Modus");
        this.Text("GibbonGR-PresetMode-Description", "Wähle aus vordefinierten Modi für verschiedene Spielerfahrungen");
        this.Text("GibbonGR-PresetMode-Limited", "Leicht");
        this.Text("GibbonGR-PresetMode-Balanced", "Ausgewogen");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Selten & Dramatisch");
        this.Text("GibbonGR-PresetMode-Chaos", "Chaos");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Erweiterte Einstellungen anzeigen");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Erweiterte Einstellungen anzeigen um einzelne Parameter fein abzustimmen. Überschreibt den Voreinstellungs-Modus.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Minimale Fahrzeuge pro Anruf");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Minimale Anzahl an Fahrzeugen die bei einem einzigen Verstärkungsanruf erscheinen");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Maximale Fahrzeuge pro Anruf");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Maximale Anzahl an Fahrzeugen die bei einem einzigen Verstärkungsanruf erscheinen können");
	}
}
