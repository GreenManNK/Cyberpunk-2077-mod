
import Codeware.UI.*

public class MarmurBankATMOpenEvent extends Event {
  public let bankBalance: Int32;
  public let walletBalance: Int32;
  public let initialMode: Int32;
  public let sessionToken: Int32;
}

public class MarmurBankATMResultEvent extends Event {
  public let sessionToken: Int32;
  public let success: Bool;
  public let message: String;
  public let bankBalance: Int32;
  public let walletBalance: Int32;
  public let clearAmount: Bool;
}

public class MarmurBankATMCloseEvent extends Event {
  public let sessionToken: Int32;
}

@addField(healthbarWidgetGameController)
private let m_marmurBankATMPopup: wref<MarmurBankATMPopup>;

private static func MarmurBankATMGetFact(game: GameInstance, factName: CName) -> Int32 {
  let quests: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
  if IsDefined(quests) {
    return quests.GetFact(factName);
  };
  return 0;
}

private static func MarmurBankATMSetFact(game: GameInstance, factName: CName, value: Int32) -> Void {
  let quests: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
  if IsDefined(quests) {
    quests.SetFact(factName, value);
  };
}

@addMethod(PlayerPuppet)
public final func MarmurBankATMOpenFromCET(
  bankBalance: Int32,
  walletBalance: Int32,
  sessionToken: Int32
) -> Bool {
  let evt: ref<MarmurBankATMOpenEvent> = new MarmurBankATMOpenEvent();
  evt.bankBalance = bankBalance;
  evt.walletBalance = walletBalance;
  evt.initialMode = MarmurBankATMGetFact(this.GetGame(), n"marmur_bank_atm_ui_mode");
  evt.sessionToken = sessionToken;
  GameInstance.GetUISystem(this.GetGame()).QueueEvent(evt);
  return true;
}

@addMethod(PlayerPuppet)
public final func MarmurBankATMResultFromCET(
  sessionToken: Int32,
  success: Bool,
  message: String,
  bankBalance: Int32,
  walletBalance: Int32,
  clearAmount: Bool
) -> Bool {
  let evt: ref<MarmurBankATMResultEvent> = new MarmurBankATMResultEvent();
  evt.sessionToken = sessionToken;
  evt.success = success;
  evt.message = message;
  evt.bankBalance = bankBalance;
  evt.walletBalance = walletBalance;
  evt.clearAmount = clearAmount;
  GameInstance.GetUISystem(this.GetGame()).QueueEvent(evt);
  return true;
}

@addMethod(PlayerPuppet)
public final func MarmurBankATMCloseFromCET(sessionToken: Int32) -> Bool {
  let evt: ref<MarmurBankATMCloseEvent> = new MarmurBankATMCloseEvent();
  evt.sessionToken = sessionToken;
  GameInstance.GetUISystem(this.GetGame()).QueueEvent(evt);
  return true;
}

@addMethod(healthbarWidgetGameController)
protected cb func OnMarmurBankATMOpenEvent(evt: ref<MarmurBankATMOpenEvent>) -> Bool {
  let game: GameInstance = GetGameInstance();
  let player: ref<PlayerPuppet> = GetPlayer(game);
  if !IsDefined(player) || !IsDefined(evt) {
    return false;
  };

  if IsDefined(this.m_marmurBankATMPopup) {
    return true;
  };

  let popup: ref<MarmurBankATMPopup> = new MarmurBankATMPopup();
  this.m_marmurBankATMPopup = popup;
  popup.Open(this, player, evt);
  return true;
}

@addMethod(healthbarWidgetGameController)
protected cb func OnMarmurBankATMResultEvent(evt: ref<MarmurBankATMResultEvent>) -> Bool {
  if IsDefined(this.m_marmurBankATMPopup) {
    this.m_marmurBankATMPopup.HandleResult(evt);
  };
  return true;
}

@addMethod(healthbarWidgetGameController)
protected cb func OnMarmurBankATMCloseEvent(evt: ref<MarmurBankATMCloseEvent>) -> Bool {
  if IsDefined(this.m_marmurBankATMPopup) {
    this.m_marmurBankATMPopup.ForceClose(evt);
  };
  return true;
}

public abstract class MarmurBankATMPopupBase extends CustomPopup {
  protected let m_vignette: wref<inkImage>;
  protected let m_background: wref<inkRectangle>;
  protected let m_container: wref<inkCompoundWidget>;

  protected cb func OnCreate() -> Void {
    super.OnCreate();
    this.CreateBackdrop();
    this.CreateContainer();
  }

