module OdoHUD
// V5
// ============================================================================
// VehicleMileage 3D ODO test
// ============================================================================


// ============================================================================
// Tick callback
// ============================================================================
private class VM3DOdoTick extends DelayCallback {
  private let svc: wref<VM3DOdoService>;

  public static func Create(svc: ref<VM3DOdoService>) -> ref<VM3DOdoTick> {
    let self = new VM3DOdoTick();
    self.svc = svc;
    return self;
  }

  public func Call() -> Void {
    if IsDefined(this.svc) {
      this.svc.tickArmed = false;
      this.svc.Tick();
    };
  }
}


// ============================================================================
// Helper: find wheel component by side
// ============================================================================
private class VM3DVehicleHelper {
  public static func GetWheelComponent(car: wref<WheeledObject>, side: CName) -> wref<PhysicalMeshComponent> {
    if !IsDefined(car) {
      return null;
    };

    let query: String = "";

    if Equals(side, n"FrontLeft") {
      query = "fl";
    } else if Equals(side, n"FrontRight") {
      query = "fr";
    } else if Equals(side, n"BackLeft") {
      query = "bl";
    } else if Equals(side, n"BackRight") {
      query = "br";
    };

    let components = car.GetComponents();

    for component in components {
      if IsDefined(component) {
        let physMesh = component as PhysicalMeshComponent;
        let name = NameToString(component.GetName());

        if IsDefined(physMesh) && StrContains(name, "odo") && StrContains(name, query) {
          return physMesh;
        };
      };
    };

    return null;
  }
}

// ============================================================================
// 3D mesh surface
// ============================================================================
private class VM3DOdoMeshComponent extends MeshComponent {
  private let PANEL_W: Float = 1.16;
  private let SIDE_EXTRA_OFFSET: Float = 1.20;
  private let PANEL_Z: Float = 0.18;

	private let placementMode: Int32; // 1 = fuel, 2 = ODO plate, 3 = fuel alt, 4 = ODO plate alt

	// Default ODO plate vertical offset when vm_3d_odo_z_cm is 0.
	// Positive magnitude only; the minus is applied at runtime.
	// Smaller value = ODO plate is higher / less far down.
	private let ODO_DEFAULT_Z_CM_MAG: Int32 = 15;

	public static func Create(id: CName, componentName: CName, mode: Int32) -> ref<VM3DOdoMeshComponent> {
		let self = new VM3DOdoMeshComponent();

		self.id = VM_GenerateCRUID(id);
		self.name = componentName;
		self.placementMode = mode;
    self.isEnabled = true;

    self.mesh *= r"OdoHUD\\hud\\odo.mesh";

    self.renderingPlane = ERenderingPlane.RPl_Scene;
    self.objectTypeID = ERenderObjectType.ROT_Vehicle;
    // Start hard-hidden. The service reveals this mesh only after the 3D
    // controller is ready, preventing a backing-material flash during power/UI changes.
    self.visualScale = Vector3(0.0, 0.0, 0.0);

    self.castShadows = shadowsShadowCastingMode.Never;
    self.castLocalShadows = shadowsShadowCastingMode.Never;
    self.castRayTracedGlobalShadows = shadowsShadowCastingMode.Never;
    self.castRayTracedLocalShadows = shadowsShadowCastingMode.Never;

    return self;
  }

  private func __Fact(name: CName) -> Int32 {
    let qs = GameInstance.GetQuestsSystem(GetGameInstance());
    if !IsDefined(qs) {
      return 0;
    };
    return qs.GetFact(name);
  }

	private func __ModeFact(fuelFact: CName, odoFact: CName, fuelAltFact: CName, odoAltFact: CName) -> Int32 {
		if this.placementMode == 1 {
			return this.__Fact(fuelFact);
		};

		if this.placementMode == 2 {
			return this.__Fact(odoFact);
		};

		if this.placementMode == 3 {
			return this.__Fact(fuelAltFact);
		};

		return this.__Fact(odoAltFact);
	}

	private func __IsHidden() -> Bool {
		let hidden: Int32 = this.__ModeFact(
			n"vm_3d_fuel_hidden",
			n"vm_3d_odo_hidden",
			n"vm_3d_fuel_alt_hidden",
			n"vm_3d_odo_alt_hidden"
		);

		return hidden > 0;
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

  private func __SideFromFact() -> CName {
    let side: Int32 = this.__ModeFact(n"vm_3d_fuel_side", n"vm_3d_odo_side", n"vm_3d_fuel_alt_side", n"vm_3d_odo_alt_side");

    if side == 1 {
      return n"BackRight";
    };
    if side == 2 {
      return n"FrontLeft";
    };
    if side == 3 {
      return n"FrontRight";
    };

    return n"BackLeft";
  }

	public func Load() -> Void {
		// Kept for compatibility with the original world-widget flow.
		// Real placement is applied from VM3DOdoService.Tick()
		// with the currently mounted vehicle.
	}

	public func VM_HardHide() -> Void {
		this.visualScale = Vector3(0.0, 0.0, 0.0);
	}

	public func ApplyLivePlacementFor(car: wref<WheeledObject>) -> Void {
		if !IsDefined(car) {
			return;
		};

		let side: CName = this.__SideFromFact();

		let outCm: Int32 = this.__ClampInt(this.__ModeFact(n"vm_3d_fuel_out_cm", n"vm_3d_odo_out_cm", n"vm_3d_fuel_alt_out_cm", n"vm_3d_odo_alt_out_cm"), -300, 300);
		let yCm: Int32 = this.__ClampInt(this.__ModeFact(n"vm_3d_fuel_y_cm", n"vm_3d_odo_y_cm", n"vm_3d_fuel_alt_y_cm", n"vm_3d_odo_alt_y_cm"), -300, 300);

		let zRaw: Int32 = this.__ModeFact(n"vm_3d_fuel_z_cm", n"vm_3d_odo_z_cm", n"vm_3d_fuel_alt_z_cm", n"vm_3d_odo_alt_z_cm");

		// Default: place ODO plate a bit lower than the fuel gauge.
		if (this.placementMode == 2 || this.placementMode == 4) && zRaw == 0 {
			zRaw = 0 - this.ODO_DEFAULT_Z_CM_MAG;
		};

		let zCm: Int32 = this.__ClampInt(zRaw, -200, 300);

		let rollDeg: Int32 = this.__ClampInt(this.__ModeFact(n"vm_3d_fuel_roll_deg", n"vm_3d_odo_roll_deg", n"vm_3d_fuel_alt_roll_deg", n"vm_3d_odo_alt_roll_deg"), -180, 180);
		let pitchDeg: Int32 = this.__ClampInt(this.__ModeFact(n"vm_3d_fuel_pitch_deg", n"vm_3d_odo_pitch_deg", n"vm_3d_fuel_alt_pitch_deg", n"vm_3d_odo_alt_pitch_deg"), -180, 180);
		let yawDeg: Int32 = this.__ClampInt(this.__ModeFact(n"vm_3d_fuel_yaw_deg", n"vm_3d_odo_yaw_deg", n"vm_3d_fuel_alt_yaw_deg", n"vm_3d_odo_alt_yaw_deg"), -180, 180);

		let scaleRaw: Int32 = this.__ModeFact(
			n"vm_3d_fuel_scale_milli",
			n"vm_3d_odo_scale_milli",
			n"vm_3d_fuel_alt_scale_milli",
			n"vm_3d_odo_alt_scale_milli"
		);

		// Runtime-only hide fix:
		// The saved user scale stays untouched.
		// But when the widget is hidden, the mesh plane is scaled to 0.
		// This removes the Path Tracing / Ray Tracing reflection from hidden widgets.
		if this.__Fact(n"vm_3d_enabled") <= 0 || this.__IsHidden() {
			this.visualScale = Vector3(0.0, 0.0, 0.0);
			return;
		};

		if scaleRaw <= 0 {
			scaleRaw = 600;
		};

		scaleRaw = this.__ClampInt(scaleRaw, 10, 2000);

		let outM: Float = Cast<Float>(outCm) / 100.0;
		let yM: Float = Cast<Float>(yCm) / 100.0;
		let zM: Float = Cast<Float>(zCm) / 100.0;

		let sideSign: Float = 1.0;
		if Equals(side, n"BackLeft") || Equals(side, n"FrontLeft") {
			sideSign = 0.0 - 1.0;
		};

		let baseY: Float = 0.0;
		if Equals(side, n"FrontLeft") || Equals(side, n"FrontRight") {
			baseY = 1.60;
		} else {
			baseY = 0.0 - 1.60;
		};

		let position: Vector4;
		position.X = sideSign * ((this.PANEL_W * 0.5) + this.SIDE_EXTRA_OFFSET + outM);
		position.Y = baseY + yM;
		position.Z = this.PANEL_Z + zM;
		position.W = 1.0;

		this.SetLocalPosition(position);

		let rot: EulerAngles;
		rot.Roll = Cast<Float>(rollDeg);
		rot.Pitch = Cast<Float>(pitchDeg);
		rot.Yaw = Cast<Float>(yawDeg);
		this.SetLocalOrientation(EulerAngles.ToQuat(rot));

		let sc: Float = Cast<Float>(scaleRaw) / 600.0;
		this.visualScale = Vector3(sc, sc, sc);

	}
}
// ============================================================================
// 3D widget binder
// ============================================================================
private class VM3DOdoWidgetComponent extends worlduiWidgetComponent {
	public static func Create(id: CName, componentName: CName, meshName: CName) -> ref<VM3DOdoWidgetComponent> {
		let self = new VM3DOdoWidgetComponent();

		self.id = VM_GenerateCRUID(id);
		self.name = componentName;
		self.isEnabled = true;

		self.meshTargetBinding = new worlduiMeshTargetBinding();
		self.meshTargetBinding.bindName = meshName;

    self.limitedSpawnDistanceFromVehicle = false;
    self.sceneWidgetProperties.isAlwaysVisible = true;
    self.sceneWidgetProperties.renderingPlane = ERenderingPlane.RPl_Scene;
    self.sceneWidgetProperties.projectionPlaneSize.X = 1.0;
    self.sceneWidgetProperties.projectionPlaneSize.Y = 1.0;

    self.widgetResource *= r"OdoHUD\\hud\\odo.inkwidget";

    return self;
  }



