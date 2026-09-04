module ModConfigurationMenu.UI

@addMethod(SettingsMainGameController)
private final func McmUiBeginBase(
  title: String,
  subtitle: String,
  transientOwner: String
) -> wref<inkCanvas> {
  this.McmUiSetTransientOwner(transientOwner);
  this.McmUiResetRenderTree();
  this.m_mcmUiActive = true;
  this.m_mcmUiContentRow = 0;
  this.m_mcmUiContentOffset = 0.0;
  this.m_mcmUiSidebarRow = 0;
  let layoutSpec: ref<MCMLayoutSpec> = this.m_mcmUiPendingLayoutSpec;
  this.m_mcmUiPendingLayoutSpec = null;
  if !IsDefined(layoutSpec) {
    layoutSpec = MCMLayout.HostSpec(
      1920.0,
      1080.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      1.0,
      0,
      true,
      1,
      0
    );
  };
  this.m_mcmUiLayout = MCMLayout.Build(layoutSpec);
  if !MCMLayout.IsValid(this.m_mcmUiLayout) {
    this.m_mcmUiActive = false;
    return null;
  };
  this.m_mcmUiScale = this.m_mcmUiLayout.uniformScale;

  let host: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  if !IsDefined(host) {
    this.m_mcmUiActive = false;
    return null;
  };

  let container: wref<inkCanvas> = this.m_mcmUiContainerRoot;
  if !IsDefined(container) {
    let newContainer: ref<inkCanvas> = new inkCanvas();
    newContainer.SetName(n"MCMRedscriptRoot");
    newContainer.SetInteractive(true);
    newContainer.Reparent(host);
    newContainer.SetAnchorPoint(new Vector2(0.0, 0.0));
    newContainer.SetRenderTransformPivot(new Vector2(0.0, 0.0));
    this.m_mcmUiContainerRoot = newContainer;
    container = newContainer;
  };
  this.McmUiSetRect(
    container,
    this.m_mcmUiLayout.offsetX,
    this.m_mcmUiLayout.offsetY,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height
  );
  container.SetVisible(true);
  container.SetScale(new Vector2(this.m_mcmUiScale, this.m_mcmUiScale));

  let root: ref<inkCanvas> = new inkCanvas();
  root.SetName(n"MCMRenderRoot");
  root.SetInteractive(true);
  this.McmUiSetRect(
    root,
    this.m_mcmUiLayout.canvas.x,
    this.m_mcmUiLayout.canvas.y,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height
  );
  root.Reparent(container, 0);
  root.SetAnchorPoint(new Vector2(0.0, 0.0));
  root.SetRenderTransformPivot(new Vector2(0.0, 0.0));
  this.m_mcmUiRoot = root;

  this.McmUiCreateImage(
    root,
    n"background",
    this.m_mcmUiLayout.canvas.x,
    this.m_mcmUiLayout.canvas.y,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height,
    this.McmUiColorBackground(),
    this.McmUiIsGameplayEntry() ? 0.72 : 0.34,
    n"cell_bg"
  );
  if this.m_mcmUiLayout.frameVisible {
    // Keep the decorative frame outside the canonical canvas so it cannot consume workspace padding.
    this.McmUiCreateImage(
      root,
      n"scaled_frame_outer",
      -12.0,
      -12.0,
      this.m_mcmUiLayout.canvas.width + 24.0,
      this.m_mcmUiLayout.canvas.height + 24.0,
      this.McmUiColorSecondary(),
      0.62,
      n"cell_fg"
    );
    this.McmUiCreateImage(
      root,
      n"scaled_frame_inner",
      -8.0,
      -8.0,
      this.m_mcmUiLayout.canvas.width + 16.0,
      this.m_mcmUiLayout.canvas.height + 16.0,
      this.McmUiColorPrimary(),
      0.28,
      n"cell_fg"
    );
  };
  let titleText: ref<inkText> = this.McmUiCreateText(root, n"title", title, this.m_mcmUiLayout.headerTitle.x, this.m_mcmUiLayout.headerTitle.y, this.m_mcmUiLayout.headerTitle.width, this.m_mcmUiLayout.headerTitle.height, 44, this.McmUiColorPrimary(), textHorizontalAlignment.Left);
  this.McmUiCreateText(root, n"subtitle", subtitle, this.m_mcmUiLayout.headerSubtitle.x, this.m_mcmUiLayout.headerSubtitle.y, this.m_mcmUiLayout.headerSubtitle.width, this.m_mcmUiLayout.headerSubtitle.height, 24, this.McmUiColorMuted(), textHorizontalAlignment.Left);
  this.McmUiApplyHeadingStyle(titleText);
  return root;
}

