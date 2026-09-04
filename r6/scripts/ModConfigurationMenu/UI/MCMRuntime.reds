module ModConfigurationMenu.UI

@addMethod(SettingsMainGameController)
private final func McmUiResetRenderTree() -> Void {
  this.McmUiHideTextInput();
  this.McmUiStopAllSidebarTextMotion();
  this.McmUiResetTextMeasurementPass();
  this.m_mcmUiActive = false;
  if IsDefined(this.m_mcmUiRoot) {
    this.m_mcmUiRoot.SetVisible(false);
    let rootParent: wref<inkCompoundWidget> = this.m_mcmUiRoot.GetParentWidget() as inkCompoundWidget;
    if IsDefined(rootParent) {
      rootParent.RemoveChild(this.m_mcmUiRoot);
    };
  };
  this.m_mcmUiRoot = null;
  this.McmUiDiscardFirstPaintStage();
  this.m_mcmUiSidebar = null;
  this.m_mcmUiContent = null;
  this.m_mcmUiDescription = null;
  this.m_mcmUiDescriptionText = null;
  this.m_mcmUiStatusText = null;
  this.m_mcmUiContentTitleText = null;
  this.m_mcmUiListSelectionMode = 0;
  this.m_mcmUiFrameworkSurface = "";
  this.McmUiEndFrameworkPreviewHover();
  this.m_mcmUiFrameworkRoot = null;
  this.m_mcmUiFrameworkContentOuter = null;
  this.m_mcmUiFrameworkContentInner = null;
  this.m_mcmUiFrameworkPreviewHost = null;
  this.m_mcmUiPendingSelect = null;
  this.m_mcmUiModal = null;
  this.m_mcmUiModalCancelId = "";
  this.m_mcmUiModalInputY = 0.0;
  this.m_mcmUiModalActionY = 0.0;
  ArrayClear(this.m_mcmUiActionWidgets);
  ArrayClear(this.m_mcmUiActionIds);
  ArrayClear(this.m_mcmUiActionDescriptions);
  ArrayClear(this.m_mcmUiActionLabels);
  ArrayClear(this.m_mcmUiActionFrames);
  ArrayClear(this.m_mcmUiActionSelected);
  ArrayClear(this.m_mcmUiActionSidebarText);
  ArrayClear(this.m_mcmUiActionFavoriteLabels);
  ArrayClear(this.m_mcmUiFavoriteWidgets);
  ArrayClear(this.m_mcmUiFavoriteImages);
  ArrayClear(this.m_mcmUiFavoriteActive);
  ArrayClear(this.m_mcmUiManagedLabelIds);
  ArrayClear(this.m_mcmUiManagedLabels);
  ArrayClear(this.m_mcmUiManagedMarkers);
  ArrayClear(this.m_mcmUiManagedLabelModified);
  ArrayClear(this.m_mcmUiScrollWidgets);
  ArrayClear(this.m_mcmUiScrollHitSurfaces);
  ArrayClear(this.m_mcmUiScrollControllers);
}

@addMethod(SettingsMainGameController)
private final func McmUiHasWidget(
  widgets: array<wref<inkWidget>>,
  widget: wref<inkWidget>
) -> Bool {
  let index: Int32 = 0;
  while index < ArraySize(widgets) {
    if Equals(widgets[index], widget) {
      return true;
    };
    index += 1;
  };
  return false;
}

@addMethod(SettingsMainGameController)
private final func McmUiClearTransientWidgets() -> Void {
  let index: Int32 = ArraySize(this.m_mcmUiTransientWidgets) - 1;
  while index >= 0 {
    let widget: wref<inkWidget> = this.m_mcmUiTransientWidgets[index];
    if IsDefined(widget) {
      let parent: wref<inkCompoundWidget> = widget.GetParentWidget() as inkCompoundWidget;
      if IsDefined(parent) {
        parent.RemoveChild(widget);
      };
    };
    index -= 1;
  };
  ArrayClear(this.m_mcmUiTransientWidgets);
}

