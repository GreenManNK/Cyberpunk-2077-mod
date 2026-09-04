@if(ModuleExists("ModSettingsModule"))
public abstract class MCMModSettingsAdapter {
  public static func ResolveName(value: CName) -> String {
    let text: String = GetLocalizedTextByKey(value);
    if StrLen(text) == 0 {
      text = NameToString(value);
    };
    return text;
  }

  public static func ResolveVarName(value: ref<ConfigVar>) -> String {
    if !IsDefined(value) {
      return "";
    };
    return NameToString(value.GetName());
  }

  public static func ResolveVarDisplayName(value: ref<ConfigVar>) -> String {
    let i: Int32;
    let size: Int32;
    let text: String;

    if !IsDefined(value) {
      return "";
    };

    size = value.GetDisplayNameKeysSize();
    if size > 0 {
      text = NameToString(value.GetDisplayName());
      i = 0;
      while i < size {
        text = StrReplace(text, "%", GetLocalizedTextByKey(value.GetDisplayNameKey(i)));
        i += 1;
      };
    } else {
      text = GetLocalizedTextByKey(value.GetDisplayName());
    };

    if StrLen(text) == 0 {
      text = NameToString(value.GetDisplayName());
    };
    return text;
  }

  public static func ResolveVarDescription(value: ref<ConfigVar>) -> String {
    let key: CName;
    let text: String;
    if !IsDefined(value) {
      return "";
    };

    key = value.GetDescription();
    text = GetLocalizedTextByKey(key);
    if StrLen(text) == 0 && NotEquals(key, n"None") {
      text = NameToString(key);
    };
    return text;
  }

  public static func EnsureVarOwner(value: ref<ConfigVar>) -> Bool {
    let className: String;
    let i: Int32;
    let parts: array<String>;
    let system: ref<ScriptableSystem>;

    if !IsDefined(value) {
      return false;
    };

    parts = StrSplit(NameToString(value.GetGroupPath()), "/", false);
    i = ArraySize(parts) - 1;
    while i >= 0 {
      if StrLen(parts[i]) > 0 {
        className = parts[i];
        break;
      };
      i -= 1;
    };
    if StrLen(className) == 0 {
      return false;
    };

    system = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(StringToName(className));
    if !IsDefined(system) {
      return false;
    };

    ModSettings.UnregisterListenerToClass(system);
    ModSettings.RegisterListenerToClass(system);
    return true;
  }
}
