-- Interested in how it works or are you here to copy something out?... If so read the next line.
-- Copyright (c) Erok - 2022 All rights reserved - excluding CET-KIT parts
-- Want to use something here? Ask me first, I might be willing to help.

-- This file is distributed as is. I do not give any warranty on any piece of this code.
-- If something doesn't work, make sure its not your end, check CET versions, check without any other mods, if it still persists write a bug on the nexus page.

-- If someone from CDPR is actually reading this for laughs, yes this is a very simplistic way of writing this, but works pretty well...
-- Maybe someone at CDPR could think of adding a system like this one day ;)

local Cron = require('external/Cron')
local GameSession = require('external/GameSession')
local GameShardUI = require("external/GameShardUI")
local GameUI = require('external/GameUI')
local VehicleBaseFunctions = require("functions/main_functions")

local UIPopupsManager = require('ui/UIPopupsManager')
local UIScroller = require('ui/UIScroller')
local UIButton = require('ui/UIButton')

local lang = require("functions/lang")

local state = { hasBeenLoaded = false, upgradedCarsInState = {}}
local sessionsFolder = 'external/sessions'

local CMSVersion = 2000

local PartsFolder = "parts"
local PartsRequireList = {}
local PartsList = {}
local PartBasket = {}
local UpgradedCarList = {}
local CurrentVehicle = nil
local CurrentVehicleListNum = -1
local UpgradedCarCount = 0
local LatestSaveFactID = 0
local CurrentPrice = 0
local ShouldClearAllOnNextUpgrade = false
local ShouldCheckForUpgrade = true
local upgrading = false

--Removal system
local isDowngrading = false
local removalList = {}

---@type worlduiIGameController
local gameController

---@type inkGameNotificationData
local notificationData

---@type inkGameNotificationToken
local notificationToken

---@type sampleStyleManagerGameController
local eventCatcher

---@type table
local buttonsData = {}
local buttonWidgets = {}

---WidgetArea Variables
local returnButton = nil
local widgetAreas = {}
local currentWidgetAreas = {}
local accessedWidgetAreas = {}
local totalAccessedWidgets = 0
local basketWidget = nil
local carPartsWidget = nil
local widgetWasIntialized = false
local uiAreaElement = nil
local basketBox = nil
local brokeConfirmBox = nil
local TextCanvasTotalBaseElementBase = nil

local latestsNotificationController = nil

local player = nil
local inGame = false

local function isSameInstance(a, b)
	return Game['OperatorEqual;IScriptableIScriptable;Bool'](a, b)
end

