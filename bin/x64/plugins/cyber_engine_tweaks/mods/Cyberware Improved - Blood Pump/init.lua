
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.BloodPumpBuffDuration_inline0.value", 10.0) 	-- Duration | Vanilla = 6.0

	TweakDB:SetFlat("Items.AdvancedBloodPumpUncommon_inline1.value", 50.0) 									-- Heal | Vanilla = 45.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpUncommon_inline2.value", 5.0) 									-- Heal Per Sec | Vanilla = 9.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpUncommon_inline7.floatValues", {50.0, 5.0, 10.0}) 				-- UI | Heal, Heal Per Sec, Duration

	TweakDB:SetFlat("Items.AdvancedBloodPumpUncommonPlus_inline1.value", 60.0) 								-- Heal | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpUncommonPlus_inline2.value", 6.0) 								-- Heal Per Sec | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpUncommonPlus_inline7.floatValues", {60.0, 6.0, 10.0}) 			-- UI | Heal, Heal Per Sec, Duration

	TweakDB:SetFlat("Items.AdvancedBloodPumpRare_inline1.value", 70.0) 										-- Heal | Vanilla = 60.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpRare_inline2.value", 7.0) 										-- Heal Per Sec | Vanilla = 12.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpRare_inline7.floatValues", {70.0, 7.0, 10.0}) 					-- UI | Heal, Heal Per Sec, Duration

	TweakDB:SetFlat("Items.AdvancedBloodPumpRarePlus_inline1.value", 80.0) 									-- Heal | Vanilla = 65.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpRarePlus_inline2.value", 8.0) 									-- Heal Per Sec | Vanilla = 13.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpRarePlus_inline7.floatValues", {80.0, 8.0, 10.0}) 				-- UI | Heal, Heal Per Sec, Duration

	TweakDB:SetFlat("Items.AdvancedBloodPumpEpic_inline1.value", 90.0) 										-- Heal | Vanilla = 70.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpEpic_inline2.value", 9.0) 										-- Heal Per Sec | Vanilla = 15.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpEpic_inline7.floatValues", {90.0, 9.0, 10.0}) 					-- UI | Heal, Heal Per Sec, Duration

	TweakDB:SetFlat("Items.AdvancedBloodPumpEpicPlus_inline1.value", 95.0) 									-- Heal | Vanilla = 75.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpEpicPlus_inline2.value", 9.5) 									-- Heal Per Sec | Vanilla = 16.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpEpicPlus_inline7.floatValues", {95.0, 9.5, 10.0}) 				-- UI | Heal, Heal Per Sec, Duration

	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendary_inline1.value", 100.0) 								-- Heal | Vanilla = 85.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendary_inline2.value", 10.0) 								-- Heal Per Sec | Vanilla = 17.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendary_inline7.floatValues", {100.0, 10.0, 10.0}) 			-- UI | Heal, Heal Per Sec, Duration

	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendaryPlus_inline1.value", 105.0) 							-- Heal | Vanilla = 100.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendaryPlus_inline2.value", 10.5) 							-- Heal Per Sec | Vanilla = 20.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendaryPlus_inline7.floatValues", {105.0, 10.5, 10.0}) 		-- UI | Heal, Heal Per Sec, Duration

	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendaryPlusPlus_inline1.value", 110.0) 						-- Heal | Vanilla = 110.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendaryPlusPlus_inline2.value", 11.0) 						-- Heal Per Sec | Vanilla = 23.0
	TweakDB:SetFlat("Items.AdvancedBloodPumpLegendaryPlusPlus_inline7.floatValues", {110.0, 11.0, 10.0}) 	-- UI | Heal, Heal Per Sec, Duration

end)
