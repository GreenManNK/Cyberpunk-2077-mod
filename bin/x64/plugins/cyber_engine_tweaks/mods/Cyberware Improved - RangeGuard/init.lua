
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedChargeSystemCommon_inline8.value", 10.0)	-- Base Armor		  | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemCommon_inline9.value", 5.0)	-- Armor per Tier	  | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemCommon_inline10.value", 5.0)	-- Armor per TierPlus | Vanilla = 6.0

	TweakDB:SetFlat("Items.AdvancedChargeSystemCommon_inline2.maxDistance", 6.0)				-- 		Max Distance | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemCommon_inline5.value", 60.0)						-- 		Armor Bonus  | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemCommon_inline1.floatValues", {6.0, 60.0})		-- UI | Distance, Armor 

	TweakDB:SetFlat("Items.AdvancedChargeSystemUncommon_inline2.maxDistance", 5.75)				-- 		Max Distance | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemUncommon_inline5.value", 70.0)					-- 		Armor Bonus  | Vanilla = 45.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemUncommon_inline1.floatValues", {5.75, 70.0})		-- UI | Distance, Armor 

	TweakDB:SetFlat("Items.AdvancedChargeSystemRare_inline2.maxDistance", 5.5)					-- 		Max Distance | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemRare_inline5.value", 80.0)						-- 		Armor Bonus  | Vanilla = 60.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemRare_inline1.floatValues", {5.5, 80.0})			-- UI | Distance, Armor 

	TweakDB:SetFlat("Items.AdvancedChargeSystemEpic_inline2.maxDistance", 5.25)					-- 		Max Distance | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemEpic_inline5.value", 90.0)						-- 		Armor Bonus  | Vanilla = 75.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemEpic_inline1.floatValues", {5.25, 90.0})			-- UI | Distance, Armor 

	TweakDB:SetFlat("Items.AdvancedChargeSystemLegendary_inline2.maxDistance", 5.0)				-- 		Max Distance | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemLegendary_inline5.value", 100.0)					-- 		Armor Bonus  | Vanilla = 90.0
	TweakDB:SetFlat("Items.AdvancedChargeSystemLegendary_inline1.floatValues", {5.0, 100.0})	-- UI | Distance, Armor 

end)
