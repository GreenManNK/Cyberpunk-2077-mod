// =====================================================================
//  COMBAT ARENA - SETTINGS
//
//  Key bindings, shown in Mod Settings (Esc > Mods > Combat Arena) as
//  real press-a-key binding widgets, exactly like the base game's own
//  key bindings screen.
//
//  How that works: r6/input/CombatArena.xml declares each button with
//  an overridableUI attribute, and each field below uses that same
//  attribute value as its NAME with type EInputKey. Mod Settings pairs
//  the two up, renders its keybind widget, persists the choice, and
//  pushes the override into the input system.
//
//  The mod reads the keys raw through Codeware's input events (see
//  ArenaKillService.OnKeyInput), so a rebind applies instantly and the
//  menu key keeps working even while the terminal popup is open.
// =====================================================================

public class ArenaSettings extends ScriptableSystem {

  @runtimeProperty("ModSettings.mod", "Combat Arena")
  @runtimeProperty("ModSettings.displayName", "Arena Menu")
  @runtimeProperty("ModSettings.description", "Opens and closes the arena terminal while inside the arena")
  public let ArenaMenuKey: EInputKey = EInputKey.IK_Z;

  @runtimeProperty("ModSettings.mod", "Combat Arena")
  @runtimeProperty("ModSettings.displayName", "Exit the Arena (hold)")
  @runtimeProperty("ModSettings.description", "Hold to leave the arena. A hold, so it cannot be hit by accident mid-fight")
  public let ArenaExitKey: EInputKey = EInputKey.IK_X;

  @runtimeProperty("ModSettings.mod", "Combat Arena")
  @runtimeProperty("ModSettings.displayName", "Quick Summon")
  @runtimeProperty("ModSettings.description", "Summons the best crew member you can afford, no menu needed")
  public let ArenaSummonKey: EInputKey = EInputKey.IK_B;

  public static func Get() -> ref<ArenaSettings> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance())
      .Get(n"ArenaSettings") as ArenaSettings;
  }

  // "IK_Z" -> "Z", "IK_F2" -> "F2". Purely for on-screen hints.
  public static func KeyName(k: EInputKey) -> String {
    let s = ToString(k);
    if StrLen(s) > 3 {
      return StrRight(s, StrLen(s) - 3);
    }
    return s;
  }
}