  protected func CreateBackdrop() -> Void {
    let background: ref<inkRectangle> = new inkRectangle();
    background.SetName(n"marmur_atm_backdrop");
    background.SetTintColor(new HDRColor(0.010, 0.012, 0.016, 1.0));
    background.SetOpacity(0.95);
    background.SetSize(3840.0, 2160.0);
    background.SetAnchor(inkEAnchor.Centered);
    background.SetAnchorPoint(new Vector2(0.5, 0.5));
    background.Reparent(this.GetRootCompoundWidget());

    let vignette: ref<inkImage> = new inkImage();
    vignette.SetName(n"marmur_atm_vignette");
    vignette.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\notifications\\vignette.inkatlas");
    vignette.SetTexturePart(n"vignette_1");
    vignette.SetNineSliceScale(true);
    vignette.SetTintColor(new HDRColor(0.92, 0.055, 0.085, 1.0));
    vignette.SetOpacity(0.78);
    vignette.SetSize(32.0, 32.0);
    vignette.SetAnchor(inkEAnchor.CenterFillHorizontaly);
    vignette.SetAnchorPoint(new Vector2(0.5, 0.5));
    vignette.SetHAlign(inkEHorizontalAlign.Center);
    vignette.SetVAlign(inkEVerticalAlign.Center);
    vignette.SetFitToContent(true);
    vignette.Reparent(this.GetRootCompoundWidget());

    this.m_background = background;
    this.m_vignette = vignette;
  }

  protected func CreateContainer() -> Void {
    let container: ref<inkCanvas> = new inkCanvas();
    container.SetName(n"marmur_atm_container");
    container.SetAnchor(inkEAnchor.Centered);
    container.SetAnchorPoint(new Vector2(0.5, 0.5));
    container.SetSize(new Vector2(3600.0, 1900.0));
    container.Reparent(this.GetRootCompoundWidget());

    this.m_container = container;
    this.SetContainerWidget(container);
  }

  protected cb func OnShow() -> Void {
    let alpha: ref<inkAnimTransparency> = new inkAnimTransparency();
    alpha.SetStartTransparency(0.0);
    alpha.SetEndTransparency(1.0);
    alpha.SetType(inkanimInterpolationType.Linear);
    alpha.SetMode(inkanimInterpolationMode.EasyIn);
    alpha.SetDuration(0.08);

    let anim: ref<inkAnimDef> = new inkAnimDef();
    anim.AddInterpolator(alpha);
    this.m_transitionAnimProxy = this.m_container.PlayAnimation(anim);
    this.m_transitionAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnShowFinish");

    this.SetUIContext();
    this.SetBackgroundBlur();
    this.PlaySound(n"Button", n"OnPress");
  }

  protected cb func OnHide() -> Void {
    let alpha: ref<inkAnimTransparency> = new inkAnimTransparency();
    alpha.SetStartTransparency(1.0);
    alpha.SetEndTransparency(0.0);
    alpha.SetType(inkanimInterpolationType.Linear);
    alpha.SetMode(inkanimInterpolationMode.EasyIn);
    alpha.SetDuration(0.16);

    let anim: ref<inkAnimDef> = new inkAnimDef();
    anim.AddInterpolator(alpha);
    this.m_transitionAnimProxy = this.m_container.PlayAnimation(anim);
    this.m_transitionAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnHideFinish");

    this.ResetUIContext();
    this.ResetBackgroundBlur();
    this.PlaySound(n"GameMenu", n"OnOpen");
  }

  public func Close() -> Void {
    super.Close();
  }

  protected func SetBackgroundBlur() -> Void {
    PopupStateUtils.SetBackgroundBlur(this.m_gameController, true);
  }

  protected func ResetBackgroundBlur() -> Void {
    PopupStateUtils.SetBackgroundBlur(this.m_gameController, false);
  }

  protected func SetUIContext() -> Void {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGame());
    uiSystem.PushGameContext(UIGameContext.ModalPopup);
    uiSystem.RequestNewVisualState(n"inkInGameMenuState");
  }

  protected func ResetUIContext() -> Void {
    let uiSystem: ref<UISystem> = GameInstance.GetUISystem(this.GetGame());
    uiSystem.PopGameContext(UIGameContext.ModalPopup);
    uiSystem.RestorePreviousVisualState(n"inkInGameMenuState");
  }
}

public class MarmurBankATMPopup extends MarmurBankATMPopupBase {
  protected let m_player: wref<PlayerPuppet>;
  protected let m_data: ref<MarmurBankATMOpenEvent>;
  protected let m_bankBalance: Int32;
  protected let m_walletBalance: Int32;
  protected let m_amount: Int32;
  protected let m_mode: Int32;
  protected let m_waitingForResult: Bool = false;
  protected let m_closedByHost: Bool = false;
  protected let m_closeNotified: Bool = false;
  protected let m_pendingHostClose: Bool = false;
  protected let m_isClosing: Bool = false;
  protected let m_selectedButton: Int32 = 0;

