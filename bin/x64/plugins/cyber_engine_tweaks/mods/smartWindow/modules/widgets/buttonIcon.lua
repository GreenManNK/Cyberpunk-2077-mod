local ink = require("modules/utils/inkHelper")
local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")

button = {}

function button:new(x, y, sizeX, sizeY, borderSize, text, textSize, inactiveColor, activeColor, callback)
	local o = {}

    o.x = x
    o.y = y
    o.sizeX = sizeX
    o.sizeY = sizeY
    o.borderSize = borderSize
    o.text = text
    o.textSize = textSize
    o.inactiveColor = inactiveColor
    o.activeColor = activeColor

    o.callback = callback
    o.eventCatcher = nil
    o.cooldown = false

    o.bg = nil
    o.fill = nil
    o.textWidget = nil
    o.canvas = nil

    o.atlas = ""

	self.__index = self
   	return setmetatable(o, self)
end

function button:initialize()
    self.canvas = ink.canvas(self.x, self.y, inkEAnchor.Centered)
    self.canvas:SetInteractive(true)

    self.fill = ink.rect(0, 0, self.sizeX, self.sizeY, color.new(0, 0, 0, 0), 0, Vector2.new({X = 0, Y = 0}))
    self.fill:Reparent(self.canvas, -1)
    self.fill:SetOpacity(0.0001) -- huh
    self.fill:SetInteractive(true)

    self.top = ink.rect(0, 0, self.sizeX, self.borderSize, self.inactiveColor, 0, Vector2.new({X = 0, Y = 0}))
    self.top:Reparent(self.canvas, -1)
    self.left = ink.rect(0, 0, self.borderSize, self.sizeY, self.inactiveColor, 0, Vector2.new({X = 0, Y = 0}))
    self.left:Reparent(self.canvas, -1)
    self.right = ink.rect(self.sizeX, 0, self.borderSize, self.sizeY, self.inactiveColor, 0, Vector2.new({X = 1, Y = 0}))
    self.right:Reparent(self.canvas, -1)
    self.bottom = ink.rect(0, self.sizeY, self.sizeX, self.borderSize, self.inactiveColor, 0, Vector2.new({X = 0, Y = 1}))
    self.bottom:Reparent(self.canvas, -1)

    local yPos = self.sizeY * 0.5
    if self.atlas ~= "" then yPos = 0.35 * self.sizeY end
    self.textWidget = ink.text(self.text, self.sizeX / 2, yPos, self.textSize, self.inactiveColor)
    self.textWidget:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.textWidget:SetLetterCase(textLetterCase.UpperCase)
    self.textWidget:Reparent(self.canvas, -1)

    self.icon = ink.image(self.sizeX / 2, self.sizeY * 0.65, 150, 150, self.atlas, "stock")
    self.icon.pos:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.icon.image:SetTintColor(self.inactiveColor)
    self.icon.pos:Reparent(self.canvas, -1)
end

function button:registerCallbacks(catcher)
    self.eventCatcher = sampleStyleManagerGameController.new()

	self.fill:RegisterToCallback('OnPress', self.eventCatcher, 'OnState1')
	self.fill:RegisterToCallback('OnEnter', self.eventCatcher, 'OnStyle1')
	self.fill:RegisterToCallback('OnLeave', self.eventCatcher, 'OnStyle2')

    table.insert(catcher.subscribers, self)
end

function button:hoverInCallback()
    self.top:SetTintColor(self.activeColor)
    self.left:SetTintColor(self.activeColor)
    self.right:SetTintColor(self.activeColor)
    self.bottom:SetTintColor(self.activeColor)
    self.textWidget:SetTintColor(self.activeColor)
    self.icon.image:SetTintColor(self.activeColor)
end

function button:hoverOutCallback()
    self.top:SetTintColor(self.inactiveColor)
    self.left:SetTintColor(self.inactiveColor)
    self.right:SetTintColor(self.inactiveColor)
    self.bottom:SetTintColor(self.inactiveColor)
    self.textWidget:SetTintColor(self.inactiveColor)
    self.icon.image:SetTintColor(self.inactiveColor)
end

function button:clickCallback()
    if not self.callback or self.cooldown then return end
    self.cooldown = true
    Cron.NextTick(function()
        self.cooldown = false
    end)
    utils.playSound("ui_menu_onpress", 1)
    self.callback()
end

return button