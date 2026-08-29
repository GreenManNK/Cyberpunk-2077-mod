module VehicleMileage.UI

import Codeware.UI.VirtualResolutionWatcher

public class VM_FuelGaugeTick extends DelayCallback {
  private let hud: wref<VM_FuelGauge>;
  private let generation: Int32;

  public static func Create(
    h: ref<VM_FuelGauge>,
    generation: Int32
  ) -> ref<VM_FuelGaugeTick> {
    let t = new VM_FuelGaugeTick();
    t.hud = h;
    t.generation = generation;
    return t;
  }

  public func Call() -> Void {
    if IsDefined(this.hud)
      && this.hud.VM_IsCallbackGeneration(this.generation) {

      this.hud.__armed = false;
      this.hud.Refresh();
      this.hud.ArmNextTick();
    }
  }
}

// high-frequency animation tick (boot/shutdown only)
public class VM_FGAnimTick extends DelayCallback {
  private let hud: wref<VM_FuelGauge>;
  private let generation: Int32;

  public static func Create(
    h: ref<VM_FuelGauge>,
    generation: Int32
  ) -> ref<VM_FGAnimTick> {
    let t = new VM_FGAnimTick();
    t.hud = h;
    t.generation = generation;
    return t;
  }

  public func Call() -> Void {
    if IsDefined(this.hud)
      && this.hud.VM_IsCallbackGeneration(this.generation) {

      this.hud.__animArmed = false;
      this.hud.AnimStep();
    }
  }
}

public class VM_FuelGauge extends IScriptable {
  // timing
  private let tick: ref<VM_FuelGaugeTick>;
  private let period: Float = 0.10; // logic/update tick (~10 Hz)
  public let __armed: Bool;
  private let callbackGeneration: Int32;

  // high-frequency animation tick for boot/shutdown (~60 fps feel)
  private let animTick: ref<VM_FGAnimTick>;
  private let ANIM_PERIOD: Float = 0.016; // ~60 fps
  public let __animArmed: Bool;

  // ink roots
  private let vrw: ref<VirtualResolutionWatcher>;
  private let rootFS: wref<inkCanvas>;
	private let place:  wref<inkCanvas>;
  private let root:   wref<inkCanvas>;
  private let needle: wref<inkCanvas>; // we’ll rotate a small canvas that holds the segments

	// user transform cache
	private let lastUserDx: Float;
	private let lastUserDy: Float;
	private let lastUserScale: Float;

  // caches
  private let built: Bool;
  private let lastPermille: Int32;
	
  // Bootup animation
  private let bootupActive: Bool;
  private let bootupTimer: Float;
  private let bootupPhase: Float;
  private let BOOTUP_DURATION: Float = 0.75;
  private let BOOTUP_SCALE_START: Float = 0.6;
  private let BOOTUP_ALPHA_START: Float = 0.0;

  // shutdown (CRT-style) animation
  private let shutdownActive: Bool;
  private let shutdownTimer: Float;
  private let shutdownPhase: Float;
  private let SHUTDOWN_DURATION: Float = 0.17;

  // visibility state
  private let lastVisible: Bool;   // currently drawn (incl. boot/shutdown)
  private let wantVisible: Bool;   // what facts/modalDepth want
  private let blinkOn: Bool;
	private let lastWarnState: Int32; // -1 = uninitialized, 0 = none, 1 = soon, 2 = empty

	// quick references so we can recolor without searching
	private let tickRefs: array<wref<inkRectangle>>;
	private let reserveCount: Int32;          // how many “red reserve” ticks on the left
	private let ndBaseRef: wref<inkRectangle>;
	private let ndMidRef:  wref<inkRectangle>;
	private let ndTipRef:  wref<inkRectangle>;
	private let ndHLRef:   wref<inkRectangle>;

	// ── Fuel gauge color themes ────────────────────────────────────────────────
	// CET fact: vm_fg_theme
	// 0 = current/default
	// 1 = cyberpunk yellow
	// 2 = E3 red
	// 3 = mox pink
	// 4 = blue
	// 5 = light blue
	// 6 = neon green
	// 7 = silver
	// 8 = gold
	// 9 = pure yellow
	private let fgThemeLast: Int32;
	private let hubRef: wref<inkRectangle>;
	private let lblERef: wref<inkText>;
	private let lblFRef: wref<inkText>;
	// For hiding HUD at phone
	private let modalDepth: Int32;
	// pump refs (for flashing/glow only)
	private let pumpWrapRef: wref<inkCanvas>;
	private let pumpRef:     wref<inkCanvas>;
	private let pumpGlowRef: wref<inkRectangle>; // soft glow behind pump
	private let pumpBodyRef: wref<inkRectangle>; // main pump body tint
	private let pumpWinRef: wref<inkRectangle>;
	private let pBaseRef:  wref<inkRectangle>;
	private let pStemRef:  wref<inkRectangle>;
	private let pNozRef:   wref<inkRectangle>;
	private let hose1Ref:  wref<inkRectangle>;
	private let hose2Ref:  wref<inkRectangle>;
	private let pShadowRef: wref<inkRectangle>; // optional; we’ll keep it steady

  // Pump
  private let pumpImgRef: wref<inkImage>;
	
	// Temp meter (right side of gauge)
  private let tempWrapRef:  wref<inkCanvas>;
  private let tempBGRef:    wref<inkImage>;
  private let tempFrameRef: wref<inkImage>;
	// cache: last applied visibility for the temp meter
	private let tempVisibleCached: Bool;


  // ── Temp labels highlight state (40/60/80/120/160) ────────────────────────
  private let tempLblRefs:       array<wref<inkText>>;
  private let tempLblVals:       array<Int32>;
  private let tempLblActiveIdx:  Int32;
  private let tempLblPhase01:    Float;
  private let TEMP_LBL_COUNT:    Int32 = 6;           // +100°C

  // Tunables: transparency + shimmer feel
  private let TEMP_LBL_ALPHA_BASE:    Float = 0.20;   // idle labels: slightly more transparent
  private let TEMP_LBL_ALPHA_ACTIVE:  Float = 1.00;
  private let TEMP_LBL_SHIMMER_HZ:    Float = 1.50;
  private let TEMP_LBL_SHIMMER_AMPL:  Float = 0.06;


	// TempBG tint smoothing
  private let oilTint: HDRColor;
  private let oilTintInited: Bool;
  private let oilTempVisC: Float;

  // ── Refuel pulse (green wobble) ───────────────────────────────────────────
  private let refuelActive: Bool;          // are we currently refueling?
  private let refuelUpTicks: Int32;        // consecutive rising fuel ticks
  private let refuelDownTimer: Float;      // seconds since last rise (for hysteresis)
  private let refuelPhase01: Float;        // 0..1 phase for the wobble sine
  private let pumpScaleSmoothed: Float;    // smoothed scale multiplier (around 1.0)

  // Tunables
  private let REFUEL_WOBBLE_HZ:   Float = 1.2;    // a bit slower = smoother
  private let REFUEL_WOBBLE_AMPL: Float = 0.08;   // a bit smaller = smoother
  private let REFUEL_DETECT_TICKS: Int32 = 2;     // need 2 rising ticks to arm
  private let REFUEL_HYST_SEC:    Float = 0.50;   // grace time after rise stops
  private let REFUEL_SMOOTH_TAU:  Float = 0.12;   // smoothing time constant (sec)
	
	// ── First-seconds self-heal for placement ─────────────────────────────────
  private let fgReassertLeft: Float;       // seconds left to keep re-applying
  private let fgReassertCool: Float;       // cooldown between re-applies
  private let FG_REASSERT_WINDOW: Float = 3.00;  // total duration to self-heal
  private let FG_REASSERT_EVERY:  Float = 0.33;  // how often to re-apply

  // ODO refs
  private let odoWrapRef: wref<inkCanvas>;
	private let odoLblRef:  wref<inkText>;
	private let odoValRef:  wref<inkText>;
	private let lastOdoM:   Int32;
	private let odoFillRef:   wref<inkImage>;
	private let odoStrokeRef: wref<inkImage>;	


	// ODO layout
	private let ODO_W: Float       = 420.0;   // plate width (match your atlas sprites)
	private let ODO_H: Float       = 66.0;    // plate height
	private let ODO_PAD_L: Float   = 22.0;    // left padding for "ODO"
	private let ODO_PAD_R: Float   = 24.0;    // right padding for the digits
	private let ODO_OFFSET_Y: Float = 150.0;  // how far below the gauge crown (tweak to taste)

	// ODO group
	private let lastOdoScale: Float;
	private let ODO_SCALE_DEFAULT: Float = 0.84; 

	// --- ODO spinner (all fields at CLASS scope) ---
	private let odoSpinWrapRef: wref<inkCanvas>;
	private let odoSpinImgRef:  wref<inkImage>;

	private let spinAngle: Float;        // deg
	private let spinOmega: Float;        // deg/sec (smoothed)
	private let spinResp:  Float = 7.0;  // smoothing aggressiveness (with period=0.25s, alpha≈0.75)

	// speed → deg/sec mapping
	private let SPIN_DEG_PER_SEC_PER_KMH: Float = 2.0;  // 100 km/h -> 200°/s
	private let SPIN_IDLE_DEG_PER_SEC:      Float = 0.0; // baseline spin at 0 km/h (set >0 to test)

	
	  // ---- Vehicle condition icon (engine) ----
  private let engineWrapRef: wref<inkCanvas>;
  private let engineImgRef:  wref<inkImage>;
  private let condLastPct:   Int32;

  // Placement for the engine icon (left of pump; unsquashed)
  private let ENGINE_SCALE:  Float = 0.60;
  private let ENGINE_DX:     Float = 160.0;  // ← move left/right
  private let ENGINE_DY:     Float = 30.0;     // ↑/↓ fine offset relative to pump Y
	
	 // Temp meter (right of pump; unsquashed)
  private let TEMP_SCALE:   Float = 0.75;     // 1.0 = atlas/native size; tweak to taste
  private let TEMP_DX:      Float = 470.0;    // → move right from centre (mirror of ENGINE_DX)
  private let TEMP_DY:      Float = 30.0;     // ↑/↓ fine offset relative to pump Y
  // native atlas pixel sizes (DO NOT CHANGE)
	private let TEMP_BG_W0:   Float = 41.0;
	private let TEMP_BG_H0:   Float = 127.0;
	private let TEMP_FR_W0:   Float = 28.0;
	private let TEMP_FR_H0:   Float = 128.0;

	// desired drawn height (both parts will end up with this height × TEMP_SCALE)
	private let TEMP_TARGET_H: Float = 320.0;




	private let  TEMP_FR_DX:  Float = 15.0;   // NEW: frame-only X offset
	private let  TEMP_FR_DY:  Float = 0.0;   // NEW: frame-only Y offset (if needed)
	
	private let TEMP_TXT_GAP:   Float = 14.0;
	private let TEMP_TXT_SIZE:  Int32 = 40;     // Digital Readout font size (Int32)
	private let TEMP_TXT_ALPHA: Float = 0.85;
	private let TEMP_FONT:      String = "base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily";
	
	// Text color (CP-ish cyan)
  private let TEMP_TXT_R: Float = 0.80;
  private let TEMP_TXT_G: Float = 0.95;
  private let TEMP_TXT_B: Float = 1.00;

  // Oil → color mapping & smoothing (°C)
	private let OIL_C_MIN: Float = 40.0;   // blue starts
	private let OIL_C1:    Float = 70.0;   // light green
	private let OIL_C2:    Float = 80.0;   // green
	private let OIL_CX:    Float = 100.0;  // mid (yellow/amber)
	private let OIL_C3:    Float = 120.0;  // red zone begins
	private let OIL_C_MAX: Float = 160.0;  // dark red
	private let OIL_TINT_K: Float = 6.0;   // smoothing speed (higher = snappier)

