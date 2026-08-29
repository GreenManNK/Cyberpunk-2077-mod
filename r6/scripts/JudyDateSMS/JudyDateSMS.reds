module JudyDateSMS

@addMethod(BaseMappinBaseController)
protected final func __jdIsJudyPin() -> Bool {
  let cap: String = this.GetMappin().GetDisplayName();
  let parts: array<String> = StrSplit(cap, "|");
  return ArraySize(parts) > 0
    && (Equals(parts[0], "JudyDate") || Equals(parts[0], "JudyHangout"));
}

@addMethod(BaseMappinBaseController)
protected final func __jdApplyJudyIconScale(opt forMinimap: Bool) -> Void {
  if !this.__jdIsJudyPin() { return; }
  if forMinimap {
    inkWidgetRef.SetScale(this.iconWidget, new Vector2(0.85, 0.85));
  }
}

@wrapMethod(MinimapPOIMappinController)
protected final func UpdateIcon() -> Void {
  wrappedMethod();
  this.__jdApplyJudyIconScale(true);
}

@wrapMethod(MinimapDeviceMappinController)
protected func Update() -> Void {
  wrappedMethod();
  this.__jdApplyJudyIconScale(true);
}

@wrapMethod(QuestMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.__jdApplyJudyIconScale(false);
}

@wrapMethod(GameplayMappinController)
private func UpdateIcon() -> Void {
  wrappedMethod();
  if IsDefined(this.m_mappin) && this.__jdIsJudyPin() {
    this.__jdApplyJudyIconScale(false);
  }
}

@wrapMethod(BaseWorldMapMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.__jdApplyJudyIconScale(false);
}

@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
  wrappedMethod(data, menu);
  let cap: String = Deref(data).mappin.GetDisplayName();
  let parts: array<String> = StrSplit(cap, "|");
  if ArraySize(parts) >= 3
    && (Equals(parts[0], "JudyDate") || Equals(parts[0], "JudyHangout")) {
    inkTextRef.SetText(this.m_titleText, parts[1]);
    inkTextRef.SetText(this.m_descText, parts[2]);
  }
}

// Cyberpunk 2.x custom SMS notification flow.
// Based on the current contact-hash approach used by Night City Allies.
@if(!ModuleExists("PhoneExtension.Classes"))
@addField(UsePhoneRequest)
public let judyDateContactHash: Int32;

@if(!ModuleExists("PhoneExtension.Classes"))
public class JudyDateOpenPhoneMessageAction extends OpenPhoneMessageAction {
  public let m_judyDateContactHash: Int32;

  public func Execute(data: ref<IScriptable>) -> Bool {
    let request: ref<UsePhoneRequest> = new UsePhoneRequest();
    request.judyDateContactHash = this.m_judyDateContactHash;
    this.m_phoneSystem.QueueRequest(request);
    return true;
  }
}

@if(!ModuleExists("PhoneExtension.Classes"))
@wrapMethod(PhoneSystem)
private final func OnUsePhone(request: ref<UsePhoneRequest>) -> Void {
  if Equals(request.judyDateContactHash, 1806317291) {
    let player = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject();

    if this.IsPhoneOpened() {
      return;
    };

    if !this.IsPhoneEnabled() {
      GameInstance.GetUISystem(player.GetGame()).QueueEvent(new UIInGameNotificationRemoveEvent());
      let notificationEvent = new UIInGameNotificationEvent();
      notificationEvent.m_notificationType = UIInGameNotificationType.CombatRestriction;
      GameInstance.GetUISystem(player.GetGame()).QueueEvent(notificationEvent);
      return;
    };

    // Passing the custom contact hash to MessageToOpenHash opens Judy's message thread.
    if !this.m_ContactsOpen {
      this.m_Blackboard.SetInt(GetAllBlackboardDefs().UI_ComDevice.MessageToOpenHash, request.judyDateContactHash, true);
      this.ToggleContacts(true);
      return;
    };
    return;
  };

  wrappedMethod(request);
}

@if(!ModuleExists("PhoneExtension.Classes"))
@addMethod(NewHudPhoneGameController)
public func PushJudyDateSMSNotification(contactHash: Int32, notificationTitle: String, notificationText: String) -> Void {
  let action: ref<JudyDateOpenPhoneMessageAction> = new JudyDateOpenPhoneMessageAction();
  action.m_phoneSystem = this.m_PhoneSystem;
  action.m_judyDateContactHash = contactHash;

  let notificationData: gameuiGenericNotificationData;
  let userData: ref<PhoneMessageNotificationViewData> = new PhoneMessageNotificationViewData();
  userData.contactHash = contactHash;
  userData.title = notificationTitle;
  userData.SMSText = notificationText;
  userData.action = action;
  userData.animation = n"notification_phone_MSG";
  userData.soundEvent = n"PhoneSmsPopup";
  userData.soundAction = n"OnOpen";

  notificationData.time = 6.70;
  notificationData.widgetLibraryItemName = n"notification_message";
  notificationData.notificationData = userData;
  this.AddNewNotificationData(notificationData);
}
