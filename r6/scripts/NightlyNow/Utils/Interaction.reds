module NightlyNow.Utils

// -----------------------------------------------------------------------------
// Interaction Utils - NightlyNow Core
// -----------------------------------------------------------------------------
public func AddInteractions(
    gameInstance: GameInstance,
    titles: array<String>,
    actions: array<CName>,
    opt isHold: Bool
) -> Bool {
    let defs = GetAllBlackboardDefs();
    let bb = GameInstance.GetBlackboardSystem(gameInstance).Get(defs.UIInteractions);
    let hub: InteractionChoiceHubData = FromVariant(bb.GetVariant(defs.UIInteractions.InteractionChoiceHub));
    if !hub.active {
        ArrayClear(hub.choices);
        hub.active = true;
    }
    let changed = false;
    let i = 0;
    while i < ArraySize(actions) {
        let alreadyPresent = false;
        for choice in hub.choices {
            if Equals(choice.localizedName, titles[i]) && Equals(choice.inputAction, actions[i]) {
                alreadyPresent = true;
            }
        }
        if !alreadyPresent {
            ArrayPush(hub.choices, CreateInteractionChoice(actions[i], titles[i], isHold));
            changed = true;
        }
        i += 1;
    }
    if !changed {
        return false;
    }

    let vis = GenerateVisualizersInfo(hub);
    bb.SetVariant(defs.UIInteractions.InteractionChoiceHub, ToVariant(hub), true);
    bb.SetVariant(defs.UIInteractions.VisualizersInfo, ToVariant(vis), true);
    return true;
}

// Remove the interaction choice from the UI blackboard
public func RemoveInteraction(gameInstance: GameInstance, title: String, action: CName) -> Bool {
    let defs = GetAllBlackboardDefs();
    let bb = GameInstance.GetBlackboardSystem(gameInstance).Get(defs.UIInteractions);
    let hub: InteractionChoiceHubData = FromVariant(bb.GetVariant(defs.UIInteractions.InteractionChoiceHub));
    let target: InteractionChoiceData;
    let found = false;
    for choice in hub.choices {
        if Equals(choice.localizedName, title) && Equals(choice.inputAction, action) {
            target = choice;
            found = true;
        }
    }
    if found {
        ArrayRemove(hub.choices, target);
        let vis = GenerateVisualizersInfo(hub);
        bb
            .SetVariant(defs.UIInteractions.InteractionChoiceHub, ToVariant(hub), true);
        bb.SetVariant(defs.UIInteractions.VisualizersInfo, ToVariant(vis), true);
        return true;
    }
    return false;
}

private func CreateInteractionChoice(action: CName, title: String, opt isHold: Bool) -> InteractionChoiceData {
    let choiceData: InteractionChoiceData;
    choiceData.localizedName = title;
    choiceData.inputAction = action;
    let choiceType: ChoiceTypeWrapper;
    ChoiceTypeWrapper.SetType(choiceType, gameinteractionsChoiceType.Blueline);
    choiceData.type = choiceType;
    return choiceData;
}

private func GenerateVisualizersInfo(choiceHubData: InteractionChoiceHubData) -> VisualizersInfo {
    let visualizersInfo: VisualizersInfo;
    visualizersInfo.activeVisId = choiceHubData.id;
    visualizersInfo.visIds = [choiceHubData.id];
    return visualizersInfo;
}

