// V17

module OdoHUD

// ============================================================================
// VehicleMileage World Entity Leaderboard
// Looks for an existing worlduiWidgetComponent named "vm_odometer_lb"
// and draws the VehicleMileage TOP 10 leaderboard on it.
//
// Required in WolvenKit:
// - worlduiWidgetComponent name: vm_odometer_lb
// - widgetResource: OdoHUD\hud\leaderboard.inkwidget
// - DynamicWidgetController on leaderboard.inkwidget: OdoHUD.inkLeaderboard
// ============================================================================


// ============================================================================
// Lua -> Redscript bridge storage
// Lua fills these rows through UISystem:VM_WorldLB_Clear / VM_WorldLB_SetRow
// ============================================================================

@addField(UISystem)
public let vmWorldLBRow1: String;

@addField(UISystem)
public let vmWorldLBRow2: String;

@addField(UISystem)
public let vmWorldLBRow3: String;

@addField(UISystem)
public let vmWorldLBRow4: String;

@addField(UISystem)
public let vmWorldLBRow5: String;

@addField(UISystem)
public let vmWorldLBRow6: String;

@addField(UISystem)
public let vmWorldLBRow7: String;

@addField(UISystem)
public let vmWorldLBRow8: String;

@addField(UISystem)
public let vmWorldLBRow9: String;

@addField(UISystem)
public let vmWorldLBRow10: String;

@addMethod(UISystem)
public func VM_WorldLB_Clear() -> Void {
  this.vmWorldLBRow1 = "";
  this.vmWorldLBRow2 = "";
  this.vmWorldLBRow3 = "";
  this.vmWorldLBRow4 = "";
  this.vmWorldLBRow5 = "";
  this.vmWorldLBRow6 = "";
  this.vmWorldLBRow7 = "";
  this.vmWorldLBRow8 = "";
  this.vmWorldLBRow9 = "";
  this.vmWorldLBRow10 = "";
}

@addMethod(UISystem)
public func VM_WorldLB_SetRow(index1: Int32, name: String, km: String) -> Void {
  let line: String = IntToString(index1) + ". " + name + " - " + km;

  if index1 == 1 {
    this.vmWorldLBRow1 = line;
  } else if index1 == 2 {
    this.vmWorldLBRow2 = line;
  } else if index1 == 3 {
    this.vmWorldLBRow3 = line;
  } else if index1 == 4 {
    this.vmWorldLBRow4 = line;
  } else if index1 == 5 {
    this.vmWorldLBRow5 = line;
  } else if index1 == 6 {
    this.vmWorldLBRow6 = line;
  } else if index1 == 7 {
    this.vmWorldLBRow7 = line;
  } else if index1 == 8 {
    this.vmWorldLBRow8 = line;
  } else if index1 == 9 {
    this.vmWorldLBRow9 = line;
  } else if index1 == 10 {
    this.vmWorldLBRow10 = line;
  };
}

@addMethod(UISystem)
public func VM_WorldLB_GetRow(index1: Int32) -> String {
  if index1 == 1 {
    return this.vmWorldLBRow1;
  } else if index1 == 2 {
    return this.vmWorldLBRow2;
  } else if index1 == 3 {
    return this.vmWorldLBRow3;
  } else if index1 == 4 {
    return this.vmWorldLBRow4;
  } else if index1 == 5 {
    return this.vmWorldLBRow5;
  } else if index1 == 6 {
    return this.vmWorldLBRow6;
  } else if index1 == 7 {
    return this.vmWorldLBRow7;
  } else if index1 == 8 {
    return this.vmWorldLBRow8;
  } else if index1 == 9 {
    return this.vmWorldLBRow9;
  } else if index1 == 10 {
    return this.vmWorldLBRow10;
  };

  return "";
}

// ============================================================================
// Runtime transform bridge for CET console testing
// Moves/scales the leaderboard content inside the world widget canvas.
// ============================================================================

@addField(UISystem)
public let vmWorldLBDx: Float;

@addField(UISystem)
public let vmWorldLBDy: Float;

@addField(UISystem)
public let vmWorldLBScaleMilli: Int32;

@addMethod(UISystem)
public func VM_WorldLB_SetOffset(dx: Float, dy: Float) -> Void {
  this.vmWorldLBDx = dx;
  this.vmWorldLBDy = dy;

 // LogChannel(
 //   n"DEBUG",
 //   "[VMWorldLeaderboard] Runtime offset set: dx="
 //   + FloatToString(dx)
 //   + " dy="
 //   + FloatToString(dy)
 // );
}

@addMethod(UISystem)
public func VM_WorldLB_SetScale(scaleMilli: Int32) -> Void {
  let s: Int32 = scaleMilli;

  if s < 1 {
    s = 1;
  };

  if s > 3000 {
    s = 3000;
  };

  this.vmWorldLBScaleMilli = s;

  //LogChannel(
  //  n"DEBUG",
  //  "[VMWorldLeaderboard] Runtime scale set: "
  //  + IntToString(s)
  //);
}

@addMethod(UISystem)
public func VM_WorldLB_SetTransform(dx: Float, dy: Float, scaleMilli: Int32) -> Void {
  this.VM_WorldLB_SetOffset(dx, dy);
  this.VM_WorldLB_SetScale(scaleMilli);
}

