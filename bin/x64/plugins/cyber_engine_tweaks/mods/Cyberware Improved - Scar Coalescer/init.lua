
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon_inline10.value", 10.0) 	-- Armor Base | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon_inline11.value", 10.1) 	-- Armor Per Tier | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon_inline12.value", 10.1) 	-- Armor Per Tier Plus | Vanilla = 6.0

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon_inline3.value", 50.0) 					-- Hp Threshold 	 				| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon_inline6.value", 0.1) 						-- Armor % Bonus 					| Vanilla = 0.08 (fix)
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon_inline7.floatValues", {50.0, 10.0}) 		-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon2_inline3.value", 50.0) 					-- Hp Threshold, Perk Bonus	 		| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon2_inline6.value", 0.125) 					-- Armor % Bonus, Perk Bonus 		| Vanilla = 0.1  (fix)
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainCommon2_inline7.floatValues", {50.0, 12.5}) 		-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainUncommon_inline3.value", 50.0) 					-- Hp Threshold 	 				| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainUncommon_inline6.value", 0.125) 					-- Armor % Bonus 					| Vanilla = 0.125
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainUncommon_inline7.floatValues", {50.0, 12.5}) 	-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainUncommon2_inline3.value", 50.0) 					-- Hp Threshold, Perk Bonus	 		| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainUncommon2_inline6.value", 0.15) 					-- Armor % Bonus, Perk Bonus 		| Vanilla = 0.145 
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainUncommon2_inline7.floatValues", {50.0, 15.0}) 	-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainRare_inline3.value", 50.0) 						-- Hp Threshold 	 				| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainRare_inline6.value", 0.15) 						-- Armor % Bonus 					| Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainRare_inline7.floatValues", {50.0, 15.0}) 		-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainRare2_inline3.value", 50.0) 						-- Hp Threshold, Perk Bonus	 		| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainRare2_inline6.value", 0.175) 						-- Armor % Bonus, Perk Bonus 		| Vanilla = 0.17 
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainRare2_inline7.floatValues", {50.0, 17.5}) 		-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainEpic_inline3.value", 50.0) 						-- Hp Threshold 	 				| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainEpic_inline6.value", 0.175) 						-- Armor % Bonus 					| Vanilla = 0.175
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainEpic_inline7.floatValues", {50.0, 17.5}) 		-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainEpic2_inline3.value", 50.0) 						-- Hp Threshold, Perk Bonus	 		| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainEpic2_inline6.value", 0.2) 						-- Armor % Bonus, Perk Bonus 		| Vanilla = 0.195 
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainEpic2_inline7.floatValues", {50.0, 20.0}) 		-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGain_Legendary_inline3.value", 50.0) 				-- Hp Threshold 	 				| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGain_Legendary_inline6.value", 0.2) 					-- Armor % Bonus 					| Vanilla = 0.2
	TweakDB:SetFlat("Items.AdvancedNoPainNoGain_Legendary_inline7.floatValues", {50.0, 20.0}) 	-- UI | Hp Threshold, Armor % Bonus

	TweakDB:SetFlat("Items.AdvancedNoPainNoGainLegendary2_inline3.value", 50.0) 				-- Hp Threshold, Perk Bonus	 		| Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainLegendary2_inline6.value", 0.225) 				-- Armor % Bonus, Perk Bonus 		| Vanilla = 0.22
	TweakDB:SetFlat("Items.AdvancedNoPainNoGainLegendary2_inline7.floatValues", {50.0, 22.5}) 	-- UI | Hp Threshold, Armor % Bonus

end)
