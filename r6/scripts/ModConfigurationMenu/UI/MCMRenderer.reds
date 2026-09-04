module ModConfigurationMenu.UI

public class MCMScrollAreaData extends IScriptable {
  public let name: String;
  public let wrapper: wref<inkCompoundWidget>;
  public let viewport: wref<inkScrollArea>;
  public let content: wref<inkCanvas>;
  public let slider: wref<inkWidget>;
  public let controller: wref<inkScrollController>;
  public let width: Float;
  public let height: Float;
}

public class MCMSidebarTextState extends IScriptable {
  public let staticLabel: wref<inkText>;
  public let viewport: wref<inkScrollArea>;
  public let content: wref<inkCanvas>;
  public let animatedLabel: wref<inkText>;
  public let loopLabel: wref<inkText>;
  public let animationDefinition: ref<inkAnimDef>;
  public let animationProxy: ref<inkAnimProxy>;
  public let activation: Int32;
  public let mode: Int32;
  public let speed: Float;
  public let availableWidth: Float;
  public let height: Float;
  public let selected: Bool;
  public let hovered: Bool;
  public let ready: Bool;
  public let canAnimate: Bool;
  public let showingAnimated: Bool;
}

@addField(SettingsMainGameController)
private let m_mcmUiActive: Bool;

@addField(SettingsMainGameController)
private let m_mcmUiCloseBlocked: Bool;

@addField(SettingsMainGameController)
private let m_mcmUiRoot: wref<inkCanvas>;

@addField(SettingsMainGameController)
private let m_mcmUiContainerRoot: wref<inkCanvas>;

@addField(SettingsMainGameController)
private let m_mcmUiLayout: ref<MCMLayoutSnapshot>;

@addField(SettingsMainGameController)
private let m_mcmUiPendingLayoutSpec: ref<MCMLayoutSpec>;

@addField(SettingsMainGameController)
private let m_mcmUiSidebar: ref<MCMScrollAreaData>;

@addField(SettingsMainGameController)
private let m_mcmUiContent: ref<MCMScrollAreaData>;

@addField(SettingsMainGameController)
private let m_mcmUiDescription: ref<MCMScrollAreaData>;

@addField(SettingsMainGameController)
private let m_mcmUiDescriptionText: wref<inkRichTextBox>;

@addField(SettingsMainGameController)
private let m_mcmUiStatusText: wref<inkText>;

@addField(SettingsMainGameController)
private let m_mcmUiContentTitleText: wref<inkText>;

@addField(SettingsMainGameController)
private let m_mcmUiListSelectionMode: Int32;

@addField(SettingsMainGameController)
private let m_mcmUiModal: wref<inkCanvas>;

@addField(SettingsMainGameController)
private let m_mcmUiModalCancelId: String;

@addField(SettingsMainGameController)
private let m_mcmUiModalInputY: Float;

@addField(SettingsMainGameController)
private let m_mcmUiModalActionY: Float;

@addField(SettingsMainGameController)
private let m_mcmUiActionWidgets: array<wref<inkWidget>>;

@addField(SettingsMainGameController)
private let m_mcmUiActionIds: array<String>;

@addField(SettingsMainGameController)
private let m_mcmUiActionDescriptions: array<String>;

@addField(SettingsMainGameController)
private let m_mcmUiActionLabels: array<wref<inkText>>;

@addField(SettingsMainGameController)
private let m_mcmUiActionFrames: array<wref<inkImage>>;

@addField(SettingsMainGameController)
private let m_mcmUiActionSelected: array<Bool>;

@addField(SettingsMainGameController)
private let m_mcmUiActionSidebarText: array<ref<MCMSidebarTextState>>;

@addField(SettingsMainGameController)
private let m_mcmUiSidebarTextMeasureTick: ref<inkAnimProxy>;

@addField(SettingsMainGameController)
private let m_mcmUiSidebarTextMeasurePasses: Int32;

@addField(SettingsMainGameController)
private let m_mcmUiActionFavoriteLabels: array<Bool>;

@addField(SettingsMainGameController)
private let m_mcmUiFavoriteWidgets: array<wref<inkWidget>>;

@addField(SettingsMainGameController)
private let m_mcmUiFavoriteImages: array<wref<inkImage>>;

@addField(SettingsMainGameController)
private let m_mcmUiFavoriteActive: array<Bool>;

@addField(SettingsMainGameController)
private let m_mcmUiManagedLabelIds: array<String>;

@addField(SettingsMainGameController)
private let m_mcmUiManagedLabels: array<wref<inkText>>;

@addField(SettingsMainGameController)
private let m_mcmUiManagedMarkers: array<wref<inkText>>;

@addField(SettingsMainGameController)
private let m_mcmUiManagedLabelModified: array<Bool>;

@addField(SettingsMainGameController)
private let m_mcmUiScrollWidgets: array<wref<inkWidget>>;

@addField(SettingsMainGameController)
private let m_mcmUiScrollHitSurfaces: array<wref<inkWidget>>;

@addField(SettingsMainGameController)
private let m_mcmUiScrollControllers: array<wref<inkScrollController>>;

@addField(SettingsMainGameController)
private let m_mcmUiPendingSelect: wref<SettingsSelectorControllerListString>;

@addField(SettingsMainGameController)
private let m_mcmUiContentRow: Int32;

@addField(SettingsMainGameController)
private let m_mcmUiContentOffset: Float;

@addField(SettingsMainGameController)
private let m_mcmUiSidebarRow: Int32;

@addField(SettingsMainGameController)
private let m_mcmUiScale: Float;

@addField(SettingsMainGameController)
private let m_mcmUiTransientOwner: String;

@addField(SettingsMainGameController)
private let m_mcmUiMutationSnapshot: array<wref<inkWidget>>;

@addField(SettingsMainGameController)
private let m_mcmUiTransientWidgets: array<wref<inkWidget>>;

