module JudyDateSMS

@addMethod(BaseMappinBaseController)
protected final func __jdIsJudyPin() -> Bool {
  let cap: String = this.GetMappin().GetDisplayName();
  let parts: array<String> = StrSplit(cap, "|");
  return ArraySize(parts) > 0
    && (Equals(parts[0], "JudyDate") || Equals(parts[0], "JudyHangout"));
}

@addMethod(BaseMappinBaseController)
protected final func __jdApplyJudyIconScale(opt forMinimap: Bool) -> Void {
  if !this.__jdIsJudyPin() { return; }
  if forMinimap {
    inkWidgetRef.SetScale(this.iconWidget, new Vector2(0.85, 0.85));
  }
}

@wrapMethod(MinimapPOIMappinController)
protected final func UpdateIcon() -> Void {
  wrappedMethod();
  this.__jdApplyJudyIconScale(true);
}

@wrapMethod(MinimapDeviceMappinController)
protected func Update() -> Void {
  wrappedMethod();
  this.__jdApplyJudyIconScale(true);
}

@wrapMethod(QuestMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.__jdApplyJudyIconScale(false);
}

@wrapMethod(GameplayMappinController)
private func UpdateIcon() -> Void {
  wrappedMethod();
  if IsDefined(this.m_mappin) && this.__jdIsJudyPin() {
    this.__jdApplyJudyIconScale(false);
  }
}

@wrapMethod(BaseWorldMapMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.__jdApplyJudyIconScale(false);
}

@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
  wrappedMethod(data, menu);
  let cap: String = Deref(data).mappin.GetDisplayName();
  let parts: array<String> = StrSplit(cap, "|");
  if ArraySize(parts) >= 3
    && (Equals(parts[0], "JudyDate") || Equals(parts[0], "JudyHangout")) {
    inkTextRef.SetText(this.m_titleText, parts[1]);
    inkTextRef.SetText(this.m_descText, parts[2]);
  }
}
