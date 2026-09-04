module ModConfigurationMenu.UI

@addField(SettingsMainGameController)
private let m_mcmUiColorBackground: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorPanel: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorPanelSelected: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorPrimary: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorSecondary: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorSuccess: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorModified: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorFavorite: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorText: CName;

@addField(SettingsMainGameController)
private let m_mcmUiColorMuted: CName;

@addMethod(SettingsMainGameController)
public final func McmUiSetThemeColors(
  background: String,
  panel: String,
  panelSelected: String,
  primary: String,
  secondary: String,
  success: String,
  modified: String,
  favorite: String,
  text: String,
  muted: String
) -> Void {
  this.m_mcmUiColorBackground = StringToName(background);
  this.m_mcmUiColorPanel = StringToName(panel);
  this.m_mcmUiColorPanelSelected = StringToName(panelSelected);
  this.m_mcmUiColorPrimary = StringToName(primary);
  this.m_mcmUiColorSecondary = StringToName(secondary);
  this.m_mcmUiColorSuccess = StringToName(success);
  this.m_mcmUiColorModified = StringToName(modified);
  this.m_mcmUiColorFavorite = StringToName(favorite);
  this.m_mcmUiColorText = StringToName(text);
  this.m_mcmUiColorMuted = StringToName(muted);
}

@addMethod(SettingsMainGameController)
private final func McmUiColorBackground() -> CName {
  return NotEquals(this.m_mcmUiColorBackground, n"")
    ? this.m_mcmUiColorBackground
    : MCMColors.Background();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorPanel() -> CName {
  return NotEquals(this.m_mcmUiColorPanel, n"")
    ? this.m_mcmUiColorPanel
    : MCMColors.Panel();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorPanelSelected() -> CName {
  return NotEquals(this.m_mcmUiColorPanelSelected, n"")
    ? this.m_mcmUiColorPanelSelected
    : MCMColors.PanelSelected();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorPrimary() -> CName {
  return NotEquals(this.m_mcmUiColorPrimary, n"")
    ? this.m_mcmUiColorPrimary
    : MCMColors.Blue();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorSecondary() -> CName {
  return NotEquals(this.m_mcmUiColorSecondary, n"")
    ? this.m_mcmUiColorSecondary
    : MCMColors.Red();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorSuccess() -> CName {
  return NotEquals(this.m_mcmUiColorSuccess, n"")
    ? this.m_mcmUiColorSuccess
    : MCMColors.Success();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorModified() -> CName {
  return NotEquals(this.m_mcmUiColorModified, n"")
    ? this.m_mcmUiColorModified
    : MCMColors.Modified();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorFavorite() -> CName {
  return NotEquals(this.m_mcmUiColorFavorite, n"")
    ? this.m_mcmUiColorFavorite
    : MCMColors.Favorite();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorText() -> CName {
  return NotEquals(this.m_mcmUiColorText, n"")
    ? this.m_mcmUiColorText
    : MCMColors.Text();
}

@addMethod(SettingsMainGameController)
private final func McmUiColorMuted() -> CName {
  return NotEquals(this.m_mcmUiColorMuted, n"")
    ? this.m_mcmUiColorMuted
    : MCMColors.Muted();
}

@addMethod(SettingsMainGameController)
public final func McmUiStyleSelectProgress(
  track: wref<inkWidget>,
  marker: wref<inkWidget>
) -> Void {
  this.McmUiApplyThemeColor(track, n"MainColors.DarkRed");
  track.SetOpacity(0.80);
  this.McmUiApplyThemeColor(marker, this.McmUiColorPrimary());
  marker.SetOpacity(0.90);
}