registerForEvent("onInit", function()
	--os.remove(sessionsFolder .. '/' .. 'vortexwhy')

	ShowMapPin()
	RenameMapPin()
	
	GameSession.StoreInDir(sessionsFolder)
    GameSession.Persist(state)
    GameSession.OnLoad(function()
        -- This state is not reset when the mod is reloaded
        --print(state.hasBeenLoaded)
    end)
    GameSession.TryLoad() -- NEW Load temp session
	
	GameUI.OnSessionStart(function()
		inGame = true
	end)
	
	GameUI.OnSessionEnd(function()
		inGame = false
		player = nil
	end)

	CName.add("CMS_User_Fact")
	CName.add("CMS_Last_Loaded_User_Fact")
	CName.add("CMS_AmountVehicleToUpgrade")
	CName.add("CMS_Version")
	CleanGarbage()
	
	UpgradePartNames = {"Engine", "Ecu", "Transmission", "Suspension", "Tires", "Brakes", "Weight Reduction"}
	--UpgradePartNames = {lang.getText("Engine"), lang.getText("Ecu"), lang.getText("Transmission"), lang.getText("Suspension"), lang.getText("Tires"), lang.getText("Brakes"), lang.getText("Weight Reduction")}
	LoadAllFilesInFolder(PartsFolder .. "/engine")
	LoadAllFilesInFolder(PartsFolder .. "/ecu")
	LoadAllFilesInFolder(PartsFolder .. "/transmission")
	LoadAllFilesInFolder(PartsFolder .. "/suspension")
	LoadAllFilesInFolder(PartsFolder .. "/tires")
	LoadAllFilesInFolder(PartsFolder .. "/brakes")
	LoadAllFilesInFolder(PartsFolder .. "/weight_reduction")
	
	for _, part in pairs(PartsRequireList) do
		partHere = part.getPart()
        PartsList[partHere.ID] = part.getPart()
    end
	
	--GameSession.Listen(function(stateToPrint)
		--GameSession.PrintState(stateToPrint)
	--end)
	
	GameSession.OnSave(function()
	    Cron.After(0.1, function()
            for _, file in pairs(dir(sessionsFolder)) do
                if file.type == "file" and file.name:match("%.lua$") then
					if file.name:match("VortexCanYouSeriouslyGoAway.lua") then
						local nothing = 0
					else
						os.remove(sessionsFolder .. '/' .. file.name)
					end
                end
            end
        end)
	end)
	
	GameSession.OnLoad(function()
		if Game.GetFact("CMS_Version") == 0 then
			if Game.GetFact("CMS_AmountVehicleToUpgrade") ~= 0 then 
				Game.AddToInventory("Items.money", 50000)
				print('A little compensation of 50000 Eddies has been transfered to your account. Your car upgrades have been reset due to having an old broken version of the save system.')
			end
			Game.SetFactValue("CMS_AmountVehicleToUpgrade", 0)
			Game.AddFact("CMS_Version", CMSVersion)
		end
		
		Game.SetFactValue("CMS_Version", CMSVersion)
	
		for _, upgradedCarToRemove in pairs(state.upgradedCarsInState) do
			--print(upgradedCarToRemove)
			RemovePreviousCarClone(upgradedCarToRemove)
		end
		state.upgradedCarsInState = {}
		OnLoad(0)
		ShowMapPin()
	end)
	
	--if ((Game.GetFact("CMS_User_Fact") ~= nil) and (Game.GetFact("CMS_User_Fact") ~= 0)) then
	--	--If you are trying to find out why your Vehicle TweakDB Isn't Working that is supposed to override CVO, this is the line. 
	--	--Please load your mods with 0.5/1.0s delay otherwise incorrect data will be passed to CMS and your mods changes won't work.
	--	for _, upgradedCarToRemove in pairs(state.upgradedCarsInState) do
	--		--print(upgradedCarToRemove)
	--		RemovePreviousCarClone(upgradedCarToRemove)
	--	end
	--	state.upgradedCarsInState = {}
	--	OnLoad(0)
	--end
	
	--Begining of Shard UI
	--UIPopupsManager.Inititalize()
	
	-- This unused class will be used to handle ink events
	-- This is a workaround for not being able to add new methods
	eventCatcher = sampleStyleManagerGameController.new()

	---@param self PopupsManager
	Observe('PopupsManager', 'OnPlayerAttach', function(self)
		gameController = self
	end)

	Observe('PopupsManager', 'OnPlayerDetach', function()
		gameController = nil
	end)

	---@param self ShardNotificationController
	Observe('ShardNotificationController', 'SetButtonHints', function(self)
		-- If there's no notification data then it's not our popup
		if not notificationData or widgetWasIntialized then
			return
		end
				
		buttonsData = {}
		buttonWidgets = {}
		widgetAreas = {}
		
		latestsNotificationController = self
		
		ShouldClearAllOnNextUpgrade = false
		
		local currentData = self:GetRootWidget():GetUserData('ShardReadPopupData')

		-- If passed user data is not our notification data
		-- then it's not our popup either
		if not isSameInstance(notificationData, currentData) then
			return
		end
		
		inkTextRef.SetText(self.titleRef, lang.getText("CMSName"))

		local rootWidget = self:GetRootCompoundWidget()
		
		-- Container and making sure the colors are the same even with HUD mods
		-- If you are reading this, yes this has been made specifically because of Spicy's E3 HUD :)
		local containerBG = rootWidget:GetWidgetByPathName(StringToName('container/Panel/mainBgHolder/bg'))		
		containerBG:SetTintColor(HDRColor.new({ Red = 0.054902, Green = 0.054902, Blue = 0.090196, Alpha = 1.0 }))
		containerBG:SetOpacity(0.8)
		
		local containerBGOutline = rootWidget:GetWidgetByPathName(StringToName('container/Panel/mainBgHolder/bg_outline'))				
		containerBGOutline:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		containerBGOutline:SetOpacity(0.3)
		
		local containerBGRight = rootWidget:GetWidgetByPathName(StringToName('container/Panel/mainBgHolder/right_bg'))				
		containerBGRight:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		containerBGRight:SetOpacity(0.8)
		
		local containerBGRightOutline = rootWidget:GetWidgetByPathName(StringToName('container/Panel/mainBgHolder/right_outline'))				
		containerBGRightOutline:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		containerBGRightOutline:SetOpacity(0.3)
		
		-- Left Container
		local containerLeftBracketBorder = rootWidget:GetWidgetByPathName(StringToName('container/Panel/leftBracketHolder/left_bracketBorder'))				
		containerLeftBracketBorder:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		containerLeftBracketBorder:SetOpacity(0.3)
		
		local containerLeftBracketBorderBg = rootWidget:GetWidgetByPathName(StringToName('container/Panel/leftBracketHolder/left_bracketBorderBg'))				
		containerLeftBracketBorderBg:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		containerLeftBracketBorderBg:SetOpacity(0.3)
		
		local containerLeftBracketAccent = rootWidget:GetWidgetByPathName(StringToName('container/Panel/leftBracketHolder/left_bracket_accent'))				
		containerLeftBracketAccent:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		containerLeftBracketAccent:SetOpacity(0.0)
		
		local containerLeftBracket = rootWidget:GetWidgetByPathName(StringToName('container/Panel/leftBracketHolder/left_bracket'))				
		containerLeftBracket:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		containerLeftBracket:SetOpacity(0.3)
		
		-- Container button
		local containerButtonBg = rootWidget:GetWidgetByPathName(StringToName('container/Panel/ButtonList/button_holder'))
		containerButtonBg:SetVisible(false)
		
		local containerButtonBg = rootWidget:GetWidgetByPathName(StringToName('container/Panel/ButtonList/button_holder/bg'))
		containerButtonBg:SetTintColor(HDRColor.new({ Red = 0.054902, Green = 0.054902, Blue = 0.090196, Alpha = 1.0 }))
		containerButtonBg:SetOpacity(0.8)
		
		local containerButtonFrame = rootWidget:GetWidgetByPathName(StringToName('container/Panel/ButtonList/button_holder/bg_outline'))
		containerButtonFrame:SetTintColor(HDRColor.new({ Red = 0.368627, Green = 0.964706, Blue = 1.0, Alpha = 1.0 }))
		containerButtonFrame:SetOpacity(0.3)
		
		-- Yes this is intentionally commented
		--local containerButtonText = rootWidget:GetWidgetByPathName(StringToName('container/Panel/ButtonList/button_holder/inkHorizontalPanelWidget5/label'))		
		--containerButtonText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
		--containerButtonText:SetFontStyle('Medium')
		--containerButtonText:SetFontSize(40)
		
		-- Actual shard building:

		---@type inkImage
		local titleIcon = rootWidget:GetWidgetByPathName(StringToName('container/Panel/vertical_organizer/topBar/icon'))
		titleIcon:SetTintColor(inkWidgetRef.GetTintColor(self.titleRef))
		titleIcon:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\fullscreen\\hub_menu\\hub_atlas.inkatlas'))
		titleIcon:SetTexturePart('ico_cafting_upgrading')

		local contentArea = rootWidget:GetWidgetByPathName(StringToName('container/Panel/vertical_organizer/contentArea'))

		local uiArea = inkCanvas.new()
		uiArea:SetName('uiArea')
		uiArea:SetAnchor(inkEAnchor.Fill)
		uiArea:Reparent(contentArea, -1)
		uiAreaElement = uiArea

		local selectionImage = inkImage.new()
		selectionImage:SetName('image')
		selectionImage:SetMargin(inkMargin.new({ left = 580.0, top = 100.0 }))
		selectionImage:SetFitToContent(true)
		selectionImage:SetScale(Vector2.new({ X = 0.5, Y = 0.5 }))
		selectionImage:SetRenderTransformPivot(Vector2.new({ X = 0.0, Y = 0.0 }))
		selectionImage:Reparent(uiArea, -1)
		
		--Scroll Component
		local scrollComponent = UIScroller.Create()

		local scrollPanel = scrollComponent:GetRootWidget()
		scrollPanel:SetAnchor(inkEAnchor.TopLeft)
		scrollPanel:SetMargin(inkMargin.new({ left = 40.0, top = 0.0 }))
		scrollPanel:SetSize(Vector2.new({ X = 1600.0, Y = 760.0 }))
		scrollPanel:Reparent(uiArea, -1)

		local scrollContent = scrollComponent:GetContentWidget()

		local textList = inkVerticalPanel.new()
		textList:SetName('list')
		textList:SetPadding(inkMargin.new({ left = 32.0, top = 2.0, right = 32.0 }))
		textList:SetChildMargin(inkMargin.new({ top = 2.0, bottom = 2.0 }))
		textList:SetFitToContent(true)
		textList:Reparent(scrollContent, -1)
		
		--Scroll Text Canvas'
		local TextCanvas = inkCanvas.new()
		TextCanvas:SetName('TextCanvas1')
		TextCanvas:SetSize(400.0, 750.0)
		TextCanvas:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
		TextCanvas:SetInteractive(false)

		local TextCanvas2 = inkCanvas.new()
		TextCanvas2:SetName('TextCanvas2')
		TextCanvas2:SetSize(400.0, 750.0)
		TextCanvas2:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
		TextCanvas2:SetInteractive(false)
		
		--Totals Text Canvases
		local TextCanvasTotalBase = inkCanvas.new()
		TextCanvasTotalBase:SetName('TextCanvasTotalBase')
		TextCanvasTotalBase:SetSize(400.0, 400.0)
		TextCanvasTotalBase:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
		TextCanvasTotalBase:SetInteractive(false)
		
		TextCanvasTotalBaseElementBase = TextCanvasTotalBase

		--All base details
		local buttonArea = inkCanvas.new()
		buttonArea:SetName('buttons')
		buttonArea:SetAnchor(inkEAnchor.Fill)
		buttonArea:Reparent(contentArea, -1)
						
		--Part Basket: text
		local partBasketMainText = inkText.new()
		partBasketMainText:SetName('basketMainText')
		partBasketMainText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
		partBasketMainText:SetFontStyle('Medium')
		partBasketMainText:SetFontSize(45)
		partBasketMainText:SetTintColor(HDRColor.new({ Red = 0.813725, Green = 0.829412, Blue = 0.813726, Alpha = 1.0 }))
		partBasketMainText:SetHorizontalAlignment(textHorizontalAlignment.Center)
		partBasketMainText:SetVerticalAlignment(textVerticalAlignment.Center)
		partBasketMainText:SetMargin(inkMargin.new({ left = 490.0, top = -50.0 }))
		partBasketMainText:Reparent(buttonArea, -1)
		local partBasketMainTextToSet = lang.getText("partBasketMainTextToSet")
		partBasketMainText:SetText(partBasketMainTextToSet)
		
		--Part Basket: parts text		
		local selectionText = inkText.new()
		selectionText:SetName('text')
		selectionText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
		selectionText:SetFontStyle('Medium')
		selectionText:SetFontSize(37)
		selectionText:SetTintColor(HDRColor.new({ Red = 0.113725, Green = 0.929412, Blue = 0.513726, Alpha = 1.0 }))
		selectionText:SetHorizontalAlignment(textHorizontalAlignment.Center)
		selectionText:SetVerticalAlignment(textVerticalAlignment.Center)
		selectionText:SetMargin(inkMargin.new({ left = 417.5, top = -5 }))
		selectionText:Reparent(TextCanvas, -1)
		TextCanvas:Reparent(textList, -1)
		
		local basketText = ''
		for _, basketItem in pairs(PartBasket) do
			basketText = basketText .. lang.getText("PartName-0" .. tostring(PartsList[basketItem].ID)) .. '\n'
		end
		selectionText:SetText(basketText)
		basketWidget = selectionText
		
		--Upgraded Parts: text
		local partListMainText = inkText.new()
		partListMainText:SetName('partsListMainText')
		partListMainText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
		partListMainText:SetFontStyle('Medium')
		partListMainText:SetFontSize(45)
		partListMainText:SetTintColor(HDRColor.new({ Red = 0.813725, Green = 0.829412, Blue = 0.813726, Alpha = 1.0 }))
		partListMainText:SetHorizontalAlignment(textHorizontalAlignment.Center)
		partListMainText:SetVerticalAlignment(textVerticalAlignment.Center)
		partListMainText:SetMargin(inkMargin.new({ left = 1070.0, top = -50.0 }))
		partListMainText:Reparent(buttonArea, -1)
		local partListMainTextToSet = lang.getText("partListMainTextToSet")
		partListMainText:SetText(partListMainTextToSet)
		
		--Upgraded Parts: parts text
		local selectionText2 = inkText.new()
		selectionText2:SetName('secondaryText')
		selectionText2:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
		selectionText2:SetFontStyle('Medium')
		selectionText2:SetFontSize(37)
		selectionText2:SetTintColor(HDRColor.new({ Red = 0.113725, Green = 0.929412, Blue = 0.513726, Alpha = 1.0 }))
		selectionText2:SetHorizontalAlignment(textHorizontalAlignment.Center)
		selectionText2:SetVerticalAlignment(textVerticalAlignment.Center)
		selectionText2:SetMargin(inkMargin.new({ left = 997.5, top = -757.5 }))
		
		selectionText2:Reparent(TextCanvas2, -1)
		TextCanvas2:Reparent(textList, -1)
		
		local basketText2 = ''
		if CurrentVehicleListNum > -1 then
			if UpgradedCarList[CurrentVehicleListNum] ~= nil then
				for _, upgradedPartFromList in pairs(UpgradedCarList[CurrentVehicleListNum].CurrentParts) do
				basketText2 = basketText2 .. lang.getText("PartName-0" .. tostring(PartsList[upgradedPartFromList].ID)) .. '\n'
				end
			end
		end
		selectionText2:SetText(basketText2)
		carPartsWidget = selectionText2

		--Description of items
		CreateDescriptionBox(uiArea)
		
		--Basket Box and stuff
		basketBox = GameShardUI.createBox("basketBox", true)
		basketBox:SetSize(730.0, 150.0)
		basketBox:SetMargin(inkMargin.new({ left = 1320.0, top = -310.0 }))
		basketBox:Reparent(uiAreaElement, -1)
		
		ShowUpgradeTotals()
		
		CName.add('ButtonClearBasket')
		local buttonData = {
			name = CName('ButtonClearBasket'),
			text = lang.getText("ButtonClearBasket"),
			value = 53,
			btype = "ClearBasket",
			bchild = {}
		}

		local buttonWidget = GameShardUI.createButton(buttonData.name, buttonData.text)
		--buttonWidget:SetSize(400.0, 97.5)
		buttonWidget:SetMargin(inkMargin.new({ left = 220.0, top = 75.0 }))
		buttonWidget:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
		buttonWidget:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
		buttonWidget:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
		buttonWidget:Reparent(basketBox, -1)

		table.insert(buttonsData, buttonData)
		
		--Not enough money Box and its stuff
		brokeConfirmBox = GameShardUI.createBox("brokeConfirmBox", true)
		brokeConfirmBox:SetSize(440.0, 275.0)
		brokeConfirmBox:SetMargin(inkMargin.new({ left = 900.0, top = 400.0 }))
		brokeConfirmBox:Reparent(uiAreaElement, -1)
		
		local brokeConfirmText = inkText.new()
		brokeConfirmText:SetName('secondaryText')
		brokeConfirmText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
		brokeConfirmText:SetFontStyle('Medium')
		brokeConfirmText:SetFontSize(37)
		brokeConfirmText:SetTintColor(HDRColor.new({ Red = 0.113725, Green = 0.929412, Blue = 0.513726, Alpha = 1.0 }))
		brokeConfirmText:SetHorizontalAlignment(textHorizontalAlignment.Center)
		brokeConfirmText:SetVerticalAlignment(textVerticalAlignment.Center)
		brokeConfirmText:SetMargin(inkMargin.new({ left = 7.5 }))
		brokeConfirmText:Reparent(brokeConfirmBox, -1)
		brokeConfirmText:SetText(lang.getText("brokeConfirmBox"))
				
		CName.add('ButtonAcceptBroke')
		local buttonConfirmData = {
			name = CName('ButtonAcceptBroke'),
			text = lang.getText("ButtonAcceptBroke"),
			value = 54,
			btype = "BrokeContinue",
			bchild = {}
		}

		local buttonConfirmWidget = GameShardUI.createButton(buttonConfirmData.name, buttonConfirmData.text)
		--buttonWidget:SetSize(400.0, 97.5)
		buttonConfirmWidget:SetMargin(inkMargin.new({ left = 220.0, top = 200.0 }))
		buttonConfirmWidget:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
		buttonConfirmWidget:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
		buttonConfirmWidget:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
		buttonConfirmWidget:Reparent(brokeConfirmBox, -1)
		
		brokeConfirmBox:SetVisible(false)

		table.insert(buttonsData, buttonConfirmData)
		
		-- Clear Parts System
		ClearPartsBox = GameShardUI.createBox("ClearPartsBox", true)
		ClearPartsBox:SetSize(875.0, 150.0)
		ClearPartsBox:SetMargin(inkMargin.new({ left = 360.0, top = -310.0 }))
		ClearPartsBox:Reparent(uiAreaElement, -1)
		
		CName.add('ClearAllUpgrades')
		CName.add('ButtonStartDowngrading')
		
		local ButtonStartDowngrading = {
			name = CName('ButtonStartDowngrading'),
			text = lang.getText("ButtonStartDowngrading"),
			value = 55,
			btype = "ButtonDowngrading",
			bchild = {}
		}
		
		local ButtonStartDowngradingWidget = GameShardUI.createButton(ButtonStartDowngrading.name, ButtonStartDowngrading.text)
		--buttonWidget:SetSize(400.0, 97.5)
		ButtonStartDowngradingWidget:SetMargin(inkMargin.new({ left = 660.0, top = 80.0 }))
		ButtonStartDowngradingWidget:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
		ButtonStartDowngradingWidget:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
		ButtonStartDowngradingWidget:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
		ButtonStartDowngradingWidget:Reparent(ClearPartsBox, -1)
		
		table.insert(buttonsData, ButtonStartDowngrading)
		
		local ClearAllUpgrades = {
			name = CName('ClearAllUpgrades'),
			text = lang.getText("ClearAllUpgrades"),
			value = 56,
			btype = "ClearAllUpgrades",
			bchild = {}
		}
		
		local ClearAllButton = GameShardUI.createButton(ClearAllUpgrades.name, ClearAllUpgrades.text)
		--buttonWidget:SetSize(400.0, 97.5)
		ClearAllButton:SetMargin(inkMargin.new({ left = 220.0, top = 80.0 }))
		ClearAllButton:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
		ClearAllButton:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
		ClearAllButton:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
		ClearAllButton:Reparent(ClearPartsBox, -1)
		
		table.insert(buttonsData, ClearAllUpgrades)
		
		--Other Buttons and Lists
		local selectionImage = inkImage.new()
		selectionImage:SetName('image')
		selectionImage:SetMargin(inkMargin.new({ left = 540.0, top = 100.0 }))
		selectionImage:SetFitToContent(true)
		selectionImage:SetScale(Vector2.new({ X = 0.5, Y = 0.5 }))
		selectionImage:SetRenderTransformPivot(Vector2.new({ X = 0.0, Y = 0.0 }))
		selectionImage:Reparent(buttonArea, -1)

		local buttonList = inkVerticalPanel.new()
		buttonList:SetName('ButtonListBase')
		buttonList:SetAnchor(inkEAnchor.LeftFillVerticaly)
		buttonList:SetMargin(inkMargin.new({ left = 40.0, top = 0.0, right = 0.0, bottom = 0.0 }))
		buttonList:SetChildMargin(inkMargin.new({ left = 0.0, top = 8.0, right = 0.0, bottom = 8.0 }))
		buttonList:Reparent(buttonArea, -1)
		
		local buttonList2 = inkVerticalPanel.new()
		buttonList2:SetName('ButtonListBase')
		buttonList2:SetAnchor(inkEAnchor.LeftFillVerticaly)
		buttonList2:SetMargin(inkMargin.new({ left = 950.0, top = 933.0, right = 0.0, bottom = 10.0 }))
		buttonList2:SetChildMargin(inkMargin.new({ left = 0.0, top = 8.0, right = 0.0, bottom = 10.0 }))
		buttonList2:Reparent(buttonArea, -1)
		
		local buttonList3 = inkVerticalPanel.new()
		buttonList3:SetName('ButtonListBase')
		buttonList3:SetAnchor(inkEAnchor.LeftFillVerticaly)
		buttonList3:SetMargin(inkMargin.new({ left = 1400.0, top = 933.0, right = 0.0, bottom = 10.0 }))
		buttonList3:SetChildMargin(inkMargin.new({ left = 0.0, top = 8.0, right = 0.0, bottom = 10.0 }))
		buttonList3:Reparent(buttonArea, -1)
		
		local previousPageButtonList = inkVerticalPanel.new()
		previousPageButtonList:SetName('ButtonListBase')
		previousPageButtonList:SetAnchor(inkEAnchor.LeftFillVerticaly)
		previousPageButtonList:SetMargin(inkMargin.new({ left = 1200.0, top = -190.0, right = 0.0, bottom = 10.0 }))
		previousPageButtonList:SetChildMargin(inkMargin.new({ left = 0.0, top = 8.0, right = 0.0, bottom = 8.0 }))
		previousPageButtonList:Reparent(buttonArea, -1)
		
		--Parts Buttons
		for i = 1, 7 do
			CName.add('Button' .. UpgradePartNames[i])
			local buttonData = {
				name = CName('Button' .. UpgradePartNames[i]),
				text = UpgradePartNames[i],
				value = i,
				btype = "PartType",
				bchild = {}
			}

			local buttonWidget = GameShardUI.createButton(buttonData.name, lang.getText(UpgradePartNames[i]))
			buttonWidget:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
			buttonWidget:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
			buttonWidget:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
			buttonWidget:Reparent(buttonList, -1)
			
			if CurrentVehicle ~= nil then
				VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()
				vehType = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".type")
				TweakDB:SetFlat(VehicleTweakDBRecordName .. ".type", "Vehicle.Car")
				typeCar = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".type")
				
				TweakDB:SetFlat(VehicleTweakDBRecordName .. ".type", vehType)

				if tostring(vehType) ~= tostring(typeCar) then
					if UpgradePartNames[i] == "Suspension" or UpgradePartNames[i] == "Weight Reduction" then
						buttonWidget:SetVisible(false)
					end
				end
			end
			
			table.insert(buttonsData, buttonData)
		end
		
		widgetAreas[0] = buttonList
		table.insert(currentWidgetAreas, buttonList)
				
		--Stage Buttons
		--local currentButtonData = buttonsData
		for _, PartTypeButton in ipairs(buttonsData) do
		--for PartTypeButton in ipairs(buttonsData) do
			if PartTypeButton.btype == "PartType" then
				local stageButtonList = inkVerticalPanel.new()
				stageButtonList:SetName('ButtonListPartType' .. PartTypeButton.text)
				stageButtonList:SetAnchor(inkEAnchor.LeftFillVerticaly)
				stageButtonList:SetMargin(inkMargin.new({ left = 40.0, top = 0.0, right = 0.0, bottom = 0.0 }))
				stageButtonList:SetChildMargin(inkMargin.new({ left = 0.0, top = 8.0, right = 0.0, bottom = 8.0 }))
				stageButtonList:Reparent(buttonArea, -1)
				PartTypeButton.bchild[0] = {}
				PartTypeButton.bchild[0].objectData = {}
				
				for i = 1, 3 do
					CName.add('ButtonStage'.. PartTypeButton.text .. i)
					local buttonData = {
						name = CName('ButtonStage'.. PartTypeButton.text .. i),
						text = lang.getText("Stage") .. ' ' .. i,
						value = 50 + i,
						btype = "Stage",
						bchild = {}
					}

					local buttonWidget = GameShardUI.createButton(buttonData.name, buttonData.text)
					buttonWidget:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
					buttonWidget:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
					buttonWidget:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
					buttonWidget:Reparent(stageButtonList, -1)
					
					table.insert(buttonsData, buttonData)
					table.insert(PartTypeButton.bchild[0].objectData, buttonData)
					
					-------------------------------------------------------------------------------------------------------------------
					local partStageButtonList = inkVerticalPanel.new()
					partStageButtonList:SetName('ButtonListPartType' .. PartTypeButton.text .. 'Stage' .. i)
					partStageButtonList:SetAnchor(inkEAnchor.LeftFillVerticaly)
					partStageButtonList:SetMargin(inkMargin.new({ left = 40.0, top = 0.0, right = 0.0, bottom = 0.0 }))
					partStageButtonList:SetChildMargin(inkMargin.new({ left = 0.0, top = 8.0, right = 0.0, bottom = 8.0 }))
					partStageButtonList:Reparent(buttonArea, -1)
					--PartTypeButton.bchild[0].objectData = {}
					
					for _, partStage in pairs(PartsList) do
						if partStage.Type == PartTypeButton.text and partStage.Stage == i then
							CName.add('ButtonPart' .. partStage.ID)
							local partButtonData = {
								name = CName('ButtonPart' .. partStage.ID),
								text = lang.getText("PartName-0" .. partStage.ID),
								value = partStage.ID,
								btype = "VehiclePart",
								bchild = {}
							}
							
							local buttonWidgetPart = GameShardUI.createButton(partButtonData.name, partButtonData.text, true)
							buttonWidgetPart:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
							buttonWidgetPart:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
							buttonWidgetPart:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
							buttonWidgetPart:Reparent(partStageButtonList, -1)
							
							table.insert(buttonWidgets, buttonWidgetPart)
							table.insert(buttonsData, partButtonData)
							table.insert(PartTypeButton.bchild[0].objectData, partButtonData)
						end
					end
					table.insert(widgetAreas, partStageButtonList)
					partStageButtonList:SetVisible(false)
					
					--if PartTypeButton.text == "Engine"
					--for StagePartButton in buttonsData do
					
					--UpgradePartNames = {"Engine", "Ecu", "Transmission", "Suspension", "Tires", "Brakes", "Weight Reduction"}
					
					-------------------------------------------------------------------------------------------------------------------

				end
				PartTypeButton.bchild[0].widgetObject = stageButtonList
				table.insert(widgetAreas, stageButtonList)
				stageButtonList:SetVisible(false)
				--PartTypeButton.bchild[0].objectData = {}
			end
		end
		
		currentButtonData = buttonsData
		--Upgrade Confirmation button
		CName.add('ButtonConfirmUpgrade')
		local ConfirmButtonData = {
				name = CName('ButtonConfirmUpgrade'),
				text = lang.getText("ButtonConfirmUpgrade"),
				value = 8,
				btype = "ConfirmUpgrade",
				bchild = {}
		}
				
		local ConfirmButtonWidget = GameShardUI.createButton(ConfirmButtonData.name, ConfirmButtonData.text)
		ConfirmButtonWidget:SetSize(400.0, 97.5)
		ConfirmButtonWidget:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
		ConfirmButtonWidget:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
		ConfirmButtonWidget:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
		ConfirmButtonWidget:Reparent(buttonList2, -1)

		table.insert(buttonsData, ConfirmButtonData)
		table.insert(widgetAreas, buttonList2)
		
		-- Close button
		local CloseUIButton = {
			name = CName('CloseUIButton'),
			text = lang.getText("CloseUIButton"),
			value = 88,
			btype = "CloseUIButton",
			bchild = {}
		}
		
		local CloseUIButtonWidget = GameShardUI.createButton(CloseUIButton.name, CloseUIButton.text)
		--buttonWidget:SetSize(400.0, 97.5)
		--CloseUIButtonWidget:SetMargin(inkMargin.new({ left = 220.0, top = 80.0 }))
		CloseUIButtonWidget:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
		CloseUIButtonWidget:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
		CloseUIButtonWidget:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
		CloseUIButtonWidget:Reparent(buttonList3, -1)
		CloseUIButtonWidget:SetSize(250.0, 97.5)
		
		local inputIconForButton = inkImage.new()
		inputIconForButton:SetName('inputIcon')
		inputIconForButton:SetAtlasResource(ResRef.FromName('base\\gameplay\\gui\\common\\input\\icons_keyboard.inkatlas'))
		inputIconForButton:SetTexturePart('kb_c')
		inputIconForButton:SetHAlign(inkEHorizontalAlign.Center)
		inputIconForButton:SetVAlign(inkEVerticalAlign.Center)
		inputIconForButton:SetAnchor(inkEAnchor.CenterLeft)
		inputIconForButton:SetMargin(inkMargin.new({ left = 50.0, top = 0.0, right = 0.0, bottom = 0.0 }))
		inputIconForButton:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
		inputIconForButton:SetTintColor(HDRColor.new({ Red = 0.949, Green = 0.341, Blue = 0.454, Alpha = 1.0 }))
		inputIconForButton:SetSize(64.0, 64.0)
		inputIconForButton:Reparent(CloseUIButtonWidget, -1)
		
		table.insert(buttonsData, CloseUIButton)
		table.insert(widgetAreas, buttonList3)
		
		-- Return button
		CName.add('ButtonReturn')
		local ReturnButtonData = {
				name = CName('ButtonReturn'),
				text = lang.getText("ButtonReturn"),
				value = 20,
				btype = "ReturnPageButton",
				bchild = {}
		}
		
		local ReturnButtonWidget = GameShardUI.createButton(ReturnButtonData.name, ReturnButtonData.text)
		ReturnButtonWidget:RegisterToCallback('OnPress', eventCatcher, 'OnState1')
		ReturnButtonWidget:RegisterToCallback('OnEnter', eventCatcher, 'OnStyle1')
		ReturnButtonWidget:RegisterToCallback('OnLeave', eventCatcher, 'OnStyle2')
		ReturnButtonWidget:Reparent(previousPageButtonList, -1)

		table.insert(buttonsData, ReturnButtonData)
		table.insert(widgetAreas, previousPageButtonList)
		
		previousPageButtonList:SetVisible(false)
		returnButton = previousPageButtonList
		
		Cron.NextTick(function()
			scrollComponent:UpdateContent(true)
		end)
	end)
		
	Observe('sampleStyleManagerGameController', 'OnStyle1', function(self, evt)
		local buttonWidget = evt:GetTarget()
		for _, buttonData in ipairs(buttonsData) do
			if buttonData.name == buttonWidget:GetName() then
				-- Check if its one of the part buttons
				if buttonData.value > 99 then
					UpdateDescription(lang.getText("PartName-0" .. PartsList[buttonData.value].ID), lang.getText("PartDesc-0" .. PartsList[buttonData.value].ID), lang.getText("descriptionPrice") .. PartsList[buttonData.value].Price .. " €$")
				end
			end
		end
	end)
	
	---@param self sampleStyleManagerGameController
	---@param evt inkPointerEvent
	Observe('sampleStyleManagerGameController', 'OnState1', function(self, evt)
		-- We should check that it's exactly our event catcher
		-- This allows many mods observe the same catch function
		if evt:IsAction('click') and isSameInstance(self, eventCatcher) then
			local audioEvent = SoundPlayEvent.new() -- Play click sound
			audioEvent.soundName = "ui_menu_onpress"
			Game.GetPlayer():QueueEvent(audioEvent)
			
			local buttonWidget = evt:GetTarget()
			for _, buttonData in ipairs(buttonsData) do
				if buttonData.name == buttonWidget:GetName() then
					if buttonData.name == CName('ButtonConfirmUpgrade') then
						if DoesPlayerHaveEnoughMoney(CurrentPrice) == false then		
							brokeConfirmBox:SetVisible(true)
						else
							latestsNotificationController:Close()
							latestsNotificationController = nil
							upgrading = true
						end
					elseif buttonData.name == CName('ButtonReturn') then
						if totalAccessedWidgets > 0 then
							for _, currentWidget in pairs(currentWidgetAreas) do
								currentWidget:SetVisible(false)
							end
							currentWidgetAreas = {}
							
							--Adding old widgets
							totalAccessedWidgets = totalAccessedWidgets - 1
							for _, widgetAreaToGrab in pairs(accessedWidgetAreas[totalAccessedWidgets]) do
								widgetAreaToGrab:SetVisible(true)
								table.insert(currentWidgetAreas, widgetAreaToGrab)
							end
							accessedWidgetAreas[totalAccessedWidgets] = nil
							
							if totalAccessedWidgets < 1 then
								returnButton:SetVisible(false)
							end
							UpdateDescription('-', '-', '-')
						end
					elseif buttonData.name == CName('ButtonClearBasket') then
						--ClearBasket functionality here
						PartBasket = {}
						ShowUpgradeTotals()
						
						if basketWidget ~= nil then
							basketWidget:SetText('')
						end
					elseif buttonData.name == CName('CloseUIButton') then
						latestsNotificationController:Close()
						latestsNotificationController = nil
					elseif buttonData.name == CName('ButtonAcceptBroke') then
						brokeConfirmBox:SetVisible(false)
					elseif buttonData.name == CName('ClearAllUpgrades') then
						if ShouldClearAllOnNextUpgrade then
							ShouldClearAllOnNextUpgrade = false
							GameShardUI.setButtonText(buttonWidget, lang.getText("ClearAllUpgrades"))
						else
							ShouldClearAllOnNextUpgrade = true
							GameShardUI.setButtonText(buttonWidget, lang.getText("StopUpgradeClear"))
						end
						
					elseif buttonData.name == CName('ButtonStartDowngrading') then
						--print("started downgrading")
						if isDowngrading then
							GameShardUI.setButtonText(buttonWidget, lang.getText("ButtonStartDowngrading"))
							isDowngrading = false
							
							for ind2, buttonWidget in pairs(buttonWidgets) do 
								buttonWidget:SetVisible(true)
							end
						else
							isDowngrading = true
							GameShardUI.setButtonText(buttonWidget, lang.getText("ButtonStopDowngrading"))
							
							for ind2, listedButton in pairs(buttonsData) do
								if listedButton.value > 99 then 
									if UpgradedCarList[CurrentVehicleListNum] ~= nil then
										local isPartUpgraded = false
										
										for ind3, upgradedPartFromList in pairs(UpgradedCarList[CurrentVehicleListNum].CurrentParts) do
											if listedButton.value == upgradedPartFromList then
												isPartUpgraded = true
												--print("found upgraded part")
											end
										end
										
										if isPartUpgraded == false then
											for ind4, buttonWidget in pairs(buttonWidgets) do 
												if buttonWidget.name == listedButton.name then
													buttonWidget:SetVisible(false)
												end
											end
										end
									else
										for ind2, buttonWidget in pairs(buttonWidgets) do 
											buttonWidget:SetVisible(false)
										end
									end
								end
							end
						end
						--Needs a for loop for all the parts in the current car
						
						--Maybe we need some proper functionality here for disabling all basic buttons that are not going to be shown...
					else
						if buttonData.value < 99 and buttonData.value ~= 20 then
							thisPageWidgets = {}
							for _, currentWidget in pairs(currentWidgetAreas) do
								currentWidget:SetVisible(false)
								table.insert(thisPageWidgets, currentWidget)
							end
							
							--table.insert(accessedWidgetAreas, thisPageWidgets)
							accessedWidgetAreas[totalAccessedWidgets] = thisPageWidgets
							totalAccessedWidgets = totalAccessedWidgets + 1
							returnButton:SetVisible(true)
							
							currentWidgetAreas = {}
						end
						
						for _, partTypeNameToFind in pairs(UpgradePartNames) do
							if buttonData.name == CName('Button' .. partTypeNameToFind) then
								--stageButtonList:SetName('ButtonListPartType' .. PartTypeButton.text)
								for _, widgetAreaToFind in pairs(widgetAreas) do
									if widgetAreaToFind.name == CName('ButtonListPartType' .. partTypeNameToFind) then
										widgetAreaToFind:SetVisible(true)
										table.insert(currentWidgetAreas, widgetAreaToFind)
									end
								end
								
								--stageButtonList:SetName('ButtonListPartType' .. PartTypeButton.text)
								--currentWidgetAreas.insert
								--local buttonArea = buttonWidget.parentWidget.parentWidget
								--table.insert(currentWidgetAreas, stageButtonList)
							end
							
							for iStage = 1, 3 do
								if buttonData.name == CName('ButtonStage' .. partTypeNameToFind .. iStage) then
									for _, widgetAreaToFind in pairs(widgetAreas) do
										if widgetAreaToFind.name == CName('ButtonListPartType' .. partTypeNameToFind .. 'Stage' .. iStage) then
											widgetAreaToFind:SetVisible(true)
											table.insert(currentWidgetAreas, widgetAreaToFind)
										end
									end
								end
							end
						end
					
					if buttonData.value > 99 then
						
						if isDowngrading then
							local isUpgradedAlready = false
							
							if UpgradedCarList[CurrentVehicleListNum] ~= nil then
								for _, upgradedPartFromList in pairs(UpgradedCarList[CurrentVehicleListNum].CurrentParts) do
									if PartsList[buttonData.value].ID == PartsList[upgradedPartFromList].ID then
										isUpgradedAlready = true
									end
								end
							end
							
							if isUpgradedAlready then
								table.insert(removalList, buttonData.value)
							end
						
						else
							--Check if currently in basket and clean if it is
							local notInPartBasket = true
							local hasSuperPartAlready = false
							for _, part in pairs(PartBasket) do
								if part == buttonData.value then
									notInPartBasket = false
									PartBasket[_] = nil
								end
								
								if PartsList[part].SuperType == PartsList[buttonData.value].SuperType then
									if PartsList[part].Stage >= PartsList[buttonData.value].Stage then
										hasSuperPartAlready = true
									else
										--Remove from basket this PartsList[part] thingy
										for indexNew, partSecondary in pairs(PartBasket) do
											if partSecondary == PartsList[part].ID then
												PartBasket[indexNew] = nil
											end
										end
									end
								end
							end
							
							--Here check for current vehicles's upgraded parts and compare them to SuperType of the added item.
							--UpgradedCarList[CurrentVehicleListNum].CurrentParts
							if UpgradedCarList[CurrentVehicleListNum] ~= nil then
								for _, upgradedPartFromList in pairs(UpgradedCarList[CurrentVehicleListNum].CurrentParts) do
									if PartsList[buttonData.value].SuperType == PartsList[upgradedPartFromList].SuperType and PartsList[upgradedPartFromList].Stage >= PartsList[buttonData.value].Stage then
										hasSuperPartAlready = true
									end
								end
							end
							
							--Add item if not in part basket
							if notInPartBasket == true then
								--SuperID checking
								if not hasSuperPartAlready then
									table.insert(PartBasket, buttonData.value)
								else
									--You Already have this SuperType part in your basket or installed that is same or higher stage
									
								end
								
							end
							
							for _, part in pairs(PartBasket) do
								--print(part)
							end
						end
					end
					end
					
					--Two levels up is our custom button area widget
					if basketWidget ~= nil then
						local basketText = ''
						for _, basketItem in pairs(PartBasket) do
							basketText = basketText .. lang.getText("PartName-0" .. PartsList[basketItem].ID) .. '\n'
						end
						basketWidget:SetText(basketText)
					end
					
					local basketText2 = ''
					if CurrentVehicleListNum > -1 then
						if UpgradedCarList[CurrentVehicleListNum] ~= nil then
							for _, upgradedPartFromList in pairs(UpgradedCarList[CurrentVehicleListNum].CurrentParts) do
								if ShouldClearAllOnNextUpgrade == false then
									local shouldBeAdded = true
									
									for i2, removalItem in pairs(removalList) do
										if upgradedPartFromList == removalItem then
											shouldBeAdded = false
										end
									end
									
									if shouldBeAdded then
										basketText2 = basketText2 .. lang.getText("PartName-0" .. PartsList[upgradedPartFromList].ID) .. '\n'
									end
								end
							end
						end
					end
					carPartsWidget:SetText(basketText2)
				end
			end
		end
		ShowUpgradeTotals()
	end)
	
	---@param self sampleStyleManagerGameController
	---@param evt inkPointerEvent
	Observe('sampleStyleManagerGameController', 'OnStyle1', function(self, evt)
		if isSameInstance(self, eventCatcher) then
			local buttonWidget = evt:GetTarget()
			buttonWidget:GetWidget('fill'):SetOpacity(0.1)
			buttonWidget:GetWidget('frame'):SetOpacity(1.0)
		end
	end)

	---@param self sampleStyleManagerGameController
	---@param evt inkPointerEvent
	Observe('sampleStyleManagerGameController', 'OnStyle2', function(self, evt)
		if isSameInstance(self, eventCatcher) then
			local buttonWidget = evt:GetTarget()
			buttonWidget:GetWidget('fill'):SetOpacity(0.0)
			buttonWidget:GetWidget('frame'):SetOpacity(0.3)
		end
	end)

	Observe('ShardNotificationController', 'Close', function()
		-- You can set it to nil with latest github build
		-- But with current release you have to use dummy
		notificationToken = inkGameNotificationToken.new()
		notificationData = nil
		latestsNotificationController = nil
		
		accessedWidgetAreas = {}
		totalAccessedWidgets = 0
		isDowngrading = false
		
		if not upgrading then
			ShouldCheckForUpgrade = true
		end
		
		local widgetAreas = {}
		local currentWidgetAreas = {}
		local accessedWidgetAreas = {}

		-- Force to destroy the previous instance that was
		-- in the notificationToken before assignment
		collectgarbage()
	end)

	-- Just for convenience when you realod mods
	---@param self gameuiInGameMenuGameController
	Observe('gameuiInGameMenuGameController', 'SpawnMenuInstanceEvent', function(self)
		gameController = self
	end)
	
	--End of Shard UI
	
	--User Variables
	UserID = 0
	SaveFactID = 0
	
	--Drawing variables
	upgrading = false

	PositionFound = false
	VehicleName = ""
	
	CurrentVehicle = nil
	CurrentVehicleListNum = -1