  protected let m_bankBalanceText: wref<inkText>;
  protected let m_walletBalanceText: wref<inkText>;
  protected let m_modeText: wref<inkText>;
  protected let m_sourceText: wref<inkText>;
  protected let m_amountText: wref<inkText>;
  protected let m_statusText: wref<inkText>;
  protected let m_depositModeText: wref<inkText>;
  protected let m_withdrawModeText: wref<inkText>;
  protected let m_depositModeEdge: wref<inkRectangle>;
  protected let m_withdrawModeEdge: wref<inkRectangle>;
  protected let m_buttons: array<wref<inkCanvas>>;
  protected let m_buttonBackgrounds: array<wref<inkRectangle>>;
  protected let m_buttonEdges: array<wref<inkRectangle>>;
  protected let m_buttonTexts: array<wref<inkText>>;

  public func Open(
    requester: wref<inkGameController>,
    player: wref<PlayerPuppet>,
    data: ref<MarmurBankATMOpenEvent>
  ) -> Void {
    this.m_player = player;
    this.m_data = data;
    this.m_bankBalance = this.ClampBalance(data.bankBalance);
    this.m_walletBalance = this.ClampBalance(data.walletBalance);
    this.m_amount = 0;
    this.m_mode = data.initialMode == 2 ? 2 : 1;
    this.m_waitingForResult = false;
    this.m_closedByHost = false;
    this.m_closeNotified = false;
    this.m_pendingHostClose = false;
    this.m_isClosing = false;
    this.m_selectedButton = this.m_mode == 2 ? 1 : 0;
    super.Open(requester);
  }

  public func UseCursor() -> Bool {
    return true;
  }

  protected cb func OnCreate() -> Void {
    super.OnCreate();
    this.BuildSheet();
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnMarmurATMGlobalRelease");
  }

  protected cb func OnAttach() -> Void {
    super.OnAttach();
    if this.m_pendingHostClose && !this.m_isClosing {
      this.m_pendingHostClose = false;
      this.Close();
    };
  }

  protected cb func OnDetach() -> Void {
    this.m_isClosing = true;
    if !this.m_closeNotified && !this.m_closedByHost {
      this.m_closeNotified = true;
      this.SendCommand(2);
    };
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnMarmurATMGlobalRelease");
    super.OnDetach();
  }

  protected cb func OnShown() -> Void {
    if this.m_pendingHostClose && !this.m_isClosing {
      this.m_pendingHostClose = false;
      this.Close();
      return;
    };
    if this.m_isClosing {
      return;
    };
    if IsDefined(this.m_data) {
      MarmurBankATMSetFact(this.GetGame(), n"marmur_bank_atm_ui_ack", this.m_data.sessionToken);
      MarmurBankATMSetFact(this.GetGame(), n"marmur_bank_atm_ui_open", 1);
    };
    this.RefreshReadouts();

    if IsDefined(this.m_player) && this.m_player.PlayerLastUsedPad() {
      this.SelectButton(this.m_selectedButton, true);
    } else {
      this.SelectButton(this.m_selectedButton, false);
    };
  }

  public func Close() -> Void {
    if this.m_waitingForResult || this.m_isClosing {
      return;
    };
    this.m_isClosing = true;
    this.m_pendingHostClose = false;
    this.SetButtonsInteractive(false);
    if !this.m_closeNotified {
      this.m_closeNotified = true;
      if !this.m_closedByHost {
        this.SendCommand(2);
      };
    };
    super.Close();
  }

  public func HandleResult(evt: ref<MarmurBankATMResultEvent>) -> Void {
    if this.m_isClosing || !IsDefined(evt) || !IsDefined(this.m_data) || evt.sessionToken != this.m_data.sessionToken {
      return;
    };

    this.m_waitingForResult = false;
    this.m_bankBalance = this.ClampBalance(evt.bankBalance);
    this.m_walletBalance = this.ClampBalance(evt.walletBalance);
    if evt.clearAmount {
      this.m_amount = 0;
    };

    if NotEquals(evt.message, "") && IsDefined(this.m_statusText) {
      this.m_statusText.SetText(StrUpper(evt.message));
      this.m_statusText.SetTintColor(
        evt.success
          ? new HDRColor(0.42, 0.92, 0.61, 1.0)
          : new HDRColor(1.0, 0.24, 0.28, 1.0)
      );
    };
    this.RefreshReadouts();
  }

  public func ForceClose(evt: ref<MarmurBankATMCloseEvent>) -> Void {
    if !IsDefined(evt) || !IsDefined(this.m_data) || evt.sessionToken != this.m_data.sessionToken {
      return;
    };
    this.m_waitingForResult = false;
    this.m_closedByHost = true;
    if !this.IsInitialized() {
      this.m_pendingHostClose = true;
      return;
    };
    this.Close();
  }