@addMethod(SettingsMainGameController)
private final func McmUiSetTransientOwner(owner: String) -> Void {
  if NotEquals(this.m_mcmUiTransientOwner, owner) {
    this.McmUiClearTransientWidgets();
    this.m_mcmUiTransientOwner = owner;
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiBeginExternalMutation() -> Void {
  ArrayClear(this.m_mcmUiMutationSnapshot);
  let host: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  if !IsDefined(host) {
    return;
  };
  this.McmUiSnapshotExternalTree(host);
}

@addMethod(SettingsMainGameController)
private final func McmUiSnapshotExternalTree(parent: wref<inkCompoundWidget>) -> Void {
  let index: Int32 = 0;
  while index < parent.GetNumChildren() {
    let widget: wref<inkWidget> = parent.GetWidgetByIndex(index);
    if IsDefined(widget) && NotEquals(widget.GetName(), n"MCMRedscriptRoot") {
      ArrayPush(this.m_mcmUiMutationSnapshot, widget);
      let compound: wref<inkCompoundWidget> = widget as inkCompoundWidget;
      if IsDefined(compound) {
        this.McmUiSnapshotExternalTree(compound);
      };
    };
    index += 1;
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiEndExternalMutation() -> Void {
  let host: wref<inkCompoundWidget> = this.GetRootCompoundWidget();
  if !IsDefined(host) {
    ArrayClear(this.m_mcmUiMutationSnapshot);
    return;
  };
  this.McmUiCollectExternalAdditions(host);
  ArrayClear(this.m_mcmUiMutationSnapshot);
}

@addMethod(SettingsMainGameController)
private final func McmUiCollectExternalAdditions(parent: wref<inkCompoundWidget>) -> Void {
  let index: Int32 = 0;
  while index < parent.GetNumChildren() {
    let widget: wref<inkWidget> = parent.GetWidgetByIndex(index);
    if IsDefined(widget) && NotEquals(widget.GetName(), n"MCMRedscriptRoot") {
      if !this.McmUiHasWidget(this.m_mcmUiMutationSnapshot, widget) {
        if !this.McmUiHasWidget(this.m_mcmUiTransientWidgets, widget) {
          ArrayPush(this.m_mcmUiTransientWidgets, widget);
        };
      } else {
        let compound: wref<inkCompoundWidget> = widget as inkCompoundWidget;
        if IsDefined(compound) {
          this.McmUiCollectExternalAdditions(compound);
        };
      };
    };
    index += 1;
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiRemove() -> Void {
  this.McmUiClearTransientWidgets();
  ArrayClear(this.m_mcmUiMutationSnapshot);
  this.m_mcmUiTransientOwner = "";
  this.McmUiResetRenderTree();
  this.McmUiClearTextMeasurementCache();
  this.McmUiResetFirstPaintState();
  this.McmUiDestroySearchInputs();
  if IsDefined(this.m_mcmUiContainerRoot) {
    this.m_mcmUiContainerRoot.SetVisible(false);
    let rootParent: wref<inkCompoundWidget> = this.m_mcmUiContainerRoot.GetParentWidget()
      as inkCompoundWidget;
    if IsDefined(rootParent) {
      rootParent.RemoveChild(this.m_mcmUiContainerRoot);
    };
  };
  this.m_mcmUiContainerRoot = null;
}

@wrapMethod(SettingsMainGameController)
protected cb func OnButtonRelease(event: ref<inkPointerEvent>) -> Bool {
  if this.McmUiIsActive() {
    this.McmUiBlurSearchInputsOnPointer(event);
    if IsDefined(this.m_mcmUiModal)
      && NotEquals(this.m_mcmUiModalCancelId, "")
      && event.IsAction(n"cancel") {
      this.McmUiEmitAction(this.m_mcmUiModalCancelId);
      return true;
    };
    if event.IsAction(n"restore_default_settings") {
      return true;
    };
    if event.IsAction(n"cancel") {
      this.McmUiEmitClosing();
      if this.m_mcmUiCloseBlocked {
        return true;
      };
    };
    return false;
  };
  return wrappedMethod(event);
}
