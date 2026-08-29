module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_hu_hu extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Engedélyezve");
        this.Text("GibbonGR-EnabledInCombat-Name", "Engedélyezve amikor a játékos harcban van");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Engedélyezve amikor a játékos utas");
        this.Text("GibbonGR-GracePeriodMin-Name", "Minimális kegyelem időszak");
        this.Text("GibbonGR-GracePeriodMin-Description", "Minimális idő mielőtt egy csapat először hívhat erősítést egy harcban");
        this.Text("GibbonGR-GracePeriodMax-Name", "Maximális kegyelem időszak");
        this.Text("GibbonGR-GracePeriodMax-Description", "Maximális idő mielőtt egy csapat először hívhat erősítést egy harcban");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Minimális hívás cooldown");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Minimális idő amit egy csapat várnia kell mielőtt újra hívhat erősítést ugyanabban a harcban");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Maximális hívás cooldown");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Maximális idő amit egy csapat várnia kell mielőtt újra hívhat erősítést ugyanabban a harcban");
        this.Text("GibbonGR-InitialHeat-Name", "Kezdeti hő");
        this.Text("GibbonGR-InitialHeat-Description", "Milyen erős lesz az első erősítés hívás");
        this.Text("GibbonGR-HeatEscalation-Name", "Hő eszkaláció");
        this.Text("GibbonGR-HeatEscalation-Description", "Mennyivel nő a hő csapatonként hívásonként");
        this.Text("GibbonGR-CallsLimit-Name", "Hívás limit");
        this.Text("GibbonGR-CallsLimit-Description", "A hívások száma amit egy csapat megtehet mielőtt a limit cooldown-t kell várnia");
        this.Text("GibbonGR-StrongCallChance-Name", "Erős hívás esély");
        this.Text("GibbonGR-StrongCallChance-Description", "Esély hogy a következő erősítés hívás erősebb lesz mint a jelenlegi hő szint");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Erős hívás hő bónusz");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Mennyi extra hőt kap az erős hívás");
        this.Text("GibbonGR-GracePeriod-Category", "Kegyelem időszak");
        this.Text("GibbonGR-Cooldowns-Category", "Cooldown-ok");
        this.Text("GibbonGR-Heat-Category", "Hő");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Előre beállított mód");
        this.Text("GibbonGR-PresetMode-Description", "Válassz előre beállított módok közül különböző játékélményekért");
        this.Text("GibbonGR-PresetMode-Limited", "Könnyű");
        this.Text("GibbonGR-PresetMode-Balanced", "Kiegyensúlyozott");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Ritka és drámai");
        this.Text("GibbonGR-PresetMode-Chaos", "Káosz");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Haladó beállítások megjelenítése");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Haladó beállítások megjelenítése az egyedi paraméterek finomhangolásához. Felülírja az előre beállított módot.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Minimum jármű hívásonként");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Minimum járműszám ami megjelenik egyetlen erősítés hívásban");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Maximum jármű hívásonként");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Maximum járműszám ami megjelenhet egyetlen erősítés hívásban");
	}
}