  private func ClampBalance(value: Int32) -> Int32 {
    if value < 0 { return 0; };
    if value > 2147483647 { return 2147483647; };
    return value;
  }

  private func FormatMoney(value: Int32) -> String {
    let raw: String = IntToString(this.ClampBalance(value));
    let length: Int32 = StrLen(raw);
    let index: Int32 = 0;
    let result: String = "";

    while index < length {
      if index > 0 && ((length - index) % 3) == 0 {
        result += ",";
      };
      result += StrMid(raw, index, 1);
      index += 1;
    };

    return "E$ " + result;
  }

  private func CurrentSourceAmount() -> Int32 {
    return this.m_mode == 2 ? this.m_bankBalance : this.m_walletBalance;
  }

  private func CurrentDestinationAmount() -> Int32 {
    return this.m_mode == 2 ? this.m_walletBalance : this.m_bankBalance;
  }

  private func CurrentMaxTransfer() -> Int32 {
    let result: Int32 = this.CurrentSourceAmount();
    let destinationRoom: Int32 = 2147483647 - this.CurrentDestinationAmount();
    if result > 2000000000 {
      result = 2000000000;
    };
    if result > destinationRoom {
      result = destinationRoom;
    };
    return result > 0 ? result : 0;
  }

  private func SetStatus(message: String, tint: HDRColor) -> Void {
    if IsDefined(this.m_statusText) {
      this.m_statusText.SetText(message);
      this.m_statusText.SetTintColor(tint);
    };
  }

  private func SetReadyStatus() -> Void {
    this.SetStatus(
      this.m_mode == 2
        ? "READY - WITHDRAW FROM MARMUR SAVINGS"
        : "READY - DEPOSIT FROM WALLET",
      new HDRColor(0.64, 0.70, 0.74, 1.0)
    );
  }

  private func SendCommand(command: Int32) -> Void {
    if !IsDefined(this.m_data) {
      return;
    };

    let quests: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
    if !IsDefined(quests) {
      return;
    };

    quests.SetFact(n"marmur_bank_atm_ui_token", this.m_data.sessionToken);
    quests.SetFact(n"marmur_bank_atm_ui_mode", this.m_mode);
    quests.SetFact(n"marmur_bank_atm_ui_amount", this.m_amount);
    quests.SetFact(n"marmur_bank_atm_ui_open", command == 1 ? 1 : 0);
    quests.SetFact(n"marmur_bank_atm_ui_command", command);
  }

  private func SetMode(mode: Int32) -> Void {
    if this.m_waitingForResult || this.m_isClosing {
      return;
    };
    this.m_mode = mode == 2 ? 2 : 1;
    MarmurBankATMSetFact(this.GetGame(), n"marmur_bank_atm_ui_mode", this.m_mode);
    this.SetReadyStatus();
    this.RefreshReadouts();
  }

  private func AppendDigit(digit: Int32) -> Void {
    if this.m_waitingForResult || this.m_isClosing {
      return;
    };
    if this.m_amount > 200000000 {
      this.SetStatus("AMOUNT LIMIT REACHED", new HDRColor(1.0, 0.24, 0.28, 1.0));
      return;
    };

    let candidate: Int32 = (this.m_amount * 10) + digit;
    if candidate < 0 || candidate > 2000000000 {
      this.SetStatus("AMOUNT LIMIT REACHED", new HDRColor(1.0, 0.24, 0.28, 1.0));
      return;
    };

    this.m_amount = candidate;
    this.SetReadyStatus();
    this.RefreshReadouts();
  }

  private func AppendDoubleZero() -> Void {
    if this.m_waitingForResult || this.m_isClosing {
      return;
    };
    if this.m_amount > 20000000 {
      this.SetStatus("AMOUNT LIMIT REACHED", new HDRColor(1.0, 0.24, 0.28, 1.0));
      return;
    };
    this.m_amount *= 100;
    this.SetReadyStatus();
    this.RefreshReadouts();
  }

  private func Backspace() -> Void {
    if this.m_waitingForResult || this.m_isClosing {
      return;
    };
    this.m_amount /= 10;
    this.SetReadyStatus();
    this.RefreshReadouts();
  }

  private func ClearAmount() -> Void {
    if this.m_waitingForResult || this.m_isClosing {
      return;
    };
    this.m_amount = 0;
    this.SetReadyStatus();
    this.RefreshReadouts();
  }

  private func FillMax() -> Void {
    if this.m_waitingForResult || this.m_isClosing {
      return;
    };
    this.m_amount = this.CurrentMaxTransfer();
    if this.m_amount <= 0 {
      this.SetStatus("NO FUNDS AVAILABLE", new HDRColor(1.0, 0.24, 0.28, 1.0));
    } else {
      this.SetReadyStatus();
    };
    this.RefreshReadouts();
  }

