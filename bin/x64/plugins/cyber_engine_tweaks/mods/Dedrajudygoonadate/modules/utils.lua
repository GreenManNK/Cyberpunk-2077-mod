local utils = {}

function utils.showNewContact(journalQ, icon, title, duration)
  if not journalQ then return end
  pcall(function()
    local data = gameuiGenericNotificationData.new()
    local userData = gameuiGenericNotificationData.new()
    data.time = duration or 5.0
    data.widgetLibraryItemName = CName("notification_message")
    data.notificationData = userData
    journalQ:AddNewNotificationData(data)
  end)
end

return utils
