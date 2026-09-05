module QJF

// -----------------------------------------------------------------------
// Mode fact I/O (kept for modes 0..6 and now used for 7 to drive highlight)
// -----------------------------------------------------------------------
private func QJF_SetMode(mode: Int32) -> Void {
  let clamped: Int32 = (mode < 0) ? 0 : ((mode > 7) ? 7 : mode);
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  if IsDefined(qs) { qs.SetFact(n"QJF_FilterMode", clamped); }
}

private func QJF_GetMode() -> Int32 {
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  if IsDefined(qs) { return qs.GetFact(n"QJF_FilterMode"); }
  return 0;
}

private func QJF_ForceRebuild(owner: wref<inkGameController>) -> Void {
  if !IsDefined(owner) { return; }
  let c1 = owner as questLogGameController;
  if IsDefined(c1) { c1.BuildQuestList(); return; }
  let c2 = owner as questLogV2GameController;
  if IsDefined(c2) { c2.BuildQuestList(); return; }
}

// ===== COMPLETED (v1 uses native Finished list) =====
@addMethod(questLogGameController)
public func QJF_ShowCompleted() -> Void {
  // Switch the underlying list to Finished like the stock UI
  this.m_virtualListController.SetFilter(QuestListItemType.Finished);
  this.m_filterSwich = true;
  this.BuildQuestList();
}

// ===== RESET (switch back from Finished to All for non-completed) =====
@addMethod(questLogGameController)
public func QJF_ResetNativeFilter() -> Void {
  this.m_virtualListController.SetFilter(QuestListItemType.All);
  this.m_filterSwich = false;
}

// (v2 stubs: safe defaults; can be wired to a dedicated finished view later)
@addMethod(questLogV2GameController)
public func QJF_ShowCompleted() -> Void {
  this.BuildQuestList();
}
@addMethod(questLogV2GameController)
public func QJF_ResetNativeFilter() -> Void {
  // no-op for now
}

// -----------------------------------------------------------------------
// UI builders
// -----------------------------------------------------------------------
private func QJF_MakeBar(parent: wref<inkCompoundWidget>) -> wref<inkHorizontalPanel> {
  if !IsDefined(parent) { return null; }

  let exist = parent.GetWidgetByPathName(n"QJF_ButtonBar") as inkHorizontalPanel;
  if IsDefined(exist) {
    exist.SetVisible(true);
    exist.SetInteractive(true);
    return exist;
  }

  let bar = new inkHorizontalPanel();
  bar.SetName(n"QJF_ButtonBar");
  bar.SetFitToContent(true);
  bar.SetHAlign(inkEHorizontalAlign.Left);
  bar.SetVAlign(inkEVerticalAlign.Top);
  bar.SetMargin(new inkMargin(0.0, 0.0, 0.0, 0.0));
  bar.SetTranslation(new Vector2(700.0, 260.0)); // visible, tweak as needed
  bar.SetChildMargin(new inkMargin(16.0, 0.0, 0.0, 0.0));
  bar.Reparent(parent, -1);
  return bar as inkHorizontalPanel;
}

private func QJF_MakeTextBtn(name: CName, label: String, parent: wref<inkCompoundWidget>) -> wref<inkText> {
  let reuse = parent.GetWidgetByPathName(name) as inkText;
  if IsDefined(reuse) {
    reuse.SetText(label);
    reuse.SetInteractive(true);
    return reuse;
  }

  let t = new inkText();
  t.SetName(name);
  t.SetText(label);
  t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  t.SetFontStyle(n"rajdhani-regular");
  t.SetFontSize(40);
  t.SetLetterCase(textLetterCase.UpperCase);
  t.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
  t.SetFitToContent(true);
  t.SetInteractive(true);
  t.Reparent(parent, -1);
  return t;
}

private func QJF_UpdateBarStyle(bar: wref<inkHorizontalPanel>, activeIdx: Int32) -> Void {
  if !IsDefined(bar) { return; }
  let count = bar.GetNumChildren();
  let i: Int32 = 0;
  while i < count {
    let w = bar.GetWidget(i);
    let t = w as inkText;
    if IsDefined(t) {
      let isActive = i == activeIdx;
      if isActive {
        t.SetTintColor(new HDRColor(1.00, 0.30, 0.30, 1.0));
        t.SetFontStyle(n"Bold");
      } else {
        t.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
        t.SetFontStyle(n"Regular");
      }
    }
    i += 1;
  }
}

