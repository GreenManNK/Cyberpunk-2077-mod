module QuestGuide
import Codeware.UI.*
import Codeware.Localization.*

enum QGCategory {
  Main = 0,
  Ending = 1,
  Cosmetic = 2,
  Gig = 3,
  PhantomLiberty = 4,
  Cyberpsycho = 5,
  Ncpd = 6,
  PhantomLibertySide = 7
}

public struct QGQuest {
  public let entry: wref<JournalQuest>;
  public let title: String;
  public let path: String;
  public let category: QGCategory;
  public let state: gameJournalEntryState;
  public let tracked: Bool;
  public let search: String;
  public let fixer: Int32;
}

public func QGFixerCount() -> Int32 {
  return 9;
}

public func QGFixerName(idx: Int32) -> String {
  switch idx {
    case 0: return "REGINA JONES - WATSON";
    case 1: return "WAKAKO OKADA - WESTBROOK";
    case 2: return "SEBASTIAN IBARRA - HEYWOOD";
    case 3: return "EL CAPITAN - CITY CENTER";
    case 4: return "DINO DINOVIC - SANTO DOMINGO";
    case 5: return "MR. HANDS - PACIFICA";
    case 6: return "DAKOTA SMITH - BADLANDS";
    case 7: return "MR. HANDS - DOGTOWN";
    default: return "";
  };
}

public func QGFixerFromPath(path: String) -> Int32 {
  if !StrContains(path, "street_stories") {
    return -1;
  };
  if StrContains(path, "ep1/") {
    return 7;
  };
  if StrContains(path, "/watson/") {
    return 0;
  };
  if StrContains(path, "/westbrook/") {
    return 1;
  };
  if StrContains(path, "/heywood/") {
    return 2;
  };
  if StrContains(path, "/city_center/") {
    return 3;
  };
  if StrContains(path, "/santo_domingo/") {
    return 4;
  };
  if StrContains(path, "/pacifica/") {
    return 5;
  };
  if StrContains(path, "/badlands/") {
    return 6;
  };
  return QGFixerCount() - 1;
}

public func QGPointOfNoReturnIds() -> array<String> {
  return ["02_sickness"];
}

public func QGIsPointOfNoReturn(id: String) -> Bool {
  return QGHas(QGPointOfNoReturnIds(), id);
}

public func QGEndingSideIds() -> array<String> {
  return [
    "sq004_riders_on_the_storm",
    "sq031_rogue",
    "sq031_smack_my_bitch_up",
    "sq031_cinema",
    "sq030_judy_romance",
    "sq028_kerry_romance",
    "sq029_sobchak_romance",
    "sq021_sick_dreams",
    "sq011_kerry", "sq017_kerry", "sq011_concert", "sq011_johnny",
    "sq017_02_lounge"
  ];
}

public func QGMetaCosmeticIds() -> array<String> {
  return ["07_nc_underground", "08_headhunter"];
}

func QGHas(ids: array<String>, id: String) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(ids) {
    if Equals(ids[i], id) {
      return true;
    };
    i += 1;
  };
  return false;
}

public func QGCategoryFromPath(path: String) -> QGCategory {
  if StrContains(path, "street_stories") {
    return QGCategory.Gig;
  };
  if StrContains(path, "ep1/") {
    return StrContains(path, "main_quest") ? QGCategory.PhantomLiberty : QGCategory.PhantomLibertySide;
  };
  if StrContains(path, "minor_activities") {
    return QGCategory.Ncpd;
  };
  if StrContains(path, "minor_quest") && StrContains(path, "/ma_") {
    return QGCategory.Cyberpsycho;
  };
  if StrContains(path, "main_quest") {
    return QGCategory.Main;
  };
  let segs: array<String> = StrSplit(path, "/");
  let i: Int32 = 0;
  while i < ArraySize(segs) - 1 {
    if i > 0 && Equals(segs[i], "meta") {
      return QGHas(QGMetaCosmeticIds(), segs[i + 1]) ? QGCategory.Cosmetic : QGCategory.Main;
    };
    if Equals(segs[i], "side_quest") {
      return QGHas(QGEndingSideIds(), segs[i + 1]) ? QGCategory.Ending : QGCategory.Cosmetic;
    };
    i += 1;
  };
  return QGCategory.Cosmetic;
}

public func QGEntryPath(jm: ref<JournalManager>, entry: wref<JournalEntry>) -> String {
  let path: String = entry.GetId();
  let parent: wref<JournalEntry> = jm.GetParentEntry(entry);
  let guard: Int32 = 0;
  while IsDefined(parent) && guard < 20 {
    path = parent.GetId() + "/" + path;
    parent = jm.GetParentEntry(parent);
    guard += 1;
  };
  return path;
}

public func QGSlotOf(item: QGQuest) -> Int32 {
  switch item.category {
    case QGCategory.Main: return 0;
    case QGCategory.PhantomLiberty: return 1;
    case QGCategory.Ending: return 2;
    case QGCategory.Cyberpsycho: return 3;
    case QGCategory.Ncpd: return 4;
    case QGCategory.Cosmetic: return 5;
    case QGCategory.PhantomLibertySide: return 6;
    default: return 7 + item.fixer;
  };
}

public func QGSlotCount() -> Int32 {
  return 7 + QGFixerCount();
}

public func QGBuildQuestList(game: GameInstance, alpha: Bool) -> array<QGQuest> {
  let result: array<QGQuest>;
  let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
  if !IsDefined(jm) {
    return result;
  };
  let context: JournalRequestContext;
  context.stateFilter.active = true;
  context.stateFilter.inactive = true;
  context.stateFilter.succeeded = true;
  context.stateFilter.failed = true;
  let entries: array<wref<JournalEntry>>;
  jm.GetQuests(context, entries);
  let tracked: wref<JournalEntry> = jm.GetTrackedEntry();
  let i: Int32 = 0;
  while i < ArraySize(entries) {
    let quest: wref<JournalQuest> = entries[i] as JournalQuest;
    if IsDefined(quest) && !Equals(quest.GetId(), "generic_sts_quest") {
      let item: QGQuest;
      item.entry = quest;
      item.title = GetLocalizedText(quest.GetTitle(jm));
      if Equals(item.title, "") {
        item.title = "?";
      };
      item.path = QGEntryPath(jm, quest);
      item.category = QGCategoryFromPath(item.path);
      item.fixer = QGFixerFromPath(item.path);
      item.state = jm.GetEntryState(quest);
      item.tracked = IsDefined(tracked) && tracked == quest;
      item.search = UTF8StrLower(item.title);
      QGInsertSorted(result, item, alpha);
    };
    i += 1;
  };
  return result;
}

func QGQuestText(jm: ref<JournalManager>, entry: wref<JournalQuest>) -> String {
  let filter: JournalRequestStateFilter;
  filter.active = true;
  filter.succeeded = true;
  filter.failed = true;
  let children: array<wref<JournalEntry>>;
  jm.GetChildren(entry, filter, children);
  let text: String = "";
  let i: Int32 = 0;
  while i < ArraySize(children) {
    let desc: wref<JournalQuestDescription> = children[i] as JournalQuestDescription;
    if IsDefined(desc) {
      text += " " + QGLocText(desc.GetDescription());
    };
    let obj: wref<JournalQuestObjective> = children[i] as JournalQuestObjective;
    if IsDefined(obj) {
      text += " " + QGLocText(obj.GetDescription());
    };
    let phase: wref<JournalQuestPhase> = children[i] as JournalQuestPhase;
    if IsDefined(phase) {
      let objs: array<wref<JournalEntry>>;
      jm.GetChildren(phase, filter, objs);
      let j: Int32 = 0;
      while j < ArraySize(objs) {
        let pObj: wref<JournalQuestObjective> = objs[j] as JournalQuestObjective;
        if IsDefined(pObj) {
          text += " " + QGLocText(pObj.GetDescription());
        };
        j += 1;
      };
    };
    i += 1;
  };
  return text;
}

func QGInsertSorted(out list: array<QGQuest>, item: QGQuest, alpha: Bool) {
  let key: Int32 = alpha ? 0 : QGStateToggleIdx(item.state);
  let i: Int32 = 0;
  while i < ArraySize(list) {
    let k: Int32 = alpha ? 0 : QGStateToggleIdx(list[i].state);
    if k > key || k == key && UnicodeStringCompare(list[i].title, item.title) > 0 {
      break;
    };
    i += 1;
  };
  ArrayInsert(list, i, item);
}

