-- local ink = require("modules/utils/inkHelper")
-- local utils = require("modules/utils/utils")

-- preview = {}

-- function preview:new()
-- 	local o = {}

--     o.x = 0
--     o.y = 0
--     o.sizeX = 380
--     o.sizeY = 100
--     o.textSize = 55

--     o.fgColor = nil
--     o.bgColor = nil

--     o.bg = nil
--     o.fill = nil
--     o.canvas = nil

--     o.stock = nil
--     o.stockIcon = nil
--     o.stockPrice = nil
--     o.stockTrend = nil

-- 	self.__index = self
--    	return setmetatable(o, self)
-- end

-- function preview:initialize()
--     local atlas = "base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas"

--     self.canvas = ink.canvas(self.x, self.y, inkEAnchor.Centered)
--     self.canvas:SetInteractive(true)

--     self.fg = ink.image(0, 0, self.sizeX, self.sizeY, atlas, "tooltip_map_fg")
--     self.fg.pos:SetInteractive(true)
--     self.fg.image.useNineSliceScale = true
--     self.fg.image:SetTintColor(self.fgColor or color.white)
--     self.fg.pos:Reparent(self.canvas, -1)

--     self.bg = ink.image(0, 0, self.sizeX, self.sizeY, atlas, "tooltip_map_bg")
--     self.bg.pos:SetInteractive(true)
--     self.bg.image.useNineSliceScale = true
--     self.bg.image:SetTintColor(self.bgColor or color.gray)
--     self.bg.image:SetOpacity(0)
--     self.bg.pos:Reparent(self.canvas, -1)

--     self.stockIcon = ink.image(-self.sizeX / 4, 0, 0, 0, "", "")
--     self.stockIcon.pos:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
--     self.stockIcon.pos:Reparent(self.canvas, -1)

--     self.stockPrice = ink.text("", self.sizeX / 8, 0, math.floor(self.textSize * 0.9), self.textColor)
--     self.stockPrice:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
--     self.stockPrice:Reparent(self.canvas, -1)

--     self.stockTrend = ink.text("", self.sizeX / 4 + (self.sizeX / 8), 0, self.textSize, self.textColor)
--     self.stockTrend:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
--     self.stockTrend:Reparent(self.canvas, -1)
-- end

-- function preview:showData()
--     if self.stock then
--         self.stockIcon.image:SetAtlasResource(ResRef.FromString(self.stock.atlasPath))
--         self.stockIcon.image:SetTexturePart(self.stock.atlasPart)
--         self.stockIcon.pos:SetSize(self.stock.iconX * 0.4, self.stock.iconY * 0.4)
--         self.stockIcon.image:SetTintColor(HDRColor.new({ Red = 0.9, Green = 0.9, Blue = 0.9, Alpha = 1.0 }))
--     end

--     local currentPrice = math.random(30, 500)
--     if self.stock then currentPrice = self.stock:getCurrentPrice() end
--     self.stockPrice:SetText(tostring(math.floor(currentPrice) .. "E$"))

--     local trend = math.random(-200, 200) / 10
--     if self.stock then trend = self.stock:getTrend() end
--     local c = color.red
--     if trend > 0 then
--         c = color.lime
--         trend = tostring("+" .. trend)
--     end

--     self.stockTrend:SetText(tostring(trend .. "%"))
--     self.stockTrend:SetTintColor(c)

--     if not self.stock then
--         self.stockTrend:SetMargin(inkMargin.new({ left = 75, top = 0, right = 0.0, bottom = 0.0 }))
--         self.stockPrice:SetMargin(inkMargin.new({ left = -75, top = 0, right = 0.0, bottom = 0.0 }))
--     end
-- end

-- return preview

local ink = require("modules/utils/inkHelper")
local utils = require("modules/utils/utils")

preview = {}

function preview:new(x, y, borderSize, text, textSize, inactiveColor, activeColor)
	local o = {}

    o.x = x
    o.y = y
    o.sizeX = 300
    o.sizeY = 80
    o.borderSize = borderSize
    o.text = text
    o.textSize = textSize
    o.inactiveColor = inactiveColor
    o.activeColor = activeColor

    o.bg = nil
    o.fill = nil
    o.textWidget = nil
    o.canvas = nil

    o.stock = nil
    o.stockIcon = nil
    o.stockPrice = nil
    o.stockTrend = nil

	self.__index = self
   	return setmetatable(o, self)
end

function preview:initialize()
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

    self.stockIcon = ink.image(self.sizeX * 0.28, self.sizeY / 2, 0, 0, "", "")
    self.stockIcon.pos:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockIcon.pos:Reparent(self.canvas, -1)

    self.stockPrice = ink.text("", self.sizeX * 0.28, self.sizeY / 2, math.floor(self.textSize * 0.9), self.textColor)
    self.stockPrice:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockPrice:Reparent(self.canvas, -1)

    self.stockTrend = ink.text("", self.sizeX * 0.75, self.sizeY / 2, self.textSize, self.textColor)
    self.stockTrend:SetAnchorPoint(Vector2.new({X = 0.5, Y = 0.5}))
    self.stockTrend:Reparent(self.canvas, -1)
end

function preview:showData()
    if self.stock then
        self.stockIcon.image:SetAtlasResource(ResRef.FromString(self.stock.atlasPath))
        self.stockIcon.image:SetTexturePart(self.stock.atlasPart)
        self.stockIcon.pos:SetSize(self.stock.iconX * 0.35, self.stock.iconY * 0.35)
        self.stockIcon.image:SetTintColor(HDRColor.new({ Red = 0.9, Green = 0.9, Blue = 0.9, Alpha = 1.0 }))
    end

    local currentPrice = math.random(30, 500)
    if self.stock then currentPrice = self.stock:getCurrentPrice() end
    self.stockPrice:SetText(tostring(math.floor(currentPrice) .. "E$"))

    local trend = math.random(-200, 200) / 10
    if self.stock then trend = self.stock:getTrend() end
    local c = color.red
    if trend > 0 then
        c = color.lime
        trend = tostring("+" .. trend)
    end

    self.stockTrend:SetText(tostring(trend .. "%"))
    self.stockTrend:SetTintColor(c)

    if self.stock then
        self.stockPrice:SetVisible(false)
    end
end

return preview