end)

registerForEvent("onUpdate", function (timeDelta)
	Cron.Update(timeDelta)
	
	if not inGame then
		player = nil
		return
	end
	
	player = Game.GetPlayer()
	if player then
	
		PlayerPosition = player:GetWorldPosition()
		
		if (not CheckCarPosition(PlayerPosition)) then
			--upgrading = false
			if ShouldCheckForUpgrade then
				PositionFound = false
			end
		end
		
		--CurrentVehicle = Game.GetMountedVehicle(player)
		playerInsideWorkspot = Game.GetWorkspotSystem():IsActorInWorkspot(player)
		
		if (CurrentVehicle ~= nil and not playerInsideWorkspot) then
			-- Guess why I didn't implement this? To somewhat idiot proof it...
			--MountVehicle(CurrentVehicle.GetEntityID())
			--UnMountVehicle()
			--MountVehicle(CurrentVehicle:GetEntityID())
			--print(tostring(CurrentVehicle.GetEntityID()))
		end
		
		if (playerInsideWorkspot) then
			CurrentVehicle = Game.GetMountedVehicle(player)
			--MountVehicle(CurrentVehicle.GetEntityID())
			--print (CurrentVehicle.GetEntityID())
			if (CurrentVehicle ~= nil) then
				if (CurrentVehicle:IsPlayerVehicle()) then
					VehicleName = tostring(CurrentVehicle:GetDisplayName())
					if (not upgrading) then
						if (CheckCarPosition(PlayerPosition)) then
							if (CheckCarPosition(PlayerPosition)and not PositionFound) then
								PositionFound = true
								ShouldCheckForUpgrade = false
																
								VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()
								CurrentVehicleListNum = -1
								for ind, UpgradedCar in pairs(UpgradedCarList) do
									if (UpgradedCar.TweakDBID == VehicleTweakDBRecordName) then
										CurrentVehicleListNum = ind
									end
								end
								
								--Shard UI Drawing
								if gameController then
									notificationData = ShardReadPopupData.new()
									notificationData.notificationName = 'base\\gameplay\\gui\\widgets\\notifications\\shard_notification.inkwidget'
									notificationData.queueName = 'modal_popup'
									notificationData.isBlocking = true
									notificationData.useCursor = true

									notificationToken = gameController:ShowGameNotification(notificationData)
								end
								
								--StopTime()
							end
						end
					end
				end
			end
		end

		if (upgrading and playerInsideWorkspot) then	
			local VehicleNumberToUse = -1
			
			VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()

			local moneyNeeded = CurrentPrice
			
			if DoesPlayerHaveEnoughMoney(moneyNeeded) then
				for ind, UpgradedCar in pairs(UpgradedCarList) do

					if (UpgradedCar.TweakDBID == VehicleTweakDBRecordName) then
						VehicleNumberToUse = ind
						CurrentVehicleListNum = ind
					end
				end
				
				if (VehicleNumberToUse ~= -1) then					
					VehicleTweakDBRecordName = UpgradedCarList[VehicleNumberToUse].TweakDBID
					
					if ShouldClearAllOnNextUpgrade == false then
						--Lua tables start from 1 not 0, don't forget :)
						local amountOfItemsInBasketCurrently = 1
						for _, partB in pairs(PartBasket) do
							amountOfItemsInBasketCurrently = amountOfItemsInBasketCurrently + 1
						end
						
						--Still needs to check if any part in the basket is not here already 
						for _, UpgradVEHPart in pairs(UpgradedCarList[VehicleNumberToUse].CurrentParts) do
							HasNotBeenAdded = true
							
							for i, partB in pairs(PartBasket) do
								if (UpgradVEHPart == partB) then
									HasNotBeenAdded = false
								end
								
								if PartsList[UpgradVEHPart].SuperType == PartsList[partB].SuperType and PartsList[partB].Stage >= PartsList[UpgradVEHPart].Stage then
									HasNotBeenAdded = false
								end
							end
							
							for j, partRemoval in pairs(removalList) do
								if UpgradVEHPart == partRemoval then
									HasNotBeenAdded = false
								end
							end
							
							if (HasNotBeenAdded) then
								PartBasket[amountOfItemsInBasketCurrently] = UpgradVEHPart
								amountOfItemsInBasketCurrently = amountOfItemsInBasketCurrently + 1
							end
						end
					else
						ShouldClearAllOnNextUpgrade = false
						PartBasket = {}
					end
					

					local carCloneName = "Vehicle.v_CMS_" .. VehicleTweakDBRecordName.hash .. VehicleTweakDBRecordName.length
					
					--print("Vehicle to SaveFact: " .. VehicleNumberToUse)
					UpgradedCarList[VehicleNumberToUse] = CloneCarForUpgrade(VehicleTweakDBRecordName, carCloneName, VehicleNumberToUse, false)
					UpgradeCarFromBasket(PartBasket, UpgradedCarList[VehicleNumberToUse], VehicleNumberToUse)
					PartBasket = {}
					--print("upgraded existing car")
					--print(VehicleNumberToUse)
				else

					local carCloneName = "Vehicle.v_CMS_" .. VehicleTweakDBRecordName.hash .. VehicleTweakDBRecordName.length
					
					UpgradedCarCount = Game.GetFact("CMS_AmountVehicleToUpgrade") + 1
					
					--print(UpgradedCarCount)
					UpgradedCarList[UpgradedCarCount] = CloneCarForUpgrade(VehicleTweakDBRecordName, carCloneName, UpgradedCarCount, true)
					UpgradeCarFromBasket(PartBasket, UpgradedCarList[UpgradedCarCount], UpgradedCarCount)
					PartBasket = {}
					
					CurrentVehicleListNum = UpgradedCarCount
					--UpgradedCarCount = UpgradedCarCount + 1
					--print("upgraded a new car")
					--print(UpgradedCarCount)
				end
							
				--print("Car Upgraded!!")
				
				pos = Game.GetPlayer():GetWorldPosition()
				--EntityIDToUse = CurrentVehicle:GetEntityID()
				UnMountVehicle()
				
				local vehicleGarageId = NewObject('vehicleGarageVehicleID')
				vehicleGarageId.recordID = TweakDBID.new(VehicleTweakDBRecordName)
				
				local vehicleGarageIdCurrent = NewObject('vehicleGarageVehicleID')
				vehicleGarageIdCurrent.recordID = TweakDBID.new(VehicleTweakDBRecordName)
				

				Cron.Every(0.05, function(timer1)
					if inGame then
						if Game.GetWorkspotSystem():IsActorInWorkspot(player) == false then 
							timer1:Halt()
							Cron.After(0.1, function()
								Game.GetVehicleSystem():ToggleSummonMode()
								Game.GetVehicleSystem():DespawnPlayerVehicle(vehicleGarageIdCurrent)
								--local vehicleGarageId = GetSingleton('vehicleGarageVehicleID'):Resolve(VehicleTweakDBRecordName)
								Game.GetVehicleSystem():TogglePlayerActiveVehicle(vehicleGarageId, 'Car', true)
								Game.GetVehicleSystem():SpawnPlayerVehicle('Car')
								Game.GetVehicleSystem():ToggleSummonMode()
								
								Cron.Every(0.05, function(timer2)
									local vehicleSummonDef = Game.GetAllBlackboardDefs().VehicleSummonData
									local vehicleSummonBB = Game.GetBlackboardSystem():Get(vehicleSummonDef)
									vehicleEntId = vehicleSummonBB:GetEntityID(vehicleSummonDef.SummonedVehicleEntityID)
									
									local entity = Game.FindEntityByID(vehicleEntId)
									
									--Game.FindEntityByID(CurrentVehicle:GetEntityID())
									if entity and entity:GetRecordID() == VehicleTweakDBRecordName then
										-- Entity spawned
										MountVehicle(vehicleEntId)
										--Game.TeleportPlayerToPosition(pos.x, pos.y, pos.z)
										Game.GetTeleportationFacility():Teleport(Game.GetPlayer(), Vector4.new(-770.597168, 2972.367676, 26.418839, 0), EulerAngles.new(0,0,Game.GetPlayer():GetWorldYaw()))
										Cron.After(10.0, function()
											ShouldCheckForUpgrade = true
										end)
										timer2:Halt()
									end
								end)
							
							end)
						end
					end
				end)
				
				--print("Car Upgraded2!!")
				
				AccountBalanceUpdate(moneyNeeded)
				
				upgrading = false
				
			else
				brokeConfirmBox:SetVisible(true)
			end
		end

	end
	

	
end)

