@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
  wrappedMethod(data, menu);

  let parts: array<String> = StrSplit(Deref(data).mappin.GetDisplayName(), "|");
  if ArraySize(parts) >= 3 && Equals(parts[0], "VM_VehicleMileage") {
    inkTextRef.SetText(this.m_titleText, parts[1]); // custom title
    inkTextRef.SetText(this.m_descText,  parts[2]); // custom desc
  }
}
