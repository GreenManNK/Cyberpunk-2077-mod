import SurvivalSystemModule.SurvivalSystem
import SurvivalSystemModule.inkSurvivalBar


// Окно будильника

@addField(TimeskipGameController)
private let SurvivalSystem: wref<SurvivalSystem>;

@addField(TimeskipGameController)
private let fatigueBar: wref<inkSurvivalBar>;

@addField(TimeskipGameController)
private let hungerBar: wref<inkSurvivalBar>;

@addField(TimeskipGameController)
private let thirstBar: wref<inkSurvivalBar>;

@addField(TimeskipGameController)
private let infoTitle: wref<inkText>;

@addField(TimeskipGameController)
private let infoDesc: wref<inkText>;

@addField(TimeskipGameController)
private let calculatedParameters: array<Vector4>;

@addField(TimeskipGameController)
private let sleepInCar: Bool;

@addField(TimeskipGameController)
private let sleepInBed: Bool;

@wrapMethod(TimeskipGameController)
protected cb func OnInitialize() -> Bool {
	
	wrappedMethod();

	this.SurvivalSystem = SurvivalSystem.GetInstance(GetGameInstance());
	this.SurvivalSystem.SetSkippingTimeMenuOpen(true);

	this.calculatedParameters = this.SurvivalSystem.GetCalculatedParameters();
	this.sleepInCar = this.SurvivalSystem.IsPlayerSleepInCar();
	this.sleepInBed = this.SurvivalSystem.IsPlayerSleepInBed();

	let parentWidget: ref<inkCompoundWidget> = this.GetRootCompoundWidget();

	this.CreateSurvivalWidget(parentWidget.GetWidget(n"container") as inkCanvas);
	this.CreateInfoWidget(parentWidget);

    this.RefreshSurvivalWidget();
    this.RefreshInfoWidget();
}

@wrapMethod(TimeskipGameController)
protected cb func OnUninitialize() -> Bool {

	this.SurvivalSystem.SetSkippingTimeFromMenu(false);
	this.SurvivalSystem.SetSkippingTimeMenuOpen(false);
	
	return wrappedMethod();
}

@addMethod(TimeskipGameController)
private final func CreateSurvivalWidget(parent: ref<inkCompoundWidget>) -> Void {

	let survivalWidget: ref<inkHorizontalPanel> = new inkHorizontalPanel();
	survivalWidget.SetName(n"SurvivalWidget");
	survivalWidget.SetAnchor(inkEAnchor.TopCenter);
	survivalWidget.SetAnchorPoint(new Vector2(0.5, 0.5));
	survivalWidget.SetMargin(new inkMargin(0.0, -100.0, 0.0, 0.0));
	survivalWidget.Reparent(parent, 12);

	let fatigueIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let fatigueIconName: CName = n"wait";

	let hungerIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let hungerIconName: CName = n"food_vendor";

	let thirstIconPath: ResRef = r"base\\gameplay\\gui\\common\\icons\\mappin_icons.inkatlas";
	let thirstIconName: CName = n"bar";

	let fatigueBarContainer: ref<inkCanvas> = this.CreateProgressBar(survivalWidget, GetLocalizedTextByKey(n"SSInventoryFatigueName"), fatigueIconPath, fatigueIconName);
	this.fatigueBar = fatigueBarContainer.GetWidget(n"HorizontalPanel/VerticalPanel/SurvivalBar") as inkSurvivalBar;

	let hungerBarContainer: ref<inkCanvas> = this.CreateProgressBar(survivalWidget, GetLocalizedTextByKey(n"SSInventoryHungerName"), hungerIconPath, hungerIconName);
	this.hungerBar = hungerBarContainer.GetWidget(n"HorizontalPanel/VerticalPanel/SurvivalBar") as inkSurvivalBar;

	let thirstBarContainer: ref<inkCanvas> = this.CreateProgressBar(survivalWidget, GetLocalizedTextByKey(n"SSInventoryThirstName"), thirstIconPath, thirstIconName);
	this.thirstBar = thirstBarContainer.GetWidget(n"HorizontalPanel/VerticalPanel/SurvivalBar") as inkSurvivalBar;
}

