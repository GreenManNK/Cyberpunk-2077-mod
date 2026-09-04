local Lang = require("external/Lang")

subtitle = {
	hudText = nil
}

function subtitle.startSubtitleObserver()
	Observe("NameplateVisualsLogicController", "OnInitialize", function(this)
		if subtitle.hudText then
			subtitle.hudText:SetVisible(false)
		end

		local label = inkText.new()
		CName.add("custom_subtitle")
		label:SetName('custom_subtitle')
		label:SetFontFamily(Lang.getFontFamily())
		label:SetFontStyle(Lang.getFontStyle())
		label:SetFontSize(55)
		label:SetLetterCase(textLetterCase.OriginalCase)
		label:SetAnchor(inkEAnchor.Fill)
		label:SetTintColor(HDRColor.new({ Red = 1.1761, Green = 0.3809, Blue = 0.3476, Alpha = 1.0 }))
		label:SetHorizontalAlignment(textHorizontalAlignment.Center)
		label:SetVerticalAlignment(textVerticalAlignment.Top)
		label:SetMargin(inkMargin.new({ left = 0.0, top = 300.0, right = 0.0, bottom = 0.0 }))
		label:SetText("")
		label:SetVisible(false)
		label:Reparent(this:GetRootCompoundWidget().parentWidget.parentWidget.parentWidget.parentWidget.parentWidget, -1)
		subtitle.hudText = label
	end)
end

return subtitle