public func QGResort(list: array<QGQuest>, alpha: Bool) -> array<QGQuest> {
  let result: array<QGQuest>;
  let i: Int32 = 0;
  while i < ArraySize(list) {
    QGInsertSorted(result, list[i], alpha);
    i += 1;
  };
  return result;
}

public func QGWhite() -> HDRColor {
  return new HDRColor(1.0, 1.0, 1.0, 1.0);
}

public func QGTrackQuest(game: GameInstance, entry: wref<JournalQuest>) {
  GameInstance.GetJournalManager(game).TrackEntry(entry);
}


func QGStateColor(state: gameJournalEntryState) -> HDRColor {
  if Equals(state, gameJournalEntryState.Succeeded) {
    return new HDRColor(0.30, 0.85, 0.35, 1.0);
  };
  if Equals(state, gameJournalEntryState.Active) {
    return new HDRColor(1.00, 0.82, 0.00, 1.0);
  };
  if Equals(state, gameJournalEntryState.Failed) {
    return new HDRColor(0.90, 0.35, 0.30, 1.0);
  };
  return new HDRColor(0.62, 0.62, 0.64, 1.0);
}

func QGStateToggleIdx(state: gameJournalEntryState) -> Int32 {
  if Equals(state, gameJournalEntryState.Active) {
    return 0;
  };
  if Equals(state, gameJournalEntryState.Succeeded) {
    return 2;
  };
  if Equals(state, gameJournalEntryState.Failed) {
    return 3;
  };
  return 1;
}

func QGFilterCount() -> Int32 {
  return 5;
}

func QGDecisionFilterIdx() -> Int32 {
  return 4;
}

func QGIsDecisionQuest(item: QGQuest) -> Bool {
  if Equals(item.state, gameJournalEntryState.Succeeded) || Equals(item.state, gameJournalEntryState.Failed) {
    return false;
  };
  return Equals(item.category, QGCategory.Ending) || QGIsPointOfNoReturn(item.entry.GetId());
}

func QGStateShowLabel(idx: Int32, loc: ref<LocalizationSystem>) -> String {
  if idx == QGDecisionFilterIdx() {
    return loc.GetText("Mod-QuestGuide-Filter-Decisions");
  };
  if idx == 0 {
    return loc.GetText("Mod-QuestGuide-State-Active");
  };
  if idx == 1 {
    return loc.GetText("Mod-QuestGuide-State-Pending");
  };
  if idx == 2 {
    return loc.GetText("Mod-QuestGuide-State-Done");
  };
  return loc.GetText("Mod-QuestGuide-State-Failed");
}

func QGStateShowColor(idx: Int32) -> HDRColor {
  if idx == QGDecisionFilterIdx() {
    return new HDRColor(0.00, 0.85, 0.85, 1.0);
  };
  if idx == 0 {
    return new HDRColor(1.00, 0.82, 0.00, 1.0);
  };
  if idx == 1 {
    return new HDRColor(0.62, 0.62, 0.64, 1.0);
  };
  if idx == 2 {
    return new HDRColor(0.30, 0.85, 0.35, 1.0);
  };
  return new HDRColor(0.90, 0.35, 0.30, 1.0);
}

func QGEstLines(text: String, charsPerLine: Int32) -> Int32 {
  return StrLen(text) / charsPerLine + 1;
}

func QGStateWord(state: gameJournalEntryState, loc: ref<LocalizationSystem>) -> String {
  if Equals(state, gameJournalEntryState.Succeeded) {
    return loc.GetText("Mod-QuestGuide-State-Done");
  };
  if Equals(state, gameJournalEntryState.Active) {
    return loc.GetText("Mod-QuestGuide-State-Active");
  };
  if Equals(state, gameJournalEntryState.Failed) {
    return loc.GetText("Mod-QuestGuide-State-Failed");
  };
  return loc.GetText("Mod-QuestGuide-State-Pending");
}

func QGStatePrefix(state: gameJournalEntryState) -> String {
  if Equals(state, gameJournalEntryState.Succeeded) {
    return "+ ";
  };
  if Equals(state, gameJournalEntryState.Active) {
    return "> ";
  };
  if Equals(state, gameJournalEntryState.Failed) {
    return "x ";
  };
  return "- ";
}

func QGEndingReason(id: String, loc: ref<LocalizationSystem>) -> String {
  if Equals(id, "sq004_riders_on_the_storm") {
    return loc.GetText("Mod-QuestGuide-Ending-Star");
  };
  if Equals(id, "sq031_rogue") {
    return loc.GetText("Mod-QuestGuide-Ending-Sun");
  };
  if Equals(id, "sq031_smack_my_bitch_up") || Equals(id, "sq031_cinema") {
    return loc.GetText("Mod-QuestGuide-Ending-JohnnyChain");
  };
  if Equals(id, "sq030_judy_romance") {
    return loc.GetText("Mod-QuestGuide-Ending-JudyRomance");
  };
  if Equals(id, "sq029_sobchak_romance") || Equals(id, "sq021_sick_dreams") {
    return loc.GetText("Mod-QuestGuide-Ending-RiverRomance");
  };
  if Equals(id, "sq028_kerry_romance") || Equals(id, "sq011_kerry") || Equals(id, "sq017_kerry")
      || Equals(id, "sq011_concert") || Equals(id, "sq011_johnny") || Equals(id, "sq017_02_lounge") {
    return loc.GetText("Mod-QuestGuide-Ending-KerryChain");
  };
  return "";
}

func QGLocText(raw: String) -> String {
  let loc: String = GetLocalizedText(raw);
  return Equals(loc, "") ? raw : loc;
}

public class QuestGuidePopup extends InGamePopup {
  protected let m_header: ref<InGamePopupHeader>;
  protected let m_footer: ref<InGamePopupFooter>;
  protected let m_content: ref<InGamePopupContent>;
  protected let m_scrollContent: wref<inkVerticalPanel>;
  protected let m_contentHeight: Float;
  protected let m_scrollOffset: Float;
  protected let m_search: ref<HubTextInput>;
  protected let m_stateToggles: array<wref<inkText>>;
  protected let m_stateShow: array<Bool>;
  protected let m_listPanel: wref<inkVerticalPanel>;
  protected let m_quests: array<QGQuest>;
  protected let m_hoverRows: array<wref<inkWidget>>;
  protected let m_hoverNames: array<wref<inkText>>;
  protected let m_hoverQuests: array<Int32>;
  protected let m_selected: Int32;
  protected let m_overDetail: Bool;
  protected let m_detailTitle: wref<inkText>;
  protected let m_trackBtn: wref<inkText>;
  protected let m_detailContent: wref<inkVerticalPanel>;
  protected let m_detailScroll: Float;
  protected let m_detailHeight: Float;
  protected let m_detailDesc: wref<inkText>;
  protected let m_detailObjectives: wref<inkVerticalPanel>;
  protected let m_detailUnlock: wref<inkText>;
  protected let m_detailPoint: wref<inkText>;
  protected let m_trackedY: Float;
  protected let m_sectionHeads: array<wref<inkText>>;
  protected let m_sectionOpen: array<Bool>;
  protected let m_sectionSlots: array<Int32>;
  protected let m_searchIndexed: Bool;
  protected let m_sectionColors: array<HDRColor>;
  protected let m_sortBtn: wref<inkText>;
  protected let m_gotoBtn: wref<inkText>;
  protected let m_alpha: Bool;
  protected let m_navWidgets: array<wref<inkText>>;
  protected let m_navKinds: array<Int32>;
  protected let m_navRefs: array<Int32>;
  protected let m_navTops: array<Float>;
  protected let m_focusZone: Int32;
  protected let m_focusIdx: Int32;
  protected let m_focusQuest: Int32;
  protected let m_focusSlot: Int32;
  protected let m_fromMenu: Bool;
  protected let m_pushedContext: Bool;

  public func QGSetFromMenu(value: Bool) -> Void {
    this.m_fromMenu = value;
  }

  protected func QGListHeight() -> Float {
    return 1500.0;
  }

  protected func QGDetailHeight() -> Float {
    return 1360.0;
  }

  public func GetName() -> CName {
    return n"QuestGuidePopup";
  }

  public func UseCursor() -> Bool {
    return true;
  }

  public func QGIsOpen() -> Bool {
    return this.IsInitialized();
  }

  protected func QGLoc() -> ref<LocalizationSystem> {
    return LocalizationSystem.GetInstance(this.GetGame());
  }

