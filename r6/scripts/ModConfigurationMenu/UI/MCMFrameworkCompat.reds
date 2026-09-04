module ModConfigurationMenu.UI

@addField(SettingsMainGameController)
private let m_mcmUiFrameworkSurface: String;

@addField(SettingsMainGameController)
private let m_mcmUiFrameworkRoot: wref<inkCanvas>;

@addField(SettingsMainGameController)
private let m_mcmUiFrameworkContentOuter: wref<inkCanvas>;

@addField(SettingsMainGameController)
private let m_mcmUiFrameworkContentInner: wref<inkCanvas>;

@addField(SettingsMainGameController)
private let m_mcmUiFrameworkPreviewHost: wref<inkCanvas>;

@addField(SettingsMainGameController)
private let m_mcmUiFrameworkPreviewHoverActive: Bool;

@addField(SettingsMainGameController)
private let m_mcmUiFrameworkPreviewNormalizePass: Int32;

@addField(SettingsMainGameController)
private let m_mcmUiFrameworkPreviewNormalizeProxy: ref<inkAnimProxy>;

@addMethod(SettingsMainGameController)
public final func McmUiSetFrameworkContext(
  surface: String,
  sourceId: String,
  sourceLabel: String
) -> Void {
  this.m_mcmUiFrameworkSurface = surface;
  this.McmUiEndFrameworkPreviewHover();

  if (NotEquals(surface, "mod_settings") && NotEquals(surface, "native_settings"))
    || Equals(sourceId, "")
    || !IsDefined(this.m_mcmUiRoot) {
    return;
  };

  let contentParent: wref<inkCompoundWidget> = this.m_mcmUiRoot;
  if Equals(surface, "native_settings") {
    contentParent = this.McmUiCreateNativeSettingsFrameworkRoot(sourceLabel);
  };

  let outer: ref<inkCanvas> = new inkCanvas();
  outer.SetName(n"mcm_framework_content_outer");
  outer.SetInteractive(false);
  this.McmUiSetRect(
    outer,
    0.0,
    0.0,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height
  );
  outer.Reparent(contentParent);
  this.m_mcmUiFrameworkContentOuter = outer;

  let inner: ref<inkCanvas> = new inkCanvas();
  inner.SetName(n"mcm_framework_content_inner");
  inner.SetInteractive(false);
  this.McmUiSetRect(
    inner,
    0.0,
    0.0,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height
  );
  inner.Reparent(outer);
  this.m_mcmUiFrameworkContentInner = inner;

  if Equals(surface, "mod_settings") {
    this.McmUiCreateModSettingsPreviewHost(sourceId);
  } else {
    this.McmUiCreateNativeSettingsPreviewHost();
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateFrameworkPathNode(
  parent: wref<inkCompoundWidget>,
  widgetName: CName
) -> ref<inkCanvas> {
  let node: ref<inkCanvas> = new inkCanvas();
  node.SetName(widgetName);
  node.SetInteractive(false);
  this.McmUiSetRect(node, 0.0, 0.0, 1.0, 1.0);
  node.Reparent(parent);
  return node;
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateNativeSettingsFrameworkRoot(
  sourceLabel: String
) -> ref<inkCanvas> {
  let root: ref<inkCanvas> = new inkCanvas();
  root.SetName(n"mcm_native_settings_root");
  root.SetInteractive(false);
  this.McmUiSetRect(
    root,
    0.0,
    0.0,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height
  );
  root.Reparent(this.m_mcmUiRoot);
  this.m_mcmUiFrameworkRoot = root;

  let wrapper1: ref<inkCanvas> = this.McmUiCreateFrameworkPathNode(root, n"wrapper");
  let wrapper2: ref<inkCanvas> = this.McmUiCreateFrameworkPathNode(wrapper1, n"wrapper");
  let topHeader: ref<inkCanvas> = this.McmUiCreateFrameworkPathNode(wrapper2, n"top_header");
  let wrapper3: ref<inkCanvas> = this.McmUiCreateFrameworkPathNode(topHeader, n"wrapper");
  let centerHolder: ref<inkCanvas> = this.McmUiCreateFrameworkPathNode(wrapper3, n"center_holder");
  let labelHolder: ref<inkCanvas> = this.McmUiCreateFrameworkPathNode(
    centerHolder,
    n"menu_label_holder"
  );
  let activeMod: ref<inkCanvas> = this.McmUiCreateFrameworkPathNode(
    labelHolder,
    n"mcm_active_mod"
  );

  let marker: ref<inkText> = new inkText();
  marker.SetName(n"txtValueHighlight");
  marker.SetText(StrUpper(sourceLabel));
  marker.SetLetterCase(textLetterCase.UpperCase);
  marker.SetOpacity(1.0);
  marker.SetVisible(true);
  this.McmUiSetRect(marker, 0.0, 0.0, 1.0, 1.0);
  marker.Reparent(activeMod);
  return root;
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateNativeSettingsPreviewHost() -> Void {
  let host: ref<inkCanvas> = new inkCanvas();
  host.SetName(n"mcm_native_settings_preview_host");
  host.SetInteractive(false);
  this.McmUiSetRect(
    host,
    this.m_mcmUiLayout.description.x,
    this.m_mcmUiLayout.description.y,
    this.m_mcmUiLayout.description.width,
    this.m_mcmUiLayout.description.height
  );
  host.Reparent(this.m_mcmUiRoot);
  this.m_mcmUiFrameworkPreviewHost = host;
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateModSettingsPreviewHost(sourceId: String) -> Void {
  let host: ref<inkCanvas> = new inkCanvas();
  host.SetName(n"mod_settings");
  host.SetInteractive(false);
  this.McmUiSetRect(
    host,
    this.m_mcmUiLayout.description.x,
    this.m_mcmUiLayout.description.y,
    this.m_mcmUiLayout.description.width,
    this.m_mcmUiLayout.description.height
  );
  host.Reparent(this.m_mcmUiRoot);
  this.m_mcmUiFrameworkPreviewHost = host;

  let modFlex: ref<inkCanvas> = new inkCanvas();
  modFlex.SetName(n"mod_flex");
  modFlex.SetVisible(false);
  this.McmUiSetRect(modFlex, 0.0, 0.0, 1.0, 1.0);
  modFlex.Reparent(host);

  let modScroller: ref<inkCanvas> = new inkCanvas();
  modScroller.SetName(n"mod_scroller");
  this.McmUiSetRect(modScroller, 0.0, 0.0, 1.0, 1.0);
  modScroller.Reparent(modFlex);

  let mods: ref<inkCanvas> = new inkCanvas();
  mods.SetName(n"mods");
  this.McmUiSetRect(mods, 0.0, 0.0, 1.0, 1.0);
  mods.Reparent(modScroller);

  let activeMod: ref<inkCanvas> = new inkCanvas();
  activeMod.SetName(n"mcm_active_mod");
  this.McmUiSetRect(activeMod, 0.0, 0.0, 1.0, 1.0);
  activeMod.Reparent(mods);

  let marker: ref<inkText> = new inkText();
  marker.SetName(n"txtValueHighlight");
  marker.SetText(sourceId);
  marker.SetOpacity(1.0);
  marker.SetVisible(true);
  this.McmUiSetRect(marker, 0.0, 0.0, 1.0, 1.0);
  marker.Reparent(activeMod);
}

@addMethod(SettingsMainGameController)
private final func McmUiFrameworkContentParent() -> wref<inkCompoundWidget> {
  if IsDefined(this.m_mcmUiFrameworkContentInner) {
    return this.m_mcmUiFrameworkContentInner;
  };
  return this.m_mcmUiRoot;
}

@addMethod(SettingsMainGameController)
public final func McmUiHasFrameworkPreviewContext() -> Bool {
  return (Equals(this.m_mcmUiFrameworkSurface, "mod_settings")
      || Equals(this.m_mcmUiFrameworkSurface, "native_settings"))
    && IsDefined(this.m_mcmUiFrameworkPreviewHost)
    && IsDefined(this.m_mcmUiLayout)
    && this.m_mcmUiLayout.descriptionVisible;
}

@addMethod(SettingsMainGameController)
public final func McmUiFinalizeFrameworkContext() -> Void {
  if !IsDefined(this.m_mcmUiFrameworkPreviewHost)
    || !IsDefined(this.m_mcmUiRoot) {
    return;
  };

  if !this.m_mcmUiLayout.descriptionVisible {
    this.McmUiCaptureFrameworkPreviewContent();
    this.m_mcmUiFrameworkPreviewHost.SetVisible(false);
    return;
  };

  this.m_mcmUiFrameworkPreviewHost.Reparent(this.m_mcmUiRoot);
}

@addMethod(SettingsMainGameController)
public final func McmUiBeginFrameworkPreviewHover() -> Void {
  if !this.McmUiHasFrameworkPreviewContext() {
    return;
  };

  let shouldSchedule: Bool = !this.m_mcmUiFrameworkPreviewHoverActive
    || !IsDefined(this.m_mcmUiFrameworkPreviewNormalizeProxy)
    || this.m_mcmUiFrameworkPreviewNormalizeProxy.IsFinished();
  if shouldSchedule {
    this.m_mcmUiFrameworkPreviewNormalizePass = 0;
  };
  this.m_mcmUiFrameworkPreviewHoverActive = true;
  this.McmUiNormalizeFrameworkPreview();
  if shouldSchedule {
    this.McmUiScheduleFrameworkPreviewNormalize(0.05);
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiScheduleFrameworkPreviewNormalize(delay: Float) -> Void {
  if !this.m_mcmUiFrameworkPreviewHoverActive
    || !IsDefined(this.m_mcmUiFrameworkPreviewHost) {
    return;
  };

  let opacity: Float = this.m_mcmUiFrameworkPreviewHost.GetOpacity();
  let timer: ref<inkAnimTransparency> = new inkAnimTransparency();
  timer.SetStartTransparency(opacity);
  timer.SetEndTransparency(opacity);
  timer.SetDuration(delay);

  let definition: ref<inkAnimDef> = new inkAnimDef();
  definition.AddInterpolator(timer);
  this.m_mcmUiFrameworkPreviewNormalizeProxy =
    this.m_mcmUiFrameworkPreviewHost.PlayAnimation(definition);
  this.m_mcmUiFrameworkPreviewNormalizeProxy.RegisterToCallback(
    inkanimEventType.OnFinish,
    this,
    n"McmUiOnFrameworkPreviewNormalize"
  );
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnFrameworkPreviewNormalize(
  proxy: ref<inkAnimProxy>
) -> Bool {
  if !this.m_mcmUiFrameworkPreviewHoverActive {
    return true;
  };

  this.McmUiNormalizeFrameworkPreview();
  this.m_mcmUiFrameworkPreviewNormalizePass += 1;
  if this.m_mcmUiFrameworkPreviewNormalizePass == 1 {
    this.McmUiScheduleFrameworkPreviewNormalize(0.15);
  } else {
    if this.m_mcmUiFrameworkPreviewNormalizePass == 2 {
      this.McmUiScheduleFrameworkPreviewNormalize(0.03);
    } else {
      if this.m_mcmUiFrameworkPreviewNormalizePass == 3 {
        this.McmUiScheduleFrameworkPreviewNormalize(0.17);
      };
    };
  };
  return true;
}

@addMethod(SettingsMainGameController)
public final func McmUiEndFrameworkPreviewHover() -> Void {
  this.m_mcmUiFrameworkPreviewHoverActive = false;
  if IsDefined(this.m_mcmUiFrameworkPreviewNormalizeProxy)
    && !this.m_mcmUiFrameworkPreviewNormalizeProxy.IsFinished() {
    this.m_mcmUiFrameworkPreviewNormalizeProxy.Stop();
  };
  this.m_mcmUiFrameworkPreviewNormalizeProxy = null;
}

@addMethod(SettingsMainGameController)
private final func McmUiFrameworkPreviewVisualSize(widget: wref<inkWidget>) -> Vector2 {
  let result: Vector2 = widget.GetDesiredSize();
  let ownSize: Vector2 = widget.GetSize();
  result.X = MaxF(result.X, ownSize.X);
  result.Y = MaxF(result.Y, ownSize.Y);

  let compound: wref<inkCompoundWidget> = widget as inkCompoundWidget;
  if !IsDefined(compound) {
    return result;
  };

  let index: Int32 = 0;
  while index < compound.GetNumChildren() {
    let childSize: Vector2 = this.McmUiFrameworkPreviewVisualSize(
      compound.GetWidgetByIndex(index)
    );
    result.X = MaxF(result.X, childSize.X);
    result.Y = MaxF(result.Y, childSize.Y);
    index += 1;
  };
  return result;
}

@addMethod(SettingsMainGameController)
private final func McmUiCaptureFrameworkPreviewContent() -> Void {
  if NotEquals(this.m_mcmUiFrameworkSurface, "native_settings")
    || !IsDefined(this.m_mcmUiFrameworkRoot)
    || !IsDefined(this.m_mcmUiFrameworkPreviewHost) {
    return;
  };

  let index: Int32 = this.m_mcmUiFrameworkRoot.GetNumChildren() - 1;
  while index >= 0 {
    let widget: wref<inkWidget> = this.m_mcmUiFrameworkRoot.GetWidgetByIndex(index);
    if IsDefined(widget)
      && NotEquals(widget.GetName(), n"wrapper")
      && NotEquals(widget.GetName(), n"mcm_framework_content_outer") {
      widget.SetVisible(false);
      widget.Reparent(this.m_mcmUiFrameworkPreviewHost);
    };
    index -= 1;
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiNormalizeFrameworkPreviewRoot(
  widget: wref<inkWidget>,
  width: Float,
  height: Float
) -> Void {
  let compound: wref<inkCompoundWidget> = widget as inkCompoundWidget;
  if !IsDefined(compound) {
    return;
  };

  let index: Int32 = 0;
  while index < compound.GetNumChildren() {
    let child: wref<inkWidget> = compound.GetWidgetByIndex(index);
    if IsDefined(child) {
      child.SetAnchor(inkEAnchor.TopLeft);
      child.SetAnchorPoint(new Vector2(0.0, 0.0));
      child.SetHAlign(inkEHorizontalAlign.Fill);
      child.SetVAlign(inkEVerticalAlign.Fill);
      child.SetSize(width, height);
      child.SetMargin(new inkMargin(0.0, 0.0, 0.0, 0.0));
      child.SetTranslation(new Vector2(0.0, 0.0));
    };
    index += 1;
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiNormalizeFrameworkPreview() -> Void {
  if !this.McmUiHasFrameworkPreviewContext() {
    return;
  };

  this.McmUiCaptureFrameworkPreviewContent();

  let sideInset: Float = MCMLayout.DescriptionPreviewSideInset();
  let topInset: Float = MCMLayout.DescriptionPreviewTopInset();
  let bottomInset: Float = MCMLayout.DescriptionPreviewBottomInset();
  let availableWidth: Float = this.m_mcmUiLayout.description.width
    - (sideInset * 2.0);
  let availableHeight: Float = this.m_mcmUiLayout.description.height
    - topInset - bottomInset;
  if availableWidth <= 0.0 || availableHeight <= 0.0 {
    return;
  };
  let index: Int32 = 0;
  while index < this.m_mcmUiFrameworkPreviewHost.GetNumChildren() {
    let widget: wref<inkWidget> = this.m_mcmUiFrameworkPreviewHost.GetWidgetByIndex(index);
    if IsDefined(widget) && NotEquals(widget.GetName(), n"mod_flex") {
      let size: Vector2 = this.McmUiFrameworkPreviewVisualSize(widget);

      if size.X > 0.0 && size.Y > 0.0 {
        let renderScale: Float = MinF(
          1.0,
          MinF(availableWidth / size.X, availableHeight / size.Y)
        );
        let renderedWidth: Float = size.X * renderScale;
        let renderedHeight: Float = size.Y * renderScale;
        let x: Float = MaxF(
          sideInset,
          (this.m_mcmUiLayout.description.width - renderedWidth) / 2.0
        );
        let y: Float = topInset + MaxF(0.0, (availableHeight - renderedHeight) / 2.0);
        widget.SetAnchorPoint(new Vector2(0.0, 0.0));
        widget.SetTranslation(new Vector2(0.0, 0.0));
        this.McmUiSetRect(widget, x, y, size.X, size.Y);
        this.McmUiNormalizeFrameworkPreviewRoot(widget, size.X, size.Y);
        widget.SetRenderTransformPivot(new Vector2(0.0, 0.0));
        widget.SetScale(new Vector2(renderScale, renderScale));
        widget.SetVisible(
          NotEquals(this.m_mcmUiFrameworkSurface, "native_settings")
            || this.m_mcmUiFrameworkPreviewNormalizePass >= 2
        );
      };
    };
    index += 1;
  };
}