@addMethod(SettingsMainGameController)
public final func McmUiSetHostViewport(
  hostWidth: Float,
  hostHeight: Float,
  safeLeft: Float,
  safeTop: Float,
  safeRight: Float,
  safeBottom: Float
) -> Void {
  this.m_mcmUiPendingLayoutSpec = MCMLayout.HostSpec(
    hostWidth,
    hostHeight,
    safeLeft,
    safeTop,
    safeRight,
    safeBottom,
    1.0,
    1.0,
    0,
    true,
    1,
    0
  );
}

@addMethod(SettingsMainGameController)
public final func McmUiConfigureLayout(
  hostDensity: Float,
  requestedScale: Float,
  requestedProfile: Int32,
  showDescription: Bool,
  bottomActionRows: Int32,
  sidebarActionRows: Int32
) -> Void {
  let hostSpec: ref<MCMLayoutSpec> = this.m_mcmUiPendingLayoutSpec;
  if !IsDefined(hostSpec) {
    hostSpec = MCMLayout.HostSpec(
      1920.0,
      1080.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      1.0,
      0,
      true,
      1,
      0
    );
  };
  this.m_mcmUiPendingLayoutSpec = MCMLayout.HostSpec(
    hostSpec.hostWidth,
    hostSpec.hostHeight,
    hostSpec.safeLeft,
    hostSpec.safeTop,
    hostSpec.safeRight,
    hostSpec.safeBottom,
    hostDensity,
    requestedScale,
    requestedProfile,
    showDescription,
    bottomActionRows,
    sidebarActionRows
  );
}

@addMethod(SettingsMainGameController)
public final func McmUiBeginOnboarding(
  title: String,
  subtitle: String,
  hostWidth: Float,
  hostHeight: Float,
  hostDensity: Float,
  requestedScale: Float,
  requestedProfile: Int32
) -> Void {
  this.m_mcmUiPendingLayoutSpec = MCMLayout.HostSpec(
    hostWidth,
    hostHeight,
    0.0,
    0.0,
    0.0,
    0.0,
    hostDensity,
    requestedScale,
    requestedProfile,
    false,
    1,
    0
  );
  this.McmUiBeginBase(
    title,
    subtitle,
    ""
  );
}

@addMethod(SettingsMainGameController)
public final func McmUiBegin(
  title: String,
  subtitle: String,
  sidebarTitle: String,
  contentTitle: String,
  status: String,
  statusKind: Int32,
  transientOwner: String,
  showSidebarSearch: Bool,
  showContentSearch: Bool,
  listSelectionMode: Int32
) -> Void {
  let root: wref<inkCanvas> = this.McmUiBeginBase(
    title,
    subtitle,
    transientOwner
  );
  if !IsDefined(root) {
    return;
  };
  this.m_mcmUiListSelectionMode = Clamp(listSelectionMode, 0, 1);

  let sidebarTitleWidth: Float = showSidebarSearch
    ? this.m_mcmUiLayout.sidebarSearch.x
      - this.m_mcmUiLayout.sidebarTitle.x - MCMLayout.SearchTitleGap()
    : this.m_mcmUiLayout.sidebarTitle.width - 40.0;
  let contentTitleWidth: Float = showContentSearch
    ? this.m_mcmUiLayout.contentSearch.x
      - this.m_mcmUiLayout.contentTitle.x - MCMLayout.SearchTitleGap()
    : this.m_mcmUiLayout.contentTitle.width;
  let sidebarTitleText: ref<inkText> = this.McmUiCreateText(root, n"sidebar_title", sidebarTitle, this.m_mcmUiLayout.sidebarTitle.x, this.m_mcmUiLayout.sidebarTitle.y, sidebarTitleWidth, this.m_mcmUiLayout.sidebarTitle.height, MCMLayout.PanelTitleFontSize(), this.McmUiColorSecondary(), textHorizontalAlignment.Left);
  this.m_mcmUiContentTitleText = this.McmUiCreateText(root, n"content_title", contentTitle, this.m_mcmUiLayout.contentTitle.x, this.m_mcmUiLayout.contentTitle.y, contentTitleWidth, this.m_mcmUiLayout.contentTitle.height, MCMLayout.PanelTitleFontSize(), this.McmUiColorText(), textHorizontalAlignment.Left);
  this.McmUiApplyHeadingStyle(sidebarTitleText);
  this.McmUiApplyHeadingStyle(this.m_mcmUiContentTitleText);

  let statusColor: CName = this.McmUiColorText();
  if statusKind == 1 {
    statusColor = this.McmUiColorSuccess();
  } else {
    if statusKind == 2 {
      statusColor = this.McmUiColorSecondary();
    };
  };
  this.m_mcmUiStatusText = this.McmUiCreateText(root, n"status", status, this.m_mcmUiLayout.status.x, this.m_mcmUiLayout.status.y, this.m_mcmUiLayout.status.width, this.m_mcmUiLayout.status.height, 23, statusColor, textHorizontalAlignment.Left);
}