@addMethod(SettingsCategoryController)
public final func McmUiSetup(label: String) -> Void {
  inkTextRef.SetText(this.m_label, label);
}

@addMethod(SettingsMainGameController)
public final func McmUiIsActive() -> Bool {
  return this.m_mcmUiActive;
}

@addMethod(SettingsMainGameController)
public final func McmUiSetCloseBlocked(blocked: Bool) -> Void {
  this.m_mcmUiCloseBlocked = blocked;
}

@addMethod(SettingsMainGameController)
public final func McmUiSetManagedLabelState(
  id: String,
  hovered: Bool,
  modified: Bool
) -> Void {
  let index: Int32 = 0;
  while index < ArraySize(this.m_mcmUiManagedLabelIds) {
    if Equals(this.m_mcmUiManagedLabelIds[index], id) {
      if IsDefined(this.m_mcmUiManagedLabels[index]) {
        let color: CName = modified ? this.McmUiColorModified() : this.McmUiColorSecondary();
        this.McmUiApplyThemeColor(
          this.m_mcmUiManagedLabels[index],
          hovered ? this.McmUiColorPrimary() : color
        );
        if IsDefined(this.m_mcmUiManagedMarkers[index]) {
          this.McmUiApplyThemeColor(
            this.m_mcmUiManagedMarkers[index],
            hovered ? this.McmUiColorPrimary() : color
          );
        };
      };
      this.m_mcmUiManagedLabelModified[index] = modified;
      return;
    };
    index += 1;
  };
}

@addMethod(SettingsMainGameController)
public func McmUiEmitAction(id: String) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitStep(id: String, forward: Bool) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitNumber(id: String, value: Float) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitKey(id: String, value: String) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitKeyListening(id: String, active: Bool) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitHover(id: String, description: String, hovered: Bool) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitReset(id: String) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitSearch(context: String, value: String) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitSearchFocus(context: String, focused: Bool) -> Void {}

@addMethod(SettingsMainGameController)
public func McmUiEmitClosing() -> Void {}

@addMethod(SettingsMainGameController)
public final func McmUiApplyTextStyle(text: wref<inkText>, baseFontSize: Int32) -> Void {
  if !IsDefined(text) {
    return;
  };

  text.SetFontSize(baseFontSize);
}