	public func GetHUD() -> wref<inkOdoHUD> {
		return this.GetGameController() as inkOdoHUD;
	}
	public func ApplyLivePlacementFromMesh(mesh: wref<VM3DOdoMeshComponent>) -> Void {
		if !IsDefined(mesh) {
			return;
		};

		this.SetLocalPosition(mesh.GetLocalPosition());
		this.SetLocalOrientation(mesh.GetLocalOrientation());
	}
}


// ============================================================================
// Displays VehicleMileage ODO on the 3D widget.
// ============================================================================
// ============================================================================
// Displays VehicleMileage fuel gauge + ODO on the 3D widget.
// ============================================================================
public class inkOdoHUD extends inkGameController {
  private let root: wref<inkCompoundWidget>;
  private let main: wref<inkCanvas>;
  private let arc: wref<inkCanvas>;
  private let needle: wref<inkCanvas>;
  private let odoText: wref<inkText>;
	private let pumpImg: wref<inkImage>;
	private let lblERef: wref<inkText>;
	private let lblFRef: wref<inkText>;
	// Theme refs
	private let fuelTickRefs: array<wref<inkRectangle>>;
	private let needleRectRef: wref<inkRectangle>;
	private let hubRef: wref<inkRectangle>;
	private let odoLabelRef: wref<inkText>;
	private let fuelBarTextRef: wref<inkText>;
	private let fuelBarBgRef: wref<inkRectangle>;
	private let fuelBarBorderTopRef: wref<inkRectangle>;
	private let fuelBarBorderBottomRef: wref<inkRectangle>;
	private let fuelBarBorderLeftRef: wref<inkRectangle>;
	private let fuelBarBorderRightRef: wref<inkRectangle>;
	private let themeLast: Int32;
	private let brightnessLast: Int32;
	private let fontLastIndex: Int32;
	private let fontLastScale: Int32;
	// Extra fuel style refs
	private let fuelBarWrap: wref<inkCanvas>;
	private let fuelBarFill: wref<inkRectangle>;
	private let fuelBarText: wref<inkText>;
	private let fuelDigitWrap: wref<inkCanvas>;
	private let fuelDigitText: wref<inkText>;
	// Fuel style 3: classic real-car needle gauge
	private let fuelClassicWrap: wref<inkCanvas>;
	private let classicTickRefs: array<wref<inkRectangle>>;
	private let classicNeedle: wref<inkCanvas>;
	private let classicNeedleRectRef: wref<inkRectangle>;
	private let classicHubRef: wref<inkRectangle>;
	private let classicPumpImg: wref<inkImage>;
	private let classicERef: wref<inkText>;
	private let classicFRef: wref<inkText>;
	// Fuel style 4: vertical segmented gauge
	private let fuelSegmentWrap: wref<inkCanvas>;
	private let segmentRefs: array<wref<inkRectangle>>;

	// Fuel style 5: pump icon only
	private let fuelPumpOnlyWrap: wref<inkCanvas>;
	private let pumpOnlyImg: wref<inkImage>;
	
	// 0 = full, 1 = fuel only, 2 = ODO plate only
	private let hudMode: Int32;

	// ODO plate refs
	private let odoWrap: wref<inkCanvas>;
  private let odoFill: wref<inkImage>;
  private let odoStroke: wref<inkImage>;

  private let lastFuelPermille: Int32;
  private let lastOdoText: String;

	// Geometry for 3D widget version.
	private let RIM_R: Float = 150.0;

	// Match the original FuelGauge shape better.
	// Original HUD used X 0.50 / Y 0.42.
	// Higher X = wider/flatter gauge.
	private let SCALE_X: Float = 0.50;
	private let SCALE_Y: Float = 0.42;

	private let DEG2RAD: Float = 0.0174532925;

  private let TICK_COUNT: Int32 = 13;
	// ODO plate layout
  private let ODO_W: Float = 260.0;
  private let ODO_H: Float = 66.0;
  private let ODO_PAD_L: Float = 22.0;
  private let ODO_PAD_R: Float = 24.0;

	// Pump icon layout.
	// Positive value = move pump UP. We apply the minus at runtime.
	private let PUMP_SIZE: Float = 54.0;
	private let PUMP_Y_UP: Float = 0.0;
	// E/F label layout.
	// Positive X distance from center. Runtime minus is used for E.
	private let LABEL_EF_X: Float = 75.0;
	private let LABEL_EF_Y: Float = 25.0;
	// Needle layout.
	// Bigger ND_LEN = longer needle.
	private let ND_W: Float = 16.0;
	private let ND_LEN: Float = 138.0;
	// Fuel style switch:
	// vm_3d_fuel_style
	// 0 = arc gauge
	// 1 = progress bar
	// 2 = digits only
	private let BAR_W: Float = 220.0;
	private let BAR_H: Float = 42.0;
	private let BAR_Y: Float = 0.0;

	// Progress bar frame / inner padding
	private let BAR_PAD: Float = 5.0;
	private let BAR_BORDER: Float = 3.0;
	private let BAR_LABEL_SIZE: Int32 = 26;

	private let DIGIT_Y: Float = 0.0;
	private let DIGIT_FONT_SIZE: Int32 = 62;
	// Fuel style 3: classic needle gauge
	// Positive values only. Negative placement is applied at runtime.
	private let CLASSIC_TICK_COUNT: Int32 = 9;
	private let CLASSIC_R: Float = 145.0;
	private let CLASSIC_START_DEG: Float = 150.0;
	private let CLASSIC_SWEEP_DEG: Float = 165.0;

	private let CLASSIC_PIVOT_X_MAG: Float = 70.0;
	private let CLASSIC_PIVOT_Y: Float = 82.0;

	private let CLASSIC_ND_W: Float = 11.0;
	private let CLASSIC_ND_LEN: Float = 165.0;
	private let CLASSIC_HUB_SIZE: Float = 30.0;

	private let CLASSIC_PUMP_SIZE: Float = 68.0;
	private let CLASSIC_PUMP_X: Float = 18.0;
	private let CLASSIC_PUMP_Y: Float = 15.0;

	private let CLASSIC_LABEL_F_X_MAG: Float = 112.0;
	private let CLASSIC_LABEL_F_Y_MAG: Float = 44.0;
	private let CLASSIC_LABEL_E_X: Float = 118.0;
	private let CLASSIC_LABEL_E_Y: Float = 86.0;
	
	// Fuel style 4: vertical segmented gauge
	private let SEG_COUNT: Int32 = 10;
	private let SEG_W: Float = 54.0;
	private let SEG_H: Float = 16.0;
	private let SEG_GAP: Float = 6.0;

	// Fuel style 5: pump icon only
	private let PUMP_ONLY_SIZE: Float = 92.0;
	private let PUMP_ONLY_X: Float = 0.0;
	private let PUMP_ONLY_Y: Float = 0.0;

	// Positive magnitude only.
	// Redscript does not allow negative expressions in class constants.
	// Font scale from CET:
	// vm_3d_font_scale_milli
	// 1000 = original size
	private let FONT_SCALE_DEFAULT: Int32 = 1000;
	private let FONT_SCALE_MIN: Int32 = 500;
	private let FONT_SCALE_MAX: Int32 = 2000;