registerForEvent('onShutdown', function()
	state.upgradedCarsInState = UpgradedCarList
    GameSession.TrySave()
end)

function CleanGarbage()
	-- You can set it to nil with latest github build
	-- But with current release you have to use dummy
	notificationToken = inkGameNotificationToken.new()
	notificationData = nil
	latestsNotificationController = nil
	
	widgetAreas = {}
	currentWidgetAreas = {}
	accessedWidgetAreas = {}
	buttonWidgets = {}
	buttonData = {}

	-- Force to destroy the previous instance that was
	-- in the notificationToken before assignment
	collectgarbage()
end
	
function UpgradeCarFromBasket(PartBasketToUse, UpgradedCarPath, VehicleNumberToUse)
	local AmountOfUpgradedParts = 0
	for _, partNumberToUse in pairs(PartBasketToUse) do
		for _, Modifier in pairs(PartsList[partNumberToUse].SubModifiers) do
			if Modifier.RecordType == "VehicleGearData" then
				FlatToApplyTo = FindFlat(UpgradedCarPath, Modifier.RecordType, Modifier.VariableName)
				OriginalFlatToGet = FindOriginalFlat(UpgradedCarPath, Modifier.RecordType, Modifier.VariableName)
				
				for indGear, GearFlatToApplyTo in pairs(FlatToApplyTo) do
					--OriginalFlatToGet[indGear]
					ModFlat(UpgradedCarPath, GearFlatToApplyTo, OriginalFlatToGet[indGear], Modifier.ModifierValue, Modifier.ModifierType, Modifier.VariableName)
				end
			else
				FlatToApplyTo = FindFlat(UpgradedCarPath, Modifier.RecordType, Modifier.VariableName)
				OriginalFlatToGet = FindOriginalFlat(UpgradedCarPath, Modifier.RecordType, Modifier.VariableName)
				ModFlat(UpgradedCarPath, FlatToApplyTo, OriginalFlatToGet, Modifier.ModifierValue, Modifier.ModifierType, Modifier.VariableName)
			end
		end
		CurrentPrice = CurrentPrice - PartsList[partNumberToUse].Price
		UpgradedCarPath.CurrentParts[AmountOfUpgradedParts] = partNumberToUse
		AmountOfUpgradedParts = AmountOfUpgradedParts + 1
		
		--CMS_VehicleToUpgrade2PartsAmount
		--CMS_VehicleToUpgrade0PartsAmount
		--Amount of Parts here
		--print("Vehicle To Upgrade Num: " .. VehicleNumberToUse)
		
		CName.add("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount")
		if ((Game.GetFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount") ~= nil) and (Game.GetFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount") ~= 0)) then
			Game.SetFactValue("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount", AmountOfUpgradedParts)
		else
			Game.AddFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount", AmountOfUpgradedParts)
		end
		
		--Part ID to Add Here
		--CMS_VehicleToUpgrade0Part0
		CName.add("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "Part" .. AmountOfUpgradedParts)
		
		if ((Game.GetFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "Part" .. AmountOfUpgradedParts) ~= nil) and (Game.GetFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "Part" .. AmountOfUpgradedParts) ~= 0)) then
			Game.SetFactValue("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "Part" .. AmountOfUpgradedParts, partNumberToUse)
		else
			Game.AddFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "Part" .. AmountOfUpgradedParts, partNumberToUse)
		end
	end
	
	if AmountOfUpgradedParts == 0 then 
		if ((Game.GetFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount") ~= nil) and (Game.GetFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount") ~= 0)) then
			Game.SetFactValue("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount", AmountOfUpgradedParts)
		else
			Game.AddFact("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "PartsAmount", AmountOfUpgradedParts)
		end
	end
end

function ClearCarUpgradesButton(UpgradVEH)
	RemovePreviousCarClone(UpgradVEH)
end

function ModFlat(VehicleToUse, FlatToSetTo, OriginalFlatToGetFrom, ModifierValueToSet, ModifierTypeToUse, VariableOfModifier)
	local CurrentFlatValue = TweakDB:GetFlat(FlatToSetTo)
	local OriginalFlatValue = TweakDB:GetFlat(OriginalFlatToGetFrom)
	
	if ModifierTypeToUse == "Add" then
		local ValueToSet = CurrentFlatValue + ModifierValueToSet
		TweakDB:SetFlat(FlatToSetTo, ValueToSet)
	end
	
	if ModifierTypeToUse == "Mult" then
		--print("current value: " .. CurrentFlatValue)
		--print("original value: " .. OriginalFlatValue)
		
		local ValueToSet = CurrentFlatValue
		
		if VariableOfModifier == "engineMaxTorque" then
			ValueToSet = CurrentFlatValue + ((OriginalFlatValue * ModifierValueToSet) - OriginalFlatValue)
		else
			ValueToSet = CurrentFlatValue + ((OriginalFlatValue * ModifierValueToSet) - OriginalFlatValue)
		end
		TweakDB:SetFlat(FlatToSetTo, ValueToSet)
	end
	
	if ModifierTypeToUse == "Bool" then
		TweakDB:SetFlat(FlatToSetTo, ModifierValueToSet)
	end
	
	if ModifierTypeToUse == "AddGear" then
		local AmountOfGears = 1
		local GearsUsed = {}
		
		fullVehicleName = VehicleToUse.DisplayName
		GearBoxToUse = {}
		
		for _, GearFlatToApplyTo in pairs(TweakDB:GetFlat(fullVehicleName.."_cms_enginedata.gears")) do
			GearsUsed[AmountOfGears] = GearFlatToApplyTo
			GearBoxToUse[AmountOfGears] = fullVehicleName.."_cms_inline_gear"..(AmountOfGears-1)
			AmountOfGears = AmountOfGears + 1
		end
		
		AmountOfGears = AmountOfGears - 1
		--print("amount of gears: " .. AmountOfGears)
		
		--VehicleToUse
		if (AmountOfGears < 8) then
			--Cloning Base and Original Gear 
			TweakDB:CloneRecord(fullVehicleName.."_cms_inline_gear"..AmountOfGears, fullVehicleName.."_cms_inline_gear"..(AmountOfGears-1))
			TweakDB:CloneRecord(fullVehicleName.."_cms_original_inline_gear"..AmountOfGears, fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears-1))
			
			--Setting Base
			TweakDB:SetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears-1) .. ".maxEngineRPM", TweakDB:GetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears-2)..".maxEngineRPM") + 100)
			--TweakDB:SetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears) .. ".minEngineRPM", TweakDB:GetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears) .. ".minEngineRPM") + 100)
			TweakDB:SetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears-1) .. ".minEngineRPM", TweakDB:GetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears-2) .. ".minEngineRPM"))
			TweakDB:SetFlat(fullVehicleName.."_cms_inline_gear"..AmountOfGears .. ".minEngineRPM", TweakDB:GetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears-2) .. ".minEngineRPM"))
			TweakDB:SetFlat(fullVehicleName.."_cms_inline_gear"..AmountOfGears .. ".minSpeed", TweakDB:GetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears-1)..".maxSpeed") * 0.9)
			TweakDB:SetFlat(fullVehicleName.."_cms_inline_gear"..AmountOfGears .. ".maxSpeed", TweakDB:GetFlat(fullVehicleName.."_cms_inline_gear"..(AmountOfGears-1)..".maxSpeed") * ModifierValueToSet)
			
			--Setting original
			TweakDB:SetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears-1) .. ".maxEngineRPM", TweakDB:GetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears-2)..".maxEngineRPM") + 100)
			--TweakDB:SetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears) .. ".minEngineRPM", TweakDB:GetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears) .. ".minEngineRPM") + 100)
			TweakDB:SetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears-1) .. ".minEngineRPM", TweakDB:GetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears-2) .. ".minEngineRPM"))
			TweakDB:SetFlat(fullVehicleName.."_cms_original_inline_gear"..AmountOfGears .. ".minEngineRPM", TweakDB:GetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears-2) .. ".minEngineRPM"))
			TweakDB:SetFlat(fullVehicleName.."_cms_original_inline_gear"..AmountOfGears .. ".minSpeed", TweakDB:GetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears-1)..".maxSpeed") * 0.9)
			TweakDB:SetFlat(fullVehicleName.."_cms_original_inline_gear"..AmountOfGears .. ".maxSpeed", TweakDB:GetFlat(fullVehicleName.."_cms_original_inline_gear"..(AmountOfGears-1)..".maxSpeed") * ModifierValueToSet)

			table.insert(VehicleToUse.VehicleRecords.OriginalGearBox, fullVehicleName.."_cms_original_inline_gear" .. AmountOfGears)
			
			--GearsUsed[AmountOfGears] = TweakDB:GetFlat(fullVehicleName.."_cms_inline_gear"..AmountOfGears+1)
			GearBoxToUse[AmountOfGears + 1] = fullVehicleName.."_cms_inline_gear"..(AmountOfGears)
			VehicleToUse.VehicleRecords.GearBox[AmountOfGears + 1] = fullVehicleName.."_cms_inline_gear"..(AmountOfGears)
			TweakDB:SetFlat(fullVehicleName.."_cms_enginedata.gears", GearBoxToUse)
		end
	end
