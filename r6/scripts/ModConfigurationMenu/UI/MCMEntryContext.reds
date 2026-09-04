module ModConfigurationMenu.UI

@addField(SettingsMainGameController)
private let m_mcmUiGameplayEntry: Bool;

@addMethod(SettingsMainGameController)
public final func McmUiSetGameplayEntry(value: Bool) -> Void {
  this.m_mcmUiGameplayEntry = value;
}

@addMethod(SettingsMainGameController)
public final func McmUiIsGameplayEntry() -> Bool {
  return this.m_mcmUiGameplayEntry;
}
