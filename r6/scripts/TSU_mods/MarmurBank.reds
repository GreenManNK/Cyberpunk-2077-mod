@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
  wrappedMethod(data, menu);

  let displayName: String = Deref(data).mappin.GetDisplayName();
  let splitDisplayName: array<String>;

  if Equals(displayName, "") {
    return;
  }

  splitDisplayName = StrSplit(displayName, "|");

  if ArraySize(splitDisplayName) < 3 {
    return;
  }

  if Equals(splitDisplayName[0], "TSU_MarmurBank") {
    inkTextRef.SetText(this.m_titleText, splitDisplayName[1]);
    inkTextRef.SetText(this.m_descText, splitDisplayName[2]);
  }
}
