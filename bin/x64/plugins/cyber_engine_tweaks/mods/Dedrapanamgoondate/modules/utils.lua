local utils = {}

function utils.showNewContact(journalQ, title, name, duration)
    local notificationData = gameuiGenericNotificationData.new()

    local userData = QuestUpdateNotificationViewData.new()
    userData.title = title
    userData.text = name
    userData.animation = "notification_newContactAdded"
    userData.soundEvent = "QuestUpdatePopup"
    userData.soundAction = "OnOpen"

    notificationData.time = duration
    notificationData.widgetLibraryItemName = "notification_NewContactAdded"
    notificationData.notificationData = userData

    journalQ:AddNewNotificationData(notificationData)
end

return utils
