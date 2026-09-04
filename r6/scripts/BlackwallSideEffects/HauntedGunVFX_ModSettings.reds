/* 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡞⠉⠛⠶⢤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⢰⠞⠛⢷⠀⠈⠙⠳⠦⣄⣀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠘⠒⠒⠋⠀⣠⣤⡀⠀⠀⠉⠛⢶⣤⣀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠋⢀⡴⠖⠶⢦⠀⠀⠀⢧⣬⠇⣀⣠⠴⠞⠋⠁⡏
⠀⠀⠀⠀⠀⠀⠀⠀⣠⠟⠀⠀⠘⠧⣤⣀⡼⠀⢀⣀⡤⠶⢛⣩⣤⣀⠀⢠⡞⠋
⠀⠀⠀⠀⠀⠀⣠⠞⣁⣀⠀⠀⠀⠀⢀⣠⡴⠖⠋⠁⠀⠀⣿⠁⠀⣹⠀⠈⢷⡄
⠀⠀⠀⠀⣠⠞⠁⠀⠷⠿⣀⣤⠴⠚⠉⠁⠀⠀⠀⠀⠀⠀⠈⠓⠒⠃⠀⠀⠀⡇
⠀⠀⣠⠞⣁⣠⡤⠶⠚⠛⠉⠀⠀⠀⣀⡀⠀⠀⠀⠀⢀⡤⠶⠶⠦⣄⠀⠀⠀⡇
⠀⡾⠛⠋⢉⣤⢤⣀⠀⠀⠀⠀⣰⠞⠉⠙⠳⡄⠀⠀⡟⠀⠀⠀⠀⢸⡆⠀⠀⡇
⠀⡇⠀⢰⡏⠀⠀⢹⡆⠀⠀⠀⡇⠀⠀⠀⠀⣿⠀⠀⠳⣄⡀⠀⢀⣸⠇⠀⠀⡇
⠀⡇⠀⠀⢷⣤⣤⠞⠁⠀⠀⠀⢷⣀⣀⣠⡴⠃⠀⠀⠀⠈⠉⠉⠉⠁⣀⣠⠴⠇
⠀⠻⣆⠀⠀⠀⠀⢀⣀⣤⣀⠀⠀⠉⠉⠁⠀⠀⠀⠀⠀⢀⣠⡤⠖⠛⠉⠀⠀⠀
⠀⠀⡿⠀⠀⠀⢰⡏⠀⠀⢹⡆⠀⠀⠀⠀⠀⣀⣤⠶⠚⠉⠁⠀⠀⠀⠀⠀⠀⠀
⢰⠞⠁⠀⠀⠀⠀⢷⣄⣤⠞⠁⣀⣠⠴⠚⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢸⡆⠀⠀⠀⠀⠀⠀⣀⡤⠖⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢸⡇⠀⢀⣠⡴⠞⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠟⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀


 __  __ _     _             _____ _              _     _       
 |  \/  (_)   | |           / ____| |            | |   | |      
 | \  / |_ ___| |_ ___ _ __| |    | |__   ___  __| | __| | __ _ 
 | |\/| | / __| __/ _ \ '__| |    | '_ \ / _ \/ _` |/ _` |/ _` |
 | |  | | \__ \ ||  __/ |  | |____| | | |  __/ (_| | (_| | (_| |
 |_|  |_|_|___/\__\___|_|   \_____|_| |_|\___|\__,_|\__,_|\__,_|


 */


public enum BlackwallSideEffects_IntensityLevel {
    Default = 0,    // Normal intensity and chances
    Low = 1         // Reduced intensity, lower bonus chances, harder heavy VFX trigger
}

public class BlackwallSideEffectsModSettings extends ScriptableSystem {

    public static func Get(gi: GameInstance) -> ref<BlackwallSideEffectsModSettings> {
        return GameInstance.GetScriptableSystemsContainer(gi).Get(n"BlackwallSideEffectsModSettings") as BlackwallSideEffectsModSettings;
    }

    @runtimeProperty("ModSettings.mod", "UI-MisterCheddaBlackwallSideEffects-modtitle")
    @runtimeProperty("ModSettings.displayName", "UI-MisterCheddaBlackwallSideEffects-enable-mod")
    @runtimeProperty("ModSettings.description", "UI-MisterCheddaBlackwallSideEffects-enable-mod-desc")
    let enabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "UI-MisterCheddaBlackwallSideEffects-modtitle")
    @runtimeProperty("ModSettings.displayName", "UI-MisterCheddaBlackwallSideEffects-intensity-level")
    @runtimeProperty("ModSettings.description", "UI-MisterCheddaBlackwallSideEffects-intensity-level-desc")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.displayValues.Default", "UI-MisterCheddaBlackwallSideEffects-intensity-default")
    @runtimeProperty("ModSettings.displayValues.Low", "UI-MisterCheddaBlackwallSideEffects-intensity-low")
    public let intensityLevel: BlackwallSideEffects_IntensityLevel = BlackwallSideEffects_IntensityLevel.Default;

    @runtimeProperty("ModSettings.mod", "UI-MisterCheddaBlackwallSideEffects-modtitle")
    @runtimeProperty("ModSettings.displayName", "UI-MisterCheddaBlackwallSideEffects-max-duration")
    @runtimeProperty("ModSettings.description", "UI-MisterCheddaBlackwallSideEffects-max-duration-desc")
    @runtimeProperty("ModSettings.dependency", "enabled")
    @runtimeProperty("ModSettings.step", "5.0")
    @runtimeProperty("ModSettings.min", "10.0")
    @runtimeProperty("ModSettings.max", "300.0")
    public let maxVFXDuration: Float = 180.0;

    @if(ModuleExists("ModSettingsModule"))
    private func OnAttach() -> Void {
        ModSettings.RegisterListenerToClass(this);
        ModSettings.RegisterListenerToModifications(this);
    }

    @if(ModuleExists("ModSettingsModule"))
    private func OnDetach() -> Void {
        ModSettings.UnregisterListenerToClass(this);
        ModSettings.UnregisterListenerToModifications(this);
    }
    
    @if(ModuleExists("ModSettingsModule"))
    private func OnModSettingsChange() -> Void {
        // FTLog(s"BlackwallSideEffects: Settings changed - Intensity Level: \(EnumInt(this.intensityLevel))");
    }

    @if(!ModuleExists("ModSettingsModule"))
    private func OnAttach() -> Void {}

    @if(!ModuleExists("ModSettingsModule"))
    private func OnDetach() -> Void {}

}