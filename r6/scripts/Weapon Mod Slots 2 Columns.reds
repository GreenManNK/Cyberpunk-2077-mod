@addField(InventoryWeaponItemChooser)
let m_ewsAttachRow: wref<inkHorizontalPanel>;

@wrapMethod(InventoryWeaponItemChooser)
protected func RebuildParts() -> Void {
	wrappedMethod();
	if IsDefined(this.m_ewsAttachRow) {
		return;
	};
	let scope: ref<inkWidget> = inkWidgetRef.Get(this.m_scopeRootContainer);
	if !IsDefined(scope) {
		return;
	};
	let vpanel: ref<inkCompoundWidget> = scope.GetParentWidget() as inkCompoundWidget;
	if !IsDefined(vpanel) {
		return;
	};
	let row: ref<inkHorizontalPanel> = new inkHorizontalPanel();
	row.SetName(n"ews_attachRow");
	row.Reparent(vpanel);
	this.m_ewsAttachRow = row;
	let sil: ref<inkWidget> = inkWidgetRef.Get(this.m_silencerRootContainer);
	let mag: ref<inkWidget> = inkWidgetRef.Get(this.m_magazineRootContainer);
	scope.Reparent(row);
	if IsDefined(sil) {
		sil.Reparent(row);
	};
	if IsDefined(mag) {
		mag.Reparent(row);
	};
}

@wrapMethod(InventoryGenericItemChooser)
protected func RebuildSlots() -> Void {
	wrappedMethod();
	if NotEquals(this.equipmentArea, gamedataEquipmentArea.Weapon) {
		return;
	};
	if inkCompoundRef.GetNumChildren(this.m_slotsContainer) <= 0 {
		return;
	};
	let grid: ref<inkUniformGrid> = inkCompoundRef.GetWidgetByIndex(this.m_slotsContainer, 0).GetParentWidget() as inkUniformGrid;
	if !IsDefined(grid) {
		return;
	};
	grid.SetOrientation(inkEOrientation.Horizontal);
	grid.SetWrappingWidgetCount(2u);
}
