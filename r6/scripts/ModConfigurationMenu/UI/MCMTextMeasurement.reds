module ModConfigurationMenu.UI

public class MCMTextMeasurement extends IScriptable {
  public let kind: Int32;
  public let value: String;
  public let constraint: Float;
  public let fontSize: Int32;
  public let result: Vector2;
  public let fallback: Vector2;
  public let widget: wref<inkWidget>;
}

@addField(SettingsMainGameController)
private let m_mcmUiTextMeasurementCache: array<ref<MCMTextMeasurement>>;

@addField(SettingsMainGameController)
private let m_mcmUiPendingTextMeasurements: array<ref<MCMTextMeasurement>>;

@addField(SettingsMainGameController)
private let m_mcmUiTextMeasurementTick: ref<inkAnimProxy>;

@addField(SettingsMainGameController)
private let m_mcmUiTextMeasurementPasses: Int32;

@addField(SettingsMainGameController)
private let m_mcmUiTextMeasurementSettlePasses: Int32;

@addField(SettingsMainGameController)
private let m_mcmUiTextMeasurementRebuildRequested: Bool;

@addField(SettingsMainGameController)
private let m_mcmUiTextMeasurementDisabled: Bool;

@addField(SettingsMainGameController)
private let m_mcmUiFirstPaintComplete: Bool;

@addField(SettingsMainGameController)
private let m_mcmUiFirstPaintStaged: Bool;

@addField(SettingsMainGameController)
private let m_mcmUiFirstPaintTranslation: Vector2;

@addMethod(SettingsMainGameController)
public func McmUiEmitTextMeasurementsReady() -> Void {}