  protected cb func OnInitialize() -> Void {
    let root = this.GetRootCompoundWidget();

    if !IsDefined(root) {
      return;
    };

		// Default hidden.
		// The service will only show it on the currently mounted valid vehicle.
		root.SetVisible(false);
		root.SetOpacity(0.0);

    this.root = root;
    this.lastFuelPermille = -1;
    this.lastOdoText = "";
		ArrayClear(this.fuelTickRefs);
		ArrayClear(this.classicTickRefs);
		ArrayClear(this.segmentRefs);
		this.themeLast = -999;
		this.brightnessLast = -999;
		this.fontLastIndex = -999;
		this.fontLastScale = -999;

    let cyan: HDRColor;
    cyan.Red = 0.35;
    cyan.Green = 0.95;
    cyan.Blue = 1.00;
    cyan.Alpha = 1.0;

    let cyanSoft: HDRColor;
    cyanSoft.Red = 0.70;
    cyanSoft.Green = 0.92;
    cyanSoft.Blue = 0.98;
    cyanSoft.Alpha = 1.0;

    let white: HDRColor;
    white.Red = 0.92;
    white.Green = 0.95;
    white.Blue = 0.98;
    white.Alpha = 1.0;

    let red: HDRColor;
    red.Red = 1.00;
    red.Green = 0.22;
    red.Blue = 0.22;
    red.Alpha = 1.0;

    // Main root for the 3D widget content.
    let main: ref<inkCanvas> = new inkCanvas();
    main.SetName(n"OdoHUD_FuelGaugeRoot");
    main.SetAnchor(inkEAnchor.Centered);
    main.SetAnchorPoint(new Vector2(0.5, 0.5));
    main.SetFitToContent(true);
    main.Reparent(root);
    this.main = main;

    // Arc container. Only this part is squashed like the normal fuel gauge.
    let arc: ref<inkCanvas> = new inkCanvas();
    arc.SetName(n"OdoHUD_FuelArc");
    arc.SetAnchor(inkEAnchor.Centered);
    arc.SetAnchorPoint(new Vector2(0.5, 0.5));
    arc.SetFitToContent(true);
    arc.SetScale(new Vector2(this.SCALE_X, this.SCALE_Y));
    arc.Reparent(main);
    this.arc = arc;

    // Fuel ticks.
    let innerR: Float = this.RIM_R - 24.0;
    let i: Int32 = 0;
    let firstMinorPainted: Bool = false;

    while i < this.TICK_COUNT {
      let t: Float = Cast<Float>(i) / Cast<Float>(this.TICK_COUNT - 1);
      let ang: Float = 180.0 - (180.0 * t);

      let lastIdx: Int32 = this.TICK_COUNT - 1;
      let q1: Int32 = (lastIdx * 1) / 4;
      let mid: Int32 = lastIdx / 2;
      let q3: Int32 = (lastIdx * 3) / 4;

      let isMajor: Bool = (i == 0) || (i == q1) || (i == mid) || (i == q3) || (i == lastIdx);
      let isMinor: Bool = !isMajor && ((i % 2) == 1);

      let tw: Float = 8.0;
      let th: Float = 26.0;

      if isMajor {
        tw = 15.0;
        th = 38.0;
      } else {
        if isMinor {
          tw = 6.0;
          th = 25.0;
        } else {
          tw = 10.0;
          th = 32.0;
        };
      };

      let tick: ref<inkRectangle> = new inkRectangle();
      tick.SetName(n"OdoHUD_FuelTick");
      tick.SetSize(new Vector2(tw, th));
      tick.SetAnchor(inkEAnchor.Centered);
      tick.SetAnchorPoint(new Vector2(0.5, 0.5));
      tick.SetRenderTransformPivot(new Vector2(0.5, 0.5));
      tick.SetRotation(270.0 - ang);
      tick.SetTranslation(this.__Polar(innerR, ang));
      tick.SetOpacity(isMajor ? 0.95 : 0.75);

      if i == 0 {
        tick.SetTintColor(red);
      } else if isMinor && !firstMinorPainted {
        tick.SetTintColor(red);
        firstMinorPainted = true;
      } else if isMajor {
        tick.SetTintColor(white);
      } else {
        tick.SetTintColor(cyanSoft);
      };

			tick.Reparent(arc);
			ArrayPush(this.fuelTickRefs, tick);
			i += 1;
    };

		// Pump icon.
		let pump: ref<inkImage> = new inkImage();
		pump.SetName(n"OdoHUD_Pump");
		pump.SetAtlasResource(r"ep1\\gameplay\\gui\\widgets\\vehicle\\sport\\v_sport2_villefort_deleon\\villefort_deleon.inkatlas");
		pump.SetTexturePart(n"fuel");
		pump.SetAnchor(inkEAnchor.Centered);
		pump.SetAnchorPoint(new Vector2(0.5, 0.5));
		pump.SetRenderTransformPivot(new Vector2(0.5, 0.5));
		pump.SetSize(new Vector2(this.PUMP_SIZE, this.PUMP_SIZE));
		pump.SetTintColor(cyan);

		// arc is squashed, so we cancel that squash for the pump image.
		pump.SetScale(new Vector2(1.0 / this.SCALE_X, 1.0 / this.SCALE_Y));

		// Keep the same visual Y logic.
		// Bigger PUMP_Y_UP = pump moves higher.
		pump.SetTranslation(new Vector2(0.0, (0.0 - this.PUMP_Y_UP) / this.SCALE_Y));

		pump.Reparent(arc);
		this.pumpImg = pump;
		
		// ============================================================================
		// Fuel style 1: progress bar
		// Full border frame + inner fill + centered label
		// ============================================================================

		let barWrap: ref<inkCanvas> = new inkCanvas();
		barWrap.SetName(n"OdoHUD_FuelBarWrap");
		barWrap.SetInteractive(false);
		barWrap.SetFitToContent(false);
		barWrap.SetSize(new Vector2(this.BAR_W, this.BAR_H));
		barWrap.SetAnchor(inkEAnchor.Centered);
		barWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
		barWrap.SetTranslation(new Vector2(0.0, this.BAR_Y));
		barWrap.Reparent(main);
		this.fuelBarWrap = barWrap;

		// Dark background
		let barBg: ref<inkRectangle> = new inkRectangle();
		barBg.SetName(n"OdoHUD_FuelBarBG");
		barBg.SetSize(new Vector2(this.BAR_W, this.BAR_H));
		barBg.SetAnchor(inkEAnchor.Centered);
		barBg.SetAnchorPoint(new Vector2(0.5, 0.5));

		let barDark: HDRColor;
		barDark.Red = 0.05;
		barDark.Green = 0.07;
		barDark.Blue = 0.08;
		barDark.Alpha = 1.0;

		barBg.SetTintColor(barDark);
		barBg.SetOpacity(0.78);
		barBg.Reparent(barWrap);
		barBg.Reparent(barWrap);
		this.fuelBarBgRef = barBg;

		// Inner fuel fill
		let barFill: ref<inkRectangle> = new inkRectangle();
		barFill.SetName(n"OdoHUD_FuelBarFill");
		barFill.SetSize(new Vector2(0.0, this.BAR_H - (this.BAR_PAD * 2.0)));
		barFill.SetAnchor(inkEAnchor.Centered);
		barFill.SetAnchorPoint(new Vector2(0.0, 0.5));
		barFill.SetTranslation(new Vector2((0.0 - this.BAR_W * 0.5) + this.BAR_PAD, 0.0));
		barFill.SetTintColor(cyan);
		barFill.SetOpacity(0.95);
		barFill.Reparent(barWrap);
		this.fuelBarFill = barFill;

		// Center label text
		let barText: ref<inkText> = new inkText();
		barText.SetName(n"OdoHUD_FuelBarText");
		barText.SetText("FUEL");
		barText.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
		barText.SetFontSize(this.BAR_LABEL_SIZE);
		barText.SetTintColor(white);
		barText.SetAnchor(inkEAnchor.Centered);
		barText.SetAnchorPoint(new Vector2(0.5, 0.5));
		barText.SetTranslation(new Vector2(0.0, 0.0));
		barText.SetOpacity(0.88);
		barText.Reparent(barWrap);
		this.fuelBarTextRef = barText;
		this.fuelBarText = barText;

		// Border color: different from fill
		let borderCol: HDRColor;
		borderCol.Red = 1.00;
		borderCol.Green = 0.80;
		borderCol.Blue = 0.10;
		borderCol.Alpha = 1.0;

		// Top border
		let barTop: ref<inkRectangle> = new inkRectangle();
		barTop.SetName(n"OdoHUD_FuelBarBorderTop");
		barTop.SetSize(new Vector2(this.BAR_W, this.BAR_BORDER));
		barTop.SetAnchor(inkEAnchor.Centered);
		barTop.SetAnchorPoint(new Vector2(0.5, 0.5));
		barTop.SetTranslation(new Vector2(0.0, (0.0 - this.BAR_H * 0.5) + (this.BAR_BORDER * 0.5)));
		barTop.SetTintColor(borderCol);
		barTop.SetOpacity(1.0);
		barTop.Reparent(barWrap);
		this.fuelBarBorderTopRef = barTop;

		// Bottom border
		let barBottom: ref<inkRectangle> = new inkRectangle();
		barBottom.SetName(n"OdoHUD_FuelBarBorderBottom");
		barBottom.SetSize(new Vector2(this.BAR_W, this.BAR_BORDER));
		barBottom.SetAnchor(inkEAnchor.Centered);
		barBottom.SetAnchorPoint(new Vector2(0.5, 0.5));
		barBottom.SetTranslation(new Vector2(0.0, (this.BAR_H * 0.5) - (this.BAR_BORDER * 0.5)));
		barBottom.SetTintColor(borderCol);
		barBottom.SetOpacity(1.0);
		barBottom.Reparent(barWrap);
		this.fuelBarBorderBottomRef = barBottom;

		// Left border
		let barLeft: ref<inkRectangle> = new inkRectangle();
		barLeft.SetName(n"OdoHUD_FuelBarBorderLeft");
		barLeft.SetSize(new Vector2(this.BAR_BORDER, this.BAR_H));
		barLeft.SetAnchor(inkEAnchor.Centered);
		barLeft.SetAnchorPoint(new Vector2(0.5, 0.5));
		barLeft.SetTranslation(new Vector2((0.0 - this.BAR_W * 0.5) + (this.BAR_BORDER * 0.5), 0.0));
		barLeft.SetTintColor(borderCol);
		barLeft.SetOpacity(1.0);
		barLeft.Reparent(barWrap);
		this.fuelBarBorderLeftRef = barLeft;

		// Right border
		let barRight: ref<inkRectangle> = new inkRectangle();
		barRight.SetName(n"OdoHUD_FuelBarBorderRight");
		barRight.SetSize(new Vector2(this.BAR_BORDER, this.BAR_H));
		barRight.SetAnchor(inkEAnchor.Centered);
		barRight.SetAnchorPoint(new Vector2(0.5, 0.5));
		barRight.SetTranslation(new Vector2((this.BAR_W * 0.5) - (this.BAR_BORDER * 0.5), 0.0));
		barRight.SetTintColor(borderCol);
		barRight.SetOpacity(1.0);
		barRight.Reparent(barWrap);
		this.fuelBarBorderRightRef = barRight;

		// ============================================================================
		// Fuel style 2: digits only
		// ============================================================================

		let digitWrap: ref<inkCanvas> = new inkCanvas();
		digitWrap.SetName(n"OdoHUD_FuelDigitWrap");
		digitWrap.SetInteractive(false);
		digitWrap.SetFitToContent(true);
		digitWrap.SetAnchor(inkEAnchor.Centered);
		digitWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
		digitWrap.SetTranslation(new Vector2(0.0, this.DIGIT_Y));
		digitWrap.Reparent(main);
		this.fuelDigitWrap = digitWrap;

		let digitText: ref<inkText> = new inkText();
		digitText.SetName(n"OdoHUD_FuelPercentText");
		digitText.SetText("100%");
		digitText.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
		digitText.SetFontSize(this.DIGIT_FONT_SIZE);
		digitText.SetTintColor(cyan);
		digitText.SetAnchor(inkEAnchor.Centered);
		digitText.SetAnchorPoint(new Vector2(0.5, 0.5));
		digitText.Reparent(digitWrap);
		this.fuelDigitText = digitText;
		
		// ============================================================================
		// Fuel style 3: classic real-car needle gauge
		// ============================================================================

		let classicWrap: ref<inkCanvas> = new inkCanvas();
		classicWrap.SetName(n"OdoHUD_FuelClassicWrap");
		classicWrap.SetInteractive(false);
		classicWrap.SetFitToContent(true);
		classicWrap.SetAnchor(inkEAnchor.Centered);
		classicWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
		classicWrap.Reparent(main);
		this.fuelClassicWrap = classicWrap;

		let ci: Int32 = 0;
		let classicLast: Int32 = this.CLASSIC_TICK_COUNT - 1;

		while ci < this.CLASSIC_TICK_COUNT {
			let ct: Float = Cast<Float>(ci) / Cast<Float>(classicLast);
			let cang: Float = this.CLASSIC_START_DEG + (this.CLASSIC_SWEEP_DEG * ct);

			let isMajorClassic: Bool = ci == 0 || ci == classicLast || ci == classicLast / 2;

			let ctw: Float = 8.0;
			let cth: Float = 30.0;

			if isMajorClassic {
				ctw = 14.0;
				cth = 42.0;
			};

			let classicTick: ref<inkRectangle> = new inkRectangle();
			classicTick.SetName(n"OdoHUD_ClassicFuelTick");
			classicTick.SetSize(new Vector2(ctw, cth));
			classicTick.SetAnchor(inkEAnchor.Centered);
			classicTick.SetAnchorPoint(new Vector2(0.5, 0.5));
			classicTick.SetRenderTransformPivot(new Vector2(0.5, 0.5));
			classicTick.SetRotation(270.0 - cang);
			classicTick.SetTranslation(this.__ClassicPolar(this.CLASSIC_R, cang));
			classicTick.SetTintColor(isMajorClassic ? white : cyanSoft);
			classicTick.SetOpacity(isMajorClassic ? 0.98 : 0.78);
			classicTick.Reparent(classicWrap);

			ArrayPush(this.classicTickRefs, classicTick);

			ci += 1;
		};

		// Classic F label
		let classicF: ref<inkText> = new inkText();
		classicF.SetName(n"OdoHUD_ClassicLabel_F");
		classicF.SetText("F");
		classicF.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
		classicF.SetFontSize(44);
		classicF.SetTintColor(white);
		classicF.SetAnchor(inkEAnchor.Centered);
		classicF.SetAnchorPoint(new Vector2(0.5, 0.5));
		classicF.SetTranslation(new Vector2(0.0 - this.CLASSIC_LABEL_F_X_MAG, 0.0 - this.CLASSIC_LABEL_F_Y_MAG));
		classicF.Reparent(classicWrap);
		this.classicFRef = classicF;

		// Classic E label
		let classicE: ref<inkText> = new inkText();
		classicE.SetName(n"OdoHUD_ClassicLabel_E");
		classicE.SetText("E");
		classicE.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
		classicE.SetFontSize(44);
		classicE.SetTintColor(white);
		classicE.SetAnchor(inkEAnchor.Centered);
		classicE.SetAnchorPoint(new Vector2(0.5, 0.5));
		classicE.SetTranslation(new Vector2(this.CLASSIC_LABEL_E_X, this.CLASSIC_LABEL_E_Y));
		classicE.Reparent(classicWrap);
		this.classicERef = classicE;

		// Classic pump icon
		let classicPump: ref<inkImage> = new inkImage();
		classicPump.SetName(n"OdoHUD_ClassicPump");
		classicPump.SetAtlasResource(r"ep1\\gameplay\\gui\\widgets\\vehicle\\sport\\v_sport2_villefort_deleon\\villefort_deleon.inkatlas");
		classicPump.SetTexturePart(n"fuel");
		classicPump.SetAnchor(inkEAnchor.Centered);
		classicPump.SetAnchorPoint(new Vector2(0.5, 0.5));
		classicPump.SetRenderTransformPivot(new Vector2(0.5, 0.5));
		classicPump.SetSize(new Vector2(this.CLASSIC_PUMP_SIZE, this.CLASSIC_PUMP_SIZE));
		classicPump.SetTranslation(new Vector2(this.CLASSIC_PUMP_X, this.CLASSIC_PUMP_Y));
		classicPump.SetTintColor(cyan);
		classicPump.Reparent(classicWrap);
		this.classicPumpImg = classicPump;

		// Classic needle pivot
		let classicNdRoot: ref<inkCanvas> = new inkCanvas();
		classicNdRoot.SetName(n"OdoHUD_ClassicNeedleRoot");
		classicNdRoot.SetAnchor(inkEAnchor.Centered);
		classicNdRoot.SetAnchorPoint(new Vector2(0.5, 1.0));
		classicNdRoot.SetRenderTransformPivot(new Vector2(0.5, 1.0));
		classicNdRoot.SetTranslation(new Vector2(0.0 - this.CLASSIC_PIVOT_X_MAG, this.CLASSIC_PIVOT_Y));
		classicNdRoot.SetRotation(135.0);
		classicNdRoot.Reparent(classicWrap);
		this.classicNeedle = classicNdRoot;

		let classicNd: ref<inkRectangle> = new inkRectangle();
		classicNd.SetName(n"OdoHUD_ClassicNeedle");
		classicNd.SetSize(new Vector2(this.CLASSIC_ND_W, this.CLASSIC_ND_LEN));
		classicNd.SetTintColor(red);
		classicNd.SetAnchor(inkEAnchor.Centered);
		classicNd.SetAnchorPoint(new Vector2(0.5, 1.0));
		classicNd.SetRenderTransformPivot(new Vector2(0.5, 1.0));
		classicNd.SetTranslation(new Vector2(0.0, 0.0));
		classicNd.Reparent(classicNdRoot);
		this.classicNeedleRectRef = classicNd;

		let classicHub: ref<inkRectangle> = new inkRectangle();
		classicHub.SetName(n"OdoHUD_ClassicHub");
		classicHub.SetSize(new Vector2(this.CLASSIC_HUB_SIZE, this.CLASSIC_HUB_SIZE));
		classicHub.SetAnchor(inkEAnchor.Centered);
		classicHub.SetAnchorPoint(new Vector2(0.5, 0.5));
		classicHub.SetTranslation(new Vector2(0.0 - this.CLASSIC_PIVOT_X_MAG, this.CLASSIC_PIVOT_Y));
		classicHub.SetOpacity(0.88);

		let classicHubDark: HDRColor;
		classicHubDark.Red = 0.02;
		classicHubDark.Green = 0.025;
		classicHubDark.Blue = 0.03;
		classicHubDark.Alpha = 1.0;

		classicHub.SetTintColor(classicHubDark);
		classicHub.Reparent(classicWrap);
		this.classicHubRef = classicHub;

		// ============================================================================
		// Fuel style 4: vertical segmented gauge
		// ============================================================================

		let segWrap: ref<inkCanvas> = new inkCanvas();
		segWrap.SetName(n"OdoHUD_FuelSegmentWrap");
		segWrap.SetInteractive(false);
		segWrap.SetFitToContent(true);
		segWrap.SetAnchor(inkEAnchor.Centered);
		segWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
		segWrap.Reparent(main);
		this.fuelSegmentWrap = segWrap;

		// Center vertical segments (bottom -> top)
		let si: Int32 = 0;
		while si < this.SEG_COUNT {
			let seg: ref<inkRectangle> = new inkRectangle();
			seg.SetName(n"OdoHUD_FuelSegment");
			seg.SetSize(new Vector2(this.SEG_W, this.SEG_H));
			seg.SetAnchor(inkEAnchor.Centered);
			seg.SetAnchorPoint(new Vector2(0.5, 0.5));

			let y: Float = 72.0 - Cast<Float>(si) * (this.SEG_H + this.SEG_GAP);
			seg.SetTranslation(new Vector2(0.0, y));
			seg.SetOpacity(0.18);
			seg.Reparent(segWrap);

			ArrayPush(this.segmentRefs, seg);
			si += 1;
		};

		// ============================================================================
		// Fuel style 5: pump icon only
		// ============================================================================

		let pumpOnlyWrap: ref<inkCanvas> = new inkCanvas();
		pumpOnlyWrap.SetName(n"OdoHUD_FuelPumpOnlyWrap");
		pumpOnlyWrap.SetInteractive(false);
		pumpOnlyWrap.SetFitToContent(true);
		pumpOnlyWrap.SetAnchor(inkEAnchor.Centered);
		pumpOnlyWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
		pumpOnlyWrap.Reparent(main);
		this.fuelPumpOnlyWrap = pumpOnlyWrap;

		let pumpOnly: ref<inkImage> = new inkImage();
		pumpOnly.SetName(n"OdoHUD_PumpOnlyIcon");
		pumpOnly.SetAtlasResource(r"ep1\\gameplay\\gui\\widgets\\vehicle\\sport\\v_sport2_villefort_deleon\\villefort_deleon.inkatlas");
		pumpOnly.SetTexturePart(n"fuel");
		pumpOnly.SetAnchor(inkEAnchor.Centered);
		pumpOnly.SetAnchorPoint(new Vector2(0.5, 0.5));
		pumpOnly.SetRenderTransformPivot(new Vector2(0.5, 0.5));
		pumpOnly.SetSize(new Vector2(this.PUMP_ONLY_SIZE, this.PUMP_ONLY_SIZE));
		pumpOnly.SetTranslation(new Vector2(this.PUMP_ONLY_X, this.PUMP_ONLY_Y));
		pumpOnly.SetTintColor(cyan);
		pumpOnly.Reparent(pumpOnlyWrap);
		this.pumpOnlyImg = pumpOnly;

    // Needle.
    let ndRoot: ref<inkCanvas> = new inkCanvas();
    ndRoot.SetName(n"OdoHUD_NeedleRoot");
    ndRoot.SetAnchor(inkEAnchor.Centered);
    ndRoot.SetAnchorPoint(new Vector2(0.5, 1.0));
    ndRoot.SetRenderTransformPivot(new Vector2(0.5, 1.0));
    ndRoot.SetTranslation(new Vector2(0.0, 0.0));
    ndRoot.SetRotation(-90.0);
    ndRoot.Reparent(arc);
    this.needle = ndRoot;

    let nd: ref<inkRectangle> = new inkRectangle();
    nd.SetName(n"OdoHUD_Needle");
    nd.SetSize(new Vector2(this.ND_W, this.ND_LEN));
    nd.SetTintColor(red);
    nd.SetAnchor(inkEAnchor.Centered);
    nd.SetAnchorPoint(new Vector2(0.5, 1.0));
    nd.SetRenderTransformPivot(new Vector2(0.5, 1.0));
    nd.SetTranslation(new Vector2(0.0, 0.0));
    nd.Reparent(ndRoot);
		this.needleRectRef = nd;

    let hub: ref<inkRectangle> = new inkRectangle();
    hub.SetName(n"OdoHUD_Hub");
    hub.SetSize(new Vector2(16.0, 16.0));
    hub.SetTintColor(white);
    hub.SetAnchor(inkEAnchor.Centered);
    hub.SetAnchorPoint(new Vector2(0.5, 0.5));
    hub.SetTranslation(new Vector2(0.0, 0.0));
    hub.Reparent(arc);
		this.hubRef = hub;
		

    // E / F labels, not squashed.
    let lblE: ref<inkText> = new inkText();
    lblE.SetName(n"OdoHUD_Label_E");
    lblE.SetText("E");
    lblE.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
    lblE.SetFontSize(36);
    lblE.SetTintColor(white);
    lblE.SetAnchor(inkEAnchor.Centered);
    lblE.SetAnchorPoint(new Vector2(0.5, 0.5));
    lblE.SetTranslation(new Vector2(0.0 - this.LABEL_EF_X, this.LABEL_EF_Y));
    lblE.Reparent(main);
		this.lblERef = lblE;

    let lblF: ref<inkText> = new inkText();
    lblF.SetName(n"OdoHUD_Label_F");
    lblF.SetText("F");
    lblF.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
    lblF.SetFontSize(36);
    lblF.SetTintColor(white);
    lblF.SetAnchor(inkEAnchor.Centered);
    lblF.SetAnchorPoint(new Vector2(0.5, 0.5));
    lblF.SetTranslation(new Vector2(this.LABEL_EF_X, this.LABEL_EF_Y));
    lblF.Reparent(main);
		this.lblFRef = lblF;

    // ============================================================================
    // ODO plate with atlas fill + stroke
    // ============================================================================

    let odoWrap: ref<inkCanvas> = new inkCanvas();
    odoWrap.SetName(n"OdoHUD_ODO_Wrap");
    odoWrap.SetInteractive(false);
    odoWrap.SetFitToContent(true);
    odoWrap.SetAnchor(inkEAnchor.Centered);
    odoWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
    odoWrap.SetTranslation(new Vector2(0.0, 98.0));
    odoWrap.Reparent(main);
    this.odoWrap = odoWrap;

    // Dark plate fill
    let plateFill: ref<inkImage> = new inkImage();
    plateFill.SetName(n"ODO_BG_FILL");
    plateFill.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\hud_johnny\\notification_assets.inkatlas");
    plateFill.SetTexturePart(n"Plate_main");
    plateFill.SetSize(new Vector2(this.ODO_W, this.ODO_H));
    plateFill.SetAnchor(inkEAnchor.Centered);
    plateFill.SetAnchorPoint(new Vector2(0.5, 0.5));

    let darkGrey: HDRColor;
    darkGrey.Red = 0.18;
    darkGrey.Green = 0.18;
    darkGrey.Blue = 0.18;
    darkGrey.Alpha = 1.0;

    plateFill.SetTintColor(darkGrey);
    plateFill.SetOpacity(0.85);
    plateFill.Reparent(odoWrap);
    this.odoFill = plateFill;

    // Cyan plate stroke
    let plateStroke: ref<inkImage> = new inkImage();
    plateStroke.SetName(n"ODO_BG_STROKE");
    plateStroke.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\hud_johnny\\notification_assets.inkatlas");
    plateStroke.SetTexturePart(n"Plate_main_Stroke");
    plateStroke.SetSize(new Vector2(this.ODO_W, this.ODO_H));
    plateStroke.SetAnchor(inkEAnchor.Centered);
    plateStroke.SetAnchorPoint(new Vector2(0.5, 0.5));
    plateStroke.SetTintColor(cyan);
    plateStroke.SetOpacity(1.0);
    plateStroke.Reparent(odoWrap);
    this.odoStroke = plateStroke;

    // Content row inside the plate
    let odoRow: ref<inkCanvas> = new inkCanvas();
    odoRow.SetName(n"OdoHUD_ODO_Row");
    odoRow.SetInteractive(false);
    odoRow.SetFitToContent(false);
    odoRow.SetSize(new Vector2(this.ODO_W, this.ODO_H));
    odoRow.SetAnchor(inkEAnchor.Centered);
    odoRow.SetAnchorPoint(new Vector2(0.5, 0.5));
    odoRow.Reparent(odoWrap);

    // ODO label on the left
    let odoLabel: ref<inkText> = new inkText();
    odoLabel.SetName(n"OdoHUD_ODO_Label");
    odoLabel.SetText("ODO");
    odoLabel.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
    odoLabel.SetFontSize(40);
    odoLabel.SetTintColor(white);
    odoLabel.SetAnchor(inkEAnchor.Centered);
    odoLabel.SetAnchorPoint(new Vector2(0.0, 0.5));
    odoLabel.SetTranslation(new Vector2((0.0 - this.ODO_W * 0.5) + this.ODO_PAD_L, 0.0));
    odoLabel.Reparent(odoRow);
		this.odoLabelRef = odoLabel;
		odoLabel.Reparent(odoRow);
		this.odoLabelRef = odoLabel;

    // ODO value right-aligned
    let odo: ref<inkText> = new inkText();
    odo.SetName(n"OdoHUD_ODO_Value");
    odo.SetText("000000");
    odo.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
    odo.SetFontSize(44);
    odo.SetTintColor(cyan);
    odo.SetAnchor(inkEAnchor.Centered);
    odo.SetAnchorPoint(new Vector2(1.0, 0.5));
    odo.SetTranslation(new Vector2((this.ODO_W * 0.5) - this.ODO_PAD_R, 0.0));
    odo.Reparent(odoRow);
		this.odoText = odo;
		this.__ApplyFontFromFact();
		this.__ApplyModeVisibility();
		this.__ApplyOdoFrameVisibility();
		this.__ApplyThemePalette(true);
  }

