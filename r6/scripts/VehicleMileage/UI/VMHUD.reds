module VehicleMileage.UI

import Codeware.UI.VirtualResolutionWatcher
import VehicleMileage.Services.VMSettingsService

// ============================================================================
// Small polling callback
// ============================================================================
public class VM_HUDTick extends DelayCallback {
  private let hud: wref<VM_HUD>;

  public func Call() -> Void {
    if IsDefined(this.hud) {
      this.hud.__tickArmed = false;
      this.hud.Refresh();
      this.hud.ArmNextTick();
    }
  }

  public static func Create(h: ref<VM_HUD>) -> ref<VM_HUDTick> {
    let t = new VM_HUDTick();
    t.hud = h;
    return t;
  }
}


// ============================================================================
// Small, fast tick to play the LB "boot-up" animation
// ============================================================================
public class VM_LBAnimTick extends DelayCallback {
  private let hud: wref<VM_HUD>;

  public func Call() -> Void {
    if IsDefined(this.hud) {
      this.hud.__lbAnimArmed = false;
      this.hud.LB_AniStep();
    }
  }

  public static func Create(h: ref<VM_HUD>) -> ref<VM_LBAnimTick> {
    let t = new VM_LBAnimTick();
    t.hud = h;
    return t;
  }
}

// ============================================================================
// Small, fast tick to drive the LB_Logo scanline loop
// ============================================================================
public class VM_LBLogoTick extends DelayCallback {
  private let hud: wref<VM_HUD>;

  public func Call() -> Void {
    if IsDefined(this.hud) {
      this.hud.__lbLogoArmed = false;
      this.hud.LB_LogoStep();
    }
  }

  public static func Create(h: ref<VM_HUD>) -> ref<VM_LBLogoTick> {
    let t = new VM_LBLogoTick();
    t.hud = h;
    return t;
  }
}

// ============================================================================
// Fast tick to drive the TOP10 row-by-row fade-in
// ============================================================================
public class VM_LBRowTick extends DelayCallback {
  private let hud: wref<VM_HUD>;

  public func Call() -> Void {
    if IsDefined(this.hud) {
      this.hud.__lbRowArmed = false;
      this.hud.LB_RowStep();
    }
  }

  public static func Create(h: ref<VM_HUD>) -> ref<VM_LBRowTick> {
    let t = new VM_LBRowTick();
    t.hud = h;
    return t;
  }
}



// ============================================================================
// HUD widget (Fuel %, Odometer, warnings, price plate)
// ============================================================================
public class VM_HUD extends IScriptable {

  // --- update scheduling ---
  private let vrw: ref<VirtualResolutionWatcher>;
  private let tick: ref<VM_HUDTick>;
  private let tickPeriod: Float = 0.25; // 4 Hz
  public let __tickArmed: Bool;

  // --- build & state caches ---
  private let __built: Bool;
  private let lastMeters: Int32;
  private let lastPermille: Int32;
  private let modalDepth: Int32;
  private let blinkOn: Bool;

  // --- LB boot-up animation state ---
  private let lbAnimTick: ref<VM_LBAnimTick>;
  public let __lbAnimArmed: Bool;
  private let lbAnimStep: Int32;
  private let lbAnimSteps: Int32 = 12;        // ~12 frames total
  private let lbAnimPeriod: Float = 0.02;     // 0.02s per step => ~0.24s total
  private let lbAnimDir: Int32;               // +1 = appear, -1 = disappear, 0 = idle


  private let vmPosVer: Uint32;
  private let lastUserX: Float;
  private let lastUserY: Float;

  // --- warning sound events (set to n"" to disable) ---
  private let SND_SOON: CName  = n"warning";
  private let SND_EMPTY: CName = n"";
  private let lastWarnState: Int32; // 0 = none, 1 = soon, 2 = empty, -1 = uninitialized

  // --- placement (virtual 3840x2160 canvas) ---
  private let MARGIN_LEFT: Float   = 280.0;
  private let MARGIN_BOTTOM: Float = 443.0;

  // --- typography ---
  private let FONT_SIZE: Int32 = 36;

  // --- horizontal layout ---
  private let X_FUEL_LABEL: Float = 0.0;
  private let X_FUEL_VALUE: Float = 100.0;
  private let X_MILE_LABEL: Float = 190.0;
  private let X_MILE_VALUE: Float = 270.0;

  // --- vertical offsets ---
  private let Y_LINE: Float    = 0.0;
  private let Y_WARN_UP: Float = 44.0;

  // --- price plate placement (relative to screen center; virtual 3840×2160) ---
  private let PRICE_OFFSET_X: Float = 0.0;
  private let PRICE_OFFSET_Y: Float = 350.0;



  // --- price plate refs/caches ---
  private let priceRoot: wref<inkCanvas>;
  private let priceTitle: wref<inkText>;
  private let priceValue: wref<inkText>;
  private let priceBuilt: Bool;
  private let lastPriceVisible: Bool;
  private let lastPriceCents: Int32;
	
	// Keep priceRoot visible while the LB plays its fade-out
  private let priceHoldVisibleDuringLB: Bool;   // NEW
	
	// --- TOP10 “ODO” widget placement (relative to the Price Plate center) ---
  // Defaults: center on the same spot as the Price Plate (tweak later via setters)
  private let LB_OFFSET_X: Float  = 800.0;   
  private let LB_OFFSET_Y: Float  = 800.0;
  private let LB_SCALE:  Float    = 0.8;

	// --- TOP10 refs/caches ---
	private let lbRoot: wref<inkCanvas>;           // root for the big plate
	private let lbRowsRoot: wref<inkCanvas>;       // rows container
	private let lbRowText: array<wref<inkText>>;   // 10 text refs
	private let lbTitle: wref<inkText>;
	private let lbBuilt: Bool;

	// Leaderboard theme refs
	private let lbThemeLast: Int32;
	private let lbBgStrokeRef: wref<inkImage>;
	private let lbRowStrokeRefs: array<wref<inkImage>>;
	// Corp logo + FX overlay
	private let lbLogo: wref<inkImage>;
	private let lbLogoFX: wref<inkImage>;

	// Logo animation state
	private let lbLogoTick: ref<VM_LBLogoTick>;
	public let __lbLogoArmed: Bool;
	private let lbLogoPhase: Float;                  // 0..1
	private let lbLogoPeriod: Float = 0.03;          // ~33 ms ~30 fps
	private let lbLogoAmpY: Float = 1.5;             // sweep amplitude (pixels)
	private let lbLogoA_min: Float = 0.10;           // min overlay opacity
	private let lbLogoA_max: Float = 0.25;           // max overlay opacity
	private let lbLogoDX: Float;                     // base translation X (logo)
	private let lbLogoDY: Float;                     // base translation Y (logo)
  private let lbEnabled: Bool;                   // master toggle (still gated by price plate)
  private let lbLastVisible: Bool;

	// Row cascade animation state
	private let lbRowTick: ref<VM_LBRowTick>;
	public let __lbRowArmed: Bool;
	private let lbRowCur: Int32;                 // current row index (9..0)
	private let lbRowStep: Int32;                // step inside one row
	private let lbRowSteps: Int32 = 6;           // frames per row fade (fast)
	private let lbRowPeriod: Float = 0.02;       // 30–33 ms per step (~0.18s/row)

	
	// --- warning audio loop state (5% fuel) ---
	private let warnSoonLoopsLeft: Int32;       // remaining plays in the current burst
	private let warnSoonTickWait: Int32;        // tick countdown until next play
	private let warnSoonTickInterval: Int32 = 20; // 20 ticks × 0.25s = 5.0s between plays

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  // Depth-first search for a descendant widget by name under a compound parent.
  private func __FindDescByNameRec(parent: wref<inkCompoundWidget>, name: CName) -> wref<inkWidget> {
    if !IsDefined(parent) { return null; }
    let n: Int32 = parent.GetNumChildren();
    let i: Int32 = 0;
    while i < n {
      let child: wref<inkWidget> = parent.GetWidget(i);
      if IsDefined(child) && Equals(child.GetName(), name) { return child; }
      let c: wref<inkCompoundWidget> = child as inkCompoundWidget;
      let hit: wref<inkWidget> = this.__FindDescByNameRec(c, name);
      if IsDefined(hit) { return hit; }
      i += 1;
    }
    return null;
  }

  // Return the same root GT uses: virtualWindowRoot = vwin.GetWidget(0). Fallback to "Root".
  private func __GetVirtualWindowRoot(vwin: wref<inkCompoundWidget>) -> wref<inkCompoundWidget> {
    if !IsDefined(vwin) { return null; }
    let root0: wref<inkCompoundWidget> = vwin.GetWidget(0) as inkCompoundWidget;
    if IsDefined(root0) { return root0; }
    return vwin.GetWidgetByPathName(n"Root") as inkCompoundWidget;
  }

  // Keep our full-screen slot OUTSIDE GT’s scan window (45..54) if we accidentally sit there.
  private func __GT_AvoidWindow() -> Void {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return; }
    let layer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(layer) { return; }
    let vwin: wref<inkCompoundWidget> = layer.GetVirtualWindow();
    if !IsDefined(vwin) { return; }