  protected cb func OnCreate() {
    super.OnCreate();
    this.m_container.SetSize(Vector2(2600.0, 1360.0));
    let loc: ref<LocalizationSystem> = this.QGLoc();

    this.m_header = InGamePopupHeader.Create();
    this.m_header.SetTitle(loc.GetText("Mod-QuestGuide-Title"));
    this.m_header.SetFluffLeft("v1.5.0");
    this.m_header.SetFluffRight("QUESTGUIDE");
    this.m_header.Reparent(this);

    this.m_footer = InGamePopupFooter.Create();
    this.m_footer.SetFluffIcon(n"fluff_triangle2");
    this.m_footer.SetFluffText(loc.GetText("Mod-QuestGuide-Footer-Hint")
      + "   [" + QuestGuideSettings.LabelOf(this.GetGame()) + "] "
      + loc.GetText("Mod-QuestGuide-Footer-Close"));
    this.m_footer.Reparent(this);
    let footRoot: ref<inkWidget> = this.m_footer.GetRootWidget();
    if IsDefined(footRoot) {
      let fm: inkMargin = footRoot.GetMargin();
      footRoot.SetMargin(inkMargin(fm.left, fm.top, fm.right, fm.bottom - 550.0));
    };

    this.m_content = InGamePopupContent.Create();
    this.m_content.Reparent(this);

    let outer: ref<inkVerticalPanel> = new inkVerticalPanel();
    outer.SetName(n"outer");
    outer.Reparent(this.m_content.GetRootCompoundWidget());

    let topRow: ref<inkHorizontalPanel> = new inkHorizontalPanel();
    topRow.SetName(n"topRow");
    topRow.SetMargin(inkMargin(0.0, 0.0, 0.0, 8.0));
    topRow.Reparent(outer);

    this.m_search = HubTextInput.Create();
    this.m_search.SetName(n"search");
    this.m_search.SetDefaultText(loc.GetText("Mod-QuestGuide-Search-Placeholder"));
    this.m_search.SetMaxLength(64);
    this.m_search.SetWidth(700.0);
    this.m_search.GetRootWidget().SetVAlign(inkEVerticalAlign.Top);
    this.m_search.Reparent(topRow);
    this.m_search.RegisterToCallback(n"OnInput", this, n"OnSearchInput");

    let body: ref<inkHorizontalPanel> = new inkHorizontalPanel();
    body.SetName(n"body");
    body.Reparent(outer);

    let listFrame: ref<inkCanvas> = new inkCanvas();
    listFrame.SetName(n"listFrame");
    listFrame.SetSize(Vector2(950.0, this.QGListHeight()));
    listFrame.Reparent(body);

    let viewport: ref<inkScrollArea> = new inkScrollArea();
    viewport.SetSize(Vector2(950.0, this.QGListHeight()));
    viewport.SetUseInternalMask(true);
    viewport.SetConstrainContentPosition(true);
    viewport.Reparent(listFrame);

    let list: ref<inkVerticalPanel> = new inkVerticalPanel();
    list.SetName(n"list");
    list.Reparent(viewport);
    this.m_listPanel = list;
    this.m_scrollContent = list;

    let filters: ref<inkHorizontalPanel> = new inkHorizontalPanel();
    filters.SetName(n"filters");
    filters.SetMargin(inkMargin(40.0, 0.0, 0.0, 0.0));
    filters.SetVAlign(inkEVerticalAlign.Top);
    filters.Reparent(topRow);

    let filtersA: ref<inkVerticalPanel> = new inkVerticalPanel();
    filtersA.Reparent(filters);
    let filtersB: ref<inkVerticalPanel> = new inkVerticalPanel();
    filtersB.SetMargin(inkMargin(32.0, 0.0, 0.0, 0.0));
    filtersB.Reparent(filters);
    let filtersC: ref<inkVerticalPanel> = new inkVerticalPanel();
    filtersC.SetMargin(inkMargin(32.0, 0.0, 0.0, 0.0));
    filtersC.Reparent(filters);

    let actions: ref<inkVerticalPanel> = new inkVerticalPanel();
    actions.SetName(n"actions");
    actions.SetMargin(inkMargin(48.0, 0.0, 0.0, 0.0));
    actions.SetVAlign(inkEVerticalAlign.Top);
    actions.Reparent(topRow);
    this.m_gotoBtn = this.MakeTopButton(actions, loc.GetText("Mod-QuestGuide-GoTracked"),
      new HDRColor(0.00, 0.85, 0.85, 1.0), 0.0);
    this.m_sortBtn = this.MakeTopButton(actions, "", new HDRColor(1.00, 0.82, 0.00, 1.0), 6.0);

    let sc: Int32 = 0;
    while sc < QGSlotCount() {
      ArrayPush(this.m_sectionOpen, true);
      sc += 1;
    };

    let ti: Int32 = 0;
    while ti < QGFilterCount() {
      ArrayPush(this.m_stateShow, ti != QGDecisionFilterIdx());
      let toggle: ref<inkText> = new inkText();
      toggle.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
      toggle.SetFontStyle(n"Medium");
      toggle.SetFontSize(25);
      toggle.SetFitToContent(true);
      toggle.SetMargin(inkMargin(0.0, ti % 2 == 0 ? 0.0 : 6.0, 0.0, 0.0));
      toggle.SetInteractive(true);
      toggle.Reparent(ti < 2 ? filtersA : (ti < 4 ? filtersB : filtersC));
      ArrayPush(this.m_stateToggles, toggle);
      ti += 1;
    };
    this.UpdateStateToggles();

    let detail: ref<inkVerticalPanel> = new inkVerticalPanel();
    detail.SetName(n"detail");
    detail.SetMargin(inkMargin(40.0, 0.0, 0.0, 0.0));
    detail.SetInteractive(true);
    detail.RegisterToCallback(n"OnHoverOver", this, n"OnDetailHoverOver");
    detail.RegisterToCallback(n"OnHoverOut", this, n"OnDetailHoverOut");
    detail.Reparent(body);

    let dTitle: ref<inkText> = new inkText();
    dTitle.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    dTitle.SetFontStyle(n"Medium");
    dTitle.SetFontSize(34);
    dTitle.SetFitToContent(true);
    dTitle.SetWrapping(true, 1330.0);
    dTitle.SetMargin(inkMargin(0.0, 0.0, 0.0, 14.0));
    dTitle.SetTintColor(new HDRColor(0.62, 0.62, 0.64, 1.0));
    dTitle.SetText(loc.GetText("Mod-QuestGuide-Detail-Header"));
    dTitle.Reparent(detail);
    this.m_detailTitle = dTitle;

    let track: ref<inkText> = new inkText();
    track.SetName(n"trackBtn");
    track.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    track.SetFontStyle(n"Medium");
    track.SetFontSize(30);
    track.SetFitToContent(true);
    track.SetMargin(inkMargin(0.0, 0.0, 0.0, 20.0));
    track.SetTintColor(new HDRColor(1.00, 0.82, 0.00, 1.0));
    track.SetInteractive(true);
    track.RegisterToCallback(n"OnHoverOver", this, n"OnDetailHoverOver");
    track.SetVisible(false);
    track.Reparent(detail);
    this.m_trackBtn = track;

    let dUnlock: ref<inkText> = new inkText();
    dUnlock.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    dUnlock.SetFontStyle(n"Medium");
    dUnlock.SetFontSize(26);
    dUnlock.SetFitToContent(true);
    dUnlock.SetWrapping(true, 1330.0);
    dUnlock.SetMargin(inkMargin(0.0, 0.0, 0.0, 16.0));
    dUnlock.SetTintColor(new HDRColor(0.00, 0.85, 0.85, 1.0));
    dUnlock.SetVisible(false);
    dUnlock.Reparent(detail);
    this.m_detailUnlock = dUnlock;

    let dPoint: ref<inkText> = new inkText();
    dPoint.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    dPoint.SetFontStyle(n"Medium");
    dPoint.SetFontSize(26);
    dPoint.SetFitToContent(true);
    dPoint.SetWrapping(true, 1330.0);
    dPoint.SetMargin(inkMargin(0.0, 0.0, 0.0, 16.0));
    dPoint.SetTintColor(new HDRColor(0.90, 0.35, 0.30, 1.0));
    dPoint.SetVisible(false);
    dPoint.Reparent(detail);
    this.m_detailPoint = dPoint;

    let dFrame: ref<inkCanvas> = new inkCanvas();
    dFrame.SetName(n"detailFrame");
    dFrame.SetSize(Vector2(1380.0, this.QGDetailHeight()));
    dFrame.Reparent(detail);

    let dView: ref<inkScrollArea> = new inkScrollArea();
    dView.SetSize(Vector2(1380.0, this.QGDetailHeight()));
    dView.SetUseInternalMask(true);
    dView.SetConstrainContentPosition(true);
    dView.Reparent(dFrame);

    let dContent: ref<inkVerticalPanel> = new inkVerticalPanel();
    dContent.SetName(n"detailContent");
    dContent.Reparent(dView);
    this.m_detailContent = dContent;

    let dDesc: ref<inkText> = new inkText();
    dDesc.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    dDesc.SetFontStyle(n"Medium");
    dDesc.SetFontSize(24);
    dDesc.SetFitToContent(true);
    dDesc.SetWrapping(true, 1330.0);
    dDesc.SetMargin(inkMargin(0.0, 0.0, 0.0, 20.0));
    dDesc.SetTintColor(new HDRColor(0.62, 0.62, 0.64, 1.0));
    dDesc.SetText(loc.GetText("Mod-QuestGuide-Detail-Placeholder"));
    dDesc.Reparent(dContent);
    this.m_detailDesc = dDesc;

    let dObjectives: ref<inkVerticalPanel> = new inkVerticalPanel();
    dObjectives.SetName(n"objectives");
    dObjectives.Reparent(dContent);
    this.m_detailObjectives = dObjectives;

    this.m_selected = -1;
    this.m_focusIdx = -1;
    this.m_focusQuest = -1;
    this.m_focusSlot = -1;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame())
      .GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(player) {
      this.m_alpha = player.m_qgSaveAlpha;
    };
    this.UpdateSortBtn();
    if IsDefined(player) && ArraySize(player.m_qgSaveShow) == QGFilterCount() {
      let si: Int32 = 0;
      while si < QGFilterCount() {
        this.m_stateShow[si] = player.m_qgSaveShow[si];
        si += 1;
      };
      this.UpdateStateToggles();
      this.m_search.SetText(player.m_qgSaveSearch);
    };
    if IsDefined(player) && ArraySize(player.m_qgSaveOpen) == QGSlotCount() {
      let so: Int32 = 0;
      while so < QGSlotCount() {
        this.m_sectionOpen[so] = player.m_qgSaveOpen[so];
        so += 1;
      };
    };
    this.m_quests = QGBuildQuestList(this.GetGame(), this.m_alpha);

