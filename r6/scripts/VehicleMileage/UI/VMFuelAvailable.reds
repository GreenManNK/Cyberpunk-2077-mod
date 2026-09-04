// VMFuelAvailable.reds
// Standalone per-station world widget for available CHOOH2 stock.
//
// WolvenKit / World Builder setup for station 5:
// - worlduiWidgetComponent name: vm_fuel_available_005
// - widgetResource: OdoHUD\hud\fuel_available.inkwidget
// - DynamicWidgetController: OdoHUD.inkFuelAvailable
// - mesh component name: fuel_available_mesh
// - meshTargetBinding.bindName: fuel_available_mesh
// - mesh resource: OdoHUD\hud\fuel_available.mesh
//
// The three-digit suffix selects:
//   vm_gas_station_005_available_fuel_l
module OdoHUD

import VehicleMileage.Runtime.VMRuntimeSystem

public class inkFuelAvailable extends inkGameController {
  private let root: wref<inkCompoundWidget>;
  private let fuelText: wref<inkText>;
  private let stationIndex: Int32;
  private let lastLiters: Int32;
  protected cb func OnInitialize() -> Void {
    this.root = this.GetRootCompoundWidget();
    if !IsDefined(this.root) {
      return;
    };
    this.root.SetVisible(true);
    this.root.SetOpacity(1.0);
    this.lastLiters = -1;
    this.EnsureFuelText();
  }
  public func SetStationIndex(index: Int32) -> Void {
    if index < 1 {
      return;
    };
    if this.stationIndex != index {
      this.stationIndex = index;
      this.lastLiters = -1;
    };
    this.RefreshFromFacts();
  }
  public func VM_FuelAvailable_SetVisible(show: Bool) -> Void {
    if IsDefined(this.root) {
      this.root.SetVisible(show);
      this.root.SetOpacity(show ? 1.0 : 0.0);
    };
  }
  private func EnsureFuelText() -> Void {
    if !IsDefined(this.root) {
      return;
    };
    // Preferred text node in the authored inkwidget.
    this.fuelText = this.root.GetWidgetByPathName(n"FuelAvailable") as inkText;
    if !IsDefined(this.fuelText) {
      this.fuelText = this.root.GetWidgetByPathName(n"AvailableFuel") as inkText;
    };
    if !IsDefined(this.fuelText) {
      this.fuelText = this.root.GetWidgetByPathName(n"Value") as inkText;
    };
    // Fallback makes the controller usable even when the template has no text.
    if !IsDefined(this.fuelText) {
      let text: ref<inkText> = new inkText();
      text.SetName(n"FuelAvailable");
      text.SetText("360.0000 L");
      text.SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily");
      text.SetFontSize(70);
      text.SetLetterCase(textLetterCase.OriginalCase);
      text.SetAnchor(inkEAnchor.Centered);
      text.SetAnchorPoint(new Vector2(0.5, 0.5));
      text.SetTranslation(new Vector2(0.0, 0.0));
      text.SetVisible(true);
      text.SetOpacity(1.0);
      text.Reparent(this.root);
      this.fuelText = text;
    };
    this.fuelText.SetVisible(true);
    this.fuelText.SetOpacity(1.0);

    // Warm amber-yellow matching the nearby CHOOH/grade display text.
    let textColor: HDRColor;
    textColor.Red = 1.0;
    textColor.Green = 0.55;
    textColor.Blue = 0.04;
    textColor.Alpha = 1.0;
    this.fuelText.SetTintColor(textColor);
  }
  private func PaddedStationIndex(index: Int32) -> String {
    if index < 10 {
      return "00" + IntToString(index);
    };
    if index < 100 {
      return "0" + IntToString(index);
    };
    return IntToString(index);
  }
  private func AddThousandsSeparators(value: Int32) -> String {
    let safeValue: Int32 = value;
    if safeValue < 0 {
      safeValue = 0;
    };
    if safeValue < 1000 {
      return IntToString(safeValue);
    };
    let thousands: Int32 = safeValue / 1000;
    let remainder: Int32 = safeValue % 1000;
    let remainderText: String;
    if remainder < 10 {
      remainderText = "00" + IntToString(remainder);
    } else {
      if remainder < 100 {
        remainderText = "0" + IntToString(remainder);
      } else {
        remainderText = IntToString(remainder);
      };
    };
    return IntToString(thousands) + "," + remainderText;
  }
  public func RefreshFromFacts() -> Void {
    if this.stationIndex < 1 {
      return;
    };
    this.EnsureFuelText();
    if !IsDefined(this.fuelText) {
      return;
    };
    let qs = GameInstance.GetQuestsSystem(GetGameInstance());
    if !IsDefined(qs) {
      return;
    };
    let factName: CName = StringToName(
      "vm_gas_station_"
      + this.PaddedStationIndex(this.stationIndex)
      + "_available_fuel_l"
    );
    let liters: Int32 = qs.GetFact(factName);
    if liters == this.lastLiters {
      return;
    };
    this.lastLiters = liters;
    this.fuelText.SetText(this.AddThousandsSeparators(liters) + " L");
  }
}
private class VMFuelAvailableTick extends DelayCallback {
  private let service: wref<VMFuelAvailableService>;
  private let token: Int32;
  public static func Create(
    service: ref<VMFuelAvailableService>,
    token: Int32
  ) -> ref<VMFuelAvailableTick> {
    let self = new VMFuelAvailableTick();
    self.service = service;
    self.token = token;
    return self;
  }
  public func Call() -> Void {
    if IsDefined(this.service) {
      if this.token != this.service.tickToken {
        return;
      };
      this.service.tickArmed = false;
      this.service.Tick();
    };
  }
}
public class VMFuelAvailableTarget extends IScriptable {
  public let widget: wref<worlduiWidgetComponent>;
  public let stationIndex: Int32;
}
@addField(UISystem)
public let vmFuelAvailableService: wref<IScriptable>;
public class VMFuelAvailableService extends IScriptable {
  public let tickArmed: Bool;
  public let tickToken: Int32;
  private let tick: ref<VMFuelAvailableTick>;
  private let callbackSystem: wref<CallbackSystem>;
  private let registered: Bool;
  private let targets: array<ref<VMFuelAvailableTarget>>;
  private let fastTicksLeft: Int32;
  private let tickPeriodFast: Float = 0.25;
  private let tickPeriodSlow: Float = 2.0;
  public func Start() -> Void {
    if !this.registered {
      this.callbackSystem = GameInstance.GetCallbackSystem();
      if IsDefined(this.callbackSystem) {
        this.callbackSystem.RegisterCallback(
          n"Entity/Assemble",
          this,
          n"OnEntityAssemble",
          true
        );
        this.registered = true;
      };
    };
    let ui = GameInstance.GetUISystem(GetGameInstance());
    if IsDefined(ui) {
      ui.vmFuelAvailableService = this;
    };
    this.RequestFastTicks(12);
  }
  private func ComponentName(index: Int32) -> CName {
    let suffix: String;
    if index < 10 {
      suffix = "00" + IntToString(index);
    } else {
      if index < 100 {
        suffix = "0" + IntToString(index);
      } else {
        suffix = IntToString(index);
      };
    };
    return StringToName("vm_fuel_available_" + suffix);
  }
  private func StationSearchLimit() -> Int32 {
    let runtime: ref<VMRuntimeSystem> = VMRuntimeSystem.Get();
    if IsDefined(runtime) {
      let stationCount: Int32 = runtime.GetGasStationCount();
      if stationCount > 0 {
        return stationCount;
      };
    };
    // Entity assembly can precede runtime station construction. Component
    // suffixes are three digits, so scan that supported range as a fallback.
    return 999;
  }
  private func EnsureWorldWidget(widget: wref<worlduiWidgetComponent>) -> Void {
    if !IsDefined(widget) {
      return;
    };
    widget.isEnabled = true;
    widget.limitedSpawnDistanceFromVehicle = false;
    widget.sceneWidgetProperties.isAlwaysVisible = true;
    widget.sceneWidgetProperties.renderingPlane = ERenderingPlane.RPl_Scene;
    widget.sceneWidgetProperties.projectionPlaneSize.X = 1.0;
    widget.sceneWidgetProperties.projectionPlaneSize.Y = 1.0;
    widget.Toggle(true);
  }
  private func HasTarget(widget: wref<worlduiWidgetComponent>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.targets) {
      if this.targets[i].widget == widget {
        return true;
      };
      i += 1;
    };
    return false;
  }
  protected cb func OnEntityAssemble(event: ref<EntityLifecycleEvent>) -> Void {
    let entity = event.GetEntity();
    if !IsDefined(entity) {
      return;
    };
    // Cheap gate avoids indexed lookups for unrelated assembled entities.
    if !IsDefined(entity.FindComponentByName(n"fuel_available_mesh")) {
      return;
    };
    let index: Int32 = 1;
    let searchLimit: Int32 = this.StationSearchLimit();
    while index <= searchLimit {
      let widget = entity.FindComponentByName(this.ComponentName(index))
        as worlduiWidgetComponent;
      if IsDefined(widget) {
        this.EnsureWorldWidget(widget);
        if !this.HasTarget(widget) {
          let target = new VMFuelAvailableTarget();
          target.widget = widget;
          target.stationIndex = index;
          ArrayPush(this.targets, target);
        };
        this.RequestFastTicks(12);
        return;
      };
      index += 1;
    };
  }
  public func RequestFastTicks(ticks: Int32) -> Void {
    let requested: Int32 = ticks;
    if requested < 1 {
      requested = 1;
    };
    if requested > 80 {
      requested = 80;
    };
    if requested > this.fastTicksLeft {
      this.fastTicksLeft = requested;
    };
    if this.tickArmed {
      this.tickToken += 1;
      this.tickArmed = false;
    };
    this.ArmTick(0.01);
  }
  public func Tick() -> Void {
    let i: Int32 = ArraySize(this.targets) - 1;
    while i >= 0 {
      let target = this.targets[i];
      if !IsDefined(target) || !IsDefined(target.widget) {
        ArrayErase(this.targets, i);
      } else {
        this.EnsureWorldWidget(target.widget);
        let controller = target.widget.GetGameController() as inkFuelAvailable;
        if IsDefined(controller) {
          controller.VM_FuelAvailable_SetVisible(true);
          controller.SetStationIndex(target.stationIndex);
        };
      };
      i -= 1;
    };
    let nextPeriod: Float = this.tickPeriodSlow;
    if this.fastTicksLeft > 0 {
      nextPeriod = this.tickPeriodFast;
      this.fastTicksLeft -= 1;
    };
    this.ArmTick(nextPeriod);
  }
  private func ArmTick(period: Float) -> Void {
    if this.tickArmed {
      return;
    };
    let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
    if !IsDefined(delaySystem) {
      return;
    };
    this.tickToken += 1;
    this.tick = VMFuelAvailableTick.Create(this, this.tickToken);
    this.tickArmed = true;
    delaySystem.DelayCallback(this.tick, period, false);
  }
}
@addField(PlayerPuppet)
private let vmFuelAvailableService: ref<VMFuelAvailableService>;
@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(resolver: EntityResolveComponentsInterface) -> Bool {
  let result = wrappedMethod(resolver);
  if !IsDefined(this.vmFuelAvailableService) {
    this.vmFuelAvailableService = new VMFuelAvailableService();
  };
  this.vmFuelAvailableService.Start();
  return result;
}
