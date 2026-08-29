
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.MemoryReplenishmentCooldownEffector_inline2.value", 20.0) -- Trigger at value % | Vanilla = 20.0
	TweakDB:SetFlat("Items.MemoryReplenishmentEffector_inline2.value", 20.0) 		 -- Trigger at value % | Vanilla = 20.0

	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerEpic_inline2.statPoolValue", 20.0)				-- 		RAM Recovery | Vanilla = 15.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerEpic_inline3.intValues", {20, 20})				-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerEpic_inline5.value", 1.0) 						-- 		MAX RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerEpic_inline6.floatValues", {1.0}) 				-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerEpicPlus_inline2.statPoolValue", 25.0) 			-- 		RAM Recovery | Vanilla = 18.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerEpicPlus_inline3.intValues", {20, 25}) 			-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerEpicPlus_inline5.value", 1.0) 					-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerEpicPlus_inline6.floatValues", {1.0}) 			-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendary_inline2.statPoolValue", 25.0) 		-- 		RAM Recovery | Vanilla = 23.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendary_inline3.intValues", {20, 25}) 		-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendary_inline5.value", 2.0) 					-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendary_inline6.floatValues", {2.0}) 			-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendaryPlus_inline2.statPoolValue", 30.0) 	-- 		RAM Recovery | Vanilla = 26.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendaryPlus_inline3.intValues", {20, 30}) 	-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendaryPlus_inline5.value", 2.0) 				-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendaryPlus_inline6.floatValues", {2.0}) 		-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendaryPlusPlus_inline2.statPoolValue", 33.0) -- 		RAM Recovery | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendaryPlusPlus_inline3.intValues", {20, 33}) -- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendaryPlusPlus_inline5.value", 2.0) 			-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedCamilloRamManagerLegendaryPlusPlus_inline6.floatValues", {2.0}) 	-- UI | Max RAM

--	Iconic
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicEpicCooldownEffector_inline2.value", 20.0) 				-- Trigger at value % | Vanilla = 10.0
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicEpicPlusCooldownEffector_inline2.value", 20.0) 			-- Trigger at value % | Vanilla = 10.0
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicLegendaryCooldownEffector_inline2.value", 20.0) 		-- Trigger at value % | Vanilla = 10.0
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicLegendaryPlusCooldownEffector_inline2.value", 20.0) 	-- Trigger at value % | Vanilla = 10.0
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicLegendaryPlusPlusCooldownEffector_inline2.value", 20.0) -- Trigger at value % | Vanilla = 10.0

	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpic_inline6.statPoolValue", 34.0) 				-- 		RAM Recovery | Vanilla = 35.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpic_inline7.intValues", {20, 34}) 				-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpic_inline9.value", 2.0) 						-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpic_inline10.floatValues", {2.0}) 				-- UI | Max RAM

	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpicPlus_inline2.statPoolValue", 38.0) 			-- 		RAM Recovery | Vanilla = 38.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpicPlus_inline3.intValues", {20, 38}) 			-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpicPlus_inline5.value", 2.0) 					-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpicPlus_inline6.floatValues", {2.0}) 			-- UI | Max RAM

	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendary_inline2.statPoolValue", 42.0) 			-- 		RAM Recovery | Vanilla = 40.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendary_inline3.intValues", {20, 42}) 			-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendary_inline5.value", 2.0) 					-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendary_inline6.floatValues", {2.0}) 			-- UI | Max RAM

	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlus_1_inline2.statPoolValue", 46.0) 	-- 		RAM Recovery | Vanilla = 42.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlus_1_inline3.intValues", {20, 46}) 	-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlus_1_inline5.value", 2.0) 				-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlus_1_inline6.floatValues", {2.0}) 		-- UI | Max RAM

	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlusPlus_inline2.statPoolValue", 50.0) 	-- 		RAM Recovery | Vanilla = 45.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlusPlus_inline3.intValues", {20, 50}) 	-- UI | Trigger %, RAM Recovery
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlusPlus_inline5.value", 2.0) 			-- 		Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlusPlus_inline6.floatValues", {2.0}) 	-- UI | Max RAM

end)