    let root0: wref<inkCompoundWidget> = this.__GetVirtualWindowRoot(vwin);
    if !IsDefined(root0) { return; }

    // Find our FS slot among direct children
    let count: Int32 = root0.GetNumChildren();
    if count <= 0 { return; }
    let fsName: CName = n"VM_FullScreenSlot";
    let idx: Int32 = -1;
    let fs: wref<inkWidget>;
    let i: Int32 = 0;
    while i < count {
      let w = root0.GetWidget(i);
      if IsDefined(w) && Equals(w.GetName(), fsName) {
        idx = i;
        fs = w;
        break;
      }
      i += 1;
    }
    if idx < 0 || !IsDefined(fs) { return; }

    // If our node sits inside 45..54, push it to the end to avoid disturbing GT’s scan.
    if idx >= 45 && idx <= 54 {
      root0.ReorderChild(fs, count - 1);
    }
  }

  // Keep Generative Texting happy: its lookup only scans indices 45..54 under virtualWindowRoot.
  // If the phone "middle" drifted outside, move it into that window (prefer 54).
  private func __FixGT_PhoneMiddleIndex() -> Void {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return; }
    let layer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(layer) { return; }
    let vwin: wref<inkCompoundWidget> = layer.GetVirtualWindow();
    if !IsDefined(vwin) { return; }

    let root0: wref<inkCompoundWidget> = this.__GetVirtualWindowRoot(vwin);
    if !IsDefined(root0) { return; }

    let count: Int32 = root0.GetNumChildren();
    if count <= 0 { return; }

    let i: Int32 = 0;
    let foundIdx: Int32 = -1;
    let mid: wref<inkCanvas>;

    while i < count {
      let cand: wref<inkCanvas> = root0.GetWidget(i) as inkCanvas;
      if IsDefined(cand) {
        let p0: wref<inkCompoundWidget> = cand.GetWidget(0) as inkCompoundWidget;
        if IsDefined(p0) {
          let slot: wref<inkWidget> = this.__FindDescByNameRec(p0, n"contact_list_slot");
          if !IsDefined(slot) {
            slot = this.__FindDescByNameRec(p0, n"sms_messenger_slot");
          }
          if IsDefined(slot) {
            foundIdx = i;
            mid = cand;
            break;
          }
        }
      }
      i += 1;
    }

    if foundIdx < 0 || !IsDefined(mid) { return; } // phone UI not present yet

    let target: Int32 = 54;
    if target >= count { target = count - 1; }

    if foundIdx < 45 || foundIdx > 54 {
      if target != foundIdx {
        root0.ReorderChild(mid, target);
      }
    }
  }

  // --------------------------------------------------------------------------
  // Tiny audio helper (one-shot)
  // --------------------------------------------------------------------------
  private func PlayEvent(ev: CName) -> Void {
    if NotEquals(ev, n"") {
      let asys: ref<AudioSystem> = GameInstance.GetAudioSystem(GetGameInstance());
      if IsDefined(asys) {
        asys.Play(ev);
      }
    }
  }

  // --------------------------------------------------------------------------
  // Reset when the world/save changes
  // --------------------------------------------------------------------------
	public func OnNewWorld() -> Void {
		this.__built = false;
		this.__tickArmed = false;
		this.modalDepth = 0;

		// Force first Refresh() to rewrite text from facts.
		// Fixes possible stale ODO text after save/load timing.
		this.lastMeters = -1;
		this.lastPermille = -1;

		this.lastWarnState = -1;
		this.blinkOn = false;

    // price plate reset
    this.priceRoot = null;
    this.priceTitle = null;
    this.priceValue = null;
    this.priceBuilt = false;
    this.lastPriceVisible = false;
    this.lastPriceCents = -1;
		
		// ensure LB starts fully hidden on save/world change (prevents one-frame snapshot)
		this.lbLastVisible = false;
		if IsDefined(this.lbRoot) {
			this.lbRoot.SetVisible(false);
			this.lbRoot.SetOpacity(0.0);
		}
		
		this.LB_ZeroRows();      // hide all row texts immediately (opacity 0)

		
		// warn sound reset
		this.warnSoonLoopsLeft = 0;
		this.warnSoonTickWait = 0;
		
    // LB animation reset
    this.__lbAnimArmed = false;
    this.lbAnimStep = 0;
    this.lbAnimDir = 0;

		// Price plate hide deferral
    this.priceHoldVisibleDuringLB = false;      // NEW
		
		// Logo loop reset
		this.__lbLogoArmed = false;
		this.lbLogoPhase = 0.0;
		
		// Row cascade reset
		this.__lbRowArmed = false;
		this.lbRowCur = -1;
		this.lbRowStep = 0;
		// Leaderboard theme reset
		this.lbThemeLast = -999;
		this.lbBgStrokeRef = null;
		ArrayClear(this.lbRowStrokeRefs);

  }

  // --------------------------------------------------------------------------
  // Helper: does our root exist in the live Ink tree?
  // --------------------------------------------------------------------------
  private func RootExists(vwin: wref<inkCompoundWidget>) -> Bool {
    if !IsDefined(vwin) { return false; }
    let w = vwin.GetWidgetByPathName(n"Root/VM_FullScreenSlot/VM_WidgetSlot/VM_HUDRoot");
    return IsDefined(w);
  }

  // --------------------------------------------------------------------------
  // Apply price plate offset from service (centered plate)
  // --------------------------------------------------------------------------
  private func ApplyPriceOffsetFromService() -> Void {
    if !IsDefined(this.priceRoot) { return; }
    let svc = VMSettingsService.Svc();
    if !IsDefined(svc) { return; }
    this.priceRoot.SetTranslation(new Vector2(0.0 - svc.GetPriceDx(), 0.0 - svc.GetPriceDy()));
  }

  // --------------------------------------------------------------------------
  // Ensure UI tree exists and is scaled/positioned
  // --------------------------------------------------------------------------
  public func Ensure() -> Void {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return; }
    let hudLayer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(hudLayer) { return; }
    let vwin: ref<inkCompoundWidget> = hudLayer.GetVirtualWindow();
    if !IsDefined(vwin) { return; }

    let rootNode = vwin.GetWidgetByPathName(n"Root") as inkCompoundWidget;
    if !IsDefined(rootNode) { return; }

    // Ensure our persistent service exists early
    let _svcTouch = VMSettingsService.Svc();

    // If widgets were destroyed by a save/load, force rebuild
    if this.__built && !this.RootExists(vwin) {
      this.__built = false;
    }

    if !this.__built {
      // (1) fullscreen virtual canvas (create or reuse)
      let fs: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/VM_FullScreenSlot") as inkCanvas;
      if !IsDefined(fs) {
        fs = new inkCanvas();
        fs.SetName(n"VM_FullScreenSlot");
        fs.SetSize(new Vector2(3840.0, 2160.0));
        fs.SetRenderTransformPivot(new Vector2(0.0, 0.0));
        fs.SetInteractive(false);
        fs.Reparent(rootNode);
      } else {
        fs.SetInteractive(false);
      }
      if !IsDefined(this.vrw) {
        this.vrw = new VirtualResolutionWatcher();
        this.vrw.Initialize(GetGameInstance());
      }
      this.vrw.ScaleWidget(fs);

      // (2) local slot (create or reuse)
      let slot: ref<inkCanvas> = fs.GetWidgetByPathName(n"VM_WidgetSlot") as inkCanvas;
      if !IsDefined(slot) {
        slot = new inkCanvas();
        slot.SetName(n"VM_WidgetSlot");
        slot.SetFitToContent(true);
        slot.SetInteractive(false);
        slot.Reparent(fs);
        slot.SetScale(new Vector2(1.0, 1.0));
      } else {
        slot.SetInteractive(false);
      }
      // Update placement every Ensure
      this.ApplyHUDPosFromService();
			
			// NEW: make the slot respect vm_fg_enabled immediately after (re)build
			let qs = GameInstance.GetQuestsSystem(GetGameInstance());
			if IsDefined(qs) {
				slot.SetVisible(qs.GetFact(n"vm_fg_enabled") == 0);
			}

      // (3) content root (create or reuse)
      let root: ref<inkCanvas> = slot.GetWidgetByPathName(n"VM_HUDRoot") as inkCanvas;
      if !IsDefined(root) {
        root = new inkCanvas();
        root.SetName(n"VM_HUDRoot");
        root.SetInteractive(false);
        root.SetAnchor(inkEAnchor.TopLeft);
        root.Reparent(slot);
      }

      // (3b) centered price plate on the fullscreen canvas
      this.EnsurePricePlate(fs);

      // Ensure children text widgets exist (idempotent)
      let white: HDRColor; white.Red = 1.0; white.Green = 1.0; white.Blue = 1.0; white.Alpha = 1.0;
      let accent: HDRColor; accent.Red = 0.72; accent.Green = 0.62; accent.Blue = 0.15; accent.Alpha = 1.0;

      // Warning
      let warn: ref<inkText> = root.GetWidgetByPathName(n"VM_WarnText") as inkText;
      if !IsDefined(warn) {
        warn = new inkText();
        warn.SetName(n"VM_WarnText");
        warn.SetAnchor(inkEAnchor.TopLeft);
        warn.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        warn.SetFontSize(this.FONT_SIZE);
        warn.SetLetterCase(textLetterCase.OriginalCase);
        warn.SetOpacity(0.0);
        warn.SetTranslation(new Vector2(0.0, 0.0 - this.Y_WARN_UP));
        warn.SetText("-FUEL EMPTY-");
        warn.Reparent(root);
      }

      // Fuel label
      let fl: ref<inkText> = root.GetWidgetByPathName(n"VM_FuelLabel") as inkText;
      if !IsDefined(fl) {
        fl = new inkText();
        fl.SetName(n"VM_FuelLabel");
        fl.SetAnchor(inkEAnchor.TopLeft);
        fl.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        fl.SetFontSize(this.FONT_SIZE);
        fl.SetLetterCase(textLetterCase.OriginalCase);
        fl.SetTintColor(accent);
        fl.SetOpacity(1.0);
        fl.SetTranslation(new Vector2(this.X_FUEL_LABEL, this.Y_LINE));
        fl.SetText("Fuel:");
        fl.Reparent(root);
      }

      // Fuel value
      let fv: ref<inkText> = root.GetWidgetByPathName(n"VM_FuelValue") as inkText;
      if !IsDefined(fv) {
        fv = new inkText();
        fv.SetName(n"VM_FuelValue");
        fv.SetAnchor(inkEAnchor.TopLeft);
        fv.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        fv.SetFontSize(this.FONT_SIZE);
        fv.SetLetterCase(textLetterCase.OriginalCase);
        fv.SetTintColor(white);
        fv.SetOpacity(1.0);
        fv.SetTranslation(new Vector2(this.X_FUEL_VALUE, this.Y_LINE));
        fv.SetText("0%");
        fv.Reparent(root);
      }

      // ODO label
      let ml: ref<inkText> = root.GetWidgetByPathName(n"VM_MileLabel") as inkText;
      if !IsDefined(ml) {
        ml = new inkText();
        ml.SetName(n"VM_MileLabel");
        ml.SetAnchor(inkEAnchor.TopLeft);
        ml.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        ml.SetFontSize(this.FONT_SIZE);
        ml.SetLetterCase(textLetterCase.OriginalCase);
        ml.SetTintColor(accent);
        ml.SetOpacity(1.0);
        ml.SetTranslation(new Vector2(this.X_MILE_LABEL, this.Y_LINE));
        ml.SetText("ODO:");
        ml.Reparent(root);
      }

      // Odometer value
      let mv: ref<inkText> = root.GetWidgetByPathName(n"VM_MileValue") as inkText;
      if !IsDefined(mv) {
        mv = new inkText();
        mv.SetName(n"VM_MileValue");
        mv.SetAnchor(inkEAnchor.TopLeft);
        mv.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        mv.SetFontSize(this.FONT_SIZE);
        mv.SetLetterCase(textLetterCase.OriginalCase);
        mv.SetTintColor(white);
        mv.SetOpacity(1.0);
        mv.SetTranslation(new Vector2(this.X_MILE_VALUE, this.Y_LINE));
        mv.SetText("0.0");
        mv.Reparent(root);
      }

      this.lastMeters = -1;
      this.lastPermille = -1;
      this.blinkOn = false;
      this.lastWarnState = -1;
      this.__built = true;

    } else {
      // Already built: keep scaling fresh, rebind the plate if needed, and keep nodes non-interactive.
      let fs2c: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/VM_FullScreenSlot") as inkCanvas;
      if IsDefined(fs2c) {
        fs2c.SetInteractive(false);
        if IsDefined(this.vrw) { this.vrw.ScaleWidget(fs2c); }
        this.EnsurePricePlate(fs2c); // safe; only builds if missing
      }

      let slot2: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/VM_FullScreenSlot/VM_WidgetSlot") as inkCanvas;
      if IsDefined(slot2) {
        slot2.SetInteractive(false);
      }

      this.ApplyHUDPosFromService();

      if !this.RootExists(vwin) {
        this.__built = false;
      }
    }

    // Compatibility: avoid GT’s window and ensure phone middle is in range.
    this.__GT_AvoidWindow();
    this.__FixGT_PhoneMiddleIndex();

    this.Refresh();
    this.ArmNextTick();
  }

  // --------------------------------------------------------------------------
  // Modal/phone overlay hide gate
  // --------------------------------------------------------------------------
  public func OnContextPushed() -> Void {
    this.modalDepth += 1;
    this.ApplyVisibilityGate();
  }

  public func OnContextPopped() -> Void {
    if this.modalDepth > 0 { this.modalDepth -= 1; }
    this.ApplyVisibilityGate();
  }

  // --------------------------------------------------------------------------
  // Arms the next delayed refresh tick (if not already armed)
  // --------------------------------------------------------------------------
  private func ArmNextTick() -> Void {
    if this.__tickArmed { return; }
    let ds = GameInstance.GetDelaySystem(GetGameInstance());
    this.tick = VM_HUDTick.Create(this);
    this.__tickArmed = true;
    ds.DelayCallback(this.tick, this.tickPeriod, false);
  }
	
	// Arm one fast animation step (0.02s later)
	private func ArmLBAnimStep() -> Void {
		if this.__lbAnimArmed { return; }
		let ds = GameInstance.GetDelaySystem(GetGameInstance());
		this.lbAnimTick = VM_LBAnimTick.Create(this);
		this.__lbAnimArmed = true;
		ds.DelayCallback(this.lbAnimTick, this.lbAnimPeriod, false);
	}


	// Start the boot-up animation (called when LB becomes visible)
	private func StartLBAppear() -> Void {
		if !IsDefined(this.lbRoot) { 
			return; 
		}

		// Start from fully transparent & shown, then zero rows
		this.lbRoot.SetOpacity(0.0);
		this.lbRoot.SetVisible(true);
		this.LB_ZeroRows();                         // clear texts/row opacities

		// Animation setup
		this.lbAnimDir = 1;                         // appear
		this.lbAnimStep = 0;

		let sEnd: Float = this.LB_SCALE;
		let sStart: Float = sEnd * 0.92;            // 92% → 100%
		this.lbRoot.SetScale(new Vector2(sStart, sStart));
		this.lbLastVisible = true;

		this.ArmLBAnimStep();
	}


	private func LB_ZeroRows() -> Void {
		let i: Int32 = 0;
		while i < ArraySize(this.lbRowText) {
			if IsDefined(this.lbRowText[i]) {
				this.lbRowText[i].SetOpacity(0.0);
			}
			i += 1;
		}
	}

	// Hard reset Leaderboard visuals (instant, no animation)
	private func LB_HardHide() -> Void {
		this.lbLastVisible = false;
		if IsDefined(this.lbRoot) {
			this.lbRoot.SetVisible(false);
			this.lbRoot.SetOpacity(0.0);
		}
		this.LB_ZeroRows();   // clear all row texts / set row opacities to 0
	}



	private func ArmLBLogoStep() -> Void {
		if this.__lbLogoArmed { return; }
		let ds = GameInstance.GetDelaySystem(GetGameInstance());
		this.lbLogoTick = VM_LBLogoTick.Create(this);
		this.__lbLogoArmed = true;
		ds.DelayCallback(this.lbLogoTick, this.lbLogoPeriod, false);
	}

	private func StartLogoLoop() -> Void {
		if !IsDefined(this.lbLogoFX) { return; }
		this.lbLogoPhase = 0.0;
		this.ArmLBLogoStep();
	}

	private func StopLogoLoop() -> Void {
		// no hard cancel needed; we just won't re-arm
		this.__lbLogoArmed = false;
		if IsDefined(this.lbLogoFX) {
			this.lbLogoFX.SetOpacity(0.0);
			this.lbLogoFX.SetTranslation(new Vector2(this.lbLogoDX, this.lbLogoDY));
		}
	}

	// One loop step: triangle wave for opacity + Y sweep
	public func LB_LogoStep() -> Void {
		if !IsDefined(this.lbLogoFX) { return; }

		// continue only while the price plate is visible or we're deferring its hide
		let run: Bool = this.lastPriceVisible || this.priceHoldVisibleDuringLB;
		if !run { return; }

		// 0..1 triangle wave
		let ph: Float = this.lbLogoPhase;
		let tri: Float = (ph < 0.5) ? (ph * 2.0) : ((1.0 - ph) * 2.0); // 0→1→0
		let a: Float = this.lbLogoA_min + (this.lbLogoA_max - this.lbLogoA_min) * tri;
		let dy: Float = this.lbLogoDY + (-this.lbLogoAmpY + (2.0 * this.lbLogoAmpY) * tri);

		this.lbLogoFX.SetOpacity(a);
		this.lbLogoFX.SetTranslation(new Vector2(this.lbLogoDX, dy));

		// advance phase (wrap at 1.0)
		let step: Float = 0.05; // speed of sweep; tweak to taste
		this.lbLogoPhase = ph + step;
		if this.lbLogoPhase >= 1.0 { this.lbLogoPhase = this.lbLogoPhase - 1.0; }

		// re-arm next step
		this.ArmLBLogoStep();
	}


	private func StartLBDisappear() -> Void {
		if !IsDefined(this.lbRoot) { return; }

		this.lbAnimDir = -1;                        // disappear
		this.lbAnimStep = 0;

		// Start from fully shown (1.0, 1.00×) and animate to 0.0, 0.92×
		this.lbRoot.SetOpacity(1.0);
		this.lbRoot.SetScale(new Vector2(this.LB_SCALE, this.LB_SCALE));
		this.lbRoot.SetVisible(true);               // keep visible until the fade completes

		this.ArmLBAnimStep();
	}


	// One animation step: fade 0→1, scale 0.92→1.00 over lbAnimSteps
	public func LB_AniStep() -> Void {
		if !IsDefined(this.lbRoot) { return; }

		let steps: Int32 = this.lbAnimSteps;
		let i: Int32 = this.lbAnimStep;

		if i >= steps || this.lbAnimDir == 0 {
			// Finish cleanly depending on direction
			if this.lbAnimDir == 1 {
				// appear end state
				this.lbRoot.SetOpacity(1.0);
				this.lbRoot.SetScale(new Vector2(this.LB_SCALE, this.LB_SCALE));
				this.lbLastVisible = true;
				
				// NEW: fade rows 10→1
				this.StartLBRowCascade();
				
			} else if this.lbAnimDir == -1 {
				// disappear end state
				this.lbRoot.SetOpacity(0.0);
				this.lbRoot.SetScale(new Vector2(this.LB_SCALE * 0.92, this.LB_SCALE * 0.92));
				this.lbRoot.SetVisible(false);
				this.lbLastVisible = false;

				// stop logo loop (after fade completes)
				this.StopLogoLoop();

				// Now that the child faded out, hide the container if we deferred it
				if this.priceHoldVisibleDuringLB && IsDefined(this.priceRoot) {
					this.priceRoot.SetVisible(false);
					this.priceHoldVisibleDuringLB = false;
				}

				// snap child back to baseline so the next appear starts clean
				this.lbRoot.SetOpacity(1.0);
				this.lbRoot.SetScale(new Vector2(this.LB_SCALE, this.LB_SCALE));
			}
			this.lbAnimDir = 0;
			return;

		}

		// Normalized progress (0,1]
		let t: Float = Cast<Float>(i + 1) / Cast<Float>(steps);

		// Interpolate per direction
		if this.lbAnimDir == 1 {
			// APPEAR: 0.92× → 1.00×, 0.0 → 1.0
			let sStart: Float = this.LB_SCALE * 0.92;
			let sEnd: Float   = this.LB_SCALE;
			let sNow: Float   = sStart + (sEnd - sStart) * t;
			let aNow: Float   = 0.0 + (1.0 - 0.0) * t;
			this.lbRoot.SetScale(new Vector2(sNow, sNow));
			this.lbRoot.SetOpacity(aNow);
		} else if this.lbAnimDir == -1 {
			// DISAPPEAR: 1.00× → 0.92×, 1.0 → 0.0
			let sStart: Float = this.LB_SCALE;
			let sEnd: Float   = this.LB_SCALE * 0.92;
			let sNow: Float   = sStart + (sEnd - sStart) * t;
			let aNow: Float   = 1.0 + (0.0 - 1.0) * t;
			this.lbRoot.SetScale(new Vector2(sNow, sNow));
			this.lbRoot.SetOpacity(aNow);
		}

		this.lbAnimStep = i + 1;
		this.ArmLBAnimStep();
	}


	private func ArmLBRowStep() -> Void {
		if this.__lbRowArmed { return; }
		let ds = GameInstance.GetDelaySystem(GetGameInstance());
		this.lbRowTick = VM_LBRowTick.Create(this);
		this.__lbRowArmed = true;
		ds.DelayCallback(this.lbRowTick, this.lbRowPeriod, false);
	}

	// Kick off the "10→1" fade-in; make all rows transparent first
	public func StartLBRowCascade() -> Void {
		if ArraySize(this.lbRowText) <= 0 { return; }
		let i: Int32 = 0;
		while i < ArraySize(this.lbRowText) {
			if IsDefined(this.lbRowText[i]) { this.lbRowText[i].SetOpacity(0.0); }
			i += 1;
		}
		this.lbRowCur = ArraySize(this.lbRowText) - 1;  // start at last row (#10)
		this.lbRowStep = 0;
		this.ArmLBRowStep();
	}

	// One step of the current row fade; when done, jump to the previous row
	public func LB_RowStep() -> Void {
		if !IsDefined(this.lbRoot) { return; }
		// If the plate isn’t visible anymore, abort gracefully
		if !this.lbLastVisible && !this.priceHoldVisibleDuringLB { return; }
		if this.lbRowCur < 0 { return; }  // finished

		let steps: Int32 = Max(1, this.lbRowSteps);
		let i: Int32 = this.lbRowStep;
		let idx: Int32 = this.lbRowCur;

		let t: Float = Cast<Float>(i + 1) / Cast<Float>(steps); // 0→1

		let w: wref<inkText> = this.lbRowText[idx];
		if IsDefined(w) { w.SetOpacity(t); }

		this.lbRowStep = i + 1;

		if this.lbRowStep >= steps {
			// finalize this row
			this.lbRowStep = 0;
			this.lbRowCur = idx - 1;        // next: previous row (e.g., 10→9)
			if this.lbRowCur < 0 {
				// All rows done — stop without re-arming
				return;
			}
		}
		// Continue animating
		this.ArmLBRowStep();
	}



  // --------------------------------------------------------------------------
  // Utility: find the VM_HUD root canvas
  // --------------------------------------------------------------------------
  private func FindRoot() -> ref<inkCanvas> {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return null; }
    let hudLayer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(hudLayer) { return null; }
    let vwin: ref<inkCompoundWidget> = hudLayer.GetVirtualWindow();
    if !IsDefined(vwin) { return null; }
    return vwin.GetWidgetByPathName(n"Root/VM_FullScreenSlot/VM_WidgetSlot/VM_HUDRoot") as inkCanvas;
  }

  // --------------------------------------------------------------------------
  // Position the HUD slot using normalized coordinates from the service
  // --------------------------------------------------------------------------
  private func ApplyHUDPosFromService() -> Void {
    let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
    if !IsDefined(inkSys) { return; }
    let hudLayer = inkSys.GetLayer(n"inkHUDLayer");
    if !IsDefined(hudLayer) { return; }
    let vwin: ref<inkCompoundWidget> = hudLayer.GetVirtualWindow();
    if !IsDefined(vwin) { return; }
    let slot: ref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/VM_FullScreenSlot/VM_WidgetSlot") as inkCanvas;
    if !IsDefined(slot) { return; }

    let svc = VMSettingsService.Svc();
    if !IsDefined(svc) { return; }

    let x: Float = svc.GetX();                // 0..1 left→right
    let y: Float = svc.GetY();                // 0..1 bottom→top
    let px: Float = x * 3840.0;
    let py: Float = 2160.0 - (y * 2160.0);    // convert to top-left space

    slot.SetTranslation(new Vector2(px, py));
  }

  // --------------------------------------------------------------------------
  // Show/hide gate: vm_hud_visible fact + modal depth (phone, etc.)
  // --------------------------------------------------------------------------
	private func ApplyVisibilityGate() -> Void {
		let root = this.FindRoot();
		if !IsDefined(root) { return; }

		let qs = GameInstance.GetQuestsSystem(GetGameInstance());
		let show: Bool = false;
		if IsDefined(qs) {
			let hudOn: Bool = qs.GetFact(n"vm_hud_visible") == 1;
			let fgOn:  Bool = qs.GetFact(n"vm_fg_enabled") == 1;
			// Only show legacy digits when selected (i.e. FuelGauge not selected)
			show = hudOn && !fgOn && (this.modalDepth == 0);
		}
		root.SetVisible(show);
	}


  // --------------------------------------------------------------------------
  // Refresh text contents + warning logic + price plate
  // --------------------------------------------------------------------------

	public func Refresh() -> Void {
		let root = this.FindRoot();
		if !IsDefined(root) { return; }

		this.UpdatePricePlate();
		this.__ApplyLBTheme(false);
		
		// Don't touch HUD while any modal/phone UI is up
		if this.modalDepth > 0 {
			return;
		}

		this.ApplyVisibilityGate();
		this.ApplyHUDPosFromService();

		let qs = GameInstance.GetQuestsSystem(GetGameInstance());
		if !IsDefined(qs) { return; }

		// ----- read facts -----
		let meters: Int32   = qs.GetFact(n"vm_hud_meters");
		let permille: Int32 = qs.GetFact(n"vm_hud_fuel_permille");

		// ----- update values only on change -----
		if meters != this.lastMeters || permille != this.lastPermille {
			this.lastMeters = meters;
			this.lastPermille = permille;

			let fv: ref<inkText> = root.GetWidgetByPathName(n"VM_FuelValue") as inkText;
			let mv: ref<inkText> = root.GetWidgetByPathName(n"VM_MileValue") as inkText;

			// Fuel % (permille / 10)
			if IsDefined(fv) {
				let pct: Int32 = permille / 10;
				let cp: Int32 = pct;
				if cp < 0 { cp = 0; }
				if cp > 100 { cp = 100; }
				fv.SetText(IntToString(cp) + "%");
			}

			// Odometer (km with 1 decimal): floor(meters/100) -> X.X km
			if IsDefined(mv) {
				let kmX10: Int32 = meters / 100;
				let km_int: Int32 = kmX10 / 10;
				let km_dec: Int32 = kmX10 - (km_int * 10);
				mv.SetText(IntToString(km_int) + "." + IntToString(km_dec));
			}
		}

		// ----- refuel mute flag -----
		let refueling: Bool = qs.GetFact(n"vm_hud_price_visible") == 1;

		// ----- warning handling (blink + color + 3x SOUND with refuel mute) -----
		let wn: ref<inkText> = root.GetWidgetByPathName(n"VM_WarnText") as inkText;
		if IsDefined(wn) {
			let amber: HDRColor; amber.Red = 1.0; amber.Green = 0.70; amber.Blue = 0.05; amber.Alpha = 1.0;
			let brightRed: HDRColor; brightRed.Red = 1.0; brightRed.Green = 0.15; brightRed.Blue = 0.15; brightRed.Alpha = 1.0;

			// Thresholds: EMPTY at 0%; SOON at/under 5% (50 permille), but not empty.
			let warnEmpty: Bool = permille <= 0;
			let warnSoon:  Bool = !warnEmpty && (permille <= 50);

			// No ternary in REDscript — compute manually
			let curState: Int32 = 0;
			if warnEmpty {
				curState = 2;
			} else if warnSoon {
				curState = 1;
			}

			// MUTE while refueling
			if refueling {
				curState = 0;
			}

			// Edge transitions (start/stop sounds & loop arming)
			if curState != this.lastWarnState {
				if curState == 2 {
					// EMPTY (SND_EMPTY currently n"")
					this.PlayEvent(this.SND_EMPTY);
					this.warnSoonLoopsLeft = 0;
					this.warnSoonTickWait = 0;
				} else if curState == 1 {
					// Entered SOON (≤5%) — immediate play + 2 more spaced by ~1s
					if !refueling {
						this.PlayEvent(this.SND_SOON);
						this.warnSoonLoopsLeft = 2;                        // remaining after immediate play
						this.warnSoonTickWait = this.warnSoonTickInterval; // 4 ticks × 0.25s = 1s
					} else {
						this.warnSoonLoopsLeft = 0;
						this.warnSoonTickWait = 0;
					}
				} else {
					// Back to normal
					this.warnSoonLoopsLeft = 0;
					this.warnSoonTickWait = 0;
				}
				this.lastWarnState = curState;
			}

			// While in SOON (and not refueling), space the remaining 2 plays at ~1s
			if curState == 1 {
				if refueling {
					this.warnSoonLoopsLeft = 0;
					this.warnSoonTickWait = 0;
				} else if this.warnSoonLoopsLeft > 0 {
					if this.warnSoonTickWait > 0 {
						this.warnSoonTickWait = this.warnSoonTickWait - 1;
					} else {
						this.PlayEvent(this.SND_SOON);
						this.warnSoonLoopsLeft = this.warnSoonLoopsLeft - 1;
						this.warnSoonTickWait = this.warnSoonTickInterval;
					}
				}
			}

			// Visuals (blink + color)
			if curState != 0 {
				this.blinkOn = !this.blinkOn;
				if curState == 2 {
					wn.SetText("-FUEL EMPTY-");
					wn.SetTintColor(brightRed);
					wn.SetOpacity(this.blinkOn ? 1.0 : 0.0);
				} else {
					wn.SetText("-FUEL SOON-");
					wn.SetTintColor(amber);
					wn.SetOpacity(this.blinkOn ? 1.0 : 0.0);
				}
			} else {
				this.blinkOn = false;
				wn.SetOpacity(0.0);
			}
		}
	}



  // ==========================================================================
  // Price plate internals
  // ==========================================================================
  private func EnsurePricePlate(fs: wref<inkCanvas>) -> Void {
    if !IsDefined(fs) { return; }

    let existing: wref<inkCanvas> = fs.GetWidgetByPathName(n"VM_PriceRoot") as inkCanvas;
    if IsDefined(existing) {
      this.priceRoot = existing;
      this.priceTitle = existing.GetWidgetByPathName(n"TextStack/Title") as inkText;
      this.priceValue = existing.GetWidgetByPathName(n"TextStack/Value") as inkText;
      this.priceBuilt = true;
      return;
    }

    let cont: ref<inkCanvas> = new inkCanvas();
    cont.SetName(n"VM_PriceRoot");
    cont.SetVisible(false);
    cont.SetInteractive(false);
    cont.SetFitToContent(true);
    cont.SetAnchor(inkEAnchor.Centered);
    cont.SetAnchorPoint(new Vector2(0.5, 0.5));
    cont.SetTranslation(new Vector2(0.0 - this.PRICE_OFFSET_X, 0.0 - this.PRICE_OFFSET_Y));
    cont.Reparent(fs);
    this.priceRoot = cont;
    this.ApplyPriceOffsetFromService();
		// Build the ODO TOP10 widget once and keep it hidden until asked
    this.EnsureLeaderboard(this.priceRoot);

    let black: HDRColor; black.Red = 0.0; black.Green = 0.0; black.Blue = 0.0; black.Alpha = 1.0;

    let bgF1: ref<inkRectangle> = new inkRectangle();
    bgF1.SetName(n"BG_F1");
    bgF1.SetTintColor(black);
    bgF1.SetOpacity(0.10);
    bgF1.SetSize(new Vector2(580.0, 180.0));
    bgF1.SetAnchor(inkEAnchor.Centered);
    bgF1.SetAnchorPoint(new Vector2(0.5, 0.5));
    bgF1.Reparent(cont);

    let bgF2: ref<inkRectangle> = new inkRectangle();
    bgF2.SetName(n"BG_F2");
    bgF2.SetTintColor(black);
    bgF2.SetOpacity(0.06);
    bgF2.SetSize(new Vector2(610.0, 210.0));
    bgF2.SetAnchor(inkEAnchor.Centered);
    bgF2.SetAnchorPoint(new Vector2(0.5, 0.5));
    bgF2.Reparent(cont);

    let bgF3: ref<inkRectangle> = new inkRectangle();
    bgF3.SetName(n"BG_F3");
    bgF3.SetTintColor(black);
    bgF3.SetOpacity(0.03);
    bgF3.SetSize(new Vector2(650.0, 250.0));
    bgF3.SetAnchor(inkEAnchor.Centered);
    bgF3.SetAnchorPoint(new Vector2(0.5, 0.5));
    bgF3.Reparent(cont);

    let bg: ref<inkRectangle> = new inkRectangle();
    bg.SetName(n"BG");
    bg.SetTintColor(black);
    bg.SetOpacity(0.20);
    bg.SetSize(new Vector2(560.0, 160.0));
    bg.SetAnchor(inkEAnchor.Centered);
    bg.SetAnchorPoint(new Vector2(0.5, 0.5));
    bg.Reparent(cont);

    let stack: ref<inkVerticalPanel> = new inkVerticalPanel();
    stack.SetName(n"TextStack");
    stack.SetAnchor(inkEAnchor.Centered);
    stack.SetAnchorPoint(new Vector2(0.5, 0.5));
    stack.SetMargin(new inkMargin(28.0, 20.0, 28.0, 20.0));
    stack.Reparent(cont);

    let amber2: HDRColor; amber2.Red = 1.0; amber2.Green = 0.75; amber2.Blue = 0.0; amber2.Alpha = 1.0;

    let t: ref<inkText> = new inkText();
    t.SetName(n"Title");
    t.SetText("Current gas price");
    t.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    t.SetFontSize(44);
    t.SetLetterCase(textLetterCase.OriginalCase);
    t.SetTintColor(amber2);
    t.Reparent(stack);
    this.priceTitle = t;

    let white2: HDRColor; white2.Red = 1.0; white2.Green = 1.0; white2.Blue = 1.0; white2.Alpha = 1.0;

    let v: ref<inkText> = new inkText();
    v.SetName(n"Value");
    v.SetText("0.00 €$/L");
    v.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    v.SetFontSize(64);
    v.SetLetterCase(textLetterCase.OriginalCase);
    v.SetTintColor(white2);
    v.SetMargin(new inkMargin(0.0, 6.0, 0.0, 0.0));
    v.Reparent(stack);
    this.priceValue = v;

    this.priceBuilt = true;
    this.lastPriceVisible = false;
    this.lastPriceCents = -1;
  }

  // ==========================================================================
  // ODO TOP10 — build the plate + rows (atlas-based)
  // ==========================================================================
  private func EnsureLeaderboard(parent: wref<inkCanvas>) -> Void {
    if this.lbBuilt && IsDefined(this.lbRoot) { return; }

    // ---- colors (same vibe as VMFuelGauge.reds) ----
    let cpCyan: HDRColor;     cpCyan.Red=0.35; cpCyan.Green=0.95; cpCyan.Blue=1.00; cpCyan.Alpha=1.0;
    let cpCyanSoft: HDRColor; cpCyanSoft.Red=0.70; cpCyanSoft.Green=0.92; cpCyanSoft.Blue=0.98; cpCyanSoft.Alpha=1.0;
    let cpWhite: HDRColor;    cpWhite.Red=0.92; cpWhite.Green=0.95; cpWhite.Blue=0.98; cpWhite.Alpha=1.0;
    let amber: HDRColor;      amber.Red=1.0; amber.Green=0.80; amber.Blue=0.10; amber.Alpha=1.0;
		let darkGrey: HDRColor; darkGrey.Red=0.18; darkGrey.Green=0.18; darkGrey.Blue=0.18; darkGrey.Alpha=1.0;

    // ---- root ----
    let root: ref<inkCanvas> = new inkCanvas();
    root.SetName(n"VM_LBRoot");
    root.SetVisible(false);
    root.SetInteractive(false);
    root.SetFitToContent(true);
    root.SetAnchor(inkEAnchor.Centered);
    root.SetAnchorPoint(new Vector2(0.5, 0.5));
    root.SetTranslation(new Vector2(-this.LB_OFFSET_X, this.LB_OFFSET_Y));
    root.SetScale(new Vector2(this.LB_SCALE, this.LB_SCALE));
    root.Reparent(parent);
    this.lbRoot = root;

    // ---- big frame (fill + stroke) ----
    let atlas: ResRef = r"ep1\\gameplay\\gui\\world\\computers\\computer_oa.inkatlas";

		let bg: ref<inkImage> = new inkImage();
		bg.SetName(n"LB_BgFill");
		bg.SetAtlasResource(atlas);
		bg.SetTexturePart(n"frame_big_bg");
		bg.SetAnchor(inkEAnchor.Centered);
		bg.SetAnchorPoint(new Vector2(0.5, 0.5));
		bg.SetTintColor(darkGrey);
		bg.SetOpacity(0.75);                             // NEW: 75% visible
		bg.SetSize(new Vector2(1256.0, 790.0));          // NEW: stretch X for longer names 1256.0, 790.
		bg.Reparent(root);

		let stroke: ref<inkImage> = new inkImage();
		stroke.SetName(n"LB_BgStroke");
		stroke.SetAtlasResource(atlas);
		stroke.SetTexturePart(n"frame_big");
		stroke.SetAnchor(inkEAnchor.Centered);
		stroke.SetAnchorPoint(new Vector2(0.5, 0.5));
		stroke.SetTintColor(cpCyan);
		stroke.SetOpacity(0.85);
		stroke.SetSize(new Vector2(1256.0, 790.0));      // NEW: match fill width/height
		stroke.Reparent(root);
		this.lbBgStrokeRef = stroke;

		// ---- title (absolute inside LB root) ----
		let title: ref<inkText> = new inkText();
		title.SetName(n"LB_Title");

		// Anchor/pivot = top-right of the plate (root is FitToContent to the plate)
		title.SetAnchor(inkEAnchor.TopRight);
		title.SetAnchorPoint(new Vector2(1.0, 0.0));

		// Visuals
		title.SetFontFamily("base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily");
		title.SetFontSize(46);
		title.SetTintColor(cpCyan);
		title.SetLetterCase(textLetterCase.OriginalCase);
		title.SetText("ODO TOP 10");

		// ABSOLUTE padding inside the plate’s top-right corner
		// (more negative X = closer to right border; smaller Y = closer to top)
		title.SetTranslation(new Vector2(444.0, -350.0));
		//	 title.SetTranslation(new Vector2(0.0, 0.0));
		title.Reparent(root);
		this.lbTitle = title;



    // ---- rows container ----
		let rows: ref<inkCanvas> = new inkCanvas();
		rows.SetName(n"LB_Rows");
		rows.SetInteractive(false);
		rows.SetFitToContent(true);
		// keep centered, but slide slightly left
		rows.SetAnchor(inkEAnchor.Centered);
		rows.SetAnchorPoint(new Vector2(0.5, 0.5));
		rows.SetTranslation(new Vector2(-20.0, 0.0));            // NEW: a little left
		rows.Reparent(root);
		this.lbRowsRoot = rows;



		// ---- build 10 rows (each a nameplate) ----
		ArrayClear(this.lbRowText);
		ArrayClear(this.lbRowStrokeRefs);
		let i: Int32 = 0;
    while i < 10 {
      let row: ref<inkCanvas> = new inkCanvas();
      let rowDynName: CName = StringToName("LB_Row_" + IntToString(i + 1));
			row.SetName(rowDynName);
      row.SetInteractive(false);
      row.SetFitToContent(true);
      row.SetAnchor(inkEAnchor.TopCenter);
      row.SetAnchorPoint(new Vector2(0.5, 0.0));
      // NEW: distribute rows around the center (10 rows × 62px spacing)
      row.SetTranslation(new Vector2(0.0, -279.0 + Cast<Float>(i) * 62.0));
      // (-279 = -(9 * 62) / 2 → visually centers the block of rows)
      row.Reparent(rows);

      // row nameplate (fill under + stroke above), rotated 180°
      let rFill: ref<inkImage> = new inkImage();
      rFill.SetName(n"RowFill");
      rFill.SetAtlasResource(atlas);
      rFill.SetTexturePart(n"button2_frame");
      rFill.SetAnchor(inkEAnchor.TopCenter);
      rFill.SetAnchorPoint(new Vector2(0.5, 0.0));
      rFill.SetRotation(180.0);
      rFill.SetTintColor(darkGrey);
			rFill.SetOpacity(0.75);                        // NEW: 75% visible
			rFill.SetSize(new Vector2(1120.0, 56.0));      // NEW: stretch X
      rFill.Reparent(row);


      let rStroke: ref<inkImage> = new inkImage();
      rStroke.SetName(n"RowStroke");
      rStroke.SetAtlasResource(atlas);
      rStroke.SetTexturePart(n"button2_bg");
      rStroke.SetAnchor(inkEAnchor.TopCenter);
      rStroke.SetAnchorPoint(new Vector2(0.5, 0.0));
      rStroke.SetRotation(180.0);
      rStroke.SetTintColor(cpCyan);
      rStroke.SetOpacity(0.70);
      rStroke.SetSize(new Vector2(1120.0, 56.0));    // NEW: match width
      rStroke.Reparent(row);
			ArrayPush(this.lbRowStrokeRefs, rStroke);

      // text: "1. Vehiclename - 00000 km"
      let t: ref<inkText> = new inkText();
      t.SetName(n"RowText");
      t.SetAnchor(inkEAnchor.TopLeft);
      t.SetFontFamily("base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily");
      t.SetFontSize(34);
      t.SetLetterCase(textLetterCase.OriginalCase);
      t.SetTintColor(cpWhite);
      t.SetOpacity(0.0);
      t.SetTranslation(new Vector2(-520.0, 13.0)); // NEW: keep a nice left margin on wider plate
      t.SetText("");
      t.Reparent(row);

      ArrayPush(this.lbRowText, t);
      i += 1;
    }

		  // ── CORP LOGO: bottom-left, in front of all layers ────────────────────────
			let logo: ref<inkImage> = new inkImage();
			logo.SetName(n"LB_Logo");
			logo.SetAtlasResource(r"ep1\\gameplay\\gui\\quests\\q303\\q303_savehouse.inkatlas");
			logo.SetTexturePart(n"03D_Zeta");
			logo.SetAnchor(inkEAnchor.BottomLeft);                 // plate’s bottom-left corner
			logo.SetAnchorPoint(new Vector2(0.0, 1.0));            // pivot = bottom-left
			logo.SetInteractive(false);
			logo.SetTintColor(amber);
			logo.SetSize(new Vector2(262.8, 62.4));
			// (with BottomLeft anchor, UP is negative Y)
			logo.SetTranslation(new Vector2(-685.0, 390.0));
			logo.Reparent(root);

			// ensure it’s drawn on top of previous children
			let cc: Int32 = root.GetNumChildren();
			root.ReorderChild(logo, cc - 1);
			
			// Remember base and ref
			this.lbLogo = logo;
			
			// Use the actual base logo position so the overlay sits on top of it
			let _basePos: Vector2 = logo.GetTranslation();
			this.lbLogoDX = _basePos.X;
			this.lbLogoDY = _basePos.Y;
						
			// ── overlay that we animate (same atlas/part) ───────────────────────────────
			let logoFX: ref<inkImage> = new inkImage();
			logoFX.SetName(n"LB_LogoFX");
			logoFX.SetAtlasResource(r"ep1\\gameplay\\gui\\quests\\q303\\q303_savehouse.inkatlas");
			logoFX.SetTexturePart(n"03D_Zeta");
			logoFX.SetAnchor(inkEAnchor.BottomLeft);
			logoFX.SetAnchorPoint(new Vector2(0.0, 1.0));
			logoFX.SetInteractive(false);
			logoFX.SetSize(logo.GetSize());                           // match size
			logoFX.SetTranslation(_basePos);                          // << align with base logo
			logoFX.SetOpacity(0.0);                                   // start invisible
			logoFX.Reparent(root);

			// keep overlay on top
			cc = root.GetNumChildren();
			root.ReorderChild(logoFX, cc - 1);

			this.lbLogoFX = logoFX;

			this.lbEnabled = true;       // default ON (still gated by price plate)
			this.lbBuilt = true;
			this.lbLastVisible = false;

			this.__ApplyLBTheme(true);
  }
	
