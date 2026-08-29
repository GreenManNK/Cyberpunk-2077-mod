local Cron = require("modules/Cron")
local okLang, lang = pcall(require, "modules/lang")
local utils = require("modules/utils")

if not okLang or type(lang) ~= "table" then
  print("[JudyDateSMS] ERROR: modules/lang.lua could not be loaded: " .. tostring(lang))
  lang = {
    getText = function(key) return tostring(key or "") end,
    getKey = function() return nil end,
    getRandomFromCategory = function() return "" end,
    getRandomReply = function() return "" end
  }
end

local messenger = {}
local buildNotification

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

local function safeEntryId(entry)
  if not entry then return nil end

  local ok, value = pcall(function() return entry.id end)
  if ok and value ~= nil then return tostring(value) end

  ok, value = pcall(function() return entry:GetId() end)
  if ok and value ~= nil then return tostring(value) end

  return nil
end

local function setReplyRendererText(this, text)
  local ok = pcall(function()
    inkTextRef.SetText(this.labelPathRef, text or "")
  end)
  if not ok then
    pcall(function()
      inkTextRef.SetText(this.m_labelPathRef, text or "")
    end)
  end
  pcall(function() this:SetActive(true) end)
end

function messenger:new(pm)
  local o = {}
  o.pm = pm
  o.contacts = {}
  o.journalQ = nil
  o.phoneController = nil
  o.selectedCategory = "nothing"
  o.selectedMessage = ""
  o.selectedReply = nil
  o.cleanupSeq = 0
  o.replySeq = 0
  o.messageSeq = 0
  o.threadVersion = 0
  o.threadMessages = {}
  o.messageById = {}
  o.replyTextById = {}
  o.pendingInviteKind = nil
  o.pendingInviteCategory = nil
  o.selectedAcceptReply = nil
  o.selectedBusyReply = nil
  o.replyState = nil
  o.activeDialogController = nil

  o.CONTACT_KEY = "judyDate"
  o.CONTACT_ID = "judyDate_contact"
  o.CONTACT_HASH = 1806317291
  o.MSG_IN_PREFIX = "judyDate_msg_in_"
  o.MSG_OUT_PREFIX = "judyDate_msg_out_"
  o.REPLY_ACCEPT_ID = "judyDate_reply_accept"
  o.REPLY_BUSY_ID = "judyDate_reply_busy"

  self.__index = self
  return setmetatable(o, self)
end

function messenger:hasVisibleThread()
  return self.threadMessages and #self.threadMessages > 0
end

function messenger:updateContactTime()
  local data = self.contacts and self.contacts[self.CONTACT_KEY]
  if not data then return end
  local ts = Game.GetTimeSystem()
  local t = ts and ts:GetGameTime() or nil
  if t then data.time = t end
end

function messenger:resetThreadState()
  self.cleanupSeq = (self.cleanupSeq or 0) + 1
  self.replySeq = (self.replySeq or 0) + 1
  self.threadVersion = (self.threadVersion or 0) + 1
  self.threadMessages = {}
  self.messageById = {}
  self.replyTextById = {}
  self.selectedCategory = "nothing"
  self.selectedMessage = ""
  self.selectedReply = nil
  self.pendingInviteKind = nil
  self.pendingInviteCategory = nil
  self.selectedAcceptReply = nil
  self.selectedBusyReply = nil
  self.replyState = nil
  factSet(self.CONTACT_KEY .. "_replied", 0)
end

function messenger:appendThreadMessage(text, sender, category)
  if type(text) ~= "string" or text == "" then return nil end

  self.messageSeq = (self.messageSeq or 0) + 1
  self.threadVersion = (self.threadVersion or 0) + 1

  local isSent = sender == "sent"
  local id = (isSent and self.MSG_OUT_PREFIX or self.MSG_IN_PREFIX) .. tostring(self.messageSeq)
  local item = {
    id = id,
    text = text,
    sender = isSent and "sent" or "received",
    category = category or "Manual"
  }

  table.insert(self.threadMessages, item)
  self.messageById[id] = item
  self.selectedCategory = item.category
  self.selectedMessage = text
  self:updateContactTime()
  return item
end