  // ---- Alarm overlay (on top of the whole widget) ----
  private let alarmImgRef:   wref<inkImage>;
  private let alarmActive:   Bool;
  private let alarmVisible:  Bool;
  private let alarmTimer:    Float;

  // Position/scale for the overlay (edit to taste)
  private let ALARM_SCALE:   Float = 0.30;
  private let ALARM_DX:      Float = 0.0;
  private let ALARM_DY:      Float = 25.0;


  // Fade state
  private let alarmPhase:    Int32; // 0=off, 1=fade-in, 2=hold, 3=fade-out, 4=gap
  private let alarmAlpha:    Float;

  // Timings
  private let ALARM_FADE_IN:  Float = 0.15;
  private let ALARM_HOLD:     Float = 0.50;
  private let ALARM_FADE_OUT: Float = 0.15;
  private let ALARM_GAP:      Float = 1.40; // pause before next flash

	private let bootApplied: Bool; // false at start
	
	

  // geometry / layout
  private let RIM_R: Float   = 360.0;      // circle radius (pre-squash)
  private let SCALE_Y: Float = 0.42;       // Y-only squash to get car-gauge look
	private let SCALE_X: Float = 0.50; // 1.00 = no stretch, >1 wider, <1 narrower
  private let DEG2RAD: Float = 0.0174532925;

  // ticks: count and style
  private let TICK_COUNT: Int32 = 13;      // odd → centre tick at crown (90°)
  private let RED_TICKS: Int32  = 3;       // leftmost reserve painted red

  // widths
  private let W_MAJOR: Float = 22.0;
  private let W_MED:   Float = 14.0;
  private let W_MIN:   Float = 8.0;

  // shared inner baseline (all ticks align here on the inner side)
  private let INNER_DEPTH: Float = 46.0;   // inner radius = RIM_R - 46

  // outward lengths (toward rim)
  private let L_OUT_MAJOR: Float = 53.0;   // majors stick ~12px past rim
  private let L_OUT_MED:   Float = 50.0;   // mediums ~4px past
  private let L_OUT_MIN:   Float = 36.0;   // minors ~10px short

  // inward lengths (toward centre)
  private let L_IN_MAJOR: Float = 22.0;    // majors reach deeper inward
  private let L_IN_MED:   Float = 10.0;
  private let L_IN_MIN:   Float = 6.0;
	
	// Pump scale
	private let PUMP_SCALE:   Float = 0.80; // 1.0 = original size, >1 bigger, <1 smaller
	private let PUMP_OFFSET_Y: Float = 0.36; // fraction of radius above center (0.34–0.42 sweet spot)


	// needle (tapered)
	private let ND_BASE_W:  Float = 45.0;  // widest at hub
	private let ND_MID_W:   Float = 20.0;
	private let ND_TIP_W:   Float = 25.0;   // narrow tip
	private let ND_HL_W:    Float = 2.0;   // thin center highlight
	// how much of ndLen each segment uses (0..1)
	private let ND_BASE_RATIO: Float = 0.28;
	private let ND_MID_RATIO:  Float = 0.42;
	private let ND_TIP_RATIO:  Float = 0.95;   // raise to 0.85–0.95 if you want it longer
	// fixed-distance from rim (smaller pad = longer needle)
	private let ND_LEN_PAD:    Float = 10.0;    // try 6–10



  // Move/scale from facts (use code-defaults when facts are 0/0/0)
	private func ApplyUserTransform() -> Void {
		if !IsDefined(this.place) { return; }
		let qs = GameInstance.GetQuestsSystem(GetGameInstance());

		let fdx: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_gauge_dx") : 0;
		let fdy: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_gauge_dy") : 0;
		let fsc: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_gauge_scale_milli") : 0;

		// initialize with code defaults (match init.lua FG_DEF_*)
		let dx: Float = -this.FG_DEF_DX_MAG;
		let dy: Float =  this.FG_DEF_DY_PX;
		let sc: Float =  this.FG_DEF_SCALE;

		// If any facts are non-zero, override the corresponding field(s)
		if !(fdx == 0 && fdy == 0 && fsc == 0) {
			dx = (fdx == 0) ? this.lastUserDx : Cast<Float>(fdx);
			dy = (fdy == 0) ? this.lastUserDy : Cast<Float>(fdy);
			sc = (fsc == 0) ? this.lastUserScale : (Cast<Float>(fsc) / 600.0);  // 600 = 1.00x

		}

		if sc < 0.20 { sc = 0.20; } else if sc > 2.00 { sc = 2.00; };

		if dx != this.lastUserDx || dy != this.lastUserDy || sc != this.lastUserScale {
			this.place.SetTranslation(new Vector2(dx, dy));
			this.place.SetScale(new Vector2(sc, sc));
			this.lastUserDx = dx;
			this.lastUserDy = dy;
			this.lastUserScale = sc;
		}
	}


	private func MakeTempLabel(tempWrap: wref<inkCanvas>, sBG: Float, value: String, normFromBottom: Float, dxPx: Float) -> ref<inkText> {
		let t: ref<inkText> = new inkText();
		t.SetInteractive(false);
		t.SetFontFamily(this.TEMP_FONT);
		t.SetFontStyle(n"Regular");
		t.SetFontSize(this.TEMP_TXT_SIZE);

		let c: HDRColor;
		c.Red   = this.TEMP_TXT_R;
		c.Green = this.TEMP_TXT_G;
		c.Blue  = this.TEMP_TXT_B;
		c.Alpha = this.TEMP_LBL_ALPHA_BASE;      // idle = slightly transparent
		t.SetTintColor(c);

		t.SetText(value);
		t.SetAnchor(inkEAnchor.Centered);
		t.SetAnchorPoint(new Vector2(0.0, 0.5));
		t.SetHAlign(inkEHorizontalAlign.Left);
		t.SetVAlign(inkEVerticalAlign.Center);

		let drawH_BG: Float = this.TEMP_BG_H0 * sBG;
		let drawW_BG: Float = this.TEMP_BG_W0 * sBG;
		let colX: Float = (drawW_BG * 0.5) + this.TEMP_TXT_GAP + this.TEMP_FR_DX + dxPx;
		let y: Float = (drawH_BG * 0.5) - (normFromBottom * drawH_BG) + this.TEMP_FR_DY;

		t.SetTranslation(new Vector2(colX, y));
		t.Reparent(tempWrap);
		return t;
	}

  // placement (virtual 3840×2160; +Y down)
  private let OFFSET_Y: Float = 620.0;     // bottom-centre

	// ── FuelGauge code-defaults ─────────────────────────────────
	// DX is stored as a positive magnitude (compiler requires literal constant);
	// we apply the negative when using it (default direction = LEFT).
	private let FG_DEF_DX_MAG:  Float = 1510.0;    // px
	private let FG_DEF_DY_PX:   Float =  275.0;    // px
	private let FG_DEF_SCALE:   Float =    0.55;   // 330 milli

public func OnNewWorld() -> Void {
		if IsDefined(this.alarmImgRef) {
			this.alarmImgRef.SetOpacity(0.0);
			this.alarmImgRef.SetVisible(false);
		}
		if IsDefined(this.root) {
			this.root.SetOpacity(0.0);
			this.root.SetVisible(false);
		}

    this.callbackGeneration += 1;
    this.built = false;
    this.__armed = false;
    this.__animArmed = false;
    this.animTick = null;

    this.lastPermille = -1;
				this.lastOdoM = -1;
    this.lastVisible  = false;
    this.wantVisible  = false;

    this.bootupActive    = false;
    this.shutdownActive  = false;
    this.bootupTimer     = 0.0;
    this.bootupPhase     = 0.0;
    this.shutdownTimer   = 0.0;
    this.shutdownPhase   = 0.0;

    this.rootFS = null;
    this.root   = null;
    this.needle = null;
    this.blinkOn = false;
		this.lastWarnState = -1;
		ArrayClear(this.tickRefs);
		this.reserveCount = 0;
		this.ndBaseRef = null;
		this.ndMidRef  = null;
		this.ndTipRef  = null;
		this.ndHLRef   = null;
		this.modalDepth = 0;
		this.fgThemeLast = -999;
		this.hubRef = null;
		this.lblERef = null;
		this.lblFRef = null;
    this.refuelActive      = false;
    this.refuelUpTicks     = 0;
    this.refuelDownTimer   = 0.0;
    this.refuelPhase01     = 0.0;
    this.pumpScaleSmoothed = 1.0;   // base scale when idle
		// placement self-heal
    this.fgReassertLeft = this.FG_REASSERT_WINDOW;
    this.fgReassertCool = 0.0;
		ArrayClear(this.tempLblRefs);
		ArrayClear(this.tempLblVals);
		this.tempLblActiveIdx = -1;
		this.tempLblPhase01   = 0.0;
		this.pumpWrapRef = null;
		this.pumpRef     = null;
		this.pumpGlowRef = null;
		this.pumpBodyRef = null;
		this.pumpWinRef = null;
		this.pBaseRef = null;
		this.pStemRef = null;
		this.pNozRef = null;
		this.hose1Ref = null;
		this.hose2Ref = null;
		this.pShadowRef = null;
		this.place = null;
		this.lastUserDx = 9999999.0;     // force first-apply
		this.lastUserDy = 9999999.0;
		this.lastUserScale = 9999999.0;
		this.odoWrapRef = null;
		this.odoLblRef  = null;
		this.odoValRef  = null;
		this.lastOdoM   = -1;
		this.odoFillRef = null;
		this.odoStrokeRef = null;
		this.lastOdoScale = -1.0;
		this.pumpImgRef = null;
		this.odoSpinWrapRef = null;
		this.odoSpinImgRef  = null;
		this.spinAngle      = 0.0;
		this.spinOmega = 0.0;
    this.engineWrapRef = null;
    this.engineImgRef  = null;
    this.condLastPct   = -999;
    this.alarmImgRef   = null;
    this.alarmActive   = false;
    this.alarmVisible  = false;
    this.alarmTimer    = 0.0;
		this.alarmPhase    = 0;
    this.alarmAlpha    = 0.0;
		// reset temp meter refs & tint state
    this.tempWrapRef   = null;
    this.tempBGRef     = null;
    this.tempFrameRef  = null;
    this.oilTintInited = false;
    this.oilTempVisC   = 0.0;
		// reset temp visibility cache
		this.tempVisibleCached = false; // default off until we read the fact

  }

  public func VM_IsCallbackGeneration(generation: Int32) -> Bool {
    return generation == this.callbackGeneration;
  }
	
	
  // hide duplicate slots after hot-reload
  private func PruneDuplicates(rootNode: wref<inkCompoundWidget>) -> Void {
    if !IsDefined(rootNode) { return; }
    let n: Int32 = rootNode.GetNumChildren();
    let seen: Int32 = 0;
    let i: Int32 = 0;
    while i < n {
      let w: wref<inkWidget> = rootNode.GetWidget(i);
      if IsDefined(w) && Equals(w.GetName(), n"VM_FuelGaugeSlot") {
        if seen == 0 { seen = 1; } else { w.SetVisible(false); }
      }
      i += 1;
    }
  }

	public func OnContextPushed() -> Void {
		this.modalDepth += 1;
		this.ApplyVisibilityGate();
	}

	public func OnContextPopped() -> Void {
		if this.modalDepth > 0 { this.modalDepth -= 1; }
		this.ApplyVisibilityGate();
	}

  public func Ensure() -> Void {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return; }
    let layer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(layer) { return; }
    let vwin: ref<inkCompoundWidget> = layer.GetVirtualWindow();
    if !IsDefined(vwin) { return; }
    let rootNode = vwin.GetWidgetByPathName(n"Root") as inkCompoundWidget;
    if !IsDefined(rootNode) { return; }

    this.PruneDuplicates(rootNode);