  private func Submit() -> Void {
    if this.m_waitingForResult || this.m_isClosing {
      return;
    };
    if this.m_amount <= 0 {
      this.SetStatus("ENTER AN AMOUNT", new HDRColor(1.0, 0.24, 0.28, 1.0));
      return;
    };
    if this.m_amount > this.CurrentSourceAmount() {
      this.SetStatus("NOT ENOUGH FUNDS", new HDRColor(1.0, 0.24, 0.28, 1.0));
      this.PlaySound(n"Button", n"OnPress");
      return;
    };
    if this.m_amount > 2147483647 - this.CurrentDestinationAmount() {
      this.SetStatus("DESTINATION BALANCE LIMIT", new HDRColor(1.0, 0.24, 0.28, 1.0));
      this.PlaySound(n"Button", n"OnPress");
      return;
    };

    this.m_waitingForResult = true;
    this.SetStatus("PROCESSING SECURE TRANSACTION...", new HDRColor(0.98, 0.72, 0.18, 1.0));
    this.SendCommand(1);
  }

  private func RefreshReadouts() -> Void {
    let red: HDRColor = new HDRColor(0.94, 0.08, 0.12, 1.0);
    let white: HDRColor = new HDRColor(0.93, 0.95, 0.97, 1.0);
    let muted: HDRColor = new HDRColor(0.42, 0.49, 0.53, 1.0);

    if IsDefined(this.m_bankBalanceText) {
      this.m_bankBalanceText.SetText(this.FormatMoney(this.m_bankBalance));
    };
    if IsDefined(this.m_walletBalanceText) {
      this.m_walletBalanceText.SetText(this.FormatMoney(this.m_walletBalance));
    };
    if IsDefined(this.m_amountText) {
      this.m_amountText.SetText(this.FormatMoney(this.m_amount));
    };
    if IsDefined(this.m_modeText) {
      this.m_modeText.SetText(this.m_mode == 2 ? "WITHDRAW" : "DEPOSIT");
    };
    if IsDefined(this.m_sourceText) {
      this.m_sourceText.SetText(
        (this.m_mode == 2 ? "AVAILABLE SAVINGS  " : "AVAILABLE WALLET  ")
        + this.FormatMoney(this.CurrentSourceAmount())
      );
    };

    if IsDefined(this.m_depositModeEdge) {
      this.m_depositModeEdge.SetTintColor(this.m_mode == 1 ? red : muted);
      this.m_depositModeEdge.SetOpacity(this.m_mode == 1 ? 1.0 : 0.45);
    };
    if IsDefined(this.m_withdrawModeEdge) {
      this.m_withdrawModeEdge.SetTintColor(this.m_mode == 2 ? red : muted);
      this.m_withdrawModeEdge.SetOpacity(this.m_mode == 2 ? 1.0 : 0.45);
    };
    if IsDefined(this.m_depositModeText) {
      this.m_depositModeText.SetTintColor(this.m_mode == 1 ? white : muted);
    };
    if IsDefined(this.m_withdrawModeText) {
      this.m_withdrawModeText.SetTintColor(this.m_mode == 2 ? white : muted);
    };

    this.RefreshButtonSelection();
  }