@addMethod(SettingsMainGameController)
private final func McmUiApplyHeadingStyle(text: wref<inkText>) -> Void {
  if IsDefined(text) {
    text.SetFontStyle(n"Medium");
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiApplyTextBounds(
  text: wref<inkText>,
  availableWidth: Float
) -> Void {
  if !IsDefined(text) || availableWidth <= 0.0 {
    return;
  };

  text.SetWidth(availableWidth);
  text.SetFitToContent(false);
  text.SetOverflowPolicy(textOverflowPolicy.DotsEnd);
}

@addMethod(SettingsMainGameController)
private final func McmUiSetRect(
  widget: wref<inkWidget>,
  x: Float,
  y: Float,
  width: Float,
  height: Float
) -> Void {
  if !IsDefined(widget) {
    return;
  };
  widget.SetAnchor(inkEAnchor.TopLeft);
  widget.SetHAlign(inkEHorizontalAlign.Left);
  widget.SetVAlign(inkEVerticalAlign.Top);
  widget.SetSize(width, height);
  widget.SetMargin(new inkMargin(x, y, 0.0, 0.0));
}

@addMethod(SettingsMainGameController)
private final func McmUiSetNativeRect(
  widget: wref<inkWidget>,
  x: Float,
  y: Float,
  width: Float,
  height: Float
) -> Void {
  if !IsDefined(widget) {
    return;
  };

  let scale: Float = this.m_mcmUiScale > 0.0 ? this.m_mcmUiScale : 1.0;
  this.McmUiSetRect(widget, x, y, width * scale, height * scale);
  widget.SetRenderTransformPivot(new Vector2(0.0, 0.0));
  widget.SetScale(new Vector2(1.0 / scale, 1.0 / scale));
}

@addMethod(SettingsMainGameController)
private final func McmUiSetNativeChildRect(
  widget: wref<inkWidget>,
  x: Float,
  y: Float,
  width: Float,
  height: Float
) -> Void {
  let scale: Float = this.m_mcmUiScale > 0.0 ? this.m_mcmUiScale : 1.0;
  this.McmUiSetRect(widget, x * scale, y * scale, width * scale, height * scale);
}

@addMethod(SettingsMainGameController)
private final func McmUiSetNativeSettingsRowRect(
  widget: wref<inkWidget>,
  x: Float,
  y: Float,
  width: Float,
  height: Float
) -> Void {
  if !IsDefined(widget) {
    return;
  };

  let nativeWidth: Float = MCMLayout.NativeSettingsRowWidth();
  let nativeHeight: Float = MCMLayout.NativeSettingsRowHeight();
  let uniformScale: Float = MinF(width / nativeWidth, height / nativeHeight);
  let renderedHeight: Float = nativeHeight * uniformScale;
  this.McmUiSetRect(
    widget,
    x,
    y + ((height - renderedHeight) / 2.0),
    nativeWidth,
    nativeHeight
  );
  widget.SetRenderTransformPivot(new Vector2(0.0, 0.0));
  widget.SetScale(new Vector2(uniformScale, uniformScale));
}

@addMethod(SettingsMainGameController)
private final func McmUiApplyThemeColor(widget: wref<inkWidget>, color: CName) -> Void {
  if !IsDefined(widget) {
    return;
  };
  widget.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  widget.BindProperty(n"tintColor", color);
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateText(
  parent: wref<inkCompoundWidget>,
  name: CName,
  value: String,
  x: Float,
  y: Float,
  width: Float,
  height: Float,
  fontSize: Int32,
  color: CName,
  alignment: textHorizontalAlignment
) -> ref<inkText> {
  let text: ref<inkText> = new inkText();
  text.SetName(name);
  text.SetText(value);
  text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  text.SetFontStyle(n"Regular");
  this.McmUiApplyTextStyle(text, fontSize);
  this.McmUiApplyThemeColor(text, color);
  text.SetHorizontalAlignment(alignment);
  text.SetVerticalAlignment(textVerticalAlignment.Center);
  text.SetInteractive(false);
  this.McmUiSetRect(text, x, y, width, height);
  text.Reparent(parent);
  this.McmUiApplyTextBounds(text, width);
  return text;
}

@addMethod(SettingsMainGameController)
private final func McmUiAddManagedLabel(
  id: String,
  label: String,
  marker: String,
  modified: Bool,
  y: Float
) -> Void {
  if !IsDefined(this.m_mcmUiContent) || !IsDefined(this.m_mcmUiContent.content) {
    return;
  };

  let color: CName = modified ? this.McmUiColorModified() : this.McmUiColorSecondary();
  let markerText: ref<inkText> = this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_managed_marker"),
    marker,
    this.m_mcmUiLayout.contentMarkerX,
    y,
    this.m_mcmUiLayout.contentMarkerWidth,
    42.0,
    MCMLayout.ContentTextFontSize(),
    color,
    textHorizontalAlignment.Center
  );
  let text: ref<inkText> = this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_managed_label"),
    label,
    this.m_mcmUiLayout.contentLabelX,
    y,
    this.m_mcmUiLayout.contentLabelWidth,
    42.0,
    MCMLayout.ContentTextFontSize(),
    color,
    textHorizontalAlignment.Left
  );
  ArrayPush(this.m_mcmUiManagedLabelIds, id);
  ArrayPush(this.m_mcmUiManagedLabels, text);
  ArrayPush(this.m_mcmUiManagedMarkers, markerText);
  ArrayPush(this.m_mcmUiManagedLabelModified, modified);
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateImage(
  parent: wref<inkCompoundWidget>,
  name: CName,
  x: Float,
  y: Float,
  width: Float,
  height: Float,
  color: CName,
  opacity: Float,
  part: CName
) -> ref<inkImage> {
  let image: ref<inkImage> = new inkImage();
  image.SetName(name);
  image.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
  image.SetTexturePart(part);
  image.SetNineSliceScale(true);
  this.McmUiApplyThemeColor(image, color);
  image.SetOpacity(opacity);
  image.SetInteractive(false);
  this.McmUiSetRect(image, x, y, width, height);
  image.Reparent(parent);
  return image;
}

@addMethod(SettingsMainGameController)
private final func McmUiTrackAction(
  widget: wref<inkWidget>,
  label: wref<inkText>,
  frame: wref<inkImage>,
  id: String,
  description: String,
  selected: Bool
) -> Void {
  ArrayPush(this.m_mcmUiActionWidgets, widget);
  ArrayPush(this.m_mcmUiActionLabels, label);
  ArrayPush(this.m_mcmUiActionFrames, frame);
  ArrayPush(this.m_mcmUiActionIds, id);
  ArrayPush(this.m_mcmUiActionDescriptions, description);
  ArrayPush(this.m_mcmUiActionSelected, selected);
  ArrayPush(this.m_mcmUiActionSidebarText, null);
  ArrayPush(this.m_mcmUiActionFavoriteLabels, false);
  widget.RegisterToCallback(n"OnRelease", this, n"McmUiOnActionRelease");
  widget.RegisterToCallback(n"OnHoverOver", this, n"McmUiOnActionHoverOver");
  widget.RegisterToCallback(n"OnHoverOut", this, n"McmUiOnActionHoverOut");
}

@addMethod(SettingsMainGameController)
private final func McmUiListSelectionUsesText() -> Bool {
  return this.m_mcmUiListSelectionMode == 1;
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateSidebarMarqueeLabel(
  parent: wref<inkCompoundWidget>,
  name: CName,
  value: String,
  height: Float,
  fontSize: Int32,
  color: CName
) -> ref<inkText> {
  let text: ref<inkText> = new inkText();
  text.SetName(name);
  text.SetText(value);
  text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  text.SetFontStyle(n"Regular");
  this.McmUiApplyTextStyle(text, fontSize);
  this.McmUiApplyThemeColor(text, color);
  text.SetHorizontalAlignment(textHorizontalAlignment.Left);
  text.SetVerticalAlignment(textVerticalAlignment.Center);
  text.SetInteractive(false);
  text.SetFitToContent(true);
  text.SetOverflowPolicy(textOverflowPolicy.None);
  text.SetAffectsLayoutWhenHidden(true);
  text.SetAnchor(inkEAnchor.TopLeft);
  text.SetHAlign(inkEHorizontalAlign.Left);
  text.SetVAlign(inkEVerticalAlign.Top);
  text.SetHeight(height);
  text.SetMargin(new inkMargin(0.0, 0.0, 0.0, 0.0));
  text.Reparent(parent);
  return text;
}

@addMethod(SettingsMainGameController)
private final func McmUiStopSidebarTextAnimation(
  state: ref<MCMSidebarTextState>
) -> Void {
  if !IsDefined(state) {
    return;
  };
  if IsDefined(state.animationProxy) {
    state.animationProxy.Stop(true);
    state.animationProxy = null;
  };
  if IsDefined(state.content) {
    state.content.SetTranslation(new Vector2(0.0, 0.0));
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiStartSidebarTextAnimation(
  state: ref<MCMSidebarTextState>
) -> Void {
  if !IsDefined(state)
    || !state.ready
    || !state.canAnimate
    || !IsDefined(state.content)
    || !IsDefined(state.animationDefinition) {
    return;
  };
  this.McmUiStopSidebarTextAnimation(state);
  let options: inkAnimOptions;
  options.loopInfinite = true;
  options.loopType = inkanimLoopType.Cycle;
  state.animationProxy = state.content.PlayAnimationWithOptions(
    state.animationDefinition,
    options
  );
}

@addMethod(SettingsMainGameController)
private final func McmUiSidebarTextShouldAnimate(
  state: ref<MCMSidebarTextState>
) -> Bool {
  return state.activation == 0
    || (state.activation == 1 && state.hovered)
    || (state.activation == 2 && (state.hovered || state.selected))
    || (state.activation == 3 && state.selected);
}

@addMethod(SettingsMainGameController)
private final func McmUiSyncSidebarText(index: Int32) -> Void {
  if index < 0 || index >= ArraySize(this.m_mcmUiActionSidebarText) {
    return;
  };
  let state: ref<MCMSidebarTextState> = this.m_mcmUiActionSidebarText[index];
  if !IsDefined(state)
    || !IsDefined(state.staticLabel)
    || !IsDefined(state.viewport) {
    return;
  };
  let showAnimated: Bool = state.ready
    && state.canAnimate
    && this.McmUiSidebarTextShouldAnimate(state);
  if Equals(state.showingAnimated, showAnimated) {
    return;
  };
  state.showingAnimated = showAnimated;
  if showAnimated {
    state.viewport.SetVisible(true);
    state.staticLabel.SetVisible(false);
    this.McmUiStartSidebarTextAnimation(state);
  } else {
    state.viewport.SetVisible(false);
    state.staticLabel.SetVisible(true);
    this.McmUiStopSidebarTextAnimation(state);
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiPrepareSidebarTextAnimation(
  index: Int32,
  textWidth: Float
) -> Void {
  let state: ref<MCMSidebarTextState> = this.m_mcmUiActionSidebarText[index];
  if !IsDefined(state) || state.ready || !IsDefined(state.animatedLabel) {
    return;
  };
  state.ready = true;
  state.canAnimate = textWidth > state.availableWidth + 1.0;
  if !state.canAnimate {
    this.McmUiSyncSidebarText(index);
    return;
  };

  let stableTextWidth: Float = MaxF(textWidth + 2.0, state.availableWidth + 2.0);
  state.animatedLabel.SetFitToContent(false);
  state.animatedLabel.SetSizeRule(inkESizeRule.Fixed);
  this.McmUiSetRect(state.animatedLabel, 0.0, 0.0, stableTextWidth, state.height);

  let distance: Float;
  let duration: Float;
  let definition: ref<inkAnimDef> = new inkAnimDef();
  if state.mode == 1 {
    let gap: Float = state.availableWidth * 0.30;
    distance = stableTextWidth + gap;
    this.McmUiSetRect(
      state.content,
      0.0,
      0.0,
      stableTextWidth * 2.0 + gap,
      state.height
    );
    let color: CName = state.hovered || (state.selected && this.McmUiListSelectionUsesText())
      ? this.McmUiColorPrimary()
      : this.m_mcmUiActionFavoriteLabels[index]
        ? this.McmUiColorFavorite()
        : this.McmUiColorSecondary();
    state.loopLabel = this.McmUiCreateSidebarMarqueeLabel(
      state.content,
      StringToName(this.m_mcmUiActionIds[index] + "_loop_label"),
      state.animatedLabel.GetText(),
      state.height,
      state.animatedLabel.GetFontSize(),
      color
    );
    state.loopLabel.SetFitToContent(false);
    state.loopLabel.SetSizeRule(inkESizeRule.Fixed);
    this.McmUiSetRect(
      state.loopLabel,
      stableTextWidth + gap,
      0.0,
      stableTextWidth,
      state.height
    );
    duration = distance / MaxF(1.0, state.speed * 60.0);
    let loopTranslation: ref<inkAnimTranslation> = new inkAnimTranslation();
    loopTranslation.SetStartTranslation(new Vector2(0.0, 0.0));
    loopTranslation.SetEndTranslation(new Vector2(-distance, 0.0));
    loopTranslation.SetDuration(duration);
    loopTranslation.SetType(inkanimInterpolationType.Linear);
    loopTranslation.SetMode(inkanimInterpolationMode.EasyIn);
    definition.AddInterpolator(loopTranslation);
  } else {
    distance = stableTextWidth - state.availableWidth;
    this.McmUiSetRect(state.content, 0.0, 0.0, stableTextWidth, state.height);
    duration = distance / MaxF(1.0, state.speed * 60.0);
    let outbound: ref<inkAnimTranslation> = new inkAnimTranslation();
    outbound.SetStartTranslation(new Vector2(0.0, 0.0));
    outbound.SetEndTranslation(new Vector2(-distance, 0.0));
    outbound.SetStartDelay(0.65);
    outbound.SetDuration(duration);
    outbound.SetType(inkanimInterpolationType.Linear);
    outbound.SetMode(inkanimInterpolationMode.EasyIn);
    definition.AddInterpolator(outbound);

    let inbound: ref<inkAnimTranslation> = new inkAnimTranslation();
    inbound.SetStartTranslation(new Vector2(-distance, 0.0));
    inbound.SetEndTranslation(new Vector2(0.0, 0.0));
    inbound.SetStartDelay(0.65 + duration + 0.65);
    inbound.SetDuration(duration);
    inbound.SetType(inkanimInterpolationType.Linear);
    inbound.SetMode(inkanimInterpolationMode.EasyIn);
    definition.AddInterpolator(inbound);
  };
  state.animationDefinition = definition;
  this.McmUiSyncSidebarText(index);
}

@addMethod(SettingsMainGameController)
private final func McmUiStopSidebarTextMeasureTick() -> Void {
  if IsDefined(this.m_mcmUiSidebarTextMeasureTick) {
    this.m_mcmUiSidebarTextMeasureTick.Stop(true);
    this.m_mcmUiSidebarTextMeasureTick = null;
  };
  this.m_mcmUiSidebarTextMeasurePasses = 0;
}

@addMethod(SettingsMainGameController)
private final func McmUiStopAllSidebarTextMotion() -> Void {
  this.McmUiStopSidebarTextMeasureTick();
  let index: Int32 = 0;
  while index < ArraySize(this.m_mcmUiActionSidebarText) {
    this.McmUiStopSidebarTextAnimation(this.m_mcmUiActionSidebarText[index]);
    index += 1;
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiEnsureSidebarTextMeasureTick() -> Void {
  if IsDefined(this.m_mcmUiSidebarTextMeasureTick) || !IsDefined(this.m_mcmUiRoot) {
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
  this.m_mcmUiSidebarTextMeasurePasses = 0;
  this.m_mcmUiSidebarTextMeasureTick = this.m_mcmUiRoot.PlayAnimationWithOptions(
    definition,
    options
  );
  this.m_mcmUiSidebarTextMeasureTick.RegisterToCallback(
    inkanimEventType.OnEndLoop,
    this,
    n"McmUiOnSidebarTextMeasureTick"
  );
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnSidebarTextMeasureTick(proxy: ref<inkAnimProxy>) -> Bool {
  let pending: Bool = false;
  let index: Int32 = 0;
  this.m_mcmUiSidebarTextMeasurePasses += 1;
  while index < ArraySize(this.m_mcmUiActionSidebarText) {
    let state: ref<MCMSidebarTextState> = this.m_mcmUiActionSidebarText[index];
    if IsDefined(state) && !state.ready && IsDefined(state.animatedLabel) {
      let size: Vector2 = state.animatedLabel.GetDesiredSize();
      if size.X > 0.01 {
        this.McmUiPrepareSidebarTextAnimation(index, size.X);
      } else {
        pending = true;
      };
    };
    index += 1;
  };
  if !pending || this.m_mcmUiSidebarTextMeasurePasses >= 120 {
    this.McmUiStopSidebarTextMeasureTick();
  };
  return true;
}

@addMethod(SettingsMainGameController)
private final func McmUiConfigureSidebarText(
  widget: wref<inkWidget>,
  mode: Int32,
  activation: Int32,
  speed: Float
) -> Void {
  let index: Int32 = this.McmUiFindAction(widget);
  if index < 0 || mode <= 0 {
    return;
  };
  let staticLabel: wref<inkText> = this.m_mcmUiActionLabels[index];
  let surface: wref<inkCompoundWidget> = widget as inkCompoundWidget;
  if !IsDefined(staticLabel) || !IsDefined(surface) {
    return;
  };
  let color: CName = this.m_mcmUiActionSelected[index] && this.McmUiListSelectionUsesText()
    ? this.McmUiColorPrimary()
    : this.McmUiColorSecondary();
  let viewport: ref<inkScrollArea> = new inkScrollArea();
  viewport.SetName(StringToName(this.m_mcmUiActionIds[index] + "_marquee"));
  viewport.SetVisible(false);
  viewport.SetAffectsLayoutWhenHidden(true);
  viewport.SetInteractive(false);
  viewport.SetFitToContentDirection(inkFitToContentDirection.Vertical);
  viewport.SetConstrainContentPosition(false);
  viewport.SetUseInternalMask(true);
  let textLeftInset: Float = MCMLayout.ListRowTextLeftInset(
    this.McmUiListSelectionUsesText()
  );
  this.McmUiSetRect(
    viewport,
    textLeftInset,
    0.0,
    staticLabel.GetWidth(),
    staticLabel.GetHeight()
  );
  viewport.Reparent(surface);

  let content: ref<inkCanvas> = new inkCanvas();
  content.SetName(StringToName(this.m_mcmUiActionIds[index] + "_marquee_content"));
  content.SetAffectsLayoutWhenHidden(true);
  content.SetInteractive(false);
  this.McmUiSetRect(content, 0.0, 0.0, staticLabel.GetWidth(), staticLabel.GetHeight());
  content.Reparent(viewport);

  let animatedLabel: ref<inkText> = this.McmUiCreateSidebarMarqueeLabel(
    content,
    StringToName(this.m_mcmUiActionIds[index] + "_animated_label"),
    staticLabel.GetText(),
    staticLabel.GetHeight(),
    staticLabel.GetFontSize(),
    color
  );

  let state: ref<MCMSidebarTextState> = new MCMSidebarTextState();
  state.staticLabel = staticLabel;
  state.viewport = viewport;
  state.content = content;
  state.animatedLabel = animatedLabel;
  state.activation = Clamp(activation, 0, 3);
  state.mode = Clamp(mode, 1, 2);
  state.speed = MaxF(0.05, speed);
  state.availableWidth = staticLabel.GetWidth();
  state.height = staticLabel.GetHeight();
  state.selected = this.m_mcmUiActionSelected[index];
  state.hovered = false;
  state.ready = false;
  state.canAnimate = false;
  state.showingAnimated = false;
  this.m_mcmUiActionSidebarText[index] = state;
  this.McmUiSyncSidebarText(index);
  this.McmUiEnsureSidebarTextMeasureTick();
}

@addMethod(SettingsMainGameController)
private final func McmUiSetActionTextColor(index: Int32, color: CName) -> Void {
  if IsDefined(this.m_mcmUiActionLabels[index]) {
    this.McmUiApplyThemeColor(this.m_mcmUiActionLabels[index], color);
  };
  let state: ref<MCMSidebarTextState> = this.m_mcmUiActionSidebarText[index];
  if IsDefined(state) && IsDefined(state.animatedLabel) {
    this.McmUiApplyThemeColor(state.animatedLabel, color);
    if IsDefined(state.loopLabel) {
      this.McmUiApplyThemeColor(state.loopLabel, color);
    };
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiFindAction(widget: wref<inkWidget>) -> Int32 {
  let index: Int32 = 0;
  while index < ArraySize(this.m_mcmUiActionWidgets) {
    if Equals(this.m_mcmUiActionWidgets[index], widget) {
      return index;
    };
    index += 1;
  };
  return -1;
}

@addMethod(SettingsMainGameController)
private final func McmUiMarkActionFavorite(widget: wref<inkWidget>) -> Void {
  let index: Int32 = this.McmUiFindAction(widget);
  if index < 0 {
    return;
  };
  this.m_mcmUiActionFavoriteLabels[index] = true;
  if !this.m_mcmUiActionSelected[index] || !this.McmUiListSelectionUsesText() {
    this.McmUiSetActionTextColor(index, this.McmUiColorFavorite());
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiTrackFavoriteVisual(
  widget: wref<inkWidget>,
  image: wref<inkImage>,
  active: Bool
) -> Void {
  ArrayPush(this.m_mcmUiFavoriteWidgets, widget);
  ArrayPush(this.m_mcmUiFavoriteImages, image);
  ArrayPush(this.m_mcmUiFavoriteActive, active);
}

@addMethod(SettingsMainGameController)
private final func McmUiFindFavoriteVisual(widget: wref<inkWidget>) -> Int32 {
  let index: Int32 = 0;
  while index < ArraySize(this.m_mcmUiFavoriteWidgets) {
    if Equals(this.m_mcmUiFavoriteWidgets[index], widget) {
      return index;
    };
    index += 1;
  };
  return -1;
}

@addMethod(SettingsMainGameController)
private final func McmUiApplyFavoriteVisual(
  image: wref<inkImage>,
  active: Bool,
  hovered: Bool
) -> Void {
  if !IsDefined(image) {
    return;
  };
  if active {
    this.McmUiApplyThemeColor(image, this.McmUiColorFavorite());
    image.SetOpacity(1.0);
  } else {
    this.McmUiApplyThemeColor(image, this.McmUiColorMuted());
    image.SetOpacity(hovered ? 0.55 : 0.16);
  };
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnActionRelease(event: ref<inkPointerEvent>) -> Bool {
  if !event.IsAction(n"click") {
    return false;
  };
  let index: Int32 = this.McmUiFindAction(event.GetCurrentTarget());
  if index < 0 {
    return false;
  };
  this.PlaySound(n"Button", n"OnPress");
  let actionId: String = this.m_mcmUiActionIds[index];
  this.McmUiEmitAction(actionId);
  return true;
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnActionHoverOver(event: ref<inkPointerEvent>) -> Bool {
  let index: Int32 = this.McmUiFindAction(event.GetCurrentTarget());
  if index < 0 {
    return false;
  };
  this.PlaySound(n"Button", n"OnHover");
  let favoriteIndex: Int32 = this.McmUiFindFavoriteVisual(event.GetCurrentTarget());
  if favoriteIndex >= 0 {
    this.McmUiApplyFavoriteVisual(
      this.m_mcmUiFavoriteImages[favoriteIndex],
      this.m_mcmUiFavoriteActive[favoriteIndex],
      true
    );
    this.McmUiEmitHover(
      this.m_mcmUiActionIds[index],
      this.m_mcmUiActionDescriptions[index],
      true
    );
    return true;
  };
  if IsDefined(this.m_mcmUiActionLabels[index]) {
    let state: ref<MCMSidebarTextState> = this.m_mcmUiActionSidebarText[index];
    if IsDefined(state) {
      state.hovered = true;
      this.McmUiSyncSidebarText(index);
    };
    this.McmUiSetActionTextColor(index, this.McmUiColorPrimary());
  };
  if IsDefined(this.m_mcmUiActionFrames[index]) {
    this.McmUiApplyThemeColor(this.m_mcmUiActionFrames[index], this.McmUiColorPrimary());
    this.m_mcmUiActionFrames[index].SetOpacity(1.0);
  };
  this.McmUiEmitHover(
    this.m_mcmUiActionIds[index],
    this.m_mcmUiActionDescriptions[index],
    true
  );
  return true;
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnActionHoverOut(event: ref<inkPointerEvent>) -> Bool {
  let index: Int32 = this.McmUiFindAction(event.GetCurrentTarget());
  if index < 0 {
    return false;
  };
  let favoriteIndex: Int32 = this.McmUiFindFavoriteVisual(event.GetCurrentTarget());
  if favoriteIndex >= 0 {
    this.McmUiApplyFavoriteVisual(
      this.m_mcmUiFavoriteImages[favoriteIndex],
      this.m_mcmUiFavoriteActive[favoriteIndex],
      false
    );
    this.McmUiEmitHover(
      this.m_mcmUiActionIds[index],
      this.m_mcmUiActionDescriptions[index],
      false
    );
    return true;
  };
  if IsDefined(this.m_mcmUiActionLabels[index]) {
    let state: ref<MCMSidebarTextState> = this.m_mcmUiActionSidebarText[index];
    if IsDefined(state) {
      state.hovered = false;
      this.McmUiSyncSidebarText(index);
    };
    this.McmUiSetActionTextColor(
      index,
      this.m_mcmUiActionSelected[index] && this.McmUiListSelectionUsesText()
        ? this.McmUiColorPrimary()
        : this.m_mcmUiActionFavoriteLabels[index]
          ? this.McmUiColorFavorite()
          : this.McmUiColorSecondary()
    );
  };
  if IsDefined(this.m_mcmUiActionFrames[index]) {
    this.McmUiApplyThemeColor(
      this.m_mcmUiActionFrames[index],
      this.m_mcmUiActionSelected[index]
        ? this.McmUiColorPrimary()
        : this.McmUiColorSecondary()
    );
    this.m_mcmUiActionFrames[index].SetOpacity(0.84);
  };
  this.McmUiEmitHover(
    this.m_mcmUiActionIds[index],
    this.m_mcmUiActionDescriptions[index],
    false
  );
  return true;
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateStockAction(
  parent: wref<inkCompoundWidget>,
  id: String,
  labelText: String,
  description: String,
  x: Float,
  y: Float,
  width: Float,
  height: Float,
  selected: Bool
) -> ref<inkWidget> {
  let nativeScale: Float = 0.5;
  let nativeWidth: Float = width / nativeScale;
  let nativeHeight: Float = height / nativeScale;
  let style: ResRef = r"base\\gameplay\\gui\\fullscreen\\settings\\settings.inkstyle";

  let surface: ref<inkFlex> = new inkFlex();
  surface.SetName(StringToName("mcm_action_" + id));
  surface.SetInteractive(true);
  this.McmUiSetRect(surface, x, y, nativeWidth, nativeHeight);
  surface.SetAnchorPoint(new Vector2(0.0, 0.0));
  surface.SetRenderTransformPivot(new Vector2(0.0, 0.0));
  surface.SetScale(new Vector2(nativeScale, nativeScale));
  surface.Reparent(parent);

  let background: ref<inkImage> = this.McmUiCreateImage(
    surface,
    n"filler-bg",
    0.0,
    0.0,
    nativeWidth,
    nativeHeight,
    this.McmUiColorPanel(),
    1.0,
    n"cell_bg"
  );
  background.SetStyle(style);
  background.BindProperty(n"tintColor", n"Button.bgColor");
  background.BindProperty(n"opacity", n"Button.bgOpacity");

  let frame: ref<inkImage> = this.McmUiCreateImage(
    surface,
    n"filler",
    0.0,
    0.0,
    nativeWidth,
    nativeHeight,
    this.McmUiColorSecondary(),
    1.0,
    n"cell_fg"
  );
  frame.SetStyle(style);
  frame.BindProperty(n"tintColor", n"Button.frameColor");
  frame.BindProperty(n"opacity", n"Button.frameOpacity");

  let label: ref<inkText> = new inkText();
  label.SetName(n"label");
  label.SetText(labelText);
  label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  label.SetFontStyle(n"Medium");
  label.SetFontSize(50);
  label.SetHorizontalAlignment(textHorizontalAlignment.Center);
  label.SetVerticalAlignment(textVerticalAlignment.Center);
  label.SetOverflowPolicy(textOverflowPolicy.DotsEnd);
  label.SetFitToContent(false);
  label.SetInteractive(false);
  label.SetStyle(style);
  label.BindProperty(n"tintColor", this.McmUiColorPrimary());
  label.BindProperty(n"fontStyle", n"MainColors.BodyFontWeight");
  label.BindProperty(n"fontSize", n"MainColors.ReadableFontSize");
  this.McmUiSetRect(label, 20.0, 0.0, nativeWidth - 40.0, nativeHeight);
  label.Reparent(surface);

  let button: ref<inkButtonController> = new inkButtonController();
  button.SetAutoUpdateWidgetState(true);
  button.SetSelectable(true);
  surface.AttachController(button);
  if selected {
    button.SetSelected(true);
  };
  button.UpdateButtonState(true);
  if selected {
    surface.SetState(n"Selected");
    background.SetState(n"Selected");
    frame.SetState(n"Selected");
    label.SetState(n"Selected");
  };

  this.McmUiTrackAction(surface, null, null, id, description, selected);
  return surface;
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateSelectedRowSurface(
  parent: wref<inkCompoundWidget>,
  width: Float,
  height: Float
) -> Void {
  let nativeScale: Float = 0.5;
  let nativeWidth: Float = width / nativeScale;
  let nativeHeight: Float = (height - 6.0) / nativeScale;
  let style: ResRef = r"base\\gameplay\\gui\\fullscreen\\settings\\settings.inkstyle";

  let surface: ref<inkFlex> = new inkFlex();
  surface.SetName(n"selected_surface");
  surface.SetInteractive(false);
  this.McmUiSetRect(surface, 0.0, 3.0, nativeWidth, nativeHeight);
  surface.SetAnchorPoint(new Vector2(0.0, 0.0));
  surface.SetRenderTransformPivot(new Vector2(0.0, 0.0));
  surface.SetScale(new Vector2(nativeScale, nativeScale));
  surface.SetState(n"Selected");
  surface.Reparent(parent);

  let background: ref<inkImage> = this.McmUiCreateImage(
    surface,
    n"filler-bg",
    0.0,
    0.0,
    nativeWidth,
    nativeHeight,
    this.McmUiColorPanelSelected(),
    1.0,
    n"cell_bg"
  );
  background.SetStyle(style);
  background.BindProperty(n"tintColor", n"Button.bgColor");
  background.BindProperty(n"opacity", n"Button.bgOpacity");
  background.SetState(n"Selected");

  let frame: ref<inkImage> = this.McmUiCreateImage(
    surface,
    n"filler",
    0.0,
    0.0,
    nativeWidth,
    nativeHeight,
    this.McmUiColorPrimary(),
    1.0,
    n"cell_fg"
  );
  frame.SetStyle(style);
  frame.BindProperty(n"tintColor", n"Button.frameColor");
  frame.BindProperty(n"opacity", n"Button.frameOpacity");
  frame.SetState(n"Selected");
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateAction(
  parent: wref<inkCompoundWidget>,
  id: String,
  labelText: String,
  description: String,
  x: Float,
  y: Float,
  width: Float,
  height: Float,
  selected: Bool,
  centered: Bool
) -> ref<inkWidget> {
  if centered {
    return this.McmUiCreateStockAction(
      parent,
      id,
      labelText,
      description,
      x,
      y,
      width,
      height,
      selected
    );
  };

  let surface: ref<inkCanvas> = new inkCanvas();
  let labelColor: CName = selected && this.McmUiListSelectionUsesText()
    ? this.McmUiColorPrimary()
    : this.McmUiColorSecondary();
  surface.SetName(StringToName("mcm_action_" + id));
  surface.SetInteractive(true);
  this.McmUiSetRect(surface, x, y, width, height);
  surface.Reparent(parent);

  if selected && !this.McmUiListSelectionUsesText() {
    this.McmUiCreateSelectedRowSurface(surface, width, height);
  };

  let textOnly: Bool = this.McmUiListSelectionUsesText();
  let textLeftInset: Float = MCMLayout.ListRowTextLeftInset(textOnly);
  let textRightInset: Float = MCMLayout.ListRowTextRightInset(textOnly);

  let label: ref<inkText> = this.McmUiCreateText(
    surface,
    n"label",
    labelText,
    textLeftInset,
    0.0,
    width - textLeftInset - textRightInset,
    height,
    26,
    labelColor,
    textHorizontalAlignment.Left
  );
  this.McmUiTrackAction(surface, label, null, id, description, selected);
  return surface;
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateScrollArea(
  parent: wref<inkCompoundWidget>,
  name: String,
  x: Float,
  y: Float,
  width: Float,
  height: Float,
  contentHeight: Float
) -> ref<MCMScrollAreaData> {
  let tempRoot: wref<inkCompoundWidget> = this.SpawnFromExternal(
    null,
    r"base\\gameplay\\gui\\fullscreen\\tarot\\tarot.inkwidget",
    n"Root"
  ) as inkCompoundWidget;
  if !IsDefined(tempRoot) {
    return null;
  };

  tempRoot.SetVisible(false);
  let wrapper: wref<inkCompoundWidget> = tempRoot.GetWidget(n"wrapper") as inkCompoundWidget;
  let tempParent: wref<inkCompoundWidget> = tempRoot.GetParentWidget() as inkCompoundWidget;
  if !IsDefined(wrapper) {
    if IsDefined(tempParent) {
      tempParent.RemoveChild(tempRoot);
    };
    return null;
  };

  wrapper.Reparent(parent);
  if IsDefined(tempParent) {
    tempParent.RemoveChild(tempRoot);
  };
  wrapper.SetName(StringToName(name));
  wrapper.SetVisible(true);
  this.McmUiSetRect(wrapper, x, y, width, height);

  let child: wref<inkWidget>;
  let index: Int32 = wrapper.GetNumChildren() - 1;
  while index >= 0 {
    child = wrapper.GetWidgetByIndex(index);
    if IsDefined(child)
      && NotEquals(child.GetName(), n"scroll_area")
      && NotEquals(child.GetName(), n"slider") {
      wrapper.RemoveChild(child);
    };
    index -= 1;
  };

  let viewport: wref<inkScrollArea> = wrapper.GetWidget(n"scroll_area") as inkScrollArea;
  let slider: wref<inkWidget> = wrapper.GetWidget(n"slider");
  if !IsDefined(viewport) {
    return null;
  };
  viewport.RemoveAllChildren();
  viewport.SetUseInternalMask(true);
  viewport.SetConstrainContentPosition(true);
  this.McmUiSetRect(viewport, 0.0, 0.0, width - 28.0, height);

  let content: ref<inkCanvas> = new inkCanvas();
  content.SetName(StringToName(name + "_content"));
  content.SetInteractive(true);
  this.McmUiSetRect(content, 0.0, 0.0, width - 34.0, MaxF(height, contentHeight));
  content.Reparent(viewport);

  if IsDefined(slider) {
    slider.SetVisible(contentHeight > height + 1.0);
    slider.SetInteractive(true);
    this.McmUiSetNativeRect(slider, width - 18.0, 0.0, 18.0, height);

    let sliderCompound: wref<inkCompoundWidget> = slider as inkCompoundWidget;
    if IsDefined(sliderCompound) {
      let slidingArea: wref<inkWidget> = sliderCompound.GetWidget(n"slidingArea");
      if IsDefined(slidingArea) {
        this.McmUiSetNativeChildRect(slidingArea, 0.0, 0.0, 18.0, height);
      };
    };
  };

  let result: ref<MCMScrollAreaData> = new MCMScrollAreaData();
  result.name = name;
  result.wrapper = wrapper;
  result.viewport = viewport;
  result.content = content;
  result.slider = slider;
  result.controller = wrapper.GetController() as inkScrollController;
  result.width = width - 34.0;
  result.height = height;
  if IsDefined(result.controller) {
    result.controller.SetInputDisabled(true);
  };

  ArrayPush(this.m_mcmUiScrollWidgets, wrapper);
  ArrayPush(this.m_mcmUiScrollHitSurfaces, content);
  ArrayPush(this.m_mcmUiScrollControllers, result.controller);
  wrapper.RegisterToCallback(n"OnHoverOver", this, n"McmUiOnScrollHoverOver");
  content.RegisterToCallback(n"OnHoverOver", this, n"McmUiOnScrollHoverOver");
  return result;
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnScrollHoverOver(event: ref<inkPointerEvent>) -> Bool {
  let hoveredIndex: Int32 = -1;
  let index: Int32 = 0;
  while index < ArraySize(this.m_mcmUiScrollWidgets) {
    if Equals(this.m_mcmUiScrollWidgets[index], event.GetCurrentTarget())
      || Equals(this.m_mcmUiScrollHitSurfaces[index], event.GetCurrentTarget()) {
      hoveredIndex = index;
      break;
    };
    index += 1;
  };

  index = 0;
  while index < ArraySize(this.m_mcmUiScrollControllers) {
    if IsDefined(this.m_mcmUiScrollControllers[index]) {
      this.m_mcmUiScrollControllers[index].SetInputDisabled(index != hoveredIndex);
    };
    index += 1;
  };
  return true;
}
