local relay = require("ui/helpers/inputrelay")
local utils = require("ui/helpers/utils")
local GameUI = require("external/GameUI")
local Cron = require("external/Cron")
local Bank = require("module/Bank")

local BrowserTab = {
    sessions = {},
    awaitingLoad = false,
    suppressed = false,
    lastComputerController = nil,
    autoSwitchArmed = false,
    handoffPollToken = nil,
    handoffPollUntil = 0,
}

local function findSession(entity)
    for idx, s in pairs(BrowserTab.sessions) do
        if utils.isSameInstance(entity, s.pc) then
            return idx, s
        end
    end
    return nil, nil
end

local function closeSession(idx)
    local s = BrowserTab.sessions[idx]
    if not s then return end
    pcall(function() s.ui:uninitialize() end)
    BrowserTab.sessions[idx] = nil
end

local function isJohnnySuppressed()
    if BrowserTab.suppressed == true then return true end
    local active = false
    pcall(function() active = GameUI.IsJohnny() == true end)
    return active
end

local function stopVanguardHandoffPoll()
    if BrowserTab.handoffPollToken then
        Cron.Halt(BrowserTab.handoffPollToken)
        BrowserTab.handoffPollToken = nil
    end
    BrowserTab.handoffPollUntil = 0
end

function BrowserTab.armVanguardHandoffPoll(duration)
    BrowserTab.handoffPollUntil = os.clock() + (duration or 10.0)
    if BrowserTab.handoffPollToken then return end

    BrowserTab.handoffPollToken = Cron.Every(0.50, function(timer)
        if not BrowserTab.lastComputerController or os.clock() > (BrowserTab.handoffPollUntil or 0) then
            Cron.Halt(BrowserTab.handoffPollToken or timer)
            BrowserTab.handoffPollToken = nil
            BrowserTab.handoffPollUntil = 0
            return
        end

        BrowserTab.tryOpenBankFromVanguardHandoff()
    end)
end

function BrowserTab.setSuppressed(active)
    BrowserTab.suppressed = active == true
    if BrowserTab.suppressed then
        BrowserTab.awaitingLoad = false
        stopVanguardHandoffPoll()
        local indexes = {}
        for idx, _ in pairs(BrowserTab.sessions) do
            table.insert(indexes, idx)
        end
        for _, idx in ipairs(indexes) do
            closeSession(idx)
        end
    end
end

local function hidePageCounters(browserCtrl)
    pcall(function()
        if browserCtrl.pageCounter then
            inkTextRef.SetVisible(browserCtrl.pageCounter, false)
            inkTextRef.SetOpacity(browserCtrl.pageCounter, 0)
        end
        if browserCtrl.scrollPageCounter then
            inkTextRef.SetVisible(browserCtrl.scrollPageCounter, false)
            inkTextRef.SetOpacity(browserCtrl.scrollPageCounter, 0)
        end
    end)
end


function BrowserTab.tryOpenBankFromVanguardHandoff()
    if BrowserTab.autoSwitchArmed then return end
    local ctrl = BrowserTab.lastComputerController
    if not ctrl then return end
    if isJohnnySuppressed() then return end

    local pending = false
    pcall(function()
        pending = (Bank:_getQuestFactInt("marmur_vanguard_open_loans") or 0) > 0
    end)
    if not pending then
        BrowserTab.autoSwitchArmed = false
        return
    end

    BrowserTab.autoSwitchArmed = true
    local ok = pcall(function()
        ctrl:ShowMenuByName("bank")
    end)
    if not ok then
        BrowserTab.autoSwitchArmed = false
    end
end

function BrowserTab.initialize()
    relay.init()

    ObserveAfter("ComputerMenuButtonController", "Initialize", function(this, _, data)
        if not data or data.widgetName ~= "bank" then
            return
        end

        pcall(function()
            local icon = this.iconWidget
            if icon then
                icon:SetAtlasResource(ResRef.FromName("base\\gameplay\\gui\\world\\internet\\templates\\atlases\\one-icon.inkatlas"))
                icon:SetTexturePart("icon")
            end
        end)
    end)

    Override("ComputerControllerPS", "GetMenuButtonWidgets", function(this, wrapped)
        local buttons = wrapped()
        if isJohnnySuppressed() then
            return buttons
        end
        local widgetPackage = SComputerMenuButtonWidgetPackage.new()
        widgetPackage.widgetName = "bank"
        widgetPackage.displayName = "Marmur Bank"
        widgetPackage.ownerID = this:GetID()
        widgetPackage.iconID = "iconInternet"
        widgetPackage.widgetTweakDBID = this:GetMenuButtonWidgetTweakDBID()
        widgetPackage.libraryID, widgetPackage.libraryPath = SWidgetPackageBase.ResolveWidgetTweakDBData(widgetPackage.widgetTweakDBID)
        widgetPackage.isValid = true
        table.insert(buttons, widgetPackage)
        return buttons
    end)

    Override("ComputerInkGameController", "ShowMenuByName", function(this, address, wrapped)
        BrowserTab.lastComputerController = this
        BrowserTab.armVanguardHandoffPoll(10.0)
        if address == "bank" and isJohnnySuppressed() then
            BrowserTab.awaitingLoad = false
            local idx = findSession(this:GetOwner())
            if idx then closeSession(idx) end
            return
        end

        if address == "bank" then
            local staleIdx = findSession(this:GetOwner())
            if staleIdx then closeSession(staleIdx) end
            BrowserTab.awaitingLoad = true
            this:ShowInternet()
            this:GetMainLayoutController():MarkManuButtonAsSelected("bank")
        else
            local idx = findSession(this:GetOwner())
            if idx then closeSession(idx) end
            wrapped(address)
        end
    end)

    Observe("BrowserGameController", "OnUninitialize", function(this)
        local idx = findSession(this:GetOwnerEntity())
        if idx then closeSession(idx) end
        BrowserTab.autoSwitchArmed = false
        stopVanguardHandoffPoll()
        BrowserTab.lastComputerController = nil
    end)

    ObserveAfter("BrowserController", "OnPageSpawned", function(this)
        local staleIdx = findSession(this:GetOwnerGameObject())
        if staleIdx then closeSession(staleIdx) end

        if isJohnnySuppressed() then
            BrowserTab.awaitingLoad = false
            return
        end

        if not BrowserTab.awaitingLoad then return end
        BrowserTab.awaitingLoad = false

        pcall(function()
            this.currentPage:RemoveAllChildren()
        end)

        local shell = require("ui/BankShell"):new(this)
        shell:startup()
        table.insert(BrowserTab.sessions, { ui = shell, pc = this:GetOwnerGameObject() })
        stopVanguardHandoffPoll()
        hidePageCounters(this)
    end)

    ObserveAfter("BrowserController", "LoadWebPage", function(this)
        local _, session = findSession(this:GetOwnerGameObject())
        if not session then return end
        pcall(function() session.ui:applyAddressBar() end)
        hidePageCounters(this)
    end)
end

return BrowserTab