@addMethod(UISystem)
public func VM_WorldLB_ResetTransform() -> Void {
  this.vmWorldLBDx = 0.0;
  this.vmWorldLBDy = 0.0;
  this.vmWorldLBScaleMilli = 1000;

  // LogChannel(n"DEBUG", "[VMWorldLeaderboard] Runtime transform reset.");
}

// ============================================================================
// Global 3D World style/config bridge
// Lua writes these from the CET "3D World" tab.
// ============================================================================

@addField(UISystem)
public let vmWorldConfigReady: Bool;

// Leaderboard style
@addField(UISystem)
public let vmWorldLBTheme: Int32;

@addField(UISystem)
public let vmWorldLBFontIndex: Int32;

@addField(UISystem)
public let vmWorldLBFontSize: Int32;

@addField(UISystem)
public let vmWorldLBBrightnessMilli: Int32;

@addField(UISystem)
public let vmWorldLBBorderHidden: Bool;

@addField(UISystem)
public let vmWorldLBHidden: Bool;

// Aux 1
@addField(UISystem)
public let vmWorldAux1Theme: Int32;

@addField(UISystem)
public let vmWorldAux1FontIndex: Int32;

@addField(UISystem)
public let vmWorldAux1FontSize: Int32;

@addField(UISystem)
public let vmWorldAux1BrightnessMilli: Int32;

@addField(UISystem)
public let vmWorldAux1Dx: Float;

@addField(UISystem)
public let vmWorldAux1Dy: Float;

@addField(UISystem)
public let vmWorldAux1ScaleMilli: Int32;

@addField(UISystem)
public let vmWorldAux1Shown: Bool;

// Aux 2
@addField(UISystem)
public let vmWorldAux2Theme: Int32;

@addField(UISystem)
public let vmWorldAux2FontIndex: Int32;

@addField(UISystem)
public let vmWorldAux2FontSize: Int32;

@addField(UISystem)
public let vmWorldAux2BrightnessMilli: Int32;

@addField(UISystem)
public let vmWorldAux2Dx: Float;

@addField(UISystem)
public let vmWorldAux2Dy: Float;

@addField(UISystem)
public let vmWorldAux2ScaleMilli: Int32;

@addField(UISystem)
public let vmWorldAux2Shown: Bool;

// Aux 3
@addField(UISystem)
public let vmWorldAux3Theme: Int32;

@addField(UISystem)
public let vmWorldAux3FontIndex: Int32;

@addField(UISystem)
public let vmWorldAux3FontSize: Int32;

@addField(UISystem)
public let vmWorldAux3BrightnessMilli: Int32;

@addField(UISystem)
public let vmWorldAux3Dx: Float;

@addField(UISystem)
public let vmWorldAux3Dy: Float;

@addField(UISystem)
public let vmWorldAux3ScaleMilli: Int32;

@addField(UISystem)
public let vmWorldAux3Shown: Bool;

// Aux dynamic text bridge.
// Lua/CET can write text here without touching style/position config.
@addField(UISystem)
public let vmWorldAux1Text: String;

@addField(UISystem)
public let vmWorldAux2Text: String;

@addField(UISystem)
public let vmWorldAux3Text: String;

@addMethod(UISystem)
public func VM_WorldLB_SetStyle(theme: Int32, fontIndex: Int32, fontSize: Int32, hidden: Bool, brightnessMilli: Int32, borderHidden: Bool) -> Void {
  this.vmWorldConfigReady = true;

  this.vmWorldLBTheme = theme;
  this.vmWorldLBFontIndex = fontIndex;
  this.vmWorldLBFontSize = fontSize;
  this.vmWorldLBHidden = hidden;
  this.vmWorldLBBrightnessMilli = brightnessMilli;
  this.vmWorldLBBorderHidden = borderHidden;
}

@addMethod(UISystem)
public func VM_WorldAux_SetConfig(index1: Int32, theme: Int32, fontIndex: Int32, fontSize: Int32, dx: Float, dy: Float, scaleMilli: Int32, shown: Bool, brightnessMilli: Int32) -> Void {
  this.vmWorldConfigReady = true;

  if index1 == 1 {
    this.vmWorldAux1Theme = theme;
    this.vmWorldAux1FontIndex = fontIndex;
		this.vmWorldAux1FontSize = fontSize;
		this.vmWorldAux1BrightnessMilli = brightnessMilli;
		this.vmWorldAux1Dx = dx;
    this.vmWorldAux1Dy = dy;
    this.vmWorldAux1ScaleMilli = scaleMilli;
    this.vmWorldAux1Shown = shown;
  } else if index1 == 2 {
    this.vmWorldAux2Theme = theme;
    this.vmWorldAux2FontIndex = fontIndex;
		this.vmWorldAux2FontSize = fontSize;
		this.vmWorldAux2BrightnessMilli = brightnessMilli;
		this.vmWorldAux2Dx = dx;
    this.vmWorldAux2Dy = dy;
    this.vmWorldAux2ScaleMilli = scaleMilli;
    this.vmWorldAux2Shown = shown;
  } else if index1 == 3 {
    this.vmWorldAux3Theme = theme;
    this.vmWorldAux3FontIndex = fontIndex;
		this.vmWorldAux3FontSize = fontSize;
		this.vmWorldAux3BrightnessMilli = brightnessMilli;
		this.vmWorldAux3Dx = dx;
    this.vmWorldAux3Dy = dy;
    this.vmWorldAux3ScaleMilli = scaleMilli;
    this.vmWorldAux3Shown = shown;
  };
}