@addMethod(TimeskipGameController)
private final func CreateProgressBar(parent: ref<inkCompoundWidget>, text: String, iconPath: ResRef, iconName :CName) -> ref<inkCanvas> {
	
	let progressBar: ref<inkCanvas> = new inkCanvas();
	progressBar.SetSize(new Vector2(660, 100.0));
	progressBar.SetMargin(new inkMargin(30.0, 30.0, 30.0, 30.0));
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
	survivalBar.Initialize(verticalPanel, new Vector2(572.0, 20.0), 100.0);

	return progressBar;
}

@addMethod(TimeskipGameController)
private final func CreateInfoWidget(parent: ref<inkCompoundWidget>) -> Void {

	let infoWidget: ref<inkVerticalPanel> = new inkVerticalPanel();
	infoWidget.SetName(n"InfoWidget");
	infoWidget.SetFitToContent(true);
	infoWidget.SetHAlign(inkEHorizontalAlign.Left);
	infoWidget.SetVAlign(inkEVerticalAlign.Top);
	infoWidget.SetAnchor(inkEAnchor.TopLeft);
	infoWidget.SetMargin(new inkMargin(540.0, 680.0, 0.0, 0.0));
	infoWidget.Reparent(parent, 2);

	let title: ref<inkText> = new inkText();
	title.SetName(n"InfoTitle");
	title.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
	title.SetFontSize(50);
	title.SetHAlign(inkEHorizontalAlign.Left);
	title.SetVAlign(inkEVerticalAlign.Top);
	title.SetAnchor(inkEAnchor.TopLeft);
	title.SetLetterCase(textLetterCase.UpperCase);
	title.SetMargin(new inkMargin(0.0, 0.0, 0.0, 0.0));
	title.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	title.BindProperty(n"tintColor", n"MainColors.ActiveRed");
	title.Reparent(infoWidget);

	let desc: ref<inkText> = new inkText();
	desc.SetName(n"InfoDesc");
	desc.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
	desc.SetFontSize(38);
	desc.SetHAlign(inkEHorizontalAlign.Left);
	desc.SetVAlign(inkEVerticalAlign.Top);
	desc.SetAnchor(inkEAnchor.TopLeft);
	desc.SetMargin(new inkMargin(18.0, 14.0, 0.0, 0.0));
	desc.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
	desc.BindProperty(n"tintColor", n"MainColors.Blue");
	desc.Reparent(infoWidget);

	this.infoTitle = infoWidget.GetWidget(n"InfoTitle") as inkText;
	this.infoDesc = infoWidget.GetWidget(n"InfoDesc") as inkText;
}

@wrapMethod(TimeskipGameController)
protected cb func OnUpdate(timeDelta: Float) -> Bool {

	let angle: Float;
	let diff: Float;
	let currentHours: Int32;

	wrappedMethod(timeDelta);

	if !this.m_inputEnabled {

		if IsDefined(this.m_progressAnimProxy) && this.m_progressAnimProxy.IsPlaying() {

			angle = Deg2Rad(inkWidgetRef.GetRotation(this.m_currentTimePointerRef));

			if angle > this.m_targetTimeAngle {

				diff = Rad2Deg(6.28 - angle + this.m_targetTimeAngle);

			} else {

				diff = Rad2Deg(this.m_targetTimeAngle - angle);
			};

			currentHours = RoundF(diff / 360.00 * 24.00);

			this.SurvivalSystem.UpdateFromSkip(this.calculatedParameters[this.m_hoursToSkip - currentHours]);
			this.RefreshSurvivalWidget();
		};
	};
}

@wrapMethod(TimeskipGameController)
protected cb func OnCloseAfterFinishing(proxy: ref<inkAnimProxy>) -> Bool {

	wrappedMethod(proxy);

	this.SurvivalSystem.ForceNotification();
}

@wrapMethod(TimeskipGameController)
protected cb func OnCloseAfterCanceling(proxy: ref<inkAnimProxy>) -> Bool {

	wrappedMethod(proxy);

	this.SurvivalSystem.ForceNotification();
}

