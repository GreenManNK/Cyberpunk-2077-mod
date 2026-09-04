// VMPriceSign.reds
// Standalone world ink widget for the current VehicleMileage fuel price.
// Built to use the same service pattern as VMWorldLeaderboard.reds.
//
// Required WolvenKit setup:
// - worlduiWidgetComponent name: vm_price_sign
// - widgetResource: OdoHUD\hud\pricesign.inkwidget
// - DynamicWidgetController on pricesign.inkwidget: OdoHUD.inkpricesign
// - meshTargetBinding.bindName must point to your mesh component name, for example: pricesign_mesh
// - That mesh component should use: OdoHUD\hud\pricesign.mesh

module OdoHUD

// ============================================================================
// Price sign widget controller
// Reads the runtime quest fact:
//   vm_hud_price_cents = current fuel price * 100
// Example: 5000 = 50.00
// ============================================================================

public class inkpricesign extends inkGameController {
  private let root: wref<inkCompoundWidget>;
  private let signRoot: wref<inkCanvas>;
  private let priceText: wref<inkText>;
  private let lastPriceCents: Int32;

  protected cb func OnInitialize() -> Void {
    let rootWidget: ref<inkCompoundWidget> = this.GetRootCompoundWidget();

    if !IsDefined(rootWidget) {
      return;
    };

    this.root = rootWidget;
    this.root.SetVisible(true);
    this.root.SetOpacity(1.0);

    this.lastPriceCents = -1;

    this.HideTemplateChildren();
    this.EnsurePriceSign();
    this.RefreshFromFacts();
  }

  private func HideTemplateChildren() -> Void {
    if !IsDefined(this.root) {
      return;
    };

    let count: Int32 = this.root.GetNumChildren();
    let i: Int32 = 0;

    while i < count {
      let child: wref<inkWidget> = this.root.GetWidget(i);

      if IsDefined(child) && !Equals(child.GetName(), n"VM_PriceSignRoot") {
        child.SetVisible(false);
        child.SetOpacity(0.0);
      };

      i += 1;
    };
  }

  private func HideWidget(widget: wref<inkWidget>) -> Void {
    if IsDefined(widget) {
      widget.SetVisible(false);
      widget.SetOpacity(0.0);
    };
  }

  // Same idea as VM_WorldLB_SetVisible in VMWorldLeaderboard.reds:
  // keep the global world canvas root alive.
  public func VM_PriceSign_SetVisible(show: Bool) -> Void {
    if IsDefined(this.root) {
      this.root.SetVisible(true);
      this.root.SetOpacity(1.0);
    };
  }

  private func EnsurePriceSign() -> Void {
    if !IsDefined(this.root) {
      return;
    };

    let existing: ref<inkCanvas> = this.root.GetWidgetByPathName(n"VM_PriceSignRoot") as inkCanvas;

    if IsDefined(existing) {
      this.signRoot = existing;

      // Keep old/template elements hidden if they exist in the ink file.
      this.HideWidget(existing.GetWidgetByPathName(n"Title"));
      this.HideWidget(existing.GetWidgetByPathName(n"BorderTop"));
      this.HideWidget(existing.GetWidgetByPathName(n"BorderBottom"));

      this.signRoot.SetVisible(true);
      this.signRoot.SetOpacity(1.0);

      this.priceText = existing.GetWidgetByPathName(n"Price") as inkText;

      if IsDefined(this.priceText) {
        this.priceText.SetVisible(true);
        this.priceText.SetOpacity(1.0);
        this.priceText.SetTranslation(new Vector2(0.0, 0.0));
      };

      return;
    };

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

    let sign: ref<inkCanvas> = new inkCanvas();
    sign.SetName(n"VM_PriceSignRoot");
    sign.SetInteractive(false);
    sign.SetFitToContent(false);
    sign.SetSize(new Vector2(720.0, 280.0));
    sign.SetAnchor(inkEAnchor.Centered);
    sign.SetAnchorPoint(new Vector2(0.5, 0.5));
    sign.SetRenderTransformPivot(new Vector2(0.5, 0.5));
    sign.SetVisible(true);
    sign.SetOpacity(1.0);
    sign.Reparent(this.root);
    this.signRoot = sign;

    let bg: ref<inkRectangle> = new inkRectangle();
    bg.SetName(n"BG");
    bg.SetSize(new Vector2(720.0, 280.0));
    bg.SetAnchor(inkEAnchor.Centered);
    bg.SetAnchorPoint(new Vector2(0.5, 0.5));
    bg.SetTintColor(dark);
    bg.SetOpacity(0.60);
    bg.Reparent(sign);

    let price: ref<inkText> = new inkText();
    price.SetName(n"Price");
    price.SetText("--.--");
    price.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
    price.SetFontSize(86);
    price.SetTintColor(white);
    price.SetLetterCase(textLetterCase.OriginalCase);
    price.SetAnchor(inkEAnchor.Centered);
    price.SetAnchorPoint(new Vector2(0.5, 0.5));
    price.SetTranslation(new Vector2(0.0, 0.0));
    price.SetVisible(true);
    price.SetOpacity(1.0);
    price.Reparent(sign);
    this.priceText = price;
  }