@addMethod(UISystem)
public func VM_WorldAux_SetText(index1: Int32, text: String) -> Void {
  if index1 == 1 {
    this.vmWorldAux1Text = text;
  } else if index1 == 2 {
    this.vmWorldAux2Text = text;
  } else if index1 == 3 {
    this.vmWorldAux3Text = text;
  };
}

// ============================================================================
// New standalone world leaderboard controller
// This replaces the old inkOdoHUD usage for the world leaderboard.
// ============================================================================

public class inkLeaderboard extends inkGameController {
	private let root: wref<inkCompoundWidget>;
	private let lbRoot: wref<inkCanvas>;
	private let titleText: wref<inkText>;
	private let rowTexts: array<wref<inkText>>;

	private let aux1Text: wref<inkText>;
	private let aux2Text: wref<inkText>;
	private let aux3Text: wref<inkText>;

	// Global scale for the complete leaderboard.
	// 1000 = 100%
	// 800  = 80%
	// 1200 = 120%
	private let LB_SCALE_MILLI: Int32 = 1000;

  protected cb func OnInitialize() -> Void {
    let rootWidget: ref<inkCompoundWidget> = this.GetRootCompoundWidget();

    if !IsDefined(rootWidget) {
      return;
    };

    this.root = rootWidget;
    this.root.SetVisible(true);
    this.root.SetOpacity(1.0);

    this.HideTemplateChildren();
    this.EnsureLeaderboard();
    this.RefreshFromUISystem();
  }

  private func HideTemplateChildren() -> Void {
    if !IsDefined(this.root) {
      return;
    };

    let count: Int32 = this.root.GetNumChildren();
    let i: Int32 = 0;

    while i < count {
      let child: wref<inkWidget> = this.root.GetWidget(i);

      if IsDefined(child)
				&& !Equals(child.GetName(), n"VM_WorldLBRoot")
				&& !Equals(child.GetName(), n"aux1")
				&& !Equals(child.GetName(), n"aux2")
				&& !Equals(child.GetName(), n"aux3") {
        child.SetVisible(false);
        child.SetOpacity(0.0);
      };

      i += 1;
    };
  }

