local Cron = require("modules/Cron")
local lang = require("modules/lang")
local utils = require("modules/utils")

messenger = {}

function messenger:new(pm)
    local o = {}

    o.pm = pm
    o.contacts = {}
    o.journalQ = nil

    -- Identifiers
    o.CONTACT_KEY = "panamDate"
    o.CONTACT_ID  = "panamDate_contact"
    o.CONTACT_HASH = 1502709311 -- stable Int32-safe hash for cross-mod compatibility

    -- Message ids (used by our injected renderer + dialog)
    o.MSG_IN_ID   = "panamDate_msg_in"
    o.MSG_OUT_ID  = "panamDate_msg_out"

    self.__index = self
    return setmetatable(o, self)
end

local function safeReadLocKeyValue(data)
    if not data then return nil end
    local ok, value = pcall(function()
        if data.contactNameLocKey and data.contactNameLocKey.value then
            return data.contactNameLocKey.value
        end
        return nil
    end)
    if ok then return value end
    return nil
end

local function safeReadJournalId(data)
    if not data then return nil end
    local ok, value = pcall(function()
        if data.journalEntry and data.journalEntry.id then
            return data.journalEntry.id
        end
        return nil
    end)
    if ok then return value end
    return nil
end

local function factGet(key)
    local qs = Game.GetQuestsSystem()
    if not qs then return 0 end
    return tonumber((qs:GetFactStr(key) or "0")) or 0
end

local function factSet(key, val)
    local qs = Game.GetQuestsSystem()
    if not qs then return end
    qs:SetFactStr(key, tonumber(val) or 0)
end

local function checkPanamRomanced()
    local qs = Game.GetQuestsSystem()
    if not qs then return false end
    local fact = tonumber((qs:GetFactStr("sq027_panam_lover") or "0")) or 0
    return fact == 1
end

