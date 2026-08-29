
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedTimeBankLegendary_inline2.value", 30.0) 								-- 		Max Reduction in Seconds 	 | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedTimeBankLegendary_inline1.value", 0.1) 								-- 		Cyberware Cooldown Reduction | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedTimeBankLegendary_inline11.floatValues", {30.0, 60.0, 10.0}) 		-- UI | Max Reduction, Cooldown, Cooldown Reduction 

	TweakDB:SetFlat("Items.AdvancedTimeBankLegendaryPlus_inline2.value", 40.0) 							-- 		Max Reduction in Seconds 	 | Vanilla = 40.0
	TweakDB:SetFlat("Items.AdvancedTimeBankLegendaryPlus_inline1.value", 0.125) 						-- 		Cyberware Cooldown Reduction | Vanilla = 0.12
	TweakDB:SetFlat("Items.AdvancedTimeBankLegendaryPlus_inline11.floatValues", {40.0, 60.0, 12.5}) 	-- UI | Max Reduction, Cooldown, Cooldown Reduction 

	TweakDB:SetFlat("Items.AdvancedTimeBankLegendaryPlusPlus_inline2.value", 50.0) 						-- 		Max Reduction in Seconds 	 | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedTimeBankLegendaryPlusPlus_inline1.value", 0.15) 						-- 		Cyberware Cooldown Reduction | Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedTimeBankLegendaryPlusPlus_inline11.floatValues", {50.0, 60.0, 15.0}) -- UI | Max Reduction, Cooldown, Cooldown Reduction 

end)