	public func VM_WorldLB_SetVisible(show: Bool) -> Void {
		// Keep the global world canvas root alive.
		// Individual visibility is still controlled by lbRoot / aux hidden settings.
		if IsDefined(this.root) {
			this.root.SetVisible(true);
			this.root.SetOpacity(1.0);
		};
	}

private func __ClampInt(v: Int32, minV: Int32, maxV: Int32) -> Int32 {
  if v < minV {
    return minV;
  };

  if v > maxV {
    return maxV;
  };

  return v;
}

private func __ThemeMainColor(theme: Int32) -> HDRColor {
  let c: HDRColor;

  if theme == 1 {
    c.Red = 1.00; c.Green = 0.78; c.Blue = 0.00;
  } else if theme == 2 {
    c.Red = 0.58; c.Green = 0.72; c.Blue = 0.69;
  } else if theme == 3 {
    c.Red = 1.00; c.Green = 0.20; c.Blue = 0.85;
  } else if theme == 4 {
    c.Red = 0.15; c.Green = 0.35; c.Blue = 1.00;
  } else if theme == 5 {
    c.Red = 0.50; c.Green = 0.90; c.Blue = 1.00;
  } else if theme == 6 {
    c.Red = 0.25; c.Green = 1.00; c.Blue = 0.25;
  } else if theme == 7 {
    c.Red = 0.85; c.Green = 0.90; c.Blue = 0.95;
  } else if theme == 8 {
    c.Red = 1.00; c.Green = 0.62; c.Blue = 0.08;
  } else if theme == 9 {
    c.Red = 1.00; c.Green = 1.00; c.Blue = 0.00;
  } else {
    c.Red = 0.35; c.Green = 0.95; c.Blue = 1.00;
  };

  c.Alpha = 1.0;
  return c;
}

private func __ApplyBrightness(color: HDRColor, brightnessMilli: Int32) -> HDRColor {
  let out: HDRColor = color;
  let b: Int32 = brightnessMilli;

  if b < 0 {
    b = 0;
  };

  if b > 3000 {
    b = 3000;
  };

  let mul: Float = Cast<Float>(b) / 1000.0;

  out.Red *= mul;
  out.Green *= mul;
  out.Blue *= mul;
  out.Alpha = color.Alpha;

  return out;
}

private func __FontFamilyFromIndex(idx: Int32) -> String {
  if idx == 1 {
    return "base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily";
  };

  if idx == 2 {
    return "base\\gameplay\\gui\\fonts\\foreign\\russian\\raj_rus.inkfontfamily";
  };

  if idx == 3 {
    return "base\\gameplay\\gui\\fonts\\industry\\industry.inkfontfamily";
  };

  if idx == 4 {
    return "engine\\ink\\fonts\\arial.inkfontfamily";
  };

  if idx == 5 {
    return "base\\gameplay\\gui\\fonts\\blender\\blender.inkfontfamily";
  };

  if idx == 6 {
    return "base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily";
  };

  if idx == 7 {
    return "base\\gameplay\\gui\\fonts\\foreign\\arabic\\ara_es_nawar\\ara_es_nawar.inkfontfamily";
  };

  if idx == 8 {
    return "base\\gameplay\\gui\\fonts\\foreign\\chinese_traditional\\jing_xi_heig_b5\\jing_xi_heig_b5.inkfontfamily";
  };

  if idx == 9 {
    return "base\\gameplay\\gui\\fonts\\foreign\\japanese\\mgenplus\\mgenplus.inkfontfamily";
  };

  if idx == 10 {
    return "base\\gameplay\\gui\\fonts\\foreign\\korean\\nanum_square\\nanum_square.inkfontfamily";
  };

  if idx == 11 {
    return "base\\gameplay\\gui\\fonts\\arame\\arame.inkfontfamily";
  };

  if idx == 12 {
    return "base\\gameplay\\gui\\fonts\\foreign\\japanese\\smart_font_ui\\smart_font_ui.inkfontfamily";
  };

  if idx == 13 {
    return "base\\gameplay\\gui\\fonts\\foreign\\thai\\printable4u\\printable4u.inkfontfamily";
  };

  return "base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily";
}


private func ApplyLeaderboardBorderVisibility(hidden: Bool) -> Void {
  if !IsDefined(this.lbRoot) {
    return;
  };

  let opacity: Float = hidden ? 0.0 : 0.95;

  let top = this.lbRoot.GetWidgetByPathName(n"VM_WorldLB_BorderTop");
  if IsDefined(top) {
    top.SetVisible(!hidden);
    top.SetOpacity(opacity);
  };

  let bottom = this.lbRoot.GetWidgetByPathName(n"VM_WorldLB_BorderBottom");
  if IsDefined(bottom) {
    bottom.SetVisible(!hidden);
    bottom.SetOpacity(opacity);
  };

  let left = this.lbRoot.GetWidgetByPathName(n"VM_WorldLB_BorderLeft");
  if IsDefined(left) {
    left.SetVisible(!hidden);
    left.SetOpacity(opacity);
  };

  let right = this.lbRoot.GetWidgetByPathName(n"VM_WorldLB_BorderRight");
  if IsDefined(right) {
    right.SetVisible(!hidden);
    right.SetOpacity(opacity);
  };
}

private func ApplyLeaderboardStyle() -> Void {
  if !IsDefined(this.lbRoot) {
    return;
  };

  let theme: Int32 = 0;
  let fontIndex: Int32 = 6;
	let fontSize: Int32 = 28;
	let brightnessMilli: Int32 = 1000;
	let borderHidden: Bool = false;
	let hidden: Bool = false;

  let ui = GameInstance.GetUISystem(GetGameInstance());

  if IsDefined(ui) && ui.vmWorldConfigReady {
    theme = ui.vmWorldLBTheme;
    fontIndex = ui.vmWorldLBFontIndex;
		fontSize = ui.vmWorldLBFontSize;
		brightnessMilli = ui.vmWorldLBBrightnessMilli;
		borderHidden = ui.vmWorldLBBorderHidden;
		hidden = ui.vmWorldLBHidden;
  };

  fontSize = this.__ClampInt(fontSize, 8, 120);

  let fontFamily: String = this.__FontFamilyFromIndex(fontIndex);
  let fontColor: HDRColor = this.__ApplyBrightness(this.__ThemeMainColor(theme), brightnessMilli);

  this.lbRoot.SetVisible(!hidden);
  this.lbRoot.SetOpacity(hidden ? 0.0 : 1.0);
	this.ApplyLeaderboardBorderVisibility(borderHidden);

  if IsDefined(this.titleText) {
    this.titleText.SetFontFamily(fontFamily);
    this.titleText.SetFontSize(this.__ClampInt(fontSize + 14, 8, 140));
    this.titleText.SetTintColor(fontColor);
  };

  let i: Int32 = 0;

  while i < ArraySize(this.rowTexts) {
    let row = this.rowTexts[i];

    if IsDefined(row) {
      row.SetFontFamily(fontFamily);
      row.SetFontSize(fontSize);
      row.SetTintColor(fontColor);
    };

    i += 1;
  };
}

private func __ApplyAux(index1: Int32, txt: wref<inkText>) -> Void {
  if !IsDefined(txt) {
    return;
  };

  let theme: Int32 = 0;
  let fontIndex: Int32 = 6;
	let fontSize: Int32 = 32;
	let brightnessMilli: Int32 = 1000;
	let dx: Float = 0.0;
  let dy: Float = 0.0;
	let scaleMilli: Int32 = 1000;
	let shown: Bool = false;
	let displayText: String = "aux" + IntToString(index1);

  if index1 == 1 {
    dx = -360.0;
  } else if index1 == 3 {
    dx = 360.0;
  };

  let ui = GameInstance.GetUISystem(GetGameInstance());

  if IsDefined(ui) && ui.vmWorldConfigReady {
    if index1 == 1 {
      theme = ui.vmWorldAux1Theme;
      fontIndex = ui.vmWorldAux1FontIndex;
			fontSize = ui.vmWorldAux1FontSize;
			brightnessMilli = ui.vmWorldAux1BrightnessMilli;
			dx = ui.vmWorldAux1Dx;
      dy = ui.vmWorldAux1Dy;
      scaleMilli = ui.vmWorldAux1ScaleMilli;
      shown = ui.vmWorldAux1Shown;
    } else if index1 == 2 {
      theme = ui.vmWorldAux2Theme;
      fontIndex = ui.vmWorldAux2FontIndex;
			fontSize = ui.vmWorldAux2FontSize;
			brightnessMilli = ui.vmWorldAux2BrightnessMilli;
			dx = ui.vmWorldAux2Dx;
      dy = ui.vmWorldAux2Dy;
      scaleMilli = ui.vmWorldAux2ScaleMilli;
      shown = ui.vmWorldAux2Shown;
    } else if index1 == 3 {
      theme = ui.vmWorldAux3Theme;
      fontIndex = ui.vmWorldAux3FontIndex;
			fontSize = ui.vmWorldAux3FontSize;
			brightnessMilli = ui.vmWorldAux3BrightnessMilli;
			dx = ui.vmWorldAux3Dx;
      dy = ui.vmWorldAux3Dy;
      scaleMilli = ui.vmWorldAux3ScaleMilli;
      shown = ui.vmWorldAux3Shown;
    };
  };

	if IsDefined(ui) {
		if index1 == 1 && !Equals(ui.vmWorldAux1Text, "") {
			displayText = ui.vmWorldAux1Text;
		} else if index1 == 2 && !Equals(ui.vmWorldAux2Text, "") {
			displayText = ui.vmWorldAux2Text;
		} else if index1 == 3 && !Equals(ui.vmWorldAux3Text, "") {
			displayText = ui.vmWorldAux3Text;
		};
	};

  fontSize = this.__ClampInt(fontSize, 8, 120);
  scaleMilli = this.__ClampInt(scaleMilli, 1, 3000);

  let scale: Float = Cast<Float>(scaleMilli) / 1000.0;

	txt.SetText(displayText);
	txt.SetVisible(shown);
	txt.SetOpacity(shown ? 1.0 : 0.0);
  txt.SetFontFamily(this.__FontFamilyFromIndex(fontIndex));
  txt.SetFontSize(fontSize);
  txt.SetTintColor(this.__ApplyBrightness(this.__ThemeMainColor(theme), brightnessMilli));
  txt.SetTranslation(new Vector2(dx, dy));
  txt.SetRenderTransformPivot(new Vector2(0.5, 0.5));
  txt.SetScale(new Vector2(scale, scale));
}

private func ApplyAuxTexts() -> Void {
  this.__ApplyAux(1, this.aux1Text);
  this.__ApplyAux(2, this.aux2Text);
  this.__ApplyAux(3, this.aux3Text);
}

private func EnsureAuxTexts() -> Void {
  if !IsDefined(this.root) {
    return;
  };

  let a1: ref<inkText> = this.root.GetWidgetByPathName(n"aux1") as inkText;

  if !IsDefined(a1) {
    a1 = new inkText();
    a1.SetName(n"aux1");
    a1.SetText("aux1");
    a1.SetLetterCase(textLetterCase.OriginalCase);
    a1.SetAnchor(inkEAnchor.Centered);
    a1.SetAnchorPoint(new Vector2(0.5, 0.5));
    a1.Reparent(this.root);
  };

  this.aux1Text = a1;

  let a2: ref<inkText> = this.root.GetWidgetByPathName(n"aux2") as inkText;

  if !IsDefined(a2) {
    a2 = new inkText();
    a2.SetName(n"aux2");
    a2.SetText("aux2");
    a2.SetLetterCase(textLetterCase.OriginalCase);
    a2.SetAnchor(inkEAnchor.Centered);
    a2.SetAnchorPoint(new Vector2(0.5, 0.5));
    a2.Reparent(this.root);
  };

  this.aux2Text = a2;

  let a3: ref<inkText> = this.root.GetWidgetByPathName(n"aux3") as inkText;

  if !IsDefined(a3) {
    a3 = new inkText();
    a3.SetName(n"aux3");
    a3.SetText("aux3");
    a3.SetLetterCase(textLetterCase.OriginalCase);
    a3.SetAnchor(inkEAnchor.Centered);
    a3.SetAnchorPoint(new Vector2(0.5, 0.5));
    a3.Reparent(this.root);
  };

  this.aux3Text = a3;

  this.ApplyAuxTexts();
}