@addMethod(SettingsMainGameController)
// Internal numeric readback keeps Lua free of profile coordinate tables.
public final func McmUiGetLayoutMetric(metric: Int32) -> Float {
  if !IsDefined(this.m_mcmUiLayout) {
    return -1.0;
  };
  if metric == 0 { return 1.0; };
  if metric == 1 { return Cast<Float>(this.m_mcmUiLayout.profile); };
  if metric == 2 { return this.m_mcmUiLayout.uniformScale; };
  if metric == 3 { return this.m_mcmUiLayout.offsetX; };
  if metric == 4 { return this.m_mcmUiLayout.offsetY; };
  if metric == 5 { return this.m_mcmUiLayout.canvas.width; };
  if metric == 6 { return this.m_mcmUiLayout.canvas.height; };
  if metric == 10 { return this.m_mcmUiLayout.sidebar.x; };
  if metric == 11 { return this.m_mcmUiLayout.sidebar.width; };
  if metric == 12 { return this.m_mcmUiLayout.sidebar.height; };
  if metric == 13 { return this.m_mcmUiLayout.sidebarInnerWidth; };
  if metric == 14 { return this.m_mcmUiLayout.sidebarRowHeight; };
  if metric == 20 { return this.m_mcmUiLayout.content.x; };
  if metric == 21 { return this.m_mcmUiLayout.content.width; };
  if metric == 22 { return this.m_mcmUiLayout.content.height; };
  if metric == 23 { return this.m_mcmUiLayout.contentInnerWidth; };
  if metric == 24 { return this.m_mcmUiLayout.contentRowHeight; };
  if metric == 25 { return this.m_mcmUiLayout.description.width; };
  if metric == 26 { return this.m_mcmUiLayout.description.height; };
  if metric == 27 { return this.m_mcmUiLayout.bottomActionY; };
  if metric == 28 { return this.m_mcmUiLayout.actionRightX; };
  if metric == 29 {
    return this.m_mcmUiLayout.modal.width - (MCMLayout.ModalPaddingX() * 2.0);
  };
  if metric == 30 { return MCMLayout.ContentMessageInsetX(); };
  if metric == 31 { return MCMLayout.ContentMessagePaddingY(); };
  if metric == 32 { return Cast<Float>(MCMLayout.ContentTextFontSize()); };
  if metric == 40 { return this.m_mcmUiLayout.topActionMinX; };
  if metric == 41 { return this.m_mcmUiLayout.topActionY; };
  if metric == 42 { return this.m_mcmUiLayout.topActionMaxWidth; };
  return -1.0;
}