    let gDone: Int32 = 0;
    let gi: Int32 = 0;
    while gi < ArraySize(this.m_quests) {
      if Equals(this.m_quests[gi].state, gameJournalEntryState.Succeeded) {
        gDone += 1;
      };
      gi += 1;
    };
    this.m_header.SetFluffRight(IntToString(gDone) + "/" + IntToString(ArraySize(this.m_quests))
      + " " + loc.GetText("Mod-QuestGuide-Progress-Done"));

    this.Rebuild();
    if this.m_trackedY >= 0.0 {
      this.m_scrollOffset = -MaxF(0.0, this.m_trackedY - 300.0);
      this.ApplyScroll();
    };
  }

  protected func MakeTopButton(parent: ref<inkCompoundWidget>, text: String, color: HDRColor,
      top: Float) -> ref<inkText> {
    let btn: ref<inkText> = new inkText();
    btn.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    btn.SetFontStyle(n"Medium");
    btn.SetFontSize(25);
    btn.SetFitToContent(true);
    btn.SetMargin(inkMargin(0.0, top, 0.0, 0.0));
    btn.SetTintColor(color);
    btn.SetInteractive(true);
    btn.SetText(text);
    btn.Reparent(parent);
    return btn;
  }

  protected func UpdateSortBtn() {
    this.m_sortBtn.SetText(this.QGLoc().GetText(this.m_alpha
      ? "Mod-QuestGuide-Sort-Alpha" : "Mod-QuestGuide-Sort-State"));
  }

  protected func UpdateStateToggles() {
    let loc: ref<LocalizationSystem> = this.QGLoc();
    let i: Int32 = 0;
    while i < ArraySize(this.m_stateToggles) {
      this.m_stateToggles[i].SetText((this.m_stateShow[i] ? "[x] " : "[ ] ")
        + QGStateShowLabel(i, loc));
      this.m_stateToggles[i].SetTintColor(this.m_stateShow[i]
        ? QGStateShowColor(i) : new HDRColor(0.35, 0.35, 0.36, 1.0));
      i += 1;
    };
  }

  protected func RowVisible(item: QGQuest, needle: String) -> Bool {
    if !Equals(needle, "") && !StrContains(item.search, needle) {
      return false;
    };
    if this.m_stateShow[QGDecisionFilterIdx()] && !QGIsDecisionQuest(item) {
      return false;
    };
    return this.m_stateShow[QGStateToggleIdx(item.state)];
  }

  protected cb func OnSearchInput(widget: wref<inkWidget>) {
    this.Rebuild();
  }

  protected func Rebuild() {
    let loc: ref<LocalizationSystem> = this.QGLoc();
    this.m_listPanel.RemoveAllChildren();
    ArrayClear(this.m_hoverRows);
    ArrayClear(this.m_hoverNames);
    ArrayClear(this.m_hoverQuests);
    ArrayClear(this.m_sectionHeads);
    ArrayClear(this.m_sectionSlots);
    ArrayClear(this.m_sectionColors);
    ArrayClear(this.m_navWidgets);
    ArrayClear(this.m_navKinds);
    ArrayClear(this.m_navRefs);
    ArrayClear(this.m_navTops);
    this.m_scrollOffset = 0.0;
    this.m_contentHeight = 0.0;
    this.m_trackedY = -1.0;
    let needle: String = UTF8StrLower(this.m_search.GetText());
    if !Equals(needle, "") {
      this.IndexSearchText();
    };
    this.AddSection(this.m_quests, QGCategory.Main,
      loc.GetText("Mod-QuestGuide-Section-Main"), new HDRColor(1.00, 0.82, 0.00, 1.0), needle,
      0, -1);
    this.AddSection(this.m_quests, QGCategory.PhantomLiberty,
      loc.GetText("Mod-QuestGuide-Section-PhantomLiberty"), new HDRColor(0.75, 0.45, 1.00, 1.0),
      needle, 1, -1);
    this.AddSection(this.m_quests, QGCategory.PhantomLibertySide,
      loc.GetText("Mod-QuestGuide-Section-PhantomLibertySide"), new HDRColor(0.60, 0.40, 0.85, 1.0),
      needle, 6, -1);
    this.AddSection(this.m_quests, QGCategory.Ending,
      loc.GetText("Mod-QuestGuide-Section-Ending"), new HDRColor(0.00, 0.85, 0.85, 1.0), needle,
      2, -1);
    this.AddSection(this.m_quests, QGCategory.Cyberpsycho,
      loc.GetText("Mod-QuestGuide-Section-Cyberpsycho"), new HDRColor(0.95, 0.35, 0.55, 1.0),
      needle, 3, -1);
    this.AddSection(this.m_quests, QGCategory.Ncpd,
      loc.GetText("Mod-QuestGuide-Section-Ncpd"), new HDRColor(0.35, 0.65, 1.00, 1.0),
      needle, 4, -1);
    this.AddSection(this.m_quests, QGCategory.Cosmetic,
      loc.GetText("Mod-QuestGuide-Section-Cosmetic"), new HDRColor(0.62, 0.62, 0.64, 1.0), needle,
      5, -1);
    let f: Int32 = 0;
    while f < QGFixerCount() {
      let title: String = Equals(QGFixerName(f), "")
        ? loc.GetText("Mod-QuestGuide-Section-Gigs") : QGFixerName(f);
      this.AddSection(this.m_quests, QGCategory.Gig, title,
        new HDRColor(1.00, 0.55, 0.20, 1.0), needle, 7 + f, f);
      f += 1;
    };
    this.ApplyScroll();
    this.RestoreFocus();
  }

  protected func IndexSearchText() {
    if this.m_searchIndexed {
      return;
    };
    this.m_searchIndexed = true;
    let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGame());
    let i: Int32 = 0;
    while i < ArraySize(this.m_quests) {
      this.m_quests[i].search += " " + UTF8StrLower(QGQuestText(jm, this.m_quests[i].entry));
      i += 1;
    };
  }

  protected func AddSection(quests: array<QGQuest>, category: QGCategory,
      title: String, color: HDRColor, needle: String, slot: Int32, fixer: Int32) {
    let loc: ref<LocalizationSystem> = this.QGLoc();

    let decisionsOnly: Bool = this.m_stateShow[QGDecisionFilterIdx()];
    let total: Int32 = 0;
    let done: Int32 = 0;
    let i: Int32 = 0;
    while i < ArraySize(quests) {
      if Equals(quests[i].category, category) && (fixer < 0 || quests[i].fixer == fixer)
          && (Equals(needle, "") || StrContains(quests[i].search, needle))
          && (!decisionsOnly || QGIsDecisionQuest(quests[i])) {
        total += 1;
        if Equals(quests[i].state, gameJournalEntryState.Succeeded) {
          done += 1;
        };
      };
      i += 1;
    };

    if total == 0 && (decisionsOnly || fixer >= 0 || Equals(category, QGCategory.PhantomLiberty)
        || Equals(category, QGCategory.PhantomLibertySide)
        || Equals(category, QGCategory.Cyberpsycho) || Equals(category, QGCategory.Ncpd)) {
      return;
    };
    let open: Bool = this.m_sectionOpen[slot] || !Equals(needle, "");

    let head: ref<inkText> = new inkText();
    head.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    head.SetFontStyle(n"Medium");
    head.SetFontSize(38);
    head.SetFitToContent(true);
    head.SetMargin(inkMargin(0.0, this.m_contentHeight > 0.0 ? 36.0 : 0.0, 0.0, 16.0));
    head.SetTintColor(color);
    head.SetInteractive(true);
    head.SetText((open ? "- " : "+ ") + title + "  " + IntToString(done) + "/" + IntToString(total));
    head.Reparent(this.m_listPanel);
    ArrayPush(this.m_sectionHeads, head);
    ArrayPush(this.m_sectionSlots, slot);
    ArrayPush(this.m_sectionColors, color);
    ArrayPush(this.m_navWidgets, head);
    ArrayPush(this.m_navKinds, 0);
    ArrayPush(this.m_navRefs, ArraySize(this.m_sectionHeads) - 1);
    ArrayPush(this.m_navTops, this.m_contentHeight + (this.m_contentHeight > 0.0 ? 36.0 : 0.0));
    this.m_contentHeight += this.m_contentHeight > 0.0 ? 102.0 : 66.0;

    let progress: ref<inkCanvas> = new inkCanvas();
    progress.SetSize(Vector2(900.0, 4.0));
    progress.SetMargin(inkMargin(0.0, 0.0, 0.0, 14.0));
    progress.Reparent(this.m_listPanel);
    let progressTrack: ref<inkRectangle> = new inkRectangle();
    progressTrack.SetSize(Vector2(900.0, 4.0));
    progressTrack.SetTintColor(color);
    progressTrack.SetOpacity(0.18);
    progressTrack.Reparent(progress);
    let progressFill: ref<inkRectangle> = new inkRectangle();
    progressFill.SetSize(Vector2(total > 0 ? 900.0 * Cast<Float>(done) / Cast<Float>(total) : 0.0, 4.0));
    progressFill.SetTintColor(color);
    progressFill.SetOpacity(0.85);
    progressFill.Reparent(progress);
    this.m_contentHeight += 18.0;
    if !open {
      return;
    };

    i = 0;
    while i < ArraySize(quests) {
      if Equals(quests[i].category, category) && (fixer < 0 || quests[i].fixer == fixer)
          && this.RowVisible(quests[i], needle) {
        let row: ref<inkHorizontalPanel> = new inkHorizontalPanel();
        row.SetMargin(inkMargin(24.0, 0.0, 0.0, 10.0));
        row.SetInteractive(true);
        row.Reparent(this.m_listPanel);

        let bar: ref<inkRectangle> = new inkRectangle();
        bar.SetSize(Vector2(6.0, 34.0));
        bar.SetMargin(inkMargin(0.0, 4.0, 12.0, 0.0));
        bar.SetTintColor(new HDRColor(0.00, 0.85, 0.85, 1.0));
        bar.SetOpacity(quests[i].tracked ? 1.0 : 0.0);
        bar.Reparent(row);

        let name: ref<inkText> = new inkText();
        name.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        name.SetFontStyle(n"Medium");
        name.SetFontSize(32);
        name.SetFitToContent(true);
        name.SetTintColor(i == this.m_selected
          ? new HDRColor(1.0, 1.0, 1.0, 1.0) : QGStateColor(quests[i].state));
        name.SetText(quests[i].title
          + (quests[i].tracked ? ("  " + loc.GetText("Mod-QuestGuide-Quest-TrackedSuffix")) : "")
          + (QGIsPointOfNoReturn(quests[i].entry.GetId())
            ? ("  " + loc.GetText("Mod-QuestGuide-Quest-PointSuffix")) : ""));
        name.Reparent(row);

        let stateText: ref<inkText> = new inkText();
        stateText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        stateText.SetFontStyle(n"Medium");
        stateText.SetFontSize(26);
        stateText.SetFitToContent(true);
        stateText.SetMargin(inkMargin(28.0, 6.0, 0.0, 0.0));
        stateText.SetTintColor(new HDRColor(0.62, 0.62, 0.64, 1.0));
        stateText.SetText(QGStateWord(quests[i].state, loc));
        stateText.Reparent(row);

        row.RegisterToCallback(n"OnHoverOver", this, n"OnRowHoverOver");
        row.RegisterToCallback(n"OnHoverOut", this, n"OnRowHoverOut");
        ArrayPush(this.m_hoverRows, row);
        ArrayPush(this.m_hoverNames, name);
        ArrayPush(this.m_hoverQuests, i);
        ArrayPush(this.m_navWidgets, name);
        ArrayPush(this.m_navKinds, 1);
        ArrayPush(this.m_navRefs, ArraySize(this.m_hoverRows) - 1);
        ArrayPush(this.m_navTops, this.m_contentHeight);
        if quests[i].tracked && this.m_trackedY < 0.0 {
          this.m_trackedY = this.m_contentHeight;
        };
        this.m_contentHeight += 52.0;

        let unlock: String = Equals(quests[i].category, QGCategory.Ending)
          ? QGEndingReason(quests[i].entry.GetId(), loc) : "";
        if !Equals(unlock, "") {
          let unlockText: ref<inkText> = new inkText();
          unlockText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
          unlockText.SetFontStyle(n"Medium");
          unlockText.SetFontSize(24);
          unlockText.SetFitToContent(true);
          unlockText.SetWrapping(true, 880.0);
          unlockText.SetMargin(inkMargin(42.0, -6.0, 0.0, 12.0));
          unlockText.SetTintColor(new HDRColor(0.00, 0.85, 0.85, 1.0));
          unlockText.SetOpacity(0.75);
          unlockText.SetText(loc.GetText("Mod-QuestGuide-Detail-Unlocks") + " " + unlock);
          unlockText.Reparent(this.m_listPanel);
          this.m_contentHeight += 34.0;
        };
      };
      i += 1;
    };
  }

  protected cb func OnAttach() {
    super.OnAttach();
    if this.m_fromMenu {
      let holder: ref<QGMenuHolder> = QGMenuHolder.Get(this.GetGame());
      if IsDefined(holder) {
        holder.QGSet(this);
        holder.QGApplyHide();
      };
      let ui: ref<UISystem> = GameInstance.GetUISystem(this.GetGame());
      if IsDefined(ui) {
        ui.PushGameContext(UIGameContext.ModalPopup);
        ui.RequestNewVisualState(n"inkInGameMenuState");
        this.m_pushedContext = true;
      };
    };
    this.RegisterToGlobalInputCallback(n"OnPostOnRelative", this, n"OnQGRelativeInput");
    GameInstance.GetCallbackSystem().RegisterCallback(n"Input/Key", this, n"OnQGPadKey")
      .SetLifetime(CallbackLifetime.Session);
    let loc: ref<LocalizationSystem> = this.QGLoc();
    let hints: wref<ButtonHintsEx> = this.m_footer.GetHints();
    if IsDefined(hints) {
      hints.AddButtonHint(n"click", loc.GetText("Mod-QuestGuide-Hint-Select"));
      hints.AddButtonHint(n"track", loc.GetText("Mod-QuestGuide-Hint-Track"));
      hints.AddButtonHint(n"activate_secondary", loc.GetText("Mod-QuestGuide-Hint-GoTracked"));
      hints.AddButtonHint(n"prior_menu", loc.GetText("Mod-QuestGuide-Hint-Section"));
      hints.AddButtonHint(n"popup_navigate_right", loc.GetText("Mod-QuestGuide-Hint-Filters"));
    };
  }

  protected cb func OnDetach() {
    if this.m_fromMenu {
      let holder: ref<QGMenuHolder> = QGMenuHolder.Get(this.GetGame());
      if IsDefined(holder) {
        holder.QGRestore();
        holder.QGSet(null);
      };
      if this.m_pushedContext {
        this.m_pushedContext = false;
        let ui: ref<UISystem> = GameInstance.GetUISystem(this.GetGame());
        if IsDefined(ui) {
          ui.PopGameContext(UIGameContext.ModalPopup);
          ui.RestorePreviousVisualState(n"inkInGameMenuState");
        };
      };
    };
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelative", this, n"OnQGRelativeInput");
    GameInstance.GetCallbackSystem().UnregisterCallback(n"Input/Key", this, n"OnQGPadKey");
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame())
      .GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(player) {
      player.m_qgSaveShow = this.m_stateShow;
      player.m_qgSaveSearch = this.m_search.GetText();
      player.m_qgSaveOpen = this.m_sectionOpen;
      player.m_qgSaveAlpha = this.m_alpha;
    };
    super.OnDetach();
  }

  protected cb func OnQGPadKey(event: ref<KeyInputEvent>) {
    if !Equals(event.GetAction(), EInputAction.IACT_Press) {
      return;
    };
    let key: EInputKey = event.GetKey();
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame())
      .GetLocalPlayerMainGameObject() as PlayerPuppet;
    let dpad: Bool = Equals(key, EInputKey.IK_Pad_DigitDown) || Equals(key, EInputKey.IK_Pad_DigitUp)
      || Equals(key, EInputKey.IK_Pad_DigitLeft) || Equals(key, EInputKey.IK_Pad_DigitRight);
    if dpad && IsDefined(player) && player.m_qgPadModHeld {
      return;
    };
    if Equals(key, EInputKey.IK_Pad_DigitDown) {
      this.MoveFocus(1);
    } else if Equals(key, EInputKey.IK_Pad_DigitUp) {
      this.MoveFocus(-1);
    } else if Equals(key, EInputKey.IK_Pad_DigitRight) {
      this.SetFocus(1, this.m_focusZone == 1 ? this.m_focusIdx : 0);
    } else if Equals(key, EInputKey.IK_Pad_DigitLeft) {
      this.SetFocus(0, this.m_focusZone == 0 ? this.m_focusIdx : this.FirstListFocus());
    } else if Equals(key, EInputKey.IK_Pad_A_CROSS) {
      this.ActivateFocus();
    } else if Equals(key, EInputKey.IK_Pad_X_SQUARE) {
      this.TrackSelected();
    } else if Equals(key, EInputKey.IK_Pad_Y_TRIANGLE) {
      this.GoToTracked();
    } else if Equals(key, EInputKey.IK_Pad_LeftShoulder) {
      this.JumpSection(-1);
    } else if Equals(key, EInputKey.IK_Pad_RightShoulder) {
      this.JumpSection(1);
    } else if Equals(key, EInputKey.IK_Pad_LeftTrigger) {
      this.m_detailScroll += 300.0;
      this.ApplyDetailScroll();
    } else if Equals(key, EInputKey.IK_Pad_RightTrigger) {
      this.m_detailScroll -= 300.0;
      this.ApplyDetailScroll();
    };
  }

  protected func FirstListFocus() -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_navKinds) {
      if this.m_navKinds[i] == 1 && this.m_hoverQuests[this.m_navRefs[i]] == this.m_selected {
        return i;
      };
      i += 1;
    };
    return 0;
  }

  protected func PaintNav(i: Int32, focused: Bool) {
    if i < 0 || i >= ArraySize(this.m_navWidgets) {
      return;
    };
    let w: wref<inkText> = this.m_navWidgets[i];
    w.SetFontStyle(focused ? n"Semi-Bold" : n"Medium");
    if this.m_navKinds[i] == 0 {
      w.SetTintColor(focused ? QGWhite() : this.m_sectionColors[this.m_navRefs[i]]);
    } else {
      let q: Int32 = this.m_hoverQuests[this.m_navRefs[i]];
      w.SetTintColor(focused || q == this.m_selected ? QGWhite() : QGStateColor(this.m_quests[q].state));
    };
  }

  protected func PaintFilter(i: Int32, focused: Bool) {
    if i >= 0 && i < QGFilterCount() {
      this.m_stateToggles[i].SetFontStyle(focused ? n"Semi-Bold" : n"Medium");
    } else if i == QGFilterCount() {
      this.m_sortBtn.SetFontStyle(focused ? n"Semi-Bold" : n"Medium");
    } else if i == QGFilterCount() + 1 {
      this.m_gotoBtn.SetFontStyle(focused ? n"Semi-Bold" : n"Medium");
    };
  }

  protected func SetFocus(zone: Int32, idx: Int32) {
    if this.m_focusZone == 0 {
      this.PaintNav(this.m_focusIdx, false);
    } else {
      this.PaintFilter(this.m_focusIdx, false);
    };
    this.m_focusZone = zone;
    if zone == 0 {
      let n: Int32 = ArraySize(this.m_navWidgets);
      this.m_focusIdx = n == 0 ? -1 : Clamp(idx, 0, n - 1);
      this.m_focusQuest = -1;
      this.m_focusSlot = -1;
      if this.m_focusIdx >= 0 {
        if this.m_navKinds[this.m_focusIdx] == 0 {
          this.m_focusSlot = this.m_sectionSlots[this.m_navRefs[this.m_focusIdx]];
        } else {
          this.m_focusQuest = this.m_hoverQuests[this.m_navRefs[this.m_focusIdx]];
        };
        this.PaintNav(this.m_focusIdx, true);
        this.EnsureFocusVisible();
      };
    } else {
      this.m_focusIdx = Clamp(idx, 0, QGFilterCount() + 1);
      this.PaintFilter(this.m_focusIdx, true);
    };
  }

  protected func MoveFocus(delta: Int32) {
    if this.m_focusIdx < 0 {
      this.SetFocus(0, this.FirstListFocus());
      return;
    };
    this.SetFocus(this.m_focusZone, this.m_focusIdx + delta);
  }

  protected func EnsureFocusVisible() {
    let top: Float = this.m_navTops[this.m_focusIdx];
    let height: Float = this.m_navKinds[this.m_focusIdx] == 0 ? 84.0 : 52.0;
    if top < -this.m_scrollOffset {
      this.m_scrollOffset = -top;
    } else if top + height > -this.m_scrollOffset + this.QGListHeight() {
      this.m_scrollOffset = -(top + height - this.QGListHeight());
    };
    this.ApplyScroll();
  }

  protected func RestoreFocus() {
    if this.m_focusZone != 0 || this.m_focusIdx < 0 {
      return;
    };
    let found: Int32 = -1;
    let i: Int32 = 0;
    while i < ArraySize(this.m_navKinds) && found < 0 {
      if this.m_navKinds[i] == 0 && this.m_focusSlot >= 0
          && this.m_sectionSlots[this.m_navRefs[i]] == this.m_focusSlot {
        found = i;
      };
      if this.m_navKinds[i] == 1 && this.m_focusQuest >= 0
          && this.m_hoverQuests[this.m_navRefs[i]] == this.m_focusQuest {
        found = i;
      };
      i += 1;
    };
    let keep: Float = this.m_scrollOffset;
    let idx: Int32 = found >= 0 ? found : this.m_focusIdx;
    this.m_focusIdx = -1;
    this.SetFocus(0, idx);
    if found < 0 {
      this.m_scrollOffset = keep;
      this.ApplyScroll();
    };
  }

  protected func ActivateFocus() {
    if this.m_focusIdx < 0 {
      return;
    };
    if this.m_focusZone == 1 {
      if this.m_focusIdx < QGFilterCount() {
        this.ToggleFilter(this.m_focusIdx);
      } else if this.m_focusIdx == QGFilterCount() {
        this.ToggleSort();
      } else {
        this.GoToTracked();
      };
      return;
    };
    if this.m_navKinds[this.m_focusIdx] == 0 {
      this.ToggleSection(this.m_navRefs[this.m_focusIdx]);
    } else {
      this.SelectQuest(this.m_hoverQuests[this.m_navRefs[this.m_focusIdx]]);
    };
  }

  protected func JumpSection(delta: Int32) {
    let i: Int32 = this.m_focusZone == 0 ? this.m_focusIdx + delta : (delta > 0 ? 0 : ArraySize(this.m_navKinds) - 1);
    while i >= 0 && i < ArraySize(this.m_navKinds) {
      if this.m_navKinds[i] == 0 {
        this.SetFocus(0, i);
        return;
      };
      i += delta;
    };
  }

  protected func GoToTracked() {
    let q: Int32 = 0;
    while q < ArraySize(this.m_quests) && !this.m_quests[q].tracked {
      q += 1;
    };
    if q >= ArraySize(this.m_quests) {
      return;
    };
    let slot: Int32 = QGSlotOf(this.m_quests[q]);
    if !this.m_sectionOpen[slot] {
      this.m_sectionOpen[slot] = true;
      this.Rebuild();
    };
    let i: Int32 = 0;
    while i < ArraySize(this.m_navKinds) {
      if this.m_navKinds[i] == 1 && this.m_hoverQuests[this.m_navRefs[i]] == q {
        this.SelectQuest(q);
        this.SetFocus(0, i);
        return;
      };
      i += 1;
    };
  }

  protected func ToggleSection(s: Int32) {
    this.m_sectionOpen[this.m_sectionSlots[s]] = !this.m_sectionOpen[this.m_sectionSlots[s]];
    let keep: Float = this.m_scrollOffset;
    this.Rebuild();
    this.m_scrollOffset = keep;
    this.ApplyScroll();
  }

  protected func ToggleFilter(t: Int32) {
    this.m_stateShow[t] = !this.m_stateShow[t];
    this.UpdateStateToggles();
    this.Rebuild();
  }

  protected func ToggleSort() {
    this.m_alpha = !this.m_alpha;
    let selectedEntry: wref<JournalQuest> = this.m_selected >= 0 ? this.m_quests[this.m_selected].entry : null;
    this.m_quests = QGResort(this.m_quests, this.m_alpha);
    this.m_selected = -1;
    let i: Int32 = 0;
    while IsDefined(selectedEntry) && i < ArraySize(this.m_quests) {
      if this.m_quests[i].entry == selectedEntry {
        this.m_selected = i;
      };
      i += 1;
    };
    this.m_focusQuest = -1;
    this.UpdateSortBtn();
    let keep: Float = this.m_scrollOffset;
    this.Rebuild();
    this.m_scrollOffset = keep;
    this.ApplyScroll();
  }

  protected cb func OnQGRelativeInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"mouse_wheel") && NotEquals(evt.GetAxisData(), 0.0) {
      if this.m_overDetail {
        this.m_detailScroll += evt.GetAxisData() * 105.0;
        this.ApplyDetailScroll();
      } else {
        this.m_scrollOffset += evt.GetAxisData() * 105.0;
        this.ApplyScroll();
      };
    };
    return false;
  }

  protected cb func OnDetailHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    this.m_overDetail = true;
    return false;
  }

  protected cb func OnDetailHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_overDetail = false;
    return false;
  }

  protected cb func OnGlobalReleaseInput(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"mouse_left") && !evt.IsHandled() {
      let target: wref<inkWidget> = evt.GetTarget();
      if IsDefined(target) && Equals(target, this.m_trackBtn) {
        this.TrackSelected();
        return super.OnGlobalReleaseInput(evt);
      };
      if IsDefined(target) && Equals(target, this.m_gotoBtn) {
        this.GoToTracked();
        return super.OnGlobalReleaseInput(evt);
      };
      if IsDefined(target) && Equals(target, this.m_sortBtn) {
        this.ToggleSort();
        return super.OnGlobalReleaseInput(evt);
      };
      let s: Int32 = 0;
      while IsDefined(target) && s < ArraySize(this.m_sectionHeads) {
        if Equals(target, this.m_sectionHeads[s]) {
          this.ToggleSection(s);
          return super.OnGlobalReleaseInput(evt);
        };
        s += 1;
      };
      let t: Int32 = 0;
      while IsDefined(target) && t < ArraySize(this.m_stateToggles) {
        if Equals(target, this.m_stateToggles[t]) {
          this.ToggleFilter(t);
          return super.OnGlobalReleaseInput(evt);
        };
        t += 1;
      };
      let i: Int32 = 0;
      while IsDefined(target) && i < ArraySize(this.m_hoverRows) {
        if Equals(target, this.m_hoverRows[i]) {
          this.SelectQuest(this.m_hoverQuests[i]);
          break;
        };
        i += 1;
      };
    };
    return super.OnGlobalReleaseInput(evt);
  }

  protected func SelectQuest(idx: Int32) {
    let j: Int32 = 0;
    while j < ArraySize(this.m_hoverQuests) {
      if this.m_hoverQuests[j] == this.m_selected {
        this.m_hoverNames[j].SetTintColor(QGStateColor(this.m_quests[this.m_selected].state));
      };
      j += 1;
    };
    this.m_selected = idx;
    j = 0;
    while j < ArraySize(this.m_hoverQuests) {
      if this.m_hoverQuests[j] == idx {
        this.m_hoverNames[j].SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
      };
      j += 1;
    };
    this.ShowDetail(idx);
  }

  protected func TrackSelected() {
    if this.m_selected < 0 || Equals(this.m_quests[this.m_selected].state, gameJournalEntryState.Succeeded) {
      return;
    };
    QGTrackQuest(this.GetGame(), this.m_quests[this.m_selected].entry);
    this.RefreshTracked();
    let keep: Float = this.m_scrollOffset;
    this.Rebuild();
    this.m_scrollOffset = keep;
    this.ApplyScroll();
    this.ShowDetail(this.m_selected);
  }

  protected cb func OnRowHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let target: wref<inkWidget> = evt.GetCurrentTarget();
    let i: Int32 = 0;
    while i < ArraySize(this.m_hoverRows) {
      if Equals(target, this.m_hoverRows[i]) {
        this.m_hoverNames[i].SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
        break;
      };
      i += 1;
    };
    return false;
  }

  protected cb func OnRowHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    let target: wref<inkWidget> = evt.GetCurrentTarget();
    let i: Int32 = 0;
    while i < ArraySize(this.m_hoverRows) {
      if Equals(target, this.m_hoverRows[i]) {
        if this.m_hoverQuests[i] != this.m_selected {
          this.m_hoverNames[i].SetTintColor(QGStateColor(this.m_quests[this.m_hoverQuests[i]].state));
        };
        break;
      };
      i += 1;
    };
    return false;
  }

  protected func ShowDetail(idx: Int32) {
    let loc: ref<LocalizationSystem> = this.QGLoc();
    let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGame());
    let item: QGQuest = this.m_quests[idx];
    this.m_detailTitle.SetTintColor(QGStateColor(item.state));
    this.m_detailTitle.SetText(item.title);
    this.m_detailObjectives.RemoveAllChildren();
    this.m_detailScroll = 0.0;
    this.m_detailHeight = 0.0;

    let reason: String = Equals(item.category, QGCategory.Ending)
      ? QGEndingReason(item.entry.GetId(), loc) : "";
    if Equals(reason, "") {
      this.m_detailUnlock.SetVisible(false);
    } else {
      this.m_detailUnlock.SetVisible(true);
      this.m_detailUnlock.SetText(loc.GetText("Mod-QuestGuide-Detail-Unlocks") + " " + reason);
    };

    let isPoint: Bool = QGIsPointOfNoReturn(item.entry.GetId());
    this.m_detailPoint.SetVisible(isPoint);
    if isPoint {
      this.m_detailPoint.SetText(loc.GetText("Mod-QuestGuide-Detail-PointOfNoReturn"));
    };

    if Equals(item.state, gameJournalEntryState.Succeeded) {
      this.m_trackBtn.SetVisible(false);
    } else {
      this.m_trackBtn.SetVisible(true);
      if item.tracked {
        this.m_trackBtn.SetText(loc.GetText("Mod-QuestGuide-Track-Tracked"));
        this.m_trackBtn.SetTintColor(new HDRColor(0.30, 0.85, 0.35, 1.0));
      } else {
        this.m_trackBtn.SetText(loc.GetText("Mod-QuestGuide-Track-Action"));
        this.m_trackBtn.SetTintColor(new HDRColor(1.00, 0.82, 0.00, 1.0));
      };
    };

    let filter: JournalRequestStateFilter;
    filter.active = true;
    filter.succeeded = true;
    filter.failed = true;
    let children: array<wref<JournalEntry>>;
    jm.GetChildren(item.entry, filter, children);

    let descFilter: JournalRequestStateFilter;
    descFilter.active = true;
    descFilter.inactive = true;
    descFilter.succeeded = true;
    descFilter.failed = true;
    let descChildren: array<wref<JournalEntry>>;
    jm.GetChildren(item.entry, descFilter, descChildren);
    let desc: String = "";
    let di: Int32 = 0;
    while di < ArraySize(descChildren) {
      let dEntry: wref<JournalQuestDescription> = descChildren[di] as JournalQuestDescription;
      if IsDefined(dEntry) && Equals(desc, "") {
        desc = QGLocText(dEntry.GetDescription());
      };
      di += 1;
    };

    let i: Int32 = 0;
    while i < ArraySize(children) {
      let phase: wref<JournalQuestPhase> = children[i] as JournalQuestPhase;
      if IsDefined(phase) {
        let objs: array<wref<JournalEntry>>;
        jm.GetChildren(phase, filter, objs);
        let j: Int32 = 0;
        while j < ArraySize(objs) {
          this.AddObjectiveRow(jm, objs[j] as JournalQuestObjective);
          j += 1;
        };
      };
      this.AddObjectiveRow(jm, children[i] as JournalQuestObjective);
      i += 1;
    };
    let descText: String = Equals(desc, "")
      ? loc.GetText("Mod-QuestGuide-Detail-NoDescription") : desc;
    this.m_detailDesc.SetText(descText);
    this.m_detailHeight += Cast<Float>(QGEstLines(descText, 80)) * 32.0 + 20.0;
    this.ApplyDetailScroll();
  }

  protected func AddObjectiveRow(jm: ref<JournalManager>, obj: wref<JournalQuestObjective>) {
    if !IsDefined(obj) {
      return;
    };
    let state: gameJournalEntryState = jm.GetEntryState(obj);
    let text: String = QGStatePrefix(state) + QGLocText(obj.GetDescription());
    if obj.HasCounter() {
      text += " (" + IntToString(jm.GetObjectiveCurrentCounter(obj))
        + "/" + IntToString(jm.GetObjectiveTotalCounter(obj)) + ")";
    };
    if jm.GetIsObjectiveOptional(obj) {
      text += " " + this.QGLoc().GetText("Mod-QuestGuide-Objective-Optional");
    };
    let row: ref<inkText> = new inkText();
    row.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    row.SetFontStyle(n"Medium");
    row.SetFontSize(24);
    row.SetFitToContent(true);
    row.SetWrapping(true, 1330.0);
    row.SetMargin(inkMargin(0.0, 0.0, 0.0, 8.0));
    row.SetTintColor(QGStateColor(state));
    row.SetText(text);
    row.Reparent(this.m_detailObjectives);
    this.m_detailHeight += Cast<Float>(QGEstLines(text, 80)) * 32.0 + 8.0;
  }

  protected func RefreshTracked() {
    let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGame());
    let tracked: wref<JournalEntry> = jm.GetTrackedEntry();
    let i: Int32 = 0;
    while i < ArraySize(this.m_quests) {
      this.m_quests[i].tracked = IsDefined(tracked) && tracked == this.m_quests[i].entry;
      i += 1;
    };
  }

  protected func ApplyScroll() {
    let viewportHeight: Float = this.QGListHeight();
    if this.m_scrollOffset > 0.0 {
      this.m_scrollOffset = 0.0;
    };
    let maxScroll: Float = MaxF(0.0, this.m_contentHeight - viewportHeight);
    this.m_scrollOffset = MaxF(-maxScroll, this.m_scrollOffset);
    this.m_scrollContent.SetTranslation(new Vector2(0.0, this.m_scrollOffset));
  }

  protected func ApplyDetailScroll() {
    if this.m_detailScroll > 0.0 {
      this.m_detailScroll = 0.0;
    };
    let maxScroll: Float = MaxF(0.0, this.m_detailHeight - this.QGDetailHeight());
    this.m_detailScroll = MaxF(-maxScroll, this.m_detailScroll);
    this.m_detailContent.SetTranslation(new Vector2(0.0, this.m_detailScroll));
  }

  public static func Show(player: ref<PlayerPuppet>) -> ref<QuestGuidePopup> {
    let popup: ref<QuestGuidePopup> = new QuestGuidePopup();
    GameInstance.GetUISystem(player.GetGame()).QueueEvent(ShowCustomPopupEvent.Create(popup));
    return popup;
  }

  public static func ShowFromMenu(player: ref<PlayerPuppet>, screen: ref<inkWidget>) -> ref<QuestGuidePopup> {
    let holder: ref<QGMenuHolder> = QGMenuHolder.Get(player.GetGame());
    if IsDefined(holder) {
      if holder.QGIsOpenNow() {
        return holder.QGGet();
      };
      holder.QGHide(screen);
    };
    let popup: ref<QuestGuidePopup> = new QuestGuidePopup();
    popup.QGSetFromMenu(true);
    GameInstance.GetUISystem(player.GetGame()).QueueEvent(ShowCustomPopupEvent.Create(popup));
    return popup;
  }
}