@addMethod(SettingsMainGameController)
private final func McmUiSetFirstPaintVisible(visible: Bool) -> Void {
  if IsDefined(this.m_mcmUiRoot) {
    this.m_mcmUiRoot.SetOpacity(1.0);
    if visible {
      if this.m_mcmUiFirstPaintStaged {
        this.m_mcmUiRoot.SetTranslation(this.m_mcmUiFirstPaintTranslation);
        this.m_mcmUiFirstPaintStaged = false;
      };
    } else {
      if !this.m_mcmUiFirstPaintStaged {
        this.m_mcmUiFirstPaintTranslation = this.m_mcmUiRoot.GetTranslation();
        this.m_mcmUiFirstPaintStaged = true;
      };
      this.m_mcmUiRoot.SetTranslation(new Vector2(-16384.0, -16384.0));
    };
    this.m_mcmUiRoot.SetInteractive(visible);
  };
  if IsDefined(this.m_mcmUiContainerRoot) {
    this.m_mcmUiContainerRoot.SetInteractive(visible);
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiDiscardFirstPaintStage() -> Void {
  this.m_mcmUiFirstPaintStaged = false;
}

@addMethod(SettingsMainGameController)
private final func McmUiFindTextMeasurement(
  entries: array<ref<MCMTextMeasurement>>,
  kind: Int32,
  value: String,
  constraint: Float,
  fontSize: Int32
) -> Int32 {
  let index: Int32 = 0;
  while index < ArraySize(entries) {
    let entry: ref<MCMTextMeasurement> = entries[index];
    if IsDefined(entry)
      && entry.kind == kind
      && Equals(entry.value, value)
      && AbsF(entry.constraint - constraint) <= 0.25
      && entry.fontSize == fontSize {
      return index;
    };
    index += 1;
  };
  return -1;
}

@addMethod(SettingsMainGameController)
private final func McmUiCacheTextMeasurement(
  measurement: ref<MCMTextMeasurement>,
  result: Vector2
) -> Void {
  if !IsDefined(measurement) {
    return;
  };
  measurement.result = result;
  measurement.widget = null;
  while ArraySize(this.m_mcmUiTextMeasurementCache) >= MCMLayout.TextMeasurementCacheLimit() {
    ArrayErase(this.m_mcmUiTextMeasurementCache, 0);
  };
  ArrayPush(this.m_mcmUiTextMeasurementCache, measurement);
}

@addMethod(SettingsMainGameController)
private final func McmUiQueueActionTextMeasurement(value: String) -> Void {
  if this.m_mcmUiTextMeasurementDisabled || !IsDefined(this.m_mcmUiRoot) {
    return;
  };

  let label: ref<inkText> = new inkText();
  label.SetName(n"mcm_action_text_measurement");
  label.SetText(value);
  label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  label.SetFontStyle(n"Medium");
  label.SetFontSize(MCMLayout.ActionTextNativeFontSize());
  label.SetHorizontalAlignment(textHorizontalAlignment.Left);
  label.SetVerticalAlignment(textVerticalAlignment.Center);
  label.SetOverflowPolicy(textOverflowPolicy.None);
  label.SetFitToContent(true);
  label.SetWrapping(false);
  label.SetInteractive(false);
  label.SetAffectsLayoutWhenHidden(true);
  label.SetStyle(r"base\\gameplay\\gui\\fullscreen\\settings\\settings.inkstyle");
  label.BindProperty(n"fontStyle", n"MainColors.BodyFontWeight");
  label.BindProperty(n"fontSize", n"MainColors.ReadableFontSize");
  label.SetHeight(MCMLayout.ModalActionHeight() / MCMLayout.ActionTextNativeScale());
  label.SetTranslation(
    this.m_mcmUiFirstPaintComplete
      ? new Vector2(-8192.0, -8192.0)
      : new Vector2(0.0, 0.0)
  );
  // The cold first-paint tree is staged offscreen as a whole, so its probes
  // can participate in normal layout without becoming visible.
  label.SetOpacity(1.0);
  label.Reparent(this.m_mcmUiRoot);

  let measurement: ref<MCMTextMeasurement> = new MCMTextMeasurement();
  measurement.kind = 1;
  measurement.value = value;
  measurement.constraint = 0.0;
  measurement.fontSize = MCMLayout.ActionTextNativeFontSize();
  measurement.fallback = new Vector2(MCMLayout.ActionFallbackWidth(), 0.0);
  measurement.widget = label;
  ArrayPush(this.m_mcmUiPendingTextMeasurements, measurement);
  this.m_mcmUiRoot.FlagForVisualInvalidation();
}

@addMethod(SettingsMainGameController)
private final func McmUiQueueWrappedTextMeasurement(
  value: String,
  width: Float,
  fontSize: Int32
) -> Void {
  if this.m_mcmUiTextMeasurementDisabled
    || !IsDefined(this.m_mcmUiRoot) || width <= 0.0 || fontSize <= 0 {
    return;
  };

  let richText: ref<inkRichTextBox> = new inkRichTextBox();
  richText.SetName(n"mcm_wrapped_text_measurement");
  richText.SetText(value);
  richText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  richText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  richText.SetFontStyle(n"Regular");
  richText.SetFontSize(fontSize);
  richText.SetHorizontalAlignment(textHorizontalAlignment.Left);
  richText.SetVerticalAlignment(textVerticalAlignment.Top);
  richText.SetFitToContent(true);
  richText.SetWrappingAtPosition(width);
  richText.SetInteractive(false);
  richText.SetAffectsLayoutWhenHidden(true);
  if this.m_mcmUiFirstPaintComplete {
    this.McmUiSetRect(richText, -8192.0, -8192.0, width, 1.0);
  } else {
    this.McmUiSetRect(richText, 0.0, 0.0, width, 1.0);
  };
  richText.SetOpacity(1.0);
  richText.Reparent(this.m_mcmUiRoot);

  let measurement: ref<MCMTextMeasurement> = new MCMTextMeasurement();
  measurement.kind = 2;
  measurement.value = value;
  measurement.constraint = width;
  measurement.fontSize = fontSize;
  measurement.fallback = new Vector2(width, Cast<Float>(fontSize) + 10.0);
  measurement.widget = richText;
  ArrayPush(this.m_mcmUiPendingTextMeasurements, measurement);
  this.m_mcmUiRoot.FlagForVisualInvalidation();
}

@addMethod(SettingsMainGameController)
public final func McmUiResolveActionWidth(value: String) -> Float {
  let cachedIndex: Int32 = this.McmUiFindTextMeasurement(
    this.m_mcmUiTextMeasurementCache,
    1,
    value,
    0.0,
    MCMLayout.ActionTextNativeFontSize()
  );
  if cachedIndex >= 0 {
    return this.m_mcmUiTextMeasurementCache[cachedIndex].result.X;
  };
  if this.McmUiFindTextMeasurement(
      this.m_mcmUiPendingTextMeasurements,
      1,
      value,
      0.0,
      MCMLayout.ActionTextNativeFontSize()
    ) < 0 {
    this.McmUiQueueActionTextMeasurement(value);
  };
  return MCMLayout.ActionFallbackWidth();
}

@addMethod(SettingsMainGameController)
public final func McmUiResolveWrappedTextHeight(
  value: String,
  width: Float,
  fontSize: Int32
) -> Float {
  let cachedIndex: Int32 = this.McmUiFindTextMeasurement(
    this.m_mcmUiTextMeasurementCache,
    2,
    value,
    width,
    fontSize
  );
  if cachedIndex >= 0 {
    return this.m_mcmUiTextMeasurementCache[cachedIndex].result.Y;
  };
  if this.McmUiFindTextMeasurement(
      this.m_mcmUiPendingTextMeasurements,
      2,
      value,
      width,
      fontSize
    ) < 0 {
    this.McmUiQueueWrappedTextMeasurement(value, width, fontSize);
  };
  return 0.0;
}

@addMethod(SettingsMainGameController)
public final func McmUiHasPendingTextMeasurements() -> Bool {
  return ArraySize(this.m_mcmUiPendingTextMeasurements) > 0
    || this.m_mcmUiTextMeasurementRebuildRequested;
}

@addMethod(SettingsMainGameController)
private final func McmUiStopTextMeasurementTick() -> Void {
  if IsDefined(this.m_mcmUiTextMeasurementTick) {
    this.m_mcmUiTextMeasurementTick.Stop(true);
    this.m_mcmUiTextMeasurementTick = null;
  };
  this.m_mcmUiTextMeasurementPasses = 0;
  this.m_mcmUiTextMeasurementSettlePasses = 0;
}

@addMethod(SettingsMainGameController)
private final func McmUiEnsureTextMeasurementTick() -> Void {
  if this.m_mcmUiTextMeasurementDisabled
    || IsDefined(this.m_mcmUiTextMeasurementTick)
    || !IsDefined(this.m_mcmUiRoot) {
    return;
  };
  let translation: ref<inkAnimTranslation> = new inkAnimTranslation();
  let position: Vector2 = this.m_mcmUiRoot.GetTranslation();
  translation.SetStartTranslation(position);
  translation.SetEndTranslation(position);
  translation.SetDuration(1.0 / 60.0);
  let definition: ref<inkAnimDef> = new inkAnimDef();
  definition.AddInterpolator(translation);
  let options: inkAnimOptions;
  options.loopInfinite = true;
  options.loopType = inkanimLoopType.Cycle;
  this.m_mcmUiTextMeasurementTick = this.m_mcmUiRoot.PlayAnimationWithOptions(
    definition,
    options
  );
  if !IsDefined(this.m_mcmUiTextMeasurementTick) {
    this.m_mcmUiTextMeasurementDisabled = true;
    return;
  };
  this.m_mcmUiTextMeasurementTick.RegisterToCallback(
    inkanimEventType.OnEndLoop,
    this,
    n"McmUiOnTextMeasurementTick"
  );
}

@addMethod(SettingsMainGameController)
public final func McmUiFinalizeTextMeasurements() -> Void {
  if !IsDefined(this.m_mcmUiRoot) {
    return;
  };
  if ArraySize(this.m_mcmUiPendingTextMeasurements) == 0 {
    this.McmUiSetFirstPaintVisible(true);
    this.m_mcmUiFirstPaintComplete = true;
    return;
  };

  // Keep only the cold first paint transactional. Later uncached strings may
  // refine in place without blanking an already visible MCM screen.
  if !this.m_mcmUiFirstPaintComplete {
    this.McmUiSetFirstPaintVisible(false);
  } else {
    this.McmUiSetFirstPaintVisible(true);
  };
  this.m_mcmUiRoot.FlagForVisualInvalidation();
  this.McmUiEnsureTextMeasurementTick();
  if !IsDefined(this.m_mcmUiTextMeasurementTick) {
    this.McmUiResetTextMeasurementPass();
    this.McmUiSetFirstPaintVisible(true);
    this.m_mcmUiFirstPaintComplete = true;
  };
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnTextMeasurementTick(proxy: ref<inkAnimProxy>) -> Bool {
  if this.m_mcmUiTextMeasurementRebuildRequested {
    this.m_mcmUiTextMeasurementSettlePasses += 1;
    if this.m_mcmUiTextMeasurementSettlePasses
      >= MCMLayout.TextMeasurementSettlePassLimit() {
      // Fail open if CET never consumes the measurement-ready callback. The
      // fallback tree is preferable to a permanently blank Settings screen.
      if !this.m_mcmUiFirstPaintComplete {
        this.McmUiSetFirstPaintVisible(true);
        this.m_mcmUiFirstPaintComplete = true;
      };
      this.m_mcmUiTextMeasurementRebuildRequested = false;
      this.McmUiStopTextMeasurementTick();
    };
    return true;
  };

  this.m_mcmUiTextMeasurementPasses += 1;
  let index: Int32 = ArraySize(this.m_mcmUiPendingTextMeasurements) - 1;
  while index >= 0 {
    let measurement: ref<MCMTextMeasurement> = this.m_mcmUiPendingTextMeasurements[index];
    if !IsDefined(measurement) {
      ArrayErase(this.m_mcmUiPendingTextMeasurements, index);
    } else {
      let size: Vector2 = IsDefined(measurement.widget)
        ? measurement.widget.GetDesiredSize()
        : new Vector2(0.0, 0.0);
      let ready: Bool = measurement.kind == 1 ? size.X > 0.01 : size.Y > 0.01;
      if ready || this.m_mcmUiTextMeasurementPasses
        >= MCMLayout.TextMeasurementPassLimit() {
        let result: Vector2 = ready ? size : measurement.fallback;
        if measurement.kind == 1 && ready {
          result.X = ClampF(
            result.X * MCMLayout.ActionTextNativeScale()
              + (MCMLayout.ActionPaddingX() * 2.0),
            MCMLayout.ActionMinWidth(),
            MCMLayout.ActionMaxWidth()
          );
        };
        if IsDefined(measurement.widget) {
          let parent: wref<inkCompoundWidget> = measurement.widget.GetParentWidget()
            as inkCompoundWidget;
          if IsDefined(parent) {
            parent.RemoveChild(measurement.widget);
          };
        };
        this.McmUiCacheTextMeasurement(measurement, result);
        ArrayErase(this.m_mcmUiPendingTextMeasurements, index);
      };
    };
    index -= 1;
  };

  if ArraySize(this.m_mcmUiPendingTextMeasurements) == 0 {
    this.m_mcmUiTextMeasurementRebuildRequested = true;
    this.m_mcmUiTextMeasurementSettlePasses = 0;
    this.McmUiEmitTextMeasurementsReady();
  };
  return true;
}

@addMethod(SettingsMainGameController)
private final func McmUiDiscardPendingTextMeasurements() -> Void {
  let index: Int32 = ArraySize(this.m_mcmUiPendingTextMeasurements) - 1;
  while index >= 0 {
    let measurement: ref<MCMTextMeasurement> = this.m_mcmUiPendingTextMeasurements[index];
    if IsDefined(measurement) && IsDefined(measurement.widget) {
      let parent: wref<inkCompoundWidget> = measurement.widget.GetParentWidget()
        as inkCompoundWidget;
      if IsDefined(parent) {
        parent.RemoveChild(measurement.widget);
      };
    };
    index -= 1;
  };
  ArrayClear(this.m_mcmUiPendingTextMeasurements);
}

@addMethod(SettingsMainGameController)
private final func McmUiResetTextMeasurementPass() -> Void {
  this.McmUiStopTextMeasurementTick();
  this.McmUiDiscardPendingTextMeasurements();
  this.m_mcmUiTextMeasurementRebuildRequested = false;
}

@addMethod(SettingsMainGameController)
public final func McmUiClearTextMeasurementCache() -> Void {
  this.McmUiResetTextMeasurementPass();
  if IsDefined(this.m_mcmUiRoot) {
    this.McmUiSetFirstPaintVisible(true);
    this.m_mcmUiFirstPaintComplete = true;
  };
  ArrayClear(this.m_mcmUiTextMeasurementCache);
}

@addMethod(SettingsMainGameController)
public final func McmUiResetFirstPaintState() -> Void {
  this.m_mcmUiFirstPaintComplete = false;
}
