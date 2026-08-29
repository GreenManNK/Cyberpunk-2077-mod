import SurvivalSystemModule.SurvivalSystem


// Виджет выносливости

@addField(StaminabarWidgetGameController)
private let SurvivalSystem: wref<SurvivalSystem>;

@addField(StaminabarWidgetGameController)
private let fatigueLabel: wref<inkText>;

@addField(StaminabarWidgetGameController)
private let hungerLabel: wref<inkText>;

@addField(StaminabarWidgetGameController)
private let thirstLabel: wref<inkText>;

@addField(StaminabarWidgetGameController)
private let stressLabel: wref<inkText>;

@addField(StaminabarWidgetGameController)
public let hideStaminaWidget: Bool = false;

@wrapMethod(StaminabarWidgetGameController)
protected cb func OnInitialize() -> Bool {
	
	wrappedMethod();

	this.SurvivalSystem = SurvivalSystem.GetInstance((this.GetOwnerEntity() as GameObject).GetGame());

	let parentWidget: ref<inkCompoundWidget> = this.GetRootCompoundWidget();

	let survivalWidget: ref<inkHorizontalPanel> = new inkHorizontalPanel();
	survivalWidget.SetName(n"SurvivalWidget");
	survivalWidget.SetFitToContent(true);
	survivalWidget.SetHAlign(inkEHorizontalAlign.Left);
	survivalWidget.SetVAlign(inkEVerticalAlign.Top);
	survivalWidget.SetAnchor(inkEAnchor.TopLeft);
	survivalWidget.SetMargin(new inkMargin(40.0, 66.0, 0.0, 0.0));
	survivalWidget.Reparent(parentWidget, 1);

	let fatigueIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let fatigueIconName: CName = n"wait";

	let hungerIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let hungerIconName: CName = n"food_vendor";

	let thirstIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let thirstIconName: CName = n"bar";

	let stressIconPath: ResRef = r"base\\gameplay\\gui\\widgets\\healthbar\\atlas_buffinfo.inkatlas";
	let stressIconName: CName = n"consumable_weight_boost";

	let fatigueContainer: ref<inkCanvas> = this.CreateWidget(survivalWidget, fatigueIconPath, fatigueIconName, 0.0);
	this.fatigueLabel = fatigueContainer.GetWidget(n"HorizontalPanel/Label") as inkText;

	let hungerContainer: ref<inkCanvas> = this.CreateWidget(survivalWidget, hungerIconPath, hungerIconName, 20.0);
	this.hungerLabel = hungerContainer.GetWidget(n"HorizontalPanel/Label") as inkText;

	let thirstContainer: ref<inkCanvas> = this.CreateWidget(survivalWidget, thirstIconPath, thirstIconName, 20.0);
	this.thirstLabel = thirstContainer.GetWidget(n"HorizontalPanel/Label") as inkText;

	let stressContainer: ref<inkCanvas> = this.CreateWidget(survivalWidget, stressIconPath, stressIconName, 20.0);
	this.stressLabel = stressContainer.GetWidget(n"HorizontalPanel/Label") as inkText;

}

@wrapMethod(StaminabarWidgetGameController)
protected cb func OnPlayerAttach(playerGameObject: ref<GameObject>) -> Bool {

	if IsDefined(playerGameObject) {

		this.SurvivalSystem = SurvivalSystem.GetInstance(GetGameInstance());

		this.RefreshSurvivalWidget();
	};

	wrappedMethod(playerGameObject);
}

@wrapMethod(StaminabarWidgetGameController)
public final func UpdateStaminaValue(oldValue: Float, newValue: Float, percToPoints: Float, statPoolType: gamedataStatPoolType) -> Void {

	if newValue < oldValue {

		this.SurvivalSystem.ChangeStress((oldValue - newValue) * percToPoints);
	};

	wrappedMethod(oldValue, newValue, percToPoints, statPoolType);
}

@replaceMethod(StaminabarWidgetGameController)
protected cb func OnFocusedCoolPerkActive(evt: ref<FocusPerkTriggerd>) -> Bool {

	if evt.isActive {

		this.m_RootWidget.SetState(n"Focused");
		this.m_RootWidget.SetOpacity(1.00);

	} else {

		this.m_RootWidget.SetState(n"Default");
		this.EvaluateStaminaBarVisibility();
	};
}

@replaceMethod(StaminabarWidgetGameController)
public final func EvaluateStaminaBarVisibility() -> Void {

	let condition: Float = this.SurvivalSystem.GetCurrentCondition();

	if this.hideStaminaWidget {

		this.m_RootWidget.SetOpacity(1.00 - (this.m_currentBarValue * condition));

	} else {

		this.m_RootWidget.SetOpacity(1.06 - (this.m_currentBarValue * condition));
	};
}

