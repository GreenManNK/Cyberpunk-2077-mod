module AldecaldosHighStakes.QuestVehicle

import Codeware.UI.*

// -----------------------------------------------------------------------------
// Quest Vehicle Durability Widget (Codeware.UI)
// -----------------------------------------------------------------------------
public class QuestVehicleWidget extends inkCustomController {
  protected let m_root: wref<inkCanvas>;
  protected let m_barFill: wref<inkImage>;
  protected let m_valueText: wref<inkText>;
  protected let m_statusText: wref<inkText>;
  protected let m_barMaxWidth: Float;
  protected let m_barHeight: Float;

  protected cb func OnCreate() {
    this.m_barMaxWidth = 560.0;
    this.m_barHeight = 26.0;
    this.CreateWidgets();
  }

  protected func CreateWidgets() {
    let root = new inkCanvas();
    root.SetName(n"QuestVehicleWidget_Root");
    root.SetSize(Vector2(600.0, 100.0));
    root.SetAnchor(inkEAnchor.TopCenter);
    root.SetAnchorPoint(Vector2(0.5, 0.0));
    root.SetTranslation(Vector2(0.0, 10.0));
    this.m_root = root;

    // Background plate
    let bg = new inkImage();
    bg.SetName(n"QuestVehicleWidget_BG");
    bg.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
    bg.SetTexturePart(n"cell_bg");
    bg.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    bg.BindProperty(n"tintColor", n"MainColors.Fullscreen_PrimaryBackgroundDarkest");
    bg.SetOpacity(0.85);
    bg.SetSize(Vector2(600.0, 100.0));
    bg.SetNineSliceScale(true);
    bg.Reparent(this.m_root);

    // Outer frame
    let frame = new inkImage();
    frame.SetName(n"QuestVehicleWidget_Frame");
    frame.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
    frame.SetTexturePart(n"cell_fg");
    frame.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    frame.BindProperty(n"tintColor", n"MainColors.Blue");
    frame.SetOpacity(0.9);
    frame.SetSize(Vector2(600.0, 100.0));
    frame.SetNineSliceScale(true);
    frame.Reparent(this.m_root);

    // Bar track
    let track = new inkImage();
    track.SetName(n"QuestVehicleWidget_Track");
    track.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
    track.SetTexturePart(n"cell_bg");
    track.SetTintColor(HDRColor(0.08, 0.1, 0.15, 0.95));
    track.SetSize(Vector2(this.m_barMaxWidth, this.m_barHeight));
    track.SetTranslation(Vector2(20.0, 40.0));
    track.SetNineSliceScale(true);
    track.Reparent(this.m_root);

    // Bar fill
    let fill = new inkImage();
    fill.SetName(n"QuestVehicleWidget_Fill");
    fill.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
    fill.SetTexturePart(n"cell_bg");
    fill.SetTintColor(ThemeColors.ElectricBlue());
    fill.SetSize(Vector2(this.m_barMaxWidth, this.m_barHeight));
    fill.SetTranslation(Vector2(20.0, 40.0));
    fill.SetNineSliceScale(true);
    fill.Reparent(this.m_root);
    this.m_barFill = fill;

    // Title
    let title = new inkText();
    title.SetName(n"QuestVehicleWidget_Title");
    title.SetText("BEHEMOTH DURABILITY");
    title.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    title.SetFontStyle(n"Bold");
    title.SetFontSize(16);
    title.SetLetterCase(textLetterCase.UpperCase);
    title.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    title.BindProperty(n"tintColor", n"MainColors.Blue");
    title.SetTranslation(Vector2(20.0, 12.0));
    title.Reparent(this.m_root);

    // Status badge
    let status = new inkText();
    status.SetName(n"QuestVehicleWidget_Status");
    status.SetText("[ OPTIMAL ]");
    status.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    status.SetFontStyle(n"Bold");
    status.SetFontSize(14);
    status.SetLetterCase(textLetterCase.UpperCase);
    status.SetTintColor(ThemeColors.LightGreen());
    status.SetTranslation(Vector2(460.0, 14.0));
    status.Reparent(this.m_root);
    this.m_statusText = status;

    // Numeric readout
    let valText = new inkText();
    valText.SetName(n"QuestVehicleWidget_ValText");
    valText.SetText("DURABILITY: 100 %");
    valText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    valText.SetFontStyle(n"Bold");
    valText.SetFontSize(15);
    valText.SetTintColor(ThemeColors.PureWhite());
    valText.SetTranslation(Vector2(20.0, 73.0));
    valText.Reparent(this.m_root);
    this.m_valueText = valText;

    this.SetRootWidget(this.m_root);
  }

