module ModConfigurationMenu.UI

@addField(SettingsSelectorController)
protected let m_mcmManaged: Bool;

@addField(SettingsSelectorController)
protected let m_mcmHost: wref<SettingsMainGameController>;

@addField(SettingsSelectorController)
protected let m_mcmId: String;

@addField(SettingsSelectorController)
protected let m_mcmDescription: String;

@addField(SettingsSelectorController)
protected let m_mcmLabel: String;

@addField(SettingsSelectorController)
protected let m_mcmModified: Bool;

@addMethod(SettingsSelectorController)
public final func McmUiIsManaged() -> Bool {
  return this.m_mcmManaged;
}

@addMethod(SettingsSelectorController)
public final func McmUiConfigureBase(
  host: ref<SettingsMainGameController>,
  id: String,
  label: String,
  description: String,
  modified: Bool
) -> Void {
  this.m_mcmManaged = true;
  this.m_mcmHost = host;
  this.m_mcmId = id;
  this.m_mcmDescription = description;
  this.m_mcmLabel = label;
  this.m_mcmModified = modified;
  inkTextRef.SetText(this.m_LabelText, label);
  this.McmUiRefreshBase(false);
  this.GetRootWidget().SetInteractive(true);
}

@addMethod(SettingsSelectorController)
protected final func McmUiRefreshBase(hovered: Bool) -> Void {
  inkWidgetRef.SetVisible(this.m_LabelText, false);
  if IsDefined(this.m_mcmHost) {
    this.m_mcmHost.McmUiSetManagedLabelState(this.m_mcmId, hovered, this.m_mcmModified);
  };
  inkWidgetRef.SetVisible(this.m_ModifiedFlag, false);
  inkWidgetRef.SetVisible(this.m_optionSwitchHint, hovered);
  inkWidgetRef.SetVisible(this.m_hoverGeneralHighlight, hovered);
}

@addMethod(SettingsSelectorController)
protected final func McmUiEmitStep(forward: Bool) -> Void {
  if IsDefined(this.m_mcmHost) {
    this.m_mcmHost.McmUiEmitStep(this.m_mcmId, forward);
  };
}

@wrapMethod(SettingsSelectorController)
public func Refresh() -> Void {
  if this.McmUiIsManaged() {
    this.McmUiRefreshBase(false);
    return;
  };
  wrappedMethod();
}

@wrapMethod(SettingsSelectorController)
protected cb func OnHoverOver(event: ref<inkPointerEvent>) -> Bool {
  if this.McmUiIsManaged() {
    if IsDefined(this.m_mcmHost) && this.m_mcmHost.McmUiHasFrameworkPreviewContext() {
      wrappedMethod(event);
    };
    this.McmUiRefreshBase(true);
    if IsDefined(this.m_mcmHost) {
      this.m_mcmHost.McmUiEmitHover(this.m_mcmId, this.m_mcmDescription, true);
      this.m_mcmHost.McmUiBeginFrameworkPreviewHover();
    };
    return true;
  };
  return wrappedMethod(event);
}

@wrapMethod(SettingsSelectorController)
protected cb func OnHoverOut(event: ref<inkPointerEvent>) -> Bool {
  if this.McmUiIsManaged() {
    if IsDefined(this.m_mcmHost) {
      this.m_mcmHost.McmUiEndFrameworkPreviewHover();
    };
    if IsDefined(this.m_mcmHost) && this.m_mcmHost.McmUiHasFrameworkPreviewContext() {
      wrappedMethod(event);
    };
    this.McmUiRefreshBase(false);
    if IsDefined(this.m_mcmHost) {
      this.m_mcmHost.McmUiEmitHover(this.m_mcmId, this.m_mcmDescription, false);
    };
    return true;
  };
  return wrappedMethod(event);
}

