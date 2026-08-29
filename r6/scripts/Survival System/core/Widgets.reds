module SurvivalSystemModule


// Универсальный прогресс бар

public final class inkSurvivalBar extends inkCanvas {

	private let barProgress: wref<inkRectangle>;
	private let barTemp: wref<inkRectangle>;

	private let currentValue: Float;
	private let barWidth: Float;
	private let barStep: Float;

	public final func Initialize(parent: ref<inkCompoundWidget>, size: Vector2, value: Float) -> Void {

		let tempSize = new Vector2(size.X < 14.0 ? 14.0 : size.X, size.Y < 14.0 ? 14.0 : size.Y);
		
		this.barWidth = tempSize.X - 12.0;
		this.barStep = this.barWidth / 100.0;

		this.SetName(n"SurvivalBar");
		this.SetSize(tempSize);
		this.Reparent(parent);

		let background: ref<inkRectangle> = new inkRectangle();
		background.SetAnchor(inkEAnchor.Fill);
		background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		background.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		background.Reparent(this);

		let background: ref<inkRectangle> = new inkRectangle();
		background.SetAnchor(inkEAnchor.Fill);
		background.SetMargin(new inkMargin(2.0, 2.0, 2.0, 2.0));
		background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		background.BindProperty(n"tintColor", n"MainColors.FaintRed");
		background.Reparent(this);

		let horizontalPanel: ref<inkHorizontalPanel> = new inkHorizontalPanel();
		horizontalPanel.SetName(n"HorizontalPanel");
		horizontalPanel.SetAnchor(inkEAnchor.Fill);
		horizontalPanel.SetHAlign(inkEHorizontalAlign.Left);
		horizontalPanel.SetVAlign(inkEVerticalAlign.Fill);
		horizontalPanel.SetMargin(new inkMargin(6.0, 6.0, 6.0, 6.0));
		horizontalPanel.Reparent(this);

		let barProgress: ref<inkRectangle> = new inkRectangle();
		barProgress.SetName(n"ProgressCurrent");
		barProgress.Reparent(horizontalPanel);

		let barTemp: ref<inkRectangle> = new inkRectangle();
		barTemp.SetName(n"ProgressTemp");
		barTemp.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		barTemp.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
		barTemp.Reparent(horizontalPanel);

		this.barProgress = this.GetWidget(n"HorizontalPanel/ProgressCurrent") as inkRectangle;
		this.barTemp = this.GetWidget(n"HorizontalPanel/ProgressTemp") as inkRectangle;

		this.SetCurrent(value);
	}

	public final func SetCurrent(value: Float) -> Void {

		this.barProgress.SetWidth(ClampF(value * this.barStep, 0.0, this.barWidth));
		this.barTemp.SetWidth(0.0);
		
		this.SetProgressBarColor();
	}

	public final func SetFuture(value: Float) -> Void {

		if value < 0.0 {

			this.barTemp.SetWidth(ClampF(AbsF(value) * this.barStep, 0.0, this.barProgress.GetWidth()));
			this.barProgress.SetWidth(ClampF(this.barProgress.GetWidth() - this.barTemp.GetWidth(), 0.0, this.barWidth));
			this.barTemp.BindProperty(n"tintColor", n"MainColors.Yellow");

		} else {

			this.barTemp.SetWidth(ClampF(value * this.barStep, 0.0, this.barWidth - this.barProgress.GetWidth()));
			this.barTemp.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
		};
	}

	private final func SetProgressBarColor() -> Void {
	
		let progress: Float = this.barProgress.GetWidth() / this.barWidth;
		let color = new HDRColor(0.0, 0.0, 0.2, 1.0);

		color.Red = LerpF(progress * -1.0 + 1.0, 0.4, 1.0, true);
		color.Green = LerpF(progress, 0.2, 0.6, true);

		this.barProgress.SetTintColor(color);
	}
}


// Кнопка отчет боимонитора

public final class inkSurvivalButton extends inkCanvas {

	private let background: wref<inkImage>;
	private let border: wref<inkImage>;
	private let icon: wref<inkImage>;