end

function FindFlat(VehicleToUse, FlatTypeToFind, VariableNameToAdd)
	local FullFlat = ""
	local FullFlatTable = {}
	
	if FlatTypeToFind == "VehicleEngineData" then
		FullFlat = VehicleToUse.VehicleRecords.VehicleEngineData
	end
	
	if FlatTypeToFind == "VehicleGearData" then
		FullFlatTable = TweakDB:GetFlat(VehicleToUse.VehicleRecords.VehicleEngineData .. ".gears")
	end
	
	if FlatTypeToFind == "VehicleDriveModelData" then
		FullFlat = VehicleToUse.VehicleRecords.VehicleDriveModelData
	end
	
	if FlatTypeToFind == "VehicleDataPackage" then
		FullFlat = VehicleToUse.VehicleRecords.VehicleDataPackage
	end
		
	if FlatTypeToFind == "VehicleWheelDimensionsSetup" then
		FullFlat = VehicleToUse.VehicleRecords.VehicleWheelDimensionsSetup
	end
	
	if FlatTypeToFind == "VehicleWheelSetup" then
		FullFlat = VehicleToUse.VehicleRecords.VehicleWheelSetup
	end
	
	if FlatTypeToFind == "FrontWheelSuspension" then
		FullFlat = VehicleToUse.VehicleRecords.FrontWheelSuspension
	end
	
	if FlatTypeToFind == "RearWheelSuspension" then
		FullFlat = VehicleToUse.VehicleRecords.RearWheelSuspension
	end
	
	if FlatTypeToFind == "VehicleGearData" then
		--FullFlat = FullFlat.."."..VariableNameToAdd
		FullGearTable = {}
		local reverseOmitted = false
		local totalGears = 0
		
		for _, gearFlat in pairs(FullFlatTable) do
			--FullGearTable = gearFlat .. "." ..VariableNameToAdd
			if reverseOmitted == true then
				table.insert(FullGearTable, gearFlat .. "." ..VariableNameToAdd)
				totalGears = totalGears + 1
			end
			reverseOmitted = true
		end
		
		return FullGearTable
	else
		FullFlat = FullFlat.."."..VariableNameToAdd
		
		return FullFlat
	end
	
	return FullFlat
