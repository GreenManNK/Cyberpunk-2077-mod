module NightlyNow.Utils

import NightlyNow.Settings.Constants

// -----------------------------------------------------------------------------
// Proximity Detection - NightlyNow Core
// -----------------------------------------------------------------------------
// Shared utility for proximity based interaction
public class ProximityDetector extends IScriptable {
    private let interactionTitles: array<String>;
    private let interactionActions: array<CName>;
    private let maxDistance: Float;
    private let checkInterval: Float;
    private let interactionShown: Bool;
    private let isHoldAction: Bool;
    private let checkDelayId: DelayID;
    // Blackboard listener to readd interaction when game clears the hub
    private let hubCallbackHandle: ref<CallbackHandle>;
    private let interactionLock: Bool;

    // Factory methods
    public static func Create(
        interactionTitle: String,
        interactionAction: CName,
        checkInterval: Float,
        opt isHold: Bool,
        opt maxDistance: Float
    ) -> ref<ProximityDetector> {
        let detector = new ProximityDetector();
        detector.interactionTitles = [interactionTitle];
        detector.interactionActions = [interactionAction];
        detector.maxDistance = maxDistance > 0.0 ? maxDistance : Constants.DefaultProximityMaxDistance();
        detector.checkInterval = checkInterval;
        detector.isHoldAction = isHold;
        return detector;
    }

    public static func Create(
        interactionTitles: array<String>,
        interactionActions: array<CName>,
        checkInterval: Float,
        opt isHold: Bool,
        opt maxDistance: Float
    ) -> ref<ProximityDetector> {
        let detector = new ProximityDetector();
        detector.interactionTitles = interactionTitles;
        detector.interactionActions = interactionActions;
        detector.maxDistance = maxDistance > 0.0 ? maxDistance : Constants.DefaultProximityMaxDistance();
        detector.checkInterval = checkInterval;
        detector.isHoldAction = isHold;
        return detector;
    }

    // Show or hide interaction based on proximity flag
    public func UpdateProximity(isNear: Bool) {
        if isNear {
            this.ShowInteraction();
        } else {
            this.HideInteraction();
        }
    }

    // Check if player is within range of any position in the array
    public func IsPlayerNearAny(positions: array<Vector4>) -> Bool {
        let playerPos = GetPlayer(GetGameInstance()).GetWorldPosition();
        for pos in positions {
            if Vector4.Distance(playerPos, pos) <= this.maxDistance {
                return true;
            }
        }
        return false;
    }

    // Check if player is within range of a single position
    public func IsPlayerNearPosition(position: Vector4) -> Bool {
        let playerPos = GetPlayer(GetGameInstance()).GetWorldPosition();
        return Vector4.Distance(playerPos, position) <= this.maxDistance;
    }

    public func IsInteractionShown() -> Bool = this.interactionShown;

    // Schedule next proximity check
    public func QueueProximityCheck(delayCallback: ref<DelayCallback>) {
        let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
        this.checkDelayId = delaySystem.DelayCallback(delayCallback, this.checkInterval, false);
    }

    // Cancel pending proximity check
    public func CancelProximityCheck() {
        let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
        delaySystem.CancelDelay(this.checkDelayId);
    }

    // Hide interaction and reset state
    public func HideInteraction() {
        if !this.interactionShown {
            return;
        }
        this.interactionLock = true;
        let i = 0;
        while i < ArraySize(this.interactionActions) {
            RemoveInteraction(
                GetGameInstance(),
                this.interactionTitles[i],
                this.interactionActions[i]
            );
            i += 1;
        }
        this.interactionLock = false;
        this.interactionShown = false;
        this.StopListeningForHubChanges();
    }

    private func ShowInteraction() {
        this.interactionLock = true;
        AddInteractions(
            GetGameInstance(),
            this.interactionTitles,
            this.interactionActions,
            this.isHoldAction
        );
        this.interactionLock = false;
        this.interactionShown = true;
        this.StartListeningForHubChanges();
    }

    // Here we need to intercept hub interactions as it would get glitchy otherwise
    private cb func OnInteractionHubChanged(value: Variant) {
        if !this.interactionShown || this.interactionLock {
            return;
        }
        this.interactionLock = true;
        AddInteractions(
            GetGameInstance(),
            this.interactionTitles,
            this.interactionActions,
            this.isHoldAction
        );
        this.interactionLock = false;
    }

    // Register blackboard listener on InteractionChoiceHub
    private func StartListeningForHubChanges() {
        if IsDefined(this.hubCallbackHandle) {
            return;
        }
        let defs = GetAllBlackboardDefs();
        let bb = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);
        this.hubCallbackHandle = bb
            .RegisterListenerVariant(
                defs.UIInteractions.InteractionChoiceHub,
                this,
                n"OnInteractionHubChanged"
            );
    }

    // Unregister blackboard listener
    private func StopListeningForHubChanges() {
        if !IsDefined(this.hubCallbackHandle) {
            return;
        }
        let defs = GetAllBlackboardDefs();
        let bb = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);
        bb
            .UnregisterListenerVariant(defs.UIInteractions.InteractionChoiceHub, this.hubCallbackHandle);
        this.hubCallbackHandle = null;
    }
}