@addMethod(SettingsMainGameController)
public final func McmUiSetContentTitle(value: String) -> Void {
  if IsDefined(this.m_mcmUiContentTitleText) {
    this.m_mcmUiContentTitleText.SetText(value);
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiBeginSidebar(
  contentHeight: Float,
  scrollPosition: Float
) -> Void {
  this.m_mcmUiSidebar = this.McmUiCreateScrollArea(
    this.m_mcmUiRoot,
    "mcm_sidebar_scroll",
    this.m_mcmUiLayout.sidebar.x,
    this.m_mcmUiLayout.sidebar.y,
    this.m_mcmUiLayout.sidebar.width,
    this.m_mcmUiLayout.sidebar.height,
    contentHeight
  );
  if IsDefined(this.m_mcmUiSidebar) && IsDefined(this.m_mcmUiSidebar.controller) {
    this.m_mcmUiSidebar.controller.SetScrollPosition(ClampF(scrollPosition, 0.0, 1.0));
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiAddSidebarItem(
  id: String,
  provider: String,
  label: String,
  description: String,
  selected: Bool,
  showProvider: Bool,
  showFavorite: Bool,
  favoriteActive: Bool,
  highlightFavorite: Bool,
  favoriteId: String,
  favoriteDescription: String,
  textScrollMode: Int32,
  textScrollActivation: Int32,
  textScrollSpeed: Float
) -> Void {
  if !IsDefined(this.m_mcmUiSidebar) || !IsDefined(this.m_mcmUiSidebar.content) {
    return;
  };
  let y: Float = Cast<Float>(this.m_mcmUiSidebarRow)
    * this.m_mcmUiLayout.sidebarRowHeight;
  let providerX: Float = 4.0;
  let favoriteX: Float = showProvider
    ? providerX + MCMLayout.LeftProviderWidth() + MCMLayout.LeftProviderGap()
    : providerX;
  let labelX: Float = showFavorite
    ? favoriteX + MCMLayout.LeftFavoriteWidth() + MCMLayout.LeftFavoriteGap()
    : favoriteX;
  if showProvider {
    this.McmUiCreateText(
      this.m_mcmUiSidebar.content,
      StringToName(id + "_provider"),
      provider,
      providerX,
      y,
      MCMLayout.LeftProviderWidth(),
      42.0,
      24,
      this.McmUiColorMuted(),
      textHorizontalAlignment.Left
    );
  };
  if showFavorite && StrLen(favoriteId) > 0 {
    let favoriteWidget: ref<inkCanvas> = new inkCanvas();
    favoriteWidget.SetName(StringToName(favoriteId + "_favorite"));
    favoriteWidget.SetInteractive(true);
    this.McmUiSetRect(
      favoriteWidget,
      favoriteX,
      y,
      MCMLayout.LeftFavoriteWidth(),
      42.0
    );
    favoriteWidget.Reparent(this.m_mcmUiSidebar.content);

    let favoriteImage: ref<inkImage> = new inkImage();
    favoriteImage.SetName(StringToName(favoriteId + "_favorite_image"));
    favoriteImage.SetAtlasResource(
      r"base\\gameplay\\gui\\common\\icons\\atlas_nameplate.inkatlas"
    );
    favoriteImage.SetTexturePart(n"icon_star");
    favoriteImage.SetInteractive(false);
    this.McmUiSetRect(favoriteImage, 3.0, 6.0, 27.0, 27.0);
    favoriteImage.Reparent(favoriteWidget);
    this.McmUiApplyFavoriteVisual(favoriteImage, favoriteActive, false);
    this.McmUiTrackAction(
      favoriteWidget,
      null,
      null,
      favoriteId,
      favoriteDescription,
      favoriteActive
    );
    this.McmUiTrackFavoriteVisual(favoriteWidget, favoriteImage, favoriteActive);
  };
  let actionWidget: ref<inkWidget> = this.McmUiCreateAction(
    this.m_mcmUiSidebar.content,
    id,
    label,
    description,
    labelX,
    y,
    this.m_mcmUiSidebar.width - labelX,
    42.0,
    selected,
    false
  );
  this.McmUiConfigureSidebarText(
    actionWidget,
    textScrollMode,
    textScrollActivation,
    textScrollSpeed
  );
  if highlightFavorite {
    this.McmUiMarkActionFavorite(actionWidget);
  };
  this.m_mcmUiSidebarRow += 1;
}

@addMethod(SettingsMainGameController)
public final func McmUiBeginContent(
  contentHeight: Float,
  scrollPosition: Float,
  contentReady: Bool
) -> Void {
  this.m_mcmUiContent = this.McmUiCreateScrollArea(
    this.McmUiFrameworkContentParent(),
    "mcm_content_scroll",
    this.m_mcmUiLayout.content.x,
    this.m_mcmUiLayout.content.y,
    this.m_mcmUiLayout.content.width,
    this.m_mcmUiLayout.content.height,
    contentHeight
  );
  if IsDefined(this.m_mcmUiContent) && IsDefined(this.m_mcmUiContent.controller) {
    this.m_mcmUiContent.controller.SetScrollPosition(ClampF(scrollPosition, 0.0, 1.0));
  };
  if IsDefined(this.m_mcmUiContent) && IsDefined(this.m_mcmUiContent.wrapper) {
    this.m_mcmUiContent.wrapper.SetVisible(contentReady);
  };
}

@addMethod(SettingsMainGameController)
private final func McmUiCurrentContentY() -> Float {
  return Cast<Float>(this.m_mcmUiContentRow) * this.m_mcmUiLayout.contentRowHeight
    + this.m_mcmUiContentOffset;
}

@addMethod(SettingsMainGameController)
private final func McmUiAdvanceContent() -> Void {
  this.m_mcmUiContentRow += 1;
}

@addMethod(SettingsMainGameController)
private final func McmUiAdvanceContentBy(height: Float) -> Void {
  this.m_mcmUiContentOffset += MaxF(height, 1.0)
    - this.m_mcmUiLayout.contentRowHeight;
  this.McmUiAdvanceContent();
}

@addMethod(SettingsMainGameController)
public final func McmUiAddCategory(
  id: String,
  label: String,
  description: String,
  frameworkId: String
) -> Void {
  if !IsDefined(this.m_mcmUiContent) || !IsDefined(this.m_mcmUiContent.content) {
    return;
  };
  let widget: wref<inkWidget> = this.SpawnFromLocal(
    this.m_mcmUiContent.content,
    n"settingsCategory"
  );
  if IsDefined(widget) {
    if Equals(this.m_mcmUiFrameworkSurface, "native_settings")
      && NotEquals(frameworkId, "") {
      widget.SetName(StringToName(frameworkId));
    };
    let controller: wref<SettingsCategoryController> = widget.GetController() as SettingsCategoryController;
    if IsDefined(controller) {
      controller.McmUiSetup(label);
    };
    this.McmUiSetNativeSettingsRowRect(
      widget,
      0.0,
      this.McmUiCurrentContentY(),
      this.m_mcmUiLayout.contentControlRight,
      this.m_mcmUiLayout.contentControlHeight
    );
  };
  this.McmUiAdvanceContent();
}

@addMethod(SettingsMainGameController)
public final func McmUiAddMessage(
  id: String,
  label: String,
  height: Float
) -> ref<inkRichTextBox> {
  if !IsDefined(this.m_mcmUiContent) || !IsDefined(this.m_mcmUiContent.content) {
    return null;
  };

  let insetX: Float = MCMLayout.ContentMessageInsetX();
  let paddingY: Float = MCMLayout.ContentMessagePaddingY();
  let width: Float = this.m_mcmUiLayout.contentControlRight - (insetX * 2.0);
  let rowHeight: Float = MaxF(height, this.m_mcmUiLayout.contentRowHeight);
  let richText: ref<inkRichTextBox> = new inkRichTextBox();
  richText.SetName(StringToName(id));
  richText.SetText(label);
  richText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  this.McmUiApplyThemeColor(richText, this.McmUiColorMuted());
  richText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  richText.SetFontStyle(n"Regular");
  richText.SetFontSize(MCMLayout.ContentTextFontSize());
  richText.SetHorizontalAlignment(textHorizontalAlignment.Left);
  richText.SetVerticalAlignment(textVerticalAlignment.Top);
  richText.SetFitToContent(true);
  richText.SetWrappingAtPosition(width);
  richText.SetInteractive(false);
  this.McmUiSetRect(
    richText,
    insetX,
    this.McmUiCurrentContentY() + paddingY,
    width,
    rowHeight - (paddingY * 2.0)
  );
  richText.Reparent(this.m_mcmUiContent.content);
  this.McmUiAdvanceContentBy(rowHeight);
  return richText;
}

@addMethod(SettingsMainGameController)
private final func McmUiPlaceNativeControl(
  widget: wref<inkWidget>,
  id: String,
  label: String,
  marker: String,
  modified: Bool
) -> Void {
  let y: Float = this.McmUiCurrentContentY();
  this.McmUiSetNativeSettingsRowRect(
    widget,
    0.0,
    y,
    this.m_mcmUiLayout.contentControlRight,
    this.m_mcmUiLayout.contentControlHeight
  );
  this.McmUiAddManagedLabel(id, label, marker, modified, y);
  this.McmUiAdvanceContent();
}

@addMethod(SettingsMainGameController)
public final func McmUiAddBool(
  id: String,
  label: String,
  description: String,
  value: Bool,
  marker: String,
  modified: Bool
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };
  let widget: wref<inkWidget> = this.SpawnFromLocal(
    this.m_mcmUiContent.content,
    n"settingsSelectorBool"
  );
  let controller: wref<SettingsSelectorControllerBool>;
  if IsDefined(widget) {
    controller = widget.GetController() as SettingsSelectorControllerBool;
  };
  if IsDefined(controller) {
    controller.McmUiConfigureBool(this, id, label, description, value, modified);
  };
  this.McmUiPlaceNativeControl(widget, id, label, marker, modified);
}

@addMethod(SettingsMainGameController)
public final func McmUiBeginSelect(
  id: String,
  label: String,
  description: String,
  index: Int32,
  marker: String,
  modified: Bool
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };
  let widget: wref<inkWidget> = this.SpawnFromLocal(
    this.m_mcmUiContent.content,
    n"settingsSelectorStringList"
  );
  if IsDefined(widget) {
    this.m_mcmUiPendingSelect = widget.GetController() as SettingsSelectorControllerListString;
  };
  if IsDefined(this.m_mcmUiPendingSelect) {
    this.m_mcmUiPendingSelect.McmUiBeginSelect(this, id, label, description, index, modified);
  };
  this.McmUiPlaceNativeControl(widget, id, label, marker, modified);
}

@addMethod(SettingsMainGameController)
public final func McmUiAddSelectOption(value: String) -> Void {
  if IsDefined(this.m_mcmUiPendingSelect) {
    this.m_mcmUiPendingSelect.McmUiAddSelectOption(value);
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiEndSelect() -> Void {
  if IsDefined(this.m_mcmUiPendingSelect) {
    this.m_mcmUiPendingSelect.McmUiFinishSelect();
  };
  this.m_mcmUiPendingSelect = null;
}

@addMethod(SettingsMainGameController)
public final func McmUiAddInt(
  id: String,
  label: String,
  description: String,
  value: Int32,
  minimum: Int32,
  maximum: Int32,
  step: Int32,
  marker: String,
  modified: Bool
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };
  let widget: wref<inkWidget> = this.SpawnFromLocal(
    this.m_mcmUiContent.content,
    n"settingsSelectorInt"
  );
  let controller: wref<SettingsSelectorControllerInt>;
  if IsDefined(widget) {
    controller = widget.GetController() as SettingsSelectorControllerInt;
  };
  if IsDefined(controller) {
    controller.McmUiConfigureInt(this, id, label, description, value, minimum, maximum, step, modified);
  };
  this.McmUiPlaceNativeControl(widget, id, label, marker, modified);
}

@addMethod(SettingsMainGameController)
public final func McmUiAddFloat(
  id: String,
  label: String,
  description: String,
  value: Float,
  minimum: Float,
  maximum: Float,
  step: Float,
  precision: Int32,
  marker: String,
  modified: Bool
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };
  let widget: wref<inkWidget> = this.SpawnFromLocal(
    this.m_mcmUiContent.content,
    n"settingsSelectorFloat"
  );
  let controller: wref<SettingsSelectorControllerFloat>;
  if IsDefined(widget) {
    controller = widget.GetController() as SettingsSelectorControllerFloat;
  };
  if IsDefined(controller) {
    controller.McmUiConfigureFloat(this, id, label, description, value, minimum, maximum, step, precision, modified);
  };
  this.McmUiPlaceNativeControl(widget, id, label, marker, modified);
}

@addMethod(SettingsMainGameController)
public final func McmUiAddKey(
  id: String,
  label: String,
  description: String,
  displayValue: String,
  marker: String,
  modified: Bool
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };
  let widget: wref<inkWidget> = this.SpawnFromLocal(
    this.m_mcmUiContent.content,
    n"settingsSelectorKeyBinding"
  );
  let controller: wref<SettingsSelectorControllerKeyBinding>;
  if IsDefined(widget) {
    controller = widget.GetController() as SettingsSelectorControllerKeyBinding;
  };
  if IsDefined(controller) {
    controller.McmUiConfigureKey(this, id, label, description, displayValue, modified);
  };
  this.McmUiPlaceNativeControl(widget, id, label, marker, modified);
}

@addMethod(SettingsMainGameController)
public final func McmUiAddActionSetting(
  id: String,
  label: String,
  description: String,
  value: String
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };
  let actionWidth: Float = 290.0;
  let actionX: Float = this.m_mcmUiLayout.contentControlRight - actionWidth;
  this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_label"),
    label,
    20.0,
    this.McmUiCurrentContentY(),
    actionX - 60.0,
    42.0,
    MCMLayout.ContentTextFontSize(),
    this.McmUiColorSecondary(),
    textHorizontalAlignment.Left
  );
  this.McmUiCreateAction(
    this.m_mcmUiContent.content,
    id,
    value,
    description,
    actionX,
    this.McmUiCurrentContentY(),
    actionWidth,
    this.m_mcmUiLayout.contentControlHeight,
    false,
    true
  );
  this.McmUiAdvanceContent();
}

