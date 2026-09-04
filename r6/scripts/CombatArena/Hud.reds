// =====================================================================
//  COMBAT ARENA - HUD
//
//  Onscreen messages are the wrong surface for anything that has to sit
//  there: the game reclaims that slot, so holding text meant re-issuing
//  it, which flickers. This attaches a real text widget to the HUD layer
//  instead - set it once, update it whenever, and it simply stays.
//
//  The widget is attached lazily, the moment a line is first shown,
//  through Codeware's ink system access. Attaching in a HUD controller's
//  OnInitialize looked cleaner but never fired after a hot reload, which
//  made every message in the mod silently invisible.
// =====================================================================

public abstract class ArenaHudBuilder {

  // Idempotent: returns immediately when the widget is already live.
  // Called from ArenaSystem.SetHud on every update, so however the mod
  // was loaded - cold boot or hot reload - the first message attaches it.
  public static func Ensure() -> Void {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return; }
    if IsDefined(sys.hudText) { return; }

    let layer = GameInstance.GetInkSystem().GetLayer(n"inkHUDLayer");
    if !IsDefined(layer) { return; }

    let window = layer.GetVirtualWindow();
    if !IsDefined(window) { return; }

    // A previous session's orphan, if any, goes first so the layer never
    // collects duplicates.
    window.RemoveChildByName(n"CombatArenaHud");

    // Sits under the minimap, right-aligned, out of the way of the
    // crosshair and the quest tracker.
    let text = new inkText();
    text.SetName(n"CombatArenaHud");
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(n"Medium");
    text.SetFontSize(36);
    text.SetTintColor(HDRColor(1.1192, 0.8441, 0.2565, 1.0));
    text.SetAnchor(inkEAnchor.TopRight);
    text.SetAnchorPoint(Vector2(1.0, 0.0));
    text.SetMargin(inkMargin(0.0, 600.0, 90.0, 0.0));
    text.SetHAlign(inkEHorizontalAlign.Right);
    text.SetVAlign(inkEVerticalAlign.Top);
    text.SetText("");
    text.SetVisible(false);
    text.Reparent(window);

    sys.hudText = text;
    ModLog(n"CombatArena", "HUD widget attached to inkHUDLayer");
  }
}
