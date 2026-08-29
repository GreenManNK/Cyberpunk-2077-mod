
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingCommon_inline8.value", 15.0)	-- Base Armor		  | Vanilla = 24.0
	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingCommon_inline9.value", 15.0)	-- Armor per Tier	  | Vanilla = 14.0
	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingCommon_inline10.value", 15.0)	-- Armor per TierPlus | Vanilla = 14.0

	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingUncommon_inline1.armorMultiplier", 0.275)	-- 		Armor Bonus | Vanilla = 0.2
	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingUncommon_inline5.floatValues", {27.5})		-- UI | Armor Bonus 

	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingRare_inline1.armorMultiplier", 0.3)			-- 		Armor Bonus | Vanilla = 0.24
	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingRare_inline5.floatValues", {30.0})			-- UI | Armor Bonus 

	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingEpic_inline1.armorMultiplier", 0.325)		-- 		Armor Bonus | Vanilla = 0.28
	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingEpic_inline5.floatValues", {32.5})			-- UI | Armor Bonus 

	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingLegendary_inline1.armorMultiplier", 0.35)	-- 		Armor Bonus | Vanilla = 0.32
	TweakDB:SetFlat("Items.AdvancedWeirdTankyPlatingLegendary_inline5.floatValues", {35.0})		-- UI | Armor Bonus 

end)