  private func BuildSheet() -> Void {
    let panel: ref<inkCanvas> = new inkCanvas();
    panel.SetName(n"marmur_bank_atm_panel");
    panel.SetAnchor(inkEAnchor.Centered);
    panel.SetAnchorPoint(new Vector2(0.5, 0.5));
    panel.SetSize(new Vector2(1720.0, 1650.0));
    panel.Reparent(this.m_container);

    let red: HDRColor = new HDRColor(0.94, 0.08, 0.12, 1.0);
    let green: HDRColor = new HDRColor(0.42, 0.92, 0.61, 1.0);
    let white: HDRColor = new HDRColor(0.93, 0.95, 0.97, 1.0);
    let muted: HDRColor = new HDRColor(0.50, 0.57, 0.61, 1.0);

    this.AddRect(panel, 0.0, 0.0, 1720.0, 1650.0, new HDRColor(0.014, 0.018, 0.023, 1.0), 0.99);
    this.AddRect(panel, 0.0, 0.0, 1720.0, 9.0, red, 1.0);
    this.AddRect(panel, 0.0, 145.0, 1720.0, 3.0, new HDRColor(0.18, 0.07, 0.08, 1.0), 1.0);

    this.AddText(panel, "MARMUR BANK ATM", 60.0, 25.0, 58, white, 660.0, 76.0, textHorizontalAlignment.Left);
    this.AddText(panel, "SECURE TRANSACTION TERMINAL", 850.0, 32.0, 38, red, 810.0, 62.0, textHorizontalAlignment.Right);
    this.AddText(panel, "NETWATCH PROTECTED  /  SESSION ACTIVE", 63.0, 96.0, 24, muted, 760.0, 38.0, textHorizontalAlignment.Left);

    this.AddPanel(panel, 60.0, 175.0, 785.0, 155.0, new HDRColor(0.72, 0.77, 0.80, 1.0));
    this.AddText(panel, "WALLET BALANCE", 90.0, 195.0, 27, muted, 700.0, 38.0, textHorizontalAlignment.Left);
    this.m_walletBalanceText = this.AddText(panel, "E$ 0", 90.0, 236.0, 49, white, 700.0, 70.0, textHorizontalAlignment.Left);

    this.AddPanel(panel, 875.0, 175.0, 785.0, 155.0, red);
    this.AddText(panel, "MARMUR SAVINGS BALANCE", 905.0, 195.0, 27, muted, 700.0, 38.0, textHorizontalAlignment.Left);
    this.m_bankBalanceText = this.AddText(panel, "E$ 0", 905.0, 236.0, 49, white, 700.0, 70.0, textHorizontalAlignment.Left);

    this.AddButton(panel, "DEPOSIT", 60.0, 365.0, 785.0, 112.0, n"OnDepositMode", red, 38);
    this.m_depositModeText = this.m_buttonTexts[0];
    this.m_depositModeEdge = this.m_buttonEdges[0];
    this.AddButton(panel, "WITHDRAW", 875.0, 365.0, 785.0, 112.0, n"OnWithdrawMode", red, 38);
    this.m_withdrawModeText = this.m_buttonTexts[1];
    this.m_withdrawModeEdge = this.m_buttonEdges[1];

    this.AddRect(panel, 60.0, 515.0, 1600.0, 140.0, new HDRColor(0.004, 0.007, 0.010, 1.0), 1.0);
    this.m_modeText = this.AddText(panel, "DEPOSIT", 90.0, 530.0, 30, muted, 310.0, 46.0, textHorizontalAlignment.Left);
    this.m_amountText = this.AddText(panel, "E$ 0", 410.0, 520.0, 61, white, 680.0, 92.0, textHorizontalAlignment.Center);
    this.m_sourceText = this.AddText(panel, "AVAILABLE WALLET  E$ 0", 1110.0, 535.0, 27, muted, 515.0, 48.0, textHorizontalAlignment.Right);
    this.AddRect(panel, 90.0, 625.0, 1540.0, 2.0, new HDRColor(0.20, 0.08, 0.09, 1.0), 1.0);

    this.AddButton(panel, "1", 60.0, 695.0, 300.0, 140.0, n"OnDigit1", white, 52);
    this.AddButton(panel, "2", 380.0, 695.0, 300.0, 140.0, n"OnDigit2", white, 52);
    this.AddButton(panel, "3", 700.0, 695.0, 300.0, 140.0, n"OnDigit3", white, 52);
    this.AddButton(panel, "CANCEL", 1020.0, 695.0, 640.0, 140.0, n"OnCancel", red, 36);

    this.AddButton(panel, "4", 60.0, 855.0, 300.0, 140.0, n"OnDigit4", white, 52);
    this.AddButton(panel, "5", 380.0, 855.0, 300.0, 140.0, n"OnDigit5", white, 52);
    this.AddButton(panel, "6", 700.0, 855.0, 300.0, 140.0, n"OnDigit6", white, 52);
    this.AddButton(panel, "CLEAR", 1020.0, 855.0, 640.0, 140.0, n"OnClear", red, 36);

    this.AddButton(panel, "7", 60.0, 1015.0, 300.0, 140.0, n"OnDigit7", white, 52);
    this.AddButton(panel, "8", 380.0, 1015.0, 300.0, 140.0, n"OnDigit8", white, 52);
    this.AddButton(panel, "9", 700.0, 1015.0, 300.0, 140.0, n"OnDigit9", white, 52);
    this.AddButton(panel, "MAX", 1020.0, 1015.0, 640.0, 140.0, n"OnMax", white, 36);

    this.AddButton(panel, "00", 60.0, 1175.0, 300.0, 140.0, n"OnDoubleZero", white, 48);
    this.AddButton(panel, "0", 380.0, 1175.0, 300.0, 140.0, n"OnDigit0", white, 52);
    this.AddButton(panel, "BACK", 700.0, 1175.0, 300.0, 140.0, n"OnBack", red, 32);
    this.AddButton(panel, "ENTER", 1020.0, 1175.0, 640.0, 140.0, n"OnEnter", green, 40);

    this.AddRect(panel, 60.0, 1360.0, 1600.0, 2.0, new HDRColor(0.18, 0.07, 0.08, 1.0), 1.0);
    this.m_statusText = this.AddText(panel, "READY - DEPOSIT FROM WALLET", 75.0, 1380.0, 31, muted, 1570.0, 60.0, textHorizontalAlignment.Left);
    this.AddText(panel, "MOUSE / VIRTUAL CURSOR  |  D-PAD NAVIGATE  |  CONFIRM SELECTS  |  BACK CLOSES", 75.0, 1480.0, 24, muted, 1570.0, 44.0, textHorizontalAlignment.Left);
    this.AddText(panel, "YOUR WEALTH. OUR PRIORITY.", 75.0, 1550.0, 28, red, 1570.0, 46.0, textHorizontalAlignment.Right);

    this.SetReadyStatus();
    this.RefreshReadouts();
  }