end

function FindOriginalFlat(VehicleToUse, FlatTypeToFind, VariableNameToAdd)
	local FullFlat = ""
	local FullFlatTable = {}
	--VehicleToUse.VehicleRecords.OriginalVehicle
	
	if FlatTypeToFind == "VehicleEngineData" then
		FullFlat = VehicleToUse.VehicleRecords.OriginalVehicleEngineData
	end
	
	if FlatTypeToFind == "VehicleGearData" then
		FullFlatTable = VehicleToUse.VehicleRecords.OriginalGearBox
	end
	
	if FlatTypeToFind == "VehicleDriveModelData" then
		FullFlat = VehicleToUse.VehicleRecords.OriginalVehicleDriveModelData
	end
	
	if FlatTypeToFind == "VehicleDataPackage" then
		FullFlat = VehicleToUse.VehicleRecords.OriginalVehicleDataPackage
	end
		
	if FlatTypeToFind == "VehicleWheelDimensionsSetup" then
		FullFlat = VehicleToUse.VehicleRecords.OriginalVehicleWheelDimensionsSetup
	end
	
	if FlatTypeToFind == "VehicleWheelSetup" then
		FullFlat = VehicleToUse.VehicleRecords.OriginalVehicleWheelSetup
	end
	
	if FlatTypeToFind == "FrontWheelSuspension" then
		FullFlat = VehicleToUse.VehicleRecords.OriginalFrontWheelSuspension
	end
	
	if FlatTypeToFind == "RearWheelSuspension" then
		FullFlat = VehicleToUse.VehicleRecords.OriginalRearWheelSuspension
	end
	
	if FlatTypeToFind == "VehicleGearData" then
		--FullFlat = FullFlat.."."..VariableNameToAdd
		FullGearTable = {}
		local reverseOmitted = false
		
		for _, gearFlat in pairs(FullFlatTable) do
			--FullGearTable = gearFlat .. "." ..VariableNameToAdd
			if reverseOmitted == true then
				table.insert(FullGearTable, gearFlat .. "." ..VariableNameToAdd)
			end
			reverseOmitted = true
		end
		
		return FullGearTable
	else
		FullFlat = FullFlat.."."..VariableNameToAdd
		
		return FullFlat
	end
	
	return FullFlat
end