  public func Load(wheel: wref<VM3DOdoMeshComponent>) -> Void {
    // Not needed yet.
  }

  public func VM_SetVisible(show: Bool) -> Void {
    if IsDefined(this.root) {
      this.root.SetVisible(show);
      this.root.SetOpacity(show ? 1.0 : 0.0);
    };
  }


	public func VM_SetMode(mode: Int32) -> Void {
		this.hudMode = mode;
		this.__ApplyModeVisibility();
	}

private func __FontFamilyFromFact() -> String {
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  let idx: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_3d_font_index") : 0;

  // 0 = default Digital Readout
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

private func __FontScaleFromFact() -> Int32 {
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  let scale: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_3d_font_scale_milli") : this.FONT_SCALE_DEFAULT;

  if scale <= 0 {
    return this.FONT_SCALE_DEFAULT;
  };

  if scale < this.FONT_SCALE_MIN {
    return this.FONT_SCALE_MIN;
  };

  if scale > this.FONT_SCALE_MAX {
    return this.FONT_SCALE_MAX;
  };

  return scale;
}

private func __ScaledFontSize(baseSize: Int32) -> Int32 {
  let scale: Int32 = this.__FontScaleFromFact();
  let result: Int32 = (baseSize * scale) / 1000;

  if result < 8 {
    return 8;
  };

  if result > 140 {
    return 140;
  };

  return result;
}

private func __ApplyFontFromFact() -> Void {
  let fontFamily: String = this.__FontFamilyFromFact();

  if IsDefined(this.lblERef) {
    this.lblERef.SetFontFamily(fontFamily);
    this.lblERef.SetFontSize(this.__ScaledFontSize(36));
  };

  if IsDefined(this.lblFRef) {
    this.lblFRef.SetFontFamily(fontFamily);
    this.lblFRef.SetFontSize(this.__ScaledFontSize(36));
  };
	
	if IsDefined(this.classicERef) {
    this.classicERef.SetFontFamily(fontFamily);
    this.classicERef.SetFontSize(this.__ScaledFontSize(44));
  };

  if IsDefined(this.classicFRef) {
    this.classicFRef.SetFontFamily(fontFamily);
    this.classicFRef.SetFontSize(this.__ScaledFontSize(44));
  };

  if IsDefined(this.odoLabelRef) {
    this.odoLabelRef.SetFontFamily(fontFamily);
    this.odoLabelRef.SetFontSize(this.__ScaledFontSize(40));
  };

  if IsDefined(this.odoText) {
    this.odoText.SetFontFamily(fontFamily);
    this.odoText.SetFontSize(this.__ScaledFontSize(44));
  };

  if IsDefined(this.fuelBarText) {
    this.fuelBarText.SetFontFamily(fontFamily);
    this.fuelBarText.SetFontSize(this.__ScaledFontSize(this.BAR_LABEL_SIZE));
  };

  if IsDefined(this.fuelDigitText) {
    this.fuelDigitText.SetFontFamily(fontFamily);
    this.fuelDigitText.SetFontSize(this.__ScaledFontSize(this.DIGIT_FONT_SIZE));
  };
}

private func __ApplyFontFromFactIfChanged() -> Void {
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());

  let idx: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_3d_font_index") : 0;
  let scale: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_3d_font_scale_milli") : this.FONT_SCALE_DEFAULT;

  if idx == this.fontLastIndex && scale == this.fontLastScale {
    return;
  };

  this.fontLastIndex = idx;
  this.fontLastScale = scale;

  this.__ApplyFontFromFact();
}

private func __FuelStyleFromFact() -> Int32 {
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());

