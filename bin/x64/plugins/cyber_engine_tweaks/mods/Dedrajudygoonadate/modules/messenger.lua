local Cron = require("modules/Cron")
local okLang, lang = pcall(require, "modules/lang")
local utils = require("modules/utils")

if not okLang or type(lang) ~= "table" then
  print("[JudyDateSMS] ERROR: modules/lang.lua could not be loaded: " .. tostring(lang))
  lang = {
    getText = function(key) return tostring(key or "") end,
    getKey = function() return nil end,
    getRandomFromCategory = function() return "" end
  }
end

local messenger = {}

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

function messenger:new(pm)
  local o = {}
  o.pm = pm
  o.contacts = {}
  o.journalQ = nil
  o.selectedCategory = "nothing"
  o.selectedMessage = ""
  o.selectedReply = nil
  o.cleanupSeq = 0

  o.CONTACT_KEY = "judyDate"
  o.CONTACT_ID = "judyDate_contact"
  o.CONTACT_HASH = 1806317291
  o.MSG_IN_ID = "judyDate_msg_in"
  o.MSG_OUT_ID = "judyDate_msg_out"

  self.__index = self
  return setmetatable(o, self)
end

function messenger:setup()
  Observe("JournalNotificationQueue", "OnMenuUpdate", function(this) self.journalQ = this end)
  Observe("JournalNotificationQueue", "OnPlayerAttach", function(this) self.journalQ = this end)
  Observe("JournalNotificationQueue", "OnInitialize", function(this) self.journalQ = this end)

  Override("PhoneMessagePopupGameController", "OnInitialize", function(this, wrapped)
    wrapped()
    local data = this and this.data
    if not data then return end
    local isJudyByJournal = (safeReadJournalId(data) == self.CONTACT_ID)
    local locValue = safeReadLocKeyValue(data)
    local key = locValue and lang.getKey(locValue) or nil
    local isJudyByName = (key == "contactName")
    if isJudyByJournal or isJudyByName then
      pcall(function()
        this.data.journalEntry = JournalContact.new()
        this.data.journalEntry.id = self.CONTACT_ID
        this:SetupData()
      end)
    end
  end)

  Override("PhoneMessagePopupGameController", "OnRefresh", function(this, event, wrapped)
    local data = event and event.data
    if not data then wrapped(event); return end
    local isJudyByJournal = (safeReadJournalId(data) == self.CONTACT_ID)
    local locValue = safeReadLocKeyValue(data)
    local key = locValue and lang.getKey(locValue) or nil
    local isJudyByName = (key == "contactName")
    if isJudyByJournal or isJudyByName then
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

  Override("MessengerUtils", "GetSimpleContactDataArray;JournalManagerBoolBoolBoolMessengerContactSyncData",
    function(journal, includeUnknown, skipEmpty, includeWithNoUnread, activeDataSync, wrapped)
      local contacts = wrapped(journal, includeUnknown, skipEmpty, includeWithNoUnread, activeDataSync) or {}
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
          c.avatarID = TweakDBID.new("PhoneAvatars.Avatar_Judy")
          c.localizedPreview = self.selectedMessage or ""
          c.hasValidTitle = true
          c.timeStamp = data.time
          table.insert(contacts, c)
        end
      end
      return contacts
    end
  )

  Override("JournalManager", "GetContactDataArray", function(_, includeUnknown, includeUncallable, wrapped)
    local contacts = wrapped(includeUnknown, includeUncallable) or {}
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
        c.avatarID = TweakDBID.new("PhoneAvatars.Avatar_Judy")
        c.timeStamp = data.time
        table.insert(contacts, c)
      end
    end
    return contacts
  end)

  Override("MessangerItemRenderer", "OnJournalEntryUpdated", function(this, entry, extra, wrapped)
    wrapped(entry, extra)
    if entry and entry.id == self.MSG_IN_ID then
      this:SetMessageView(self.selectedMessage or "", MessageViewType.Received, lang.getText("contactName"))
    elseif entry and entry.id == self.MSG_OUT_ID then
      this:SetMessageView(lang.getText("vReply"), MessageViewType.Sent, lang.getText("contactName"))
    end
  end)

  ObserveAfter("MessengerDialogViewController", "UpdateData;BoolBool", function(this, a, _, _)
    if this.parentEntry and this.parentEntry.id == self.CONTACT_ID then
      local msgs = {}
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
      if #(this.replyOptions) > 0 then this.choicesListController:SetSelectedIndex(0) end
      if IsDefined(this.newMessageAninmProxy) then this.newMessageAninmProxy:Stop() end
      local countMessages = this.messagesListController:Size()
      local lastMessageWidget = nil
      if a and countMessages > 0 then lastMessageWidget = this.messagesListController:GetItemAt(countMessages - 1) end
      if IsDefined(lastMessageWidget) then
        this.newMessageAninmProxy = this:PlayLibraryAnimationOnAutoSelectedTargets("new_message", lastMessageWidget)
      end
      this.scrollController:SetScrollPosition(1.00)
    end
  end)
end

function messenger:ensureContactWhenReady()
  if factGet("q001_wakeup_scene_done") == 1 then
    self:addContact()
  else
    Cron.Every(5, function(timer)
      if factGet("q001_wakeup_scene_done") == 1 then
        self:addContact()
        timer:Halt()
      end
    end)
  end
end

function messenger:addContact()
  if self.contacts[self.CONTACT_KEY] then return end
  local ts = Game.GetTimeSystem()
  if not ts then
    Cron.After(1.0, function() self:addContact() end)
    return
  end
  local t = ts:GetGameTime()
  if not t then
    Cron.After(1.0, function() self:addContact() end)
    return
  end
  self.contacts[self.CONTACT_KEY] = { hash = self.CONTACT_HASH, time = t }
  if factGet(self.CONTACT_KEY .. "_showed") == 0 then
    factSet(self.CONTACT_KEY .. "_showed", 1)
    Cron.After(2.0, function()
      if self.journalQ then utils.showNewContact(self.journalQ, "", lang.getText("contactName"), 7) end
    end)
  end
end

local function buildNotification(self, smsText)
  if not self.journalQ then
    print("[JudyDateSMS] journalQ not ready yet, retrying.")
    Cron.After(2.0, function()
      if self.journalQ then buildNotification(self, smsText) end
    end)
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
  userData.SMSText = smsText or ""
  userData.action = openAction
  userData.animation = CName("notification_phone_MSG")
  userData.soundEvent = CName("PhoneSmsPopup")
  userData.soundAction = CName("OnOpen")
  notificationData.time = 6.7
  notificationData.widgetLibraryItemName = CName("notification_message")
  notificationData.notificationData = userData
  self.journalQ:AddNewNotificationData(notificationData)
end

function messenger:clearActiveMessage(reason)
  self.cleanupSeq = (self.cleanupSeq or 0) + 1
  self.selectedCategory = "nothing"
  self.selectedMessage = ""
  self.selectedReply = nil
  factSet(self.CONTACT_KEY .. "_replied", 0)
  if reason then
    print("[JudyDateSMS] Phone journal thread cleared: " .. tostring(reason))
  end
end

function messenger:scheduleJournalClear(seconds, categorySnapshot)
  self.cleanupSeq = (self.cleanupSeq or 0) + 1
  local seq = self.cleanupSeq
  local cat = categorySnapshot or self.selectedCategory
  Cron.After(seconds or 60.0, function()
    if self.cleanupSeq == seq and self.selectedCategory == cat then
      self.selectedCategory = "nothing"
      self.selectedMessage = ""
      self.selectedReply = nil
      factSet(self.CONTACT_KEY .. "_replied", 0)
      print("[JudyDateSMS] Phone journal thread auto-cleared after " .. tostring(seconds or 60.0) .. " seconds for " .. tostring(cat))
    end
  end)
end

function messenger:sendIncomingFromCategory(category)
  if category == nil or category == "nothing" then return end
  if not self.contacts[self.CONTACT_KEY] then self:addContact() end

  local ok, message = pcall(lang.getRandomFromCategory, category)
  if not ok then
    print("[JudyDateSMS] ERROR: failed to read message category " .. tostring(category) .. ": " .. tostring(message))
    return
  end
  if type(message) ~= "string" or message == "" then
    print("[JudyDateSMS] ERROR: localization category is missing or empty: " .. tostring(category))
    return
  end

  self.selectedCategory = category
  self.selectedMessage = message
  factSet(self.CONTACT_KEY .. "_replied", 0)
  buildNotification(self, self.selectedMessage)
  self:scheduleJournalClear(60.0, category)
end

function messenger:manualMessage(text, category)
  if not self.contacts[self.CONTACT_KEY] then self:addContact() end
  self.selectedCategory = category or "Manual"
  self.selectedMessage = text or ""
  factSet(self.CONTACT_KEY .. "_replied", 0)
  buildNotification(self, self.selectedMessage)
  self:scheduleJournalClear(60.0, self.selectedCategory)
end

function messenger:sendReply()
  if not self.contacts[self.CONTACT_KEY] then return end
  if factGet(self.CONTACT_KEY .. "_replied") == 1 then return end
  factSet(self.CONTACT_KEY .. "_replied", 1)
  buildNotification(self, lang.getText("vReply"))
  self:scheduleJournalClear(45.0, self.selectedCategory)
end

function messenger:cleanUp(soft)
  if not soft then
    self.journalQ = nil
    self.contacts = {}
  end
end

function messenger:resetForNewSave()
  self:clearActiveMessage("new save/reset")
end

return messenger
