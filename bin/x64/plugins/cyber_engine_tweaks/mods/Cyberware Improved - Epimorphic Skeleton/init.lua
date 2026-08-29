
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedEndoskeletonEpic_inline5.value", 0.0) 	-- Base Armor | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedEndoskeletonEpic_inline6.value", 25.0) 	-- Armor gained per tier | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedEndoskeletonEpic_inline7.value", 25.0) 	-- Armor gained per tier plus | Vanilla = 30.0

	TweakDB:SetFlat("Items.AdvancedEndoskeletonEpic_inline1.value", 0.125) 					-- 		Hp Bonus | 				Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedEndoskeletonEpic2_inline1.value", 0.15) 					-- 		Hp Bonus | Perk Bonus | Vanilla = 0.12
	TweakDB:SetFlat("Items.AdvancedEndoskeletonEpic_inline2.floatValues", {12.5}) 			-- UI | Hp Bonus | 				Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedEndoskeletonEpic2_inline2.floatValues", {15.0}) 			-- UI | Hp Bonus | Perk Bonus | Vanilla = 12.0

	TweakDB:SetFlat("Items.AdvancedEndoskeletonLegendary_inline1.value", 0.15) 				-- 		Hp Bonus | 				Vanilla = 0.13
	TweakDB:SetFlat("Items.AdvancedEndoSkeletonLegendary2_inline1.value", 0.175) 			-- 		Hp Bonus | Perk Bonus | Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedEndoskeletonLegendary_inline2.floatValues", {15.0}) 		-- UI | Hp Bonus | 				Vanilla = 13.0
	TweakDB:SetFlat("Items.AdvancedEndoSkeletonLegendary2_inline2.floatValues", {17.5}) 	-- UI | Hp Bonus | Perk Bonus | Vanilla = 15.0

end)
