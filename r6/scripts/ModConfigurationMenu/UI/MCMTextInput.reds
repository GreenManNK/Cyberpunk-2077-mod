module ModConfigurationMenu.UI

import Codeware.UI.*
import Codeware.UI.TextInput.*

public class MCMTextInputControl extends HubTextInput {
  protected func CreateWidgets() -> Void {
    super.CreateWidgets();

    let fontSize: Int32 = MCMLayout.ModalInputFontSize();
    let inputHeight: Float = MCMLayout.ModalInputHeight();
    let verticalPadding: Float = (inputHeight - Cast<Float>(fontSize)) / 2.0 - 1.0;
    let text: ref<inkText> = this.m_root.GetWidgetByPath(
      inkWidgetPath.Build(n"viewport", n"content", n"text")
    ) as inkText;
    if IsDefined(text) {
      text.SetFontSize(fontSize);
    };
    this.m_root.SetHeight(inputHeight);
    this.m_wrapper.SetMargin(new inkMargin(18.0, verticalPadding, 18.0, 0.0));
  }

  public static func Create() -> ref<MCMTextInputControl> {
    let input: ref<MCMTextInputControl> = new MCMTextInputControl();
    input.CreateInstance();
    return input;
  }
}

public class MCMSearchInputControl extends HubTextInput {
  private let m_mcmPendingInputEvents: array<ref<inkKeyInputEvent>>;
  private let m_mcmInputQueueTick: ref<inkAnimProxy>;

  protected func CreateWidgets() -> Void {
    super.CreateWidgets();

    let fontSize: Int32 = MCMLayout.SearchInputFontSize();
    let inputHeight: Float = MCMLayout.SearchInputHeight();
    let verticalPadding: Float = (inputHeight - Cast<Float>(fontSize)) / 2.0 - 1.0;
    let text: ref<inkText> = this.m_root.GetWidgetByPath(
      inkWidgetPath.Build(n"viewport", n"content", n"text")
    ) as inkText;
    if IsDefined(text) {
      text.SetFontSize(fontSize);
    };
    this.m_root.SetHeight(inputHeight);
    this.m_wrapper.SetMargin(new inkMargin(14.0, verticalPadding, 14.0, 0.0));
    this.CreateMcmInputQueueTick();
  }

  protected func ApplyDisabledState() -> Void {
    // MCM owns the search root opacity; HubTextInput's initialization animation
    // would otherwise restore a newly attached field to full opacity.
  }

  private final func CreateMcmInputQueueTick() -> Void {
    let tick: ref<inkAnimTextValueProgress> = new inkAnimTextValueProgress();
    tick.SetStartProgress(0.0);
    tick.SetEndProgress(0.0);
    tick.SetDuration(1.0 / 60.0);
    let definition: ref<inkAnimDef> = new inkAnimDef();
    definition.AddInterpolator(tick);
    let options: inkAnimOptions;
    options.loopInfinite = true;
    options.loopType = inkanimLoopType.Cycle;
    this.m_mcmInputQueueTick = this.m_root.PlayAnimationWithOptions(definition, options);
    this.m_mcmInputQueueTick.RegisterToCallback(
      inkanimEventType.OnStartLoop,
      this,
      n"OnMcmInputQueueTick"
    );
  }

  protected func ProcessInputEvent(event: ref<inkKeyInputEvent>) -> Void {
    if this.m_measurer.IsMeasuring() || ArraySize(this.m_mcmPendingInputEvents) > 0 {
      ArrayPush(this.m_mcmPendingInputEvents, event);
      return;
    };
    super.ProcessInputEvent(event);
  }

  protected cb func OnMcmInputQueueTick(anim: ref<inkAnimProxy>) -> Bool {
    if !this.m_measurer.IsMeasuring() && ArraySize(this.m_mcmPendingInputEvents) > 0 {
      let event: ref<inkKeyInputEvent> = this.m_mcmPendingInputEvents[0];
      ArrayErase(this.m_mcmPendingInputEvents, 0);
      super.ProcessInputEvent(event);
    };
    return true;
  }

  public static func Create() -> ref<MCMSearchInputControl> {
    let input: ref<MCMSearchInputControl> = new MCMSearchInputControl();
    input.CreateInstance();
    return input;
  }