@addMethod(SettingsMainGameController)
public final func McmUiAddReadonly(
  id: String,
  label: String,
  description: String,
  value: String
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };
  let valueWidth: Float = 360.0;
  let valueX: Float = this.m_mcmUiLayout.contentControlRight - valueWidth;
  this.McmUiCreateAction(
    this.m_mcmUiContent.content,
    id,
    label,
    description,
    20.0,
    this.McmUiCurrentContentY(),
    valueX - 70.0,
    42.0,
    false,
    false
  );
  this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_value"),
    value,
    valueX,
    this.McmUiCurrentContentY(),
    valueWidth,
    42.0,
    MCMLayout.ContentTextFontSize(),
    this.McmUiColorMuted(),
    textHorizontalAlignment.Right
  );
  this.McmUiAdvanceContent();
}

@addMethod(SettingsMainGameController)
public final func McmUiAddCustom(
  id: String,
  reservedHeight: Float,
  renderScale: Float
) -> ref<inkVerticalPanel> {
  if !IsDefined(this.m_mcmUiContent) || !IsDefined(this.m_mcmUiContent.content) {
    return null;
  };

  let scale: Float = ClampF(renderScale, 0.10, 4.00);
  let nativeReservedHeight: Float = MaxF(reservedHeight / scale, 1.0);
  let host: ref<inkVerticalPanel> = new inkVerticalPanel();
  host.SetName(StringToName(id + "_custom"));
  host.SetInteractive(false);
  host.SetFitToContent(false);
  host.SetHAlign(inkEHorizontalAlign.Left);
  host.SetVAlign(inkEVerticalAlign.Top);
  host.SetMargin(
    new inkMargin(
      this.m_mcmUiLayout.contentLabelX,
      this.McmUiCurrentContentY(),
      0.0,
      0.0
    )
  );
  host.SetSize(
    (this.m_mcmUiLayout.contentControlRight
      - this.m_mcmUiLayout.contentLabelX) / scale,
    nativeReservedHeight
  );
  host.SetRenderTransformPivot(new Vector2(0.0, 0.0));
  host.SetScale(new Vector2(scale, scale));
  host.Reparent(this.m_mcmUiContent.content);
  this.McmUiAdvanceContentBy(reservedHeight);
  return host;
}