public class QGMenuHolder extends ScriptableSystem {
  private let m_popup: ref<QuestGuidePopup>;
  private let m_hidden: wref<inkWidget>;

  public final static func Get(game: GameInstance) -> ref<QGMenuHolder> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(n"QuestGuide.QGMenuHolder") as QGMenuHolder;
  }

  public final func QGGet() -> ref<QuestGuidePopup> {
    return this.m_popup;
  }

  public final func QGSet(popup: ref<QuestGuidePopup>) -> Void {
    this.m_popup = popup;
  }

  public final func QGIsOpenNow() -> Bool {
    return IsDefined(this.m_popup) && this.m_popup.QGIsOpen();
  }

  public final func QGHide(widget: ref<inkWidget>) -> Void {
    this.m_hidden = widget;
  }

  public final func QGApplyHide() -> Void {
    if IsDefined(this.m_hidden) {
      this.m_hidden.SetVisible(false);
    };
  }

  public final func QGRestore() -> Void {
    if IsDefined(this.m_hidden) {
      this.m_hidden.SetVisible(true);
      this.m_hidden = null;
    };
  }
}


@addField(PlayerPuppet)
let m_qgPopup: ref<QuestGuidePopup>;

@addField(PlayerPuppet)
let m_qgInBlockedMenu: Bool;