	private func ApplyLeaderboardScale() -> Void {
		if !IsDefined(this.lbRoot) {
			return;
		};

		let dx: Float = 0.0;
		let dy: Float = 0.0;
		let scaleMilli: Int32 = this.LB_SCALE_MILLI;

		let ui = GameInstance.GetUISystem(GetGameInstance());

		if IsDefined(ui) {
			dx = ui.vmWorldLBDx;
			dy = ui.vmWorldLBDy;

			if ui.vmWorldLBScaleMilli > 0 {
				scaleMilli = ui.vmWorldLBScaleMilli;
			};
		};

		if scaleMilli < 1 {
			scaleMilli = 1;
		};

		if scaleMilli > 3000 {
			scaleMilli = 3000;
		};

		let scale: Float = Cast<Float>(scaleMilli) / 1000.0;

		this.lbRoot.SetRenderTransformPivot(new Vector2(0.5, 0.5));
		this.lbRoot.SetTranslation(new Vector2(dx, dy));
		this.lbRoot.SetScale(new Vector2(scale, scale));
	}

	private func EnsureLeaderboard() -> Void {
    if !IsDefined(this.root) {
      return;
    };

	let existing: ref<inkCanvas> = this.root.GetWidgetByPathName(n"VM_WorldLBRoot") as inkCanvas;

	if IsDefined(existing) {
		this.lbRoot = existing;
		this.EnsureAuxTexts();
		this.ApplyLeaderboardScale();
		this.ApplyLeaderboardStyle();
		this.ApplyAuxTexts();
		return;
	};

    ArrayClear(this.rowTexts);

    let cyan: HDRColor;
    cyan.Red = 0.35;
    cyan.Green = 0.95;
    cyan.Blue = 1.00;
    cyan.Alpha = 1.0;

    let white: HDRColor;
    white.Red = 0.92;
    white.Green = 0.95;
    white.Blue = 0.98;
    white.Alpha = 1.0;

    let dark: HDRColor;
    dark.Red = 0.02;
    dark.Green = 0.04;
    dark.Blue = 0.05;
    dark.Alpha = 1.0;

		let lb: ref<inkCanvas> = new inkCanvas();
		lb.SetName(n"VM_WorldLBRoot");
		lb.SetInteractive(false);
		lb.SetFitToContent(false);
		lb.SetSize(new Vector2(1150.0, 680.0));
		lb.SetAnchor(inkEAnchor.Centered);
		lb.SetAnchorPoint(new Vector2(0.5, 0.5));
		lb.SetRenderTransformPivot(new Vector2(0.5, 0.5));
		lb.Reparent(this.root);
		this.lbRoot = lb;

		this.ApplyLeaderboardScale();

    // Main background only.
    // Row backgrounds were removed to avoid the white/bright row blocks.
    let bg: ref<inkRectangle> = new inkRectangle();
    bg.SetName(n"VM_WorldLB_BG");
    bg.SetSize(new Vector2(1150.0, 680.0));
    bg.SetAnchor(inkEAnchor.Centered);
    bg.SetAnchorPoint(new Vector2(0.5, 0.5));
    bg.SetTintColor(dark);
    bg.SetOpacity(0.55);
    bg.Reparent(lb);
		
		// Border around the leaderboard content only.
		// Parent is lb / VM_WorldLBRoot, NOT the whole widget canvas.
		let borderSize: Float = 4.0;

		let borderTop: ref<inkRectangle> = new inkRectangle();
		borderTop.SetName(n"VM_WorldLB_BorderTop");
		borderTop.SetSize(new Vector2(1150.0, borderSize));
		borderTop.SetAnchor(inkEAnchor.Centered);
		borderTop.SetAnchorPoint(new Vector2(0.5, 0.5));
		borderTop.SetTranslation(new Vector2(0.0, -340.0 + (borderSize * 0.5)));
		borderTop.SetTintColor(cyan);
		borderTop.SetOpacity(0.95);
		borderTop.Reparent(lb);

		let borderBottom: ref<inkRectangle> = new inkRectangle();
		borderBottom.SetName(n"VM_WorldLB_BorderBottom");
		borderBottom.SetSize(new Vector2(1150.0, borderSize));
		borderBottom.SetAnchor(inkEAnchor.Centered);
		borderBottom.SetAnchorPoint(new Vector2(0.5, 0.5));
		borderBottom.SetTranslation(new Vector2(0.0, 340.0 - (borderSize * 0.5)));
		borderBottom.SetTintColor(cyan);
		borderBottom.SetOpacity(0.95);
		borderBottom.Reparent(lb);

		let borderLeft: ref<inkRectangle> = new inkRectangle();
		borderLeft.SetName(n"VM_WorldLB_BorderLeft");
		borderLeft.SetSize(new Vector2(borderSize, 680.0));
		borderLeft.SetAnchor(inkEAnchor.Centered);
		borderLeft.SetAnchorPoint(new Vector2(0.5, 0.5));
		borderLeft.SetTranslation(new Vector2(-575.0 + (borderSize * 0.5), 0.0));
		borderLeft.SetTintColor(cyan);
		borderLeft.SetOpacity(0.95);
		borderLeft.Reparent(lb);

		let borderRight: ref<inkRectangle> = new inkRectangle();
		borderRight.SetName(n"VM_WorldLB_BorderRight");
		borderRight.SetSize(new Vector2(borderSize, 680.0));
		borderRight.SetAnchor(inkEAnchor.Centered);
		borderRight.SetAnchorPoint(new Vector2(0.5, 0.5));
		borderRight.SetTranslation(new Vector2(575.0 - (borderSize * 0.5), 0.0));
		borderRight.SetTintColor(cyan);
		borderRight.SetOpacity(0.95);
		borderRight.Reparent(lb);

    let title: ref<inkText> = new inkText();
    title.SetName(n"VM_WorldLB_Title");
    title.SetText("ODO TOP 10");
    title.SetFontFamily("base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily");
    title.SetFontSize(42);
    title.SetTintColor(cyan);
    title.SetLetterCase(textLetterCase.OriginalCase);
    title.SetAnchor(inkEAnchor.TopLeft);
    title.SetAnchorPoint(new Vector2(0.0, 0.0));
    title.SetTranslation(new Vector2(42.0, 32.0));
    title.Reparent(lb);
		this.titleText = title;

    let i: Int32 = 0;

    while i < 10 {
      let txt: ref<inkText> = new inkText();
      txt.SetName(StringToName("VM_WorldLB_RowText_" + IntToString(i + 1)));
      txt.SetText(IntToString(i + 1) + ". ---");
      txt.SetFontFamily("base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily");
      txt.SetFontSize(28);
      txt.SetTintColor(white);
      txt.SetLetterCase(textLetterCase.OriginalCase);
      txt.SetAnchor(inkEAnchor.TopLeft);
      txt.SetAnchorPoint(new Vector2(0.0, 0.0));
      txt.SetTranslation(new Vector2(42.0, 105.0 + Cast<Float>(i) * 52.0));
      txt.Reparent(lb);

      ArrayPush(this.rowTexts, txt);

      i += 1;
    };

    this.EnsureAuxTexts();
    this.ApplyLeaderboardScale();
    this.ApplyLeaderboardStyle();
    this.ApplyAuxTexts();
  }