@addMethod(SettingsMainGameController)
public final func McmUiIsCompactCustom(host: wref<inkWidget>) -> Bool {
  if !IsDefined(host) {
    return false;
  };

  let current: wref<inkWidget> = host;
  let depth: Int32 = 0;
  while depth < 8 {
    let compound: wref<inkCompoundWidget> = current as inkCompoundWidget;
    if !IsDefined(compound) {
      break;
    };
    if compound.GetNumChildren() != 1 {
      return false;
    };
    current = compound.GetWidgetByIndex(0);
    if !IsDefined(current) {
      return false;
    };
    depth += 1;
  };

  let rectangle: wref<inkRectangle> = current as inkRectangle;
  return IsDefined(rectangle);
}

@addMethod(SettingsMainGameController)
private final func McmUiMeasureCustomNode(widget: wref<inkWidget>) -> Float {
  if !IsDefined(widget) {
    return 0.0;
  };

  let contentHeight: Float = 0.0;
  let compound: wref<inkCompoundWidget> = widget as inkCompoundWidget;
  if IsDefined(compound) && compound.GetNumChildren() > 0 {
    let vertical: wref<inkVerticalPanel> = widget as inkVerticalPanel;
    let index: Int32 = 0;
    while index < compound.GetNumChildren() {
      let childHeight: Float = this.McmUiMeasureCustomNode(
        compound.GetWidgetByIndex(index)
      );
      if IsDefined(vertical) {
        contentHeight += childHeight;
      } else {
        contentHeight = MaxF(contentHeight, childHeight);
      };
      index += 1;
    };

    let padding: inkMargin = widget.GetPadding();
    contentHeight = MaxF(0.0, contentHeight + padding.top + padding.bottom);
  } else {
    let rectangle: wref<inkRectangle> = widget as inkRectangle;
    if IsDefined(rectangle) && widget.GetSize().Y > 0.0 {
      contentHeight = widget.GetSize().Y;
    } else {
      contentHeight = widget.GetDesiredSize().Y;
      if contentHeight <= 1.0 {
        contentHeight = widget.GetSize().Y;
      };

      let text: wref<inkText> = widget as inkText;
      if contentHeight <= 1.0 && IsDefined(text) {
        contentHeight = Cast<Float>(text.GetFontSize()) * 1.20;
      };
    };
  };

  let margin: inkMargin = widget.GetMargin();
  return MaxF(0.0, contentHeight + margin.top + margin.bottom);
}