    if !this.built {
      // fullscreen canvas
      let fs: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/VM_FuelGaugeSlot") as inkCanvas;
      if !IsDefined(fs) {
        fs = new inkCanvas();
        fs.SetName(n"VM_FuelGaugeSlot");
        fs.SetSize(new Vector2(3840.0, 2160.0));
        fs.SetRenderTransformPivot(new Vector2(0.0, 0.0));
        fs.SetInteractive(false);
        fs.Reparent(rootNode);
      } else { fs.SetInteractive(false); }
      this.rootFS = fs;

      if !IsDefined(this.vrw) { this.vrw = new VirtualResolutionWatcher(); this.vrw.Initialize(GetGameInstance()); }
      this.vrw.ScaleWidget(fs);
			
			// --- move/scale wrapper (center-anchored) ---
			let place: ref<inkCanvas> = fs.GetWidgetByPathName(n"VM_FuelPlace") as inkCanvas;
			if !IsDefined(place) {
				place = new inkCanvas();
				place.SetName(n"VM_FuelPlace");
				place.SetInteractive(false);
				place.SetFitToContent(true);
				place.SetAnchor(inkEAnchor.Centered);
				place.SetAnchorPoint(new Vector2(0.5, 0.5));
				place.Reparent(fs);
			}
			this.place = place;

      // bottom-centred container (Y-squashed)
      let cont: ref<inkCanvas> = fs.GetWidgetByPathName(n"GaugeRoot") as inkCanvas;
      if !IsDefined(cont) {
        cont = new inkCanvas();
        cont.SetName(n"GaugeRoot");
        cont.SetInteractive(false);
        cont.SetFitToContent(true);
        cont.SetAnchor(inkEAnchor.Centered);
        cont.SetAnchorPoint(new Vector2(0.5, 0.5));
        cont.Reparent(place);
      }
      cont.SetTranslation(new Vector2(0.0, this.OFFSET_Y));
      cont.SetScale(new Vector2(this.SCALE_X, this.SCALE_Y));
			cont.SetVisible(false);
      this.root = cont;

      // colours
			// colours (CP2077 style)
			let cpCyan: HDRColor;      cpCyan.Red=0.35; cpCyan.Green=0.95; cpCyan.Blue=1.00; cpCyan.Alpha=1.0;
			let cpCyanSoft: HDRColor;  cpCyanSoft.Red=0.70; cpCyanSoft.Green=0.92; cpCyanSoft.Blue=0.98; cpCyanSoft.Alpha=1.0;
			let cpWhite: HDRColor;     cpWhite.Red=0.92; cpWhite.Green=0.95; cpWhite.Blue=0.98; cpWhite.Alpha=1.0;
			let amber: HDRColor;       amber.Red=1.0; amber.Green=0.80; amber.Blue=0.10; amber.Alpha=1.0;
			let red: HDRColor;         red.Red=1.0; red.Green=0.22; red.Blue=0.22; red.Alpha=1.0;


      // PumpWrap (unsquashed)
			let pumpWrap: ref<inkCanvas> = new inkCanvas();
			pumpWrap.SetName(n"PumpWrap");
			pumpWrap.SetInteractive(false);
			pumpWrap.SetFitToContent(true);
			pumpWrap.SetAnchor(inkEAnchor.Centered);
			pumpWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
			pumpWrap.SetTranslation(new Vector2(0.0, -this.RIM_R * this.PUMP_OFFSET_Y));
			pumpWrap.SetScale(new Vector2(1.0 / this.SCALE_X, 1.0 / this.SCALE_Y));
			pumpWrap.Reparent(cont);
			this.pumpWrapRef = pumpWrap;

			// (optional, currently unused)
			let pumpGlow: ref<inkRectangle> = new inkRectangle();
			pumpGlow.SetName(n"PumpGlow");
			pumpGlow.SetSize(new Vector2(140.0, 140.0));
			pumpGlow.SetAnchor(inkEAnchor.Centered);
			pumpGlow.SetAnchorPoint(new Vector2(0.5, 0.5));
			pumpGlow.SetOpacity(0.0);
			let glowDefault: HDRColor; glowDefault.Red=1.0; glowDefault.Green=0.8; glowDefault.Blue=0.1; glowDefault.Alpha=1.0;
			pumpGlow.SetTintColor(glowDefault);
			pumpGlow.Reparent(pumpWrap);
			this.pumpGlowRef = pumpGlow;

			// PumpIcon (atlas sprite we flash)
			let pump: ref<inkCanvas> = new inkCanvas();
			pump.SetName(n"PumpIcon");
			pump.SetInteractive(false);
			pump.SetFitToContent(true);
			pump.SetAnchor(inkEAnchor.Centered);
			pump.SetAnchorPoint(new Vector2(0.5, 0.5));
			pump.SetRenderTransformPivot(new Vector2(0.5, 0.5));
			pump.SetScale(new Vector2(this.PUMP_SCALE, this.PUMP_SCALE));
			pump.Reparent(pumpWrap);
			this.pumpRef = pump;

			// Single image from Villefort Deleon atlas
			let pumpImg: ref<inkImage> = new inkImage();
			pumpImg.SetName(n"PumpSprite");
			pumpImg.SetAtlasResource(r"ep1\\gameplay\\gui\\widgets\\vehicle\\sport\\v_sport2_villefort_deleon\\villefort_deleon.inkatlas");
			pumpImg.SetTexturePart(n"fuel");
			pumpImg.SetAnchor(inkEAnchor.Centered);
			pumpImg.SetAnchorPoint(new Vector2(0.5, 0.5));

			// Pick a starting size; tweak if needed (scale still applied by PUMP_SCALE)
			pumpImg.SetSize(new Vector2(96.0, 96.0));

			// default tint = neutral light grey (same vibe as before)
			let pumpGrey: HDRColor; pumpGrey.Red=0.92; pumpGrey.Green=0.92; pumpGrey.Blue=0.92; pumpGrey.Alpha=1.0;
			pumpImg.SetTintColor(cpCyan);
			pumpImg.SetOpacity(1.0);

			pumpImg.Reparent(pump);
			this.pumpImgRef = pumpImg;

			// kill any background glow (kept just in case)
			if IsDefined(this.pumpGlowRef) { this.pumpGlowRef.SetOpacity(0.0); }

      // ======= ENGINE ICON (vehicle condition) =======
      let engWrap: ref<inkCanvas> = new inkCanvas();
      engWrap.SetName(n"EngineWrap");
      engWrap.SetInteractive(false);
      engWrap.SetFitToContent(true);
      engWrap.SetAnchor(inkEAnchor.Centered);
      engWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
      // place to the LEFT of the pump, same vertical band as pump (unsquashed)
      engWrap.SetTranslation(new Vector2(-this.ENGINE_DX, -this.RIM_R * this.PUMP_OFFSET_Y + this.ENGINE_DY));
      engWrap.SetScale(new Vector2(1.0 / this.SCALE_X, 1.0 / this.SCALE_Y));
      engWrap.Reparent(cont);
      this.engineWrapRef = engWrap;

      let engImg: ref<inkImage> = new inkImage();
      engImg.SetName(n"EngineSprite");
      engImg.SetAtlasResource(r"ep1\\gameplay\\gui\\widgets\\vehicle\\sport\\v_sport2_villefort_deleon\\villefort_deleon.inkatlas");
      engImg.SetTexturePart(n"engine");
      engImg.SetAnchor(inkEAnchor.Centered);
      engImg.SetAnchorPoint(new Vector2(0.5, 0.5));
      engImg.SetRenderTransformPivot(new Vector2(0.5, 0.5));
      engImg.SetSize(new Vector2(96.0, 96.0));
      engImg.SetScale(new Vector2(this.ENGINE_SCALE, this.ENGINE_SCALE));
      // start green-ish
      let startG: HDRColor; startG.Red=0.36; startG.Green=0.95; startG.Blue=0.40; startG.Alpha=1.0;
      engImg.SetTintColor(startG);
      engImg.SetOpacity(1.0);
      engImg.Reparent(engWrap);
      this.engineImgRef = engImg;
			
			 // ======= TEMP METER (right side of gauge) =======
      let tempWrap: ref<inkCanvas> = new inkCanvas();
      tempWrap.SetName(n"TempWrap");
      tempWrap.SetInteractive(false);
      tempWrap.SetFitToContent(true);
      tempWrap.SetAnchor(inkEAnchor.Centered);
      tempWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
      tempWrap.SetRenderTransformPivot(new Vector2(0.5, 0.5));

      // place to the RIGHT of the pump, same vertical band as pump (unsquashed)
      tempWrap.SetTranslation(new Vector2(this.TEMP_DX, -this.RIM_R * this.PUMP_OFFSET_Y + this.TEMP_DY));
      tempWrap.SetScale(new Vector2(1.0 / this.SCALE_X, 1.0 / this.SCALE_Y)); // cancel gauge squash
      tempWrap.Reparent(cont);
      this.tempWrapRef = tempWrap;

			// --- Initial Temp visibility (fixes cold start / save-load flash) ---
			let qsInit = GameInstance.GetQuestsSystem(GetGameInstance());
			let tempOnAtBuild: Bool = IsDefined(qsInit) && (qsInit.GetFact(n"vm_fg_temp_visible") > 0);
			// Default to OFF if fact is missing/zero
			this.tempVisibleCached = tempOnAtBuild;
			this.tempWrapRef.SetVisible(tempOnAtBuild);

      // BG fill (rotated 180°)
      let tempBG: ref<inkImage> = new inkImage();
      tempBG.SetName(n"TempBG");
      tempBG.SetAtlasResource(r"ep1\\gameplay\\gui\\widgets\\hazmat\\hazmat.inkatlas");
      tempBG.SetTexturePart(n"tempMeterBGLeft");
      tempBG.SetAnchor(inkEAnchor.Centered);
      tempBG.SetAnchorPoint(new Vector2(0.5, 0.5));
      tempBG.SetRenderTransformPivot(new Vector2(0.5, 0.5));
      tempBG.SetRotation(180.0); // flip 180°
			// BG
			let sBG: Float = (this.TEMP_TARGET_H / this.TEMP_BG_H0) * this.TEMP_SCALE;
			tempBG.SetSize(new Vector2(this.TEMP_BG_W0, this.TEMP_BG_H0));     // native aspect
			tempBG.SetScale(new Vector2(sBG, sBG));                            // uniform
      // neutral tint for the background (optional)
      let bgTint: HDRColor; bgTint.Red=0.35; bgTint.Green=0.45; bgTint.Blue=0.50; bgTint.Alpha=0.60;
      tempBG.SetTintColor(bgTint);
      tempBG.Reparent(tempWrap);
      this.tempBGRef = tempBG;

      // Frame stroke (rotated 180°; drawn on top)
      let tempFrame: ref<inkImage> = new inkImage();
      tempFrame.SetName(n"TempFrame");
      tempFrame.SetAtlasResource(r"ep1\\gameplay\\gui\\widgets\\hazmat\\hazmat.inkatlas");
      tempFrame.SetTexturePart(n"tempMeterFrameLeft");
      tempFrame.SetAnchor(inkEAnchor.Centered);
      tempFrame.SetAnchorPoint(new Vector2(0.5, 0.5));
      tempFrame.SetRenderTransformPivot(new Vector2(0.5, 0.5));
      tempFrame.SetRotation(180.0); // flip 180°
			// Frame
			let sFR: Float = (this.TEMP_TARGET_H / this.TEMP_FR_H0) * this.TEMP_SCALE;
			tempFrame.SetSize(new Vector2(this.TEMP_FR_W0, this.TEMP_FR_H0));  // native aspect
			tempFrame.SetScale(new Vector2(sFR, sFR));                         // uniform
      // bright stroke (optional)
      let frameTint: HDRColor; frameTint.Red=0.92; frameTint.Green=0.95; frameTint.Blue=0.98; frameTint.Alpha=1.0;
      tempFrame.SetTintColor(frameTint);
			// NEW: frame-only local offset (positive DX moves it to the right)
			tempFrame.SetTranslation(new Vector2(this.TEMP_FR_DX, this.TEMP_FR_DY));
      tempFrame.Reparent(tempWrap);
      this.tempFrameRef = tempFrame;

			// ======= TEMP LABELS (to the right of the frame) =======
			ArrayClear(this.tempLblRefs);
			ArrayClear(this.tempLblVals);
			this.tempLblActiveIdx = -1;
			this.tempLblPhase01   = 0.0;

			let L0 = this.MakeTempLabel(tempWrap, sBG, "40",  0.02,  -50.0); ArrayPush(this.tempLblRefs, L0); ArrayPush(this.tempLblVals, 40);
			let L1 = this.MakeTempLabel(tempWrap, sBG, "60",  0.22,  -26.0); ArrayPush(this.tempLblRefs, L1); ArrayPush(this.tempLblVals, 60);
			let L2 = this.MakeTempLabel(tempWrap, sBG, "80",  0.40,  -10.0); ArrayPush(this.tempLblRefs, L2); ArrayPush(this.tempLblVals, 80);
			let Lx = this.MakeTempLabel(tempWrap, sBG, "100", 0.57,  -18.0); ArrayPush(this.tempLblRefs, Lx); ArrayPush(this.tempLblVals, 100);
			let L3 = this.MakeTempLabel(tempWrap, sBG, "120", 0.74,  -26.0); ArrayPush(this.tempLblRefs, L3); ArrayPush(this.tempLblVals, 120);
			let L4 = this.MakeTempLabel(tempWrap, sBG, "160", 0.96,  -50.0); ArrayPush(this.tempLblRefs, L4); ArrayPush(this.tempLblVals, 160);
			// set initial vis for the temp meter from the fact (0/1)
			this.ApplyTempVisibility();


      // ======================= TICKS (inner baseline + in/out lengths) =======================
      let innerR: Float = this.RIM_R - this.INNER_DEPTH;
      let i: Int32 = 0;
			ArrayClear(this.tickRefs);
			let firstMinorPainted: Bool = false;
      while i < this.TICK_COUNT {
        let t: Float = Cast<Float>(i) / Cast<Float>(this.TICK_COUNT - 1); // 0..1 inclusive
        let ang: Float = 180.0 - (180.0 * t);                             // 180 → 0

        // indices for 0%, 25%, 50%, 75%, 100%
				let lastIdx: Int32 = this.TICK_COUNT - 1;
				let q1: Int32 = (lastIdx * 1) / 4;   // 25%
				let mid: Int32 =  lastIdx      / 2;  // 50% (exact when TICK_COUNT is odd)
				let q3: Int32 = (lastIdx * 3) / 4;   // 75%

				let isMajor: Bool = (i == 0) || (i == q1) || (i == mid) || (i == q3) || (i == lastIdx);
				let isMinor: Bool = !isMajor && ((i % 2) == 1); // every other non-major

        let tw: Float; let lOut: Float; let lIn: Float;
        if isMajor {
          tw = this.W_MAJOR; lOut = this.L_OUT_MAJOR; lIn = this.L_IN_MAJOR;
        } else {
          if isMinor { tw = this.W_MIN;  lOut = this.L_OUT_MIN;  lIn = this.L_IN_MIN; }
          else       { tw = this.W_MED;  lOut = this.L_OUT_MED;  lIn = this.L_IN_MED; }
        }

        let total: Float = lIn + lOut;
        let centerR: Float = innerR + (lOut - lIn) * 0.5;

        let tick: ref<inkRectangle> = new inkRectangle();
        tick.SetName(n"VM_Tick");
        tick.SetSize(new Vector2(tw, total));                 // full length
        tick.SetAnchor(inkEAnchor.Centered);
        tick.SetAnchorPoint(new Vector2(0.5, 0.5));           // centre-anchored
        tick.SetRenderTransformPivot(new Vector2(0.5, 0.5));  // rotate around centre
        tick.SetInteractive(false);
				tick.SetOpacity(isMajor ? 0.95 : 0.75);

				let tint: HDRColor;

				// 1) the very first tick (leftmost, “E”) is a MAJOR → CP red
				if i == 0 {
					tint = red;

				// 2) the first *minor* (thin) tick we encounter → CP red
				} else if isMinor && !firstMinorPainted {
					tint = red;
					firstMinorPainted = true;

				// 3) all other majors → soft white
				} else if isMajor {
					tint = cpWhite;

				// 4) everything else (mediums + later minors) → soft cyan
				} else {
					tint = cpCyanSoft;
				}

				tick.SetTintColor(tint);

        tick.SetRotation(270.0 - ang);                        // radial
        tick.SetTranslation(this.__Polar(centerR, ang));      // midpoint on ray
        tick.Reparent(cont);
				ArrayPush(this.tickRefs, tick);

        i += 1;
      }

      // ======================= Labels =======================
			// ----- E / F labels (kept crisp by canceling parent scaling) -----

			// E wrapper cancels both X and Y scale from the GaugeRoot
			let eWrap: ref<inkCanvas> = new inkCanvas();
			eWrap.SetName(n"E_Wrap");
			eWrap.SetInteractive(false);
			eWrap.SetFitToContent(true);
			eWrap.SetAnchor(inkEAnchor.Centered);
			eWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
			eWrap.SetTranslation(this.__Polar(this.RIM_R + 54.0, 180.0)); // same placement as before
			eWrap.SetScale(new Vector2(1.0 / this.SCALE_X, 1.0 / this.SCALE_Y)); // << cancel squash & stretch
			eWrap.Reparent(cont);

			let lblE: ref<inkText> = new inkText();
			lblE.SetName(n"E_Label");
			lblE.SetText("E");
			lblE.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
			lblE.SetFontSize(62);
			lblE.SetTintColor(cpWhite);
			lblE.SetAnchor(inkEAnchor.Centered);
			lblE.SetAnchorPoint(new Vector2(0.5, 0.5));
			lblE.SetTranslation(new Vector2(0.0, 0.0)); // centered inside wrapper
			lblE.Reparent(eWrap);
			this.lblERef = lblE;

			// F wrapper cancels both X and Y scale from the GaugeRoot
			let fWrap: ref<inkCanvas> = new inkCanvas();
			fWrap.SetName(n"F_Wrap");
			fWrap.SetInteractive(false);
			fWrap.SetFitToContent(true);
			fWrap.SetAnchor(inkEAnchor.Centered);
			fWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
			fWrap.SetTranslation(this.__Polar(this.RIM_R + 54.0, 0.0));
			fWrap.SetScale(new Vector2(1.0 / this.SCALE_X, 1.0 / this.SCALE_Y));
			fWrap.Reparent(cont);

			let lblF: ref<inkText> = new inkText();
			lblF.SetName(n"F_Label");
			lblF.SetText("F");
			lblF.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
			lblF.SetFontSize(62);
			lblF.SetTintColor(cpWhite);
			lblF.SetAnchor(inkEAnchor.Centered);
			lblF.SetAnchorPoint(new Vector2(0.5, 0.5));
			lblF.SetTranslation(new Vector2(0.0, 0.0));
			lblF.Reparent(fWrap);
			this.lblFRef = lblF;

      // ======================= Needle (on top) =======================
			// === NEEDLE (tapered, rotates around base) ===
			let ndRoot: ref<inkCanvas> = new inkCanvas();
			ndRoot.SetName(n"NeedleRoot");
			ndRoot.SetInteractive(false);
			ndRoot.SetFitToContent(true);
			ndRoot.SetAnchor(inkEAnchor.Centered);
			ndRoot.SetAnchorPoint(new Vector2(0.5, 1.0));         // base at center
			ndRoot.SetRenderTransformPivot(new Vector2(0.5, 1.0)); // rotate around base
			ndRoot.SetTranslation(new Vector2(0.0, 0.0));
			ndRoot.SetRotation(0.0);
			ndRoot.Reparent(cont);
			this.needle = ndRoot;

			let ndLen: Float = this.RIM_R - this.ND_LEN_PAD;

			// base segment (widest, shortest)
			let ndBase: ref<inkRectangle> = new inkRectangle();
			ndBase.SetName(n"NeedleBase");
			ndBase.SetSize(new Vector2(this.ND_BASE_W, ndLen * this.ND_BASE_RATIO));
			ndBase.SetTintColor(red);                 // reuse your 'red' color from above
			ndBase.SetAnchor(inkEAnchor.Centered);
			ndBase.SetAnchorPoint(new Vector2(0.5, 1.0));
			ndBase.SetRenderTransformPivot(new Vector2(0.5, 1.0));
			ndBase.SetTranslation(new Vector2(0.0, 0.0));
			ndBase.Reparent(ndRoot);
			this.ndBaseRef = ndBase;

			// mid segment
			let ndMid: ref<inkRectangle> = new inkRectangle();
			ndMid.SetName(n"NeedleMid");
			ndMid.SetSize(new Vector2(this.ND_MID_W,   ndLen * this.ND_MID_RATIO));
			ndMid.SetTintColor(red);
			ndMid.SetAnchor(inkEAnchor.Centered);
			ndMid.SetAnchorPoint(new Vector2(0.5, 1.0));
			ndMid.SetRenderTransformPivot(new Vector2(0.5, 1.0));
			ndMid.SetTranslation(new Vector2(0.0, 0.0));
			ndMid.Reparent(ndRoot);
			this.ndMidRef = ndMid;

			// tip segment (narrow & longest; gives the triangular silhouette)
			let ndTip: ref<inkRectangle> = new inkRectangle();
			ndTip.SetName(n"NeedleTip");
			ndTip.SetSize(new Vector2(this.ND_TIP_W,   ndLen * this.ND_TIP_RATIO));
			ndTip.SetTintColor(red);
			ndTip.SetAnchor(inkEAnchor.Centered);
			ndTip.SetAnchorPoint(new Vector2(0.5, 1.0));
			ndTip.SetRenderTransformPivot(new Vector2(0.5, 1.0));
			ndTip.SetTranslation(new Vector2(0.0, 0.0));
			ndTip.Reparent(ndRoot);
			this.ndTipRef = ndTip;

			// subtle center highlight
			let hl: ref<inkRectangle> = new inkRectangle();
			hl.SetName(n"NeedleHighlight");
			hl.SetSize    (new Vector2(this.ND_HL_W,   ndLen * this.ND_TIP_RATIO));
			hl.SetTintColor(cpWhite);       // reuse your 'white' color from above
			hl.SetOpacity(0.45);
			hl.SetAnchor(inkEAnchor.Centered);
			hl.SetAnchorPoint(new Vector2(0.5, 1.0));
			hl.SetRenderTransformPivot(new Vector2(0.5, 1.0));
			hl.SetTranslation(new Vector2(0.0, 0.0));
			hl.Reparent(ndRoot);
			this.ndHLRef = hl;

			// hub (unchanged)
			let hub: ref<inkRectangle> = new inkRectangle();
			hub.SetName(n"Hub");
			hub.SetSize(new Vector2(22.0, 22.0));
			hub.SetTintColor(cpWhite);
			hub.SetOpacity(1.0);
			hub.SetAnchor(inkEAnchor.Centered);
			hub.SetAnchorPoint(new Vector2(0.5, 0.5));
			hub.SetTranslation(new Vector2(0.0, 0.0));
			hub.Reparent(cont);
			this.hubRef = hub;
			
			// ODO wrapper (centered under gauge)
			let odoWrap: ref<inkCanvas> = new inkCanvas();
			odoWrap.SetName(n"ODO_Wrap");
			odoWrap.SetInteractive(false);
			odoWrap.SetFitToContent(true);
			odoWrap.SetAnchor(inkEAnchor.Centered);
			odoWrap.SetAnchorPoint(new Vector2(0.5, 0.0));
			odoWrap.SetTranslation(new Vector2(0.0, this.ODO_OFFSET_Y)); // you already have an offset here
			odoWrap.Reparent(cont);
			

			// ----- Background: FILL (dark grey) + STROKE (white) -----
			let plateFill: ref<inkImage> = new inkImage();
			plateFill.SetName(n"ODO_BG_FILL");
			
			plateFill.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\hud_johnny\\notification_assets.inkatlas");
			plateFill.SetTexturePart(n"Plate_main");
						
			plateFill.SetSize(new Vector2(this.ODO_W, this.ODO_H));
			plateFill.SetAnchor(inkEAnchor.Centered);
			plateFill.SetAnchorPoint(new Vector2(0.5, 0.5));
			let darkGrey: HDRColor; darkGrey.Red=0.18; darkGrey.Green=0.18; darkGrey.Blue=0.18; darkGrey.Alpha=1.0;
			plateFill.SetTintColor(darkGrey);
			plateFill.SetOpacity(0.85); // semi-opaque dark grey
			plateFill.Reparent(odoWrap);
			this.odoFillRef = plateFill;

			let plateStroke: ref<inkImage> = new inkImage();
			plateStroke.SetName(n"ODO_BG_STROKE");


			
			plateStroke.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\hud_johnny\\notification_assets.inkatlas");
			plateStroke.SetTexturePart(n"Plate_main_Stroke");
			
			plateStroke.SetSize(new Vector2(this.ODO_W, this.ODO_H));
			plateStroke.SetAnchor(inkEAnchor.Centered);
			plateStroke.SetAnchorPoint(new Vector2(0.5, 0.5));
			let white: HDRColor; white.Red=1.0; white.Green=1.0; white.Blue=1.0; white.Alpha=1.0;
			plateStroke.SetTintColor(cpCyan);
			plateStroke.SetOpacity(1.0);
			plateStroke.Reparent(odoWrap);
			this.odoStrokeRef = plateStroke;

			// ----- Content row (same size as plate, so we can place left/right items cleanly) -----
			let odoRow: ref<inkCanvas> = new inkCanvas();
			odoRow.SetName(n"ODO_Row");
			odoRow.SetInteractive(false);
			odoRow.SetFitToContent(false);
			odoRow.SetSize(new Vector2(this.ODO_W, this.ODO_H));
			odoRow.SetAnchor(inkEAnchor.Centered);
			odoRow.SetAnchorPoint(new Vector2(0.5, 0.5));
			odoRow.Reparent(odoWrap);
			
			
			// "ODO" label — left side
			let odoLbl: ref<inkText> = new inkText();
			odoLbl.SetName(n"ODO_Label");
			odoLbl.SetText("ODO");
			odoLbl.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
			odoLbl.SetFontSize(60);
			odoLbl.SetTintColor(cpWhite);
			// place at left padding
			odoLbl.SetAnchor(inkEAnchor.Centered);
			odoLbl.SetAnchorPoint(new Vector2(0.0, 0.5)); // left middle of the text box
			odoLbl.SetTranslation(new Vector2(-this.ODO_W * 0.5 + this.ODO_PAD_L, 0.0));
			odoLbl.Reparent(odoRow);
			this.odoLblRef = odoLbl;

			// ODO digits — RIGHT-ALIGNED (no “km” unit)
			let odoDigits: ref<inkText> = new inkText();
			odoDigits.SetName(n"ODO_Digits");
			odoDigits.SetText("000000"); // will be updated in Refresh()
			odoDigits.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
			odoDigits.SetFontSize(58);
			odoDigits.SetTintColor(cpCyan);
			// anchor the RIGHT edge of the text to the right padding point
			odoDigits.SetAnchor(inkEAnchor.Centered);
			odoDigits.SetAnchorPoint(new Vector2(1.0, 0.5)); // right middle
			odoDigits.SetTranslation(new Vector2(this.ODO_W * 0.5 - this.ODO_PAD_R, 0.0));
			odoDigits.Reparent(odoRow);
			
			// ---- ODO spinner (between label and value) ----
			let spinWrap: ref<inkCanvas> = new inkCanvas();
			spinWrap.SetName(n"ODO_SpinnerWrap");
			spinWrap.SetInteractive(false);
			spinWrap.SetFitToContent(true);
			spinWrap.SetAnchor(inkEAnchor.Centered);
			spinWrap.SetAnchorPoint(new Vector2(0.5, 0.5));
			// position: center of the plate; nudge if you want (x,y)
			spinWrap.SetTranslation(new Vector2(-52.0, 0.0));
			spinWrap.Reparent(odoRow);

			let spinImg: ref<inkImage> = new inkImage();
			spinImg.SetName(n"ODO_Spinner");
			spinImg.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\autodrive\\autodrive.inkatlas");
			spinImg.SetTexturePart(n"freeroam");
			spinImg.SetAnchor(inkEAnchor.Centered);
			spinImg.SetAnchorPoint(new Vector2(0.5, 0.5));
			spinImg.SetRenderTransformPivot(new Vector2(0.5, 0.5));
			spinImg.SetSize(new Vector2(40.0, 40.0));
			spinImg.SetTintColor(cpCyan);     // CP cyan
			spinImg.SetOpacity(1.0);
			spinImg.Reparent(spinWrap);
			spinImg.SetTranslation(new Vector2(0.0, 0.0));
			


			// ======= ALARM OVERLAY (top-most) =======
			// A world/session rebuild can reuse GaugeRoot. Hide every prior alarm
			// child, then reuse one instead of leaving an orphaned visible advert.
			let alarmChildCount: Int32 = cont.GetNumChildren();
			let alarmChildIndex: Int32 = 0;
			while alarmChildIndex < alarmChildCount {
				let alarmChild: wref<inkWidget> = cont.GetWidget(alarmChildIndex);
				if IsDefined(alarmChild) && Equals(alarmChild.GetName(), n"VM_AlarmOverlay") {
					alarmChild.SetOpacity(0.0);
					alarmChild.SetVisible(false);
				}
				alarmChildIndex += 1;
			}

			let alarmImg: ref<inkImage> = cont.GetWidgetByPathName(n"VM_AlarmOverlay") as inkImage;
			if !IsDefined(alarmImg) {
				alarmImg = new inkImage();
				alarmImg.SetName(n"VM_AlarmOverlay");
			}
			// Keep the reused overlay as the top-most child as well.
			alarmImg.Reparent(cont, -1);
			alarmImg.SetVisible(false);
			alarmImg.SetOpacity(0.0);   // start hidden via opacity
			alarmImg.SetAtlasResource(r"ep1\\gameplay\\gui\\world\\adverts\\q304_escape_monitors\\q304_monitors.inkatlas");
			alarmImg.SetTexturePart(n"21_9v2");
			alarmImg.SetSize(new Vector2(1024.0, 439.0));
			alarmImg.SetAnchor(inkEAnchor.Centered);
			alarmImg.SetAnchorPoint(new Vector2(0.5, 0.5));
			alarmImg.SetRenderTransformPivot(new Vector2(0.5, 0.5));
			alarmImg.SetInteractive(false);
			alarmImg.SetVisible(false);

			let warm: HDRColor;
			warm.Red = 1.0; warm.Green = 0.96; warm.Blue = 0.92; warm.Alpha = 1.0; // subtle warm-white
			alarmImg.SetTintColor(warm);

			// Sit exactly over the gauge & cancel the parent's squash
			alarmImg.SetTranslation(new Vector2(this.ALARM_DX, -this.ALARM_DY));
			alarmImg.SetScale(new Vector2(
				this.ALARM_SCALE / this.SCALE_X,   // cancel X squash from 'cont'
				this.ALARM_SCALE / this.SCALE_Y    // cancel Y squash from 'cont'
			));

			this.alarmImgRef = alarmImg;



			
			// keep references if you need them in Refresh()
			this.odoWrapRef = odoWrap;
			this.odoValRef = odoDigits;
			this.odoSpinWrapRef = spinWrap;
			this.odoSpinImgRef  = spinImg;
			// Force Refresh() to write current vm_hud_meters into the ODO text.
			this.lastOdoM = -1;
			this.ApplyOdoScale();
			this.__ApplyThemePalette(true);

						
			this.lastPermille = -1; this.lastVisible = false; this.built = true;
			} else {
				if IsDefined(this.vrw) && IsDefined(this.rootFS) { this.vrw.ScaleWidget(this.rootFS); }
			}
			this.ApplyOdoScale();
			this.ApplyUserTransform();
			this.Refresh();
			this.ArmNextTick();
		}

