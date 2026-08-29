// ************************************************************************************************
// ***  Lizzie's Braindances
// ***    Author: ArmanIII
// ***
// *** Please, if you will have unconquerable lust to edit this file (which I don't recommend),
// *** then please do not report any bugs you will encounter in the mod, because I don't want
// *** then spend X hours of searching of a bug which doesn't exist and in the end we find that
// *** it's all your fault. Help me save my nerves. Thanks.
// ***
// ************************************************************************************************

// https://codeberg.org/adamsmasher/cyberpunk/src/branch/master/cyberpunk/UI/fullscreen/metro_map/ncartMetroMap.swift

//@addField(NcartMetroMapController)
//private let inkSystem: ref<inkSystem>;

module LizziesBDs.UI

import LizziesBDs.Classes.*

@addField(NcartMetroMapController)
private let lizziesBDsMenuUISlotName: CName = n"LizziesBDsMenuUISlot";

@addField(NcartMetroMapController)
private let lizziesBDsMenuUIWidgetName: CName = n"LizziesBDsMenuUIWidget";

@addField(NcartMetroMapController)
private let lizziesBDsCreditsUISlotName: CName = n"LizziesBDsCreditsUISlot";

@addField(NcartMetroMapController)
private let lizziesBDsCreditsUIWidgetName: CName = n"LizziesBDsCreditsUIWidget";

@wrapMethod(NcartMetroMapController)
protected cb func OnInitialize() -> Bool {
	wrappedMethod();
	//this.inkSystem = GameInstance.GetInkSystem();
	this.InjectLizziesBDsMenuUISlot();
	this.InjectLizziesBDsCreditsUISlot();
}

@addMethod(NcartMetroMapController)
private final func InjectLizziesBDsMenuUISlot() -> Void {
	//let root: ref<inkCompoundWidget> = this.inkSystem.GetLayer(n"inkHUDLayer").GetVirtualWindow();
	let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
	let slot: ref<inkCompoundWidget> = root.GetWidgetByPathName(this.lizziesBDsMenuUISlotName) as inkCompoundWidget;
	if !IsDefined(slot) {
		let layout: inkWidgetLayout;
		layout.padding = new inkMargin(0.0, 0.0, 0.0, 0.0);
		layout.margin = new inkMargin(0.0, 0.0, 0.0, 0.0);
		layout.HAlign = inkEHorizontalAlign.Center;
		layout.VAlign = inkEVerticalAlign.Center;
		layout.anchor = inkEAnchor.Centered;
		layout.anchorPoint = new Vector2(0.5, 0.5);

		slot = new inkCanvas();
		slot.SetName(this.lizziesBDsMenuUISlotName);
		slot.SetFitToContent(true);
		slot.SetLayout(layout);
		slot.Reparent(root);
	};
	let scale: Float = 1.25;
	slot.SetScale(new Vector2(scale, scale));
	let offset: Int32 = 0;
	slot.SetTranslation(0.0, Cast<Float>(offset));
	slot.SetOpacity(1);
}

@addMethod(NcartMetroMapController)
protected cb func OnInjectLizziesBDsMenuUIToHudEvent(evt: ref<InjectLizziesBDsMenuUIToHudEvent>) -> Bool {
	//let root: ref<inkCompoundWidget> = this.inkSystem.GetLayer(n"inkHUDLayer").GetVirtualWindow();
	let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
	let slot: ref<inkCompoundWidget> = root.GetWidgetByPathName(this.lizziesBDsMenuUISlotName) as inkCompoundWidget;
	
	slot.RemoveAllChildren();

	let spawned: ref<inkWidget> = this.SpawnFromExternal(
		slot, 
		r"mod\\arman3_lizzies_bds\\gameplay\\gui\\lizzies_bds_menu.inkwidget", 
		n"Root:LizziesBDs.UI.MenuUIController"
	);

	spawned.SetName(this.lizziesBDsMenuUIWidgetName);

	//ModLog(n"LizziesBDs", "ui spawned");
}

@addMethod(NcartMetroMapController)
protected cb func OnRemoveLizziesBDsMenuUIFromHudEvent(evt: ref<RemoveLizziesBDsMenuUIFromHudEvent>) -> Bool {
	//let root: ref<inkCompoundWidget> = this.inkSystem.GetLayer(n"inkHUDLayer").GetVirtualWindow();
	let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
	let slot: ref<inkCompoundWidget> = root.GetWidgetByPathName(this.lizziesBDsMenuUISlotName) as inkCompoundWidget;
	slot.RemoveChildByName(this.lizziesBDsMenuUIWidgetName);
}

@addMethod(NcartMetroMapController)
private final func InjectLizziesBDsCreditsUISlot() -> Void {
	let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
	let slot: ref<inkCompoundWidget> = root.GetWidgetByPathName(this.lizziesBDsCreditsUISlotName) as inkCompoundWidget;
	if !IsDefined(slot) {
		let layout: inkWidgetLayout;
		layout.padding = new inkMargin(0.0, 0.0, 0.0, 0.0);
		layout.margin = new inkMargin(0.0, 0.0, 0.0, 0.0);
		layout.HAlign = inkEHorizontalAlign.Center;
		layout.VAlign = inkEVerticalAlign.Center;
		layout.anchor = inkEAnchor.Centered;
		layout.anchorPoint = new Vector2(0.5, 0.5);

		slot = new inkCanvas();
		slot.SetName(this.lizziesBDsCreditsUISlotName);
		slot.SetFitToContent(true);
		slot.SetLayout(layout);
		slot.Reparent(root);
	};
	let scale: Float = 1;
	slot.SetScale(new Vector2(scale, scale));
	let offset: Int32 = 0;
	slot.SetTranslation(0.0, Cast<Float>(offset));
	slot.SetOpacity(1);
}

@addMethod(NcartMetroMapController)
protected cb func OnInjectLizziesBDsCreditsUIToHudEvent(evt: ref<InjectLizziesBDsCreditsUIToHudEvent>) -> Bool {
	let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
	let slot: ref<inkCompoundWidget> = root.GetWidgetByPathName(this.lizziesBDsCreditsUISlotName) as inkCompoundWidget;
	
	slot.RemoveAllChildren();

	let spawned: ref<inkWidget> = this.SpawnFromExternal(
		slot, 
		r"mod\\arman3_lizzies_bds\\gameplay\\gui\\lizzies_bds_credits.inkwidget", 
		n"Root:LizziesBDs.UI.CreditsUIController"
	);

	spawned.SetName(this.lizziesBDsCreditsUIWidgetName);
}

@addMethod(NcartMetroMapController)
protected cb func OnRemoveLizziesBDsCreditsUIFromHudEvent(evt: ref<RemoveLizziesBDsCreditsUIFromHudEvent>) -> Bool {
	let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
	let slot: ref<inkCompoundWidget> = root.GetWidgetByPathName(this.lizziesBDsCreditsUISlotName) as inkCompoundWidget;
	slot.RemoveChildByName(this.lizziesBDsCreditsUIWidgetName);
}