@addMethod(SettingsMainGameController)
public final func McmUiMeasureCustom(
  host: wref<inkWidget>,
  renderScale: Float
) -> Float {
  if !IsDefined(host) {
    return 0.0;
  };

  let contentHeight: Float = 0.0;
  let compound: wref<inkCompoundWidget> = host as inkCompoundWidget;
  if IsDefined(compound) {
    let index: Int32 = 0;
    while index < compound.GetNumChildren() {
      contentHeight += this.McmUiMeasureCustomNode(
        compound.GetWidgetByIndex(index)
      );
      index += 1;
    };
  };
  return contentHeight * ClampF(renderScale, 0.10, 4.00);
}

@addMethod(SettingsMainGameController)
public final func McmUiAddPreview(
  id: String,
  label: String,
  currentValue: String,
  targetValue: String,
  status: String,
  nested: Bool
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };

  let y: Float = this.McmUiCurrentContentY();
  let labelX: Float = nested ? 54.0 : 20.0;
  let rightEdge: Float = this.m_mcmUiLayout.contentControlRight - 5.0;
  let targetWidth: Float = 185.0;
  let targetX: Float = rightEdge - targetWidth;
  let arrowWidth: Float = 30.0;
  let arrowX: Float = targetX - arrowWidth - 8.0;
  let currentWidth: Float = 185.0;
  let currentX: Float = arrowX - currentWidth - 8.0;
  let labelRight: Float = currentX - 8.0;
  let targetColor: CName = Equals(status, "matches") ? this.McmUiColorMuted() : this.McmUiColorPrimary();
  if Equals(status, "missing") || Equals(status, "invalid") || Equals(status, "unsupported") {
    targetColor = this.McmUiColorSecondary();
  };

  this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_label"),
    label,
    labelX,
    y,
    labelRight - labelX,
    42.0,
    MCMLayout.ContentTextFontSize(),
    nested ? this.McmUiColorMuted() : this.McmUiColorSecondary(),
    textHorizontalAlignment.Left
  );
  this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_current"),
    currentValue,
    currentX,
    y,
    currentWidth,
    42.0,
    MCMLayout.DescriptionFontSize(),
    this.McmUiColorMuted(),
    textHorizontalAlignment.Right
  );
  this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_arrow"),
    "->",
    arrowX,
    y,
    arrowWidth,
    42.0,
    MCMLayout.DescriptionFontSize(),
    this.McmUiColorMuted(),
    textHorizontalAlignment.Center
  );
  this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_target"),
    targetValue,
    targetX,
    y,
    targetWidth,
    42.0,
    MCMLayout.DescriptionFontSize(),
    targetColor,
    textHorizontalAlignment.Right
  );
  this.McmUiAdvanceContent();
}

