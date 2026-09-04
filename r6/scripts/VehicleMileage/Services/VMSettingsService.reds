module VehicleMileage.Services

// ============================================================================
// VMSettingsService
// ----------------------------------------------------------------------------
// Lightweight global settings store for the VehicleMileage HUD.
// Lives on UISystem (as vmSettings) so the runtime and UI controllers share it.
//
// Stores:
//   - HUD position (normalized 0..1): X (left→right), Y (bottom→top)
//   - Price plate offsets (pixels): Dx (+=LEFT), Dy (+=UP)
//   - A simple monotonic version counter (ver) to detect changes
//
// Access patterns:
//   - From REDscript: VMSettingsService.Svc() -> Get*/Set*()
//   - Through UISystem: VM_* helpers (see bottom of file)
// ============================================================================
public class VMSettingsService extends IScriptable {

  // --- backing fields ---
  private let initDone: Bool;
  private let hudX: Float;        // 0..1 (left → right)
  private let hudY: Float;        // 0..1 (bottom → top)
  private let priceDxPx: Float;   // px; + pushes LEFT
  private let priceDyPx: Float;   // px; + pushes UP
  private let ver: Uint32;        // change counter


  // --------------------------------------------------------------------------
  // Instance API
  // --------------------------------------------------------------------------

  // Clamp helper for normalized values
  private func Clamp01(x: Float) -> Float {
    if x < 0.0 { return 0.0; }
    if x > 1.0 { return 1.0; }
    return x;
  }

  // --- HUD (normalized) ---
  public func GetX() -> Float = this.Clamp01(this.hudX);
  public func GetY() -> Float = this.Clamp01(this.hudY);

  public func SetX(x: Float) -> Void {
    this.hudX = this.Clamp01(x);
    this.ver += 1u;
  }

  public func SetY(y: Float) -> Void {
    this.hudY = this.Clamp01(y);
    this.ver += 1u;
  }

  public func Set(x: Float, y: Float) -> Void {
    this.hudX = this.Clamp01(x);
    this.hudY = this.Clamp01(y);
    this.ver += 1u;
  }

  // --- Price plate (pixels) ---
  public func GetPriceDx() -> Float = this.priceDxPx;
  public func GetPriceDy() -> Float = this.priceDyPx;

  public func SetPriceDx(v: Float) -> Void {
    this.priceDxPx = v;
    this.ver += 1u;
  }

  public func SetPriceDy(v: Float) -> Void {
    this.priceDyPx = v;
    this.ver += 1u;
  }

  // --- Defaults (match VMSettings defaults) ---
  public func Reset() -> Void {
    // HUD defaults = your margins on 3840x2160
    this.hudX = 280.0 / 3840.0;
    this.hudY = 443.0 / 2160.0;

    // Price plate defaults (match your existing behavior)
    this.priceDxPx = 0.0;    // pushes LEFT by 0
    this.priceDyPx = 350.0;  // pushes UP   by 350




    this.ver += 1u;
  }

  public func InitDefaults() -> Void {
    if this.initDone { return; }
    this.Reset();
    this.initDone = true;
  }
	
	
  public func GetVersion() -> Uint32 = this.ver;
	

  // --------------------------------------------------------------------------
  // Static accessor (singleton on UISystem)
  // --------------------------------------------------------------------------
  public static func Svc() -> ref<VMSettingsService> {
    let ui: ref<UISystem> = GameInstance.GetUISystem(GetGameInstance());
    if !IsDefined(ui) { return null; }
    if !IsDefined(ui.vmSettings) {
      ui.vmSettings = new VMSettingsService();
      ui.vmSettings.InitDefaults();
    }
    return ui.vmSettings;
  }
}


// ============================================================================
// UISystem storage & runtime bridge
// ----------------------------------------------------------------------------
// Expose one shared instance on UISystem and provide VM_* helpers used by the
// REDscript runtime and HUD controllers.
// ============================================================================

// Store a single instance on UISystem so the runtime and HUD can reach it.
@addField(UISystem)
public let vmSettings: ref<VMSettingsService>;


// --- Runtime bridge on UISystem ---

@addMethod(UISystem)
public final func VM_GetHUDPosX() -> Float {
  let svc = VMSettingsService.Svc();
  if IsDefined(svc) { return svc.GetX(); }
  return 280.0 / 3840.0;
}

@addMethod(UISystem)
public final func VM_GetHUDPosY() -> Float {
  let svc = VMSettingsService.Svc();
  if IsDefined(svc) { return svc.GetY(); }
  return 443.0 / 2160.0;
}

@addMethod(UISystem)
public final func VM_SetHUDPosX(x: Float) -> Void {
  let svc = VMSettingsService.Svc();
  if IsDefined(svc) { svc.SetX(x); }
}

@addMethod(UISystem)
public final func VM_SetHUDPosY(y: Float) -> Void {
  let svc = VMSettingsService.Svc();
  if IsDefined(svc) { svc.SetY(y); }
}

@addMethod(UISystem)
public final func VM_ResetHUDPos() -> Void {
  let svc = VMSettingsService.Svc();
  if IsDefined(svc) { svc.Reset(); }
}

@addMethod(UISystem)
public final func VM_GetPriceDx() -> Float {
  let s = VMSettingsService.Svc();
  return IsDefined(s) ? s.GetPriceDx() : 0.0;
}

@addMethod(UISystem)
public final func VM_GetPriceDy() -> Float {
  let s = VMSettingsService.Svc();
  return IsDefined(s) ? s.GetPriceDy() : 350.0;
}

@addMethod(UISystem)
public final func VM_SetPriceDx(v: Float) -> Void {
  let s = VMSettingsService.Svc();
  if IsDefined(s) { s.SetPriceDx(v); }
}

@addMethod(UISystem)
public final func VM_SetPriceDy(v: Float) -> Void {
  let s = VMSettingsService.Svc();
  if IsDefined(s) { s.SetPriceDy(v); }
}