	public func RefreshFromUISystem() -> Void {
		this.EnsureLeaderboard();

		// Apply live CET / vm_settings.json config.
		this.ApplyLeaderboardScale();
		this.ApplyLeaderboardStyle();
		this.ApplyAuxTexts();

		if ArraySize(this.rowTexts) <= 0 {
			return;
		};

    let ui = GameInstance.GetUISystem(GetGameInstance());

    if !IsDefined(ui) {
      return;
    };

    let i: Int32 = 1;

    while i <= 10 {
      let line: String = ui.VM_WorldLB_GetRow(i);

      if Equals(line, "") {
        line = IntToString(i) + ". ---";
      };

      let row: wref<inkText> = this.rowTexts[i - 1];

      if IsDefined(row) {
        row.SetText(line);
      };

      i += 1;
    };
  }
}


// ============================================================================
// Tick callback
// ============================================================================

private class VMWorldLeaderboardTick extends DelayCallback {
  private let svc: wref<VMWorldLeaderboardService>;
  private let token: Int32;

  public static func Create(svc: ref<VMWorldLeaderboardService>, token: Int32) -> ref<VMWorldLeaderboardTick> {
    let self = new VMWorldLeaderboardTick();
    self.svc = svc;
    self.token = token;
    return self;
  }

  public func Call() -> Void {
    if IsDefined(this.svc) {
      if this.token != this.svc.tickToken {
        return;
      };

      this.svc.tickArmed = false;
      this.svc.Tick();
    };
  }
}