	public final func Initialize(parent: ref<inkCompoundWidget>) -> Void {

		this.SetName(n"SurvivalButton");
		this.SetSize(new Vector2(595.0, 82.0));
		this.SetMargin(new inkMargin(2562.0, 404.0, 0.0, 0.0));
		this.SetInteractive(true);
		this.Reparent(parent);

		let background: ref<inkImage> = new inkImage();
		background.SetName(n"Background");
		background.SetAnchor(inkEAnchor.Centered);
		background.SetSize(new Vector2(82.0, 595.0));
		background.SetRotation(90.0);
		background.SetAnchorPoint(new Vector2(0.5, 0.5));
		background.SetAnchor(inkEAnchor.Centered);
		background.SetBrushMirrorType(inkBrushMirrorType.Both);
		background.SetBrushTileType(inkBrushTileType.NoTile);
		background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		background.BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");
		background.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		background.SetTexturePart(n"frame_large_bg");
		background.Reparent(this);

		let border: ref<inkImage> = new inkImage();
		border.SetName(n"Border");
		border.SetSize(new Vector2(82.0, 595.0));
		border.SetRotation(90.0);
		border.SetAnchorPoint(new Vector2(0.5, 0.5));
		border.SetAnchor(inkEAnchor.Centered);
		border.SetBrushMirrorType(inkBrushMirrorType.Both);
		border.SetBrushTileType(inkBrushTileType.NoTile);
		border.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		border.BindProperty(n"tintColor", n"MainColors.FaintRed");
		border.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		border.SetTexturePart(n"frame_large_fg");
		border.Reparent(this);

		let icon: ref<inkImage> = new inkImage();
		icon.SetName(n"Icon");
		icon.SetSize(new Vector2(350.0, 64.0));
		icon.SetAnchorPoint(new Vector2(0.5, 0.5));
		icon.SetAnchor(inkEAnchor.Centered);
		icon.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		icon.SetBrushTileType(inkBrushTileType.NoTile);
		icon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		icon.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		icon.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\q001_sandra.inkatlas");
		icon.SetTexturePart(n"Medtech_Logo");
		icon.Reparent(this);

		this.background = this.GetWidget(n"Background") as inkImage;
		this.border = this.GetWidget(n"Border") as inkImage;
		this.icon = this.GetWidget(n"Icon") as inkImage;
	}

	public final func ButtonHoverOver() -> Void {

		this.background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.background.BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");

		this.border.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.border.BindProperty(n"tintColor", n"MainColors.ActiveBlue");

		this.icon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.icon.BindProperty(n"tintColor", n"MainColors.ActiveRed");
	}

	public final func ButtonHoverOut() -> Void {

		this.background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.background.BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");

		this.border.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.border.BindProperty(n"tintColor", n"MainColors.FaintRed");

		this.icon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.icon.BindProperty(n"tintColor", n"MainColors.ActiveRed");
	}

	public final func ButtonRelease() -> Void {

		this.background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.background.BindProperty(n"tintColor", n"MainColors.FaintBlue");

		this.border.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.border.BindProperty(n"tintColor", n"MainColors.ActiveBlue");

		this.icon.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		this.icon.BindProperty(n"tintColor", n"MainColors.ActiveBlue");
	}

	public final func ButtonActive(active: Bool) -> Void {

		if active {

			this.icon.BindProperty(n"tintColor", n"MainColors.ActiveRed");

		} else {

			this.icon.BindProperty(n"tintColor", n"MainColors.FaintRed");
		};
	}
}


// Окно информации боимонитора

public final class inkSurvivalInfo extends inkCanvas {

	private let infoPanel: wref<inkVerticalPanel>;
	private let statusStrings: array<String>;