  public func UpdateDurability(durability: Int32) {
    let clamped: Int32 = Max(Min(durability, 100), 0);
    let ratio: Float = Cast<Float>(clamped) / 100.0;

    if IsDefined(this.m_barFill) {
      this.m_barFill.SetSize(Vector2(this.m_barMaxWidth * ratio, this.m_barHeight));

      if ratio <= 0.25 {
        this.m_barFill.SetTintColor(ThemeColors.Bittersweet());
        if IsDefined(this.m_statusText) {
          this.m_statusText.SetText("[ CRITICAL ]");
          this.m_statusText.SetTintColor(ThemeColors.Bittersweet());
        }
      } else if ratio <= 0.5 {
        this.m_barFill.SetTintColor(ThemeColors.Dandelion());
        if IsDefined(this.m_statusText) {
          this.m_statusText.SetText("[ WARNING ]");
          this.m_statusText.SetTintColor(ThemeColors.Dandelion());
        }
      } else {
        this.m_barFill.SetTintColor(ThemeColors.ElectricBlue());
        if IsDefined(this.m_statusText) {
          this.m_statusText.SetText("[ OPTIMAL ]");
          this.m_statusText.SetTintColor(ThemeColors.LightGreen());
        }
      }
    }

    if IsDefined(this.m_valueText) {
      this.m_valueText.SetText(s"DURABILITY: \(clamped) %");
    }
  }

  public static func Create() -> ref<QuestVehicleWidget> {
    let self = new QuestVehicleWidget();
    self.CreateInstance();
    return self;
  }
}

// -----------------------------------------------------------------------------
// Quest Vehicle Service
// -----------------------------------------------------------------------------
public class QuestVehicleService extends ScriptableService {
  private let m_vehicle_hp: Int32;
  private let m_vehicle_destroyed: Bool;
  private let m_vehicle_object: ref<VehicleObject>;
  private let m_widget: ref<QuestVehicleWidget>;
  // 0 | 1 | 2 | 3 | 4 | 5
  // 0 - initial | 1 - 85% ~ 75% | 2 - 65% - 50% | 3 - 25 ~ 30%  | 4 - 15% ~ 10% | 5 - disabled notification
  private let m_notification_state: Int32;

  private cb func OnLoad() {
    GameInstance
      .GetCallbackSystem()
      .RegisterCallback(n"Session/Ready", this, n"OnSessionReady");
  }

  private cb func OnSessionReady(event: ref<GameSessionEvent>) {
    if !event.IsPreGame() {
      this.m_notification_state = 0;
      this.m_vehicle_hp = 100;
      this.m_vehicle_destroyed = false;

      let player = GameInstance.GetPlayerSystem(GetGameInstance()).GetLocalPlayerMainGameObject() as PlayerPuppet;
      if IsDefined(player) {
        let vehicle = player.GetMountedVehicle();
        if IsDefined(vehicle) && this.IsQuestVehicle(vehicle.GetRecordID()) {
          this.ShowWidget(vehicle);
          return;
        }
      }
      this.HideWidget();
    }
  }

  public func SetVehicle(vehicle: ref<VehicleObject>) -> Void {
    this.m_vehicle_object = vehicle;
    if this.m_vehicle_hp < 0 {
      this.m_vehicle_hp = 100;
    }
  }

  public func HasVehicle() -> Bool {
    return IsDefined(this.m_vehicle_object);
  }

  public func GetVehicleObject() -> ref<VehicleObject> {
    return this.m_vehicle_object;
  }

  public func IsQuestVehicle(recordId: TweakDBID) -> Bool {
    return Equals(t"Vehicle.sq_hs_behemoth", recordId);
  }

  public func ApplyDamage(destruction: Float) -> Void {
    this.m_vehicle_hp = Cast<Int32>(destruction);
    if this.m_vehicle_hp == 0 {
      this.m_vehicle_destroyed = true;
    }
    if IsDefined(this.m_widget) {
      this.m_widget.UpdateDurability(this.m_vehicle_hp);
    }
    this.AlertPlayer();
  }

  public func ShowWidget(vehicle: ref<VehicleObject>) -> Void {
    if !IsDefined(vehicle) {
      return;
    }

    this.SetVehicle(vehicle);

    let statPools = GameInstance.GetStatPoolsSystem(vehicle.GetGame());
    let statsObj = Cast<StatsObjectID>(vehicle.GetEntityID());
    if statPools.IsStatPoolAdded(statsObj, gamedataStatPoolType.Health) {
      let hp = statPools.GetStatPoolValue(statsObj, gamedataStatPoolType.Health, false);
      if hp >= 0.0 {
        this.m_vehicle_hp = Cast<Int32>(hp);
      }
    }

    this.AttachWidget();
    if IsDefined(this.m_widget) {
      this.m_widget.UpdateDurability(this.m_vehicle_hp);
    }
  }

  public func HideWidget() -> Void {
    let hudLayer = GameInstance.GetInkSystem().GetLayer(n"inkHUDLayer");
    if IsDefined(hudLayer) {
      let win = hudLayer.GetVirtualWindow();
      if IsDefined(win) {
        let hudRoot = win.GetWidget(0) as inkCompoundWidget;
        if IsDefined(hudRoot) {
          let old = hudRoot.GetWidget(n"QuestVehicleWidget_Root");
          if IsDefined(old) {
            hudRoot.RemoveChild(old);
          }
        }
      }
    }
    this.m_widget = null;
    this.m_vehicle_object = null;
  }