// fii 3

	public func Refresh() -> Void {
    if !IsDefined(this.root) { return; }
    let qs = GameInstance.GetQuestsSystem(GetGameInstance());
    if !IsDefined(qs) { return; }

		this.ApplyVisibilityGate();
		this.ApplyUserTransform();
		this.ApplyOdoScale();
		// also update Temp meter visibility (even if root is hidden; cheap & safe)
		this.ApplyTempVisibility();

		// read CET theme fact and recolor if changed
		this.__ApplyThemePalette(false);

    // If we are fully hidden and no animation is playing, skip the heavy work
    if !this.lastVisible && !this.bootupActive && !this.shutdownActive {
      return;
    }

    // keep a copy *before* updating to detect refuel rises
    let prevP: Int32 = this.lastPermille;

    let p: Int32 = qs.GetFact(n"vm_hud_fuel_permille");
    if p != this.lastPermille {
      this.lastPermille = p;
      let f: Float = Cast<Float>(p);
      let clamped: Float;
      if f < 0.0 { clamped = 0.0; } else { if f > 1000.0 { clamped = 1000.0; } else { clamped = f; } }
      let t: Float = clamped / 1000.0;
      let rot: Float = -90.0 + (180.0 * t);
      if IsDefined(this.needle) { this.needle.SetRotation(rot); }
    }

		    // ── First-seconds placement self-heal ──
    if this.fgReassertLeft > 0.0 {
      this.fgReassertCool -= this.period;
      if this.fgReassertCool <= 0.0 {
        this.fgReassertCool = this.FG_REASSERT_EVERY;
        this.ApplyUserTransform();  // uses code-defaults when facts are 0/0/0
      }
      this.fgReassertLeft -= this.period;
    }


		// First-tick safety: if we are still at (0,0,1.0) and facts are zero, apply defaults once.
		if !this.bootApplied {
			let qs = GameInstance.GetQuestsSystem(GetGameInstance());
			let zdx: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_gauge_dx") : 0;
			let zdy: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_gauge_dy") : 0;
			let zsc: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_gauge_scale_milli") : 0;
			if zdx == 0 && zdy == 0 && zsc == 0 {
				// apply code-defaults
				this.place.SetTranslation(new Vector2(-this.FG_DEF_DX_MAG, this.FG_DEF_DY_PX));
				this.place.SetScale(new Vector2(this.FG_DEF_SCALE, this.FG_DEF_SCALE));
				this.lastUserDx = -this.FG_DEF_DX_MAG;
				this.lastUserDy =  this.FG_DEF_DY_PX;
				this.lastUserScale = this.FG_DEF_SCALE;
			}
			this.bootApplied = true;
		}


    // ── Refuel state detection (rise in fuel permille) ──
    let dp: Int32 = (prevP >= 0) ? (p - prevP) : 0;

    if dp > 0 {
      this.refuelUpTicks += 1;
      this.refuelDownTimer = 0.0;
    } else {
      this.refuelUpTicks = 0;
      this.refuelDownTimer += this.period;
    }

    // enter: two consecutive rises and not full
    if !this.refuelActive && (this.refuelUpTicks >= this.REFUEL_DETECT_TICKS) && (p < 1000) {
      this.refuelActive      = true;
      this.refuelPhase01     = 0.0;
      this.pumpScaleSmoothed = 1.0; // start from base for a clean ramp
    }

    if this.refuelActive && (p >= 1000 || this.refuelDownTimer >= this.REFUEL_HYST_SEC) {
      this.refuelActive      = false;
      this.refuelPhase01     = 0.0;
      this.pumpScaleSmoothed = 1.0;

      if IsDefined(this.pumpRef) {
        this.pumpRef.SetScale(new Vector2(this.PUMP_SCALE, this.PUMP_SCALE));
      }
      this.__ApplyWarnPalette(this.lastWarnState, this.blinkOn);
    }


			// --- warning/empty palette & blink ---
			let curState: Int32 = 0;
			if this.lastPermille <= 0 {
				curState = 2; // EMPTY
			} else if this.lastPermille <= 50 {
				curState = 1; // SOON (≤5%)
			}

			// flip the blink bit only while warning/empty
			if curState != 0 {
				this.blinkOn = !this.blinkOn;
			} else {
				this.blinkOn = false;
			}

			// Always apply when state changes, and also every tick while blinking
			if curState != this.lastWarnState || curState != 0 {
				this.__ApplyWarnPalette(curState, this.blinkOn);
				this.lastWarnState = curState;
			}
			// --- Vehicle condition → engine icon color ---
			// Important: this stays independent from the selected HUD theme.
			let cond: Int32 = qs.GetFact(n"vm_hud_vehicle_cond_pct"); // -1 if unknown

			if cond != this.condLastPct {
				this.condLastPct = cond;
			}

			// Always re-apply fixed condition color.
			// This prevents theme changes from temporarily tinting the engine icon.
			this.__ApplyEngineConditionPalette(cond);

			// --- Oil temp → TempBG color (smooth) ---
      if IsDefined(this.tempBGRef) {
        let oilI: Int32 = qs.GetFact(n"vm_hud_oil_temp_c");
        let targetC: Float = Cast<Float>(oilI);

        if !this.oilTintInited {
          this.oilTempVisC = targetC;
          this.oilTint     = this.__ColorForOilC(targetC);
          this.tempBGRef.SetTintColor(this.oilTint);
          this.oilTintInited = true;
        } else {
          // smooth both the temperature and the color
          let step: Float = this.__Clamp01(this.period * this.OIL_TINT_K);
          this.oilTempVisC = this.oilTempVisC + (targetC - this.oilTempVisC) * step;

          let wantCol: HDRColor = this.__ColorForOilC(this.oilTempVisC);
          this.oilTint = this.__LerpColor(this.oilTint, wantCol, step);
          this.tempBGRef.SetTintColor(this.oilTint);
        }
      }

			this.__UpdateTempLabels(this.oilTintInited ? this.oilTempVisC : Cast<Float>(qs.GetFact(n"vm_hud_oil_temp_c")));

			// --- <6% → FADE flash loop ---
			let wantAlarm: Bool = this.wantVisible && (cond >= 0) && (cond < 6);

			// change detection without '!=' on Bool
			if ( (wantAlarm && !this.alarmActive) || (!wantAlarm && this.alarmActive) ) {
				this.alarmActive = wantAlarm;
				this.alarmTimer  = 0.0;
				this.alarmAlpha  = 0.0;

				if this.alarmActive {
					this.alarmPhase = 1; // fade-in
					if IsDefined(this.alarmImgRef) {
						this.alarmImgRef.SetVisible(true);
						this.alarmImgRef.SetOpacity(0.0);
					}
				} else {
					this.alarmPhase = 0; // off
					if IsDefined(this.alarmImgRef) {
						this.alarmImgRef.SetOpacity(0.0);
						this.alarmImgRef.SetVisible(false);
					}
				}
			}

			// run the fade only while active
			if this.alarmActive && IsDefined(this.alarmImgRef) {
				this.alarmTimer += this.period;

				if this.alarmPhase == 1 { // fade-in
					let t: Float = this.__Clamp01(this.alarmTimer / this.ALARM_FADE_IN);
					this.alarmAlpha = this.__EaseSmoothstep(t);
					this.alarmImgRef.SetOpacity(this.alarmAlpha);
					if this.alarmTimer >= this.ALARM_FADE_IN {
						this.alarmPhase = 2; 
						this.alarmTimer = 0.0;
						this.alarmImgRef.SetOpacity(1.0);
					}

				} else if this.alarmPhase == 2 { // hold
					this.alarmImgRef.SetOpacity(1.0);
					if this.alarmTimer >= this.ALARM_HOLD {
						this.alarmPhase = 3; 
						this.alarmTimer = 0.0;
					}

				} else if this.alarmPhase == 3 { // fade-out
					let t2: Float = this.__Clamp01(this.alarmTimer / this.ALARM_FADE_OUT);
					this.alarmAlpha = 1.0 - this.__EaseSmoothstep(t2);
					this.alarmImgRef.SetOpacity(this.alarmAlpha);
					if this.alarmTimer >= this.ALARM_FADE_OUT {
						this.alarmPhase = 4; 
						this.alarmTimer = 0.0;
						this.alarmImgRef.SetOpacity(0.0);
					}

				} else if this.alarmPhase == 4 { // gap
					this.alarmImgRef.SetOpacity(0.0);
					if this.alarmTimer >= this.ALARM_GAP {
						this.alarmPhase = 1; 
						this.alarmTimer = 0.0;
					}

				} else {
					// safety
					this.alarmImgRef.SetOpacity(0.0);
				}

			} else if IsDefined(this.alarmImgRef) {
				this.alarmImgRef.SetOpacity(0.0);
				this.alarmImgRef.SetVisible(false);
			}


			// --- Spinner animation (smoothed speed → angle) ---
			if IsDefined(this.odoSpinImgRef) {
				let kmh: Int32 = qs.GetFact(n"vm_hud_speed_kmh");
				if kmh < 0 { kmh = 0; } else if kmh > 400 { kmh = 400; }

				// target angular velocity
				let targetOmega: Float = this.SPIN_IDLE_DEG_PER_SEC + (Cast<Float>(kmh) * this.SPIN_DEG_PER_SEC_PER_KMH);

				// simple EMA toward target (alpha = period * spinResp, clamped to 1)
				let a: Float = this.period * this.spinResp; 
				if a > 1.0 { a = 1.0; }
				this.spinOmega = this.spinOmega + (targetOmega - this.spinOmega) * a;

				// integrate rotation
				this.spinAngle += this.spinOmega * this.period;

				// wrap
				while this.spinAngle >= 360.0 { this.spinAngle -= 360.0; }
				while this.spinAngle < 0.0    { this.spinAngle += 360.0; }

      this.odoSpinImgRef.SetRotation(this.spinAngle);
    }

    // NEW: pump wobble pulse while refueling (green liquid look) — SMOOTHED
    if this.refuelActive {
      // advance normalized phase 0..1
      this.refuelPhase01 += this.period * this.REFUEL_WOBBLE_HZ;
      if this.refuelPhase01 >= 1.0 { this.refuelPhase01 -= 1.0; }

      // raw target wobble (sinus)
      let sTarget: Float = 1.0 + (this.REFUEL_WOBBLE_AMPL * SinF(this.refuelPhase01 * 6.2831853));

      // exponential smoothing (RC filter): k = dt / (tau + dt)
      let k: Float = this.period / (this.REFUEL_SMOOTH_TAU + this.period);
      this.pumpScaleSmoothed = this.pumpScaleSmoothed + k * (sTarget - this.pumpScaleSmoothed);

      if IsDefined(this.pumpRef) {
        let sApplied: Float = this.PUMP_SCALE * this.pumpScaleSmoothed;
        this.pumpRef.SetScale(new Vector2(sApplied, sApplied));
      }

      // lively green while refueling
      let g: HDRColor; g.Red = 0.30; g.Green = 1.00; g.Blue = 0.40; g.Alpha = 1.0;
      if IsDefined(this.pumpImgRef) {
        this.pumpImgRef.SetTintColor(g);
        this.pumpImgRef.SetOpacity(1.0);
      }
    }


    // --- ODO update (meters -> km, padded) ---
    let odoM: Int32 = qs.GetFact(n"vm_hud_meters"); // meters total
			if odoM != this.lastOdoM {
				this.lastOdoM = odoM;
				let km: Int32 = odoM / 1000; // integer km
				let s: String = this.__Pad6(km);
				if IsDefined(this.odoValRef) { this.odoValRef.SetText(s); }
			}
		
  }

  private func ArmNextTick() -> Void {
    if this.__armed { return; }
    let ds = GameInstance.GetDelaySystem(GetGameInstance());
    if !IsDefined(ds) { return; }
    this.tick = VM_FuelGaugeTick.Create(
      this,
      this.callbackGeneration
    );
    this.__armed = true;
    ds.DelayCallback(this.tick, this.period, false);
  }

 // high-frequency animation driver (boot-up + shutdown)
  private func ArmAnimStep() -> Void {
    // don’t arm if nothing is animating
    if this.__animArmed { return; }
    if !this.bootupActive && !this.shutdownActive { return; }

    let ds = GameInstance.GetDelaySystem(GetGameInstance());
    if !IsDefined(ds) { return; }
    this.animTick = VM_FGAnimTick.Create(
      this,
      this.callbackGeneration
    );
    this.__animArmed = true;
    ds.DelayCallback(this.animTick, this.ANIM_PERIOD, false);
  }

  public func AnimStep() -> Void {
    let dt: Float = this.ANIM_PERIOD;

    // ── Boot-up animation (same math as before, but high-fps) ─────────────
    if this.bootupActive {
      this.bootupTimer += dt;
      this.bootupPhase = MinF(this.bootupTimer / this.BOOTUP_DURATION, 1.0);

      let t = this.bootupPhase;
      let easedScale: Float;
      let easedAlpha: Float;

      // Exponential ease-out for super smooth deceleration
      easedScale = 1.0 - PowF(2.0, -10.0 * t);

      // Alpha ease with slight delay
      if t < 0.1 {
        easedAlpha = t * 10.0 * 0.3;
      } else {
        let ta = (t - 0.1) / 0.9;
        easedAlpha = 0.3 + 0.7 * (1.0 - PowF(1.0 - ta, 2.0));
      }

      // Subtle elastic finish near the end
      if t > 0.85 {
        let tf = (t - 0.85) / 0.15;
        let microBounce = SinF(tf * 3.14159 * 2.0) * 0.015 * (1.0 - tf);
        easedScale = easedScale + microBounce;
      }

      let currentAlpha: Float = this.BOOTUP_ALPHA_START + (1.0 - this.BOOTUP_ALPHA_START) * easedAlpha;
      let scaleProgress: Float = this.BOOTUP_SCALE_START + (1.0 - this.BOOTUP_SCALE_START) * easedScale;

      if IsDefined(this.root) {
        this.root.SetOpacity(currentAlpha);
        this.root.SetScale(new Vector2(
          this.SCALE_X * scaleProgress,
          this.SCALE_Y * scaleProgress
        ));
      }

      // Finish clean
      if this.bootupPhase >= 1.0 {
        this.bootupActive = false;
        if IsDefined(this.root) {
          this.root.SetOpacity(1.0);
          this.root.SetScale(new Vector2(this.SCALE_X, this.SCALE_Y));
        }
      }
    }

    // ── Shutdown (CRT-style) animation (same math, high-fps) ──────────────
    if this.shutdownActive {
      this.shutdownTimer += dt;
      this.shutdownPhase = MinF(this.shutdownTimer / this.SHUTDOWN_DURATION, 1.0);
      let t: Float = this.shutdownPhase;

      if IsDefined(this.root) {
        // 1) vertical collapse → thin horizontal line
        let lineMul: Float;
        if t < 0.60 {
          let tv: Float = this.__Clamp01(t / 0.60);
          let vEase: Float = this.__EaseSmoothstep(tv);
          lineMul = 1.0 - (0.95 * vEase);
        } else {
          lineMul = 0.05;
        }

        // 2) then shrink horizontally into a point
        let xMul: Float = 1.0;
        if t > 0.30 {
          let tx: Float = this.__Clamp01((t - 0.30) / 0.70);
          let xEase: Float = this.__EaseSmoothstep(tx);
          xMul = 1.0 - (0.92 * xEase);
        }

        let sx: Float = this.SCALE_X * xMul;
        let sy: Float = this.SCALE_Y * lineMul;
        this.root.SetScale(new Vector2(sx, sy));

        // 3) brightness fade in the last part
        let fadeT: Float = (t <= 0.60) ? 0.0 : this.__Clamp01((t - 0.60) / 0.40);
        let alpha: Float = 1.0 - (fadeT * fadeT);
        this.root.SetOpacity(alpha);
      }

      if this.shutdownPhase >= 1.0 {
        this.shutdownActive = false;
        if IsDefined(this.root) {
          this.root.SetOpacity(0.0);
          this.root.SetVisible(false);
          this.root.SetScale(new Vector2(this.SCALE_X, this.SCALE_Y));
        }
        this.lastVisible = false;
      }
    }

    // Re-arm while any animation is still running
    if this.bootupActive || this.shutdownActive {
      this.ArmAnimStep();
    }
  }

  // polar helper (Ink Y+ down; 0°=right, 90°=up, 180°=left)
  private func __Polar(r: Float, deg: Float) -> Vector2 {
    let rad: Float = deg * this.DEG2RAD;
    return new Vector2(r * CosF(rad), -r * SinF(rad));
  }
	
		// Scale the whole ODO block (unsquash + extra scale)
	private func ApplyOdoScale() -> Void {
		if !IsDefined(this.odoWrapRef) { return; }

		// read an optional fact (permille), else use default
		let qs = GameInstance.GetQuestsSystem(GetGameInstance());
		let milli: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_odo_scale_milli") : 0;

		let s: Float = (milli > 0) ? (Cast<Float>(milli) / 1000.0) : this.ODO_SCALE_DEFAULT;

		// clamp (same range you liked for the gauge)
		let clamped: Float = (s < 0.50) ? 0.50 : ((s > 2.00) ? 2.00 : s);

		// cancel parent squash and apply our extra scale
		let sx: Float = clamped / this.SCALE_X;
		let sy: Float = clamped / this.SCALE_Y;

		// only update when it changed
		if clamped != this.lastOdoScale {
			this.odoWrapRef.SetScale(new Vector2(sx, sy));
			this.lastOdoScale = clamped;
		}
	}
	
	// digit helper
	private func __Pad6(n: Int32) -> String {
  if n < 0 { n = -n; } // just in case
  let d5: Int32 = (n / 100000) % 10;
  let d4: Int32 = (n / 10000)  % 10;
  let d3: Int32 = (n / 1000)   % 10;
  let d2: Int32 = (n / 100)    % 10;
  let d1: Int32 = (n / 10)     % 10;
  let d0: Int32 =  n           % 10;
  return IntToString(d5) + IntToString(d4) + IntToString(d3) + IntToString(d2) + IntToString(d1) + IntToString(d0);
}

	// --- helpers ---
	private func __Clamp01(x: Float) -> Float {
		let r: Float = x;
		if r < 0.0 { r = 0.0; } else { if r > 1.0 { r = 1.0; } }
		return r;
	}

	private func __EaseSmoothstep(x: Float) -> Float {
		return x * x * (3.0 - 2.0 * x); // smoothstep(0..1)
	}

 private func __Lerp(a: Float, b: Float, t: Float) -> Float {
    let tt: Float = this.__Clamp01(t);
    return a + (b - a) * tt;
  }

  private func __LerpColor(a: HDRColor, b: HDRColor, t: Float) -> HDRColor {
    let r: HDRColor;
    let tt: Float = this.__Clamp01(t);
    r.Red   = a.Red   + (b.Red   - a.Red)   * tt;
    r.Green = a.Green + (b.Green - a.Green) * tt;
    r.Blue  = a.Blue  + (b.Blue  - a.Blue)  * tt;
    r.Alpha = a.Alpha + (b.Alpha - a.Alpha) * tt;
    return r;
  }

  // Map oil °C to a B→G→R color with an amber pass around ~100 °C
	private func __ColorForOilC(c: Float) -> HDRColor {
		let x: Float = c;

		// Anchors at the thresholds
		let col40:  HDRColor; col40.Red=0.30; col40.Green=0.60; col40.Blue=1.00; col40.Alpha=1.0; // blue (≤40)
		let col60:  HDRColor; col60.Red=0.55; col60.Green=1.00; col60.Blue=0.65; col60.Alpha=1.0; // light green (70)
		let col80:  HDRColor; col80.Red=0.20; col80.Green=0.85; col80.Blue=0.25; col80.Alpha=1.0; // green (80)
		let col100: HDRColor; col100.Red=0.95; col100.Green=0.83; col100.Blue=0.25; col100.Alpha=1.0; // yellow (100)
		let col120: HDRColor; col120.Red=1.00; col120.Green=0.22; col120.Blue=0.22; col120.Alpha=1.0; // orange-red (120)
		let col160: HDRColor; col160.Red=0.55; col160.Green=0.08; col160.Blue=0.08; col160.Alpha=1.0; // dark red (160)

		if x <= this.OIL_C_MIN { return col40; }
		if x <  this.OIL_C1    { return this.__LerpColor(col40,  col60,  (x - this.OIL_C_MIN) / (this.OIL_C1   - this.OIL_C_MIN)); } // 40..70
		if x <  this.OIL_C2    { return this.__LerpColor(col60,  col80,  (x - this.OIL_C1)    / (this.OIL_C2   - this.OIL_C1)); }    // 70..80
		if x <  this.OIL_CX    { return this.__LerpColor(col80,  col100, (x - this.OIL_C2)    / (this.OIL_CX   - this.OIL_C2)); }    // 80..100
		if x <  this.OIL_C3    { return this.__LerpColor(col100, col120, (x - this.OIL_CX)    / (this.OIL_C3   - this.OIL_CX)); }    // 100..120
		if x <  this.OIL_C_MAX { return this.__LerpColor(col120, col160, (x - this.OIL_C3)    / (this.OIL_C_MAX - this.OIL_C3)); }   // 120..160
		return col160;
	}
	