  let style: Int32 = 0;

  if IsDefined(qs) {
    if this.hudMode == 3 {
      // Fuel Gauge Alt uses its own style config.
      style = qs.GetFact(n"vm_3d_fuel_alt_style");
    } else {
      // Normal Fuel Gauge.
      style = qs.GetFact(n"vm_3d_fuel_style");
    };
  };

  if style < 0 {
    return 0;
  };

  if style > 5 {
    return 0;
  };

  return style;
}

	private func __ApplyModeVisibility() -> Void {
		let showFuel: Bool = this.hudMode == 0 || this.hudMode == 1 || this.hudMode == 3;
		let showOdo: Bool = this.hudMode == 0 || this.hudMode == 2 || this.hudMode == 4;

		let style: Int32 = this.__FuelStyleFromFact();

		let showArc: Bool = showFuel && style == 0;
		let showBar: Bool = showFuel && style == 1;
		let showDigits: Bool = showFuel && style == 2;
		let showClassic: Bool = showFuel && style == 3;
		let showSegment: Bool = showFuel && style == 4;
		let showPumpOnly: Bool = showFuel && style == 5;

		if IsDefined(this.arc) {
			this.arc.SetVisible(showArc);
		};

		if IsDefined(this.lblERef) {
			this.lblERef.SetVisible(showArc);
		};

		if IsDefined(this.lblFRef) {
			this.lblFRef.SetVisible(showArc);
		};

		if IsDefined(this.fuelBarWrap) {
			this.fuelBarWrap.SetVisible(showBar);
		};

		if IsDefined(this.fuelDigitWrap) {
			this.fuelDigitWrap.SetVisible(showDigits);
		};

		if IsDefined(this.fuelClassicWrap) {
			this.fuelClassicWrap.SetVisible(showClassic);
		};

		if IsDefined(this.fuelSegmentWrap) {
			this.fuelSegmentWrap.SetVisible(showSegment);
		};

		if IsDefined(this.fuelPumpOnlyWrap) {
			this.fuelPumpOnlyWrap.SetVisible(showPumpOnly);
		};

		if IsDefined(this.odoWrap) {
			this.odoWrap.SetVisible(showOdo);
		};
	}
		
	private func __ApplyOdoFrameVisibility() -> Void {
		let qs = GameInstance.GetQuestsSystem(GetGameInstance());
		let hideFrame: Bool = IsDefined(qs) && (
			(this.hudMode == 4 && qs.GetFact(n"vm_3d_odo_alt_hide_frame") > 0)
			|| (this.hudMode != 4 && qs.GetFact(n"vm_3d_odo_hide_frame") > 0)
		);

		let showFrame: Bool = !hideFrame;

		if IsDefined(this.odoFill) {
			this.odoFill.SetVisible(showFrame);
		};

		if IsDefined(this.odoStroke) {
			this.odoStroke.SetVisible(showFrame);
		};
	}
	
  public func VM_SetOdoText(value: String) -> Void {
    this.VM_SetFuelGaugeData(value, this.lastFuelPermille);
  }

	public func VM_SetFuelGaugeData(odoValue: String, fuelPermille: Int32) -> Void {
		if IsDefined(this.root) {
			this.root.SetVisible(true);
			this.root.SetOpacity(1.0);
		};


		// Re-check style/frame/theme/font every tick so CET switches work live.
		this.__ApplyModeVisibility();
		this.__ApplyOdoFrameVisibility();
		this.__ApplyFontFromFactIfChanged();
		this.__ApplyThemePalette(false);
		this.__UpdateFuelAltStyles(fuelPermille);

		this.lastOdoText = odoValue;

		if IsDefined(this.odoText) {
			this.odoText.SetText(odoValue);
		};

		if fuelPermille != this.lastFuelPermille {
      this.lastFuelPermille = fuelPermille;

      let p: Int32 = fuelPermille;
      if p < 0 {
        p = 0;
      };
      if p > 1000 {
        p = 1000;
      };

      let t: Float = Cast<Float>(p) / 1000.0;
      let rot: Float = -90.0 + (180.0 * t);

      if IsDefined(this.needle) {
        this.needle.SetRotation(rot);
      };

			// Classic gauge:
			// 0% = needle points to E, 100% = needle points to F.
			let classicAngle: Float = this.CLASSIC_START_DEG + (this.CLASSIC_SWEEP_DEG * (1.0 - t));
			let classicRot: Float = 90.0 - classicAngle;

			if classicRot < -180.0 {
				classicRot += 360.0;
			};

			if IsDefined(this.classicNeedle) {
				this.classicNeedle.SetRotation(classicRot);
			};

      this.__ApplyPumpColor(p);
    };
  }

