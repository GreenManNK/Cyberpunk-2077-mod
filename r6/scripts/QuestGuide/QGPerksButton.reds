module QuestGuide
import Codeware.Localization.*

public class QGPerksButton extends inkLogicController {
  private let m_owner: wref<PlayerPuppet>;
  private let m_screen: wref<inkWidget>;

  public func QGSetup(owner: ref<PlayerPuppet>, screen: ref<inkWidget>) -> Void {
    this.m_owner = owner;
    this.m_screen = screen;
  }

  protected cb func OnQGClick(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsAction(n"click") {
      return false;
    };
    if IsDefined(this.m_owner) && IsDefined(this.m_screen) {
      this.m_owner.m_qgPopup = QuestGuidePopup.ShowFromMenu(this.m_owner, this.m_screen);
    };
    return false;
  }
}

public func QGFindText(root: ref<inkCompoundWidget>) -> ref<inkText> {
  if !IsDefined(root) {
    return null;
  };
  let i: Int32 = 0;
  while i < root.GetNumChildren() {
    let child: ref<inkWidget> = root.GetWidgetByIndex(i);
    let asText: ref<inkText> = child as inkText;
    if IsDefined(asText) {
      return asText;
    };
    let deeper: ref<inkText> = QGFindText(child as inkCompoundWidget);
    if IsDefined(deeper) {
      return deeper;
    };
    i += 1;
  };
  return null;
}

@if(ModuleExists("CustomPerkFramework"))
public func QGCustomPerkFrameworkInstalled() -> Bool {
  return true;
}

@if(!ModuleExists("CustomPerkFramework"))
public func QGCustomPerkFrameworkInstalled() -> Bool {
  return false;
}

@if(ModuleExists("DroneCompanion"))
public func QGDroneCompanionInstalled() -> Bool {
  return true;
}

@if(!ModuleExists("DroneCompanion"))
public func QGDroneCompanionInstalled() -> Bool {
  return false;
}

@addField(NewPerksCategoriesGameController)
let m_qgButton: wref<inkWidget>;

@addField(NewPerksCategoriesGameController)
let m_qgButtonLogic: ref<QGPerksButton>;

@addMethod(NewPerksCategoriesGameController)
protected cb func OnQGScreenBlock(evt: ref<inkPointerEvent>) -> Bool {
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  if !IsDefined(player) {
    return false;
  };
  let holder: ref<QGMenuHolder> = QGMenuHolder.Get(player.GetGame());
  if IsDefined(holder) && holder.QGIsOpenNow()
    && (evt.IsAction(n"next_menu") || evt.IsAction(n"prior_menu")
      || evt.IsAction(n"next_sub_menu") || evt.IsAction(n"prior_sub_menu")) {
    evt.Consume();
  };
  return false;
}

@wrapMethod(NewPerksCategoriesGameController)
protected cb func OnUninitialize() -> Bool {
  this.UnregisterFromGlobalInputCallback(n"OnPreOnPress", this, n"OnQGScreenBlock");
  let player: ref<PlayerPuppet> = this.GetPlayerControlledObject() as PlayerPuppet;
  if IsDefined(player) {
    let holder: ref<QGMenuHolder> = QGMenuHolder.Get(player.GetGame());
    if IsDefined(holder) {
      holder.QGRestore();
    };
  };
  return wrappedMethod();
}

@wrapMethod(NewPerksCategoriesGameController)
protected cb func OnInitialize() -> Bool {
  let result: Bool = wrappedMethod();
  if IsDefined(this.m_qgButton) {
    return result;
  };

  let sibling: ref<inkWidget> = inkWidgetRef.Get(this.m_skillsScreenButton);
  if !IsDefined(sibling) {
    return result;
  };
  let parent: ref<inkCompoundWidget> = sibling.GetParentWidget() as inkCompoundWidget;
  if !IsDefined(parent) {
    return result;
  };

  let base: inkMargin = sibling.GetMargin();
  let size: Vector2 = sibling.GetSize();
  let slots: Float = 1.0
    + (QGCustomPerkFrameworkInstalled() ? 1.0 : 0.0)
    + (QGDroneCompanionInstalled() ? 1.0 : 0.0);
  let lift: Float = (size.Y + 20.0) * slots;

  let spawned: ref<inkWidget> = this.SpawnFromExternal(parent,
    r"base\\gameplay\\gui\\fullscreen\\inventory\\inventory_screen.inkwidget",
    n"HyperlinkButton");
  if !IsDefined(spawned) {
    return result;
  };

  let holder: ref<inkWidget> = spawned;
  holder.SetName(n"qgQuestGuideButton");
  holder.SetAnchor(sibling.GetAnchor());
  holder.SetAnchorPoint(sibling.GetAnchorPoint());
  holder.SetMargin(inkMargin(base.left, base.top - lift, base.right, base.bottom + lift));
  holder.SetInteractive(true);
  holder.SetSupportFocus(true);

  let label: ref<inkText> = QGFindText(holder as inkCompoundWidget);
  if IsDefined(label) {
    label.SetText(LocalizationSystem.GetInstance(this.GetPlayerControlledObject().GetGame()).GetText("Mod-QuestGuide-PerksButton"));
    label.SetLetterCase(textLetterCase.UpperCase);
    label.SetFontSize(34);
    label.SetWrapping(false, 0.0);
  };

  let logic: ref<QGPerksButton> = new QGPerksButton();
  logic.QGSetup(this.GetPlayerControlledObject() as PlayerPuppet, this.GetRootCompoundWidget());
  this.m_qgButtonLogic = logic;
  holder.RegisterToCallback(n"OnRelease", logic, n"OnQGClick");

  this.m_qgButton = holder;
  this.RegisterToGlobalInputCallback(n"OnPreOnPress", this, n"OnQGScreenBlock");
  return result;
}