function messenger:setup()

    -- Needed so we can push notifications
    Observe("JournalNotificationQueue", "OnMenuUpdate", function(this) self.journalQ = this end)
    Observe("JournalNotificationQueue", "OnPlayerAttach", function(this) self.journalQ = this end)
    Observe("JournalNotificationQueue", "OnInitialize", function(this) self.journalQ = this end)

    -- Make the popup open our thread when the contact name matches our localized key
    Override("PhoneMessagePopupGameController", "OnInitialize", function(this, wrapped)
        wrapped()

        local data = this and this.data
        if not data then return end

        local isPanamByJournal = (safeReadJournalId(data) == self.CONTACT_ID)
        local locValue = safeReadLocKeyValue(data)
        local key = locValue and lang.getKey(locValue) or nil
        local isPanamByName = (key == "contactName")

        if isPanamByJournal or isPanamByName then
            pcall(function()
                this.data.journalEntry = JournalContact.new()
                this.data.journalEntry.id = self.CONTACT_ID
                this:SetupData()
            end)
        end
    end)

    Override("PhoneMessagePopupGameController", "OnRefresh", function(this, event, wrapped)
        local data = event and event.data
        if not data then
            wrapped(event)
            return
        end

        local isPanamByJournal = (safeReadJournalId(data) == self.CONTACT_ID)
        local locValue = safeReadLocKeyValue(data)
        local key = locValue and lang.getKey(locValue) or nil
        local isPanamByName = (key == "contactName")

        if isPanamByJournal or isPanamByName then
            pcall(function()
                this.data = data
                this.data.journalEntry = JournalContact.new()
                this.data.journalEntry.id = self.CONTACT_ID
                this:SetupData()
            end)
            return
        end

        wrapped(event)
    end)

    -- Inject our contact into messenger lists (threads list)
    Override("MessengerUtils", "GetSimpleContactDataArray;JournalManagerBoolBoolBoolMessengerContactSyncData",
        function(journal, includeUnknown, skipEmpty, includeWithNoUnread, activeDataSync, wrapped)

        local contacts = wrapped(journal, includeUnknown, skipEmpty, includeWithNoUnread, activeDataSync) or {}

        -- Only inject contact if it's not in "nothing" category (end-stage cleanup)
        if self.contacts and self.contacts[self.CONTACT_KEY] and self.selectedCategory ~= "nothing" then
            for _, data in pairs(self.contacts) do
                local c = ContactData.new()
                c.hash = data.hash
                c.localizedName = lang.getText("contactName")
                c.id = self.CONTACT_KEY
                c.contactId = self.CONTACT_ID
                c.isCallable = true
                c.type = MessengerContactType.SingleThread
                c.questRelated = false

                -- Avatar is optional, Unknown is safest.
                c.avatarID = TweakDBID.new("PhoneAvatars.Avatar_Panam")
                c.localizedPreview = self.selectedMessage or ""
                c.hasValidTitle = true
                c.timeStamp = data.time

                table.insert(contacts, c)
            end
        end

        return contacts
    end)

    -- Inject into contacts list (the contacts screen)
    Override("JournalManager", "GetContactDataArray", function(_, includeUnknown, includeUncallable, wrapped)
        local contacts = wrapped(includeUnknown, includeUncallable) or {}

        -- Only inject contact if it's not in "nothing" category (end-stage cleanup)
        if self.contacts and self.contacts[self.CONTACT_KEY] and self.selectedCategory ~= "nothing" then
            for _, data in pairs(self.contacts) do
                local c = ContactData.new()
                c.hash = data.hash
                c.localizedName = lang.getText("contactName")
                c.id = self.CONTACT_KEY
                c.contactId = self.CONTACT_ID
                c.isCallable = true
                c.type = MessengerContactType.Contact
                c.questRelated = false
                c.avatarID = TweakDBID.new("PhoneAvatars.Avatar_Panam")
                c.timeStamp = data.time

                table.insert(contacts, c)
            end
        end

        return contacts
    end)

    -- Render our message ids as real bubbles (incoming vs sent)
    Override("MessangerItemRenderer", "OnJournalEntryUpdated", function(this, entry, extra, wrapped)
        wrapped(entry, extra)

        if entry and entry.id == self.MSG_IN_ID then
            this:SetMessageView(self.selectedMessage, MessageViewType.Received, lang.getText("contactName")) -- FIXED
        elseif entry and entry.id == self.MSG_OUT_ID then
            this:SetMessageView(lang.getText("vReply"), MessageViewType.Sent, lang.getText("contactName"))
        end
    end)

    -- Build the thread contents when you open Panam’s conversation
    ObserveAfter("MessengerDialogViewController", "UpdateData;BoolBool", function(this, a, _, _)
        if this.parentEntry and this.parentEntry.id == self.CONTACT_ID then

            local msgs = {}

            -- Only show incoming message if it's not from "nothing" category
            if self.selectedCategory ~= "nothing" then
                local m1 = JournalPhoneMessage.new()
                m1.id = self.MSG_IN_ID
                table.insert(msgs, m1)
            end

            if factGet(self.CONTACT_KEY .. "_replied") == 1 then
                local m2 = JournalPhoneMessage.new()
                m2.id = self.MSG_OUT_ID
                table.insert(msgs, m2)
            end

            this.messages = msgs

            inkWidgetRef.SetVisible(this.replayFluff, #this.replyOptions > 0)
            this:SetVisited(this.messages)

            this.messagesListController:Clear()
            this.messagesListController:PushEntries(this.messages)

            this.choicesListController:Clear()
            this.choicesListController:PushEntries(this.replyOptions)

            if #(this.replyOptions) > 0 then
                this.choicesListController:SetSelectedIndex(0)
            end

            if IsDefined(this.newMessageAninmProxy) then
                this.newMessageAninmProxy:Stop()
            end

            local countMessages = this.messagesListController:Size()
            local lastMessageWidget = nil
            if a and countMessages > 0 then
                lastMessageWidget = this.messagesListController:GetItemAt(countMessages - 1)
            end
            if IsDefined(lastMessageWidget) then
                this.newMessageAninmProxy = this:PlayLibraryAnimationOnAutoSelectedTargets("new_message", lastMessageWidget)
            end

            this.scrollController:SetScrollPosition(1.00)
        end
    end)
end

function messenger:ensureContactWhenReady()
    if Game.GetQuestsSystem():GetFactStr("q001_wakeup_scene_done") == 1 then
        self:addContact()
    else
        Cron.Every(5, function(timer)
            if Game.GetQuestsSystem():GetFactStr("q001_wakeup_scene_done") == 1 then
                self:addContact()
                timer:Halt()
            end
        end)
    end
end

function messenger:addContact()
    if self.contacts[self.CONTACT_KEY] then return end
    
    -- Only add contact if player has romanced Panam
    if not checkPanamRomanced() then
        return
    end

    -- Use 'nothing' category only during initial romance check phase (before 2-4 day cooldown)
    self.selectedCategory = "nothing"
    self.selectedMessage = lang.getRandomFromCategory(self.selectedCategory)

    -- No reply category needed for 'nothing' messages during this phase
    local replyCategory = self.selectedCategory .. "Replies"
    self.selectedReply = lang.getRandomFromCategory(replyCategory)

    local showedFact = self.CONTACT_KEY .. "_showed"

    local t = Game.GetTimeSystem():GetGameTime()
    self.contacts[self.CONTACT_KEY] = { hash = self.CONTACT_HASH, time = t }

    if factGet(showedFact) == 0 then
        factSet(showedFact, 1)
        -- Show the new contact animation shortly after
        Cron.After(2.0, function()
            if self.journalQ then
                utils.showNewContact(self.journalQ, "", lang.getText("contactName"), 7)
            end
        end)
    end
end

function messenger:sendIncoming()
    if not self.journalQ then
        print("[PanamDateSMS] journalQ not ready yet.")
        return
    end

    -- Select a new random category and message each time
    local categories = { "Beach", "Shootingrange", "Autofix" }
    self.selectedCategory = categories[math.random(#categories)]
    self.selectedMessage = lang.getRandomFromCategory(self.selectedCategory)

    local notificationData = gameuiGenericNotificationData.new()
    local openAction = OpenPhoneMessageAction.new()
    openAction.phoneSystem = Game.GetScriptableSystemsContainer():Get("PhoneSystem")

    local contact = JournalContact.new()
    contact.avatarID = TweakDBID.new("custom")
    contact.id = self.CONTACT_ID
    openAction.journalEntry = contact

    local userData = PhoneMessageNotificationViewData.new()
    userData.title = lang.getText("contactName")
    userData.SMSText = self.selectedMessage
    userData.action = openAction
    userData.animation = CName("notification_phone_MSG")
    userData.soundEvent = CName("PhoneSmsPopup")
    userData.soundAction = CName("OnOpen")

    notificationData.time = 6.7
    notificationData.widgetLibraryItemName = CName("notification_message")
    notificationData.notificationData = userData

    self.journalQ:AddNewNotificationData(notificationData)
end

function messenger:manualMessage(text)
    if not self.contacts[self.CONTACT_KEY] then
        self:addContact()
    end

    self.selectedMessage = text or ""

    if not self.journalQ then
        print("[PanamDateSMS] journalQ not ready yet.")
        return
    end

    local notificationData = gameuiGenericNotificationData.new()
    local openAction = OpenPhoneMessageAction.new()
    openAction.phoneSystem = Game.GetScriptableSystemsContainer():Get("PhoneSystem")

    local contact = JournalContact.new()
    contact.avatarID = TweakDBID.new("custom")
    contact.id = self.CONTACT_ID
    openAction.journalEntry = contact

    local userData = PhoneMessageNotificationViewData.new()
    userData.title = lang.getText("contactName")
    userData.SMSText = self.selectedMessage
    userData.action = openAction
    userData.animation = CName("notification_phone_MSG")
    userData.soundEvent = CName("PhoneSmsPopup")
    userData.soundAction = CName("OnOpen")

    notificationData.time = 6.7
    notificationData.widgetLibraryItemName = CName("notification_message")
    notificationData.notificationData = userData

    self.journalQ:AddNewNotificationData(notificationData)
end

function messenger:sendIncomingFromCategory(category)
    if not self.contacts[self.CONTACT_KEY] then
        self:addContact()
    end

    -- Skip sending "nothing" category to journal entirely
    if category == "nothing" then
        return
    end

    self.selectedCategory = category
    self.selectedMessage = lang.getRandomFromCategory(category)

    if not self.journalQ then
        print("[PanamDateSMS] journalQ not ready yet.")
        return
    end

    local notificationData = gameuiGenericNotificationData.new()
    local openAction = OpenPhoneMessageAction.new()
    openAction.phoneSystem = Game.GetScriptableSystemsContainer():Get("PhoneSystem")

    local contact = JournalContact.new()
    contact.avatarID = TweakDBID.new("custom")
    contact.id = self.CONTACT_ID
    openAction.journalEntry = contact

    local userData = PhoneMessageNotificationViewData.new()
    userData.title = lang.getText("contactName")
    userData.SMSText = self.selectedMessage
    userData.action = openAction
    userData.animation = CName("notification_phone_MSG")
    userData.soundEvent = CName("PhoneSmsPopup")
    userData.soundAction = CName("OnOpen")

    notificationData.time = 6.7
    notificationData.widgetLibraryItemName = CName("notification_message")
    notificationData.notificationData = userData

    self.journalQ:AddNewNotificationData(notificationData)

    -- If "Ending" category, hide contact from journal after 60 seconds
    if category == "Ending" then
        Cron.After(60.0, function()
            self.selectedCategory = "nothing"
        end)
    end
end

function messenger:sendReply()
    -- Require contact exists
    if not self.contacts[self.CONTACT_KEY] then
        print("[PanamDateSMS] Contact not created yet.")
        return
    end

    if factGet(self.CONTACT_KEY .. "_replied") == 1 then
        print("[PanamDateSMS] Reply already sent.")
        return
    end

    factSet(self.CONTACT_KEY .. "_replied", 1)

    -- Optional: show a popup again so you notice something happened
    if self.journalQ then
        local notificationData = gameuiGenericNotificationData.new()
        local openAction = OpenPhoneMessageAction.new()
        openAction.phoneSystem = Game.GetScriptableSystemsContainer():Get("PhoneSystem")

        local contact = JournalContact.new()
        contact.avatarID = TweakDBID.new("custom")
        contact.id = self.CONTACT_ID
        openAction.journalEntry = contact

        local userData = PhoneMessageNotificationViewData.new()
        userData.title = lang.getText("contactName")
        userData.SMSText = lang.getText("vReply")
        userData.action = openAction
        userData.animation = CName("notification_phone_MSG")
        userData.soundEvent = CName("PhoneSmsPopup")
        userData.soundAction = CName("OnOpen")

        notificationData.time = 6.7
        notificationData.widgetLibraryItemName = CName("notification_message")
        notificationData.notificationData = userData

        self.journalQ:AddNewNotificationData(notificationData)
    end
end

function messenger:forceIncoming()
    self:addContact()
    self:sendIncoming()
end

function messenger:cleanUp(soft)
    if not soft then
        self.journalQ = nil
        self.contacts = {}
    end
end

function messenger:resetForNewSave()
    -- Keep contact, reset only messages/state
    self.selectedCategory = "nothing"
    self.selectedMessage = ""
    self.selectedReply = nil
    
    -- Reset only reply/message state (do not remove/re-add contact)
    local qs = Game.GetQuestsSystem()
    if qs then
        qs:SetFactStr(self.CONTACT_KEY .. "_replied", 0)
    end
end

return messenger
