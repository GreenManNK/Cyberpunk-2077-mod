module NightlyNow.Settings

// -----------------------------------------------------------------------------
// Settings - NightlyNow Core
// -----------------------------------------------------------------------------
// I've got a 9mm, ready to go off any minute so you feel it
@if(ModuleExists("ModSettingsModule"))
public func RegisterNightlyNowSettingsListener(listener: ref<IScriptable>) {
    ModSettings.RegisterListenerToClass(listener);
    ModSettings.RegisterListenerToModifications(listener);
}

@if(ModuleExists("ModSettingsModule"))
public func UnregisterNightlyNowSettingsListener(listener: ref<IScriptable>) {
    ModSettings.UnregisterListenerToClass(listener);
    ModSettings.UnregisterListenerToModifications(listener);
}

public final class SettingsSystem extends ScriptableSystem {
    func OnAttach() {
        RegisterNightlyNowSettingsListener(this);
    }

    func OnDetach() {
        UnregisterNightlyNowSettingsListener(this);
    }

    public static func Get() -> ref<SettingsSystem> {
        return GameInstance
            .GetScriptableSystemsContainer(GetGameInstance())
            .Get(n"NightlyNow.Settings.SettingsSystem") as SettingsSystem;
    }

    // Enable information widget
    @runtimeProperty("ModSettings.mod", "NightlyNow.Settings.Name")
    @runtimeProperty("ModSettings.category", "NN.Settings.InformationWidget")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "NN.Settings.InformationWidget.Enable")
    @runtimeProperty("ModSettings.description", "NN.Settings.InformationWidget.Enable.Description")
    public let enableInformationWidget: Bool = true;

    // Information widget position x
    @runtimeProperty("ModSettings.mod", "NightlyNow.Settings.Name")
    @runtimeProperty("ModSettings.category", "NN.Settings.InformationWidget")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "NN.Settings.InformationWidget.PositionX")
    @runtimeProperty("ModSettings.description", "NN.Settings.InformationWidget.PositionX.Description")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "-2000")
    @runtimeProperty("ModSettings.max", "2000")
    public let informationWidgetX: Float = 0.0;

    // Information widget position y
    @runtimeProperty("ModSettings.mod", "NightlyNow.Settings.Name")
    @runtimeProperty("ModSettings.category", "NN.Settings.InformationWidget")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "NN.Settings.InformationWidget.PositionY")
    @runtimeProperty("ModSettings.description", "NN.Settings.InformationWidget.PositionY.Description")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "-2000")
    @runtimeProperty("ModSettings.max", "500")
    public let informationWidgetY: Float = 0.0;

    // Enable progress bar
    @runtimeProperty("ModSettings.mod", "NightlyNow.Settings.Name")
    @runtimeProperty("ModSettings.category", "NN.Settings.ProgressBar")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "NN.Settings.ProgressBar.Enable")
    @runtimeProperty("ModSettings.description", "NN.Settings.ProgressBar.Enable.Description")
    public let enableProgressBar: Bool = true;

    // Progress bar position y
    @runtimeProperty("ModSettings.mod", "NightlyNow.Settings.Name")
    @runtimeProperty("ModSettings.category", "NN.Settings.ProgressBar")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "NN.Settings.ProgressBar.PositionY")
    @runtimeProperty("ModSettings.description", "NN.Settings.ProgressBar.PositionY.Description")
    @runtimeProperty("ModSettings.step", "5")
    @runtimeProperty("ModSettings.min", "-100")
    @runtimeProperty("ModSettings.max", "2000")
    public let progressBarY: Float = 0.0;
}