@wrapMethod(SettingsSelectorController)
protected cb func OnLeft(event: ref<inkPointerEvent>) -> Bool {
  if this.McmUiIsManaged() {
    if event.IsAction(n"click") {
      this.McmUiEmitStep(false);
      this.PlaySound(n"ButtonValueDown", n"OnPress");
    };
    return true;
  };
  return wrappedMethod(event);
}

@wrapMethod(SettingsSelectorController)
protected cb func OnRight(event: ref<inkPointerEvent>) -> Bool {
  if this.McmUiIsManaged() {
    if event.IsAction(n"click") {
      this.McmUiEmitStep(true);
      this.PlaySound(n"ButtonValueUp", n"OnPress");
    };
    return true;
  };
  return wrappedMethod(event);
}

@wrapMethod(SettingsSelectorController)
protected cb func OnShortcutPress(event: ref<inkPointerEvent>) -> Bool {
  if this.McmUiIsManaged() {
    if !event.IsHandled()
      && (event.IsAction(n"restore_default_settings") || event.IsAction(n"unequip_item")) {
      if IsDefined(this.m_mcmHost) {
        this.m_mcmHost.McmUiEmitReset(this.m_mcmId);
      };
      event.Handle();
    } else {
      if !event.IsHandled() && event.IsAction(n"option_switch_prev_settings") {
        this.McmUiEmitStep(false);
        this.PlaySound(n"ButtonValueDown", n"OnPress");
        event.Handle();
      } else {
        if !event.IsHandled() && event.IsAction(n"option_switch_next_settings") {
          this.McmUiEmitStep(true);
          this.PlaySound(n"ButtonValueUp", n"OnPress");
          event.Handle();
        };
      };
    };
    return true;
  };
  return wrappedMethod(event);
}

@wrapMethod(SettingsSelectorController)
protected cb func OnShortcutRepeat(event: ref<inkPointerEvent>) -> Bool {
  if this.McmUiIsManaged() {
    if !event.IsHandled() && event.IsAction(n"option_switch_prev_settings") {
      this.McmUiEmitStep(false);
      event.Handle();
    } else {
      if !event.IsHandled() && event.IsAction(n"option_switch_next_settings") {
        this.McmUiEmitStep(true);
        event.Handle();
      };
    };
    return true;
  };
  return wrappedMethod(event);
}

@addMethod(SettingsSelectorControllerBool)
public final func McmUiConfigureBool(
  host: ref<SettingsMainGameController>,
  id: String,
  label: String,
  description: String,
  value: Bool,
  modified: Bool
) -> Void {
  this.McmUiConfigureBase(host, id, label, description, modified);
  inkWidgetRef.SetVisible(this.m_onState, value);
  inkWidgetRef.SetVisible(this.m_offState, !value);
  this.SetInteractive(true);
}

@wrapMethod(SettingsSelectorControllerBool)
private func AcceptValue(forward: Bool) -> Void {
  if this.McmUiIsManaged() {
    this.McmUiEmitStep(true);
    return;
  };
  wrappedMethod(forward);
}

@addField(SettingsSelectorControllerListString)
private let m_mcmOptions: array<String>;

@addField(SettingsSelectorControllerListString)
private let m_mcmIndex: Int32;

