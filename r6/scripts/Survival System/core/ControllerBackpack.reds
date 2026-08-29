import SurvivalSystemModule.SurvivalSystem
import SurvivalSystemModule.inkSurvivalBar
import SurvivalSystemModule.inkSurvivalButton
import SurvivalSystemModule.inkSurvivalInfo


// Окно инвентаря

@addField(BackpackMainGameController)
private let SurvivalSystem: wref<SurvivalSystem>;

@addField(BackpackMainGameController)
private let inventoryPanel: wref<inkCanvas>;

@addField(BackpackMainGameController)
private let fatigueBarContainer: wref<inkCanvas>;

@addField(BackpackMainGameController)
private let fatigueBar: wref<inkSurvivalBar>;

@addField(BackpackMainGameController)
private let fatigueIcon: wref<inkImage>;

@addField(BackpackMainGameController)
private let hungerBarContainer: wref<inkCanvas>;

@addField(BackpackMainGameController)
private let hungerBar: wref<inkSurvivalBar>;

@addField(BackpackMainGameController)
private let hungerIcon: wref<inkImage>;

@addField(BackpackMainGameController)
private let thirstBarContainer: wref<inkCanvas>;

@addField(BackpackMainGameController)
private let thirstBar: wref<inkSurvivalBar>;

@addField(BackpackMainGameController)
private let thirstIcon: wref<inkImage>;

@addField(BackpackMainGameController)
private let survivalButton: wref<inkSurvivalButton>;

@addField(BackpackMainGameController)
private let survivalInfo: wref<inkSurvivalInfo>;

@wrapMethod(BackpackMainGameController)
protected cb func OnInitialize() -> Bool {
	
	wrappedMethod();
	
	let parentWidget: ref<inkCompoundWidget> = this.GetRootCompoundWidget();

	this.CreateSurvivalWidget(parentWidget);
	this.CreateButtonWidget(parentWidget);
	this.CreateInfoWidget(parentWidget);

	this.inventoryPanel = parentWidget.GetWidget(n"wrapper/inventory_wrapper") as inkCanvas;

	this.fatigueBarContainer.RegisterToCallback(n"OnHoverOver", this, n"OnFatigueHoverOver");
	this.fatigueBarContainer.RegisterToCallback(n"OnHoverOut", this, n"OnFatigueHoverOut");

	this.hungerBarContainer.RegisterToCallback(n"OnHoverOver", this, n"OnHungerHoverOver");
	this.hungerBarContainer.RegisterToCallback(n"OnHoverOut", this, n"OnHungerHoverOut");

	this.thirstBarContainer.RegisterToCallback(n"OnHoverOver", this, n"OnThirstHoverOver");
	this.thirstBarContainer.RegisterToCallback(n"OnHoverOut", this, n"OnThirstHoverOut");

	this.survivalButton.RegisterToCallback(n"OnHoverOver", this, n"OnButtonHoverOver");
	this.survivalButton.RegisterToCallback(n"OnHoverOut", this, n"OnButtonHoverOut");
	this.survivalButton.RegisterToCallback(n"OnRelease", this, n"OnButtonRelease");
}

@wrapMethod(BackpackMainGameController)
protected cb func OnUninitialize() -> Bool {

	this.fatigueBarContainer.UnregisterFromCallback(n"OnHoverOver", this, n"OnFatigueHoverOver");
	this.fatigueBarContainer.UnregisterFromCallback(n"OnHoverOut", this, n"OnFatigueHoverOut");

	this.hungerBarContainer.UnregisterFromCallback(n"OnHoverOver", this, n"OnHungerHoverOver");
	this.hungerBarContainer.UnregisterFromCallback(n"OnHoverOut", this, n"OnHungerHoverOut");

	this.thirstBarContainer.UnregisterFromCallback(n"OnHoverOver", this, n"OnThirstHoverOver");
	this.thirstBarContainer.UnregisterFromCallback(n"OnHoverOut", this, n"OnThirstHoverOut");

	this.survivalButton.UnregisterFromCallback(n"OnHoverOver", this, n"OnButtonHoverOver");
	this.survivalButton.UnregisterFromCallback(n"OnHoverOut", this, n"OnButtonHoverOut");
	this.survivalButton.UnregisterFromCallback(n"OnRelease", this, n"OnButtonRelease");

	wrappedMethod();
}