  private func FormatPrice(centsRaw: Int32) -> String {
    let cents: Int32 = centsRaw;

    if cents < 0 {
      cents = 0;
    };

    let whole: Int32 = cents / 100;
    let frac: Int32 = cents % 100;
    let fracStr: String = frac < 10 ? "0" + IntToString(frac) : IntToString(frac);

    // No unit suffix. Example: 50.00
    return IntToString(whole) + "." + fracStr;
  }

  public func RefreshFromFacts() -> Void {
    this.EnsurePriceSign();

    if !IsDefined(this.priceText) {
      return;
    };

    let qs = GameInstance.GetQuestsSystem(GetGameInstance());

    if !IsDefined(qs) {
      return;
    };

    let centsRaw: Int32 = qs.GetFact(n"vm_hud_price_cents");

    if centsRaw == this.lastPriceCents {
      return;
    };

    this.lastPriceCents = centsRaw;
    this.priceText.SetText(this.FormatPrice(centsRaw));
  }
}

// ============================================================================
// Tick callback
// ============================================================================

private class VMPriceSignTick extends DelayCallback {
  private let svc: wref<VMPriceSignService>;
  private let token: Int32;

  public static func Create(svc: ref<VMPriceSignService>, token: Int32) -> ref<VMPriceSignTick> {
    let self = new VMPriceSignTick();
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
// Same structure as VMWorldLeaderboardService, only target component name differs.
// ============================================================================

@addField(UISystem)
public let vmPriceSignSvc: wref<IScriptable>;

public class VMPriceSignService extends IScriptable {
  public let tickArmed: Bool;
  public let tickToken: Int32;

  private let tick: ref<VMPriceSignTick>;

  // Fast shortly after startup / entity assemble.
  private let tickPeriodFast: Float = 0.25;

  // Same normal idle refresh as the leaderboard.
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
        // LogChannel(n"DEBUG", "[VMPriceSign] Entity/Assemble callback registered.");
      };
    };

    let ui = GameInstance.GetUISystem(GetGameInstance());

    if IsDefined(ui) {
      ui.vmPriceSignSvc = this;
    };

    // Fast refresh shortly after startup / loading.
    this.RequestFastTicks(12);
  }

  private func EnsureWorldWidgetComponent(widget: wref<worlduiWidgetComponent>) -> Void {
    if !IsDefined(widget) {
      return;
    };

    // Same important part as VMWorldLeaderboard.reds:
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

    let widget = ent.FindComponentByName(n"vm_price_sign") as worlduiWidgetComponent;

    if !IsDefined(widget) {
      return;
    };

    this.EnsureWorldWidgetComponent(widget);

    if !this.HasTargetWidget(widget) {
      ArrayPush(this.targetWidgets, widget);

      // LogChannel(
      //   n"DEBUG",
      //   "[VMPriceSign] Found world widget: vm_price_sign | total="
      //   + IntToString(ArraySize(this.targetWidgets))
      // );
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

        let sign = widget.GetGameController() as inkpricesign;

        if IsDefined(sign) {
          if !this.loggedReady {
            // LogChannel(n"DEBUG", "[VMPriceSign] Controller ready. Drawing fuel price sign.");
            this.loggedReady = true;
          };

          sign.VM_PriceSign_SetVisible(true);
          sign.RefreshFromFacts();
        } else {
          if !this.loggedControllerMissing {
            // LogChannel(n"DEBUG", "[VMPriceSign] Controller is NULL on at least one sign.");
            // LogChannel(n"DEBUG", "[VMPriceSign] Check DynamicWidgetController: OdoHUD.inkpricesign");
            // LogChannel(n"DEBUG", "[VMPriceSign] Check widgetResource: OdoHUD\\hud\\pricesign.inkwidget");
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
    this.tick = VMPriceSignTick.Create(this, this.tickToken);
    this.tickArmed = true;

    ds.DelayCallback(this.tick, period, false);
  }
}

@addMethod(UISystem)
public func VM_PriceSign_RequestFastTicks(ticks: Int32) -> Void {
  let svc = this.vmPriceSignSvc as VMPriceSignService;

  if IsDefined(svc) {
    svc.RequestFastTicks(ticks);
  };
}

// ============================================================================
// Start service after player control
// ============================================================================

@addField(PlayerPuppet)
private let vmPriceSignSvc: ref<VMPriceSignService>;

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(resolver: EntityResolveComponentsInterface) -> Bool {
  let r = wrappedMethod(resolver);

  if !IsDefined(this.vmPriceSignSvc) {
    this.vmPriceSignSvc = new VMPriceSignService();
  };

  this.vmPriceSignSvc.Start();

  return r;
}