@addMethod(SettingsMainGameController)
public final func McmUiAddCollectionEntry(
  id: String,
  label: String,
  summary: String,
  selected: Bool,
  alignSummaryLeft: Bool
) -> Void {
  if !IsDefined(this.m_mcmUiContent) {
    return;
  };

  let y: Float = this.McmUiCurrentContentY();
  let rightEdge: Float = this.m_mcmUiLayout.contentControlRight - 30.0;
  let summaryWidth: Float = alignSummaryLeft ? 360.0 : 230.0;
  let summaryX: Float = rightEdge - summaryWidth;
  let actionWidth: Float = summaryX - 20.0;
  this.McmUiCreateAction(
    this.m_mcmUiContent.content,
    id,
    label,
    summary,
    0.0,
    y,
    actionWidth,
    42.0,
    selected,
    false
  );
  this.McmUiCreateText(
    this.m_mcmUiContent.content,
    StringToName(id + "_summary"),
    summary,
    summaryX,
    y,
    summaryWidth,
    42.0,
    MCMLayout.DescriptionFontSize(),
    selected && this.McmUiListSelectionUsesText()
      ? this.McmUiColorPrimary()
      : this.McmUiColorMuted(),
    alignSummaryLeft ? textHorizontalAlignment.Left : textHorizontalAlignment.Right
  );
  this.McmUiAdvanceContent();
}

@addMethod(SettingsMainGameController)
public final func McmUiAddTopAction(
  id: String,
  label: String,
  x: Float,
  y: Float,
  width: Float,
  selected: Bool
) -> Void {
  if IsDefined(this.m_mcmUiRoot) {
    this.McmUiCreateAction(this.m_mcmUiRoot, id, label, "", x, y, width, 50.0, selected, true);
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiAddBottomAction(
  id: String,
  label: String,
  x: Float,
  width: Float,
  active: Bool
) -> Void {
  if IsDefined(this.m_mcmUiRoot) {
    this.McmUiCreateAction(this.m_mcmUiRoot, id, label, "", x, this.m_mcmUiLayout.bottomActionY, width, 46.0, active, true);
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiAddBottomActionAt(
  id: String,
  label: String,
  x: Float,
  y: Float,
  width: Float,
  active: Bool
) -> Void {
  if IsDefined(this.m_mcmUiRoot) {
    this.McmUiCreateAction(this.m_mcmUiRoot, id, label, "", x, y, width, 46.0, active, true);
  };
}
