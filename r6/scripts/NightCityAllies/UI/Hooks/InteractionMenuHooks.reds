module NightCityAllies.UI.Hooks

import NightCityAllies.*
import NightCityAllies.UI.*

@wrapMethod(InteractionUIBase)
protected cb func OnDialogsData(value: Variant) -> Bool {
    let menu = NCA.InteractionMenu();

    if !IsDefined(menu) || !menu.IsShown() {
        return wrappedMethod(value);
    }

    let data: DialogChoiceHubs = FromVariant<DialogChoiceHubs>(value);
    ArrayPush(data.choiceHubs, menu.GetHub());

    return wrappedMethod(ToVariant(data));
}

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let result = wrappedMethod(action, consumer);

    let menu = NCA.InteractionMenu();

    if IsDefined(menu) {
        menu.HandleAction(action, consumer);
    }

    return result;
}

@wrapMethod(dialogWidgetGameController)
protected cb func OnDialogsSelectIndex(index: Int32) -> Bool {
    let menu = NCA.InteractionMenu();

    if IsDefined(menu) && menu.OwnsCursor() && index != menu.GetSelectedIndex() {
        return false;
    }

    return wrappedMethod(index);
}

@wrapMethod(dialogWidgetGameController)
protected cb func OnDialogsActivateHub(activeHubId: Int32) -> Bool {
    let menu = NCA.InteractionMenu();

    if IsDefined(menu) && menu.OwnsCursor() && activeHubId != menu.GetHubId() {
        return false;
    }

    return wrappedMethod(activeHubId);
}