  private func AddPanel(
    parent: ref<inkCompoundWidget>,
    x: Float,
    y: Float,
    width: Float,
    height: Float,
    accent: HDRColor
  ) -> Void {
    this.AddRect(parent, x, y, width, height, new HDRColor(0.030, 0.036, 0.043, 1.0), 0.98);
    this.AddRect(parent, x, y, width, 5.0, accent, 1.0);
  }

  private func AddRect(
    parent: ref<inkCompoundWidget>,
    x: Float,
    y: Float,
    width: Float,
    height: Float,
    tint: HDRColor,
    opacity: Float
  ) -> ref<inkRectangle> {
    let rect: ref<inkRectangle> = new inkRectangle();
    rect.SetAnchor(inkEAnchor.TopLeft);
    rect.SetMargin(new inkMargin(x, y, 0.0, 0.0));
    rect.SetSize(new Vector2(width, height));
    rect.SetTintColor(tint);
    rect.SetOpacity(opacity);
    rect.Reparent(parent);
    return rect;
  }

  private func AddText(
    parent: ref<inkCompoundWidget>,
    value: String,
    x: Float,
    y: Float,
    size: Int32,
    tint: HDRColor,
    width: Float,
    height: Float,
    alignment: textHorizontalAlignment
  ) -> ref<inkText> {
    let text: ref<inkText> = new inkText();
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(n"Regular");
    text.SetFontSize(size);
    text.SetLetterCase(textLetterCase.OriginalCase);
    text.SetAnchor(inkEAnchor.TopLeft);
    text.SetMargin(new inkMargin(x, y, 0.0, 0.0));
    text.SetSize(new Vector2(width, height));
    text.SetHorizontalAlignment(alignment);
    text.SetVerticalAlignment(textVerticalAlignment.Center);
    text.SetTintColor(tint);
    text.SetText(value);
    text.Reparent(parent);
    return text;
  }

  private func AddButton(
    parent: ref<inkCompoundWidget>,
    label: String,
    x: Float,
    y: Float,
    width: Float,
    height: Float,
    callback: CName,
    accent: HDRColor,
    fontSize: Int32
  ) -> Void {
    let hit: ref<inkCanvas> = new inkCanvas();
    hit.SetAnchor(inkEAnchor.TopLeft);
    hit.SetMargin(new inkMargin(x, y, 0.0, 0.0));
    hit.SetSize(new Vector2(width, height));
    hit.SetInteractive(true);
    hit.RegisterToCallback(n"OnRelease", this, callback);
    hit.Reparent(parent);

    let background: ref<inkRectangle> = new inkRectangle();
    background.SetAnchor(inkEAnchor.Fill);
    background.SetTintColor(new HDRColor(0.050, 0.060, 0.070, 1.0));
    background.SetOpacity(0.88);
    background.Reparent(hit);

    let edge: ref<inkRectangle> = new inkRectangle();
    edge.SetAnchor(inkEAnchor.TopLeft);
    edge.SetMargin(new inkMargin(0.0, height - 6.0, 0.0, 0.0));
    edge.SetSize(new Vector2(width, 6.0));
    edge.SetTintColor(accent);
    edge.SetOpacity(0.92);
    edge.Reparent(hit);

    let text: ref<inkText> = new inkText();
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(n"Semi-Bold");
    text.SetFontSize(fontSize);
    text.SetTintColor(accent);
    text.SetText(label);
    text.SetAnchor(inkEAnchor.Fill);
    text.SetHorizontalAlignment(textHorizontalAlignment.Center);
    text.SetVerticalAlignment(textVerticalAlignment.Center);
    text.Reparent(hit);

    ArrayPush(this.m_buttons, hit);
    ArrayPush(this.m_buttonBackgrounds, background);
    ArrayPush(this.m_buttonEdges, edge);
    ArrayPush(this.m_buttonTexts, text);
  }

