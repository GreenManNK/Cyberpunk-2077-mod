module NightCityAllies.Event.Hooks

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Event.*
import NightCityAllies.Settings.*

// Blackboard Listeners
public class BlackboardListeners extends ScriptableSystem {
    private let m_menuListener: ref<CallbackHandle>;
    private let m_phoneListener: ref<CallbackHandle>;
    private let m_radialListener: ref<CallbackHandle>;
    private let m_scannerListener: ref<CallbackHandle>;
    private let m_quickHackListener: ref<CallbackHandle>;
    private let m_gameplayTierChangeListener: ref<CallbackHandle>;
    private let m_elevatorListener: ref<CallbackHandle>;

    public static func Register() -> Void {
        let system: ref<BlackboardListeners> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<BlackboardListeners>()) as BlackboardListeners;
        system.RegisterListeners();
    }

    public static func Unregister() -> Void {
        let system: ref<BlackboardListeners> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<BlackboardListeners>()) as BlackboardListeners;
        system.UnregisterListeners();
    }

    public func RegisterListeners() -> Void {
        let player = GetPlayer(GetGameInstance());
        let bbSystem = GameInstance.GetBlackboardSystem(player.GetGame());
        let allBbDefs = GetAllBlackboardDefs();
        
        // 1. Main Menu (Inventory, Map, Stats)
        let uiSystemBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_System);
        this.m_menuListener = uiSystemBB.RegisterListenerBool(allBbDefs.UI_System.IsInMenu, this, n"UpdateContext");

        // 2. Phone
        let phoneBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_ComDevice);
        this.m_phoneListener = phoneBB.RegisterListenerBool(allBbDefs.UI_ComDevice.ContactsActive, this, n"UpdateContext");

        // 3. Radial Menu
        let radialBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_QuickSlotsData);
        this.m_radialListener = radialBB.RegisterListenerBool(allBbDefs.UI_QuickSlotsData.UIRadialContextRequest, this, n"UpdateContext");

        // 4. Scanner
        let scannerBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_Scanner);
        this.m_scannerListener = scannerBB.RegisterListenerBool(allBbDefs.UI_Scanner.UIVisible, this, n"UpdateContext");

        // 5. Quick Hack Menu
        let quickHackBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_QuickSlotsData);
        this.m_quickHackListener = quickHackBB.RegisterListenerBool(allBbDefs.UI_QuickSlotsData.quickhackPanelOpen, this, n"UpdateContext");

        // 6. Scene Tier
        let playerBB: ref<IBlackboard> = bbSystem.GetLocalInstanced(player.GetEntityID(), allBbDefs.PlayerStateMachine);
        this.m_gameplayTierChangeListener = playerBB.RegisterListenerInt(allBbDefs.PlayerStateMachine.SceneTier, this, n"OnSceneTierChange", true);

        // 7. Elevator
        this.m_elevatorListener = playerBB.RegisterListenerBool(allBbDefs.PlayerStateMachine.IsPlayerInsideElevator, this, n"OnElevatorChange", true);
    }

    private func UnregisterListeners() -> Void {
        let player = GetPlayer(GetGameInstance());
        let bbSystem = GameInstance.GetBlackboardSystem(player.GetGame());
        let allBbDefs = GetAllBlackboardDefs();

        // 1. Main Menu (Inventory, Map, Stats)
        let uiSystemBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_System);
        uiSystemBB.UnregisterListenerBool(allBbDefs.UI_System.IsInMenu, this.m_menuListener);
        this.m_menuListener = null;

        // 2. Phone
        let phoneBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_ComDevice);
        phoneBB.UnregisterListenerBool(allBbDefs.UI_ComDevice.ContactsActive, this.m_phoneListener);
        this.m_phoneListener = null;

        // 3. Radial Menu
        let radialBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_QuickSlotsData);
        radialBB.UnregisterListenerBool(allBbDefs.UI_QuickSlotsData.UIRadialContextRequest, this.m_radialListener);
        this.m_radialListener = null;

        // 4. Scanner
        let scannerBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_Scanner);
        scannerBB.UnregisterListenerBool(allBbDefs.UI_Scanner.UIVisible, this.m_scannerListener);
        this.m_scannerListener = null;

        // 5. Quick Hack Menu
        let quickHackBB: ref<IBlackboard> = bbSystem.Get(allBbDefs.UI_QuickSlotsData);
        quickHackBB.UnregisterListenerBool(allBbDefs.UI_QuickSlotsData.quickhackPanelOpen, this.m_quickHackListener);
        this.m_quickHackListener = null;

        // 6. Scene Tier
        let playerBB: ref<IBlackboard> = bbSystem.GetLocalInstanced(player.GetEntityID(), allBbDefs.PlayerStateMachine);
        playerBB.UnregisterListenerInt(allBbDefs.PlayerStateMachine.SceneTier, this.m_gameplayTierChangeListener);
        this.m_gameplayTierChangeListener = null;

        // 7. Elevator
        playerBB.UnregisterListenerBool(allBbDefs.PlayerStateMachine.IsPlayerInsideElevator, this.m_elevatorListener);
        this.m_elevatorListener = null;
    }

    protected cb func OnSceneTierChange(value: Int32) -> Void {
        let previous: Int32 = EnumInt(NCA.Context().gameplayTier);
        NCA.Context().gameplayTier = IntEnum<GameplayTier>(value);
        NCA.Events().OnContextChange(NCA.Context());

        if (value == previous) {
            return;
        }

        if (value > previous && value > EnumInt(NCA.Settings().maxGameplayTier)) {
            NCA.Context().isRestrictedTier = true;
            NCA.Events().OnEnterRestrictedTier();
        }

        if (value < previous && value <= EnumInt(NCA.Settings().maxGameplayTier)) {
            NCA.Context().isRestrictedTier = false;
            NCA.Events().OnExitRestrictedTier();
        }
    }

    protected cb func OnElevatorChange(value: Bool) -> Void {
        let context = NCA.Context();

        if (!context.isInElevator && value) {
            context.isInElevator = true;
            NCA.Events().OnEnterElevator();
            NCA.Events().OnContextChange(context);
        }

        if (context.isInElevator && !value) {
            context.isInElevator = false;
            NCA.Events().OnExitElevator();
            NCA.Events().OnContextChange(context);
        }
    }

    protected cb func UpdateContext(value: Bool) -> Bool {
        let context = NCA.Context();

        if (!context.isInMenu && value) {
            context.isInMenu = true;
            NCA.Events().OnEnterMenu();
            NCA.Events().OnContextChange(context);
        } 

        if (context.isInMenu && !value) {
            context.isInMenu = false;
            NCA.Events().OnExitMenu();
            NCA.Events().OnContextChange(context);
        }
    }
}