@wrapMethod(TimeskipGameController)
private final func UpdateTargetTime(angle: Float) -> Void {

	wrappedMethod(angle);

	this.RefreshSurvivalWidget();
	this.RefreshInfoWidget();
}

@addMethod(TimeskipGameController)
private final func RefreshSurvivalWidget() -> Void {

	if !this.SurvivalSystem.settings.bigRedButton {

		let fatigueAdded: Float = this.calculatedParameters[this.m_hoursToSkip].X - this.SurvivalSystem.GetFatigueCurrent();
		let hungerAdded: Float = this.calculatedParameters[this.m_hoursToSkip].Y - this.SurvivalSystem.GetHungerCurrent();
		let thirstAdded: Float = this.calculatedParameters[this.m_hoursToSkip].Z - this.SurvivalSystem.GetThirstCurrent();

		this.fatigueBar.SetCurrent(this.SurvivalSystem.GetFatigueCurrent());
		this.hungerBar.SetCurrent(this.SurvivalSystem.GetHungerCurrent());
		this.thirstBar.SetCurrent(this.SurvivalSystem.GetThirstCurrent());

		this.fatigueBar.SetFuture(fatigueAdded);
		this.hungerBar.SetFuture(hungerAdded);
		this.thirstBar.SetFuture(thirstAdded);

	} else {

		this.fatigueBar.SetCurrent(this.SurvivalSystem.GetFatigueCurrent());
		this.hungerBar.SetCurrent(this.SurvivalSystem.GetHungerCurrent());
		this.thirstBar.SetCurrent(this.SurvivalSystem.GetThirstCurrent());
	};
}

@addMethod(TimeskipGameController)
private final func RefreshInfoWidget() -> Void {

	let stress: Float = AbsF(this.calculatedParameters[this.m_hoursToSkip].W);
	let fatigue: Float = AbsF(this.calculatedParameters[this.m_hoursToSkip].X - this.SurvivalSystem.GetFatigueCurrent());
	let hunger: Float = AbsF(this.calculatedParameters[this.m_hoursToSkip].Y - this.SurvivalSystem.GetHungerCurrent());
	let thirst: Float = AbsF(this.calculatedParameters[this.m_hoursToSkip].Z - this.SurvivalSystem.GetThirstCurrent());
	
	let stressStr: String = GetLocalizedTextByKey(n"SSTimeSkipStressLevelName");
	let fatigueStr: String = GetLocalizedTextByKey(n"SSTimeSkipFatigueRestName");
	let hungerStr: String = GetLocalizedTextByKey(n"SSTimeSkipHungerLossName");
	let thirstStr: String = GetLocalizedTextByKey(n"SSTimeSkipThirstLossName");

	if !this.SurvivalSystem.settings.bigRedButton {

		if this.sleepInCar {

			this.infoTitle.SetText(GetLocalizedTextByKey(n"SSRestInCarName"));

		} else {

			if this.sleepInBed {

				this.infoTitle.SetText(GetLocalizedTextByKey(n"SSRestInBedName"));

			} else {

				this.infoTitle.SetText(GetLocalizedTextByKey(n"SSTimeSkipName"));

				fatigueStr = GetLocalizedTextByKey(n"SSTimeSkipFatigueLossName");
			};
		};

		stressStr = StrReplace(stressStr, "{float_0}", ToString(stress != 1.0 ? FloatToStringPrec(stress, 1) : "1.0"));
		fatigueStr = StrReplace(fatigueStr, "{float_0}", ToString(FloatToStringPrec(fatigue, 1)));
		hungerStr = StrReplace(hungerStr, "{float_0}", ToString(FloatToStringPrec(hunger, 1)));
		thirstStr = StrReplace(thirstStr, "{float_0}", ToString(FloatToStringPrec(thirst, 1)));

		this.infoDesc.SetText(s"\(stressStr)\n\(fatigueStr)\n\(hungerStr)\n\(thirstStr)");
	};
}