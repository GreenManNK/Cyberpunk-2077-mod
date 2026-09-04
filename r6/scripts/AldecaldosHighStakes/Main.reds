module AldecaldosHighStakes

import AldecaldosHighStakes.Widgets.*

class WidgetService extends ScriptableService {
    private let m_active_widget: ref<BriefPopup>;

    private cb func OnLoad() {
        GameInstance
            .GetCallbackSystem()
            .RegisterCallback(n"Session/Ready", this, n"OnSessionReady");
    }

    private cb func OnSessionReady(event: ref<GameSessionEvent>) {
        if !event.IsPreGame() {
            let axlVersion = StringToFloat(ArchiveXL.Version(), 0);
            FTLog(s"AXL version \(axlVersion)");
            if axlVersion < 1.17 {
                SetFactValue(GetGameInstance(), n"sq_hs_axl_outdated", 1);
            } else {
                SetFactValue(GetGameInstance(), n"sq_hs_axl_outdated", 0);
            }
        }
    }

    public func CloseBriefPopup() -> Void {
        if IsDefined(this.m_active_widget) {
            this.m_active_widget.Close();
        }
    }

    public func ShowBriefPopup() -> Void {
        let inkSystem = GameInstance.GetInkSystem();
        let layers = inkSystem.GetLayers();

        for layer in layers {
            for controller in layer.GetGameControllers() {
                let _controller = controller as gameuiInGameMenuGameController;
                if IsDefined(_controller) {
                    this.m_active_widget = BriefPopup.Show(_controller);
                }
            }
        }
    }
}

@addMethod(PlayerPuppet)
public func TestPopup() -> Void {
    let widgetService = GameInstance
        .GetScriptableServiceContainer()
        .GetService(n"AldecaldosHighStakes.WidgetService") as WidgetService;
    widgetService.ShowBriefPopup();
}

@addMethod(PlayerPuppet)
public func ClosePopup() -> Void {
    let widgetService = GameInstance
        .GetScriptableServiceContainer()
        .GetService(n"AldecaldosHighStakes.WidgetService") as WidgetService;
    widgetService.CloseBriefPopup();
}

@addMethod(PlayerPuppet)
protected cb func OnAldecaldosHighStakesVOEvent(event: ref<ActionEvent>) -> Void {
    let widgetService = GameInstance
        .GetScriptableServiceContainer()
        .GetService(n"AldecaldosHighStakes.WidgetService") as WidgetService;

    switch event.eventAction {
        case n"OpenBriefWidget":
            widgetService.ShowBriefPopup();
            break;
        case n"CloseBriefWidget":
            widgetService.CloseBriefPopup();
            break;
        default:
            FTLog(s"default case: \(event.eventAction)");
            break;
    }
}

@wrapMethod(ShardCaseContainer)
protected cb func OnInteraction(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let currentReadShardTweakID = this.itemTDBID;
    if Equals(currentReadShardTweakID, t"Items.sq_hs_regina_shard") {
        SetFactValue(this.GetGame(), n"sq_high_stakes_regina_shard_read", 1);
    }
    let result: Bool = wrappedMethod(choiceEvent);
    return result;
}