@addMethod(StaminabarWidgetGameController)
private final func CreateWidget(container: ref<inkHorizontalPanel>, iconPath: ResRef, iconName :CName, offset: Float) -> ref<inkCanvas> {
	
	let widget: ref<inkCanvas> = new inkCanvas();
	widget.SetName(n"OuterContainer");
	widget.SetHAlign(inkEHorizontalAlign.Left);
	widget.SetVAlign(inkEVerticalAlign.Top);
	widget.SetAnchor(inkEAnchor.TopLeft);
	widget.SetSize(new Vector2(100.0, 40.0));
	widget.SetMargin(new inkMargin(offset, 0.0, 0.0, 0.0));
	widget.Reparent(container);

	let horizontalPanel: ref<inkHorizontalPanel> = new inkHorizontalPanel();
	horizontalPanel.SetName(n"HorizontalPanel");
	horizontalPanel.SetFitToContent(true);
	horizontalPanel.SetHAlign(inkEHorizontalAlign.Fill);
	horizontalPanel.SetVAlign(inkEVerticalAlign.Fill);
	horizontalPanel.SetAnchor(inkEAnchor.Fill);
	horizontalPanel.Reparent(widget);

	let icon: ref<inkImage> = new inkImage();
	icon.SetName(n"Icon");
	icon.SetAtlasResource(iconPath);
	icon.SetTexturePart(iconName);
	icon.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
	icon.SetBrushTileType(inkBrushTileType.NoTile);
	icon.SetContentHAlign(inkEHorizontalAlign.Center);
	icon.SetContentVAlign(inkEVerticalAlign.Center);
	icon.SetMargin(new inkMargin(22.0, 22.0, 22.0, 22.0));
	icon.SetScale(new Vector2(0.5, 0.5));
	icon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	icon.BindProperty(n"tintColor", n"MainColors.Yellow");
	icon.Reparent(horizontalPanel);

	let label: ref<inkText> = new inkText();
	label.SetName(n"Label");
	label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
	label.SetFontSize(30);
	label.SetHAlign(inkEHorizontalAlign.Left);
	label.SetVAlign(inkEVerticalAlign.Center);
	label.SetAnchor(inkEAnchor.CenterLeft);
	label.SetMargin(new inkMargin(0.0, 0.0, 0.0, 0.0));
	label.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	label.BindProperty(n"tintColor", n"MainColors.Yellow");
	label.Reparent(horizontalPanel);

	return widget;
}

@addMethod(StaminabarWidgetGameController)
private final func RefreshSurvivalWidget() -> Void {
	
	this.hideStaminaWidget = this.SurvivalSystem.settings.hideStaminaWidget;

	let stress: Float = this.SurvivalSystem.GetStressCurrent();

	this.fatigueLabel.SetText(s"\(FloatToStringPrec(this.SurvivalSystem.GetFatigueCurrent(), 0))%");
	this.hungerLabel.SetText(s"\(FloatToStringPrec(this.SurvivalSystem.GetHungerCurrent(), 0))%");
	this.thirstLabel.SetText(s"\(FloatToStringPrec(this.SurvivalSystem.GetThirstCurrent(), 0))%");
	this.stressLabel.SetText(s"\(stress != 1.0 ? FloatToStringPrec(stress, 1) : "1.0")x");

	this.m_RootWidget.SetVisible(true);

	this.EvaluateStaminaBarVisibility();
}

@addMethod(StaminabarWidgetGameController)
private cb func OnUpdateSettingsEvent(evt: ref<UpdateSettingsEvent>) -> Bool {

	this.RefreshSurvivalWidget();
}

@addMethod(StaminabarWidgetGameController)
private cb func OnUpdateFatigueEvent(evt: ref<UpdateFatigueEvent>) -> Bool {

	this.fatigueLabel.SetText(s"\(FloatToStringPrec(evt.current, 0))%");
}

@addMethod(StaminabarWidgetGameController)
private cb func OnUpdateHungerEvent(evt: ref<UpdateHungerEvent>) -> Bool {

	this.hungerLabel.SetText(s"\(FloatToStringPrec(evt.current, 0))%");
}

@addMethod(StaminabarWidgetGameController)
private cb func OnUpdateThirstEvent(evt: ref<UpdateThirstEvent>) -> Bool {

	this.thirstLabel.SetText(s"\(FloatToStringPrec(evt.current, 0))%");
}

@addMethod(StaminabarWidgetGameController)
private cb func OnUpdateStressEvent(evt: ref<UpdateStressEvent>) -> Bool {

	this.stressLabel.SetText(s"\(evt.current != 1.0 ? FloatToStringPrec(evt.current, 1) : "1.0")x");
}