// ==========================================================================
// Leaderboard theme helpers
// Uses the same CET fact as VMFuelGauge.reds:
// vm_fg_theme
// ==========================================================================

private func __LBThemeMainColor(theme: Int32) -> HDRColor {
  let c: HDRColor;

  if theme == 1 { // Cyberpunk Yellow
    c.Red = 1.00; c.Green = 0.78; c.Blue = 0.00;
  } else if theme == 2 { // E3 / Project E3 HUD blue-green
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

private func __ApplyLBTheme(force: Bool) -> Void {
  if !IsDefined(this.lbRoot) {
    return;
  }

  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  let themeRaw: Int32 = IsDefined(qs) ? qs.GetFact(n"vm_fg_theme") : 0;

  let theme: Int32 = themeRaw;
  if theme < 0 || theme > 9 {
    theme = 0;
  }

  if !force && theme == this.lbThemeLast {
    return;
  }

  this.lbThemeLast = theme;

	let main: HDRColor = this.__LBThemeMainColor(theme);

	// Big leaderboard frame
	// Rebind every time so live CET theme changes also affect the frame stroke.
	this.lbBgStrokeRef = this.lbRoot.GetWidgetByPathName(n"LB_BgStroke") as inkImage;

	if IsDefined(this.lbBgStrokeRef) {
		this.lbBgStrokeRef.SetTintColor(main);
		this.lbBgStrokeRef.SetOpacity(0.85);
	}
  // Title
  if IsDefined(this.lbTitle) {
    this.lbTitle.SetTintColor(main);
  }

	// Row strokes
	// Rebind every time so live CET theme changes also affect all row frames.
	ArrayClear(this.lbRowStrokeRefs);

	if IsDefined(this.lbRowsRoot) {
		let i: Int32 = 0;

		while i < 10 {
			let rowName: CName = StringToName("LB_Row_" + IntToString(i + 1));
			let row: ref<inkCanvas> = this.lbRowsRoot.GetWidgetByPathName(rowName) as inkCanvas;

			if IsDefined(row) {
				let rowStroke: ref<inkImage> = row.GetWidgetByPathName(n"RowStroke") as inkImage;

				if IsDefined(rowStroke) {
					rowStroke.SetTintColor(main);
					rowStroke.SetOpacity(0.70);
					ArrayPush(this.lbRowStrokeRefs, rowStroke);
				}
			}

			i += 1;
		}
	}

  // Corp logo + scanline overlay
  //if IsDefined(this.lbLogo) {
    // this.lbLogo.SetTintColor(main);
  //}

  // if IsDefined(this.lbLogoFX) {
    // this.lbLogoFX.SetTintColor(main);
 //}
}
	
  // keep visibility in sync with the Price Plate
  private func SyncLeaderboardVisibility(wantPriceVisible: Bool) -> Void {
    if !IsDefined(this.lbRoot) { return; }
		let want: Bool = wantPriceVisible && this.lbEnabled && (this.modalDepth == 0);

		// Rising edge → play boot-up animation
		if want && !this.lbLastVisible {
			this.StartLBAppear();
			return;
		}

		// Falling edge → play power-down animation
		if !want && this.lbLastVisible {
			this.StartLBDisappear();
			return;
		}

  }

  private func ApplyLBOffsetScale(dx: Float, dy: Float, sc: Float) -> Void {
    if !IsDefined(this.lbRoot) { return; }
    this.lbRoot.SetTranslation(new Vector2(dx, dy));
    let s: Float = (sc <= 0.0) ? 1.0 : (sc / 600.0); // match Lua “600” baseline like FG
    this.lbRoot.SetScale(new Vector2(s, s));
  }


  private func UpdatePricePlate() -> Void {
    if !IsDefined(this.priceRoot) {
      let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
      if !IsDefined(inkSys) { return; }
      let hudLayer = inkSys.GetLayer(n"inkHUDLayer");
      if !IsDefined(hudLayer) { return; }
      let vwin: ref<inkCompoundWidget> = hudLayer.GetVirtualWindow();
      if !IsDefined(vwin) { return; }
      let fs: wref<inkCanvas> = vwin.GetWidgetByPathName(n"Root/VM_FullScreenSlot") as inkCanvas;
      if IsDefined(fs) { this.EnsurePricePlate(fs); }
      if !IsDefined(this.priceRoot) { return; }
    }

    this.ApplyPriceOffsetFromService();

    let qs = GameInstance.GetQuestsSystem(GetGameInstance());
    if !IsDefined(qs) { return; }

		let wantVis: Bool = (qs.GetFact(n"vm_hud_price_visible") == 1) && (this.modalDepth == 0);

		// Rising edge → show container now and animate LB in
		if wantVis && !this.lastPriceVisible {
			this.lastPriceVisible = true;                  // mark edge handled
			this.priceHoldVisibleDuringLB = false;         // no deferral needed

			// Prep LB first (zero rows, opacity 0, scale start) so no “snapshot” can show
			this.SyncLeaderboardVisibility(true);          // triggers StartLBAppear()

			// Only then reveal the container
			this.priceRoot.SetVisible(true);               // container visible immediately
			this.StartLogoLoop();
		}

		// Falling edge → keep container visible, animate LB out, hide container after
			else if !wantVis && this.lastPriceVisible {
			this.lastPriceVisible = false;

			// No fade-out needed → instantly zero the LB so no snapshot can persist
			this.lbRoot.SetOpacity(0.0);
			this.LB_HardHide();

			// If you previously used this to defer container hide, disable the hold:
			this.priceHoldVisibleDuringLB = false;
		}


		// NEW: robust sync in case LB state ever drifts from the price-plate gate
		this.SyncLeaderboardVisibility(wantVis);

		if !wantVis { return; }                          // skip price value update when hidden



    let centsRaw: Int32 = qs.GetFact(n"vm_hud_price_cents");
    if centsRaw != this.lastPriceCents {
      this.lastPriceCents = centsRaw;
      let cents: Int32 = (centsRaw < 0) ? -centsRaw : centsRaw;
      let whole: Int32 = cents / 100;
      let frac: Int32 = cents % 100;
      let fracStr: String = (frac < 10) ? ("0" + IntToString(frac)) : IntToString(frac);
      if IsDefined(this.priceValue) {
        this.priceValue.SetText(IntToString(whole) + "." + fracStr + " €$/L");
      }
    }
  }
}

// ============================================================================
// Lifecycle hooks + modal hide
// ============================================================================
@addField(UISystem)
public let vmHUD: ref<VM_HUD>;

@wrapMethod(UISystem)
public final func PushGameContext(context: UIGameContext) -> Void {
  wrappedMethod(context);
  let _svcTouch = VMSettingsService.Svc();
  if !IsDefined(this.vmHUD) { this.vmHUD = new VM_HUD(); }
  this.vmHUD.OnContextPushed();
	this.vmHUD.Ensure();
  this.vmHUD.__GT_AvoidWindow();
  this.vmHUD.__FixGT_PhoneMiddleIndex();
}

@wrapMethod(UISystem)
public final func PopGameContext(context: UIGameContext, opt invalidate: Bool) -> Void {
  wrappedMethod(context, invalidate);
  let _svcTouch = VMSettingsService.Svc();
  if IsDefined(this.vmHUD) {
    this.vmHUD.OnContextPopped();
  }
  if !IsDefined(this.vmHUD) { this.vmHUD = new VM_HUD(); }
  this.vmHUD.Ensure();
  this.vmHUD.__GT_AvoidWindow();
  this.vmHUD.__FixGT_PhoneMiddleIndex();
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(resolver: EntityResolveComponentsInterface) -> Bool {
  let r = wrappedMethod(resolver);
  let _svcTouch = VMSettingsService.Svc();
  let uiSys: ref<UISystem> = GameInstance.GetUISystem(GetGameInstance());
  if IsDefined(uiSys) {
    if !IsDefined(uiSys.vmHUD) { uiSys.vmHUD = new VM_HUD(); }
    uiSys.vmHUD.OnNewWorld();
    uiSys.vmHUD.Ensure();
  }
  return r;
}

// ============================================================================
// UI bridge methods for Lua (widget mode + FuelGauge stubs)
// - Safe to call even if a FuelGauge UI does not exist yet.
// - Legacy VMHUD is toggled by showing/hiding VM_WidgetSlot.
// - FuelGauge assumes a root canvas at: Root/VM_FullScreenSlot/FG_RootSlot
//   If it doesn't exist, FG_* calls are harmless no-ops.
// ============================================================================
@addMethod(UISystem)
public func VM__GetVWin() -> ref<inkCompoundWidget> {
  let inkSys: ref<inkSystem> = GameInstance.GetInkSystem();
  if !IsDefined(inkSys) { return null; }
  let layer = inkSys.GetLayer(n"inkHUDLayer");
  if !IsDefined(layer) { return null; }
  return layer.GetVirtualWindow();
}

// Legacy HUD slot stays the same
@addMethod(UISystem)
public func VM__LegacySlotPath() -> CName {
  return n"Root/VM_FullScreenSlot/VM_WidgetSlot";
}

// FuelGauge paths ***matching VMFuelGauge.reds***
@addMethod(UISystem)
public func VM__FGPlacePath() -> CName {
  // wrapper we translate/scale
  return n"Root/VM_FuelGaugeSlot/VM_FuelPlace";
}

@addMethod(UISystem)
public func VM__FGRootPath() -> CName {
  // the actual gauge root we show/hide
  return n"Root/VM_FuelGaugeSlot/GaugeRoot";
}



// --------------------------------------------------------------------------
// Preferred single-call API used by Lua
// --------------------------------------------------------------------------
@addMethod(UISystem)
public func VM_SetWidgetMode(mode: String) -> Void {
  let useFG: Bool = Equals(mode, "fuelgauge");
  this.FG_EnableFuelGauge(useFG);
  this.VM_EnableLegacyHUD(!useFG);
}



// --------------------------------------------------------------------------
// Fallback pair (Lua will use these if VM_SetWidgetMode doesn't exist)
// --------------------------------------------------------------------------
@addMethod(UISystem)
public func VM_EnableLegacyHUD(enabled: Bool) -> Void {
  let vwin = this.VM__GetVWin();
  if !IsDefined(vwin) { return; }
  let slot: ref<inkCanvas> = vwin.GetWidgetByPathName(this.VM__LegacySlotPath()) as inkCanvas;
  if IsDefined(slot) {
    slot.SetVisible(enabled);
  }
  // Ensure legacy HUD exists so the slot path is present on first toggle
  if IsDefined(this.vmHUD) {
    this.vmHUD.Ensure();
  }
}

@addMethod(UISystem)
public func FG_EnableFuelGauge(enabled: Bool) -> Void {
  let vwin = this.VM__GetVWin();
  if !IsDefined(vwin) { return; }

  // tell the gauge which widget is selected
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  if IsDefined(qs) {
    qs.SetFact(n"vm_fg_enabled", enabled ? 1 : 0);
  }

  // also directly toggle the root if it already exists
  let fgRoot: ref<inkCanvas> = vwin.GetWidgetByPathName(this.VM__FGRootPath()) as inkCanvas;
  if IsDefined(fgRoot) {
    fgRoot.SetVisible(enabled);
  }
}


// --------------------------------------------------------------------------
// FuelGauge transforms (safe stubs)
// - dx,dy are pixels relative to screen center; positive => LEFT/UP
// - scale uses 600 as "1.0x" baseline (matches Lua defaults)
// --------------------------------------------------------------------------
@addMethod(UISystem)
public func FG_SetOffset(dx: Float, dy: Float) -> Void {
  let vwin = this.VM__GetVWin();
  if !IsDefined(vwin) { return; }
  let place: ref<inkCanvas> = vwin.GetWidgetByPathName(this.VM__FGPlacePath()) as inkCanvas;
  if IsDefined(place) {
    place.SetTranslation(new Vector2(dx, dy));
  }
}

@addMethod(UISystem)
public func FG_SetScale(scale: Float) -> Void {
  let vwin = this.VM__GetVWin();
  if !IsDefined(vwin) { return; }
  let place: ref<inkCanvas> = vwin.GetWidgetByPathName(this.VM__FGPlacePath()) as inkCanvas;
  if IsDefined(place) {
    let s: Float = (scale <= 0.0) ? 1.0 : (scale / 600.0); // 600 = your Lua baseline
    place.SetScale(new Vector2(s, s));
  }
}

@addMethod(UISystem)
public func VM_HaveLegacySlot() -> Bool {
  let v = this.VM__GetVWin(); if !IsDefined(v) { return false; }
  return IsDefined(v.GetWidgetByPathName(this.VM__LegacySlotPath()) as inkCanvas);
}

@addMethod(UISystem)
public func FG_HavePlace() -> Bool {
  let v = this.VM__GetVWin(); if !IsDefined(v) { return false; }
  return IsDefined(v.GetWidgetByPathName(this.VM__FGPlacePath()) as inkCanvas);
}

// ==========================================================================
// ODO TOP10 — UISystem helpers for CET (Lua)
// ==========================================================================
@addMethod(UISystem)
public func VM__LBRootPath() -> CName {
  // where the leaderboard root lives (inside the Price Plate)
  return n"Root/VM_FullScreenSlot/VM_PriceRoot/VM_LBRoot";
}

@addMethod(UISystem)
public func VM_LB_SetEnabled(enabled: Bool) -> Void {
  if !IsDefined(this.vmHUD) { return; }
  this.vmHUD.lbEnabled = enabled;

  // Recompute the gate strictly from the quest fact (source of truth),
  // and also respect modal depth (phone, etc.).
  let qs = GameInstance.GetQuestsSystem(GetGameInstance());
  let gate: Bool = false;
  if IsDefined(qs) {
    gate = qs.GetFact(n"vm_hud_price_visible") == 1;
  }
  gate = gate && (this.vmHUD.modalDepth == 0);

  // Drive leaderboard visibility only from the fact-based gate.
  this.vmHUD.SyncLeaderboardVisibility(gate);

  // Failsafe: if disabled, force-hide now and reset state
  if !enabled && IsDefined(this.vmHUD.lbRoot) {
    this.vmHUD.lbRoot.SetVisible(false);
    this.vmHUD.lbLastVisible = false;
  }
}


@addMethod(UISystem)
public func VM_LB_SetOffset(dx: Float, dy: Float) -> Void {
  if !IsDefined(this.vmHUD) { return; }
  this.vmHUD.LB_OFFSET_X = dx;
  this.vmHUD.LB_OFFSET_Y = dy;
  this.vmHUD.ApplyLBOffsetScale(dx, dy, 600.0 * this.vmHUD.LB_SCALE);
}

@addMethod(UISystem)
public func VM_LB_SetScale(scale: Float) -> Void {
  if !IsDefined(this.vmHUD) { return; }
  // scale follows FuelGauge convention: 600 = 1.0x
  let sc: Float = (scale <= 0.0) ? 600.0 : scale;
  this.vmHUD.LB_SCALE = sc / 600.0;
  this.vmHUD.ApplyLBOffsetScale(this.vmHUD.LB_OFFSET_X, this.vmHUD.LB_OFFSET_Y, sc);
}

@addMethod(UISystem)
public func VM_LB_Clear() -> Void {
  if !IsDefined(this.vmHUD) || !IsDefined(this.vmHUD.lbRowsRoot) { return; }
  let i: Int32 = 0;
  while i < ArraySize(this.vmHUD.lbRowText) {
    if IsDefined(this.vmHUD.lbRowText[i]) {
      this.vmHUD.lbRowText[i].SetText("");
    }
    i += 1;
  }
}

@addMethod(UISystem)
public func VM_LB_SetRow(index1: Int32, name: String, km: String) -> Void {
  if !IsDefined(this.vmHUD) || !IsDefined(this.vmHUD.lbRowsRoot) { return; }
  let idx: Int32 = index1 - 1;            // 1→0
  if idx < 0 || idx >= ArraySize(this.vmHUD.lbRowText) { return; }

  let prefix: String = IntToString(index1) + ". ";
  let sep: String = " - ";
  let line: String = prefix + name + sep + km;

  let t: wref<inkText> = this.vmHUD.lbRowText[idx];
  if IsDefined(t) {
    t.SetText(line);
  }
}

@addMethod(UISystem)
public func VM_LB_HavePlace() -> Bool {
  let v = this.VM__GetVWin(); if !IsDefined(v) { return false; }
  return IsDefined(v.GetWidgetByPathName(this.VM__LBRootPath()) as inkCanvas);
}

@addMethod(UISystem)
public func VM_LB_GetEnabled() -> Bool {
  if !IsDefined(this.vmHUD) { return false; }
  return this.vmHUD.lbEnabled;
}

@addMethod(UISystem)
public func VM_LB_GetLastVisible() -> Bool {
  if !IsDefined(this.vmHUD) { return false; }
  return this.vmHUD.lbLastVisible;
}

@addMethod(UISystem)
public func VM_ForceHidePricePlate() -> Void {
  if !IsDefined(this.vmHUD) { return; }
  // Update cached flag (if you track it)
  this.vmHUD.lastPriceVisible = false;
  // Hard-hide root immediately (no fade needed)
  if IsDefined(this.vmHUD.priceRoot) {
    this.vmHUD.priceRoot.SetVisible(false);
  }
}

@addMethod(UISystem)
public func VM_LB_ForceHide() -> Void {
  if !IsDefined(this.vmHUD) { return; }
  // Instant, no animation: hide root, zero rows, reset flag
  this.vmHUD.lbLastVisible = false;
  if IsDefined(this.vmHUD.lbRoot) {
    this.vmHUD.lbRoot.SetVisible(false);
    this.vmHUD.lbRoot.SetOpacity(0.0);
  }
  this.vmHUD.LB_ZeroRows();
}
