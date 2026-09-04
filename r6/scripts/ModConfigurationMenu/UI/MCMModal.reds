module ModConfigurationMenu.UI

@addMethod(SettingsMainGameController)
private final func McmUiModalX() -> Float {
  return this.m_mcmUiLayout.modal.x;
}

@addMethod(SettingsMainGameController)
private final func McmUiModalWidth() -> Float {
  return this.m_mcmUiLayout.modal.width;
}

@addMethod(SettingsMainGameController)
private final func McmUiModalMessageMaxHeight(hasInput: Bool) -> Float {
  return hasInput
    ? this.m_mcmUiLayout.modalInputMessageMaxHeight
    : this.m_mcmUiLayout.modalMessageMaxHeight;
}

@addMethod(SettingsMainGameController)
private final func McmUiModalColor(kind: String) -> CName {
  if Equals(kind, "info")
  || Equals(kind, "input")
  || Equals(kind, "collection")
  || Equals(kind, "setup") {
    return this.McmUiColorPrimary();
  };
  if Equals(kind, "success") {
    return this.McmUiColorSuccess();
  };
  return this.McmUiColorSecondary();
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateModalIcon(
  modal: wref<inkCompoundWidget>,
  kind: String,
  modalY: Float,
  color: CName
) -> Void {
  let atlas: ResRef =
    r"base\\gameplay\\gui\\widgets\\notifications\\notification_assets.inkatlas";
  let part: CName = n"ico_quest_new";
  let iconWidth: Float = 30.0;
  let iconHeight: Float = 18.0;
  if Equals(kind, "collection") {
    atlas =
      r"base\\gameplay\\gui\\fullscreen\\inventory\\atlas_inventory.inkatlas";
    part = n"icon_add";
    iconWidth = 24.0;
    iconHeight = 24.0;
  };
  if Equals(kind, "setup") {
    atlas =
      r"base\\gameplay\\gui\\fullscreen\\main_menu\\character_creation_randomization_optionsbuttonatlas.inkatlas";
    part = n"cogwheel";
    iconWidth = 24.0;
    iconHeight = 24.0;
  } else {
    if Equals(kind, "warning") {
      atlas = r"base\\gameplay\\gui\\fullscreen\\common\\fullscreen_elements.inkatlas";
      part = n"fluff_attention_fill";
      iconWidth = MCMLayout.ModalIconWidth();
      iconHeight = MCMLayout.ModalIconHeight();
    } else {
      if Equals(kind, "error") {
        atlas = r"base\\gameplay\\gui\\common\\icons\\atlas_common.inkatlas";
        part = n"ico_exclamation_circle2";
        iconWidth = 24.0;
        iconHeight = 25.0;
      } else {
        if Equals(kind, "success") {
          part = n"ico_quest_complete";
          iconWidth = 32.0;
          iconHeight = 18.0;
        } else {
          if Equals(kind, "input") {
            part = n"ico_quest_update";
            iconWidth = 22.0;
            iconHeight = 22.0;
          };
        };
      };
    };
  };

  let icon: ref<inkImage> = new inkImage();
  icon.SetName(n"modal_icon");
  icon.SetAtlasResource(atlas);
  icon.SetTexturePart(part);
  icon.SetFitToContent(false);
  this.McmUiApplyThemeColor(icon, color);
  icon.SetInteractive(false);
  this.McmUiSetRect(
    icon,
    this.McmUiModalX()
      + MCMLayout.ModalIconX()
      + ((MCMLayout.ModalIconWidth() - iconWidth) / 2.0),
    modalY
      + MCMLayout.ModalIconY()
      + ((MCMLayout.ModalIconHeight() - iconHeight) / 2.0),
    iconWidth,
    iconHeight
  );
  icon.Reparent(modal);

  this.McmUiCreateImage(
    modal,
    n"modal_title_separator",
    this.McmUiModalX() + MCMLayout.ModalTitleSeparatorX(),
    modalY + 12.0,
    2.0,
    36.0,
    color,
    0.72,
    n"cell_bg"
  );
}

@addMethod(SettingsMainGameController)
private final func McmUiCreateModalBase(
  title: String,
  message: String,
  requestedMessageHeight: Float,
  hasInput: Bool,
  kind: String
) -> Void {
  if !IsDefined(this.m_mcmUiRoot) {
    return;
  };

  if IsDefined(this.m_mcmUiModal) {
    this.m_mcmUiRoot.RemoveChild(this.m_mcmUiModal);
  };

  let modal: ref<inkCanvas> = new inkCanvas();
  modal.SetName(n"mcm_modal");
  modal.SetInteractive(true);
  this.McmUiSetRect(
    modal,
    this.m_mcmUiLayout.canvas.x,
    this.m_mcmUiLayout.canvas.y,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height
  );
  modal.Reparent(this.m_mcmUiRoot);
  this.m_mcmUiModal = modal;

  let messageHeight: Float = ClampF(
    requestedMessageHeight,
    MCMLayout.ModalMessageMinHeight(),
    this.McmUiModalMessageMaxHeight(hasInput)
  );
  let inputLocalY: Float = MCMLayout.ModalMessageY()
    + messageHeight
    + MCMLayout.ModalSectionGap();
  let actionLocalY: Float = hasInput
    ? inputLocalY + MCMLayout.ModalInputHeight() + MCMLayout.ModalSectionGap()
    : inputLocalY;
  let panelHeight: Float = actionLocalY
    + MCMLayout.ModalBottomPadding();
  let modalGroupHeight: Float = panelHeight
    + MCMLayout.ModalActionGap()
    + MCMLayout.ModalActionHeight();
  let modalY: Float = (this.m_mcmUiLayout.canvas.height - modalGroupHeight) / 2.0
    + this.m_mcmUiLayout.modalVerticalOffset;
  let modalColor: CName = this.McmUiModalColor(kind);
  this.m_mcmUiModalInputY = modalY + inputLocalY;
  this.m_mcmUiModalActionY = modalY + panelHeight + MCMLayout.ModalActionGap();

  this.McmUiCreateImage(
    modal,
    n"modal_scrim",
    0.0,
    0.0,
    this.m_mcmUiLayout.canvas.width,
    this.m_mcmUiLayout.canvas.height,
    this.McmUiColorBackground(),
    0.78,
    n"cell_bg"
  );
  this.McmUiCreateImage(
    modal,
    n"modal_panel",
    this.McmUiModalX(),
    modalY,
    this.McmUiModalWidth(),
    panelHeight,
    this.McmUiColorBackground(),
    0.97,
    n"cell_bg"
  );
  this.McmUiCreateImage(
    modal,
    n"modal_frame",
    this.McmUiModalX(),
    modalY,
    this.McmUiModalWidth(),
    panelHeight,
    modalColor,
    0.56,
    n"cell_fg"
  );
  this.McmUiCreateImage(
    modal,
    n"modal_title_accent",
    this.McmUiModalX(),
    modalY,
    MCMLayout.ModalTitleAccentWidth(),
    panelHeight,
    modalColor,
    1.0,
    n"cell_bg"
  );
  this.McmUiCreateModalIcon(modal, kind, modalY, modalColor);
  let modalTitle: ref<inkText> = this.McmUiCreateText(
    modal,
    n"modal_title",
    title,
    this.McmUiModalX() + MCMLayout.ModalTitleX(),
    modalY + MCMLayout.ModalTitleY(),
    this.McmUiModalWidth()
      - MCMLayout.ModalTitleX()
      - MCMLayout.ModalPaddingX(),
    MCMLayout.ModalTitleAccentHeight(),
    26,
    modalColor,
    textHorizontalAlignment.Left
  );
  this.McmUiApplyHeadingStyle(modalTitle);

  let richText: ref<inkRichTextBox> = new inkRichTextBox();
  richText.SetName(n"modal_message");
  richText.SetText(message);
  richText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  this.McmUiApplyThemeColor(richText, this.McmUiColorText());
  richText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  richText.SetFontStyle(n"Regular");
  richText.SetFontSize(21);
  richText.SetHorizontalAlignment(textHorizontalAlignment.Left);
  richText.SetVerticalAlignment(textVerticalAlignment.Top);
  richText.SetFitToContent(true);
  richText.SetWrappingAtPosition(
    this.McmUiModalWidth() - (MCMLayout.ModalPaddingX() * 2.0)
  );
  richText.SetInteractive(false);
  this.McmUiSetRect(
    richText,
    this.McmUiModalX() + MCMLayout.ModalPaddingX(),
    modalY + MCMLayout.ModalMessageY(),
    this.McmUiModalWidth() - (MCMLayout.ModalPaddingX() * 2.0),
    messageHeight
  );
  richText.Reparent(modal);
}

@addMethod(SettingsMainGameController)
private final func McmUiAddModalActions(
  confirmId: String,
  confirmLabel: String,
  confirmWidth: Float,
  cancelId: String,
  cancelLabel: String,
  cancelWidth: Float,
  cancelInputId: String
) -> Void {
  if !IsDefined(this.m_mcmUiModal) {
    return;
  };

  let availableWidth: Float = MaxF(
    1.0,
    this.McmUiModalWidth() - MCMLayout.ActionGap()
  );
  let resolvedConfirmWidth: Float = MaxF(1.0, confirmWidth);
  let resolvedCancelWidth: Float = MaxF(1.0, cancelWidth);
  let combinedWidth: Float = resolvedConfirmWidth + resolvedCancelWidth;
  if combinedWidth > availableWidth {
    let fitScale: Float = availableWidth / combinedWidth;
    resolvedConfirmWidth *= fitScale;
    resolvedCancelWidth *= fitScale;
  };

  let right: Float = this.McmUiModalX() + this.McmUiModalWidth();
  let y: Float = this.m_mcmUiModalActionY;
  let cancelX: Float = right - resolvedCancelWidth;
  let confirmX: Float = cancelX - MCMLayout.ActionGap() - resolvedConfirmWidth;
  this.McmUiCreateAction(
    this.m_mcmUiModal,
    confirmId,
    confirmLabel,
    "",
    confirmX,
    y,
    resolvedConfirmWidth,
    MCMLayout.ModalActionHeight(),
    true,
    true
  );
  this.McmUiCreateAction(
    this.m_mcmUiModal,
    cancelId,
    cancelLabel,
    "",
    cancelX,
    y,
    resolvedCancelWidth,
    MCMLayout.ModalActionHeight(),
    false,
    true
  );
  this.m_mcmUiModalCancelId = cancelInputId;
}

@addMethod(SettingsMainGameController)
public final func McmUiShowModal(
  title: String,
  message: String,
  messageHeight: Float,
  hasInput: Bool,
  kind: String
) -> Void {
  this.McmUiCreateModalBase(title, message, messageHeight, hasInput, kind);
}

@addMethod(SettingsMainGameController)
public final func McmUiSetModalActions(
  confirmId: String,
  confirmLabel: String,
  confirmWidth: Float,
  cancelId: String,
  cancelLabel: String,
  cancelWidth: Float
) -> Void {
  this.McmUiAddModalActions(
    confirmId,
    confirmLabel,
    confirmWidth,
    cancelId,
    cancelLabel,
    cancelWidth,
    cancelId
  );
}

@addMethod(SettingsMainGameController)
public final func McmUiSetChoiceModalActions(
  primaryId: String,
  primaryLabel: String,
  primaryWidth: Float,
  secondaryId: String,
  secondaryLabel: String,
  secondaryWidth: Float,
  escapeId: String
) -> Void {
  this.McmUiAddModalActions(
    primaryId,
    primaryLabel,
    primaryWidth,
    secondaryId,
    secondaryLabel,
    secondaryWidth,
    escapeId
  );
}

@addMethod(SettingsMainGameController)
public final func McmUiSetNoticeModalAction(
  actionId: String,
  label: String,
  width: Float
) -> Void {
  if !IsDefined(this.m_mcmUiModal) {
    return;
  };

  let resolvedWidth: Float = ClampF(width, 1.0, this.McmUiModalWidth());

  this.McmUiCreateAction(
    this.m_mcmUiModal,
    actionId,
    label,
    "",
    this.McmUiModalX() + this.McmUiModalWidth() - resolvedWidth,
    this.m_mcmUiModalActionY,
    resolvedWidth,
    MCMLayout.ModalActionHeight(),
    true,
    true
  );
  this.m_mcmUiModalCancelId = actionId;
}

@addMethod(SettingsMainGameController)
public final func McmUiShowModalTextInput(
  placeholder: String,
  value: String
) -> Void {
  this.McmUiShowTextInput(
    placeholder,
    value,
    this.McmUiModalX() + MCMLayout.ModalPaddingX(),
    this.m_mcmUiModalInputY,
    this.McmUiModalWidth() - (MCMLayout.ModalPaddingX() * 2.0)
  );
}

@addMethod(SettingsMainGameController)
public final func McmUiHideModal() -> Void {
  if !IsDefined(this.m_mcmUiModal) {
    return;
  };
  this.McmUiHideTextInput();
  if IsDefined(this.m_mcmUiModal) && IsDefined(this.m_mcmUiRoot) {
    this.m_mcmUiRoot.RemoveChild(this.m_mcmUiModal);
  };
  this.m_mcmUiModal = null;
  this.m_mcmUiModalCancelId = "";
  this.m_mcmUiModalInputY = 0.0;
  this.m_mcmUiModalActionY = 0.0;
}

@addMethod(SettingsMainGameController)
public final func McmUiSetDescription(text: String, contentHeight: Float, scrollPosition: Float) -> Void {
  if !IsDefined(this.m_mcmUiRoot) {
    return;
  };
  if IsDefined(this.m_mcmUiDescription) && IsDefined(this.m_mcmUiDescription.wrapper) {
    let descriptionParent: wref<inkCompoundWidget> = this.m_mcmUiDescription.wrapper.GetParentWidget() as inkCompoundWidget;
    if IsDefined(descriptionParent) {
      descriptionParent.RemoveChild(this.m_mcmUiDescription.wrapper);
    };
  };
  let wrapper: ref<inkCanvas> = new inkCanvas();
  wrapper.SetName(n"mcm_description_panel");
  wrapper.SetInteractive(false);
  this.McmUiSetRect(
    wrapper,
    this.m_mcmUiLayout.description.x,
    this.m_mcmUiLayout.description.y,
    this.m_mcmUiLayout.description.width,
    this.m_mcmUiLayout.description.height
  );
  wrapper.Reparent(this.m_mcmUiRoot);

  let viewport: ref<inkScrollArea> = new inkScrollArea();
  viewport.SetName(n"mcm_description_viewport");
  viewport.SetUseInternalMask(true);
  viewport.SetConstrainContentPosition(true);
  viewport.SetInteractive(false);
  this.McmUiSetRect(
    viewport,
    0.0,
    0.0,
    this.m_mcmUiLayout.description.width,
    this.m_mcmUiLayout.description.height
  );
  viewport.Reparent(wrapper);

  let content: ref<inkCanvas> = new inkCanvas();
  content.SetName(n"mcm_description_content");
  this.McmUiSetRect(
    content,
    0.0,
    0.0,
    this.m_mcmUiLayout.description.width,
    this.m_mcmUiLayout.description.height
  );
  content.Reparent(viewport);

  let panel: ref<MCMScrollAreaData> = new MCMScrollAreaData();
  panel.name = "mcm_description_panel";
  panel.wrapper = wrapper;
  panel.viewport = viewport;
  panel.content = content;
  panel.width = this.m_mcmUiLayout.description.width;
  panel.height = this.m_mcmUiLayout.description.height;
  this.m_mcmUiDescription = panel;

  let richText: ref<inkRichTextBox> = new inkRichTextBox();
  richText.SetName(n"description_text");
  richText.SetText(text);
  richText.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
  this.McmUiApplyThemeColor(richText, this.McmUiColorMuted());
  richText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
  richText.SetFontStyle(n"Regular");
  richText.SetFontSize(MCMLayout.DescriptionFontSize());
  richText.SetHorizontalAlignment(textHorizontalAlignment.Left);
  richText.SetVerticalAlignment(textVerticalAlignment.Top);
  richText.SetFitToContent(true);
  richText.SetWrappingAtPosition(this.m_mcmUiDescription.width - 32.0);
  richText.SetInteractive(false);
  this.McmUiSetRect(
    richText,
    16.0,
    12.0,
    this.m_mcmUiDescription.width - 32.0,
    this.m_mcmUiLayout.description.height - 24.0
  );
  richText.Reparent(this.m_mcmUiDescription.content);
  this.m_mcmUiDescriptionText = richText;
}

@addMethod(SettingsMainGameController)
public final func McmUiUpdateDescription(text: String, contentHeight: Float) -> Void {
  if IsDefined(this.m_mcmUiDescriptionText) {
    this.m_mcmUiDescriptionText.SetText(text);
    this.McmUiSetRect(
      this.m_mcmUiDescriptionText,
      16.0,
      12.0,
      this.m_mcmUiLayout.description.width - 32.0,
      this.m_mcmUiLayout.description.height - 24.0
    );
  };
}

@addMethod(SettingsMainGameController)
public final func McmUiGetSidebarScrollPosition() -> Float {
  return IsDefined(this.m_mcmUiSidebar) && IsDefined(this.m_mcmUiSidebar.controller)
    ? this.m_mcmUiSidebar.controller.GetScrollPosition()
    : 0.0;
}

@addMethod(SettingsMainGameController)
public final func McmUiGetContentScrollPosition() -> Float {
  return IsDefined(this.m_mcmUiContent) && IsDefined(this.m_mcmUiContent.controller)
    ? this.m_mcmUiContent.controller.GetScrollPosition()
    : 0.0;
}

@addMethod(SettingsMainGameController)
public final func McmUiGetDescriptionScrollPosition() -> Float {
  return 0.0;
}
