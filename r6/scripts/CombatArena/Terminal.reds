// =====================================================================
//  COMBAT ARENA - THE TERMINAL
//
//  One clean window, built on Codeware's InGamePopup so it behaves like
//  a base-game modal: vignette, background blur, cursor, the radial-menu
//  time dilation, and the game's own show/hide handling.
//
//  Four tabs, a paged list, nothing else. No overlay, no scattered
//  windows.
// =====================================================================

import Codeware.UI.*

// Rebuilding the row list destroys the very button whose click handler is
// still running, which takes the popup down with it. So a click schedules
// the rebuild for the next frame instead of doing it inline.
public class ArenaTerminalRefresh extends DelayCallback {
  protected func Call() -> Void {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return; }
    if !IsDefined(sys.terminal) { return; }
    sys.terminal.Refresh();
  }
}

public class ArenaTerminal extends InGamePopup {

  private let m_tab: Int32;          // 0 RUN | 1 SHOP | 2 GAUNTLET
  private let m_shopTab: Int32;      // 0 WEAPONS | 1 ABILITIES | 2 SUPPORT
  private let m_page: Int32;
  private let m_list: wref<inkVerticalPanel>;
  private let m_tabRow: wref<inkHorizontalPanel>;
  private let m_status: wref<inkText>;
  private let m_shards: wref<inkText>;
  private let m_verdict: wref<inkText>;
  private let m_header: ref<InGamePopupHeader>;
  private let m_detail: wref<inkVerticalPanel>;
  private let m_detailWrap: wref<inkCanvas>;
  private let m_detailFrame: wref<inkRectangle>;
  private let m_detailBg: wref<inkRectangle>;
  // Icon native-size watching (see TRUE ICON RATIOS below).
  private let m_detailIconWidget: wref<inkImage>;
  private let m_probeIconID: TweakDBID;
  private let m_probeAttempts: Int32;
  private let m_ratioIds: array<TweakDBID>;
  private let m_ratioVals: array<Float>;
  private let m_csvInput: ref<HubTextInput>;
  private let m_rowNames: array<CName>;
  private let m_rowKinds: array<Int32>;   // 0 none, 1 weapon, 2 ally, 3 perk, 4 action
  private let m_rowIndex: array<Int32>;
  // Full-screen verdict (YOU WON / YOU LOST) shown when a run ends.
  private let m_verdictMode: Bool;
  // Weapon indices sorted per m_sortMode, rebuilt on each refresh.
  private let m_sortedWeapons: array<Int32>;
  //  0 COST | 1 DPS | 2 TYPE | 3 RANGE
  private let m_sortMode: Int32;
  // Preview-instance stats, computed once and reused for sorting.
  private let m_dpsCache: array<Float>;
  private let m_rangeCache: array<Float>;
  // The weapon whose detail panel is open; -1 = none.
  private let m_selectedWeapon: Int32;
  // The crew member whose detail panel is open; -1 = none.
  private let m_selectedAlly: Int32;
  // The ability whose detail panel is open; -1 = none.
  private let m_selectedPerk: Int32;

  public static func ROWS_PER_PAGE() -> Int32 { return 8; }

  // =================================================================
  //  OPEN / CLOSE
  // =================================================================

  public static func Toggle() -> Void {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return; }
    if sys.state == 0 { return; }

    if IsDefined(sys.terminal) {
      sys.terminal.Close();
      sys.terminal = null;
      return;
    };

