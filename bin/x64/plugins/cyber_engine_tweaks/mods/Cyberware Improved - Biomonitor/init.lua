
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.HealthMonitorEffector_inline2.value", 49) -- < HP % to Trigger Heal | Vanilla = 50

	TweakDB:SetFlat("Items.AdvancedBiomonitorCommon_inline1.value", 0.01) 							-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorCommon_inline2.value", 0.01) 							-- 		Heal bonus | Vanilla = 0.02
	TweakDB:SetFlat("Items.AdvancedBiomonitorCommon_inline3.value", 0.01) 							-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorCommon_inline4.floatValues", {50.0, 1.0}) 				-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorCommonPlus_inline1.value", 0.02) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorCommonPlus_inline2.value", 0.02) 						-- 		Heal bonus | Vanilla = 0.03
	TweakDB:SetFlat("Items.AdvancedBiomonitorCommonPlus_inline3.value", 0.02) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorCommonPlus_inline4.floatValues", {50.0, 2.0}) 			-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorUncommon_inline1.value", 0.04) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorUncommon_inline2.value", 0.04) 						-- 		Heal bonus | Vanilla = 0.05
	TweakDB:SetFlat("Items.AdvancedBiomonitorUncommon_inline3.value", 0.04) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorUncommon_inline4.floatValues", {50.0, 4.0}) 			-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorUncommonPlus_inline1.value", 0.06) 					-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorUncommonPlus_inline2.value", 0.06) 					-- 		Heal bonus | Vanilla = 0.06
	TweakDB:SetFlat("Items.AdvancedBiomonitorUncommonPlus_inline3.value", 0.06) 					-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorUncommonPlus_inline4.floatValues", {50.0, 6.0}) 		-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorRare_inline1.value", 0.08) 							-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorRare_inline2.value", 0.08) 							-- 		Heal bonus | Vanilla = 0.08
	TweakDB:SetFlat("Items.AdvancedBiomonitorRare_inline3.value", 0.08) 							-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorRare_inline4.floatValues", {50.0, 8.0}) 				-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorRarePlus_inline1.value", 0.10) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorRarePlus_inline2.value", 0.10) 						-- 		Heal bonus | Vanilla = 0.09
	TweakDB:SetFlat("Items.AdvancedBiomonitorRarePlus_inline3.value", 0.10) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorRarePlus_inline4.floatValues", {50.0, 10.0}) 			-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorEpic_inline1.value", 0.12) 							-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorEpic_inline2.value", 0.12) 							-- 		Heal bonus | Vanilla = 0.11
	TweakDB:SetFlat("Items.AdvancedBiomonitorEpic_inline3.value", 0.12) 							-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorEpic_inline4.floatValues", {50.0, 12.0}) 				-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorEpicPlus_inline1.value", 0.14) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorEpicPlus_inline2.value", 0.14) 						-- 		Heal bonus | Vanilla = 0.12
	TweakDB:SetFlat("Items.AdvancedBiomonitorEpicPlus_inline3.value", 0.14) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorEpicPlus_inline4.floatValues", {50.0, 14.0}) 			-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendary_inline1.value", 0.16) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendary_inline2.value", 0.16) 						-- 		Heal bonus | Vanilla = 0.14
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendary_inline3.value", 0.16) 						-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendary_inline4.floatValues", {50.0, 16.0}) 			-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendaryPlus_inline1.value", 0.18) 					-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendaryPlus_inline2.value", 0.18) 					-- 		Heal bonus | Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendaryPlus_inline3.value", 0.18) 					-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendaryPlus_inline4.floatValues", {50.0, 18.0}) 		-- UI | Heal Bonus

	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendaryPlusPlus_inline1.value", 0.20) 				-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendaryPlusPlus_inline2.value", 0.20) 				-- 		Heal bonus | Vanilla = 0.16
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendaryPlusPlus_inline3.value", 0.20) 				-- 		Heal bonus
	TweakDB:SetFlat("Items.AdvancedBiomonitorLegendaryPlusPlus_inline4.floatValues", {50.0, 20.0}) 	-- UI | Heal Bonus

end)