	private func __UpdateFuelAltStyles(fuelPermille: Int32) -> Void {
		let p: Int32 = fuelPermille;

		if p < 0 {
			p = 0;
		};

		if p > 1000 {
			p = 1000;
		};

		let pct: Int32 = (p + 5) / 10;

		if IsDefined(this.fuelBarFill) {
			let fillW: Float = (this.BAR_W - 10.0) * (Cast<Float>(p) / 1000.0);
			this.fuelBarFill.SetSize(new Vector2(fillW, this.BAR_H - 10.0));
		};

		if IsDefined(this.fuelDigitText) {
			this.fuelDigitText.SetText(IntToString(pct) + "%");
		};
		
		// Style 4: vertical segments
		let theme: Int32 = this.__ThemeFromFact();
		let main: HDRColor = this.__ThemeMainColor(theme);
		let white: HDRColor = this.__ThemeWhiteColor(theme);
		let reserveRed: HDRColor = this.__ThemeReserveRed(theme);

		let amber: HDRColor;
		amber.Red = 1.00;
		amber.Green = 0.78;
		amber.Blue = 0.10;
		amber.Alpha = 1.0;
		amber = this.__ApplyBrightness(amber);

		let activeCount: Int32 = (p + 99) / 100;
		if activeCount < 0 {
			activeCount = 0;
		};
		if activeCount > this.SEG_COUNT {
			activeCount = this.SEG_COUNT;
		};

		let darkSeg: HDRColor;
		darkSeg.Red = 0.08;
		darkSeg.Green = 0.10;
		darkSeg.Blue = 0.12;
		darkSeg.Alpha = 1.0;

		let si: Int32 = 0;
		let segCountNow: Int32 = ArraySize(this.segmentRefs);

		while si < segCountNow {
			let segRef: wref<inkRectangle> = this.segmentRefs[si];

			if IsDefined(segRef) {
				if si < activeCount {
					if si == 0 {
						segRef.SetTintColor(reserveRed);
					} else {
						if si == 1 {
							segRef.SetTintColor(amber);
						} else {
							segRef.SetTintColor(main);
						};
					};

					segRef.SetOpacity(0.96);
				} else {
					segRef.SetTintColor(darkSeg);
					segRef.SetOpacity(0.22);
				};
			};

			si += 1;
		};
		
	}

	private func __BrightnessDeciFromFact() -> Int32 {
		let qs = GameInstance.GetQuestsSystem(GetGameInstance());
		let v: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_3d_emissive_ev_deci") : 60;

		if v < 0 {
			return 0;
		};

		if v > 120 {
			return 120;
		};

		return v;
	}

	private func __ApplyBrightness(c: HDRColor) -> HDRColor {
		let evDeci: Int32 = this.__BrightnessDeciFromFact();

		// 60 = EmissiveEV 6.0 = default multiplier 1.0
		let mult: Float = Cast<Float>(evDeci) / 60.0;

		c.Red = c.Red * mult;
		c.Green = c.Green * mult;
		c.Blue = c.Blue * mult;

		return c;
	}

	private func __ThemeFromFact() -> Int32 {
		let qs = GameInstance.GetQuestsSystem(GetGameInstance());
		let theme: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_3d_theme") : 0;

		if theme < 0 {
			return 0;
		};

		if theme > 9 {
			return 0;
		};

		return theme;
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
		return this.__ApplyBrightness(c);
		return c;
	}

	private func __ThemeSoftColor(theme: Int32) -> HDRColor {
		let c: HDRColor;

		if theme == 1 {
			c.Red = 1.00; c.Green = 0.90; c.Blue = 0.35;
		} else if theme == 2 {
			c.Red = 0.78; c.Green = 0.92; c.Blue = 0.89;
		} else if theme == 3 {
			c.Red = 1.00; c.Green = 0.55; c.Blue = 0.95;
		} else if theme == 4 {
			c.Red = 0.50; c.Green = 0.65; c.Blue = 1.00;
		} else if theme == 5 {
			c.Red = 0.75; c.Green = 0.96; c.Blue = 1.00;
		} else if theme == 6 {
			c.Red = 0.65; c.Green = 1.00; c.Blue = 0.65;
		} else if theme == 7 {
			c.Red = 0.65; c.Green = 0.72; c.Blue = 0.78;
		} else if theme == 8 {
			c.Red = 1.00; c.Green = 0.82; c.Blue = 0.35;
		} else if theme == 9 {
			c.Red = 1.00; c.Green = 1.00; c.Blue = 0.55;
		} else {
			c.Red = 0.70; c.Green = 0.92; c.Blue = 0.98;
		};

		c.Alpha = 1.0;
		return this.__ApplyBrightness(c);
		return c;
	}

	private func __ThemeWhiteColor(theme: Int32) -> HDRColor {
		let c: HDRColor;

		if theme == 2 {
			c.Red = 0.98; c.Green = 1.00; c.Blue = 0.99;
		} else {
			c.Red = 0.92; c.Green = 0.95; c.Blue = 0.98;
		};

		c.Alpha = 1.0;
		return this.__ApplyBrightness(c);
		return c;
	}

	private func __ThemeReserveRed(theme: Int32) -> HDRColor {
		let c: HDRColor;

		if theme == 2 {
			c.Red = 0.92; c.Green = 0.16; c.Blue = 0.26;
		} else {
			c.Red = 1.00; c.Green = 0.22; c.Blue = 0.22;
		};

		c.Alpha = 1.0;
		return this.__ApplyBrightness(c);
		return c;
	}

	private func __ApplyThemePalette(force: Bool) -> Void {
		let theme: Int32 = this.__ThemeFromFact();
		let brightness: Int32 = this.__BrightnessDeciFromFact();

		if !force && theme == this.themeLast && brightness == this.brightnessLast {
			return;
		};

		this.themeLast = theme;
		this.brightnessLast = brightness;

		let main: HDRColor = this.__ThemeMainColor(theme);
		let soft: HDRColor = this.__ThemeSoftColor(theme);
		let white: HDRColor = this.__ThemeWhiteColor(theme);
		let reserveRed: HDRColor = this.__ThemeReserveRed(theme);

		let firstMinorPainted: Bool = false;
		let count: Int32 = ArraySize(this.fuelTickRefs);
		let i: Int32 = 0;

		while i < count {
			let tick: wref<inkRectangle> = this.fuelTickRefs[i];

			if IsDefined(tick) {
				let lastIdx: Int32 = this.TICK_COUNT - 1;
				let q1: Int32 = (lastIdx * 1) / 4;
				let mid: Int32 = lastIdx / 2;
				let q3: Int32 = (lastIdx * 3) / 4;

				let isMajor: Bool = (i == 0) || (i == q1) || (i == mid) || (i == q3) || (i == lastIdx);
				let isMinor: Bool = !isMajor && ((i % 2) == 1);

				if i == 0 {
					tick.SetTintColor(reserveRed);
				} else if isMinor && !firstMinorPainted {
					tick.SetTintColor(reserveRed);
					firstMinorPainted = true;
				} else if isMajor {
					tick.SetTintColor(white);
				} else {
					tick.SetTintColor(soft);
				};
			};

			i += 1;
		};

		if IsDefined(this.pumpImg) {
			if this.lastFuelPermille > 150 || this.lastFuelPermille < 0 {
				this.pumpImg.SetTintColor(main);
			} else {
				this.__ApplyPumpColor(this.lastFuelPermille);
			};
		};

		if IsDefined(this.odoStroke) {
			if theme == 2 {
				this.odoStroke.SetTintColor(reserveRed);
			} else {
				this.odoStroke.SetTintColor(main);
			};
		};

		if IsDefined(this.odoText) {
			this.odoText.SetTintColor(main);
		};

		if IsDefined(this.odoLabelRef) {
			if theme == 2 {
				this.odoLabelRef.SetTintColor(reserveRed);
			} else {
				this.odoLabelRef.SetTintColor(white);
			};
		};

		if IsDefined(this.lblERef) {
			if theme == 2 {
				this.lblERef.SetTintColor(reserveRed);
			} else {
				this.lblERef.SetTintColor(white);
			};
		};

		if IsDefined(this.lblFRef) {
			if theme == 2 {
				this.lblFRef.SetTintColor(main);
			} else {
				this.lblFRef.SetTintColor(white);
			};
		};

		if IsDefined(this.needleRectRef) {
			this.needleRectRef.SetTintColor(reserveRed);
		};

		if IsDefined(this.hubRef) {
			this.hubRef.SetTintColor(white);
		};

		if IsDefined(this.fuelBarFill) {
			this.fuelBarFill.SetTintColor(main);
		};

		if IsDefined(this.fuelBarTextRef) {
			this.fuelBarTextRef.SetTintColor(white);
		};

		if IsDefined(this.fuelDigitText) {
			this.fuelDigitText.SetTintColor(main);
		};

		if IsDefined(this.pumpOnlyImg) {
			if this.lastFuelPermille > 150 || this.lastFuelPermille < 0 {
				this.pumpOnlyImg.SetTintColor(main);
			} else {
				this.__ApplyPumpColor(this.lastFuelPermille);
			};
		};

		if IsDefined(this.classicPumpImg) {
			this.classicPumpImg.SetTintColor(main);
		};

		if IsDefined(this.classicNeedleRectRef) {
			this.classicNeedleRectRef.SetTintColor(reserveRed);
		};

		if IsDefined(this.classicERef) {
			this.classicERef.SetTintColor(white);
		};

		if IsDefined(this.classicFRef) {
			this.classicFRef.SetTintColor(white);
		};

		let classicCount: Int32 = ArraySize(this.classicTickRefs);
		let classicIndex: Int32 = 0;

		while classicIndex < classicCount {
			let classicTickRef: wref<inkRectangle> = this.classicTickRefs[classicIndex];

			if IsDefined(classicTickRef) {
				if classicIndex == 0 || classicIndex == classicCount - 1 || classicIndex == (classicCount - 1) / 2 {
					classicTickRef.SetTintColor(white);
				} else {
					classicTickRef.SetTintColor(soft);
				};
			};

			classicIndex += 1;
		};

		if IsDefined(this.fuelBarBorderTopRef) {
			this.fuelBarBorderTopRef.SetTintColor(reserveRed);
		};

		if IsDefined(this.fuelBarBorderBottomRef) {
			this.fuelBarBorderBottomRef.SetTintColor(reserveRed);
		};

		if IsDefined(this.fuelBarBorderLeftRef) {
			this.fuelBarBorderLeftRef.SetTintColor(reserveRed);
		};

		if IsDefined(this.fuelBarBorderRightRef) {
			this.fuelBarBorderRightRef.SetTintColor(reserveRed);
		};
	}