private func __UpdateTempLabels(curC: Float) -> Void {
  // 1) Which label is active? (highest threshold <= current temp)
  let newIdx: Int32 = -1;
  let i: Int32 = 0;
  while i < this.TEMP_LBL_COUNT {
    if curC >= Cast<Float>(this.tempLblVals[i]) { newIdx = i; }
    i += 1;
  }

  // 2) On milestone change: reset all labels to idle cyan (alpha 0.40), normal scale
  if newIdx != this.tempLblActiveIdx {
    this.tempLblActiveIdx = newIdx;
    this.tempLblPhase01   = 0.0;

    i = 0;
    while i < this.TEMP_LBL_COUNT {
      let lbl: wref<inkText> = this.tempLblRefs[i];
      if IsDefined(lbl) {
        let c: HDRColor;
        c.Red   = this.TEMP_TXT_R;
        c.Green = this.TEMP_TXT_G;
        c.Blue  = this.TEMP_TXT_B;
        c.Alpha = this.TEMP_LBL_ALPHA_BASE;   // 0.40
        lbl.SetTintColor(c);
        lbl.SetScale(new Vector2(1.0, 1.0));
        lbl.SetOpacity(1.0);
      }
      i += 1;
    }
  }

  // 3) For the active label, apply current band color + shimmer every tick
  if this.tempLblActiveIdx >= 0 {
    // match the BG’s band color at the **smoothed** temp
    let band: HDRColor = this.__ColorForOilC(curC);
    band.Alpha = this.TEMP_LBL_ALPHA_ACTIVE;  // 1.0

    // shimmer timing
    this.tempLblPhase01 += this.period * this.TEMP_LBL_SHIMMER_HZ;
    if this.tempLblPhase01 >= 1.0 { this.tempLblPhase01 -= 1.0; }

    let s:  Float = 1.0 + (this.TEMP_LBL_SHIMMER_AMPL * SinF(this.tempLblPhase01 * 6.2831853));
    let op: Float = 0.92 + 0.08 * (0.5 + 0.5 * SinF(this.tempLblPhase01 * 6.2831853));

    let hot: wref<inkText> = this.tempLblRefs[this.tempLblActiveIdx];
    if IsDefined(hot) {
      hot.SetTintColor(band);              // ← dynamic banding color
      hot.SetScale(new Vector2(s, s));
      hot.SetOpacity(op);
    }
  }
}