function messenger:getInvitationKind(category)
  if category == "JudySwim" then return "swim" end
  if category == "GuitarInvite" then return "guitar" end
  if category == "ClimbInvite" then return "climb" end
  return nil
end

function messenger:prepareInvitationReplies(category)
  local kind = self:getInvitationKind(category)
  if not kind then
    self.pendingInviteKind = nil
    self.pendingInviteCategory = nil
    self.selectedAcceptReply = nil
    self.selectedBusyReply = nil
    self.replyState = nil
    self.replyTextById = {}
    return false
  end

  self.pendingInviteKind = kind
  self.pendingInviteCategory = category
  self.selectedAcceptReply = lang.getRandomReply("accept")
  self.selectedBusyReply = lang.getRandomReply("busy")
  self.replyState = nil
  self.replyTextById = {
    [self.REPLY_ACCEPT_ID] = self.selectedAcceptReply,
    [self.REPLY_BUSY_ID] = self.selectedBusyReply
  }
  factSet(self.CONTACT_KEY .. "_replied", 0)
  return true
end

function messenger:buildJournalMessages()
  local messages = {}
  for _, item in ipairs(self.threadMessages or {}) do
    local entry = JournalPhoneMessage.new()
    entry.id = item.id
    table.insert(messages, entry)
  end
  return messages
end

function messenger:buildReplyChoices()
  local replies = {}
  if not self.pendingInviteKind or self.replyState ~= nil then return replies end

  local accept = JournalPhoneChoiceEntry.new()
  accept.id = self.REPLY_ACCEPT_ID
  table.insert(replies, accept)

  local busy = JournalPhoneChoiceEntry.new()
  busy.id = self.REPLY_BUSY_ID
  table.insert(replies, busy)

  return replies
end

function messenger:refreshDialog(controller)
  local target = controller or self.activeDialogController
  if not target then return end
  Cron.After(0.05, function()
    pcall(function()
      if target.parentEntry and tostring(target.parentEntry.id) == self.CONTACT_ID then
        target:UpdateData(false, true)
      end
    end)
  end)
end

function messenger:getReplyIdFromTarget(controller, target)
  local entryId = nil

  if target then
    pcall(function()
      local data = target:GetData()
      if data then
        local entry = nil
        pcall(function() entry = data.entry end)
        if not entry then pcall(function() entry = data.m_entry end) end
        entryId = safeEntryId(entry)
      end
    end)
  end

  if entryId == self.REPLY_ACCEPT_ID or entryId == self.REPLY_BUSY_ID then
    return entryId
  end

  local selectedIndex = nil
  pcall(function()
    selectedIndex = controller.choicesListController:GetSelectedIndex()
  end)
  if selectedIndex == 0 then return self.REPLY_ACCEPT_ID end
  if selectedIndex == 1 then return self.REPLY_BUSY_ID end

  return nil
end

function messenger:chooseReply(kind, controller)
  if not self.pendingInviteKind or self.replyState ~= nil then return false end
  if kind ~= "accept" and kind ~= "busy" then return false end

  local dateKind = self.pendingInviteKind
  local replyText = kind == "accept" and self.selectedAcceptReply or self.selectedBusyReply
  if type(replyText) ~= "string" or replyText == "" then
    replyText = lang.getRandomReply(kind)
  end

  self.replyState = kind
  self.selectedReply = replyText
  self.replyTextById = {}
  factSet(self.CONTACT_KEY .. "_replied", 1)
  self:appendThreadMessage(replyText, "sent", kind == "accept" and "ReplyAccept" or "ReplyBusy")

  local handled = true
  if self.pm and self.pm.handleDateReply then
    local ok, result = pcall(function()
      return self.pm:handleDateReply(kind, dateKind)
    end)
    handled = ok and result ~= false
    if not ok then
      print("[JudyDateSMS] ERROR: date reply handler failed: " .. tostring(result))
    end
  end

  self.pendingInviteKind = nil
  self.pendingInviteCategory = nil
  self.selectedAcceptReply = nil
  self.selectedBusyReply = nil
  self:refreshDialog(controller)

  if kind == "accept" then
    self:scheduleJournalClear(45.0, self.threadVersion)
    return handled
  end

  self.replySeq = (self.replySeq or 0) + 1
  local seq = self.replySeq
  Cron.After(1.25, function()
    if self.replySeq ~= seq or self.replyState ~= "busy" then return end

    local response = lang.getRandomReply("decline")
    if type(response) ~= "string" or response == "" then
      response = "Ah sure, maybe next time then!"
    end

    self:appendThreadMessage(response, "received", "JudyDeclineResponse")
    buildNotification(self, response)
    self:refreshDialog(controller)
    self:scheduleJournalClear(60.0, self.threadVersion)
  end)

  return handled
