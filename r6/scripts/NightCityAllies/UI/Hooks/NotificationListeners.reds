module NightCityAllies.UI.Hooks

import NightCityAllies.*
import NightCityAllies.UI.*

@wrapMethod(GenericNotificationController)
protected cb func OnInitialize() -> Bool {
    let result = wrappedMethod();
    NCA.UI().PushNotification();
    return result;
}

@wrapMethod(GenericNotificationController)
protected cb func OnUninitialize() -> Bool {
    let result = wrappedMethod();
    NCA.UI().PopNotification();
    return result;
}
