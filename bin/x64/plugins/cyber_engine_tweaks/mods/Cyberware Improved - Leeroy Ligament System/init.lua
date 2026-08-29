
registerForEvent('onInit', function()

--  [ EDIT THE VALUES ON THE LEFT | VANILLA VALUES ARE ON THE RIGHT ]
	TweakDB:SetFlat("Items.IconicJenkinsTendonsUncommon_inline4.value", 0.0)	-- Base Armor		  | Vanilla = 10.0
	TweakDB:SetFlat("Items.IconicJenkinsTendonsUncommon_inline5.value", 10.0)	-- Armor per Tier	  | Vanilla = 4.0
	TweakDB:SetFlat("Items.IconicJenkinsTendonsUncommon_inline6.value", 5.0)	-- Armor per TierPlus | Vanilla = 4.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsUncommon_inline2.value", 0.15)					-- 		Movement Speed Bonus | Vanilla = 0.12
	TweakDB:SetFlat("Items.IconicJenkinsTendonsUncommon_inline1.floatValues", {15.0})			-- UI | Movement Speed Bonus | Vanilla = 12.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsUncommonPlus_inline2.value", 0.175)				-- 		Movement Speed Bonus | Vanilla = 0.13
	TweakDB:SetFlat("Items.IconicJenkinsTendonsUncommonPlus_inline1.floatValues", {17.5})		-- UI | Movement Speed Bonus | Vanilla = 13.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsRare_inline2.value", 0.20)						-- 		Movement Speed Bonus | Vanilla = 0.14
	TweakDB:SetFlat("Items.IconicJenkinsTendonsRare_inline1.floatValues", {20.0})				-- UI | Movement Speed Bonus | Vanilla = 14.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsRarePlus_inline2.value", 0.225)					-- 		Movement Speed Bonus | Vanilla = 0.15
	TweakDB:SetFlat("Items.IconicJenkinsTendonsRarePlus_inline1.floatValues", {22.5})			-- UI | Movement Speed Bonus | Vanilla = 15.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsEpic_inline2.value", 0.25)						-- 		Movement Speed Bonus | Vanilla = 0.16
	TweakDB:SetFlat("Items.IconicJenkinsTendonsEpic_inline1.floatValues", {25.0})				-- UI | Movement Speed Bonus | Vanilla = 16.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsEpicPlus_inline2.value", 0.275)					-- 		Movement Speed Bonus | Vanilla = 0.17
	TweakDB:SetFlat("Items.IconicJenkinsTendonsEpicPlus_inline1.floatValues", {27.5})			-- UI | Movement Speed Bonus | Vanilla = 17.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsLegendary_inline2.value", 0.3)					-- 		Movement Speed Bonus | Vanilla = 0.18
	TweakDB:SetFlat("Items.IconicJenkinsTendonsLegendary_inline1.floatValues", {30.0})			-- UI | Movement Speed Bonus | Vanilla = 18.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsLegendaryPlus_inline2.value", 0.315)				-- 		Movement Speed Bonus | Vanilla = 0.19
	TweakDB:SetFlat("Items.IconicJenkinsTendonsLegendaryPlus_inline1.floatValues", {31.5})		-- UI | Movement Speed Bonus | Vanilla = 19.0

	TweakDB:SetFlat("Items.IconicJenkinsTendonsLegendaryPlusPlus_inline2.value", 0.33)			-- 		Movement Speed Bonus | Vanilla = 0.2
	TweakDB:SetFlat("Items.IconicJenkinsTendonsLegendaryPlusPlus_inline1.floatValues", {33.0})	-- UI | Movement Speed Bonus | Vanilla = 20.0

--	Note: This Cyberware has no Attunement for some reason...
end)