end

function messenger:setupReplyActivationOverride()
  if self._replyOverrideInstalled then return end
  self._replyOverrideInstalled = true

  local handler = function(this, target, wrapped)
    local parentId = this and this.parentEntry and tostring(this.parentEntry.id) or nil
    if parentId ~= self.CONTACT_ID then
      wrapped(target)
      return
    end

    local id = self:getReplyIdFromTarget(this, target)
    if id == self.REPLY_ACCEPT_ID then
      self:chooseReply("accept", this)
      return
    elseif id == self.REPLY_BUSY_ID then
      self:chooseReply("busy", this)
      return
    end

    wrapped(target)
  end

  local ok = pcall(function()
    Override("MessengerDialogViewController", "ActivateReply;ListItemController", handler)
  end)
  if not ok then
    local fallbackOk, fallbackErr = pcall(function()
      Override("MessengerDialogViewController", "ActivateReply", handler)
    end)
    if not fallbackOk then
      print("[JudyDateSMS] ERROR: phone reply hook could not be installed: " .. tostring(fallbackErr))
    end
  end
end

function messenger:setup()
  Observe("JournalNotificationQueue", "OnMenuUpdate", function(this) self.journalQ = this end)
  Observe("JournalNotificationQueue", "OnPlayerAttach", function(this) self.journalQ = this end)
  Observe("JournalNotificationQueue", "OnInitialize", function(this) self.journalQ = this end)

  -- Cyberpunk 2.x phone controller. The notification action must target the contact hash
  -- so clicking the SMS popup opens Judy's message thread instead of only opening Contacts.
  Observe("NewHudPhoneGameController", "OnInitialize", function(this)
    self.phoneController = this
  end)

  Override("PhoneMessagePopupGameController", "OnInitialize", function(this, wrapped)
    wrapped()
    local data = this and this.data
    if not data then return end
    local isJudyByJournal = safeReadJournalId(data) == self.CONTACT_ID
    local locValue = safeReadLocKeyValue(data)
    local key = locValue and lang.getKey(locValue) or nil
    local isJudyByName = key == "contactName"
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
    local isJudyByJournal = safeReadJournalId(data) == self.CONTACT_ID
    local locValue = safeReadLocKeyValue(data)
    local key = locValue and lang.getKey(locValue) or nil
    local isJudyByName = key == "contactName"
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
      if self.contacts and self.contacts[self.CONTACT_KEY] and self:hasVisibleThread() then
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
    if self.contacts and self.contacts[self.CONTACT_KEY] and self:hasVisibleThread() then
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
    local id = safeEntryId(entry)
    local item = id and self.messageById[id] or nil
    if item then
      local viewType = item.sender == "sent" and MessageViewType.Sent or MessageViewType.Received
      this:SetMessageView(item.text or "", viewType, lang.getText("contactName"))
      return
    end
    wrapped(entry, extra)
  end)

  Override("MessangerReplyItemRenderer", "OnJournalEntryUpdated", function(this, entry, extra, wrapped)
    local id = safeEntryId(entry)
    local text = id and self.replyTextById[id] or nil
    if text then
      setReplyRendererText(this, text)
      return
    end
    wrapped(entry, extra)
  end)

  ObserveAfter("MessengerDialogViewController", "UpdateData;BoolBool", function(this, animateNewMessage, _, _)
    if this.parentEntry and tostring(this.parentEntry.id) == self.CONTACT_ID then
      self.activeDialogController = this
      local messages = self:buildJournalMessages()
      local replies = self:buildReplyChoices()
      this.messages = messages
      this.replyOptions = replies
      inkWidgetRef.SetVisible(this.replayFluff, #replies > 0)
      this:SetVisited(this.messages)
      this.messagesListController:Clear()
      this.messagesListController:PushEntries(this.messages)
      this.choicesListController:Clear()
      this.choicesListController:PushEntries(this.replyOptions)
      if #replies > 0 then this.choicesListController:SetSelectedIndex(0) end
      if IsDefined(this.newMessageAninmProxy) then this.newMessageAninmProxy:Stop() end
      local countMessages = this.messagesListController:Size()
      local lastMessageWidget = nil
      if animateNewMessage and countMessages > 0 then
        lastMessageWidget = this.messagesListController:GetItemAt(countMessages - 1)
      end
      if IsDefined(lastMessageWidget) then
        this.newMessageAninmProxy = this:PlayLibraryAnimationOnAutoSelectedTargets("new_message", lastMessageWidget)
      end
      this.scrollController:SetScrollPosition(1.00)
    end
  end)

  self:setupReplyActivationOverride()
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

buildNotification = function(self, smsText)
  local title = lang.getText("contactName")
  local text = smsText or ""

  if not self.phoneController then
    print("[JudyDateSMS] NewHudPhoneGameController not ready yet, retrying SMS notification.")
    Cron.After(1.0, function()
      if self.phoneController then buildNotification(self, text) end
    end)
    return
  end

  -- Standalone JudyDateSMS implementation of the modern Night City Allies style notification.
  -- It uses the custom contact hash, so selecting the popup opens the actual message thread.
  local ok = pcall(function()
    self.phoneController:PushJudyDateSMSNotification(self.CONTACT_HASH, title, text)
  end)
  if ok then return end

  -- Phone Extension / Night City Allies expose the same modern custom SMS helper.
  ok = pcall(function()
    self.phoneController:PushSMSNotificationCustom(self.CONTACT_HASH, title, text)
  end)
  if ok then return end

  print("[JudyDateSMS] ERROR: modern phone SMS notification helper is unavailable.")
end

function messenger:clearActiveMessage(reason)
  self:resetThreadState()
  if reason then
    print("[JudyDateSMS] Phone journal thread cleared: " .. tostring(reason))
  end
end

function messenger:scheduleJournalClear(seconds, versionSnapshot)
  self.cleanupSeq = (self.cleanupSeq or 0) + 1
  local seq = self.cleanupSeq
  local version = versionSnapshot or self.threadVersion
  Cron.After(seconds or 60.0, function()
    if self.cleanupSeq == seq and self.threadVersion == version then
      local category = self.selectedCategory
      self:resetThreadState()
      print("[JudyDateSMS] Phone journal thread auto-cleared after " .. tostring(seconds or 60.0) .. " seconds for " .. tostring(category))
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

  local isInvite = self:getInvitationKind(category) ~= nil
  if isInvite then
    self:resetThreadState()
    self:prepareInvitationReplies(category)
  else
    self.pendingInviteKind = nil
    self.pendingInviteCategory = nil
    self.selectedAcceptReply = nil
    self.selectedBusyReply = nil
    self.replyTextById = {}
  end

  self:appendThreadMessage(message, "received", category)
  buildNotification(self, message)

  if not isInvite then
    self:scheduleJournalClear(60.0, self.threadVersion)
  end
end

function messenger:manualMessage(text, category)
  if not self.contacts[self.CONTACT_KEY] then self:addContact() end
  self:resetThreadState()
  self:appendThreadMessage(text or "", "received", category or "Manual")
  buildNotification(self, text or "")
  self:scheduleJournalClear(60.0, self.threadVersion)
end

function messenger:sendReply()
  if not self.contacts[self.CONTACT_KEY] then return end
  if self.pendingInviteKind and self.replyState == nil then
    self:chooseReply("accept", self.activeDialogController)
    return
  end
  if factGet(self.CONTACT_KEY .. "_replied") == 1 then return end
  local text = lang.getText("vReply")
  factSet(self.CONTACT_KEY .. "_replied", 1)
  self:appendThreadMessage(text, "sent", "ReplyAccept")
  self:scheduleJournalClear(45.0, self.threadVersion)
end

function messenger:cleanUp(soft)
  self.activeDialogController = nil
  if not soft then
    self.journalQ = nil
    self.contacts = {}
  end
end

function messenger:resetForNewSave()
  self:clearActiveMessage("new save/reset")
end

return messenger
