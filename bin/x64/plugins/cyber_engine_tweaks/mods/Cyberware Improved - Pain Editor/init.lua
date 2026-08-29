
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedPainReductorEpic_inline6.value", 10.0)	-- Base Armor	 	  | Vanilla = 28.0
	TweakDB:SetFlat("Items.AdvancedPainReductorEpic_inline7.value", 15.0)	-- Armor per Tier	  | Vanilla = 20.0
	TweakDB:SetFlat("Items.AdvancedPainReductorEpic_inline8.value", 15.0)	-- Armor per TierPlus | Vanilla = 20.0

	TweakDB:SetFlat("Items.AdvancedPainReductorEpic_inline1.value", 0.925)				-- 		Damage Reduction | Vanilla = 0.94
	TweakDB:SetFlat("Items.AdvancedPainReductorEpic_inline3.floatValues", {7.5})		-- UI | Damage Reduction 

	TweakDB:SetFlat("Items.AdvancedPainReductorLegendary_inline1.value", 0.9)			-- 		Damage Reduction | Vanilla = 0.93
	TweakDB:SetFlat("Items.AdvancedPainReductorLegendary_inline3.floatValues", {10.0})	-- UI | Damage Reduction 

end)