	public final func Initialize(parent: ref<inkCompoundWidget>) -> Void {

		this.SetName(n"SurvivalInfo");
		this.SetSize(new Vector2(2050.0, 852.0));
		this.SetMargin(new inkMargin(890.0, 580.0, 0.0, 0.0));
		this.SetVisible(false);
		this.Reparent(parent);

		let background: ref<inkImage> = new inkImage();
		background.SetAnchor(inkEAnchor.TopLeft);
		background.SetSize(new Vector2(2050.0, 852.0));
		background.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		background.SetBrushTileType(inkBrushTileType.NoTile);
		background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		background.BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");
		background.SetAtlasResource(r"base\\gameplay\\gui\\common\\tooltip\\tooltips_new.inkatlas");
		background.SetTexturePart(n"generic_background");
		background.Reparent(this);

		let background: ref<inkImage> = new inkImage();
		background.SetAnchor(inkEAnchor.TopLeft);
		background.SetSize(new Vector2(2050.0, 852.0));
		background.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		background.SetBrushTileType(inkBrushTileType.NoTile);
		background.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		background.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		background.SetAtlasResource(r"base\\gameplay\\gui\\common\\tooltip\\tooltips_new.inkatlas");
		background.SetTexturePart(n"generic_background_fg");
		background.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(166.0, 792.0));
		image.SetMargin(new inkMargin(20.0, 20.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.SupRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\sq021_farms_map.inkatlas");
		image.SetTexturePart(n"Frame_FG");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(162.0, 788.0));
		image.SetMargin(new inkMargin(22.0, 22.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.FaintRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\sq021_farms_map.inkatlas");
		image.SetTexturePart(n"Frame_FG");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(140.0, 35.0));
		image.SetMargin(new inkMargin(32.0, 34.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\q001_jackie.inkatlas");
		image.SetTexturePart(n"CC_Big");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(140.0, 140.0));
		image.SetMargin(new inkMargin(32.0, 88.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\personal_link.inkatlas");
		image.SetTexturePart(n"SYS 3-A44");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(140.0, 49.0));
		image.SetMargin(new inkMargin(32.0, 242.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\personal_link.inkatlas");
		image.SetTexturePart(n"protocol_icon_alone");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(176.0, 55.0));
		image.SetMargin(new inkMargin(206.0, 20.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\personal_link.inkatlas");
		image.SetTexturePart(n"medilineplus");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(639.0, 39.0));
		image.SetMargin(new inkMargin(206.0, 714.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\q000_jenkins_brief.inkatlas");
		image.SetTexturePart(n"Intro_fluff_01");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(723.0, 46.0));
		image.SetMargin(new inkMargin(206.0, 766.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\q115_lockdown.inkatlas");
		image.SetTexturePart(n"QR_bar_code");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(490.0, 72.0));
		image.SetMargin(new inkMargin(972.0, 739.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\personal_link.inkatlas");
		image.SetTexturePart(n"cctv_fluff");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(482.0, 664.0));
		image.SetMargin(new inkMargin(1516.0, 36.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\q000_jenkins_brief.inkatlas");
		image.SetTexturePart(n"tex_CARD-1");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(93.0, 93.0));
		image.SetMargin(new inkMargin(1516.0, 730.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\personal_link.inkatlas");
		image.SetTexturePart(n"A-A51_Icon");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(366.0, 93.0));
		image.SetMargin(new inkMargin(1632.0, 730.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.NoMirror);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\quests\\assets\\q001_jackie.inkatlas");
		image.SetTexturePart(n"WARNING_BLOCK");
		image.Reparent(this);

		let image: ref<inkImage> = new inkImage();
		image.SetAnchor(inkEAnchor.TopLeft);
		image.SetSize(new Vector2(134.0, 482.0));
		image.SetMargin(new inkMargin(2050.0, -92.0, 0.0, 0.0));
		image.SetBrushMirrorType(inkBrushMirrorType.Horizontal);
		image.SetBrushTileType(inkBrushTileType.NoTile);
		image.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		image.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		image.SetAtlasResource(r"base\\gameplay\\gui\\fullscreen\\perks\\atlas_perks_connections.inkatlas");
		image.SetTexturePart(n"connect13");
		image.Reparent(this);

		let label: ref<inkText> = new inkText();
		label.SetAnchor(inkEAnchor.TopLeft);
		label.SetMargin(new inkMargin(426.0, 20.0, 0.0, 0.0));
		label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		label.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		label.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		label.SetLetterCase(textLetterCase.UpperCase);
		label.SetFontSize(50);
		label.SetText(GetLocalizedTextByKey(n"SSInfoWidgetTitle"));
		label.Reparent(this);

		let infoPanel: ref<inkVerticalPanel> = new inkVerticalPanel();
		infoPanel.SetName(n"InfoPanel");
		infoPanel.SetSize(new Vector2(1100.0, 520.0));
		infoPanel.SetMargin(new inkMargin(264.0, 148.0, 0.0, 0.0));
		infoPanel.SetWidth(1116.0);
		infoPanel.SetFitToContent(false);
		infoPanel.Reparent(this);

		this.infoPanel = this.GetWidget(n"InfoPanel") as inkVerticalPanel;

		this.statusStrings = [

			GetLocalizedTextByKey(n"SSInfoWidgetString1"),
			GetLocalizedTextByKey(n"SSInfoWidgetString2"),
			GetLocalizedTextByKey(n"SSInfoWidgetString3"),
			GetLocalizedTextByKey(n"SSInfoWidgetString4"),
			GetLocalizedTextByKey(n"SSInfoWidgetString5"),
			GetLocalizedTextByKey(n"SSInfoWidgetString6"),
			GetLocalizedTextByKey(n"SSInfoWidgetString7"),
			GetLocalizedTextByKey(n"SSInfoWidgetString8"),
			GetLocalizedTextByKey(n"SSInfoWidgetString9")
		];
	}

	public final func ShowWidget(values: array<Float>) -> Void {

		this.infoPanel.RemoveAllChildren();

		let horizontalPanel: ref<inkHorizontalPanel> = new inkHorizontalPanel();
		horizontalPanel.SetMargin(new inkMargin(0.0, 0.0, 0.0, 8.0));
		horizontalPanel.Reparent(this.infoPanel);

		let label: ref<inkText> = new inkText();
		label.SetSizeRule(inkESizeRule.Stretch);
		label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		label.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		label.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		label.SetLetterCase(textLetterCase.UpperCase);
		label.SetFontSize(40);
		label.SetText(GetLocalizedTextByKey(n"SSInfoWidgetLabelLeft"));
		label.Reparent(horizontalPanel);

		let canvas: ref<inkCanvas> = new inkCanvas();
		canvas.SetAnchorPoint(1.0, 0.0);
		canvas.SetAnchor(inkEAnchor.TopRight);
		canvas.SetSize(new Vector2(240.0, 50.0));
		canvas.Reparent(horizontalPanel);

		let label: ref<inkText> = new inkText();
		label.SetAnchor(inkEAnchor.TopFillHorizontaly);
		label.SetHorizontalAlignment(textHorizontalAlignment.Center);
		label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		label.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
		label.BindProperty(n"tintColor", n"MainColors.ActiveRed");
		label.SetLetterCase(textLetterCase.UpperCase);
		label.SetFontSize(40);
		label.SetText(GetLocalizedTextByKey(n"SSInfoWidgetLabelRight"));
		label.Reparent(canvas);

		let i: Int32 = 0;

		while i < ArraySize(values) {
			
			let horizontalPanel: ref<inkHorizontalPanel> = new inkHorizontalPanel();
			horizontalPanel.Reparent(this.infoPanel);

			let text: ref<inkText> = new inkText();
			text.SetMargin(new inkMargin(60.0, 0.0, 0.0, 0.0));
			text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
			text.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
			text.BindProperty(n"tintColor", n"MainColors.ActiveRed");
			text.SetFontSize(38);
			text.SetText(this.statusStrings[i]);
			text.Reparent(horizontalPanel);

			let line: ref<inkRectangle> = new inkRectangle();
			line.SetSizeRule(inkESizeRule.Stretch);
			line.SetMargin(new inkMargin(8.0, 30.0, 8.0, 14.0));
			line.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
			line.BindProperty(n"tintColor", n"MainColors.SupRed");
			line.Reparent(horizontalPanel);

			let canvas: ref<inkCanvas> = new inkCanvas();
			canvas.SetMargin(new inkMargin(0.0, 0.0, 80.0, 0.0));
			canvas.SetSize(new Vector2(100.0, 48.0));
			canvas.Reparent(horizontalPanel);

			let value: ref<inkText> = new inkText();
			value.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
			value.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
			value.BindProperty(n"tintColor", n"MainColors.ActiveRed");
			value.SetFontSize(38);
			value.SetText(values[i] < 0.05 ? GetLocalizedTextByKey(n"SSInfoWidgetNormal") : s"\(FloatToStringPrec(values[i], 1))%");
			value.Reparent(canvas);

			i += 1;
		};

		this.SetVisible(true);
	}

	public final func HideWidget() -> Void {

		this.SetVisible(false);
	}
}