private func QJF_AttachButtons(root: wref<inkWidget>, owner: ref<IScriptable>) -> Void {
  if !IsDefined(root) || !IsDefined(owner) { return; }

  let parent = root as inkCompoundWidget;
  if !IsDefined(parent) { return; }

  let bar = QJF_MakeBar(parent);

  let labels: array<String>;
  ArrayPush(labels, "ALL");
  ArrayPush(labels, "MAIN");
  ArrayPush(labels, "SIDE");
  ArrayPush(labels, "MINOR");
  ArrayPush(labels, "STREET");
  ArrayPush(labels, "PSYCHOS");
  ArrayPush(labels, "CONTRACTS");
  ArrayPush(labels, "COMPLETED");

  let callbacks: array<CName>;
  ArrayPush(callbacks, n"OnQJF0");
  ArrayPush(callbacks, n"OnQJF1");
  ArrayPush(callbacks, n"OnQJF2");
  ArrayPush(callbacks, n"OnQJF3");
  ArrayPush(callbacks, n"OnQJF4");
  ArrayPush(callbacks, n"OnQJF5");
  ArrayPush(callbacks, n"OnQJF6");
  ArrayPush(callbacks, n"OnQJF7");

  let i: Int32 = 0;
  while i < ArraySize(labels) {
    let btnName = NameToString(n"QJF_BTN_") + ToString(i);
    let btn = QJF_MakeTextBtn(StringToName(btnName), labels[i], bar);
    btn.UnregisterFromCallback(n"OnRelease", owner, callbacks[i]);
    btn.RegisterToCallback(n"OnRelease", owner, callbacks[i]);
    i += 1;
  }

  QJF_UpdateBarStyle(bar, QJF_GetMode());
}

// -----------------------------------------------------------------------
// Hook controllers + CALLBACK handlers
// -----------------------------------------------------------------------

// ===== v1: questLogGameController =====
@wrapMethod(questLogGameController)
protected cb func OnInitialize() -> Bool {
  let ok = wrappedMethod();
  QJF_AttachButtons(this.GetRootWidget(), this);
  return ok;
}

@wrapMethod(questLogGameController)
protected func BuildQuestList() -> Void {
  wrappedMethod();
  QJF_AttachButtons(this.GetRootWidget(), this);
}

// Non-completed: RESET native list (Finished->All), set mode, rebuild, refresh bar
@addMethod(questLogGameController) protected cb func OnQJF0(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(0); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogGameController) protected cb func OnQJF1(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(1); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogGameController) protected cb func OnQJF2(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(2); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogGameController) protected cb func OnQJF3(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(3); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogGameController) protected cb func OnQJF4(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(4); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogGameController) protected cb func OnQJF5(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(5); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogGameController) protected cb func OnQJF6(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(6); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }

// Completed: set mode=7 (for highlight + to stop intersecting with last mode), switch to Finished, refresh bar
@addMethod(questLogGameController) protected cb func OnQJF7(widget: wref<inkWidget>) -> Bool {
  QJF_SetMode(7);                // <-- NEW: drive highlight + neutralize other filters
  this.QJF_ShowCompleted();      // native Finished list
  QJF_AttachButtons(this.GetRootWidget(), this);
  return true;
}

// ===== v2: questLogV2GameController =====
@wrapMethod(questLogV2GameController)
protected cb func OnInitialize() -> Bool {
  let ok = wrappedMethod();
  QJF_AttachButtons(this.GetRootWidget(), this);
  return ok;
}

@wrapMethod(questLogV2GameController)
protected func BuildQuestList() -> Void {
  wrappedMethod();
  QJF_AttachButtons(this.GetRootWidget(), this);
}

@addMethod(questLogV2GameController) protected cb func OnQJF0(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(0); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogV2GameController) protected cb func OnQJF1(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(1); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogV2GameController) protected cb func OnQJF2(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(2); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogV2GameController) protected cb func OnQJF3(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(3); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogV2GameController) protected cb func OnQJF4(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(4); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogV2GameController) protected cb func OnQJF5(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(5); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }
@addMethod(questLogV2GameController) protected cb func OnQJF6(widget: wref<inkWidget>) -> Bool { this.QJF_ResetNativeFilter(); QJF_SetMode(6); QJF_ForceRebuild(this); QJF_AttachButtons(this.GetRootWidget(), this); return true; }

@addMethod(questLogV2GameController) protected cb func OnQJF7(widget: wref<inkWidget>) -> Bool {
  QJF_SetMode(7);               // drive highlight consistently on v2 as well
  this.QJF_ShowCompleted();
  QJF_AttachButtons(this.GetRootWidget(), this);
  return true;
}