	private func __ApplyPumpColor(fuelPermille: Int32) -> Void {
		if !IsDefined(this.pumpImg) {
			return;
		};

		let c: HDRColor;
		let theme: Int32 = this.__ThemeFromFact();

		if fuelPermille <= 50 {
			c = this.__ThemeReserveRed(theme);
		} else if fuelPermille <= 150 {
			c.Red = 1.00;
			c.Green = 0.80;
			c.Blue = 0.10;
			c.Alpha = 1.0;
		} else {
			c = this.__ThemeMainColor(theme);
		};

		this.pumpImg.SetTintColor(c);
		
		if IsDefined(this.classicPumpImg) {
			this.classicPumpImg.SetTintColor(c);
		};
		
		if IsDefined(this.pumpOnlyImg) {
			this.pumpOnlyImg.SetTintColor(c);
		};
		
	}

  private func __Polar(r: Float, deg: Float) -> Vector2 {
    let rad: Float = deg * this.DEG2RAD;
    return new Vector2(r * CosF(rad), -r * SinF(rad));
  }
	
	private func __ClassicPolar(r: Float, deg: Float) -> Vector2 {
		let p: Vector2 = this.__Polar(r, deg);
		return new Vector2((0.0 - this.CLASSIC_PIVOT_X_MAG) + p.X, this.CLASSIC_PIVOT_Y + p.Y);
	}
}
// ============================================================================
// Scriptable service:
// - adds mesh/widget to assembled vehicles
// - updates ODO text on the currently mounted vehicle
// ============================================================================
public class VM3DOdoService extends IScriptable {
  public let tickArmed: Bool;

  private let tick: ref<VM3DOdoTick>;
  private let tickPeriod: Float = 0.25;

	private let callbackSystem: wref<CallbackSystem>;
	private let lastFuelMesh: wref<VM3DOdoMeshComponent>;
	private let lastOdoMesh: wref<VM3DOdoMeshComponent>;
	private let lastFuelAltMesh: wref<VM3DOdoMeshComponent>;
	private let lastOdoAltMesh: wref<VM3DOdoMeshComponent>;
	private let lastFuelWidget: wref<VM3DOdoWidgetComponent>;
	private let lastOdoWidget: wref<VM3DOdoWidgetComponent>;
	private let lastFuelAltWidget: wref<VM3DOdoWidgetComponent>;
	private let lastOdoAltWidget: wref<VM3DOdoWidgetComponent>;
	private let registered: Bool;

	// Tracks mounted vehicle change.
	// This lets us hide the old vehicle widget only when needed.
	private let lastVehicleHash: Uint64;

	private let placementCacheReady: Bool;
	private let lastSideFact: Int32;
	private let lastOutCm: Int32;
	private let lastYCm: Int32;
	private let lastZCm: Int32;
	private let lastRollDeg: Int32;
	private let lastPitchDeg: Int32;
	private let lastYawDeg: Int32;
	private let lastScaleMilli: Int32;

private func Fact(name: CName) -> Int32 {
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());

  if !IsDefined(qs) {
    return 0;
  };

  return qs.GetFact(name);
}

private func IsVehicleUIActive(car: wref<WheeledObject>) -> Bool {
	if !IsDefined(car) {
		return false;
	};

	let blackboard: ref<IBlackboard> = car.GetBlackboard();
	return IsDefined(blackboard)
		&& blackboard.GetBool(GetAllBlackboardDefs().Vehicle.IsUIActive);
}

private func HideCarMeshes(car: wref<WheeledObject>) -> Void {
	if !IsDefined(car) {
		return;
	};

	let fuelMesh = car.FindComponentByName(n"fuel_mesh") as VM3DOdoMeshComponent;
	let odoMesh = car.FindComponentByName(n"odo_mesh") as VM3DOdoMeshComponent;
	let fuelAltMesh = car.FindComponentByName(n"fuel_alt_mesh") as VM3DOdoMeshComponent;
	let odoAltMesh = car.FindComponentByName(n"odo_alt_mesh") as VM3DOdoMeshComponent;

	if IsDefined(fuelMesh) { fuelMesh.VM_HardHide(); };
	if IsDefined(odoMesh) { odoMesh.VM_HardHide(); };
	if IsDefined(fuelAltMesh) { fuelAltMesh.VM_HardHide(); };
	if IsDefined(odoAltMesh) { odoAltMesh.VM_HardHide(); };
}

private func PlacementChanged() -> Bool {
  let side: Int32 = this.Fact(n"vm_3d_odo_side");
  let outCm: Int32 = this.Fact(n"vm_3d_odo_out_cm");
  let yCm: Int32 = this.Fact(n"vm_3d_odo_y_cm");
  let zCm: Int32 = this.Fact(n"vm_3d_odo_z_cm");
  let rollDeg: Int32 = this.Fact(n"vm_3d_odo_roll_deg");
  let pitchDeg: Int32 = this.Fact(n"vm_3d_odo_pitch_deg");
  let yawDeg: Int32 = this.Fact(n"vm_3d_odo_yaw_deg");

  let scaleMilli: Int32 = this.Fact(n"vm_3d_odo_scale_milli");
  if scaleMilli <= 0 {
    scaleMilli = 600;
  };

  if !this.placementCacheReady {
    this.placementCacheReady = true;
    this.lastSideFact = side;
    this.lastOutCm = outCm;
    this.lastYCm = yCm;
    this.lastZCm = zCm;
    this.lastRollDeg = rollDeg;
    this.lastPitchDeg = pitchDeg;
    this.lastYawDeg = yawDeg;
    this.lastScaleMilli = scaleMilli;
    return true;
  };

  if side != this.lastSideFact
    || outCm != this.lastOutCm
    || yCm != this.lastYCm
    || zCm != this.lastZCm
    || rollDeg != this.lastRollDeg
    || pitchDeg != this.lastPitchDeg
    || yawDeg != this.lastYawDeg
    || scaleMilli != this.lastScaleMilli {

    this.lastSideFact = side;
    this.lastOutCm = outCm;
    this.lastYCm = yCm;
    this.lastZCm = zCm;
    this.lastRollDeg = rollDeg;
    this.lastPitchDeg = pitchDeg;
    this.lastYawDeg = yawDeg;
    this.lastScaleMilli = scaleMilli;
    return true;
  };

  return false;
}

	public func Start() -> Void {
		if !this.registered {
			this.callbackSystem = GameInstance.GetCallbackSystem();

			if IsDefined(this.callbackSystem) {
				this.callbackSystem.RegisterCallback(n"Entity/Assemble", this, n"OnVehicleAssemble", true)
					.AddTarget(EntityTarget.Type(NameOf(VehicleObject)));

				this.registered = true;
				// LogChannel(n"DEBUG", "[OdoHUD] Entity/Assemble callback registered");
			};
		};

		this.ArmTick();
	}

	private func EnsureCarComponents(car: wref<WheeledObject>) -> Void {
		if !IsDefined(car) {
			return;
		};

		let fuelMesh = car.FindComponentByName(n"fuel_mesh") as VM3DOdoMeshComponent;
		let fuelWidget = car.FindComponentByName(n"fuel_widget") as VM3DOdoWidgetComponent;

		let odoMesh = car.FindComponentByName(n"odo_mesh") as VM3DOdoMeshComponent;
		let odoWidget = car.FindComponentByName(n"odo_widget") as VM3DOdoWidgetComponent;
		
		let fuelAltMesh = car.FindComponentByName(n"fuel_alt_mesh") as VM3DOdoMeshComponent;
		let fuelAltWidget = car.FindComponentByName(n"fuel_alt_widget") as VM3DOdoWidgetComponent;

		let odoAltMesh = car.FindComponentByName(n"odo_alt_mesh") as VM3DOdoMeshComponent;
		let odoAltWidget = car.FindComponentByName(n"odo_alt_widget") as VM3DOdoWidgetComponent;

		let id = EntityID.ToHash(car.GetEntityID());

		if !IsDefined(fuelMesh) {
			let fm = VM3DOdoMeshComponent.Create(StringToName("fuel_mesh_" + ToString(id)), n"fuel_mesh", 1);
			car.AddComponent(fm);
			fm.Toggle(true);
			fm.Load();
		};

		if !IsDefined(fuelWidget) {
			let fw = VM3DOdoWidgetComponent.Create(StringToName("fuel_widget_" + ToString(id)), n"fuel_widget", n"fuel_mesh");
			car.AddComponent(fw);
			fw.Toggle(true);
		};

		if !IsDefined(odoMesh) {
			let om = VM3DOdoMeshComponent.Create(StringToName("odo_mesh_" + ToString(id)), n"odo_mesh", 2);
			car.AddComponent(om);
			om.Toggle(true);
			om.Load();
		};

		if !IsDefined(odoWidget) {
			let ow = VM3DOdoWidgetComponent.Create(StringToName("odo_widget_" + ToString(id)), n"odo_widget", n"odo_mesh");
			car.AddComponent(ow);
			ow.Toggle(true);
		};
		
		if !IsDefined(fuelAltMesh) {
			let fam = VM3DOdoMeshComponent.Create(StringToName("fuel_alt_mesh_" + ToString(id)), n"fuel_alt_mesh", 3);
			car.AddComponent(fam);
			fam.Toggle(true);
			fam.Load();
		};

		if !IsDefined(fuelAltWidget) {
			let faw = VM3DOdoWidgetComponent.Create(StringToName("fuel_alt_widget_" + ToString(id)), n"fuel_alt_widget", n"fuel_alt_mesh");
			car.AddComponent(faw);
			faw.Toggle(true);
		};

		if !IsDefined(odoAltMesh) {
			let oam = VM3DOdoMeshComponent.Create(StringToName("odo_alt_mesh_" + ToString(id)), n"odo_alt_mesh", 4);
			car.AddComponent(oam);
			oam.Toggle(true);
			oam.Load();
		};

		if !IsDefined(odoAltWidget) {
			let oaw = VM3DOdoWidgetComponent.Create(StringToName("odo_alt_widget_" + ToString(id)), n"odo_alt_widget", n"odo_alt_mesh");
			car.AddComponent(oaw);
			oaw.Toggle(true);
		};
	}

	protected cb func OnVehicleAssemble(event: ref<EntityLifecycleEvent>) -> Void {
		let car = event.GetEntity() as WheeledObject;

		if !IsDefined(car) {
			return;
		};

		// Important:
		// Create the worldui components during vehicle assembly.
		// If we create them later while mounted, GetGameController() can stay NULL.
		//
		// This is safe now because inkOdoHUD.OnInitialize() starts hidden.
		// Tick() is the only place that makes the mounted vehicle visible.
		this.EnsureCarComponents(car);
		this.HideCarMeshes(car);
	}

	private func GetMountedWheeledVehicle() -> wref<WheeledObject> {
		let player = GetPlayer(GetGameInstance());

		if !IsDefined(player) {
			return null;
		};

		return player.GetMountedVehicle() as WheeledObject;
	}


