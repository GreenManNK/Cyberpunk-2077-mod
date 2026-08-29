@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
  wrappedMethod(data, menu);

  let mappin = Deref(data).mappin;
  if !IsDefined(mappin) {
    return;
  };

  let parts: array<String> = StrSplit(mappin.GetDisplayName(), "|");
  if ArraySize(parts) >= 3 && Equals(parts[0], "VM_VehicleMileage") {
    if inkWidgetRef.IsValid(this.m_titleText) {
      inkTextRef.SetText(this.m_titleText, parts[1]); // custom title
    };
    if inkWidgetRef.IsValid(this.m_descText) {
      inkTextRef.SetText(this.m_descText, parts[2]); // custom desc
    };
  }
}