@addField(PlayerPuppet)
let m_qgSaveShow: array<Bool>;

@addField(PlayerPuppet)
let m_qgSaveSearch: String;

@addField(PlayerPuppet)
let m_qgSaveOpen: array<Bool>;

@addField(PlayerPuppet)
let m_qgSaveAlpha: Bool;

@addField(PlayerPuppet)
let m_qgPadModHeld: Bool;

@wrapMethod(PauseMenuBackgroundGameController)
protected cb func OnInitialize() -> Bool {
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  if IsDefined(player) {
    player.m_qgInBlockedMenu = true;
  };
  return wrappedMethod();
}

@wrapMethod(PauseMenuBackgroundGameController)
protected cb func OnUninitialize() -> Bool {
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  if IsDefined(player) {
    player.m_qgInBlockedMenu = false;
  };
  return wrappedMethod();
}

@wrapMethod(DeathMenuGameController)
protected cb func OnInitialize() -> Bool {
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  if IsDefined(player) {
    player.m_qgInBlockedMenu = true;
  };
  return wrappedMethod();
}

@wrapMethod(DeathMenuGameController)
protected cb func OnUninitialize() -> Bool {
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  if IsDefined(player) {
    player.m_qgInBlockedMenu = false;
  };
  return wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();
  GameInstance.GetCallbackSystem().RegisterCallback(n"Input/Key", this, n"OnQGKeyInput")
    .SetLifetime(CallbackLifetime.Session);
  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
  GameInstance.GetCallbackSystem().UnregisterCallback(n"Input/Key", this, n"OnQGKeyInput");
  return wrappedMethod();
}

@addMethod(PlayerPuppet)
protected cb func OnQGKeyInput(event: ref<KeyInputEvent>) {
  let key: EInputKey = event.GetKey();
  if Equals(key, QuestGuideSettings.PadModKeyOf(this.GetGame())) {
    this.m_qgPadModHeld = !Equals(event.GetAction(), EInputAction.IACT_Release);
    return;
  };
  if !Equals(event.GetAction(), EInputAction.IACT_Press) {
    return;
  };
  let padKey: EInputKey = QuestGuideSettings.PadBtnKeyOf(this.GetGame());
  let fromPad: Bool = this.m_qgPadModHeld && !Equals(padKey, EInputKey.IK_None) && Equals(key, padKey);
  if !fromPad && !Equals(key, QuestGuideSettings.KeyOf(this.GetGame())) {
    return;
  };
  if IsDefined(this.m_qgPopup) && this.m_qgPopup.QGIsOpen() {
    this.m_qgPopup.Close();
    this.m_qgPopup = null;
    return;
  };
  if this.m_qgInBlockedMenu || GameInstance.GetSystemRequestsHandler().IsPreGame() {
    return;
  };
  this.m_qgPopup = null;
  this.m_qgPopup = QuestGuidePopup.Show(this);
}
