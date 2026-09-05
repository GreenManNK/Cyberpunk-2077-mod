module NightCityAllies.UI

import Codeware.UI.VirtualResolutionWatcher
import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Persistence.*
import NightCityAllies.Settings.*
import NightCityAllies.Localization.*

public class UISystem extends ScriptableSystem {
    private let m_controller: ref<SquadContainerController>;
    private let m_resWatcher: ref<VirtualResolutionWatcher>;
    private let m_addWidgetRequests: array<ref<NpcHandle>>;
    private let m_isHiddenByMenu: Bool;
    private let m_notificationCount: Int32;
    private let m_equipmentPanelNpc: ref<NpcHandle>;
    private let m_equipmentPanelData: ref<inkGameNotificationData>;
    private let m_equipmentPanelToken: ref<inkGameNotificationToken>;
    private let m_equipmentPanelController: ref<NCAEquipmentPanelController>;

    public func AddSquadMemberWidget(npc: ref<NpcHandle>) -> Void {
        if Equals(NCA.Context().isSessionStarted, true) {
            this.m_controller.AddMember(npc);
        } else {
            ArrayPush(this.m_addWidgetRequests, npc);
        }
    }

    public func ActivateWidgetsAfterSessionStart() -> Void {
        this.m_notificationCount = 0;

        let i: Int32 = 0;
        while i < ArraySize(this.m_addWidgetRequests) {
            this.m_controller.AddMember(this.m_addWidgetRequests[i]);
            i += 1;
        }
        ArrayClear(this.m_addWidgetRequests);
    }

    public func RemoveAllSquadMemberWidgets() -> Void {
        this.m_controller.ClearMembers();
    }

    // TODO make event driven
    public func RefreshSquadHeader() -> Void {
        if !IsDefined(this.m_controller) {
            return;
        }

        this.m_controller.RefreshHeader();
    }

    public func OpenEquipmentPanel(npc: ref<NpcHandle>) -> Void {
        if !IsDefined(this.m_controller) || IsDefined(this.m_equipmentPanelToken) {
            return;
        }

        let data = new inkGameNotificationData();
        data.notificationName = NCAEquipmentPanel.WidgetName();
        data.queueName = NCAEquipmentPanel.QueueName();
        data.isBlocking = true;
        data.useCursor = true;

        this.m_equipmentPanelNpc = npc;
        this.m_equipmentPanelData = data;
        this.m_equipmentPanelToken = this.m_controller.ShowNotification(data);

        NCA.InteractionMenu().SetSuppressed(true);
    }

    public func OnEquipmentPanelClosed() -> Void {
        this.m_equipmentPanelController = null;

        NCA.InteractionMenu().SetSuppressed(false);
    }

    public func RegisterEquipmentPanel(controller: ref<NCAEquipmentPanelController>) -> Void {
        this.m_equipmentPanelController = controller;
    }

    public func HandleEquipmentPanelAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Void {
        if IsDefined(this.m_equipmentPanelController) {
            this.m_equipmentPanelController.HandleAction(action, consumer);
        }
    }

    public func CloseEquipmentPanel() -> Void {
        if !IsDefined(this.m_equipmentPanelToken) {
            return;
        }

        let token: ref<inkGameNotificationToken> = this.m_equipmentPanelToken;
        let data: ref<inkGameNotificationData> = this.m_equipmentPanelData;

        this.m_equipmentPanelToken = null;
        this.m_equipmentPanelData = null;
        this.m_equipmentPanelNpc = null;

        token.TriggerCallback(data);
    }

    public func GetEquipmentPanelNpc() -> ref<NpcHandle> {
        return this.m_equipmentPanelNpc;
    }

    public func RegisterWidgets(fullScreenSlot: ref<inkCompoundWidget>, controller: ref<SquadContainerController>) -> Void {
        this.m_controller = controller;
        this.m_resWatcher = new VirtualResolutionWatcher();
        this.m_resWatcher.Initialize(GetGameInstance());
        this.m_resWatcher.ScaleWidget(fullScreenSlot);

        this.UpdateVisibility();
    }

    public func Open() {
        this.m_isHiddenByMenu = false;
        this.UpdateVisibility();
    }

    public func Close() {
        this.m_isHiddenByMenu = true;
        this.UpdateVisibility();
    }

    public func PushNotification() -> Void {
        this.m_notificationCount += 1;
        this.UpdateVisibility();
    }

    public func PopNotification() -> Void {
        if (this.m_notificationCount <= 0) {
            return;
        }

        this.m_notificationCount -= 1;
        this.UpdateVisibility();
    }

    // For applying settings
    public func RefreshSquadHUD() -> Void {
        if !IsDefined(this.m_controller) {
            return;
        }

        this.m_controller.ApplyTransform();

        if !NCA.Settings().showSquadHUD {
            this.m_controller.Close();
            return;
        }

        this.UpdateVisibility();
    }

    public func RefreshVisibility() -> Void {
        this.UpdateVisibility();
    }

    private func UpdateVisibility() -> Void {
        if (!IsDefined(this.m_controller) || !NCA.Settings().showSquadHUD) {
            return;
        }

        let hiddenByNotification: Bool = this.m_notificationCount > 0 && !NCA.Context().isInCombat; // always show in combat

        if (this.m_isHiddenByMenu || hiddenByNotification) {
            this.m_controller.Close();
        } else {
            this.m_controller.Open();
        }
    }
}


@addField(healthbarWidgetGameController)
private let m_squadList: inkCompoundRef;

@wrapMethod(healthbarWidgetGameController)
protected cb func OnInitialize() -> Bool {
    let result = wrappedMethod();

    let inkHUD = GameInstance.GetInkSystem().GetLayer(n"inkHUDLayer").GetVirtualWindow();
    let hudRoot = inkHUD.GetWidgetByPathName(n"Root") as inkCompoundWidget;

    if !IsDefined(hudRoot) {
        return result;
    }

    let canvas = new inkCanvas();
    canvas.SetName(n"NCAUICanvas");
    canvas.SetSize(Vector2(3840.0, 2160.0));
    canvas.SetRenderTransformPivot(Vector2(0.0, 0.0));
    canvas.SetInteractive(false);
    canvas.Reparent(hudRoot);

    let widget: wref<inkWidget> = this.SpawnFromExternal(inkWidgetRef.Get(this.m_squadList), r"nca\\gameplay\\gui\\widgets\\squad.inkwidget", n"Root");
    widget.Reparent(canvas);

    let widgetController = widget.GetController() as SquadContainerController;
    widgetController.Setup();

    NCA.UI().RegisterWidgets(canvas, widgetController);

    return result;
}