private func __ApplyEngineConditionPalette(cond: Int32) -> Void {
  if !IsDefined(this.engineImgRef) { return; }

  let healthy: HDRColor;
  healthy.Red = 0.35;
  healthy.Green = 0.95;
  healthy.Blue = 1.00;
  healthy.Alpha = 1.0;

  let warn: HDRColor;
  warn.Red = 1.00;
  warn.Green = 0.80;
  warn.Blue = 0.10;
  warn.Alpha = 1.0;

  let bad: HDRColor;
  bad.Red = 1.00;
  bad.Green = 0.22;
  bad.Blue = 0.22;
  bad.Alpha = 1.0;

  if cond >= 50 || cond < 0 {
    this.engineImgRef.SetTintColor(healthy);
  } else if cond >= 9 {
    this.engineImgRef.SetTintColor(warn);
  } else {
    this.engineImgRef.SetTintColor(bad);
  }
}

// ── Fuel gauge theme helpers ───────────────────────────────────────────────

private func __ThemeMainColor(theme: Int32) -> HDRColor {
  let c: HDRColor;

  if theme == 1 { // Cyberpunk Yellow
    c.Red = 1.00; c.Green = 0.78; c.Blue = 0.00;
	} else if theme == 2 { // E3 Red / Project E3 HUD blue-green main
		c.Red = 0.58; c.Green = 0.72; c.Blue = 0.69;
  } else if theme == 3 { // Mox Pink
    c.Red = 1.00; c.Green = 0.20; c.Blue = 0.85;
  } else if theme == 4 { // Blue
    c.Red = 0.15; c.Green = 0.35; c.Blue = 1.00;
  } else if theme == 5 { // Light Blue
    c.Red = 0.50; c.Green = 0.90; c.Blue = 1.00;
  } else if theme == 6 { // Neon Green
    c.Red = 0.25; c.Green = 1.00; c.Blue = 0.25;
  } else if theme == 7 { // Silver
    c.Red = 0.85; c.Green = 0.90; c.Blue = 0.95;
  } else if theme == 8 { // Gold
    c.Red = 1.00; c.Green = 0.62; c.Blue = 0.08;
  } else if theme == 9 { // Pure Yellow
    c.Red = 1.00; c.Green = 1.00; c.Blue = 0.00;
  } else { // 0 = current/default
    c.Red = 0.35; c.Green = 0.95; c.Blue = 1.00;
  }

  c.Alpha = 1.0;
  return c;
}

