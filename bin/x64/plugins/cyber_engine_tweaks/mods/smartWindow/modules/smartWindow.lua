local ink = require("modules/utils/inkHelper")
local Cron = require("modules/external/Cron")
local color = require("modules/utils/color")
local lang = require("modules/lang")
local utils = require("modules/utils/utils")

window = {}

function window:new(windowController, catcher, shutterIDs, radioID, locationName, noBG)
	local o = {}

    o.windowController = windowController
    o.catcher = catcher
    o.shutterIDs = shutterIDs
    o.radioID = radioID
    o.locationName = locationName
    o.noBG = noBG

    o.sizeY = 1920

    o.bgColor = color.new(0, 75, 75, 50, 255)
    o.yellowColor = color.yellow
    o.blueColor = color.turquoise

    o.stateText = nil
    o.messagesButton = nil

    o.updateCron = nil
    o.highLevelCron = nil
    o.newsCron = nil

    o.partyCounter = 0

	self.__index = self
   	return setmetatable(o, self)
end

function window:initialize()
    Cron.After(1, function ()
        local root = self.windowController:GetMainLayoutController():GetRootWidget()
        root:SetSize(Vector2.new({X = 1620, Y = 1000}))

        self:setupBackground(root)
        self:setupShutterButtons(root)
        self:setupMessagesButton(root)
        self:setupShutterState(root)
        self:setupLocation(root)
        self:setupWeather(root)
        self:setupNews(root)
        self:setupStocksGraph(root)
        self:setupStocksButton(root)
        self:updateStockInfo()
    end)

    self.updateCron = Cron.Every(5, function()
        if Vector4.Distance(GetPlayer():GetWorldPosition(), self.windowController:GetOwner():GetWorldPosition()) > 20 then
            return
        end

        self:update()
        self:updateStockInfo()

        local stocks = GetMod("stocks")
        if not stocks then return end
        self.graph.data = stocks.market.marketStock.exportData.data
        self.graph:showData()
    end)

    self.highLevelCron = Cron.Every(0.75, function ()
        if GetPlayer():GetPlayerStateMachineBlackboard():GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) > 2 then
            self.windowController:GetOwner():FindComponentByName("terminalui"):Toggle(false)
        else
            self.windowController:GetOwner():FindComponentByName("terminalui"):Toggle(true)
        end
    end)
end

function window:uninit()
    Cron.Halt(self.highLevelCron)
    Cron.Halt(self.updateCron)
    Cron.Halt(self.newsCron)
end

function window:update()
    self.messagesButton.textWidget:SetText(GetLocalizedText("LocKey#49556") .. " (" .. utils.getNumUnreadMessages() .. ")")
    self:updateWeather()
end

function window:setupBackground(root)
    if self.noBG then return end
    local y = self.sizeY
    if #self.shutterIDs == 0 then
        y = self.sizeY - 520
    end
    local rect = ink.rect(0, 25, 10000, y, self.bgColor)
    rect:Reparent(root, 1)
end

function window:setupStocksGraph(root)
    local stocks = GetMod("stocks")
    self.graph = require("modules/widgets/graph"):new(60, 50, 1200, 550, 6, 3, "Time", "Value", 6, 40, color.darkcyan, 0)
    self.graph.intervall = 30
    if stocks then self.graph.intervall = stocks.intervall end

    local ui = self.graph:initialize()
    ui:Reparent(root, 2)

    if stocks then
        self.graph.data = stocks.market.marketStock.exportData.data
    else
        local points = {1050}
        for i = 2, 90 do
            points[i] = points[i - 1] + math.random(-5, 5)
        end
        self.graph.data = points
    end

    self.graph:showData()
end

function window:setupStocksButton(root)
    local canvas = ink.canvas(35, self.sizeY - 1330)
    canvas:Reparent(root, 2)

    self.top1 = require("modules/widgets/stockPreview"):new(0, 50, 4, "", 46, self.blueColor, self.yellowColor)
    self.top1:initialize()
    self.top1.canvas:Reparent(canvas, -1)
    self.top2 = require("modules/widgets/stockPreview"):new(312, 50, 4, "", 46, self.blueColor, self.yellowColor)
    self.top2:initialize()
    self.top2.canvas:Reparent(canvas, -1)
    self.low1 = require("modules/widgets/stockPreview"):new(622, 50, 4, "", 46, self.blueColor, self.yellowColor)
    self.low1:initialize()
    self.low1.canvas:Reparent(canvas, -1)
    self.low2 = require("modules/widgets/stockPreview"):new(932, 50, 4, "", 46, self.blueColor, self.yellowColor)
    self.low2:initialize()
    self.low2.canvas:Reparent(canvas, -1)
end

function window:updateStockInfo()
    if GetMod("stocks") and GetMod("stocks").version ~= nil then
        local top = GetMod("stocks").market:getTopStocks()
        self.top1.stock = top.top1
        self.top2.stock = top.top2
        self.low1.stock = top.low1
        self.low2.stock = top.low2
    end

    self.top1:showData()
    self.top2:showData()
    self.low1:showData()
    self.low2:showData()