function CloneCarForUpgrade(VehTweakDBIDForClone, SimpleVehicleName, VehicleNumberToUse, shouldChangeVehicleNum)

	car = {}
	
	car.TweakDBID = VehTweakDBIDForClone
	car.DisplayName = SimpleVehicleName
	car.CurrentParts = {}
	car.VehicleRecords = {}
	
	--Cloning
	car.VehicleRecords = VehicleBaseFunctions.cloneVehicleSettings(SimpleVehicleName, VehTweakDBIDForClone, true, true, true, true, true)
	
	VehicleBaseFunctions.setSupensionData(car.VehicleRecords.VehicleDriveModelData, car.VehicleRecords.VehicleWheelSetup, car.VehicleRecords.FrontWheelSuspension, car.VehicleRecords.RearWheelSuspension)
	VehicleBaseFunctions.setVehicleSettings(VehTweakDBIDForClone, car.VehicleRecords.VehicleEngineData, car.VehicleRecords.VehicleDriveModelData, car.VehicleRecords.VehicleDataPackage, car.VehicleRecords.VehicleWheelDimensionsSetup)
	
	CName.add("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "TweakCRC32Hash")
	CName.add("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "TweakLengthHash")
	
	if shouldChangeVehicleNum == true then
		Game.SetFactValue("CMS_AmountVehicleToUpgrade", VehicleNumberToUse)
	end

	Game.SetFactValue("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "TweakCRC32Hash", VehTweakDBIDForClone.hash)
	Game.SetFactValue("CMS_VehicleToUpgrade" .. VehicleNumberToUse .. "TweakLengthHash", VehTweakDBIDForClone.length)
	
	return car
end

function RemovePreviousCarClone(UpgradVEH)
	for ind, UpgradedCar in pairs(UpgradedCarList) do
		local carCloneName = "Vehicle.v_CMS_" .. UpgradedCar.TweakDBID.hash .. UpgradedCar.TweakDBID.length
		UpgradedCarList[ind] = CloneCarForUpgrade(UpgradedCar.TweakDBID, carCloneName, ind, false)
	end
end

function DeleteAllUpgradedCars()
	for _, UpgradedVEH in pairs(UpgradedCarList) do
		RemovePreviousCarClone(UpgradedVEH)
	end
end

function OnLoad(SaveFactIDTotalToAdd)

	PartBasket = {}
	CurrentVehicleListNum = -1
	DeleteAllUpgradedCars()
	UpgradedCarList = {}
	CurrentVehicle = nil
	UpgradedCarCount = 0
	CurrentPrice = 0
	
	local UpgradedCarIDs = ""
	local CountUpgradedCars = 1
	
	local OverallAmountOfUpgradedCars = Game.GetFact("CMS_AmountVehicleToUpgrade")
	--print(OverallAmountOfUpgradedCars)
	
	if OverallAmountOfUpgradedCars > 0 then
		for UpgradedCarsIndex=1, OverallAmountOfUpgradedCars do
			--print("test6")
			--print("amountOfUpgradedCars" .. UpgradedCarsIndex)

			CName.add("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "TweakCRC32Hash")
			CName.add("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "TweakLengthHash")
			CName.add("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "PartsAmount")
			
			local TDBIDcrc32 = Game.GetFact("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "TweakCRC32Hash")
			local TDBIDlength = Game.GetFact("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "TweakLengthHash")

			if TDBIDcrc32 == 0 or TweakDB:GetRecord(TweakDBID.new(TDBIDcrc32, TDBIDlength)) == nil then
				print("Car missing with ID:" .. UpgradedCarsIndex)
				print(TDBIDcrc32)
				CountUpgradedCars = CountUpgradedCars + 1
			else
						--print(TDBIDcrc32)
				local RowVehicleTweakDBID = TweakDBID.new(TDBIDcrc32, TDBIDlength)
			
				--print(TDBID.ToStringDEBUG(RowVehicleTweakDBID))
			
				local totalCarPartsNum = Game.GetFact("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "PartsAmount")
				local RowsCarPartsAdded = {}
			
				for UpgradedPartsIndex=0, totalCarPartsNum do
					CName.add("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "Part" .. UpgradedPartsIndex)
					if Game.GetFact("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "Part" .. UpgradedPartsIndex) > 0 then
						table.insert(RowsCarPartsAdded, Game.GetFact("CMS_VehicleToUpgrade" .. UpgradedCarsIndex .. "Part" .. UpgradedPartsIndex))
					end
				end
			
				--RowsCarPartsAdded = VehicleBaseFunctions.split(row.CarPartsAdded, ",")
			
				--print("rowshere")
				--print(RowsCarPartsAdded[1])
			
				local LoadingPartBasket = {}
				local LoadingPartBasketCount = 0
			
				for _, rowPart in pairs(RowsCarPartsAdded) do
					LoadingPartBasket[LoadingPartBasketCount] = tonumber(rowPart)
					LoadingPartBasketCount = LoadingPartBasketCount + 1
				end
			
				--print("got to here")
				--print(LoadingPartBasket[0])
			
				local carCloneName = "Vehicle.v_CMS_" .. RowVehicleTweakDBID.hash .. RowVehicleTweakDBID.length
		
				UpgradedCarList[CountUpgradedCars] = CloneCarForUpgrade(RowVehicleTweakDBID, carCloneName, CountUpgradedCars, false)
				--UpgradedCarList[CountUpgradedCars].loadedTweakDBID = TweakDBID.new(TDBIDcrc32, TDBIDlength)
				--print(UpgradedCarList[CountUpgradedCars].DisplayName)
				UpgradeCarFromBasket(LoadingPartBasket, UpgradedCarList[CountUpgradedCars], CountUpgradedCars)
				LoadingPartBasket = {}
			
				CountUpgradedCars = CountUpgradedCars + 1
				--print("got to the end")
				
			end

		end
		
		UpgradedCarCount = OverallAmountOfUpgradedCars
	end
		
	state.hasBeenLoaded = true
end

function roundToDecimalPlace(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function LoadAllFilesInFolder(FilesFolder)
	for _, file in pairs(dir(FilesFolder)) do
		if file.type == "file" and file.name:match("%.lua$") then
			local name = file.name:match("(.+)%..+")
			PartsRequireList[name] = require(FilesFolder .. "/" .. name)
		end
	end
	count = 0
	for _, filein in pairs(PartsRequireList) do
		count = count + 1
	end
	--print(count)
end

function MountVehicle(entID)
    --local player = Game.GetPlayer()

    local data = NewObject('handle:gameMountEventData')
    data.isInstant = true
    data.slotName = "seat_front_left"
    data.mountParentEntityId = entID
    data.entryAnimName = "forcedTransition"

    local slotID = NewObject('gamemountingMountingSlotId')
    slotID.id = "seat_front_left"

    local mountingInfo = NewObject('gamemountingMountingInfo')
    mountingInfo.childId = Game.GetPlayer():GetEntityID()
    mountingInfo.parentId = entID
    mountingInfo.slotId = slotID

    local mountEvent = NewObject('handle:gamemountingMountingRequest')
    mountEvent.lowLevelMountingInfo = mountingInfo
    mountEvent.mountData = data

    Game.GetMountingFacility():Mount(mountEvent)
end

function UnMountVehicle()
    local event = gamemountingUnmountingRequest.new()
    local info = gamemountingMountingInfo.new()
    info.childId = Game.GetPlayer():GetEntityID()
    event.lowLevelMountingInfo = info
    event.mountData = gameMountEventData.new()
    event.mountData.isInstant = true
    event.mountData.removePitchRollRotationOnDismount = true
    Game.GetMountingFacility():Unmount(event)
end

function CheckCarPosition(CurrentPosition)
	if (CurrentPosition.y > 2965 and CurrentPosition.y < 2977) 
		and (CurrentPosition.x < -770 and CurrentPosition.x > -780) then
		return true
	else
		return false
	end
end

local TotalsArray = nil

function ShowUpgradeTotals()
	--Totals Figures:
	
	--Creation system
	if TotalsArray == nil then
		TotalsArray = {}
		
		local totalTorqueText = inkText.new()
		CName.add("totalTorqueText")
		totalTorqueText:SetName('totalTorqueText')
		table.insert(TotalsArray, totalTorqueText)
		totalTorqueText:SetMargin(inkMargin.new({ left = 692.5, top = 960 }))
		
		local totalGearsText = inkText.new()
		CName.add("totalGearsText")
		totalGearsText:SetName('totalGearsText')
		table.insert(TotalsArray, totalGearsText)
		totalGearsText:SetMargin(inkMargin.new({ left = 692.5, top = 1000 }))
		
		local totalHeightText = inkText.new()
		CName.add("totalHeightText")
		totalHeightText:SetName('totalHeightText')
		table.insert(TotalsArray, totalHeightText)
		totalHeightText:SetMargin(inkMargin.new({ left = 982.5, top = 960 }))
		
		local totalWeightText = inkText.new()
		CName.add("totalWeightText")
		totalWeightText:SetName('totalWeightText')
		table.insert(TotalsArray, totalWeightText)
		totalWeightText:SetMargin(inkMargin.new({ left = 982.5, top = 1000 }))
		
		local totalTractionText = inkText.new()
		CName.add("totalTractionText")
		totalTractionText:SetName('totalTractionText')
		table.insert(TotalsArray, totalTractionText)
		totalTractionText:SetMargin(inkMargin.new({ left = 1272.5, top = 960 }))
		
		local totalBrakePowerText = inkText.new()
		CName.add("totalBrakePowerText")
		totalBrakePowerText:SetName('totalBrakePowerText')
		table.insert(TotalsArray, totalBrakePowerText)
		totalBrakePowerText:SetMargin(inkMargin.new({ left = 1272.5, top = 1000 }))
		
		local totalPriceText = inkText.new()
		CName.add("totalPriceText")
		totalPriceText:SetName('totalPriceText')
		table.insert(TotalsArray, totalPriceText)
		totalPriceText:SetMargin(inkMargin.new({ left = 1640, top = 20 }))
	end
	
	if TextCanvasTotalBaseElementBase ~= nil and uiAreaElement ~= nil then
		TextCanvasTotalBaseElementBase:Reparent(uiAreaElement, -1)
	end
	
	if TotalsArray ~= nil then
		for _, totalsElement in pairs(TotalsArray) do
		
			--Torque:
			if totalsElement:GetName() == CName.new('totalTorqueText') then
				
				local totalTorqueText = totalsElement
				
				local basetotalTorqueText = lang.getText("basetotalTorqueText")
				local totalVehicleTorque = 0
				local calculateTotalVehicleTorque = 0
				if CurrentVehicle ~= nil then
					VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()

					EngineTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehEngineData")
					totalVehicleTorque = TweakDB:GetFlat(EngineTDB .. ".engineMaxTorque")

					local carCloneName = "Vehicle.v_CMS_" .. VehicleTweakDBRecordName.hash .. VehicleTweakDBRecordName.length .. "_cms_original"
					EngineTDBOriginal = TweakDB:GetFlat(carCloneName .. ".vehEngineData")
					if EngineTDBOriginal == nil then
						EngineTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehEngineData")
					end

					originalVehicleTorque = TweakDB:GetFlat(EngineTDBOriginal .. ".engineMaxTorque")

					calculateTotalVehicleTorque = totalVehicleTorque
				end
				local totalTorqueBasketMult = 1.0
				local totalTorqueBasketMultAddition = 0
				local totalTorqueBasketAddition = 0
						
				for _, basketItem in pairs(PartBasket) do
					for index2, basketModifier in pairs(PartsList[basketItem].SubModifiers) do
						if basketModifier.VariableName == "engineMaxTorque" then
							calculateTotalVehicleTorque = CalculateTotalAddon(totalVehicleTorque, originalVehicleTorque, calculateTotalVehicleTorque, basketModifier.ModifierType, basketModifier.ModifierValue)
						end
					end
				end
				
				--totalTorqueText:SetText(basetotalTorqueText .. tostring(roundToDecimalPlace(((totalVehicleTorque + totalTorqueBasketAddition) + totalTorqueBasketMultAddition), 2)))
				totalTorqueText:SetText(basetotalTorqueText .. tostring(roundToDecimalPlace(calculateTotalVehicleTorque, 2)))
			
			--Gears:
			elseif totalsElement:GetName() == CName.new('totalGearsText') then
			
				local totalGearsText = totalsElement
				TotalGears = -1
				
				if CurrentVehicle ~= nil then
					VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()
					EngineTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehEngineData")
					allVehGears = TweakDB:GetFlat(EngineTDB .. ".gears")
					
					for _, vehGear in pairs(allVehGears) do
						TotalGears = TotalGears + 1
					end
					
					for _, basketItem in pairs(PartBasket) do
						for index2, basketModifier in pairs(PartsList[basketItem].SubModifiers) do
							if basketModifier.ModifierType == "AddGear" then
								if TotalGears < 7 then 
									TotalGears = TotalGears + 1
								end
							end
						end
					end
				end

				local basetotalGearsText = lang.getText("basetotalGearsText")
				
				totalGearsText:SetText(basetotalGearsText .. tostring(TotalGears))
			
			--Height:
			elseif totalsElement:GetName() == CName.new('totalHeightText') then
			
				local totalHeightText = totalsElement
				
				local basetotalHeightText = lang.getText("basetotalHeightText")
				local calculateTotalVehicleHeight = 0
				
				if CurrentVehicle ~= nil then
					VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()
					local carCloneName = "Vehicle.v_CMS_" .. VehicleTweakDBRecordName.hash .. VehicleTweakDBRecordName.length .. "_cms_original"

					local isBike = false
					if TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData") ~= TweakDBID.new() then
						isBike = true
					end

					DriveModelTDBOriginal = TweakDB:GetFlat(carCloneName .. ".vehDriveModelData")
					if DriveModelTDBOriginal == nil then
						DriveModelTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehDriveModelData")
					end

					if isBike == true then
						DriveModelTDBOriginal = TweakDB:GetFlat(carCloneName .. ".bikeDriveModelData")
						if DriveModelTDBOriginal == nil then
							DriveModelTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData")
						end
					end

					OriginalWheelData = TweakDB:GetFlat(DriveModelTDBOriginal .. ".wheelSetup")
					OriginalBackWheelSetup = TweakDB:GetFlat(OriginalWheelData .. ".backPreset")
					OriginalRearHeight = TweakDB:GetFlat(OriginalBackWheelSetup .. ".wheelsVerticalOffset")


					DriveModelTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehDriveModelData")
					if isBike == true then
						DriveModelTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData")
					end
					WheelData = TweakDB:GetFlat(DriveModelTDB .. ".wheelSetup")
					BackWheelSetup = TweakDB:GetFlat(WheelData .. ".backPreset")
					RearHeight = TweakDB:GetFlat(BackWheelSetup .. ".wheelsVerticalOffset")
					
					if RearHeight ~= nil then
						calculateTotalVehicleHeight = RearHeight
					end
					
					local totalBasketMult = 1.0
					local totalBasketAddition = 0
					
					for _, basketItem in pairs(PartBasket) do
						for index2, basketModifier in pairs(PartsList[basketItem].SubModifiers) do
							if basketModifier.VariableName == "wheelsVerticalOffset" then
								calculateTotalVehicleHeight = CalculateTotalAddon(RearHeight, OriginalRearHeight, calculateTotalVehicleHeight, basketModifier.ModifierType, basketModifier.ModifierValue)
							end
						end
					end
				end
				
				totalHeightText:SetText(basetotalHeightText .. roundToDecimalPlace(calculateTotalVehicleHeight, 2))
			
			--Weight:
			elseif totalsElement:GetName() == CName.new('totalWeightText') then
			
				local totalWeightText = totalsElement
				
				local basetotalWeightText = lang.getText("basetotalWeightText")
				
				local calculateTotalVehicleWeight = 0
				
				if CurrentVehicle ~= nil then
					VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()
					local carCloneName = "Vehicle.v_CMS_" .. VehicleTweakDBRecordName.hash .. VehicleTweakDBRecordName.length .. "_cms_original"

					local isBike = false
					if TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData") ~= TweakDBID.new() then
						isBike = true
					end

					DriveModelTDBOriginal = TweakDB:GetFlat(carCloneName .. ".vehDriveModelData")
					if DriveModelTDBOriginal == nil then
						DriveModelTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehDriveModelData")
					end

					if isBike == true then
						DriveModelTDBOriginal = TweakDB:GetFlat(carCloneName .. ".bikeDriveModelData")
						if DriveModelTDBOriginal == nil then
							DriveModelTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData")
						end
					end

					OriginalWeightTotal = TweakDB:GetFlat(DriveModelTDBOriginal .. ".total_mass")

					DriveModelTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehDriveModelData")
					if isBike == true then
						DriveModelTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData")
					end
					WeightTotal = TweakDB:GetFlat(DriveModelTDB .. ".total_mass")
					
					calculateTotalVehicleWeight = WeightTotal
					
					local totalBasketMult = 1.0
					local totalBasketAddition = 0
					
					for _, basketItem in pairs(PartBasket) do
						for index2, basketModifier in pairs(PartsList[basketItem].SubModifiers) do
							if basketModifier.VariableName == "total_mass" then
								calculateTotalVehicleWeight = CalculateTotalAddon(WeightTotal, OriginalWeightTotal, calculateTotalVehicleWeight, basketModifier.ModifierType, basketModifier.ModifierValue)
							end
						end
					end
				end
				
				totalWeightText:SetText(basetotalWeightText .. roundToDecimalPlace(calculateTotalVehicleWeight, 2))
			
			--Traction:
			elseif totalsElement:GetName() == CName.new('totalTractionText') then
			
				local totalTractionText = totalsElement
				
				local basetotalTractionText = lang.getText("basetotalTractionText")
				local calculateTotalVehicleTraction = 1.00
				
				if CurrentVehicle ~= nil then
					VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()
					local carCloneName = "Vehicle.v_CMS_" .. VehicleTweakDBRecordName.hash .. VehicleTweakDBRecordName.length .. "_cms_original"

					local isBike = false
					if TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData") ~= TweakDBID.new() then
						isBike = true
					end

					DriveModelTDBOriginal = TweakDB:GetFlat(carCloneName .. ".vehDriveModelData")
					if DriveModelTDBOriginal == nil then
						DriveModelTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehDriveModelData")
					end

					if isBike == true then
						DriveModelTDBOriginal = TweakDB:GetFlat(carCloneName .. ".bikeDriveModelData")
						if DriveModelTDBOriginal == nil then
							DriveModelTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData")
						end
					end

					OriginalWheelData = TweakDB:GetFlat(DriveModelTDBOriginal .. ".wheelSetup")
					OriginalBackWheelSetup = TweakDB:GetFlat(OriginalWheelData .. ".backPreset")
					OriginalRearFriction = TweakDB:GetFlat(OriginalBackWheelSetup .. ".frictionMulLongitudinal")

					DriveModelTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehDriveModelData")
					if isBike == true then
						DriveModelTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData")
					end
					WheelData = TweakDB:GetFlat(DriveModelTDB .. ".wheelSetup")
					BackWheelSetup = TweakDB:GetFlat(WheelData .. ".backPreset")
					RearFriction = TweakDB:GetFlat(BackWheelSetup .. ".frictionMulLongitudinal")
					
					calculateTotalVehicleTraction = RearFriction
					
					local totalBasketMult = 1.0
					local totalBasketAddition = 0
					
					for _, basketItem in pairs(PartBasket) do
						for index2, basketModifier in pairs(PartsList[basketItem].SubModifiers) do
							if basketModifier.VariableName == "frictionMulLongitudinal" and basketModifier.RecordType == "RearWheelSuspension" then
								calculateTotalVehicleTraction = CalculateTotalAddon(RearFriction, OriginalRearFriction, calculateTotalVehicleTraction, basketModifier.ModifierType, basketModifier.ModifierValue)
							end
						end
					end
				end
				
				totalTractionText:SetText(basetotalTractionText .. roundToDecimalPlace(calculateTotalVehicleTraction, 2))
			
			--Brakes:
			elseif totalsElement:GetName() == CName.new('totalBrakePowerText') then
			
				local totalBrakePowerText = totalsElement
				
				local basetotalBrakePowerText = lang.getText("basetotalBrakePowerText")
				local calculateTotalVehicleBrakeTorque = 1
				
				if CurrentVehicle ~= nil then
					VehicleTweakDBRecordName = CurrentVehicle:GetRecordID()
					local carCloneName = "Vehicle.v_CMS_" .. VehicleTweakDBRecordName.hash .. VehicleTweakDBRecordName.length .. "_cms_original"

					local isBike = false
					if TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData") ~= TweakDBID.new() then
						isBike = true
					end

					DriveModelTDBOriginal = TweakDB:GetFlat(carCloneName .. ".vehDriveModelData")
					if DriveModelTDBOriginal == nil then
						DriveModelTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehDriveModelData")
					end

					if isBike == true then
						DriveModelTDBOriginal = TweakDB:GetFlat(carCloneName .. ".bikeDriveModelData")
						if DriveModelTDBOriginal == nil then
							DriveModelTDBOriginal = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData")
						end
					end

					OriginalWheelData = TweakDB:GetFlat(DriveModelTDBOriginal .. ".wheelSetup")
					OriginalBackWheelSetup = TweakDB:GetFlat(OriginalWheelData .. ".backPreset")
					OriginalRearBrakeTorque = TweakDB:GetFlat(OriginalBackWheelSetup .. ".maxBrakingTorque")

					DriveModelTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".vehDriveModelData")
					if isBike == true then
						DriveModelTDB = TweakDB:GetFlat(VehicleTweakDBRecordName .. ".bikeDriveModelData")
					end
					WheelData = TweakDB:GetFlat(DriveModelTDB .. ".wheelSetup")
					BackWheelSetup = TweakDB:GetFlat(WheelData .. ".backPreset")
					RearBrakeTorque = TweakDB:GetFlat(BackWheelSetup .. ".maxBrakingTorque")
					
					calculateTotalVehicleBrakeTorque = RearBrakeTorque
					
					local totalBasketMult = 1.0
					local totalBasketAddition = 0
					
					for _, basketItem in pairs(PartBasket) do
						for index2, basketModifier in pairs(PartsList[basketItem].SubModifiers) do
							if basketModifier.VariableName == "maxBrakingTorque" and basketModifier.RecordType == "RearWheelSuspension" then
								calculateTotalVehicleBrakeTorque = CalculateTotalAddon(RearBrakeTorque, OriginalRearBrakeTorque, calculateTotalVehicleBrakeTorque, basketModifier.ModifierType, basketModifier.ModifierValue)
							end
						end
					end
				end
				
				totalBrakePowerText:SetText(basetotalBrakePowerText .. roundToDecimalPlace(calculateTotalVehicleBrakeTorque,2))

			--Total Price:
			elseif totalsElement:GetName() == CName.new('totalPriceText') then

				local totalPriceText = totalsElement
				
				local basetotalPriceText = lang.getText("basetotalPriceText")
				local totalBasketPrice = 0
				
				for _, basketItem in pairs(PartBasket) do
					totalBasketPrice = totalBasketPrice + PartsList[basketItem].Price
				end
				CurrentPrice = totalBasketPrice
				
				totalPriceText:SetText(basetotalPriceText .. totalBasketPrice)
				
				totalPriceText:SetTintColor(HDRColor.new({ Red = 1.0, Green = 0.84, Blue = 0.0, Alpha = 1.0 }))
			end
		end
		
		for _, totalsText in pairs(TotalsArray) do
			totalsText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
			totalsText:SetFontStyle('Medium')
			totalsText:SetFontSize(37)
			--totalsText:SetTintColor(HDRColor.new({ Red = 0.813725, Green = 0.829412, Blue = 0.813726, Alpha = 1.0 }))
			totalsText:SetHorizontalAlignment(textHorizontalAlignment.Center)
			totalsText:SetVerticalAlignment(textVerticalAlignment.Center)
			if TextCanvasTotalBaseElementBase ~= nil then
				totalsText:Reparent(TextCanvasTotalBaseElementBase, -1)
			end
			
			if totalsText:GetName() == CName.new('totalPriceText') then
				totalsText:SetMargin(inkMargin.new({ left = 550.0, top = 33.0 }))
				totalsText:Reparent(basketBox, -1)
			end
		end
	end
end

function CalculateTotalAddon(currentTweakValue, OriginalValue, CalculatedTotal, ModifierType, ModifierValue)
	if ModifierType == "Mult" then
		local ValueToSet = CalculatedTotal + ((OriginalValue * ModifierValue) - OriginalValue)
		CalculatedTotal = ValueToSet
	elseif ModifierType == "Add" then
		CalculatedTotal = CalculatedTotal + ModifierValue
	end
	return CalculatedTotal
end


local itemNameText = nil
local descriptionText = nil
local itemTweakValueText = nil

function CreateDescriptionBox(uiArea)
	local baseDescriptionBox = GameShardUI.createBox("CannotUpgradeBox", true)
	baseDescriptionBox:SetSize(900.0, 200.0)
	baseDescriptionBox:SetMargin(inkMargin.new({ left = 380.0, top = 990.0 }))
	baseDescriptionBox:Reparent(uiArea, -1)
	
	itemNameText = inkText.new()
	itemNameText:SetName('itemNameText')
	itemNameText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
	itemNameText:SetFontStyle('Medium')
	itemNameText:SetFontSize(37)
	itemNameText:SetTintColor(HDRColor.new({ Red = 0.113725, Green = 0.929412, Blue = 0.513726, Alpha = 1.0 }))
	itemNameText:SetHorizontalAlignment(textHorizontalAlignment.Center)
	itemNameText:SetVerticalAlignment(textVerticalAlignment.Center)
	itemNameText:SetMargin(inkMargin.new({ left = 50.5, top = 30.0 }))
	itemNameText:SetText("-")
	itemNameText:Reparent(baseDescriptionBox, -1)
	
	descriptionText = inkText.new()
	descriptionText:SetName('descriptionText')
	descriptionText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
	descriptionText:SetFontStyle('Medium')
	descriptionText:SetFontSize(37)
	descriptionText:SetTintColor(HDRColor.new({ Red = 0.113725, Green = 0.929412, Blue = 0.513726, Alpha = 1.0 }))
	descriptionText:SetHorizontalAlignment(textHorizontalAlignment.Center)
	descriptionText:SetVerticalAlignment(textVerticalAlignment.Center)
	descriptionText:SetMargin(inkMargin.new({ left = 50.5, top = 80.0 }))
	descriptionText:SetText("-")
	descriptionText:Reparent(baseDescriptionBox, -1)
	
	itemTweakValueText = inkText.new()
	itemTweakValueText:SetName('itemTweakValueText')
	itemTweakValueText:SetFontFamily('base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily')
	itemTweakValueText:SetFontStyle('Medium')
	itemTweakValueText:SetFontSize(37)
	itemTweakValueText:SetTintColor(HDRColor.new({ Red = 0.113725, Green = 0.929412, Blue = 0.513726, Alpha = 1.0 }))
	itemTweakValueText:SetHorizontalAlignment(textHorizontalAlignment.Center)
	itemTweakValueText:SetVerticalAlignment(textVerticalAlignment.Center)
	itemTweakValueText:SetMargin(inkMargin.new({ left = 50.5, top = 130.0 }))
	itemTweakValueText:SetText("-")
	itemTweakValueText:Reparent(baseDescriptionBox, -1)
end

function UpdateDescription(itemName, itemDesc, itemTweakValue)
	itemNameText:SetText(itemName)
	descriptionText:SetText(itemDesc)
	itemTweakValueText:SetText(itemTweakValue)
end

function AddToMapPinDB(tweakDBToGet, MappinToAdd)
	local MapPinDB = TweakDB:GetFlat(tweakDBToGet)
	local ShouldAddToMapDB = true
	for _, MapPinDBEntry in pairs(MapPinDB) do 
		if MapPinDBEntry == TweakDBID.new(MappinToAdd) then
			ShouldAddToMapDB = false
		end
	end
	
	if ShouldAddToMapDB == true then
		table.insert(MapPinDB, TweakDBID.new(MappinToAdd))
	end
	
	TweakDB:SetFlat(tweakDBToGet, MapPinDB)
end

function ShowMapPin()
	local pos = Vector4.new(-773.45, 2968.5, 26.5, 1.0)
	
	-- You may be asking yourself, why am I adding this to every possible map filter?
	-- Well of course its simple, people who download mods tend to not read absolutely anything
	-- Nor do the understand very very simple things, thus I am adding it to all filters
	
	--local pos = Game.GetPlayer():GetWorldPosition()
	--Drop Point Filter Group
	AddToMapPinDB("WorldMap.DropPointFilterGroup.mappins", 'Mappins.PointOfInterest_ServicePointTechVariant')
	AddToMapPinDB("Mappins.DropPointDynamicMappin.possibleVariants", 'Mappins.PointOfInterest_ServicePointTechVariant')
	AddToMapPinDB("Mappins.DropPointStaticMappin.possibleVariants", 'Mappins.PointOfInterest_ServicePointTechVariant')
	AddToMapPinDB("WorldMap.JobsFilterGroup.mappins", 'Mappins.PointOfInterest_ServicePointTechVariant')
	AddToMapPinDB("WorldMap.AllServicePointsFilterGroup.mappins", 'Mappins.PointOfInterest_ServicePointTechVariant')
	
	--Mappins.DropPointDynamicMappin.possibleVariants
	--Mappins.DropPointStaticMappin.possibleVariants
		
	--local mappinData = gamemappinsMappinData.new()
	local mappinData = MappinData.new()
	mappinData.mappinType = TweakDBID.new('Mappins.DefaultStaticMappin')
	mappinData.variant = gamedataMappinVariant.ServicePointTechVariant
	--mappinData.variant = gamedataMappinVariant.FastTravelVariant
	--mappinData.caption = "Welp this does not work haha"
	

	mappinData.visibleThroughWalls = true
	--local mapPinID = Game.GetMappinSystem():RegisterMappin(mappinData, pos)
	
	Game.GetMappinSystem():RegisterMappin(mappinData, pos)
	
	mappinData.mappinType = TweakDBID.new('Mappins.DropPointDynamicMappin')
	Game.GetMappinSystem():RegisterMappin(mappinData, pos)
	
	mappinData.mappinType = TweakDBID.new('Mappins.DropPointStaticMappin')
	Game.GetMappinSystem():RegisterMappin(mappinData, pos)

	--https://nativedb.red4ext.com/gamedataMappinVariant
end

local lastFoundPin = nil

function RenameMapPin()
	
	Observe("WorldMapTooltipBaseController", "Show", function (self)
		if IsDefined(self) then
			if self.titleText:GetText() == "Techie" then -- Check if its the custom pin with the techie or smth like that titel
				self.titleText:SetText(lang.getText("mapTitleText"))
				self.descText:SetText(lang.getText("mapDescText"))
				lastFoundPin = self
			end
		end
	end)
	
	Observe("WorldMapTooltipBaseController", "Hide", function (self)
		if lastFoundPin ~= nil then
			--if IsDefined(lastFoundPin) then
				lastFoundPin = nil
			--end
		end
	end)
	
	Observe("WorldMapTooltipBaseController", "HideInstant", function (self)
		if lastFoundPin ~= nil then
			--if IsDefined(lastFoundPin) then
				--if IsDefined(lastFoundPin.titleText) then
					lastFoundPin = nil
				--end
			--end
		end
	end)
	
	Observe("WorldMapMenuGameController", "PlaySound", function (self)
		if lastFoundPin ~= nil then
			if IsDefined(lastFoundPin) then
				if lastFoundPin.titleText:GetText() == "Techie" then -- Check if its the custom pin with the techie or smth like that titel
					lastFoundPin.titleText:SetText(lang.getText("mapTitleText"))
					lastFoundPin.descText:SetText(lang.getText("mapDescText"))
				end
			end
		end
	end)
end

function AccountBalanceUpdate(amount)
	Game.GetTransactionSystem():GiveItem(player, ItemID.new(TweakDBID.new('Items.money')), -amount)
end

function DoesPlayerHaveEnoughMoney(AmountNeeded)
	currentBalance = PlayerAccountBalance()
	if (currentBalance > AmountNeeded) then
		return true
	else
		return false
	end
end

function PlayerAccountBalance()
	return Game.GetTransactionSystem():GetItemQuantity(player, ItemID.new(TweakDBID.new('Items.money')))
end