  private func AttachWidget() -> Void {
    let hudLayer = GameInstance.GetInkSystem().GetLayer(n"inkHUDLayer");
    if !IsDefined(hudLayer) {
      return;
    }
    let win = hudLayer.GetVirtualWindow();
    if !IsDefined(win) {
      return;
    }
    let hudRoot = win.GetWidget(0) as inkCompoundWidget;
    if !IsDefined(hudRoot) {
      return;
    }

    let old = hudRoot.GetWidget(n"QuestVehicleWidget_Root");
    if IsDefined(old) {
      hudRoot.RemoveChild(old);
    }

    this.m_widget = QuestVehicleWidget.Create();
    this.m_widget.Reparent(hudRoot);
  }

  public func AlertPlayer() -> Void {
    if this.m_vehicle_hp <= 100 && this.m_vehicle_hp >= 85 && this.m_notification_state == 0 {
      this.m_notification_state = 1;
      this.ShowNotification(
        GetLocalizedText(s"LocKey#9436066804195855013") + this.m_vehicle_hp + "%"
      );
    }
    if this.m_vehicle_hp <= 85 && this.m_vehicle_hp >= 75 && this.m_notification_state == 1 {
      this.m_notification_state = 2;
      this.ShowNotification(
        GetLocalizedText(s"LocKey#7846835637855334049") + this.m_vehicle_hp + "%"
      );
    }
    if this.m_vehicle_hp <= 65 && this.m_vehicle_hp >= 50 && this.m_notification_state == 2 {
      this.m_notification_state = 3;
      this.ShowNotification(
        GetLocalizedText(s"LocKey#5704945695707168034") + this.m_vehicle_hp + "%"
      );
    }
    if this.m_vehicle_hp <= 30 && this.m_vehicle_hp >= 25 && this.m_notification_state == 3 {
      this.ShowNotification(
        GetLocalizedText(s"LocKey#9322729103479920025") + this.m_vehicle_hp + "%"
      );
      this.m_notification_state = 4;
    }
    if this.m_vehicle_hp <= 15 && this.m_vehicle_hp >= 10 && this.m_notification_state == 4 {
      this.ShowNotification(
        GetLocalizedText(s"LocKey#17921965581097729998") + this.m_vehicle_hp + "%"
      );
      this.m_notification_state = 5;
    }
  }

  public func ShowNotification(message: String) -> Void {
    let msg = new SimpleScreenMessage();
    msg.duration = 3;
    msg.message = message;
    msg.isShown = true;
    msg.type = SimpleMessageType.Negative;
    GetGameInstance()
      .GetBlackboardSystem()
      .Get(GetAllBlackboardDefs().UI_Notifications)
      .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, msg, true);
  }
}

// -----------------------------------------------------------------------------
// Hooks
// -----------------------------------------------------------------------------
@wrapMethod(VehicleComponent)
private final func EvaluateDamageLevel(destruction: Float) -> Int32 {
  let result: Int32 = wrappedMethod(destruction);

  let veh = this.GetVehicle();
  if IsDefined(veh) {
    let vehicleService = GameInstance
      .GetScriptableServiceContainer()
      .GetService(n"AldecaldosHighStakes.QuestVehicle.QuestVehicleService") as QuestVehicleService;
    if IsDefined(vehicleService) && vehicleService.IsQuestVehicle(veh.GetRecordID()) {
      vehicleService.ApplyDamage(destruction);
    }
  }

  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnMountingEvent(evt: ref<MountingEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);

  let vehicle = this.GetMountedVehicle();
  if IsDefined(vehicle) {
    let vehicleService = GameInstance
      .GetScriptableServiceContainer()
      .GetService(n"AldecaldosHighStakes.QuestVehicle.QuestVehicleService") as QuestVehicleService;
    if IsDefined(vehicleService) && vehicleService.IsQuestVehicle(vehicle.GetRecordID()) {
      vehicleService.ShowWidget(vehicle);
    }
  }

  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnUnmountingEvent(evt: ref<UnmountingEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);

  let vehicleService = GameInstance
    .GetScriptableServiceContainer()
    .GetService(n"AldecaldosHighStakes.QuestVehicle.QuestVehicleService") as QuestVehicleService;
  if IsDefined(vehicleService) {
    vehicleService.HideWidget();
  }

  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();

  let vehicle = this.GetMountedVehicle();
  let vehicleService = GameInstance
    .GetScriptableServiceContainer()
    .GetService(n"AldecaldosHighStakes.QuestVehicle.QuestVehicleService") as QuestVehicleService;
  if IsDefined(vehicleService) {
    if IsDefined(vehicle) && vehicleService.IsQuestVehicle(vehicle.GetRecordID()) {
      vehicleService.ShowWidget(vehicle);
    } else {
      vehicleService.HideWidget();
    }
  }

  return result;
}