  public final func SetSearchText(value: String) -> Void {
    this.SetText(value);
    this.SetCaretPosition(UTF8StrLen(value));
  }

}

@addField(SettingsMainGameController)
private let m_mcmUiTextInput: ref<MCMTextInputControl>;

@addField(SettingsMainGameController)
private let m_mcmUiSidebarSearchInput: ref<MCMSearchInputControl>;

@addField(SettingsMainGameController)
private let m_mcmUiContentSearchInput: ref<MCMSearchInputControl>;

@addField(SettingsMainGameController)
private let m_mcmUiSearchRoot: wref<inkCanvas>;

@addMethod(SettingsMainGameController)
private final func McmUiEnsureSearchRoot() -> wref<inkCanvas> {
  if IsDefined(this.m_mcmUiSearchRoot) {
    return this.m_mcmUiSearchRoot;
  };
  if !IsDefined(this.m_mcmUiContainerRoot) {
    return null;
  };

  let root: ref<inkCanvas> = new inkCanvas();
  root.SetName(n"MCMSearchRoot");
  root.SetInteractive(false);
  this.McmUiSetRect(
    root,
    this.m_mcmUiLayout.canvas.x,
    this.m_mcmUiLayout.canvas.y,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height
  );
  root.Reparent(this.m_mcmUiContainerRoot);
  root.SetAnchorPoint(new Vector2(0.0, 0.0));
  root.SetRenderTransformPivot(new Vector2(0.0, 0.0));
  this.m_mcmUiSearchRoot = root;
  return root;
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateSearchInput(
  name: CName,
  placeholder: String,
  value: String,
  x: Float,
  y: Float,
  width: Float
) -> ref<MCMSearchInputControl> {
  let input: ref<MCMSearchInputControl> = MCMSearchInputControl.Create();
  input.SetName(name);
  input.SetDefaultText(placeholder);
  input.SetLetterCase(textLetterCase.OriginalCase);
  input.SetMaxLength(64);
  input.SetWidth(width);
  input.Reparent(this.m_mcmUiSearchRoot);
  let root: wref<inkWidget> = input.GetRootWidget();
  if IsDefined(root) {
    this.McmUiSetRect(
      root,
      x,
      y,
      width,
      MCMLayout.SearchInputHeight()
    );
    root.SetOpacity(MCMLayout.SearchInputInactiveOpacity());
  };
  if StrLen(value) > 0 {
    input.SetSearchText(value);
  };
  return input;
}

@addMethod(SettingsMainGameController)
private final func McmUiConfigureSearchInput(
  input: ref<MCMSearchInputControl>,
  placeholder: String,
  value: String,
  visible: Bool
) -> Void {
  if !IsDefined(input) {
    return;
  };

  input.SetDefaultText(placeholder);
  if !input.IsFocused() && NotEquals(input.GetText(), value) {
    input.SetSearchText(value);
  };
  let root: wref<inkWidget> = input.GetRootWidget();
  if IsDefined(root) {
    root.SetVisible(visible);
    root.SetOpacity(input.IsFocused() ? 1.0 : MCMLayout.SearchInputInactiveOpacity());
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiShowSearchInputs(
  sidebarPlaceholder: String,
  sidebarValue: String,
  contentPlaceholder: String,
  contentValue: String,
  showContentInput: Bool,
  focusContext: String
) -> Void {
  if !this.McmUiIsActive() || !IsDefined(this.McmUiEnsureSearchRoot()) {
    return;
  };

  this.m_mcmUiSearchRoot.SetVisible(true);
  if !IsDefined(this.m_mcmUiSidebarSearchInput) {
    this.m_mcmUiSidebarSearchInput = this.McmUiCreateSearchInput(
      n"mcmSidebarSearchInput",
      sidebarPlaceholder,
      sidebarValue,
      this.m_mcmUiLayout.sidebarSearch.x,
      this.m_mcmUiLayout.sidebarSearch.y,
      this.m_mcmUiLayout.sidebarSearch.width
    );
    this.m_mcmUiSidebarSearchInput.RegisterToCallback(
      n"OnInput",
      this,
      n"McmUiOnSidebarSearchInput"
    );
    this.m_mcmUiSidebarSearchInput.RegisterToCallback(
      n"OnFocusReceived",
      this,
      n"McmUiOnSidebarSearchFocusReceived"
    );
    this.m_mcmUiSidebarSearchInput.RegisterToCallback(
      n"OnFocusLost",
      this,
      n"McmUiOnSidebarSearchFocusLost"
    );
  };
  if showContentInput && !IsDefined(this.m_mcmUiContentSearchInput) {
    this.m_mcmUiContentSearchInput = this.McmUiCreateSearchInput(
      n"mcmContentSearchInput",
      contentPlaceholder,
      contentValue,
      this.m_mcmUiLayout.contentSearch.x,
      this.m_mcmUiLayout.contentSearch.y,
      this.m_mcmUiLayout.contentSearch.width
    );
    this.m_mcmUiContentSearchInput.RegisterToCallback(
      n"OnInput",
      this,
      n"McmUiOnContentSearchInput"
    );
    this.m_mcmUiContentSearchInput.RegisterToCallback(
      n"OnFocusReceived",
      this,
      n"McmUiOnContentSearchFocusReceived"
    );
    this.m_mcmUiContentSearchInput.RegisterToCallback(
      n"OnFocusLost",
      this,
      n"McmUiOnContentSearchFocusLost"
    );
  };

  this.McmUiConfigureSearchInput(
    this.m_mcmUiSidebarSearchInput,
    sidebarPlaceholder,
    sidebarValue,
    true
  );
  this.McmUiConfigureSearchInput(
    this.m_mcmUiContentSearchInput,
    contentPlaceholder,
    contentValue,
    showContentInput
  );
  if !showContentInput
    && IsDefined(this.m_mcmUiContentSearchInput)
    && this.m_mcmUiContentSearchInput.IsFocused() {
    this.RequestSetFocus(null);
  };

  if Equals(focusContext, "sidebar")
    && IsDefined(this.m_mcmUiSidebarSearchInput)
    && !this.m_mcmUiSidebarSearchInput.IsFocused() {
    this.RequestSetFocus(this.m_mcmUiSidebarSearchInput.GetRootWidget());
  } else {
    if Equals(focusContext, "content")
      && IsDefined(this.m_mcmUiContentSearchInput)
      && !this.m_mcmUiContentSearchInput.IsFocused() {
      this.RequestSetFocus(this.m_mcmUiContentSearchInput.GetRootWidget());
    };
  };
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnSidebarSearchInput(widget: wref<inkWidget>) -> Bool {
  if this.McmUiIsActive() && IsDefined(this.m_mcmUiSidebarSearchInput) {
    this.McmUiEmitSearch("sidebar", this.m_mcmUiSidebarSearchInput.GetText());
  };
  return true;
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnContentSearchInput(widget: wref<inkWidget>) -> Bool {
  if this.McmUiIsActive() && IsDefined(this.m_mcmUiContentSearchInput) {
    this.McmUiEmitSearch("content", this.m_mcmUiContentSearchInput.GetText());
  };
  return true;
}

@addMethod(SettingsMainGameController)
private final func McmUiSetSearchFocus(context: String, focused: Bool) -> Void {
  let root: wref<inkWidget>;
  if Equals(context, "sidebar") && IsDefined(this.m_mcmUiSidebarSearchInput) {
    root = this.m_mcmUiSidebarSearchInput.GetRootWidget();
  } else {
    if Equals(context, "content") && IsDefined(this.m_mcmUiContentSearchInput) {
      root = this.m_mcmUiContentSearchInput.GetRootWidget();
    };
  };
  if IsDefined(root) {
    root.SetOpacity(focused ? 1.0 : MCMLayout.SearchInputInactiveOpacity());
  };
  if this.McmUiIsActive() {
    this.McmUiEmitSearchFocus(context, focused);
  };
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnSidebarSearchFocusReceived(event: ref<inkEvent>) -> Bool {
  this.McmUiSetSearchFocus("sidebar", true);
  return true;
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnSidebarSearchFocusLost(event: ref<inkEvent>) -> Bool {
  this.McmUiSetSearchFocus("sidebar", false);
  return true;
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnContentSearchFocusReceived(event: ref<inkEvent>) -> Bool {
  this.McmUiSetSearchFocus("content", true);
  return true;
}

@addMethod(SettingsMainGameController)
protected cb func McmUiOnContentSearchFocusLost(event: ref<inkEvent>) -> Bool {
  this.McmUiSetSearchFocus("content", false);
  return true;
}

@addMethod(SettingsMainGameController)
public final func McmUiHideSearchInputs() -> Void {
  if IsDefined(this.m_mcmUiSidebarSearchInput)
    && this.m_mcmUiSidebarSearchInput.IsFocused() {
    this.RequestSetFocus(null);
  } else {
    if IsDefined(this.m_mcmUiContentSearchInput)
      && this.m_mcmUiContentSearchInput.IsFocused() {
      this.RequestSetFocus(null);
    };
  };
  if IsDefined(this.m_mcmUiSearchRoot) {
    this.m_mcmUiSearchRoot.SetVisible(false);
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiDestroySearchInputs() -> Void {
  this.McmUiHideSearchInputs();
  if IsDefined(this.m_mcmUiSearchRoot) {
    let parent: wref<inkCompoundWidget> = this.m_mcmUiSearchRoot.GetParentWidget()
      as inkCompoundWidget;
    if IsDefined(parent) {
      parent.RemoveChild(this.m_mcmUiSearchRoot);
    };
  };
  this.m_mcmUiSearchRoot = null;
  this.m_mcmUiSidebarSearchInput = null;
  this.m_mcmUiContentSearchInput = null;
}

@addMethod(SettingsMainGameController)
private final func McmUiIsSearchInputWidget(widget: wref<inkWidget>) -> Bool {
  let current: wref<inkWidget> = widget;
  while IsDefined(current) {
    if Equals(current.GetName(), n"mcmSidebarSearchInput")
      || Equals(current.GetName(), n"mcmContentSearchInput") {
      return true;
    };
    current = current.GetParentWidget();
  };
  return false;
}

@addMethod(SettingsMainGameController)
private final func McmUiHasFocusedSearchInput() -> Bool {
  return (IsDefined(this.m_mcmUiSidebarSearchInput)
      && this.m_mcmUiSidebarSearchInput.IsFocused())
    || (IsDefined(this.m_mcmUiContentSearchInput)
      && this.m_mcmUiContentSearchInput.IsFocused());
}

@addMethod(SettingsMainGameController)
public final func McmUiBlurSearchInputsOnPointer(event: ref<inkPointerEvent>) -> Void {
  if !event.IsAction(n"click")
    || !this.McmUiHasFocusedSearchInput() {
    return;
  };

  let target: wref<inkWidget> = event.GetTarget();
  if !this.McmUiIsSearchInputWidget(target) {
    this.RequestSetFocus(null);
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiShowTextInput(
  placeholder: String,
  value: String,
  x: Float,
  y: Float,
  width: Float
) -> Void {
  if !this.McmUiIsActive() || !IsDefined(this.m_mcmUiModal) {
    return;
  };

  this.McmUiHideTextInput();

  let input: ref<MCMTextInputControl> = MCMTextInputControl.Create();
  this.m_mcmUiTextInput = input;
  input.SetName(n"mcmTextInput");
  input.SetDefaultText(placeholder);
  input.SetMaxLength(64);
  input.Reparent(this.m_mcmUiModal);
  input.SetWidth(width);
  let root: wref<inkWidget> = input.GetRootWidget();
  if IsDefined(root) {
    this.McmUiSetRect(root, x, y, width, MCMLayout.ModalInputHeight());
  };
  if StrLen(value) > 0 {
    input.SetText(value);
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiGetTextInputText() -> String {
  if IsDefined(this.m_mcmUiTextInput) {
    return this.m_mcmUiTextInput.GetText();
  };
  return "";
}

@addMethod(SettingsMainGameController)
public final func McmUiFocusTextInput() -> Void {
  if IsDefined(this.m_mcmUiTextInput) {
    this.RequestSetFocus(this.m_mcmUiTextInput.GetRootWidget());
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiHideTextInput() -> Void {
  if !IsDefined(this.m_mcmUiTextInput) {
    return;
  };

  let root: wref<inkWidget> = this.m_mcmUiTextInput.GetRootWidget();
  if IsDefined(root) {
    root.SetVisible(false);
    let parent: wref<inkCompoundWidget> = root.GetParentWidget() as inkCompoundWidget;
    if IsDefined(parent) {
      parent.RemoveChild(root);
    };
  };
  this.m_mcmUiTextInput = null;
}