@addMethod(SettingsSelectorControllerListString)
private final func McmUiRenderSelectProgress(count: Int32, index: Int32) -> Void {
  inkCompoundRef.RemoveAllChildren(this.m_dotsContainer);
  if count <= 1 {
    return;
  };

  let parent: wref<inkCompoundWidget> = inkWidgetRef.Get(this.m_dotsContainer) as inkCompoundWidget;
  if !IsDefined(parent) {
    return;
  };

  let normalSlotWidth: Float = 48.0;
  let normalMarkerWidth: Float = 40.0;
  let maximumTrackWidth: Float = 600.0;
  let trackWidth: Float = MinF(Cast<Float>(count) * normalSlotWidth, maximumTrackWidth);
  let slotWidth: Float = trackWidth / Cast<Float>(count);
  let markerWidth: Float = MinF(normalMarkerWidth, slotWidth);
  let markerX: Float = Cast<Float>(Clamp(index, 0, count - 1)) * slotWidth
    + ((slotWidth - markerWidth) / 2.0);

  let surface: ref<inkCanvas> = new inkCanvas();
  surface.SetName(n"mcm_select_progress");
  surface.SetSize(trackWidth, 4.0);
  surface.SetHAlign(inkEHorizontalAlign.Center);
  surface.SetInteractive(false);
  surface.Reparent(parent);

  let track: ref<inkRectangle> = new inkRectangle();
  track.SetName(n"track");
  track.SetAnchor(inkEAnchor.TopLeft);
  track.SetSize(trackWidth, 4.0);
  track.SetInteractive(false);
  track.Reparent(surface);

  let marker: ref<inkRectangle> = new inkRectangle();
  marker.SetName(n"marker");
  marker.SetAnchor(inkEAnchor.TopLeft);
  marker.SetSize(markerWidth, 4.0);
  marker.SetMargin(new inkMargin(markerX, 0.0, 0.0, 0.0));
  marker.SetInteractive(false);
  marker.Reparent(surface);

  if IsDefined(this.m_mcmHost) {
    this.m_mcmHost.McmUiStyleSelectProgress(track, marker);
  };
}

@addMethod(SettingsSelectorControllerListString)
public final func McmUiBeginSelect(
  host: ref<SettingsMainGameController>,
  id: String,
  label: String,
  description: String,
  index: Int32,
  modified: Bool
) -> Void {
  ArrayClear(this.m_mcmOptions);
  this.m_mcmIndex = index;
  this.McmUiConfigureBase(host, id, label, description, modified);
}

@addMethod(SettingsSelectorControllerListString)
public final func McmUiAddSelectOption(value: String) -> Void {
  ArrayPush(this.m_mcmOptions, value);
}

@addMethod(SettingsSelectorControllerListString)
public final func McmUiFinishSelect() -> Void {
  let count: Int32 = ArraySize(this.m_mcmOptions);
  if count <= 0 {
    inkCompoundRef.RemoveAllChildren(this.m_dotsContainer);
    inkTextRef.SetText(this.m_ValueText, "");
    return;
  };
  this.m_mcmIndex = Clamp(this.m_mcmIndex, 0, count - 1);
  this.McmUiRenderSelectProgress(count, this.m_mcmIndex);
  inkTextRef.SetText(this.m_ValueText, this.m_mcmOptions[this.m_mcmIndex]);
}

@wrapMethod(SettingsSelectorControllerListString)
private func ChangeValue(forward: Bool) -> Void {
  if this.McmUiIsManaged() {
    this.McmUiEmitStep(forward);
    return;
  };
  wrappedMethod(forward);
}

@wrapMethod(SettingsSelectorControllerListString)
public func Refresh() -> Void {
  if this.McmUiIsManaged() {
    this.McmUiRefreshBase(false);
    this.McmUiFinishSelect();
    return;
  };
  wrappedMethod();
}

@addMethod(SettingsSelectorControllerInt)
public final func McmUiConfigureInt(
  host: ref<SettingsMainGameController>,
  id: String,
  label: String,
  description: String,
  value: Int32,
  minimum: Int32,
  maximum: Int32,
  step: Int32,
  modified: Bool
) -> Void {
  this.McmUiConfigureBase(host, id, label, description, modified);
  this.m_newValue = value;
  this.m_sliderController = inkWidgetRef.GetControllerByType(this.m_sliderWidget, n"inkSliderController") as inkSliderController;
  if IsDefined(this.m_sliderController) {
    this.m_sliderController.Setup(Cast<Float>(minimum), Cast<Float>(maximum), Cast<Float>(value), Cast<Float>(step));
    this.m_sliderController.RegisterToCallback(n"OnSliderValueChanged", this, n"OnSliderValueChanged");
    this.m_sliderController.RegisterToCallback(n"OnSliderHandleReleased", this, n"OnHandleReleased");
  };
  inkTextRef.SetText(this.m_ValueText, IntToString(value));
}

