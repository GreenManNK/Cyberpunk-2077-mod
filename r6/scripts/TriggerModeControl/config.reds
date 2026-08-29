module TriggerModeControl.Config

@if(ModuleExists("ModSettingsModule"))
import ModSettingsModule.*

@if(ModuleExists("ModSettingsModule"))
public class TMCKeybinds {
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-Keybind")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-Keybind_desc")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Keybinds")
  @runtimeProperty("ModSettings.category.order", "0")
  public let SwapFiremode: EInputKey = EInputKey.IK_T;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-KeybindPad")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-Keybind_desc")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Keybinds")
  @runtimeProperty("ModSettings.category.order", "0")
  public let SwapFiremode_Pad: EInputKey = EInputKey.IK_Pad_DigitDown;

}

public class TMCSettings extends ScriptableSystem {

  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideTech")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideTech_desc")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Overrides")
  @runtimeProperty("ModSettings.category.order", "1")
  let overrideTech : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideOthers")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideOthers_desc")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Overrides")
  @runtimeProperty("ModSettings.category.order", "1")
  let overrideOthers : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideAuto")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideAuto_desc")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Overrides")
  @runtimeProperty("ModSettings.category.order", "1")
  let overrideAuto : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideHoldCharge")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideHoldCharge_desc")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Overrides")
  @runtimeProperty("ModSettings.category.order", "1")
  let overrideHoldCharge : Bool = false;
  
  @runtimeProperty("ModSettings.mod", "Trigger Control")
  @runtimeProperty("ModSettings.displayName", "Mod-TriggerModeCtrl-OverrideChargeSpeed")
  @runtimeProperty("ModSettings.description", "Mod-TriggerModeCtrl-OverrideChargeSpeed_desc")
  @runtimeProperty("ModSettings.category", "Mod-TriggerModeCtrl-Overrides")
  @runtimeProperty("ModSettings.category.order", "1")
  let overrideChargeSpeed : Bool = false;
  
  public static func GetSettings() -> ref<TMCSettings> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"TriggerModeControl.Config.TMCSettings") as TMCSettings;
  }

  @if(ModuleExists("ModSettingsModule"))
  private func OnAttach() -> Void {
    ModSettings.RegisterListenerToClass(this);
  }

  @if(ModuleExists("ModSettingsModule"))
  private func OnDetach() -> Void {
    ModSettings.UnregisterListenerToClass(this);
  }
  
}