private func __ThemeSoftColor(theme: Int32) -> HDRColor {
  let c: HDRColor;

  if theme == 1 { // Cyberpunk Yellow
    c.Red = 1.00; c.Green = 0.90; c.Blue = 0.35;
	} else if theme == 2 { // E3 Red / Project E3 HUD soft blue-green
		c.Red = 0.78; c.Green = 0.92; c.Blue = 0.89;
  } else if theme == 3 { // Mox Pink
    c.Red = 1.00; c.Green = 0.55; c.Blue = 0.95;
  } else if theme == 4 { // Blue
    c.Red = 0.50; c.Green = 0.65; c.Blue = 1.00;
  } else if theme == 5 { // Light Blue
    c.Red = 0.75; c.Green = 0.96; c.Blue = 1.00;
  } else if theme == 6 { // Neon Green
    c.Red = 0.65; c.Green = 1.00; c.Blue = 0.65;
  } else if theme == 7 { // Silver
    c.Red = 0.65; c.Green = 0.72; c.Blue = 0.78;
  } else if theme == 8 { // Gold
    c.Red = 1.00; c.Green = 0.82; c.Blue = 0.35;
  } else if theme == 9 { // Pure Yellow
    c.Red = 1.00; c.Green = 1.00; c.Blue = 0.55;
  } else { // 0 = current/default
    c.Red = 0.70; c.Green = 0.92; c.Blue = 0.98;
  }

  c.Alpha = 1.0;
  return c;
}

