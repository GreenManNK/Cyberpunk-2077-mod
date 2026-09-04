module ModConfigurationMenu.UI

@addField(MenuScenario_PauseMenu)
private let m_mcmUiGameplaySettingsEntry: Bool;

@wrapMethod(MenuScenario_PauseMenu)
protected cb func OnEnterScenario(prevScenario: CName, userData: ref<IScriptable>) -> Bool {
  let entrySystem: ref<MCMSettingsEntrySystem> = MCMSettingsEntrySystem.Get(GetGameInstance());
  this.m_mcmUiGameplaySettingsEntry = IsDefined(entrySystem)
    && entrySystem.IsGameplayEntryActive();

  // Let vanilla establish the complete pause host first: it opens both the
  // background and pause menu, enables menu mode, and pauses simulation.
  let result: Bool = wrappedMethod(prevScenario, userData);
  if this.m_mcmUiGameplaySettingsEntry {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(GetGameInstance());
    entrySystem.SetStage(2);
    if entrySystem.IsReady() && IsDefined(uiSystem) {
      uiSystem.QueueMenuEvent(n"OnMcmUiReadySettings");
    };
  };
  return result;
}

@addMethod(MenuScenario_PauseMenu)
protected cb func OnMcmUiReadySettings() -> Bool {
  if this.m_mcmUiGameplaySettingsEntry {
    let entrySystem: ref<MCMSettingsEntrySystem> = MCMSettingsEntrySystem.Get(GetGameInstance());
    if IsDefined(entrySystem)
      && entrySystem.IsGameplayEntryActive()
      && entrySystem.IsReady()
      && entrySystem.GetStage() < 3 {
      entrySystem.SetStage(3);
      this.SwitchMenu(n"settings_main");
    };
  };
}

@addMethod(MenuScenario_PauseMenu)
protected cb func OnMcmUiCancelSettingsEntry() -> Bool {
  if this.m_mcmUiGameplaySettingsEntry {
    this.m_mcmUiGameplaySettingsEntry = false;
    this.GotoIdleState();
  };
}

@wrapMethod(MenuScenario_PauseMenu)
protected cb func OnCloseSettingsScreen() -> Bool {
  if this.m_mcmUiGameplaySettingsEntry {
    this.m_mcmUiGameplaySettingsEntry = false;
    let entrySystem: ref<MCMSettingsEntrySystem> = MCMSettingsEntrySystem.Get(GetGameInstance());
    if IsDefined(entrySystem) {
      entrySystem.Finish();
    };
    this.GotoIdleState();
    return true;
  };

  return wrappedMethod();
}

@wrapMethod(PauseMenuBackgroundGameController)
protected cb func OnInitialize() -> Bool {
  let result: Bool = wrappedMethod();
  let entrySystem: ref<MCMSettingsEntrySystem> = MCMSettingsEntrySystem.Get(GetGameInstance());
  if IsDefined(entrySystem) && entrySystem.IsGameplayEntryActive() {
    entrySystem.AttachPauseBackground(this.GetRootWidget());
  };
  return result;
}

@wrapMethod(PauseMenuBackgroundGameController)
protected cb func OnUninitialize() -> Bool {
  let entrySystem: ref<MCMSettingsEntrySystem> = MCMSettingsEntrySystem.Get(GetGameInstance());
  if IsDefined(entrySystem) && entrySystem.IsGameplayEntryActive() {
    entrySystem.Finish();
  };
  return wrappedMethod();
}

public class MCMSettingsEntrySystem extends ScriptableSystem {
  private let m_ready: Bool;

  private let m_gameplayEntryActive: Bool;

  private let m_stage: Int32;

  private let m_pauseBackgroundRoot: wref<inkWidget>;

  private let m_pauseBackgroundRootWasVisible: Bool;

  public static func Get(gameInstance: GameInstance) -> ref<MCMSettingsEntrySystem> {
    return GameInstance.GetScriptableSystemsContainer(gameInstance)
      .Get(n"ModConfigurationMenu.UI.MCMSettingsEntrySystem") as MCMSettingsEntrySystem;
  }

  private final func SpawnInGameMenuEvent(eventName: CName) -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGameInstance());
    if !IsDefined(blackboardSystem) {
      return false;
    };
    let definition: ref<MenuEventBlackboardDef> = GetAllBlackboardDefs().MenuEventBlackboard;
    if !IsDefined(definition) {
      return false;
    };
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(definition);
    if !IsDefined(blackboard) {
      return false;
    };
    blackboard.SetName(definition.MenuEventToTrigger, eventName, true);
    return true;
  }

  public func Open() -> Int32 {
    this.m_gameplayEntryActive = true;
    this.m_stage = 1;
    if !this.SpawnInGameMenuEvent(n"OnOpenPauseMenu") {
      this.Finish();
      return 1;
    };
    return 0;
  }

  private final func RestorePauseBackground() -> Void {
    if IsDefined(this.m_pauseBackgroundRoot) {
      this.m_pauseBackgroundRoot.SetVisible(this.m_pauseBackgroundRootWasVisible);
    };
    this.m_pauseBackgroundRoot = null;
    this.m_pauseBackgroundRootWasVisible = false;
  }

  public func AttachPauseBackground(root: wref<inkWidget>) -> Void {
    this.RestorePauseBackground();
    this.m_pauseBackgroundRoot = root;
    if IsDefined(root) {
      this.m_pauseBackgroundRootWasVisible = root.IsVisible();
      root.SetVisible(false);
    };
  }

  public func Ready() -> Int32 {
    this.m_ready = true;
    if this.m_gameplayEntryActive && !this.SpawnInGameMenuEvent(n"OnMcmUiReadySettings") {
      return 1;
    };
    return 0;
  }

  public func Cancel() -> Void {
    let wasActive: Bool = this.m_gameplayEntryActive;
    this.RestorePauseBackground();
    this.m_ready = false;
    this.m_gameplayEntryActive = false;
    this.m_stage = 0;
    if wasActive {
      this.SpawnInGameMenuEvent(n"OnMcmUiCancelSettingsEntry");
    };
  }

  public func Finish() -> Void {
    this.RestorePauseBackground();
    this.m_ready = false;
    this.m_gameplayEntryActive = false;
    this.m_stage = 0;
  }

  public func IsReady() -> Bool {
    return this.m_ready;
  }

  public func IsGameplayEntryActive() -> Bool {
    return this.m_gameplayEntryActive;
  }

  public func SetStage(stage: Int32) -> Void {
    this.m_stage = stage;
  }

  public func GetStage() -> Int32 {
    return this.m_stage;
  }
}
