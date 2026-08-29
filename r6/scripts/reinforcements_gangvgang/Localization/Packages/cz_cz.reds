module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_cz_cz extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Povoleno");
        this.Text("GibbonGR-EnabledInCombat-Name", "Povoleno když je hráč v boji");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Povoleno když je hráč pasažér");
        this.Text("GibbonGR-GracePeriodMin-Name", "Minimální milostivé období");
        this.Text("GibbonGR-GracePeriodMin-Description", "Minimální čas předtím, než může gang poprvé zavolat posily v boji");
        this.Text("GibbonGR-GracePeriodMax-Name", "Maximální milostivé období");
        this.Text("GibbonGR-GracePeriodMax-Description", "Maximální čas předtím, než může gang poprvé zavolat posily v boji");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Minimální doba čekání volání");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Minimální čas, který musí gang počkat před dalším voláním posil ve stejném boji");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Maximální doba čekání volání");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Maximální čas, který musí gang počkat před dalším voláním posil ve stejném boji");
        this.Text("GibbonGR-InitialHeat-Name", "Počáteční heat");
        this.Text("GibbonGR-InitialHeat-Description", "Jak silné bude první volání posil");
        this.Text("GibbonGR-HeatEscalation-Name", "Eskalace heat");
        this.Text("GibbonGR-HeatEscalation-Description", "O kolik se heat zvýší pro každý gang při každém volání");
        this.Text("GibbonGR-CallsLimit-Name", "Limit volání");
        this.Text("GibbonGR-CallsLimit-Description", "Počet volání, které může gang udělat před tím, než musí počkat dobu čekání limitu");
        this.Text("GibbonGR-StrongCallChance-Name", "Šance na silné volání");
        this.Text("GibbonGR-StrongCallChance-Description", "Šance, že další volání posil bude silnější než současná úroveň heat");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Heat bonus pro silné volání");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Kolik extra heat bude mít silné volání");
        this.Text("GibbonGR-GracePeriod-Category", "Milostivé období");
        this.Text("GibbonGR-Cooldowns-Category", "Doby čekání");
        this.Text("GibbonGR-Heat-Category", "Heat");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Režim přednastavení");
        this.Text("GibbonGR-PresetMode-Description", "Vyberte z přednastavených režimů pro různé herní zážitky");
        this.Text("GibbonGR-PresetMode-Limited", "Lehký");
        this.Text("GibbonGR-PresetMode-Balanced", "Vyvážený");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Vzácný a dramatický");
        this.Text("GibbonGR-PresetMode-Chaos", "Chaos");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Zobrazit pokročilá nastavení");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Zobrazit pokročilá nastavení pro jemné doladění jednotlivých parametrů. Přepíše režim přednastavení.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Minimální vozidla na volání");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Minimální počet vozidel, které se objeví při jediném volání posil");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Maximální vozidla na volání");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Maximální počet vozidel, které se mohou objevit při jediném volání posil");
	}
}