end

function window:setupWeather(root)
    local canvas = ink.canvas(630, self.sizeY - 1130)
    canvas:Reparent(root, 2)

    self.sunShape = ink.circle(100, 85, 80, color.new(255, 190, 0, 255, 255))
    self.sunShape:Reparent(canvas, -1)

    self.weatherText = ink.text("", 160, 7, 33, self.blueColor)
    self.weatherText:Reparent(canvas, -1)

    local graph = require("modules/widgets/graph"):new(-10, 185, 600, 50, 8, 5, "", "", 0, 0, color.wheat, 0)
    graph:initialize()
    graph.canvas:Reparent(canvas, -1)
    graph.setLabels = function()end
    graph.data = {}
    local currentValue = 0
    for i = 1, 8 do
		currentValue = currentValue + math.random(-3, 3)
		graph.data[i] = currentValue
	end
    graph:showData()
    for _, line in pairs(graph.graphLines) do
        line:SetTintColor(color.new(255, 170, 0, 255, 255))
    end

    self:updateWeather()
end

function window:setupNews(root)
    local canvas = ink.canvas(35, self.sizeY - 1160)
    canvas:Reparent(root, 2)

    local newsText = ink.text("", 0, 40, 32, self.blueColor)
    newsText:Reparent(canvas, -1)
    local newsTitle = ink.text("", 0, 0, 35, self.yellowColor)
    newsTitle:Reparent(canvas, -1)

    local button = require("modules/widgets/buttonIcon"):new(-10, -10, 600, 300, 0, "", 80, self.blueColor, self.yellowColor)
    button:initialize()
    button:registerCallbacks(self.catcher)
    button.callback = function()
        self:swipeNews()
        Cron.Halt(self.newsCron)
        self.newsCron = Cron.Every(14, function()
            self:swipeNews()
        end)
    end
    button.hoverInCallback = function()
        newsText:SetTintColor(color.new(64, 224, 208, 1, 190))
    end
    button.hoverOutCallback = function()
        newsText:SetTintColor(self.blueColor)
    end
    button.canvas:Reparent(canvas, -1)

    local newsPrefix = {"UI-GlobalTV-Newsfeed-ClimateCatastrophes", "UI-GlobalTV-Newsfeed-ExtinctAnimals", "UI-GlobalTV-Newsfeed-Technology", "UI-GlobalTV-Newsfeed-Lifestyle", "UI-GlobalTV-Newsfeed-Culture", "UI-GlobalTV-Newsfeed-NetSecurity", "UI-GlobalTV-Newsfeed-GangActivity", "UI-GlobalTV-Newsfeed-Sport", "UI-GlobalTV-Newsfeed-NightCity", "UI-GlobalTV-Newsfeed-WorldInfo", "UI-GlobalTV-Newsfeed-BreakingNews"}
    local newsQueue = {}
    while #newsQueue < 10 do
        if (#newsQueue == 0 or #newsQueue == 3 or #newsQueue == 7 or #newsQueue == 9) and (GetMod("stocks") and GetMod("stocks").version ~= nil) then
            local sm = GetMod("stocks")
            local news = sm.market.newsManager:getNews()
            local i = 1
            if #newsQueue == 3 then i = 2 end
            if #newsQueue == 9 then i = 3 end
            local title, msg = sm.market.newsManager.lang.getNewsText(news[i])
            table.insert(newsQueue, {title = title, msg = utils.shortenText(msg, 185)})
        else
            table.insert(newsQueue, {title = GetLocalizedText("LocKey#33676"), msg = utils.shortenText(GetLocalizedText(newsPrefix[math.random(#newsPrefix)] .. math.random(9)), 220)})
        end
    end

    self.newsQueue = newsQueue
    self.currentNews = 1
    self.newsTitle = newsTitle
    self.newsText = newsText

    self:swipeNews()

    self.newsCron = Cron.Every(14, function()
        self:swipeNews()
    end)
end

function window:swipeNews()
    local news = self.newsQueue[self.currentNews]
    self.currentNews = self.currentNews + 1
    if self.currentNews > #self.newsQueue then self.currentNews = 1 end

    self.newsTitle:SetText(news.title)
    self.newsText:SetText(utils.wrap(news.msg, 30))
end

function window:updateWeather()
    if Game.GetTimeSystem():GetGameTime():Hours() > 20 or Game.GetTimeSystem():GetGameTime():Hours() < 5 then
        self.sunShape:SetTintColor(color.new(150, 150, 150, 255, 255))
    else
        self.sunShape:SetTintColor(color.new(255, 190, 0, 255, 255))
    end

    if self.weatherText:GetText() == "" or math.random(1, 500) == 69 then
        local text = GetLocalizedText("UI-GlobalTV-Newsfeed-Weather" .. math.random(0, 9))
        local lines = utils.split(text, "%. ")
        local displayText = ""
        for _, line in pairs(lines) do displayText = displayText .. line .. "\n" end
        self.weatherText:SetText(displayText)
    end
end

function window:setupMessagesButton(root)
    local open = require("modules/widgets/buttonIcon"):new(-620, self.sizeY - 1915, 1240, 220, 7, GetLocalizedText("LocKey#49556") .. " (" .. utils.getNumUnreadMessages() .. ")", 80, self.blueColor, self.yellowColor)
    open:initialize()
    open:registerCallbacks(self.catcher)
    open.callback = function()
        Game.GetScriptableSystemsContainer():Get("PhoneSystem"):QueueRequest(UsePhoneRequest.new())
    end
    open.canvas:Reparent(root, 2)
    self.messagesButton = open
end

function window:setupLocation(root)
    local y = self.sizeY - 530
    if #self.shutterIDs == 0 then
        y = y - 50
    end
    local text = ink.text(GetLocalizedText(self.locationName), 30, y, 50, color.black, textLetterCase.UpperCase)
    text:Reparent(root, 2)

    Cron.After(1, function()
        local xSize = text:GetDesiredWidth()
        local rect = ink.rect(30, y, xSize, 50, color.yellow)
        rect:Reparent(root, 2)
        text:Reparent(root, 3)
    end)
end

function window:setupShutterState(root)
    if #self.shutterIDs == 0 then return end

    local text = ink.text(lang.getText("current_setting") .. ": " .. GetLocalizedText("LocKey#23356"), 30, self.sizeY - 475, 50, self.yellowColor, textLetterCase.UpperCase)
    text:Reparent(root, 2)
    self.stateText = text
end

--https://www.flaticon.com/free-icon/sun_709768?related_id=709768&origin=search
--designvector10 moon https://www.flaticon.com/search?type=icon&word=moon&license=&color=&shape=outline&current_section=&author_id=&pack_id=&family_id=&style_id=&choice=&type=icon
--Freepik spiral https://www.flaticon.com/search?type=icon&word=spiral&license=&color=&shape=outline&current_section=&author_id=&pack_id=&family_id=&style_id=&choice=&type=icon

function window:activateGachi()
    self.openButton.icon.image:SetAtlasResource(ResRef.FromName("base\\icon\\gachi_m.inkatlas"))
    self.closeButton.icon.image:SetAtlasResource(ResRef.FromName("base\\icon\\gachi_n.inkatlas"))
    self.partyButton.icon.image:SetAtlasResource(ResRef.FromName("base\\icon\\gachi_p.inkatlas"))
end

function window:setupShutterButtons(root)
    if #self.shutterIDs == 0 then return end

    local size = 400
    local y = self.sizeY - 1485
    local textSize = 50

    self.openButton = require("modules/widgets/buttonIcon"):new(-620, y, size, size, 7, GetLocalizedText("LocKey#53701"), textSize, self.blueColor, self.yellowColor)
    self.openButton.atlas = "base\\icon\\sun.inkatlas"
    self.openButton:initialize()
    self.openButton:registerCallbacks(self.catcher)
    self.openButton.callback = function()
        self.partyCounter = 0
        self:toggleShutters(true)
        if self.stateText then
            self.stateText:SetText(lang.getText("current_setting") .. ": " .. GetLocalizedText("LocKey#53701"))
        end
    end
    self.openButton.canvas:Reparent(root, 2)

    self.closeButton = require("modules/widgets/buttonIcon"):new(-200, y, size, size, 7, GetLocalizedText("LocKey#53702"), textSize, self.blueColor, self.yellowColor)
    self.closeButton.atlas = "base\\icon\\moon.inkatlas"
    self.closeButton:initialize()
    self.closeButton:registerCallbacks(self.catcher)
    self.closeButton.callback = function()
        self.partyCounter = 0
        self:toggleShutters(false)
        if self.stateText then
            self.stateText:SetText(lang.getText("current_setting") .. ": " .. GetLocalizedText("LocKey#53702"))
        end
    end
    self.closeButton.canvas:Reparent(root, 2)

    self.partyButton = require("modules/widgets/buttonIcon"):new(220, y, size, size, 7, lang.getText("party_mode"), textSize, self.blueColor, self.yellowColor)
    self.partyButton.atlas = "base\\icon\\dance.inkatlas"
    self.partyButton:initialize()
    self.partyButton:registerCallbacks(self.catcher)
    self.partyButton.callback = function()
        self.partyCounter = self.partyCounter + 1
        if self.partyCounter > 6 then self:activateGachi() end
        self:toggleShutters(false)

        if self.stateText then
            self.stateText:SetText(lang.getText("current_setting") .. ": " .. lang.getText("party_mode"))
        end

        local radio = Game.FindEntityByID(entEntityID.new({hash = self.radioID}))
        if not radio then return end

        radio:TurnOnDevice()
        radio:PlayGivenStation()
        radio:UpdateDeviceState()
        radio:RefreshUI()
    end
    self.partyButton.canvas:Reparent(root, 2)
end

function window:toggleShutters(state)
    for _, id in pairs(self.shutterIDs) do
        local shutter = Game.FindEntityByID(entEntityID.new({hash = id}))
        if shutter then
            shutter:ApplyAnimState(state, false)
        end
    end
end

return window