module Gibbon.GR.Localization.Packages
import Codeware.Localization.*
public class GR_pl_pl extends ModLocalizationPackage{
	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Włączone");
        this.Text("GibbonGR-EnabledInCombat-Name", "Włączone gdy gracz jest w walce");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Włączone gdy gracz jest pasażerem");
        this.Text("GibbonGR-GracePeriodMin-Name", "Minimalny okres łaski");
        this.Text("GibbonGR-GracePeriodMin-Description", "Minimalny czas zanim gang może po raz pierwszy wezwać wsparcie w walce");
        this.Text("GibbonGR-GracePeriodMax-Name", "Maksymalny okres łaski");
        this.Text("GibbonGR-GracePeriodMax-Description", "Maksymalny czas zanim gang może po raz pierwszy wezwać wsparcie w walce");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Minimalny cooldown wezwania");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Minimalny czas jaki gang musi czekać przed ponownym wezwaniem wsparcia w tej samej walce");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Maksymalny cooldown wezwania");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Maksymalny czas jaki gang musi czekać przed ponownym wezwaniem wsparcia w tej samej walce");
        this.Text("GibbonGR-InitialHeat-Name", "Początkowy heat");
        this.Text("GibbonGR-InitialHeat-Description", "Jak silne będzie pierwsze wezwanie wsparcia");
        this.Text("GibbonGR-HeatEscalation-Name", "Wzrost heat");
        this.Text("GibbonGR-HeatEscalation-Description", "O ile wzrasta heat na gang na wezwanie");
        this.Text("GibbonGR-CallsLimit-Name", "Limit wezwań");
        this.Text("GibbonGR-CallsLimit-Description", "Liczba wezwań jaką gang może wykonać przed koniecznością czekania na cooldown");
        this.Text("GibbonGR-StrongCallChance-Name", "Szansa na silne wezwanie");
        this.Text("GibbonGR-StrongCallChance-Description", "Szansa że następne wezwanie wsparcia będzie silniejsze niż obecny poziom heat");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Bonus heat za mocne wezwanie");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Ile dodatkowego heat będzie miało silne wezwanie");
        this.Text("GibbonGR-GracePeriod-Category", "Okres łaski");
        this.Text("GibbonGR-Cooldowns-Category", "Cooldowny");
        this.Text("GibbonGR-Heat-Category", "Heat");
        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Tryb ustawień");
        this.Text("GibbonGR-PresetMode-Description", "Wybierz z presetów dla różnych doświadczeń rozgrywki");
        this.Text("GibbonGR-PresetMode-Limited", "Ograniczony");
        this.Text("GibbonGR-PresetMode-Balanced", "Zbalansowany");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Rzadkie Epickie Bitwy");
        this.Text("GibbonGR-PresetMode-Chaos", "Chaos");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Pokaż zaawansowane ustawienia");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Pokaż zaawansowane ustawienia do precyzyjnego dostrojenia parametrów. Nadpisuje preset mode.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Min pojazdów na wezwanie");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Minimalna liczba pojazdów które pojawiają się w jednym wezwaniu wsparcia");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Max pojazdów na wezwanie");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Maksymalna liczba pojazdów które mogą się pojawić w jednym wezwaniu wsparcia");
	}
}
