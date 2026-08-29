module Gibbon.GR.Settings

import Gibbon.GR.Logging.*
import Gibbon.GR.ReinforcementSystem.*

enum PresetMode {
    Limited = 0,
    Balanced = 1,
    RareBigFight = 2,
    Chaos = 3,
}

public class GRSettings extends ScriptableSystem {
	private let debug: Bool = false;

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRSettings> {
        let system: ref<GRSettings> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.Settings.GRSettings") as GRSettings;
        return system;
    }

    public func OnAttach() -> Void {
        ModSettings.RegisterListenerToClass(this);
        ModSettings.RegisterListenerToModifications(this);
    }

    public func OnDetach() -> Void {
        ModSettings.UnregisterListenerToClass(this);
        ModSettings.UnregisterListenerToModifications(this);
    }

    public cb func OnModSettingsChange() -> Void {
        this.ReconcileSettings();
    }

    public func ReconcileSettings() -> Void {
        //GRLog("Reconciling settings");
        if this.useAdvancedSettings {
            this.gracePeriodMin = MinF(this._gracePeriodMin, this.gracePeriodMax);
            this.gracePeriodMax = MaxF(this._gracePeriodMin, this.gracePeriodMax);
            this.callSuccessCooldownMin = MinF(this._callSuccessCooldownMin, this.callSuccessCooldownMax);
            this.callSuccessCooldownMax = MaxF(this._callSuccessCooldownMin, this.callSuccessCooldownMax);
            this.initialHeat = this._initialHeat;
            this.heatEscalation = this._heatEscalation;
            this.callsLimit = this._callsLimit;
            this.strongCallChance = this._strongCallChance;
            this.strongCallHeatBonus = this._strongCallHeatBonus;
            this.minVehiclesPerCall = Min(this._minVehiclesPerCall, this._maxVehiclesPerCall);
            this.maxVehiclesPerCall = Max(this._minVehiclesPerCall, this._maxVehiclesPerCall);
        } else {
            if Equals(this.presetMode, PresetMode.Limited) {
                this.gracePeriodMin = 20;
                this.gracePeriodMax = 30;
                this.callSuccessCooldownMin = 45;
                this.callSuccessCooldownMax = 60;
                this.initialHeat = 1;
                this.heatEscalation = 1;
                this.callsLimit = 3;
                this.strongCallChance = 25;
                this.strongCallHeatBonus = 8;
                this.minVehiclesPerCall = 1;
                this.maxVehiclesPerCall = 1;
            } else if Equals(this.presetMode, PresetMode.Balanced) {
                this.gracePeriodMin = 20;
                this.gracePeriodMax = 30;
                this.callSuccessCooldownMin = 45;
                this.callSuccessCooldownMax = 60;
                this.initialHeat = 2;
                this.heatEscalation = 3;
                this.callsLimit = 6;
                this.strongCallChance = 25;
                this.strongCallHeatBonus = 8;
                this.minVehiclesPerCall = 1;
                this.maxVehiclesPerCall = 2;
            } else if Equals(this.presetMode, PresetMode.RareBigFight) {
                this.gracePeriodMin = 40;
                this.gracePeriodMax = 60;
                this.callSuccessCooldownMin = 45;
                this.callSuccessCooldownMax = 60;
                this.initialHeat = 15;
                this.heatEscalation = 5;
                this.callsLimit = 1;
                this.strongCallChance = 35;
                this.strongCallHeatBonus = 5;
                this.minVehiclesPerCall = 2;
                this.maxVehiclesPerCall = 4;
            } else if Equals(this.presetMode, PresetMode.Chaos) {
                this.gracePeriodMin = 1;
                this.gracePeriodMax = 5;
                this.callSuccessCooldownMin = 45;
                this.callSuccessCooldownMax = 60;
                this.initialHeat = 10;
                this.heatEscalation = 3;
                this.callsLimit = 10;
                this.strongCallChance = 5;
                this.strongCallHeatBonus = 3;
                this.minVehiclesPerCall = 2;
                this.maxVehiclesPerCall = 4;
            }

			if(this.debug){
				this.gracePeriodMin = 5;
				this.gracePeriodMax = 10;
				this.callSuccessCooldownMin = 5;
				this.callSuccessCooldownMax = 10;
				this.initialHeat = 20;
				this.heatEscalation = 1;
				this.callsLimit = 1;
				this.strongCallChance = 1;
				this.strongCallHeatBonus = 1;
				this.minVehiclesPerCall = 1;
				this.maxVehiclesPerCall = 3;
			}
        }

		GRReinforcementSystem.GetInstance(GetGameInstance()).OnSettingsChanged();
    }
	
    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-Enabled-Name")
    public let enabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-EnabledInCombat-Name")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let enabledWhenPlayerInCombat: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-EnabledWhenPlayerIsPassenger-Name")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let enabledWhenPlayerIsPassenger: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Authority Intervention")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let authorityInterventionEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "6th Street")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let sixthStreetEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Aldecaldos")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let aldecaldosEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Animals")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let animalsEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Arasaka")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let arasakaEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Barghest")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let barghestEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Kang Tao")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let kangTaoEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Maelstrom")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let maelstromEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Militech")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let militechEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Mox")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let moxEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "NCPD")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let ncpdEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Scavs")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let scavsEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Tyger Claws")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let tygerClawsEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Valentinos")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let valentinosEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Voodoo Boys")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let voodooBoysEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "Wraiths")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let wraithsEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-PresetMode-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-PresetMode-Description")
    @runtimeProperty("ModSettings.displayValues.Limited", "GibbonGR-PresetMode-Limited")
    @runtimeProperty("ModSettings.displayValues.Balanced", "GibbonGR-PresetMode-Balanced")
    @runtimeProperty("ModSettings.displayValues.RareBigFight", "GibbonGR-PresetMode-RareBigFight")
    @runtimeProperty("ModSettings.displayValues.Chaos", "GibbonGR-PresetMode-Chaos")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let presetMode: PresetMode = PresetMode.Balanced;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-ShowAdvancedSettings-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-ShowAdvancedSettings-Description")
    @runtimeProperty("ModSettings.dependency", "enabled")
    public let useAdvancedSettings: Bool = false;

    //---------------------------------------------------- GRACE PERIOD ---------------------------------------------------- //
    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-GracePeriodMin-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-GracePeriodMin-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-GracePeriod-Category")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "60")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _gracePeriodMin: Float = 5;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-GracePeriodMax-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-GracePeriodMax-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-GracePeriod-Category")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "60")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _gracePeriodMax: Float = 15;

    //---------------------------------------------------- COOLDOWNS ---------------------------------------------------- //
    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-CallSuccessCooldownMin-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-CallSuccessCooldownMin-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Cooldowns-Category")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "60")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _callSuccessCooldownMin: Float = 15;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-CallSuccessCooldownMax-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-CallSuccessCooldownMax-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Cooldowns-Category")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "60")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _callSuccessCooldownMax: Float = 60;


    //---------------------------------------------------- HEAT --------------------------------------------------------- //
    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-InitialHeat-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-InitialHeat-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Heat-Category")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "20")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _initialHeat: Int32 = 2;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-HeatEscalation-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-HeatEscalation-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Heat-Category")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "4")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _heatEscalation: Int32 = 3;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-CallsLimit-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-CallsLimit-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Heat-Category")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _callsLimit: Int32 = 3;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-StrongCallChance-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-StrongCallChance-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Heat-Category")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "100")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _strongCallChance: Int32 = 20;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-StrongCallHeatBonus-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-StrongCallHeatBonus-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Heat-Category")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _strongCallHeatBonus: Int32 = 8;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-MinVehiclesPerCall-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-MinVehiclesPerCall-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Heat-Category")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "5")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _minVehiclesPerCall: Int32 = 1;

    @runtimeProperty("ModSettings.mod", "GibbonGR-Title")
    @runtimeProperty("ModSettings.displayName", "GibbonGR-MaxVehiclesPerCall-Name")
    @runtimeProperty("ModSettings.description", "GibbonGR-MaxVehiclesPerCall-Description")
    @runtimeProperty("ModSettings.category", "GibbonGR-Heat-Category")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "5")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.dependency", "useAdvancedSettings")
    private let _maxVehiclesPerCall: Int32 = 2;

    //---------------------------------------------------- BACKUP DELAYS ---------------------------------------------------- //

    // Public versions of private members
    public let gracePeriodMin: Float = 5;
    public let gracePeriodMax: Float = 15;
    public let callSuccessCooldownMin: Float = 15;
    public let callSuccessCooldownMax: Float = 60;
    public let initialHeat: Int32 = 2;
    public let heatEscalation: Int32 = 3;
    public let callsLimit: Int32 = 3;
    public let strongCallChance: Int32 = 20;
    public let strongCallHeatBonus: Int32 = 8;
    public let minVehiclesPerCall: Int32 = 1;
    public let maxVehiclesPerCall: Int32 = 2;
}