  private func RefreshButtonSelection() -> Void {
    let index: Int32 = 0;
    while index < ArraySize(this.m_buttonBackgrounds) {
      if IsDefined(this.m_buttonBackgrounds[index]) {
        this.m_buttonBackgrounds[index].SetOpacity(index == this.m_selectedButton ? 1.0 : 0.88);
        this.m_buttonBackgrounds[index].SetTintColor(
          index == this.m_selectedButton
            ? new HDRColor(0.125, 0.045, 0.052, 1.0)
            : new HDRColor(0.050, 0.060, 0.070, 1.0)
        );
      };
      index += 1;
    };
  }

  private func SetButtonsInteractive(interactive: Bool) -> Void {
    let index: Int32 = 0;
    while index < ArraySize(this.m_buttons) {
      if IsDefined(this.m_buttons[index]) {
        this.m_buttons[index].SetInteractive(interactive);
      };
      index += 1;
    };
  }

  private func SelectButton(index: Int32, moveCursor: Bool) -> Void {
    let count: Int32 = ArraySize(this.m_buttons);
    if count <= 0 {
      return;
    };
    if index < 0 { index = 0; };
    if index >= count { index = count - 1; };
    this.m_selectedButton = index;
    this.RefreshButtonSelection();

    if moveCursor && IsDefined(this.m_gameController) && IsDefined(this.m_buttons[index]) {
      this.m_gameController.SetCursorOverWidget(this.m_buttons[index], 0.0, true);
    };
  }

  private func NavigateButton(horizontal: Int32, vertical: Int32) -> Void {
    let index: Int32 = this.m_selectedButton;
    if index < 2 {
      if horizontal != 0 {
        index = index == 0 ? 1 : 0;
      } else if vertical > 0 {
        index = index == 0 ? 2 : 4;
      };
      this.SelectButton(index, true);
      return;
    };

    let gridIndex: Int32 = index - 2;
    let row: Int32 = gridIndex / 4;
    let column: Int32 = gridIndex % 4;

    if horizontal < 0 {
      column = column == 0 ? 3 : column - 1;
    } else if horizontal > 0 {
      column = column == 3 ? 0 : column + 1;
    } else if vertical < 0 {
      if row == 0 {
        this.SelectButton(column < 2 ? 0 : 1, true);
        return;
      };
      row -= 1;
    } else if vertical > 0 {
      if row < 3 {
        row += 1;
      };
    };

    this.SelectButton(2 + (row * 4) + column, true);
  }

  protected cb func OnMarmurATMGlobalRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsHandled() || !this.IsTopPopup() || this.m_isClosing || this.m_waitingForResult {
      return false;
    };
    if evt.IsAction(n"navigate_up") || evt.IsAction(n"up_button") {
      this.NavigateButton(0, -1);
      evt.Handle();
      return true;
    };
    if evt.IsAction(n"navigate_down") || evt.IsAction(n"down_button") {
      this.NavigateButton(0, 1);
      evt.Handle();
      return true;
    };
    if evt.IsAction(n"navigate_left") || evt.IsAction(n"left_button") {
      this.NavigateButton(-1, 0);
      evt.Handle();
      return true;
    };
    if evt.IsAction(n"navigate_right") || evt.IsAction(n"right_button") {
      this.NavigateButton(1, 0);
      evt.Handle();
      return true;
    };
    return false;
  }

  protected cb func OnDepositMode(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(0, false);
    this.SetMode(1);
    return true;
  }

  protected cb func OnWithdrawMode(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(1, false);
    this.SetMode(2);
    return true;
  }

  protected cb func OnDigit1(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(2, false); this.AppendDigit(1); return true;
  }
  protected cb func OnDigit2(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(3, false); this.AppendDigit(2); return true;
  }
  protected cb func OnDigit3(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(4, false); this.AppendDigit(3); return true;
  }
  protected cb func OnDigit4(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(6, false); this.AppendDigit(4); return true;
  }
  protected cb func OnDigit5(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(7, false); this.AppendDigit(5); return true;
  }
  protected cb func OnDigit6(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(8, false); this.AppendDigit(6); return true;
  }
  protected cb func OnDigit7(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(10, false); this.AppendDigit(7); return true;
  }
  protected cb func OnDigit8(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(11, false); this.AppendDigit(8); return true;
  }
  protected cb func OnDigit9(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(12, false); this.AppendDigit(9); return true;
  }
  protected cb func OnDigit0(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(15, false); this.AppendDigit(0); return true;
  }
  protected cb func OnDoubleZero(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(14, false); this.AppendDoubleZero(); return true;
  }
  protected cb func OnClear(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(9, false); this.ClearAmount(); return true;
  }
  protected cb func OnMax(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(13, false); this.FillMax(); return true;
  }
  protected cb func OnBack(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(16, false); this.Backspace(); return true;
  }
  protected cb func OnCancel(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(5, false); this.Close(); return true;
  }
  protected cb func OnEnter(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") || this.m_waitingForResult { return false; };
    this.SelectButton(17, false); this.Submit(); return true;
  }
}
