local color = {}

function color.new(r, g, b, a, bytescale)
    local s = bytescale or 255
    return HDRColor.new({
        Red = (r or 255) / s,
        Green = (g or 255) / s,
        Blue = (b or 255) / s,
        Alpha = a or 1,
    })
end

color.brandWhite     = color.new(232,232,228,1,255)
color.brandWhiteSoft = color.new(205,207,210,1,255)
color.brandBlack     = color.new(3,4,7,1,255)
color.brandPanel     = color.new(7,8,11,1,255)
color.brandPanel2    = color.new(13,14,18,1,255)
color.brandPanel3    = color.new(19,20,24,1,255)
color.brandRed       = color.new(204,46,54,1,255)
color.brandRedSoft   = color.new(228,68,76,1,255)
color.brandRedBright = color.new(242,88,96,1,255)

color.white   = color.brandWhite
color.black   = color.brandBlack
color.dim     = color.new(132,136,142,1,255)
color.panel   = color.brandPanel
color.panel2  = color.brandPanel2
color.line    = color.brandRed
color.red     = color.brandRedSoft

color.cyan    = color.brandWhiteSoft
color.green   = color.brandWhite
color.gold    = color.brandRedBright
color.orange  = color.brandRedSoft

color.riskGreen    = color.new(76, 210, 128, 1, 255)
color.riskOrange   = color.new(238, 150, 48, 1, 255)
color.riskRed      = color.brandRedBright
color.cashbackGreen = color.new(82, 224, 132, 1, 255)
return color
