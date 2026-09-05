module QJF

// --- tiny equality helpers ---
private func StrEqRaw(a: String, b: String) -> Bool = StrLen(a) == StrLen(b) && StrContains(a, b);
private func NameIs(w: wref<inkWidget>, lit: CName) -> Bool = StrEqRaw(NameToString(w.GetName()), NameToString(lit));

// recursively find a child named `filter` and hide it (don’t touch our QJF bar)
private func QJF_HideFilterRecursive(w: wref<inkWidget>) -> Bool {
  if !IsDefined(w) { return false; }

  if NameIs(w, n"filter") {
    w.SetVisible(false);
    w.SetInteractive(false);
    return true;
  }

  let comp = w as inkCompoundWidget;
  if IsDefined(comp) {
    let i: Int32 = 0;
    let n = comp.GetNumChildren();
    while i < n {
      let child = comp.GetWidget(i); // correct accessor (GetChild doesn't exist)
      if QJF_HideFilterRecursive(child) { return true; }
      i += 1;
    }
  }
  return false;
}

public func QJF_HideVanillaFilterAtRoot(root: wref<inkWidget>) -> Void {
  if !IsDefined(root) { return; }
  QJF_HideFilterRecursive(root);
}

// hook both controllers and hide vanilla filter whenever the screen builds
@wrapMethod(questLogGameController)
protected cb func OnInitialize() -> Bool {
  let ok = wrappedMethod();
  QJF_HideVanillaFilterAtRoot(this.GetRootWidget());
  return ok;
}

@wrapMethod(questLogGameController)
protected func BuildQuestList() -> Void {
  wrappedMethod();
  QJF_HideVanillaFilterAtRoot(this.GetRootWidget());
}

// v2
@wrapMethod(questLogV2GameController)
protected cb func OnInitialize() -> Bool {
  let ok = wrappedMethod();
  QJF_HideVanillaFilterAtRoot(this.GetRootWidget());
  return ok;
}

@wrapMethod(questLogV2GameController)
protected func BuildQuestList() -> Void {
  wrappedMethod();
  QJF_HideVanillaFilterAtRoot(this.GetRootWidget());
}
