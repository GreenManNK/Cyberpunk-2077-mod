// LoveOverride
// Cyberpunk 2077 2.31
// User-facing UI: simple Mod Settings switches
// Author: drixsm

public class LoveOverrideSettings extends ScriptableSystem {
  @runtimeProperty("ModSettings.mod", "LoveOverride")
  @runtimeProperty("ModSettings.category", "Romance Unlocks")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Judy")
  @runtimeProperty("ModSettings.description", "ON unlocks Judy's romance gate immediately. Use before the romance quest decision.")
  public let judy: Bool = false;

  @runtimeProperty("ModSettings.mod", "LoveOverride")
  @runtimeProperty("ModSettings.category", "Romance Unlocks")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Panam")
  @runtimeProperty("ModSettings.description", "ON unlocks Panam's romance gate immediately. Use before the romance quest decision.")
  public let panam: Bool = false;

  @runtimeProperty("ModSettings.mod", "LoveOverride")
  @runtimeProperty("ModSettings.category", "Romance Unlocks")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "River")
  @runtimeProperty("ModSettings.description", "ON unlocks River's romance gate immediately. Use before the romance quest decision.")
  public let river: Bool = false;

  @runtimeProperty("ModSettings.mod", "LoveOverride")
  @runtimeProperty("ModSettings.category", "Romance Unlocks")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Kerry")
  @runtimeProperty("ModSettings.description", "ON unlocks Kerry's romance gate immediately. Use before the romance quest decision.")
  public let kerry: Bool = false;

  public static func Get(gi: GameInstance) -> ref<LoveOverrideSettings> {
    return GameInstance.GetScriptableSystemsContainer(gi).Get(n"LoveOverrideSettings") as LoveOverrideSettings;
  }

  @if(ModuleExists("ModSettingsModule"))
  private func OnAttach() -> Void {
    ModSettings.RegisterListenerToClass(this);
    ModSettings.RegisterListenerToModifications(this);
  }

  @if(!ModuleExists("ModSettingsModule"))
  private func OnAttach() -> Void {}

  @if(ModuleExists("ModSettingsModule"))
  private func OnDetach() -> Void {
    ModSettings.UnregisterListenerToClass(this);
    ModSettings.UnregisterListenerToModifications(this);
  }

  @if(!ModuleExists("ModSettingsModule"))
  private func OnDetach() -> Void {}

  private func ToFactValue(value: Bool) -> Int32 {
    if value {
      return 1;
    }
    return 0;
  }

  private func SetFactString(fact: String, value: Int32) -> Void {
    let quests = GameInstance.GetQuestsSystem(this.GetGameInstance());
    if IsDefined(quests) {
      quests.SetFactStr(fact, value);
    }
  }

  private func ApplyJudy() -> Void {
    this.SetFactString("judy_romanceable", this.ToFactValue(this.judy));
  }

  private func ApplyPanam() -> Void {
    this.SetFactString("panam_romanceable", this.ToFactValue(this.panam));
  }

  private func ApplyRiver() -> Void {
    this.SetFactString("river_romanceable", this.ToFactValue(this.river));
  }

  private func ApplyKerry() -> Void {
    this.SetFactString("kerry_romanceable", this.ToFactValue(this.kerry));
  }

  private func ApplyAll() -> Void {
    this.ApplyJudy();
    this.ApplyPanam();
    this.ApplyRiver();
    this.ApplyKerry();
  }

  @if(ModuleExists("ModSettingsModule"))
  public cb func OnModVariableChangeRequested(groupPath: CName, varName: CName) -> Void {
    // Mod Settings keeps UI changes pending until Apply/Back.
    // LoveOverride writes immediately so users do not have to understand the settings lifecycle.
    if Equals(varName, n"judy") { this.ApplyJudy(); return; }
    if Equals(varName, n"panam") { this.ApplyPanam(); return; }
    if Equals(varName, n"river") { this.ApplyRiver(); return; }
    if Equals(varName, n"kerry") { this.ApplyKerry(); return; }
  }

  @if(ModuleExists("ModSettingsModule"))
  public cb func OnModVariableChangeAccepted(groupPath: CName, varName: CName) -> Void {
    if Equals(varName, n"judy") { this.ApplyJudy(); return; }
    if Equals(varName, n"panam") { this.ApplyPanam(); return; }
    if Equals(varName, n"river") { this.ApplyRiver(); return; }
    if Equals(varName, n"kerry") { this.ApplyKerry(); return; }
  }

  @if(ModuleExists("ModSettingsModule"))
  public cb func OnModSettingsChange() -> Void {
    this.ApplyAll();
  }
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let ret: Bool = wrappedMethod();
  if !this.IsReplacer() {
    LoveOverrideSettings.Get(this.GetGame());
  }
  return ret;
}
