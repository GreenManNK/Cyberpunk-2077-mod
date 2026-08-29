
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedPlatingGlitchCommon_inline9.value", 10.0)		-- Base Armor	 	  | Vanilla = 24.0
	TweakDB:SetFlat("Items.AdvancedPlatingGlitchCommon_inline10.value", 15.0)		-- Armor per Tier	  | Vanilla = 14.0
	TweakDB:SetFlat("Items.AdvancedPlatingGlitchCommon_inline11.value", 15.0)		-- Armor per TierPlus | Vanilla = 14.0

	TweakDB:SetFlat("BaseStatusEffect.PlatingGlitchBuffRare_inline3.value", 60.0)				-- 		Mitigation Chance | Vanilla = 50.0
	TweakDB:SetFlat("BaseStatusEffect.PlatingGlitchBuffRare_inline1.value", 3.0)				-- 		Duration 		  | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedPlatingGlitchRare_inline1.floatValues", {60.0, 3.0})			-- UI | Miti Chance, Duration

	TweakDB:SetFlat("BaseStatusEffect.PlatingGlitchBuffEpic_inline3.value", 75.0)				-- 		Mitigation Chance | Vanilla = 70.0
	TweakDB:SetFlat("BaseStatusEffect.PlatingGlitchBuffEpic_inline1.value", 3.5)				-- 		Duration 		  | Vanilla = 3.5
	TweakDB:SetFlat("Items.AdvancedPlatingGlitchEpic_inline1.floatValues", {75.0, 3.5})			-- UI | Miti Chance, Duration

	TweakDB:SetFlat("BaseStatusEffect.PlatingGlitchBuffLegendary_inline3.value", 90.0)			-- 		Mitigation Chance | Vanilla = 90.0
	TweakDB:SetFlat("BaseStatusEffect.PlatingGlitchBuffLegendary_inline1.value", 4.0)			-- 		Duration 		  | Vanilla = 4.0
	TweakDB:SetFlat("Items.AdvancedPlatingGlitchLegendary_inline1.floatValues", {90.0, 4.0})	-- UI | Miti Chance, Duration

end)