// ============================================================================
// Service
// ============================================================================

@addField(UISystem)
public let vmWorldLeaderboardSvc: wref<IScriptable>;

public class VMWorldLeaderboardService extends IScriptable {
	public let tickArmed: Bool;
	public let tickToken: Int32;

	private let tick: ref<VMWorldLeaderboardTick>;

	// Fast while using CET sliders.
	private let tickPeriodFast: Float = 0.25;

	// Slow normal idle refresh.
	private let tickPeriodSlow: Float = 5.0;

	private let fastTicksLeft: Int32;

  private let callbackSystem: wref<CallbackSystem>;
  private let registered: Bool;

	private let targetWidgets: array<wref<worlduiWidgetComponent>>;
	private let loggedReady: Bool;
	private let loggedControllerMissing: Bool;

  public func Start() -> Void {
    if !this.registered {
      this.callbackSystem = GameInstance.GetCallbackSystem();

      if IsDefined(this.callbackSystem) {
        this.callbackSystem.RegisterCallback(n"Entity/Assemble", this, n"OnEntityAssemble", true);

        this.registered = true;
        // LogChannel(n"DEBUG", "[VMWorldLeaderboard] Entity/Assemble callback registered.");
      };
    };

    let ui = GameInstance.GetUISystem(GetGameInstance());

		if IsDefined(ui) {
			ui.vmWorldLeaderboardSvc = this;
		};

		// Fast refresh shortly after startup / loading.
		this.RequestFastTicks(12);
  }

