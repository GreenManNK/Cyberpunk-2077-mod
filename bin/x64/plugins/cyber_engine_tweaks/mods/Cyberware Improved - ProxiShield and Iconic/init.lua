
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedProximityReducerCommon_inline5.value", 10.0)	-- Base Armor		  | Vanilla = 8.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerCommon_inline6.value", 5.0)	-- Armor per Tier	  | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerCommon_inline7.value", 5.0)	-- Armor per TierPlus | Vanilla = 5.0

	TweakDB:SetFlat("Items.AdvancedProximityReducerCommon_inline1.percentMult", 0.9)					-- 		Damage Reduction | Vanilla = 0.92
	TweakDB:SetFlat("Items.AdvancedProximityReducerCommon_inline1.minDistance", 3.0)					-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerCommon_inline1.maxDistance", 5.0)					-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerCommon_inline2.floatValues", {10.0, 3.0, 5.0})		-- UI | Damage Reduction, Min Dist, Max Dist

	TweakDB:SetFlat("Items.AdvancedProximityReducerUncommon_inline1.percentMult", 0.875)				-- 		Damage Reduction | Vanilla = 0.89
	TweakDB:SetFlat("Items.AdvancedProximityReducerUncommon_inline1.minDistance", 3.0)					-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerUncommon_inline1.maxDistance", 5.25)					-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerUncommon_inline2.floatValues", {12.5, 3.0, 5.25})	-- UI | Damage Reduction, Min Dist, Max Dist

	TweakDB:SetFlat("Items.AdvancedProximityReducerRare_inline1.percentMult", 0.85)						-- 		Damage Reduction | Vanilla = 0.86
	TweakDB:SetFlat("Items.AdvancedProximityReducerRare_inline1.minDistance", 3.0)						-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerRare_inline1.maxDistance", 5.5)						-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerRare_inline2.floatValues", {15.0, 3.0, 5.5})			-- UI | Damage Reduction, Min Dist, Max Dist

	TweakDB:SetFlat("Items.AdvancedProximityReducerEpic_inline1.percentMult", 0.825)					-- 		Damage Reduction | Vanilla = 0.83
	TweakDB:SetFlat("Items.AdvancedProximityReducerEpic_inline1.minDistance", 3.0)						-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerEpic_inline1.maxDistance", 5.75)						-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerEpic_inline2.floatValues", {17.5, 3.0, 5.75})		-- UI | Damage Reduction, Min Dist, Max Dist

	TweakDB:SetFlat("Items.AdvancedProximityReducerLegendary_inline1.percentMult", 0.8)					-- 		Damage Reduction | Vanilla = 0.8
	TweakDB:SetFlat("Items.AdvancedProximityReducerLegendary_inline1.minDistance", 3.0)					-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerLegendary_inline1.maxDistance", 6.0)					-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedProximityReducerLegendary_inline2.floatValues", {20.0, 3.0, 6.0})	-- UI | Damage Reduction, Min Dist, Max Dist

--	Iconic
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpic_inline1.value", 10.0)			-- Base Armor 		  | Vanilla = 30.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpic_inline2.value", 10.0)			-- Armor per Tier	  | Vanilla = 5.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpic_inline3.value", 10.0)			-- Armor per TierPlus | Vanilla = 5.0

	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendary_inline1.value", 10.0)	-- Base Armor 		  | Vanilla = 30.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendary_inline2.value", 10.0)	-- Armor per Tier	  | Vanilla = 5.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendary_inline3.value", 10.0)	-- Armor per TierPlus | Vanilla = 5.0

	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpic_inline8.percentMult", 0.7)							-- 		Damage Reduction | Vanilla = 0.66
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpic_inline8.minDistance", 3.0)							-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpic_inline8.maxDistance", 6.0)							-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpic_inline9.floatValues", {30.0, 3.0, 6.0})				-- UI | Damage Reduction, Min Dist, Max Dist

	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpicPlus_inline1.percentMult", 0.675)						-- 		Damage Reduction | Vanilla = 0.64
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpicPlus_inline1.minDistance", 3.0)						-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpicPlus_inline1.maxDistance", 6.0)						-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerEpicPlus_inline2.floatValues", {32.5, 3.0, 6.0})			-- UI | Damage Reduction, Min Dist, Max Dist

	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendary_inline7.percentMult", 0.65)						-- 		Damage Reduction | Vanilla = 0.6
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendary_inline7.minDistance", 3.0)						-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendary_inline7.maxDistance", 6.0)						-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendary_inline8.floatValues", {35.0, 3.0, 6.0})			-- UI | Damage Reduction, Min Dist, Max Dist

	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendaryPlus_inline1.percentMult", 0.625)					-- 		Damage Reduction | Vanilla = 0.58
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendaryPlus_inline1.minDistance", 3.0)					-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendaryPlus_inline1.maxDistance", 6.0)					-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendaryPlus_inline2.floatValues", {37.5, 3.0, 6.0})		-- UI | Damage Reduction, Min Dist, Max Dist

	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendaryPlusPlus_inline1.percentMult", 0.6)				-- 		Damage Reduction | Vanilla = 0.55
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendaryPlusPlus_inline1.minDistance", 3.0)				-- 		Min Distance 	 | Vanilla = 3.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendaryPlusPlus_inline1.maxDistance", 6.0)				-- 		Max Distance 	 | Vanilla = 6.0
	TweakDB:SetFlat("Items.IconicAdvancedProximityReducerLegendaryPlusPlus_inline2.floatValues", {40.0, 3.0, 6.0})	-- UI | Damage Reduction, Min Dist, Max Dist

end)