@wrapMethod(BackpackMainGameController)
protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {

	this.SurvivalSystem = SurvivalSystem.GetInstance(GetGameInstance());
	this.survivalButton.ButtonActive(this.SurvivalSystem.IsBiomonitorInstalled());
	
	this.RefreshSurvivalWidget();

	wrappedMethod(playerPuppet);
}

@wrapMethod(BackpackMainGameController)
protected cb func OnItemDisplayHoverOver(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {

	wrappedMethod(evt);

	let controller: ref<DropdownListController> = inkWidgetRef.GetController(this.m_sortingDropdown) as DropdownListController;

	if !this.SurvivalSystem.settings.bigRedButton && !controller.IsOpened() {

		if IsDefined(evt.uiInventoryItem) {
			
			let itemData: wref<gameItemData> = evt.uiInventoryItem.GetItemData();

			if itemData.HasTag(n"Consumable") {
				
				let nutritionValue: Vector3 = GetNutritionVector(itemData);

				if nutritionValue.X != 0.0 {
					
					this.fatigueBar.SetFuture(nutritionValue.X);
				};

				if nutritionValue.Y != 0.0 {
					
					this.hungerBar.SetFuture(nutritionValue.Y);
				};

				if nutritionValue.Z != 0.0 {
					
					this.thirstBar.SetFuture(nutritionValue.Z);
				};
			};
		};
	};
}

@wrapMethod(BackpackMainGameController)
protected cb func OnItemDisplayHoverOut(evt: ref<ItemDisplayHoverOutEvent>) -> Bool {

	this.RefreshSurvivalWidget();

    wrappedMethod(evt);
}

@addMethod(BackpackMainGameController)
private final func CreateSurvivalWidget(parent: ref<inkCompoundWidget>) -> Void {

	let survivalWidget: ref<inkHorizontalPanel> = new inkHorizontalPanel();
	survivalWidget.SetName(n"SurvivalWidget");
	survivalWidget.SetAnchor(inkEAnchor.TopCenter);
	survivalWidget.SetAnchorPoint(new Vector2(0.5, 0.5));
	survivalWidget.SetMargin(new inkMargin(310.0, 260.0, 0.0, 0.0));
	survivalWidget.Reparent(parent, 1);

	let fatigueIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let fatigueIconName: CName = n"wait";

	let hungerIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let hungerIconName: CName = n"food_vendor";

	let thirstIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let thirstIconName: CName = n"bar";

	this.fatigueBarContainer = this.CreateProgressBar(survivalWidget, GetLocalizedTextByKey(n"SSInventoryFatigueName"), fatigueIconPath, fatigueIconName);
	this.fatigueBar = this.fatigueBarContainer.GetWidget(n"HorizontalPanel/VerticalPanel/SurvivalBar") as inkSurvivalBar;
	this.fatigueIcon = this.fatigueBarContainer.GetWidget(n"HorizontalPanel/Icon") as inkImage;

	this.hungerBarContainer = this.CreateProgressBar(survivalWidget, GetLocalizedTextByKey(n"SSInventoryHungerName"), hungerIconPath, hungerIconName);
	this.hungerBar = this.hungerBarContainer.GetWidget(n"HorizontalPanel/VerticalPanel/SurvivalBar") as inkSurvivalBar;
	this.hungerIcon = this.hungerBarContainer.GetWidget(n"HorizontalPanel/Icon") as inkImage;

	this.thirstBarContainer = this.CreateProgressBar(survivalWidget, GetLocalizedTextByKey(n"SSInventoryThirstName"), thirstIconPath, thirstIconName);
	this.thirstBar = this.thirstBarContainer.GetWidget(n"HorizontalPanel/VerticalPanel/SurvivalBar") as inkSurvivalBar;
	this.thirstIcon = this.thirstBarContainer.GetWidget(n"HorizontalPanel/Icon") as inkImage;
}

@addMethod(BackpackMainGameController)
private final func CreateProgressBar(parent: ref<inkCompoundWidget>, text: String, iconPath: ResRef, iconName :CName) -> ref<inkCanvas> {
	
	let progressBar: ref<inkCanvas> = new inkCanvas();
	progressBar.SetSize(new Vector2(660, 100.0));
	progressBar.SetMargin(new inkMargin(30.0, 30.0, 30.0, 30.0));
	progressBar.SetInteractive(true);
	progressBar.Reparent(parent);

	let horizontalPanel: ref<inkHorizontalPanel> = new inkHorizontalPanel();
	horizontalPanel.SetName(n"HorizontalPanel");
	horizontalPanel.SetAnchor(inkEAnchor.Fill);
	horizontalPanel.Reparent(progressBar);

	let icon: ref<inkImage> = new inkImage();
	icon.SetName(n"Icon");
	icon.SetMargin(new inkMargin(20.0, 40.0, 60.0, 0.0));
	icon.SetContentHAlign(inkEHorizontalAlign.Center);
	icon.SetContentVAlign(inkEVerticalAlign.Center);
	icon.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
	icon.SetBrushTileType(inkBrushTileType.NoTile);
	icon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	icon.BindProperty(n"tintColor", n"MainColors.ActiveRed");
	icon.SetAtlasResource(iconPath);
	icon.SetTexturePart(iconName);
	icon.Reparent(horizontalPanel);

	let verticalPanel: ref<inkVerticalPanel> = new inkVerticalPanel();
	verticalPanel.SetName(n"VerticalPanel");
	verticalPanel.SetAnchor(inkEAnchor.RightFillVerticaly);
	verticalPanel.Reparent(horizontalPanel);

	let label: ref<inkText> = new inkText();
	label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
	label.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	label.BindProperty(n"tintColor", n"MainColors.ActiveRed");
	label.SetLetterCase(textLetterCase.UpperCase);
	label.SetFontSize(50);
	label.SetText(text);
	label.Reparent(verticalPanel);

	let survivalBar: ref<inkSurvivalBar> = new inkSurvivalBar();
	survivalBar.SetMargin(new inkMargin(0.0, 10.0, 0.0, 0.0));
	survivalBar.Initialize(verticalPanel, new Vector2(572.0, 20.0), 0.0);

	return progressBar;
}

@addMethod(BackpackMainGameController)
private final func CreateButtonWidget(parent: ref<inkCompoundWidget>) -> Void {

	let survivalButton: ref<inkSurvivalButton> = new inkSurvivalButton();
	survivalButton.Initialize(parent);

	this.survivalButton = parent.GetWidget(n"SurvivalButton") as inkSurvivalButton;
}

@addMethod(BackpackMainGameController)
private final func CreateInfoWidget(parent: ref<inkCompoundWidget>) -> Void {

	let survivalInfo: ref<inkSurvivalInfo> = new inkSurvivalInfo();
	survivalInfo.Initialize(parent);

	this.survivalInfo = parent.GetWidget(n"SurvivalInfo") as inkSurvivalInfo;
}

@addMethod(BackpackMainGameController)
private final func RefreshSurvivalWidget() -> Void {
	
	this.fatigueBar.SetCurrent(this.SurvivalSystem.GetFatigueCurrent());
	this.hungerBar.SetCurrent(this.SurvivalSystem.GetHungerCurrent());
	this.thirstBar.SetCurrent(this.SurvivalSystem.GetThirstCurrent());
}

@addMethod(BackpackMainGameController)
private cb func OnUpdateFatigueEvent(evt: ref<UpdateFatigueEvent>) -> Bool {
	
	this.fatigueBar.SetCurrent(evt.current);
}

@addMethod(BackpackMainGameController)
private cb func OnUpdateHungerEvent(evt: ref<UpdateHungerEvent>) -> Bool {
	
	this.hungerBar.SetCurrent(evt.current);
}

@addMethod(BackpackMainGameController)
private cb func OnUpdateThirstEvent(evt: ref<UpdateThirstEvent>) -> Bool {
	
	this.thirstBar.SetCurrent(evt.current);
}

@addMethod(BackpackMainGameController)
private cb func OnFatigueHoverOver(evt: ref<inkPointerEvent>) -> Bool {
	
	this.fatigueIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	this.fatigueIcon.BindProperty(n"tintColor", n"MainColors.ActiveBlue");

	let data: ref<MessageTooltipData> = new MessageTooltipData();

	data.Title = s"\(GetLocalizedTextByKey(n"SSInventoryFatigueName")): \(FloatToStringPrec(this.SurvivalSystem.GetFatigueCurrent(), 0)) / 100";

	let loss: Int32 = RoundF(this.SurvivalSystem.settings.fatigueLoss);
	let threshold: Int32 = RoundF(this.SurvivalSystem.settings.fatigueThreshold);

	let desc: String = GetLocalizedTextByKey(n"SSInventoryFatigueDesc");
	desc = StrReplace(desc, "{int_0}", ToString(loss));
	desc = StrReplace(desc, "{int_1}", ToString(threshold));
	data.Description = desc;

	this.m_TooltipsManager.ShowTooltipAtWidget(0, this.fatigueIcon, data, gameuiETooltipPlacement.RightTop, false, new inkMargin(-34.0, 80.0, 0.0, 0.0));
}

@addMethod(BackpackMainGameController)
private cb func OnHungerHoverOver(evt: ref<inkPointerEvent>) -> Bool {
	
	this.hungerIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	this.hungerIcon.BindProperty(n"tintColor", n"MainColors.ActiveBlue");

	let data: ref<MessageTooltipData> = new MessageTooltipData();

	data.Title = s"\(GetLocalizedTextByKey(n"SSInventoryHungerName")): \(FloatToStringPrec(this.SurvivalSystem.GetHungerCurrent(), 0)) / 100";

	let loss: Int32 = RoundF(this.SurvivalSystem.settings.hungerLoss);
	let threshold: Int32 = RoundF(this.SurvivalSystem.settings.hungerThreshold);

	let desc: String = GetLocalizedTextByKey(n"SSInventoryHungerDesc");
	desc = StrReplace(desc, "{int_0}", ToString(loss));
	desc = StrReplace(desc, "{int_1}", ToString(threshold));
	data.Description = desc;

	this.m_TooltipsManager.ShowTooltipAtWidget(0, this.hungerIcon, data, gameuiETooltipPlacement.RightTop, false, new inkMargin(-34.0, 80.0, 0.0, 0.0));
}

@addMethod(BackpackMainGameController)
private cb func OnThirstHoverOver(evt: ref<inkPointerEvent>) -> Bool {
	
	this.thirstIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	this.thirstIcon.BindProperty(n"tintColor", n"MainColors.ActiveBlue");

	let data: ref<MessageTooltipData> = new MessageTooltipData();

	data.Title = s"\(GetLocalizedTextByKey(n"SSInventoryThirstName")): \(FloatToStringPrec(this.SurvivalSystem.GetThirstCurrent(), 0)) / 100";

	let loss: Int32 = RoundF(this.SurvivalSystem.settings.thirstLoss);
	let threshold: Int32 = RoundF(this.SurvivalSystem.settings.thirstThreshold);

	let desc: String = GetLocalizedTextByKey(n"SSInventoryThirstDesc");
	desc = StrReplace(desc, "{int_0}", ToString(loss));
	desc = StrReplace(desc, "{int_1}", ToString(threshold));
	data.Description = desc;

	this.m_TooltipsManager.ShowTooltipAtWidget(0, this.thirstIcon, data, gameuiETooltipPlacement.RightTop, false, new inkMargin(-34.0, 80.0, 0.0, 0.0));
}

@addMethod(BackpackMainGameController)
private cb func OnFatigueHoverOut(evt: ref<inkPointerEvent>) -> Bool {
	
	this.fatigueIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	this.fatigueIcon.BindProperty(n"tintColor", n"MainColors.ActiveRed");
	this.m_TooltipsManager.HideTooltips();
}

@addMethod(BackpackMainGameController)
private cb func OnHungerHoverOut(evt: ref<inkPointerEvent>) -> Bool {
	
	this.hungerIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	this.hungerIcon.BindProperty(n"tintColor", n"MainColors.ActiveRed");
	this.m_TooltipsManager.HideTooltips();
}

@addMethod(BackpackMainGameController)
private cb func OnThirstHoverOut(evt: ref<inkPointerEvent>) -> Bool {
	
	this.thirstIcon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	this.thirstIcon.BindProperty(n"tintColor", n"MainColors.ActiveRed");
	this.m_TooltipsManager.HideTooltips();
}

@addMethod(BackpackMainGameController)
private cb func OnButtonHoverOver(evt: ref<inkPointerEvent>) -> Bool {
	
	if !this.survivalInfo.IsVisible() {

		let data: ref<MessageTooltipData> = new MessageTooltipData();

		if this.SurvivalSystem.IsBiomonitorInstalled() {

			if !this.SurvivalSystem.settings.bigRedButton {

				this.survivalButton.ButtonHoverOver();

			} else {

				data.Title = GetLocalizedTextByKey(n"SSBiomonitorNotRespond");
				this.m_TooltipsManager.ShowTooltipAtWidget(0, this.survivalButton, data, gameuiETooltipPlacement.LeftTop, false, new inkMargin(-30.0, 0.0, 0.0, 0.0));
			};

		} else {

			data.Title = GetLocalizedTextByKey(n"SSBiomonitorNotFound");
			this.m_TooltipsManager.ShowTooltipAtWidget(0, this.survivalButton, data, gameuiETooltipPlacement.LeftTop, false, new inkMargin(-30.0, 0.0, 0.0, 0.0));
		};
	};
}

@addMethod(BackpackMainGameController)
private cb func OnButtonHoverOut(evt: ref<inkPointerEvent>) -> Bool {
	
	if !this.survivalInfo.IsVisible() {

		if this.SurvivalSystem.IsBiomonitorInstalled() {

			if !this.SurvivalSystem.settings.bigRedButton {

				this.survivalButton.ButtonHoverOut();

			} else {

				this.m_TooltipsManager.HideTooltips();
			};

		} else {

			this.m_TooltipsManager.HideTooltips();
		};
	};
}

@addMethod(BackpackMainGameController)
private cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {

	if evt.IsAction(n"click") && this.SurvivalSystem.IsBiomonitorInstalled() && !this.SurvivalSystem.settings.bigRedButton {

		if this.survivalInfo.IsVisible() {

			this.survivalInfo.HideWidget();
			this.inventoryPanel.SetVisible(true);
			this.survivalButton.ButtonHoverOver();

		} else {

			this.survivalInfo.ShowWidget(this.SurvivalSystem.GetStatusValues());
			this.inventoryPanel.SetVisible(false);
			this.survivalButton.ButtonRelease();
		};

		GameInstance.GetAudioSystem(this.m_player.GetGame()).Play(n"ui_menu_onpress");
	};
}