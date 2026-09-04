module QuestGuide

enum QGHotkey {
  F2 = 0,
  F6 = 1,
  F7 = 2,
  F8 = 3,
  F10 = 4,
  F11 = 5,
  Insert = 6
}

enum QGPadMod {
  LB = 0,
  RB = 1
}

enum QGPadBtn {
  None = 0,
  DpadUp = 1,
  DpadDown = 2,
  DpadLeft = 3,
  DpadRight = 4
}

public class QuestGuideSettings extends ScriptableSystem {

  @runtimeProperty("ModSettings.mod", "Mod-QuestGuide-Title")
  @runtimeProperty("ModSettings.displayName", "Mod-QuestGuide-Set-Hotkey")
  @runtimeProperty("ModSettings.description", "Mod-QuestGuide-Set-Hotkey-Desc")
  @runtimeProperty("ModSettings.displayValues", "\"F2\", \"F6\", \"F7\", \"F8\", \"F10\", \"F11\", \"Insert\"")
  public let hotkey: QGHotkey = QGHotkey.F2;

  @runtimeProperty("ModSettings.mod", "Mod-QuestGuide-Title")
  @runtimeProperty("ModSettings.displayName", "Mod-QuestGuide-Set-PadMod")
  @runtimeProperty("ModSettings.description", "Mod-QuestGuide-Set-PadMod-Desc")
  @runtimeProperty("ModSettings.displayValues", "\"LB\", \"RB\"")
  public let padMod: QGPadMod = QGPadMod.LB;

  @runtimeProperty("ModSettings.mod", "Mod-QuestGuide-Title")
  @runtimeProperty("ModSettings.displayName", "Mod-QuestGuide-Set-PadBtn")
  @runtimeProperty("ModSettings.description", "Mod-QuestGuide-Set-PadBtn-Desc")
  @runtimeProperty("ModSettings.displayValues", "\"Off\", \"D-pad Up\", \"D-pad Down\", \"D-pad Left\", \"D-pad Right\"")
  public let padBtn: QGPadBtn = QGPadBtn.DpadDown;

  public static func Get(game: GameInstance) -> ref<QuestGuideSettings> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(n"QuestGuide.QuestGuideSettings") as QuestGuideSettings;
  }

  public static func KeyOf(game: GameInstance) -> EInputKey {
    let self: ref<QuestGuideSettings> = QuestGuideSettings.Get(game);
    return IsDefined(self) ? self.GetKey() : EInputKey.IK_F2;
  }

  public static func LabelOf(game: GameInstance) -> String {
    let self: ref<QuestGuideSettings> = QuestGuideSettings.Get(game);
    return IsDefined(self) ? self.GetKeyLabel() : "F2";
  }

  public static func PadModKeyOf(game: GameInstance) -> EInputKey {
    let self: ref<QuestGuideSettings> = QuestGuideSettings.Get(game);
    if IsDefined(self) && Equals(self.padMod, QGPadMod.RB) {
      return EInputKey.IK_Pad_RightShoulder;
    };
    return EInputKey.IK_Pad_LeftShoulder;
  }

  public static func PadBtnKeyOf(game: GameInstance) -> EInputKey {
    let self: ref<QuestGuideSettings> = QuestGuideSettings.Get(game);
    if !IsDefined(self) {
      return EInputKey.IK_Pad_DigitDown;
    };
    switch self.padBtn {
      case QGPadBtn.DpadUp: return EInputKey.IK_Pad_DigitUp;
      case QGPadBtn.DpadDown: return EInputKey.IK_Pad_DigitDown;
      case QGPadBtn.DpadLeft: return EInputKey.IK_Pad_DigitLeft;
      case QGPadBtn.DpadRight: return EInputKey.IK_Pad_DigitRight;
      default: return EInputKey.IK_None;
    };
  }

  public func GetKey() -> EInputKey {
    switch this.hotkey {
      case QGHotkey.F6: return EInputKey.IK_F6;
      case QGHotkey.F7: return EInputKey.IK_F7;
      case QGHotkey.F8: return EInputKey.IK_F8;
      case QGHotkey.F10: return EInputKey.IK_F10;
      case QGHotkey.F11: return EInputKey.IK_F11;
      case QGHotkey.Insert: return EInputKey.IK_Insert;
      default: return EInputKey.IK_F2;
    };
  }

  public func GetKeyLabel() -> String {
    switch this.hotkey {
      case QGHotkey.F6: return "F6";
      case QGHotkey.F7: return "F7";
      case QGHotkey.F8: return "F8";
      case QGHotkey.F10: return "F10";
      case QGHotkey.F11: return "F11";
      case QGHotkey.Insert: return "INSERT";
      default: return "F2";
    };
  }

  @if(ModuleExists("ModSettingsModule"))
  private func OnAttach() -> Void {
    ModSettings.RegisterListenerToClass(this);
  }

  @if(!ModuleExists("ModSettingsModule"))
  private func OnAttach() -> Void {}

  @if(ModuleExists("ModSettingsModule"))
  private func OnDetach() -> Void {
    ModSettings.UnregisterListenerToClass(this);
  }

  @if(!ModuleExists("ModSettingsModule"))
  private func OnDetach() -> Void {}
}