@wrapMethod(SettingsSelectorControllerInt)
private func ChangeValue(forward: Bool) -> Void {
  if this.McmUiIsManaged() {
    this.McmUiEmitStep(forward);
    return;
  };
  wrappedMethod(forward);
}

@wrapMethod(SettingsSelectorControllerInt)
private func AcceptValue(forward: Bool) -> Void {
  if this.McmUiIsManaged() {
    this.McmUiEmitStep(forward);
    return;
  };
  wrappedMethod(forward);
}

@wrapMethod(SettingsSelectorControllerInt)
protected cb func OnSliderValueChanged(
  sliderController: wref<inkSliderController>,
  progress: Float,
  value: Float
) -> Bool {
  if this.McmUiIsManaged() {
    this.m_newValue = Cast<Int32>(value);
    inkTextRef.SetText(this.m_ValueText, IntToString(this.m_newValue));
    return true;
  };
  return wrappedMethod(sliderController, progress, value);
}

@wrapMethod(SettingsSelectorControllerInt)
protected cb func OnHandleReleased() -> Bool {
  if this.McmUiIsManaged() {
    if IsDefined(this.m_mcmHost) {
      this.m_mcmHost.McmUiEmitNumber(this.m_mcmId, Cast<Float>(this.m_newValue));
    };
    return true;
  };
  return wrappedMethod();
}

@wrapMethod(SettingsSelectorControllerInt)
public func Refresh() -> Void {
  if this.McmUiIsManaged() {
    this.McmUiRefreshBase(false);
    inkTextRef.SetText(this.m_ValueText, IntToString(this.m_newValue));
    if IsDefined(this.m_sliderController) {
      this.m_sliderController.ChangeValue(Cast<Float>(this.m_newValue));
    };
    return;
  };
  wrappedMethod();
}

@addField(SettingsSelectorControllerFloat)
private let m_mcmPrecision: Int32;

@addMethod(SettingsSelectorControllerFloat)
public final func McmUiConfigureFloat(
  host: ref<SettingsMainGameController>,
  id: String,
  label: String,
  description: String,
  value: Float,
  minimum: Float,
  maximum: Float,
  step: Float,
  precision: Int32,
  modified: Bool
) -> Void {
  this.McmUiConfigureBase(host, id, label, description, modified);
  this.m_mcmPrecision = Clamp(precision, 0, 8);
  this.m_newValue = value;
  this.m_sliderController = inkWidgetRef.GetControllerByType(this.m_sliderWidget, n"inkSliderController") as inkSliderController;
  if IsDefined(this.m_sliderController) {
    this.m_sliderController.Setup(minimum, maximum, value, step);
    this.m_sliderController.RegisterToCallback(n"OnSliderValueChanged", this, n"OnSliderValueChanged");
    this.m_sliderController.RegisterToCallback(n"OnSliderHandleReleased", this, n"OnHandleReleased");
  };
  inkTextRef.SetText(this.m_ValueText, FloatToStringPrec(value, this.m_mcmPrecision));
}

@wrapMethod(SettingsSelectorControllerFloat)
private func ChangeValue(forward: Bool) -> Void {
  if this.McmUiIsManaged() {
    this.McmUiEmitStep(forward);
    return;
  };
  wrappedMethod(forward);
}

@wrapMethod(SettingsSelectorControllerFloat)
private func AcceptValue(forward: Bool) -> Void {
  if this.McmUiIsManaged() {
    this.McmUiEmitStep(forward);
    return;
  };
  wrappedMethod(forward);
}