	private func EnsureWorldWidgetComponent(widget: wref<worlduiWidgetComponent>) -> Void {
		if !IsDefined(widget) {
			return;
		};

		// Important for standalone world canvases:
		// keep this component active even after mounting/unmounting vehicles.
		widget.isEnabled = true;
		widget.limitedSpawnDistanceFromVehicle = false;
		widget.sceneWidgetProperties.isAlwaysVisible = true;
		widget.sceneWidgetProperties.renderingPlane = ERenderingPlane.RPl_Scene;
		widget.sceneWidgetProperties.projectionPlaneSize.X = 1.0;
		widget.sceneWidgetProperties.projectionPlaneSize.Y = 1.0;
		widget.Toggle(true);
	}

	private func HasTargetWidget(widget: wref<worlduiWidgetComponent>) -> Bool {
		let i: Int32 = 0;

		while i < ArraySize(this.targetWidgets) {
			if this.targetWidgets[i] == widget {
				return true;
			};

			i += 1;
		};

		return false;
	}

  protected cb func OnEntityAssemble(event: ref<EntityLifecycleEvent>) -> Void {
    let ent = event.GetEntity();

    if !IsDefined(ent) {
      return;
    };

		let widget = ent.FindComponentByName(n"vm_odometer_lb") as worlduiWidgetComponent;

		if !IsDefined(widget) {
			return;
		};

		this.EnsureWorldWidgetComponent(widget);

		if !this.HasTargetWidget(widget) {
			ArrayPush(this.targetWidgets, widget);

			//LogChannel(
			//	n"DEBUG",
			//	"[VMWorldLeaderboard] Found world widget: vm_odometer_lb | total="
			//	+ IntToString(ArraySize(this.targetWidgets))
			//);
		};

		this.loggedReady = false;
		this.loggedControllerMissing = false;

		// New widget found -> refresh fast for a few ticks.
		this.RequestFastTicks(12);
  }

	public func RequestFastTicks(ticks: Int32) -> Void {
		let n: Int32 = ticks;

		if n < 1 {
			n = 1;
		};

		if n > 80 {
			n = 80;
		};

		if n > this.fastTicksLeft {
			this.fastTicksLeft = n;
		};

		// Cancel the currently scheduled slow tick logically.
		// The old callback may still fire later, but its token will be outdated.
		if this.tickArmed {
			this.tickToken += 1;
			this.tickArmed = false;
		};

		// Wake almost immediately.
		this.ArmTick(0.01);
	}

	public func Tick() -> Void {
		if ArraySize(this.targetWidgets) <= 0 {
			this.ArmTick(this.tickPeriodSlow);
			return;
		};

		let i: Int32 = 0;

		while i < ArraySize(this.targetWidgets) {
			let widget = this.targetWidgets[i];

			if IsDefined(widget) {
				this.EnsureWorldWidgetComponent(widget);

				let lb = widget.GetGameController() as inkLeaderboard;

				if IsDefined(lb) {
					if !this.loggedReady {
						// LogChannel(n"DEBUG", "[VMWorldLeaderboard] Controller ready. Drawing TOP 10 leaderboard.");
						this.loggedReady = true;
					};

					lb.VM_WorldLB_SetVisible(true);
					lb.RefreshFromUISystem();
				} else {
					if !this.loggedControllerMissing {
						// LogChannel(n"DEBUG", "[VMWorldLeaderboard] Controller is NULL on at least one board.");
						// LogChannel(n"DEBUG", "[VMWorldLeaderboard] Check DynamicWidgetController: OdoHUD.inkLeaderboard");
						// LogChannel(n"DEBUG", "[VMWorldLeaderboard] Check widgetResource: OdoHUD\\hud\\leaderboard.inkwidget");
						this.loggedControllerMissing = true;
					};
				};
			};

			i += 1;
		};

		let nextPeriod: Float = this.tickPeriodSlow;

		if this.fastTicksLeft > 0 {
			nextPeriod = this.tickPeriodFast;
			this.fastTicksLeft -= 1;
		};

		this.ArmTick(nextPeriod);
	}

	private func ArmTick(period: Float) -> Void {
		if this.tickArmed {
			return;
		};

		let ds = GameInstance.GetDelaySystem(GetGameInstance());

		if !IsDefined(ds) {
			return;
		};

		this.tickToken += 1;
		this.tick = VMWorldLeaderboardTick.Create(this, this.tickToken);
		this.tickArmed = true;

		ds.DelayCallback(this.tick, period, false);
	}
}

@addMethod(UISystem)
public func VM_World_RequestFastTicks(ticks: Int32) -> Void {
  let svc = this.vmWorldLeaderboardSvc as VMWorldLeaderboardService;

  if IsDefined(svc) {
    svc.RequestFastTicks(ticks);
  };
}

// ============================================================================
// Start service after player control
// ============================================================================

@addField(PlayerPuppet)
private let vmWorldLeaderboardSvc: ref<VMWorldLeaderboardService>;

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(resolver: EntityResolveComponentsInterface) -> Bool {
  let r = wrappedMethod(resolver);

  if !IsDefined(this.vmWorldLeaderboardSvc) {
    this.vmWorldLeaderboardSvc = new VMWorldLeaderboardService();
  };

  this.vmWorldLeaderboardSvc.Start();

  return r;
}