private func __ThemeWhiteColor(theme: Int32) -> HDRColor {
  let c: HDRColor;

  if theme == 2 { // Project E3 HUD white
    c.Red = 0.98;
    c.Green = 1.00;
    c.Blue = 0.99;
  } else {
    c.Red = 0.92;
    c.Green = 0.95;
    c.Blue = 0.98;
  }

  c.Alpha = 1.0;
  return c;
}

private func __ThemeReserveRed(theme: Int32) -> HDRColor {
  let c: HDRColor;

  if theme == 2 { // Project E3 HUD red
    c.Red = 0.92;
    c.Green = 0.16;
    c.Blue = 0.26;
  } else {
    c.Red = 1.00;
    c.Green = 0.22;
    c.Blue = 0.22;
  }

  c.Alpha = 1.0;
  return c;
}

private func __ApplyThemePalette(force: Bool) -> Void {
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  let themeRaw: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_fg_theme") : 0;

  let theme: Int32 = themeRaw;
  if theme < 0 || theme > 9 {
    theme = 0;
  }

  if !force && theme == this.fgThemeLast {
    return;
  }

  this.fgThemeLast = theme;

  let main: HDRColor = this.__ThemeMainColor(theme);
  let soft: HDRColor = this.__ThemeSoftColor(theme);
	let white: HDRColor = this.__ThemeWhiteColor(theme);
	let reserveRed: HDRColor = this.__ThemeReserveRed(theme);

  // Recolor fuel ticks.
  // Keep first reserve ticks red, keep major ticks white, recolor medium/minor ticks.
  let firstMinorPainted: Bool = false;
  let count: Int32 = ArraySize(this.tickRefs);
  let i: Int32 = 0;

  while i < count {
    let tick: wref<inkRectangle> = this.tickRefs[i];

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
      }
    }

    i += 1;
  }

  // Pump: only recolor normal state.
  // Warning/refuel colors still override this.
  if !this.refuelActive {
    if this.lastWarnState == 1 || this.lastWarnState == 2 {
      this.__ApplyWarnPalette(this.lastWarnState, this.blinkOn);
    } else {
      if IsDefined(this.pumpImgRef) {
        this.pumpImgRef.SetTintColor(main);
        this.pumpImgRef.SetOpacity(1.0);
      }
    }
  }


	// ODO accents
	// Project E3 version uses red for the plate stroke, but blue-green for digits/spinner.
	if theme == 2 {
		if IsDefined(this.odoStrokeRef) { this.odoStrokeRef.SetTintColor(reserveRed); }
	} else {
		if IsDefined(this.odoStrokeRef) { this.odoStrokeRef.SetTintColor(main); }
	}

	if IsDefined(this.odoValRef)     { this.odoValRef.SetTintColor(main); }
	if IsDefined(this.odoSpinImgRef) { this.odoSpinImgRef.SetTintColor(main); }

	// Oil temperature frame stroke
	// This colors the small frame around the oil temperature curve with the active theme main color.
	if IsDefined(this.tempFrameRef) { this.tempFrameRef.SetTintColor(main); }

	// Text / neutral parts
	// Project E3 version: E + ODO label = red, F + needle highlight = blue-green.
	if theme == 2 {
		if IsDefined(this.lblERef)   { this.lblERef.SetTintColor(reserveRed); }
		if IsDefined(this.lblFRef)   { this.lblFRef.SetTintColor(main); }
		if IsDefined(this.odoLblRef) { this.odoLblRef.SetTintColor(reserveRed); }
		if IsDefined(this.ndHLRef)   { this.ndHLRef.SetTintColor(main); }
	} else {
		if IsDefined(this.lblERef)   { this.lblERef.SetTintColor(white); }
		if IsDefined(this.lblFRef)   { this.lblFRef.SetTintColor(white); }
		if IsDefined(this.odoLblRef) { this.odoLblRef.SetTintColor(white); }
		if IsDefined(this.ndHLRef)   { this.ndHLRef.SetTintColor(white); }
	}

	if IsDefined(this.hubRef) { this.hubRef.SetTintColor(white); }

	// Needle body should use the theme reserve red.
	if IsDefined(this.ndBaseRef) { this.ndBaseRef.SetTintColor(reserveRed); }
	if IsDefined(this.ndMidRef)  { this.ndMidRef.SetTintColor(reserveRed); }
	if IsDefined(this.ndTipRef)  { this.ndTipRef.SetTintColor(reserveRed); }

}
	// New Gas Pump Warning/Empty — pump-only flash/glow
	private func __ApplyWarnPalette(state: Int32, blink: Bool) -> Void {
		// CP-style colors (local to this function)
		let normal: HDRColor = this.__ThemeMainColor(this.fgThemeLast);
		let amber:  HDRColor; amber.Red =1.00; amber.Green =0.80; amber.Blue =0.10; amber.Alpha =1.0;
		let red:    HDRColor; red.Red   =1.00; red.Green   =0.22; red.Blue   =0.22; red.Alpha   =1.0;

		// blink opacity (entire glyph)
		let a: Float = (state == 0) ? 1.0 : (blink ? 1.0 : 0.35);

		// choose tint: empty -> red, soon -> amber, otherwise cyan
		let tint: HDRColor = (state == 2) ? red : ((state == 1) ? amber : normal);

		if IsDefined(this.pumpImgRef) {
			this.pumpImgRef.SetTintColor(tint);
			this.pumpImgRef.SetOpacity(a);
		}

		// keep any legacy glow off
		if IsDefined(this.pumpGlowRef) { this.pumpGlowRef.SetOpacity(0.0); }
	}


	// End ApplyWarnPalette

	// Show/hide the Temp meter group from CET fact vm_fg_temp_visible (1=on, 0=off)
	private func ApplyTempVisibility() -> Void {
		if !IsDefined(this.tempWrapRef) { return; }
		let qs = GameInstance.GetQuestsSystem(GetGameInstance());
		let on: Bool = IsDefined(qs) && (qs.GetFact(n"vm_fg_temp_visible") > 0);

		// Redscript: avoid '!=' on Bool
		let changed: Bool = (on && !this.tempVisibleCached) || (!on && this.tempVisibleCached);
		if changed {
			this.tempVisibleCached = on;
			this.tempWrapRef.SetVisible(on);
		}
	}


	// Show/hide gate: HUD facts + mounted vehicle dashboard power + modal depth.
	private func IsMountedVehicleUIActive() -> Bool {
		let player = GetPlayer(GetGameInstance());
		if !IsDefined(player) { return false; }

		let vehicle = player.GetMountedVehicle();
		if !IsDefined(vehicle) { return false; }

		let blackboard: ref<IBlackboard> = vehicle.GetBlackboard();
		return IsDefined(blackboard)
			&& blackboard.GetBool(GetAllBlackboardDefs().Vehicle.IsUIActive);
	}

  private func ApplyVisibilityGate() -> Void {
    if !IsDefined(this.root) { return; }
    let qs = GameInstance.GetQuestsSystem(GetGameInstance());

    let showByFact: Bool      = IsDefined(qs) && (qs.GetFact(n"vm_hud_visible") == 1);
    let enabledBySwitch: Bool = IsDefined(qs) ? (qs.GetFact(n"vm_fg_enabled") == 1) : true;
    let vehicleUIActive: Bool = this.IsMountedVehicleUIActive();
    let want: Bool            = showByFact && enabledBySwitch && vehicleUIActive && (this.modalDepth == 0);

    // Keep for debugging / future use, but don't rely on its transitions
    this.wantVisible = want;

		// Power-off and dismount must clear the alarm even if the normal visibility
		// transition was missed while the vehicle UI was being disabled.
		if !want {
			this.alarmActive = false;
			this.alarmPhase  = 0;
			this.alarmTimer  = 0.0;
			this.alarmAlpha  = 0.0;
			if IsDefined(this.alarmImgRef) {
				this.alarmImgRef.SetOpacity(0.0);
				this.alarmImgRef.SetVisible(false);
			}
		}

    // Consider the gauge "on" if it was fully visible or currently animating
    let wasOn: Bool = this.lastVisible || this.bootupActive || this.shutdownActive;

		// Direct UI mode calls and reused HUD roots must not be able to bypass
		// the power/mount gate while it is steadily off.
		if !want && !wasOn {
			this.root.SetOpacity(0.0);
			this.root.SetVisible(false);
			this.root.SetScale(new Vector2(this.SCALE_X, this.SCALE_Y));
			this.lastVisible = false;
			return;
		}

    // ── Turning ON → start boot-up ─────────────────────────────
    if want && !wasOn {
      this.shutdownActive = false;
      this.bootupActive   = true;
      this.bootupTimer    = 0.0;
      this.bootupPhase    = 0.0;

      if IsDefined(this.root) {
        this.root.SetVisible(true);
        this.root.SetOpacity(this.BOOTUP_ALPHA_START);
        let startScale: Float = this.BOOTUP_SCALE_START;
        this.root.SetScale(new Vector2(
          this.SCALE_X * startScale,
          this.SCALE_Y * startScale
        ));
      }

      // Gauge is now logically "on" (even while booting)
      this.lastVisible = true;

      // drive boot-up at high FPS
      this.ArmAnimStep();
      return;
    }

    // ── Turning OFF → start CRT shutdown ──────────────────────
    if !want && wasOn && !this.shutdownActive {
      // stop any boot-up in progress
      this.bootupActive = false;

      if IsDefined(this.root) {
        // keep it drawn while we animate the shutdown
        this.root.SetVisible(true);
        this.root.SetOpacity(1.0);
        this.root.SetScale(new Vector2(this.SCALE_X, this.SCALE_Y));
      }

      this.shutdownActive = true;
      this.shutdownTimer  = 0.0;
      this.shutdownPhase  = 0.0;

      // drive shutdown at high FPS
      this.ArmAnimStep();
      return;
    }

    // No transition → keep current boot/shutdown state
  }

}

// lifecycle hooks
@addField(UISystem) public let vmFuelGauge: ref<VM_FuelGauge>;

@wrapMethod(UISystem)
public final func PushGameContext(context: UIGameContext) -> Void {
  wrappedMethod(context);
  if !IsDefined(this.vmFuelGauge) { this.vmFuelGauge = new VM_FuelGauge(); }
  this.vmFuelGauge.Ensure();
	this.vmFuelGauge.OnContextPushed();
}

@wrapMethod(UISystem)
public final func PopGameContext(context: UIGameContext, opt invalidate: Bool) -> Void {
  wrappedMethod(context, invalidate);
  if !IsDefined(this.vmFuelGauge) { this.vmFuelGauge = new VM_FuelGauge(); }
  this.vmFuelGauge.Ensure();
	this.vmFuelGauge.OnContextPopped();
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(resolver: EntityResolveComponentsInterface) -> Bool {
  let r = wrappedMethod(resolver);
  let uiSys: ref<UISystem> = GameInstance.GetUISystem(GetGameInstance());
  if IsDefined(uiSys) {
    if !IsDefined(uiSys.vmFuelGauge) { uiSys.vmFuelGauge = new VM_FuelGauge(); }
    uiSys.vmFuelGauge.OnNewWorld();
    uiSys.vmFuelGauge.Ensure();
  }
  return r;
}