@wrapMethod(SettingsSelectorControllerFloat)
protected cb func OnSliderValueChanged(
  sliderController: wref<inkSliderController>,
  progress: Float,
  value: Float
) -> Bool {
  if this.McmUiIsManaged() {
    this.m_newValue = value;
    inkTextRef.SetText(this.m_ValueText, FloatToStringPrec(value, this.m_mcmPrecision));
    return true;
  };
  return wrappedMethod(sliderController, progress, value);
}

@wrapMethod(SettingsSelectorControllerFloat)
protected cb func OnHandleReleased() -> Bool {
  if this.McmUiIsManaged() {
    if IsDefined(this.m_mcmHost) {
      this.m_mcmHost.McmUiEmitNumber(this.m_mcmId, this.m_newValue);
    };
    return true;
  };
  return wrappedMethod();
}

@wrapMethod(SettingsSelectorControllerFloat)
public func Refresh() -> Void {
  if this.McmUiIsManaged() {
    this.McmUiRefreshBase(false);
    inkTextRef.SetText(this.m_ValueText, FloatToStringPrec(this.m_newValue, this.m_mcmPrecision));
    if IsDefined(this.m_sliderController) {
      this.m_sliderController.ChangeValue(this.m_newValue);
    };
    return;
  };
  wrappedMethod();
}

@addField(SettingsSelectorControllerKeyBinding)
private let m_mcmKeyDisplay: String;

@addMethod(SettingsSelectorControllerKeyBinding)
public final func McmUiConfigureKey(
  host: ref<SettingsMainGameController>,
  id: String,
  label: String,
  description: String,
  displayValue: String,
  modified: Bool
) -> Void {
  this.McmUiConfigureBase(host, id, label, description, modified);
  this.m_mcmKeyDisplay = displayValue;
  inkTextRef.SetText(this.m_text, displayValue);
}

@wrapMethod(SettingsSelectorControllerKeyBinding)
protected cb func OnKeyBindingEvent(event: ref<KeyBindingEvent>) -> Bool {
  if this.McmUiIsManaged() && this.IsListeningForInput() {
    if NotEquals(event.keyName, n"IK_Escape") && IsDefined(this.m_mcmHost) {
      this.m_mcmHost.McmUiEmitKey(this.m_mcmId, NameToString(event.keyName));
    } else {
      inkTextRef.SetText(this.m_text, this.m_mcmKeyDisplay);
    };
    this.StopListeningForInput();
    inkWidgetRef.SetOpacity(this.m_editView, 0.0);
    if IsDefined(this.m_mcmHost) {
      this.m_mcmHost.McmUiEmitKeyListening(this.m_mcmId, false);
    };
    return true;
  };
  return wrappedMethod(event);
}

@wrapMethod(SettingsSelectorControllerKeyBinding)
public func Refresh() -> Void {
  if this.McmUiIsManaged() {
    this.McmUiRefreshBase(false);
    inkTextRef.SetText(this.m_text, this.m_mcmKeyDisplay);
    return;
  };
  wrappedMethod();
}

@wrapMethod(SettingsSelectorControllerKeyBinding)
protected cb func OnRelease(event: ref<inkPointerEvent>) -> Bool {
  if this.McmUiIsManaged() {
    if event.IsAction(n"click") {
      inkTextRef.SetLocalizedText(this.m_text, n"UI-Settings-ButtonMappings-Misc-KeyBind");
      inkWidgetRef.SetOpacity(this.m_editView, this.m_editOpacity);
      this.ListenForInput();
      if IsDefined(this.m_mcmHost) {
        this.m_mcmHost.McmUiEmitKeyListening(this.m_mcmId, true);
      };
    } else {
      if event.IsAction(n"unequip_item") && IsDefined(this.m_mcmHost) {
        this.m_mcmHost.McmUiEmitReset(this.m_mcmId);
      };
    };
    return true;
  };
  return wrappedMethod(event);
}