public func Tick() -> Void {
  let car = this.GetMountedWheeledVehicle();

  if !IsDefined(car) {
    this.placementCacheReady = false;
    this.lastVehicleHash = 0ul;
    this.HideLastWidget();
    this.ArmTick();
    return;
  };
	// Master switch from Lua.
	// If 3D Widget mode is not active, keep everything hidden.
	if this.Fact(n"vm_3d_enabled") <= 0 {
		this.placementCacheReady = false;
		this.HideCarMeshes(car);
		this.HideLastWidget();
		this.ArmTick();
		return;
	};

	// EVS and the base game drive this vanilla blackboard when the vehicle
	// dashboard is powered down. Its world-UI controller can be unavailable
	// while the backing mesh still renders, so hard-hide both layers.
	if !this.IsVehicleUIActive(car) {
		this.placementCacheReady = false;
		this.HideCarMeshes(car);
		this.HideLastWidget();
		this.ArmTick();
		return;
	};

  let carHash: Uint64 = EntityID.ToHash(car.GetEntityID());

  if carHash != this.lastVehicleHash {
    this.HideLastWidget();
    this.lastVehicleHash = carHash;
    this.placementCacheReady = false;
  };
	// Safety fallback:
	// If this mounted vehicle did not receive the 3D components during assembly,
	// create them now. This only runs for the currently mounted vehicle.
	this.EnsureCarComponents(car);
  // --------------------------------------------------------------------------
  // Find both independent 3D widget pairs
  // --------------------------------------------------------------------------
	let fuelMesh = car.FindComponentByName(n"fuel_mesh") as VM3DOdoMeshComponent;
	let fuelWidget = car.FindComponentByName(n"fuel_widget") as VM3DOdoWidgetComponent;

	let odoMesh = car.FindComponentByName(n"odo_mesh") as VM3DOdoMeshComponent;
	let odoWidget = car.FindComponentByName(n"odo_widget") as VM3DOdoWidgetComponent;

	let fuelAltMesh = car.FindComponentByName(n"fuel_alt_mesh") as VM3DOdoMeshComponent;
	let fuelAltWidget = car.FindComponentByName(n"fuel_alt_widget") as VM3DOdoWidgetComponent;

	let odoAltMesh = car.FindComponentByName(n"odo_alt_mesh") as VM3DOdoMeshComponent;
	let odoAltWidget = car.FindComponentByName(n"odo_alt_widget") as VM3DOdoWidgetComponent;

	if !IsDefined(fuelMesh) || !IsDefined(fuelWidget)
		|| !IsDefined(odoMesh) || !IsDefined(odoWidget)
		|| !IsDefined(fuelAltMesh) || !IsDefined(fuelAltWidget)
		|| !IsDefined(odoAltMesh) || !IsDefined(odoAltWidget) {
		this.HideCarMeshes(car);
		this.ArmTick();
		return;
	};

	this.lastFuelMesh = fuelMesh;
	this.lastOdoMesh = odoMesh;
	this.lastFuelAltMesh = fuelAltMesh;
	this.lastOdoAltMesh = odoAltMesh;

  // --------------------------------------------------------------------------
	// Remember the current widget components.
  // --------------------------------------------------------------------------
  this.lastFuelWidget = fuelWidget;
  this.lastOdoWidget = odoWidget;

	this.lastFuelAltWidget = fuelAltWidget;
	this.lastOdoAltWidget = odoAltWidget;

  // --------------------------------------------------------------------------
  // Read VehicleMileage facts once
  // --------------------------------------------------------------------------
	let qs = GameInstance.GetQuestsSystem(GetGameInstance());

	let meters: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_hud_meters") : 0;
	let fuel: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_hud_fuel_permille") : 0;

	let fuelHidden: Bool = IsDefined(qs) && qs.GetFact(n"vm_3d_fuel_hidden") > 0;
	let odoHidden: Bool = IsDefined(qs) && qs.GetFact(n"vm_3d_odo_hidden") > 0;
	
	let fuelAltHidden: Bool = IsDefined(qs) && qs.GetFact(n"vm_3d_fuel_alt_hidden") > 0;
	let odoAltHidden: Bool = IsDefined(qs) && qs.GetFact(n"vm_3d_odo_alt_hidden") > 0;

	let km: Int32 = meters / 1000;
	let odoText: String = this.Pad6(km);

  // --------------------------------------------------------------------------
  // Fuel widget: show fuel gauge only
  // --------------------------------------------------------------------------
	let fuelHud = fuelWidget.GetHUD();

	if IsDefined(fuelHud) {
		fuelMesh.ApplyLivePlacementFor(car);
		fuelWidget.ApplyLivePlacementFromMesh(fuelMesh);
		fuelHud.Load(fuelMesh);

		if fuelHidden {
			fuelHud.VM_SetVisible(false);
		} else {
			fuelHud.VM_SetMode(1); // 1 = fuel only
			fuelHud.VM_SetFuelGaugeData(odoText, fuel);
		};
	} else {
		fuelMesh.VM_HardHide();
		// LogChannel(n"DEBUG", "[OdoHUD] fuel_widget controller is NULL");
	};

  // --------------------------------------------------------------------------
  // ODO widget: show ODO plate only
  // --------------------------------------------------------------------------
	let odoHud = odoWidget.GetHUD();

	if IsDefined(odoHud) {
		odoMesh.ApplyLivePlacementFor(car);
		odoWidget.ApplyLivePlacementFromMesh(odoMesh);
		odoHud.Load(odoMesh);

		if odoHidden {
			odoHud.VM_SetVisible(false);
		} else {
			odoHud.VM_SetMode(2); // 2 = ODO plate only
			odoHud.VM_SetFuelGaugeData(odoText, fuel);
		};
	} else {
		odoMesh.VM_HardHide();
		// LogChannel(n"DEBUG", "[OdoHUD] odo_widget controller is NULL");
	};
	
	// --------------------------------------------------------------------------
	// Fuel Alt widget: show fuel gauge only
	// --------------------------------------------------------------------------
	let fuelAltHud = fuelAltWidget.GetHUD();

	if IsDefined(fuelAltHud) {
		fuelAltMesh.ApplyLivePlacementFor(car);
		fuelAltWidget.ApplyLivePlacementFromMesh(fuelAltMesh);
		fuelAltHud.Load(fuelAltMesh);

		if fuelAltHidden {
			fuelAltHud.VM_SetVisible(false);
		} else {
			fuelAltHud.VM_SetMode(3); // 3 = fuel alt only
			fuelAltHud.VM_SetFuelGaugeData(odoText, fuel);
		};
	} else {
		fuelAltMesh.VM_HardHide();
	};

	// --------------------------------------------------------------------------
	// ODO Alt widget: show ODO plate only
	// --------------------------------------------------------------------------
	let odoAltHud = odoAltWidget.GetHUD();

	if IsDefined(odoAltHud) {
		odoAltMesh.ApplyLivePlacementFor(car);
		odoAltWidget.ApplyLivePlacementFromMesh(odoAltMesh);
		odoAltHud.Load(odoAltMesh);

		if odoAltHidden {
			odoAltHud.VM_SetVisible(false);
		} else {
			odoAltHud.VM_SetMode(4); // 4 = ODO plate alt only
			odoAltHud.VM_SetFuelGaugeData(odoText, fuel);
		};
	} else {
		odoAltMesh.VM_HardHide();
	};

  this.ArmTick();
}

private func HideLastWidget() -> Void {
	if IsDefined(this.lastFuelMesh) { this.lastFuelMesh.VM_HardHide(); };
	if IsDefined(this.lastOdoMesh) { this.lastOdoMesh.VM_HardHide(); };
	if IsDefined(this.lastFuelAltMesh) { this.lastFuelAltMesh.VM_HardHide(); };
	if IsDefined(this.lastOdoAltMesh) { this.lastOdoAltMesh.VM_HardHide(); };

  if IsDefined(this.lastFuelWidget) {
    let fuelHud = this.lastFuelWidget.GetHUD();
    if IsDefined(fuelHud) {
      fuelHud.VM_SetVisible(false);
    };
  };

  if IsDefined(this.lastOdoWidget) {
    let odoHud = this.lastOdoWidget.GetHUD();
    if IsDefined(odoHud) {
      odoHud.VM_SetVisible(false);
    };
  };
	if IsDefined(this.lastFuelAltWidget) {
		let fuelAltHud = this.lastFuelAltWidget.GetHUD();
		if IsDefined(fuelAltHud) {
			fuelAltHud.VM_SetVisible(false);
		};
	};

	if IsDefined(this.lastOdoAltWidget) {
		let odoAltHud = this.lastOdoAltWidget.GetHUD();
		if IsDefined(odoAltHud) {
			odoAltHud.VM_SetVisible(false);
		};
	};
}

private func ArmTick() -> Void {
  if this.tickArmed {
    return;
  };

  let ds = GameInstance.GetDelaySystem(GetGameInstance());
  if !IsDefined(ds) {
    return;
  };

  this.tick = VM3DOdoTick.Create(this);
  this.tickArmed = true;
  ds.DelayCallback(this.tick, this.tickPeriod, false);
}

private func Pad6(n: Int32) -> String {
  if n < 0 {
    n = 0;
  };

  let d5: Int32 = (n / 100000) % 10;
  let d4: Int32 = (n / 10000) % 10;
  let d3: Int32 = (n / 1000) % 10;
  let d2: Int32 = (n / 100) % 10;
  let d1: Int32 = (n / 10) % 10;
  let d0: Int32 = n % 10;

  return IntToString(d5) + IntToString(d4) + IntToString(d3) + IntToString(d2) + IntToString(d1) + IntToString(d0);
}
}

private func VM_GenerateCRUID(component: CName) -> CRUID {
  let hash: Uint64 = 17293822569102704640ul | Cast<Uint64>(BitShiftL32(FNV1a32(NameToString(component)), 2));
  return ToCRUID(hash);
}
// ============================================================================
// Safety touch: make sure the service exists after player control.
// ============================================================================
@addField(PlayerPuppet)
private let vm3dOdoSvc: ref<VM3DOdoService>;

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(resolver: EntityResolveComponentsInterface) -> Bool {
  let r = wrappedMethod(resolver);

  if !IsDefined(this.vm3dOdoSvc) {
    this.vm3dOdoSvc = new VM3DOdoService();
  };

  this.vm3dOdoSvc.Start();
  this.vm3dOdoSvc.Tick();

  return r;
}