    let popup = new ArenaTerminal();
    sys.terminal = popup;
    CustomPopupManager.GetInstance().ShowPopup(popup);
  }

  public static func Open() -> Void {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return; }
    if IsDefined(sys.terminal) { return; }

    let popup = new ArenaTerminal();
    sys.terminal = popup;
    CustomPopupManager.GetInstance().ShowPopup(popup);
  }

  protected cb func OnHidden() {
    super.OnHidden();
    let sys = ArenaSystem.Get();
    if IsDefined(sys) { sys.terminal = null; };
    ArenaSpawner.ClearMenuState();
    ModLog(n"CombatArena", "terminal closed");
  }

  public func GetName() -> CName {
    return n"CombatArena.Terminal";
  }

  public func UseCursor() -> Bool {
    return true;
  }

  // =================================================================
  //  LAYOUT
  // =================================================================

  protected cb func OnCreate() {
    super.OnCreate();

    this.m_header = InGamePopupHeader.Create();
    this.m_header.SetTitle("COMBAT ARENA");
    this.m_header.SetFluffLeft("BRAINDANCE");
    this.m_header.SetFluffRight(ArenaData.ArenaName());
    this.m_header.Reparent(this);

    let content = InGamePopupContent.Create();
    content.Reparent(this);

    let column = new inkVerticalPanel();
    column.SetName(n"column");
    column.SetAnchor(inkEAnchor.Fill);
    column.SetChildMargin(inkMargin(0.0, 0.0, 0.0, 10.0));
    column.Reparent(content.GetRootCompoundWidget());

    // ---- shards line
    let shards = new inkText();
    shards.SetName(n"shards");
    shards.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    shards.SetFontStyle(n"Medium");
    shards.SetFontSize(42);
    shards.SetTintColor(ThemeColors.Dandelion());
    shards.SetText("$0");
    shards.Reparent(column);
    this.m_shards = shards;

    // ---- the verdict, hidden until a run ends
    let verdict = new inkText();
    verdict.SetName(n"verdict");
    verdict.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    verdict.SetFontStyle(n"Semi-Bold");
    verdict.SetFontSize(110);
    verdict.SetTintColor(HDRColor(1.6, 0.25, 0.2, 1.0));
    verdict.SetText("");
    verdict.SetVisible(false);
    verdict.Reparent(column);
    this.m_verdict = verdict;

    // ---- status line
    let status = new inkText();
    status.SetName(n"status");
    status.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    status.SetFontStyle(n"Medium");
    status.SetFontSize(28);
    status.SetTintColor(ThemeColors.ElectricBlue());
    status.SetText("");
    status.Reparent(column);
    this.m_status = status;

    // ---- tab row
    let tabRow = new inkHorizontalPanel();
    tabRow.SetName(n"tabs");
    tabRow.SetChildMargin(inkMargin(0.0, 16.0, 12.0, 16.0));
    tabRow.Reparent(column);
    this.m_tabRow = tabRow;

    this.BuildTab(n"tab0", "RUN");
    this.BuildTab(n"tab1", "SHOP");
    this.BuildTab(n"tab2", "CHEATS");

    // ---- body: the row list, with the weapon detail panel beside it
    let body = new inkHorizontalPanel();
    body.SetName(n"body");
    body.SetChildMargin(inkMargin(0.0, 0.0, 30.0, 0.0));
    body.Reparent(column);

    let list = new inkVerticalPanel();
    list.SetName(n"list");
    list.SetChildMargin(inkMargin(0.0, 0.0, 0.0, 6.0));
    list.Reparent(body);
    this.m_list = list;

    // The detail card: a FIXED-SIZE canvas. Auto-sizing containers kept
    // collapsing around dynamically measured text, taking the frame and
    // background down with them - a constant-size card sidesteps the
    // whole problem, tooltip-style.
    let detailWrap = new inkCanvas();
    detailWrap.SetName(n"detailWrap");
    detailWrap.SetSize(new Vector2(560.0, 900.0));
    detailWrap.SetVisible(false);
    detailWrap.Reparent(body);
    this.m_detailWrap = detailWrap;

    // The backing plates get EXPLICIT pixel sizes, not Fill anchors: ink
    // sometimes lays the canvas out smaller than declared, Fill-anchored
    // children shrink with it, and the content - which ink never clips -
    // spills out past the background. Fixed sizes cannot shrink.
    let dframe = new inkRectangle();
    dframe.SetName(n"detailFrame");
    dframe.SetSize(new Vector2(560.0, 900.0));
    dframe.SetTintColor(HDRColor(0.85, 0.16, 0.16, 0.9));
    dframe.Reparent(detailWrap);
    this.m_detailFrame = dframe;

    let dbg = new inkRectangle();
    dbg.SetName(n"detailBg");
    dbg.SetSize(new Vector2(556.0, 896.0));
    dbg.SetMargin(inkMargin(2.0, 2.0, 0.0, 0.0));
    dbg.SetTintColor(HDRColor(0.035, 0.045, 0.06, 0.97));
    dbg.Reparent(detailWrap);
    this.m_detailBg = dbg;

    let detail = new inkVerticalPanel();
    detail.SetName(n"detail");
    detail.SetAnchor(inkEAnchor.TopLeft);
    detail.SetChildMargin(inkMargin(0.0, 0.0, 0.0, 6.0));
    detail.SetMargin(inkMargin(22.0, 22.0, 22.0, 22.0));
    detail.Reparent(detailWrap);
    this.m_detail = detail;

    // No footer: nothing between you and the rows. The menu key or Esc
    // closes, and the game's own cancel key still works silently.

    this.m_tab = 0;
    this.m_page = 0;
    this.m_selectedWeapon = -1;
    this.m_selectedAlly = -1;
    this.m_selectedPerk = -1;
  }

  protected cb func OnInitialize() {
    super.OnInitialize();
    // A finished run opens on the verdict, not the shop.
    let sys = ArenaSystem.Get();
    if IsDefined(sys) && sys.state == 3 && sys.result != 0 {
      this.m_verdictMode = true;
    };
    this.Refresh();
  }

  private func BuildTab(name: CName, label: String) {
    let btn = SimpleButton.Create();
    btn.SetName(name);
    btn.SetText(label);
    btn.SetWidth(380.0);
    btn.Reparent(this.m_tabRow);
    btn.RegisterToCallback(n"OnBtnClick", this, n"OnTabClick");
  }

  // =================================================================
  //  CONTENT
  // =================================================================

  private func AddRow(label: String, kind: Int32, index: Int32, disabled: Bool) {
    let rowName = StringToName("row" + ToString(ArraySize(this.m_rowNames)));

    let btn = SimpleButton.Create();
    btn.SetName(rowName);
    btn.SetText(label);
    btn.SetWidth(1300.0);
    btn.SetDisabled(disabled);
    btn.Reparent(this.m_list);
    btn.RegisterToCallback(n"OnBtnClick", this, n"OnRowClick");

    ArrayPush(this.m_rowNames, rowName);
    ArrayPush(this.m_rowKinds, kind);
    ArrayPush(this.m_rowIndex, index);
  }

  private func ClearRows() {
    ArrayClear(this.m_rowNames);
    ArrayClear(this.m_rowKinds);
    ArrayClear(this.m_rowIndex);
    this.m_csvInput = null;
    if IsDefined(this.m_list) {
      this.m_list.RemoveAllChildren();
    };
    if IsDefined(this.m_detail) {
      this.m_detail.RemoveAllChildren();
    };
    if IsDefined(this.m_detailWrap) {
      this.m_detailWrap.SetVisible(false);
    };
    this.m_detailIconWidget = null;
  }

  // Narrower rows for the weapon list, leaving room for the detail
  // panel beside it.
  private func AddNarrowRow(label: String, kind: Int32, index: Int32, disabled: Bool) {
    let rowName = StringToName("row" + ToString(ArraySize(this.m_rowNames)));

    let btn = SimpleButton.Create();
    btn.SetName(rowName);
    btn.SetText(label);
    btn.SetWidth(880.0);
    btn.SetDisabled(disabled);
    btn.Reparent(this.m_list);
    btn.RegisterToCallback(n"OnBtnClick", this, n"OnRowClick");

    ArrayPush(this.m_rowNames, rowName);
    ArrayPush(this.m_rowKinds, kind);
    ArrayPush(this.m_rowIndex, index);
  }

  private func Money(value: Int32) -> String {
    return "$" + ToString(value);
  }

  // A stat line: bold label on the left, value beside it. Every text
  // must be fit-to-content: without it inkText reports zero size inside
  // panels, children stack at x=0 and the whole card collapses - which
  // is exactly the mangled screen this replaces.
  // Scanner-style stat row: small red uppercase label on the left,
  // bright value flush right. Built on a fixed-size canvas with absolute
  // anchors - the one layout ink executes deterministically. (Flowing
  // two-widget rows in panels is what produced the overlapping garbage.)
  private func AddStatRow(label: String, value: String) {
    let row = new inkCanvas();
    row.SetSize(new Vector2(510.0, 36.0));
    row.Reparent(this.m_detail);

    let l = new inkText();
    l.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    l.SetFontStyle(n"Medium");
    l.SetFontSize(24);
    l.SetFitToContent(true);
    l.SetLetterCase(textLetterCase.UpperCase);
    l.SetTintColor(HDRColor(0.96, 0.28, 0.28, 1.0));
    l.SetAnchor(inkEAnchor.TopLeft);
    l.SetMargin(inkMargin(0.0, 5.0, 0.0, 0.0));
    l.SetText(label);
    l.Reparent(row);

    let v = new inkText();
    v.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    v.SetFontStyle(n"Semi-Bold");
    v.SetFontSize(30);
    v.SetFitToContent(true);
    v.SetTintColor(HDRColor(0.62, 0.92, 0.99, 1.0));
    v.SetAnchor(inkEAnchor.TopRight);
    v.SetAnchorPoint(new Vector2(1.0, 0.0));
    v.SetText(value);
    v.Reparent(row);
  }

  // Hand-tuned aspect per weapon class. The generated renders cannot be
  // measured from script, so these are eyeballed constants - if a class
  // looks off, the numbers are right here.
  // ------------------------------------------------------------------
  //  TRUE ICON RATIOS, MEASURED AT RUNTIME
  //
  //  The render textures cannot be measured offline, so the card does
  //  it live: an invisible probe image loads the same icon with
  //  fit-to-content on, the engine sizes it to the real texture, and
  //  GetDesiredSize() hands over the true dimensions. The visible
  //  render is then resized to the exact measured ratio, and the
  //  result is cached per icon so each one is measured once ever.
  // ------------------------------------------------------------------

  // Cached NATIVE WIDTH per icon (0 = not yet known).
  private func CachedRatio(iconID: TweakDBID) -> Float {
    let i = 0;
    while i < ArraySize(this.m_ratioIds) {
      if this.m_ratioIds[i] == iconID { return this.m_ratioVals[i]; };
      i += 1;
    };
    return 0.0;
  }

  // Watches the visible fit-to-content image until the texture reports
  // its native size, then scales it down uniformly if it is wider than
  // the card. Uniform scale = ratio untouched.
  public func TickIconProbe() -> Void {
    if !IsDefined(this.m_detailIconWidget) { return; }

    let s = this.m_detailIconWidget.GetDesiredSize();
    if s.X > 1.0 && s.Y > 1.0 {
      ArrayPush(this.m_ratioIds, this.m_probeIconID);
      ArrayPush(this.m_ratioVals, s.X);
      ModLog(n"CombatArena", "icon native size: " + FloatToStringPrec(s.X, 0)
        + "x" + FloatToStringPrec(s.Y, 0));
      if s.X > 500.0 {
        let k = 500.0 / s.X;
        this.m_detailIconWidget.SetScale(new Vector2(k, k));
      };
      return;
    };

    this.m_probeAttempts += 1;
    if this.m_probeAttempts >= 20 {
      ModLog(n"CombatArena", "icon size never reported (widget stayed unmeasured)");
      return;
    };
    let tick = new ArenaIconProbeTick();
    tick.terminal = this;
    GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(tick, 0.15, false);
  }

  // Opens the card: visible, and given a fixed working width by an
  // invisible spacer so the frame never hugs the text.
  //
  // THE crash of builds 22-24 lived here: a careless mass-edit made this
  // function call itself, and every weapon click overflowed the stack.
  // It is plain straight-line code now and must stay that way.
  private func ShowDetailCard() {
    this.m_detailWrap.SetVisible(true);
  }

  // "FastMeleeT2" -> "FAST MELEE T2": a space before each capital, then
  // everything upper-cased. Enum names are for compilers, not players.
  private func PrettyEnum(s: String) -> String {
    let out = "";
    let i = 0;
    while i < StrLen(s) {
      let c = StrMid(s, i, 1);
      if i > 0 && NotEquals(c, StrLower(c)) { out += " "; };
      out += c;
      i += 1;
    };
    return StrUpper(out);
  }

  public func Refresh() -> Void {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return; }

    this.m_shards.SetText(this.Money(sys.shards));
    this.ClearRows();

    // ---- the verdict screen: one big line, two choices --------------
    if this.m_verdictMode && sys.state == 3 {
      let won = sys.result == 1;
      this.m_verdict.SetText(won ? "YOU WON" : "YOU LOST");
      this.m_verdict.SetTintColor(won
        ? HDRColor(0.37, 1.42, 0.62, 1.0)
        : HDRColor(1.60, 0.25, 0.20, 1.0));
      this.m_verdict.SetVisible(true);
      this.m_tabRow.SetVisible(false);
      this.m_status.SetText(ToString(sys.kills) + " KILLS     PEAK COMBO x"
        + ToString(sys.peakCombo) + "     " + this.Money(sys.earned) + " EARNED");
      this.AddRow("RETURN TO ARENA MENU", 4, 8, false);
      this.AddRow("EXIT THE ARENA", 4, 2, false);
      return;
    };
    this.m_verdict.SetVisible(false);
    this.m_tabRow.SetVisible(true);

    if sys.state == 2 {
      this.m_status.SetText("WAVE " + ToString(sys.wave) + "/" + ToString(sys.totalWaves)
        + "     " + ToString(sys.enemiesAlive) + " HOSTILES"
        + "     " + ToString(Cast<Int32>(sys.timeLeft)) + "s LEFT"
        + "     " + ToString(sys.kills) + " KILLS");
    } else {
      if sys.state == 3 {
        let verdict = "TIME'S UP";
        if sys.result == 1 { verdict = "YOU WON"; };
        if sys.result == 3 { verdict = "YOU LOST"; };
        this.m_status.SetText(verdict + "     " + ToString(sys.kills) + " KILLS     PEAK COMBO x"
          + ToString(sys.peakCombo));
      } else {
        this.m_status.SetText(ArenaData.ArenaSubtitle());
      };
    };

    if this.m_tab == 0 { this.BuildRunTab(sys); }
    else {
      if this.m_tab == 1 { this.BuildShopTab(sys); }
      else { this.BuildCheatsTab(sys); };
    };
  }

  // One SHOP tab, three counters inside it.
  private func BuildShopTab(sys: ref<ArenaSystem>) {
    // The card spans exactly from the top of the first item row to the
    // bottom of the last. SimpleButton is 100 tall, the list gap is 6,
    // so the geometry is arithmetic, not guesswork: sub-tab row = 114
    // (its own bottom margin) + 6 gap; the weapons page adds one more
    // 106 pitch for the sort row.
    // Weapons page has a sort row above the items; support page has the
    // quota ledger. Both shift the first item down one pitch.
    let top = 120.0;
    if this.m_shopTab == 0 || this.m_shopTab == 2 { top += 106.0; };
    let rows = 8;
    if this.m_shopTab == 1 { rows = ArraySize(sys.GetPerks()); };
    let h = Cast<Float>(rows) * 106.0 - 6.0;
    this.m_detailWrap.SetMargin(inkMargin(0.0, top, 0.0, 0.0));
    this.m_detailWrap.SetSize(new Vector2(560.0, h));
    this.m_detailFrame.SetSize(new Vector2(560.0, h));
    this.m_detailBg.SetSize(new Vector2(556.0, h - 4.0));

    let subRow = new inkHorizontalPanel();
    subRow.SetName(n"subtabs");
    subRow.SetChildMargin(inkMargin(0.0, 0.0, 12.0, 14.0));
    subRow.Reparent(this.m_list);

    this.BuildSubTab(subRow, n"subtab0", "WEAPONS");
    this.BuildSubTab(subRow, n"subtab1", "ABILITIES");
    this.BuildSubTab(subRow, n"subtab2", "SUPPORT");

    if this.m_shopTab == 0 { this.BuildListTab(sys, 1); }
    else {
      if this.m_shopTab == 1 { this.BuildAbilitiesTab(sys); }
      else { this.BuildCrewTab(sys); };
    };
  }

  private func BuildSubTab(row: ref<inkHorizontalPanel>, name: CName, label: String) {
    let btn = SimpleButton.Create();
    btn.SetName(name);
    btn.SetText(label);
    btn.SetWidth(285.0);
    btn.Reparent(row);
    btn.RegisterToCallback(n"OnBtnClick", this, n"OnSubTabClick");
  }

  protected cb func OnSubTabClick(widget: wref<inkWidget>) -> Bool {
    let name = widget.GetName();
    if Equals(name, n"subtab0") { this.m_shopTab = 0; };
    if Equals(name, n"subtab1") { this.m_shopTab = 1; };
    if Equals(name, n"subtab2") { this.m_shopTab = 2; };
    this.m_page = 0;
    this.m_selectedWeapon = -1;
    this.m_selectedAlly = -1;
    this.m_selectedPerk = -1;
    this.RefreshSoon();
    return true;
  }

  // Back / forward arrows with the page count between them.
  private func AddPagerRow(pages: Int32) {
    let row = new inkHorizontalPanel();
    row.SetName(n"pager");
    row.SetChildMargin(inkMargin(0.0, 6.0, 14.0, 0.0));
    row.Reparent(this.m_list);

    let prev = SimpleButton.Create();
    prev.SetName(n"pagerPrev");
    prev.SetText("<");
    prev.SetWidth(140.0);
    prev.Reparent(row);
    prev.RegisterToCallback(n"OnBtnClick", this, n"OnPagerPrev");

    let label = new inkText();
    label.SetName(n"pagerLabel");
    label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    label.SetFontStyle(n"Medium");
    label.SetFontSize(34);
    label.SetTintColor(ThemeColors.ElectricBlue());
    label.SetVAlign(inkEVerticalAlign.Center);
    label.SetMargin(inkMargin(20.0, 12.0, 20.0, 0.0));
    label.SetText(ToString(this.m_page + 1) + " / " + ToString(pages));
    label.Reparent(row);

    let next = SimpleButton.Create();
    next.SetName(n"pagerNext");
    next.SetText(">");
    next.SetWidth(140.0);
    next.Reparent(row);
    next.RegisterToCallback(n"OnBtnClick", this, n"OnPagerNext");
  }

  private func PageCount(total: Int32) -> Int32 {
    let perPage = ArenaTerminal.ROWS_PER_PAGE();
    return (total + perPage - 1) / perPage;
  }

  protected cb func OnPagerPrev(widget: wref<inkWidget>) -> Bool {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return true; }
    let total = this.m_shopTab == 0 ? ArraySize(sys.GetWeapons()) : ArraySize(sys.GetAllies());
    let pages = this.PageCount(total);
    this.m_page -= 1;
    if this.m_page < 0 { this.m_page = pages - 1; };
    this.RefreshSoon();
    return true;
  }

  protected cb func OnPagerNext(widget: wref<inkWidget>) -> Bool {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return true; }
    let total = this.m_shopTab == 0 ? ArraySize(sys.GetWeapons()) : ArraySize(sys.GetAllies());
    let pages = this.PageCount(total);
    this.m_page += 1;
    if this.m_page >= pages { this.m_page = 0; };
    this.RefreshSoon();
    return true;
  }

  private func BuildRunTab(sys: ref<ArenaSystem>) {
    if sys.state == 1 {
      this.AddRow("START RUN", 4, 1, false);
    };
    if sys.state == 3 {
      this.AddRow("RUN IT BACK", 4, 1, false);
    };
    if sys.state == 2 {
      this.AddRow("BACK TO THE FIGHT", 4, 3, false);
    };
    this.AddRow("EXIT THE ARENA", 4, 2, false);
    if sys.gauntletEnabled {
      this.AddRow("DIFFICULTY: (GAUNTLET RUNS ITS OWN RULES)", 4, 7, true);
    } else {
      this.AddRow("DIFFICULTY: " + sys.DiffName(), 4, 7, false);
    };

    // Gauntlet lives right under difficulty now: same custom-run
    // options, no separate tab.
    this.AddRow(sys.gauntletEnabled ? "GAUNTLET MODE: ON" : "GAUNTLET MODE: OFF", 4, 10, false);
    if sys.gauntletEnabled {
      this.AddRow("WAVES: " + ToString(sys.gauntletWaves), 4, 11, false);

      let input = HubTextInput.Create();
      input.SetName(n"csv");
      input.SetText(sys.gauntletCsv);
      input.Reparent(this.m_list);
      this.m_csvInput = input;

      this.AddRow("APPLY HORDE LIST  (enemies per wave, CSV)", 4, 12, false);
      this.AddRow("BOSSES: " + ToString(sys.gauntletBosses) + "   (Smasher always last)", 4, 13, false);
      this.AddRow("STARTING CREW: " + ToString(sys.gauntletAllies), 4, 14, false);
      this.AddRow("TIME LIMIT: " + ToString(sys.gauntletTime) + "s", 4, 15, false);
    };
  }

  // Cheats and modifiers, in one place.
  private func BuildCheatsTab(sys: ref<ArenaSystem>) {
    let god = sys.godMode && sys.richMode;
    this.AddRow(god ? "GOD MODE: ON   (health + money)" : "GOD MODE: OFF   (health + money)", 4, 5, false);
    this.AddRow(sys.godMode ? "INVULNERABLE: ON" : "INVULNERABLE: OFF", 4, 17, false);
    this.AddRow(sys.richMode ? "FILTHY RICH: ON" : "FILTHY RICH: OFF", 4, 18, false);
    this.AddRow("ENEMY HEALTH: x" + FloatToStringPrec(sys.enemyHealthMult, 2), 4, 16, false);
    this.AddRow("PREP TIME BEFORE EACH WAVE: " + ToString(sys.prepSeconds) + "s", 4, 6, false);
  }

  private func SortModeName() -> String {
    if this.m_sortMode == 1 { return "DPS"; };
    if this.m_sortMode == 2 { return "TYPE"; };
    if this.m_sortMode == 3 { return "RANGE"; };
    return "COST";
  }

  // DPS and range come from preview item instances; computed once for
  // the whole arsenal and cached for the sorter.
  private func EnsureStatCache(sys: ref<ArenaSystem>) {
    let weapons = sys.GetWeapons();
    if ArraySize(this.m_dpsCache) == ArraySize(weapons) { return; }
    ArrayClear(this.m_dpsCache);
    ArrayClear(this.m_rangeCache);

    let gi = GetGameInstance();
    let invMgr = GameInstance.GetInventoryManager(gi);
    let player = GetPlayer(gi);
    let i = 0;
    while i < ArraySize(weapons) {
      let data = invMgr.CreateBasicItemData(ItemID.FromTDBID(weapons[i].id), player);
      if IsDefined(data) {
        ArrayPush(this.m_dpsCache, data.GetStatValueByType(gamedataStatType.EffectiveDPS));
        ArrayPush(this.m_rangeCache, data.GetStatValueByType(gamedataStatType.EffectiveRange));
      } else {
        ArrayPush(this.m_dpsCache, 0.0);
        ArrayPush(this.m_rangeCache, 0.0);
      };
      i += 1;
    };
  }

  // True when a should come before b under the current sort mode.
  private func SortBefore(sys: ref<ArenaSystem>, a: Int32, b: Int32) -> Bool {
    let weapons = sys.GetWeapons();
    if this.m_sortMode == 1 { return this.m_dpsCache[a] > this.m_dpsCache[b]; };
    if this.m_sortMode == 3 { return this.m_rangeCache[a] > this.m_rangeCache[b]; };
    if this.m_sortMode == 2 {
      if weapons[a].cat != weapons[b].cat { return weapons[a].cat < weapons[b].cat; };
      return weapons[a].price < weapons[b].price;
    };
    return weapons[a].price < weapons[b].price;
  }

  private func SortWeapons(sys: ref<ArenaSystem>) {
    if this.m_sortMode == 1 || this.m_sortMode == 3 { this.EnsureStatCache(sys); };
    ArrayClear(this.m_sortedWeapons);
    let weapons = sys.GetWeapons();
    let i = 0;
    while i < ArraySize(weapons) {
      ArrayPush(this.m_sortedWeapons, i);
      i += 1;
    };
    let a = 1;
    while a < ArraySize(this.m_sortedWeapons) {
      let key = this.m_sortedWeapons[a];
      let b = a - 1;
      while b >= 0 && this.SortBefore(sys, key, this.m_sortedWeapons[b]) {
        this.m_sortedWeapons[b + 1] = this.m_sortedWeapons[b];
        b -= 1;
      };
      this.m_sortedWeapons[b + 1] = key;
      a += 1;
    };
  }

  // kind 1 = weapons. Paged, because there are a lot of them.
  private func BuildListTab(sys: ref<ArenaSystem>, kind: Int32) {
    this.AddNarrowRow("SORT BY: " + this.SortModeName(), 4, 19, false);
    this.SortWeapons(sys);
    let weapons = sys.GetWeapons();
    let total = ArraySize(this.m_sortedWeapons);
    let perPage = ArenaTerminal.ROWS_PER_PAGE();
    let pages = (total + perPage - 1) / perPage;
    if this.m_page >= pages { this.m_page = 0; };

    let start = this.m_page * perPage;
    let i = start;
    while i < total && i < start + perPage {
      let wIdx = this.m_sortedWeapons[i];
      let w = weapons[wIdx];
      // Clicking opens the detail panel; affording is the panel's business.
      this.AddNarrowRow(w.name + "          " + this.Money(w.price), 1, wIdx, false);
      i += 1;
    };

    if pages > 1 { this.AddPagerRow(pages); };

    this.BuildWeaponDetail(sys);
  }

  private func AddDetailText(text: String, size: Int32, color: HDRColor, style: CName) {
    let t = new inkText();
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontStyle(style);
    t.SetFontSize(size);
    t.SetTintColor(color);
    t.SetText(text);
    t.Reparent(this.m_detail);
  }

  // Finds the icon record for an item, refusing any guess that does not
  // resolve to a REAL UIIcon record - a made-up id fails silently and
  // leaves a blank hole, which is what happened to the grenades.
  private func ResolveItemIcon(id: TweakDBID, rec: ref<Item_Record>) -> TweakDBID {
    let resolverID: TweakDBID;
    let pathID: TweakDBID;

    let resolved = IconsNameResolver.GetIconsNameResolver().TranslateItemToIconName(id, true);
    if NotEquals(resolved, n"") && NotEquals(resolved, n"None") {
      resolverID = TDBID.Create("UIIcon." + NameToString(resolved));
    };
    if IsDefined(rec) {
      let iconPath = rec.IconPath();
      if StrLen(iconPath) > 0 { pathID = TDBID.Create("UIIcon." + iconPath); };
    };

    // Prefer whichever candidate provably exists; if the existence check
    // can vouch for neither, still show SOMETHING - the explicit icon
    // path first (grenades), then the resolver's guess (weapons).
    if TDBID.IsValid(resolverID) && IsDefined(TweakDBInterface.GetUIIconRecord(resolverID)) {
      return resolverID;
    };
    if TDBID.IsValid(pathID) && IsDefined(TweakDBInterface.GetUIIconRecord(pathID)) {
      return pathID;
    };
    if TDBID.IsValid(pathID) { return pathID; };
    if TDBID.IsValid(resolverID) { return resolverID; };
    if IsDefined(rec) {
      let uiIcon = rec.Icon();
      if IsDefined(uiIcon) { return uiIcon.GetID(); };
    };
    return TDBID.None();
  }

  // The side panel: the weapon's own render, its live stats, and the
  // button that actually buys it. Built beside the list, inventory-style.
  private func BuildWeaponDetail(sys: ref<ArenaSystem>) {
    if this.m_selectedWeapon < 0 { return; }
    let weapons = sys.GetWeapons();
    if this.m_selectedWeapon >= ArraySize(weapons) { return; }
    let w = weapons[this.m_selectedWeapon];
    this.ShowDetailCard();

    this.AddDetailText(StrUpper(w.name), 48, ThemeColors.Dandelion(), n"Semi-Bold");

    let rec = TweakDBInterface.GetItemRecord(w.id);

    // The render, async through the game's icon pipeline. True native
    // pixel sizes are not readable from script, and letting the widget
    // size itself from a generated render is the crash path - so the
    // cell takes the icon's actual shape class instead: weapon renders
    // are generated 2:1, throwable icons are square. Fixed width, the
    // right aspect, fully deterministic.
    // Fixed width, game-chosen height: fit-to-content makes the widget
    // take the texture's NATIVE size - the ratio is correct by
    // construction, no measuring, no guessing. The watcher below only
    // scales oversized renders DOWN uniformly to the card width, which
    // preserves the ratio exactly.
    let iconID = this.ResolveItemIcon(w.id, rec);
    if TDBID.IsValid(iconID) {
      let img = new inkImage();
      img.SetName(n"detailIcon");
      img.SetFitToContent(true);
      img.SetRenderTransformPivot(Vector2(0.0, 0.0));
      img.Reparent(this.m_detail);
      this.m_detailIconWidget = img;

      let iconRef = new UIIconReference();
      iconRef.iconID = iconID;
      img.RequestSetImage(iconRef);

      // Known size? Scale immediately. Otherwise watch until the
      // texture reports, then scale and remember.
      let cachedW = this.CachedRatio(iconID);
      if cachedW > 1.0 {
        if cachedW > 500.0 {
          let k = 500.0 / cachedW;
          img.SetScale(new Vector2(k, k));
        };
      } else {
        this.m_probeIconID = iconID;
        this.m_probeAttempts = 0;
        let tick = new ArenaIconProbeTick();
        tick.terminal = this;
        GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(tick, 0.15, false);
      };
    };

    let cats = ArenaData.CategoryNames();
    this.AddStatRow("TYPE  ", cats[w.cat]);
    if IsDefined(rec) {
      let q = rec.Quality();
      if IsDefined(q) { this.AddStatRow("QUALITY  ", StrUpper(ToString(q.Type()))); };
      let wrec = rec as WeaponItem_Record;
      if IsDefined(wrec) {
        let evo = wrec.Evolution();
        if IsDefined(evo) { this.AddStatRow("CLASS  ", StrUpper(ToString(evo.Type()))); };
      };
    };

    // Real numbers, from real item data - the same stats the inventory
    // computes, via a preview instance that is never added to anyone.
    let gi = GetGameInstance();
    let itemData = GameInstance.GetInventoryManager(gi)
      .CreateBasicItemData(ItemID.FromTDBID(w.id), GetPlayer(gi));
    if IsDefined(itemData) {
      let dps = itemData.GetStatValueByType(gamedataStatType.EffectiveDPS);
      if dps > 0.0 { this.AddStatRow("DPS  ", FloatToStringPrec(dps, 1)); };
      let dmg = itemData.GetStatValueByType(gamedataStatType.BaseDamage);
      if dmg > 0.0 { this.AddStatRow("DAMAGE  ", FloatToStringPrec(dmg, 1)); };
      let aps = itemData.GetStatValueByType(gamedataStatType.AttacksPerSecond);
      if aps > 0.0 { this.AddStatRow("ATTACK SPEED  ", FloatToStringPrec(aps, 2)); };
      let mag = itemData.GetStatValueByType(gamedataStatType.MagazineCapacity);
      if mag > 0.0 { this.AddStatRow("MAGAZINE  ", ToString(Cast<Int32>(mag))); };
      let rng = itemData.GetStatValueByType(gamedataStatType.EffectiveRange);
      if rng > 0.0 { this.AddStatRow("RANGE  ", FloatToStringPrec(rng, 0) + "m"); };
    };

    this.AddStatRow("COST  ", this.Money(w.price));

    let pick = SimpleButton.Create();
    pick.SetName(n"pickBtn");
    pick.SetText("PICK WEAPON");
    pick.SetWidth(460.0);
    pick.SetDisabled(!sys.CanAfford(w.price));
    pick.Reparent(this.m_detail);
    pick.RegisterToCallback(n"OnBtnClick", this, n"OnPickClick");
  }

  protected cb func OnPickClick(widget: wref<inkWidget>) -> Bool {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return true; }
    if this.m_selectedWeapon >= 0 {
      sys.BuyWeapon(this.m_selectedWeapon);
    };
    this.RefreshSoon();
    return true;
  }

  private func BuildCrewTab(sys: ref<ArenaSystem>) {
    let allies = sys.GetAllies();
    let total = ArraySize(allies);
    let perPage = ArenaTerminal.ROWS_PER_PAGE();
    let pages = (total + perPage - 1) / perPage;
    if this.m_page >= pages { this.m_page = 0; };

    let start = this.m_page * perPage;
    // The quota ledger, always visible above the roster.
    this.AddNarrowRow("ELITES " + ToString(sys.HiredEliteCount()) + "/2 PER RUN"
      + "          ACTIVE CREW " + ToString(sys.AliveRegularAllies()) + "/3", 4, 9, true);

    let i = start;
    while i < total && i < start + perPage {
      let a = allies[i];
      let tag = sys.IsEliteAlly(i) ? "  [ELITE]" : "";
      if sys.IsHired(i) {
        this.AddNarrowRow(a.name + tag + "          ON THE CREW", 2, i, true);
      } else {
        this.AddNarrowRow(a.name + tag + "          " + this.Money(a.price), 2, i, false);
      };
      i += 1;
    };

    if pages > 1 { this.AddPagerRow(pages); };

    this.BuildCrewDetail(sys);
  }

  // Abilities: one-shot boosters, each with a full description in the
  // side panel and a BUY button.
  private func BuildAbilitiesTab(sys: ref<ArenaSystem>) {
    let perks = sys.GetPerks();
    let i = 0;
    while i < ArraySize(perks) {
      let p = perks[i];
      this.AddNarrowRow(p.name + "          " + this.Money(p.price), 3, i, false);
      i += 1;
    };
    this.BuildAbilityDetail(sys);
  }

  private func BuildAbilityDetail(sys: ref<ArenaSystem>) {
    if this.m_selectedPerk < 0 { return; }
    let perks = sys.GetPerks();
    if this.m_selectedPerk >= ArraySize(perks) { return; }
    let p = perks[this.m_selectedPerk];
    this.ShowDetailCard();

    this.AddDetailText(p.name, 48, ThemeColors.Dandelion(), n"Semi-Bold");

    let desc = new inkText();
    desc.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    desc.SetFontStyle(n"Regular");
    desc.SetFontSize(30);
    desc.SetTintColor(HDRColor(0.9, 0.93, 1.0, 1.0));
    desc.SetWrapping(true, 500.0);
    desc.SetText(p.blurb);
    desc.Reparent(this.m_detail);

    this.AddStatRow("COST  ", this.Money(p.price));

    let buy = SimpleButton.Create();
    buy.SetName(n"abilityBtn");
    buy.SetText("BUY ABILITY");
    buy.SetWidth(460.0);
    buy.SetDisabled(!sys.CanAfford(p.price));
    buy.Reparent(this.m_detail);
    buy.RegisterToCallback(n"OnBtnClick", this, n"OnAbilityClick");
  }

  protected cb func OnAbilityClick(widget: wref<inkWidget>) -> Bool {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return true; }
    if this.m_selectedPerk >= 0 {
      sys.BuyPerk(this.m_selectedPerk);
    };
    this.RefreshSoon();
    return true;
  }

  // Crew dossier: who they are, who they run with, what class of threat
  // they are - everything the character records will actually admit to.
  private func BuildCrewDetail(sys: ref<ArenaSystem>) {
    if this.m_selectedAlly < 0 { return; }
    let allies = sys.GetAllies();
    if this.m_selectedAlly >= ArraySize(allies) { return; }
    let a = allies[this.m_selectedAlly];
    this.ShowDetailCard();

    this.AddDetailText(StrUpper(a.name), 48, ThemeColors.Dandelion(), n"Semi-Bold");

    let tiers = ArenaData.TierNames();
    this.AddStatRow("TIER  ", tiers[a.tier]);
    this.AddStatRow("SLOT  ", sys.IsEliteAlly(this.m_selectedAlly)
      ? "ELITE - 2 PER RUN" : "CREW - 3 ACTIVE MAX");
    let rec = TweakDBInterface.GetCharacterRecord(a.id);
    if IsDefined(rec) {
      let aff = rec.Affiliation();
      if IsDefined(aff) { this.AddStatRow("CREW  ", StrUpper(ToString(aff.Type()))); };
      let rar = rec.Rarity();
      if IsDefined(rar) { this.AddStatRow("CLASS  ", StrUpper(ToString(rar.Type()))); };
      let arch = rec.ArchetypeData();
      if IsDefined(arch) {
        let archType = arch.Type();
        if IsDefined(archType) {
          this.AddStatRow("STYLE  ", this.PrettyEnum(ToString(archType.Type())));
        };
      };
    };

    let blurb = new inkText();
    blurb.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    blurb.SetFontStyle(n"Regular");
    blurb.SetFontSize(30);
    blurb.SetTintColor(HDRColor(0.9, 0.93, 1.0, 1.0));
    blurb.SetWrapping(true, 500.0);
    blurb.SetText(a.blurb);
    blurb.Reparent(this.m_detail);

    this.AddStatRow("COST  ", this.Money(a.price));

    let hired = sys.IsHired(this.m_selectedAlly);
    let hire = SimpleButton.Create();
    hire.SetName(n"hireBtn");
    hire.SetText(hired ? "ON THE CREW" : "HIRE CREW");
    hire.SetWidth(460.0);
    hire.SetDisabled(hired || !sys.CanAfford(a.price));
    hire.Reparent(this.m_detail);
    hire.RegisterToCallback(n"OnBtnClick", this, n"OnHireClick");
  }

  protected cb func OnHireClick(widget: wref<inkWidget>) -> Bool {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return true; }
    if this.m_selectedAlly >= 0 {
      sys.SummonAlly(this.m_selectedAlly);
    };
    this.RefreshSoon();
    return true;
  }


  // =================================================================
  //  INPUT
  // =================================================================

  // Never rebuild inline - see ArenaTerminalRefresh.
  private func RefreshSoon() {
    GameInstance.GetDelaySystem(GetGameInstance())
      .DelayCallback(new ArenaTerminalRefresh(), 0.05, false);
  }

  protected cb func OnTabClick(widget: wref<inkWidget>) -> Bool {
    let name = widget.GetName();
    if Equals(name, n"tab0") { this.m_tab = 0; };
    if Equals(name, n"tab1") { this.m_tab = 1; };
    if Equals(name, n"tab2") { this.m_tab = 2; };
    this.m_page = 0;
    this.m_selectedWeapon = -1;
    this.m_selectedAlly = -1;
    this.m_selectedPerk = -1;
    this.RefreshSoon();
    return true;
  }

  protected cb func OnRowClick(widget: wref<inkWidget>) -> Bool {
    let sys = ArenaSystem.Get();
    if !IsDefined(sys) { return true; }

    let name = widget.GetName();
    let slot = -1;
    let i = 0;
    while i < ArraySize(this.m_rowNames) {
      if Equals(this.m_rowNames[i], name) { slot = i; };
      i += 1;
    };
    if slot < 0 { return true; }

    let kind = this.m_rowKinds[slot];
    let index = this.m_rowIndex[slot];

    if kind == 1 {
      // Select, don't buy - the detail panel's PICK WEAPON does that.
      this.m_selectedWeapon = index;
    } else {
      if kind == 2 {
        // Same pattern for crew: the dossier's HIRE CREW seals it.
        this.m_selectedAlly = index;
      } else {
        if kind == 3 {
          // And abilities: the panel's BUY ABILITY does the spending.
          this.m_selectedPerk = index;
        } else {
          // actions
          if index == 1 { this.CloseAndClear(); sys.StartRun(); return true; };
          if index == 2 { this.CloseAndClear(); sys.ExitArena(); return true; };
          if index == 3 { this.CloseAndClear(); return true; };
          if index == 4 { this.m_page += 1; };
          if index == 5 {
            // God mode = invulnerable + filthy rich, as one switch.
            let enable = !(sys.godMode && sys.richMode);
            sys.SetGodMode(enable);
            sys.SetRichMode(enable);
          };
          if index == 6 {
            // Cycle 0 / 5 / 10 / 15 / 20 / 30 seconds.
            let p = sys.prepSeconds;
            if p == 0 { p = 5; }
            else { if p == 5 { p = 10; }
            else { if p == 10 { p = 15; }
            else { if p == 15 { p = 20; }
            else { if p == 20 { p = 30; } else { p = 0; }; }; }; }; };
            sys.prepSeconds = p;
          };
          if index == 7 {
            // EASY > NORMAL > HARD > DEATHMODE, applied at next START RUN.
            sys.difficulty = (sys.difficulty + 1) % 4;
          };
          if index == 8 {
            // Off the verdict screen, back to the terminal proper.
            this.m_verdictMode = false;
          };
          if index == 10 { sys.gauntletEnabled = !sys.gauntletEnabled; };
          if index == 11 {
            sys.gauntletWaves += 1;
            if sys.gauntletWaves > 20 { sys.gauntletWaves = 1; };
          };
          if index == 12 {
            if IsDefined(this.m_csvInput) {
              sys.gauntletCsv = this.m_csvInput.GetText();
              ArenaSpawner.Notify("HORDE LIST SET: " + sys.gauntletCsv, 2.5);
            };
          };
          if index == 13 {
            sys.gauntletBosses += 1;
            if sys.gauntletBosses > 10 { sys.gauntletBosses = 1; };
          };
          if index == 14 {
            sys.gauntletAllies += 1;
            if sys.gauntletAllies > 10 { sys.gauntletAllies = 0; };
          };
          if index == 15 {
            let t = sys.gauntletTime;
            if t == 60 { t = 120; } else { if t == 120 { t = 180; } else {
            if t == 180 { t = 240; } else { if t == 240 { t = 300; } else {
            if t == 300 { t = 420; } else { if t == 420 { t = 600; } else {
            if t == 600 { t = 900; } else { t = 60; }; }; }; }; }; }; };
            sys.gauntletTime = t;
          };
          if index == 17 { sys.SetGodMode(!sys.godMode); };
          if index == 18 { sys.SetRichMode(!sys.richMode); };
          if index == 19 {
            this.m_sortMode = (this.m_sortMode + 1) % 4;
            this.m_page = 0;
          };
          if index == 16 {
            let m = sys.enemyHealthMult;
            if m < 0.30 { m = 0.50; } else { if m < 0.60 { m = 0.75; } else {
            if m < 0.80 { m = 1.00; } else { if m < 1.10 { m = 1.25; } else {
            if m < 1.30 { m = 1.50; } else { if m < 1.60 { m = 1.75; } else {
            if m < 1.80 { m = 2.00; } else { m = 0.25; }; }; }; }; }; }; };
            sys.enemyHealthMult = m;
          };
        };
      };
    };

    this.RefreshSoon();
    return true;
  }

  // Closing on the menu key needs no code here: the key is read raw
  // through Codeware's input events, which fire with the popup open, so
  // the tick's Toggle() closes it. Escape closes via Codeware's own
  // m_closeAction handling.

  // Closing has to restore time and input even if OnHide is skipped.
  private func CloseAndClear() {
    let sys = ArenaSystem.Get();
    if IsDefined(sys) { sys.terminal = null; };
    this.Close();
    ArenaSpawner.ClearMenuState();
  }
}

// Drives the icon-ratio measurement: re-checks the probe every 0.15s
// until the texture reports its true size. Plain straight-line code.
public class ArenaIconProbeTick extends DelayCallback {
  public let terminal: wref<ArenaTerminal>;

  protected func Call() -> Void {
    if IsDefined(this.terminal) {
      this.terminal.TickIconProbe();
    };
  }
}
