
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedBloodDepleterCommon_inline8.value", 35.0)	-- Base Armor	 	  | Vanilla = 42.0
	TweakDB:SetFlat("Items.AdvancedBloodDepleterCommon_inline9.value", 25.0)	-- Armor per Tier	  | Vanilla = 24.0
	TweakDB:SetFlat("Items.AdvancedBloodDepleterCommon_inline10.value", 25.0)	-- Armor per TierPlus | Vanilla = 24.0

	TweakDB:SetFlat("Items.AdvancedBloodDepleterEpic_inline1.value", 0.75)						-- 		Damage Reduction  | Vanilla = 0.75
	TweakDB:SetFlat("Items.AdvancedBloodDepleterEpic_inline4.damageConversion", 0.25)			-- 		Damage Conversion | Vanilla = 0.25
	TweakDB:SetFlat("Items.AdvancedBloodDepleterEpic_inline4.dotDistributionTime", 5.0)			-- 		DoT Duration 	  | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedBloodDepleterEpic_inline10.floatValues", {25.0})				-- UI | Damage Conversion

	TweakDB:SetFlat("Items.AdvancedBloodDepleterLegendary_inline1.value", 0.7)					-- 		Damage Reduction  | Vanilla = 0.7
	TweakDB:SetFlat("Items.AdvancedBloodDepleterLegendary_inline4.damageConversion", 0.3)		-- 		Damage Conversion | Vanilla = 0.3
	TweakDB:SetFlat("Items.AdvancedBloodDepleterLegendary_inline4.dotDistributionTime", 5.0)	-- 		DoT Duration 	  | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedBloodDepleterLegendary_inline10.floatValues", {30.0})		-- UI | Damage Conversion

end)
