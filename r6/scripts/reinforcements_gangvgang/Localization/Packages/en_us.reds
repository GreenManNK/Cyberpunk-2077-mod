module Gibbon.GR.Localization.Packages

import Codeware.Localization.*

public class GR_en_us extends ModLocalizationPackage {
    protected func DefineTexts() {
        this.Text("GibbonGR-Title", "Reinforcements Gang Vs Gang");
        this.Text("GibbonGR-Enabled-Name", "Enabled");
        this.Text("GibbonGR-EnabledInCombat-Name", "Enabled When Player in Combat");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Enabled When Player is Passenger");
        this.Text("GibbonGR-GracePeriodMin-Name", "Minimum Grace Period");
        this.Text("GibbonGR-GracePeriodMin-Description", "Minimum time before a gang can call for backup the first time in a fight");
        this.Text("GibbonGR-GracePeriodMax-Name", "Maximum Grace Period");
        this.Text("GibbonGR-GracePeriodMax-Description", "Maximum time before a gang can call for backup the first time in a fight");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Minimum Call Cooldown");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Minimum time a gang must wait before calling for backup again in the same fight");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Maximum Call Cooldown");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Maximum time a gang must wait before calling for backup again in the same fight");
        this.Text("GibbonGR-InitialHeat-Name", "Initial Heat");
        this.Text("GibbonGR-InitialHeat-Description", "How strong the first backup call will be");
        this.Text("GibbonGR-HeatEscalation-Name", "Heat Escalation");
        this.Text("GibbonGR-HeatEscalation-Description", "Amount heat increases per gang per call");
        this.Text("GibbonGR-CallsLimit-Name", "Calls Limit");
        this.Text("GibbonGR-CallsLimit-Description", "The number of calls a gang can make before they must wait the limit cooldown");
        this.Text("GibbonGR-StrongCallChance-Name", "Stronger Call Chance");
        this.Text("GibbonGR-StrongCallChance-Description", "Chance the next backup call will be stronger than the current heat level");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Stronger Call Heat Bonus");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "How much extra heat the strong call will have");
        this.Text("GibbonGR-GracePeriod-Category", "Grace Period");
        this.Text("GibbonGR-Cooldowns-Category", "Cooldowns");
        this.Text("GibbonGR-Heat-Category", "Heat");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Preset Mode");
        this.Text("GibbonGR-PresetMode-Description", "Choose from preset modes for different gameplay experiences");
        this.Text("GibbonGR-PresetMode-Limited", "Limited");
        this.Text("GibbonGR-PresetMode-Balanced", "Balanced");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Rare Big Battles");
        this.Text("GibbonGR-PresetMode-Chaos", "Chaos");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Show Advanced Settings");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Show advanced settings to fine-tune individual parameters. Overrides the preset mode.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Minimum Vehicles Per Call");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Minimum number of vehicles that spawn in a single backup call");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Maximum Vehicles Per Call");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Maximum number of vehicles that can spawn in a single backup call");
    }
}

