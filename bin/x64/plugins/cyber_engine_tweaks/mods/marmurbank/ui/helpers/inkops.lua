local inkops = {}
local Lang = require("external/Lang")

local activeFontScale = 1.10

function inkops.setFontScale(scale)
    local value = tonumber(scale) or 1.10
    if value < 0.75 then value = 0.75 end
    if value > 1.50 then value = 1.50 end
    activeFontScale = value
end

function inkops.getFontScale()
    return activeFontScale
end

function inkops.resolveFontSize(fontSize)
    local requested = tonumber(fontSize) or 32
    return math.max(1, math.floor((requested * activeFontScale) + 0.5))
end

local function applyMargin(widget, x, y)
    widget:SetMargin(inkMargin.new({ left = x or 0, top = y or 0, right = 0, bottom = 0 }))
end

function inkops.translate(content)
    return Lang.translate(content)
end

function inkops.canvas(x, y, anchor)
    local cv = inkCanvas.new()
    cv:SetAnchor(anchor or inkEAnchor.TopLeft)
    applyMargin(cv, x, y)
    return cv
end

function inkops.text(content, x, y, fontSize, tint, casing, fontStyle)
    local widget = inkText.new()
    local family = Lang.getFontFamily()
    local familyOk = pcall(function() widget:SetFontFamily(family) end)
    if not familyOk then
        widget:SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily")
    end
    local style = fontStyle or Lang.getFontStyle() or "Regular"
    local ok = pcall(function() widget:SetFontStyle(style) end)
    if not ok then ok = pcall(function() widget:SetFontStyle("Regular") end) end
    if not ok then pcall(function() widget:SetFontStyle("Medium") end) end
    widget:SetFontSize(inkops.resolveFontSize(fontSize))
    widget:SetLetterCase(casing or textLetterCase.OriginalCase)
    widget:SetTintColor(tint or HDRColor.new({ Red=1, Green=1, Blue=1, Alpha=1 }))
    widget:SetAnchor(inkEAnchor.TopLeft)
    widget:SetText(Lang.translate(content or ""))
    widget:SetVisible(true)
    applyMargin(widget, x, y)
    return widget
end

function inkops.rect(x, y, w, h, tint)
    local r = inkRectangle.new()
    r:SetSize(w or 10, h or 10)
    r:SetTintColor(tint or HDRColor.new({ Red=1, Green=1, Blue=1, Alpha=1 }))
    r:SetAnchor(inkEAnchor.TopLeft)
    applyMargin(r, x, y)
    return r
end

function inkops.image(x, y, w, h, atlasPath, texturePart, tint)
    local pos = inkops.canvas(x, y)
    pos:SetSize(w or 10, h or 10)
    pos:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))

    local img = inkImage.new()
    img:SetAtlasResource(ResRef.FromName(atlasPath))
    img:SetTexturePart(texturePart)
    img:SetAnchor(inkEAnchor.Fill)
    img:SetOpacity(1)
    img:SetTintColor(tint or HDRColor.new({ Red=1, Green=1, Blue=1, Alpha=1 }))
    img:Reparent(pos, -1)

    return { pos = pos, image = img }
end

function inkops.line(x0, y0, x1, y1, tint, thickness)
    local dx = (x1 or 0) - (x0 or 0)
    local dy = (y1 or 0) - (y0 or 0)
    local length = math.sqrt((dx * dx) + (dy * dy))
    if length < 1 then length = 1 end

    local angle = math.deg(math.atan(dy / math.max(0.001, dx)))
    if dx < 0 then angle = angle + 180 end

    local line = inkRectangle.new()
    line:SetSize(length, thickness or 3)
    line:SetTintColor(tint or HDRColor.new({ Red=1, Green=1, Blue=1, Alpha=1 }))
    line:SetAnchor(inkEAnchor.TopLeft)
    line:SetAnchorPoint(Vector2.new({ X = 0.5, Y = 0.5 }))
    pcall(function() line:SetRotation(angle) end)
    applyMargin(line, (x0 or 0) + (dx * 0.5), (y0 or 0) + (dy * 0.5))
    return line
end

return inkops
