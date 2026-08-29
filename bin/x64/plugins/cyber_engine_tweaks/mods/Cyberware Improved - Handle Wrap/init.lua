
registerForEvent('onInit', function()

	TweakDB:SetFlat("BaseStatusEffect.KnifeSharpenerBuff_inline3.value", 6.0)	-- Duration in Seconds | Vanilla = 6.0

	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerRare_inline3.value", 0.1)								-- 		Crit Chance | Vanilla = 0.08
	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerRare_inline4.floatValues", {10.0, 6.0})				-- UI | Crit Chance, Duration

	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerRarePlus_inline3.value", 0.125)						-- 		Crit Chance | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerRarePlus_inline4.floatValues", {12.5, 6.0})			-- UI | Crit Chance, Duration

	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerEpic_inline3.value", 0.15)								-- 		Crit Chance | Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerEpic_inline4.floatValues", {15.0, 6.0})				-- UI | Crit Chance, Duration

	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerEpicPlus_inline3.value", 0.175)						-- 		Crit Chance | Vanilla = 0.17
	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerEpicPlus_inline4.floatValues", {17.5, 6.0})			-- UI | Crit Chance, Duration

	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerLegendary_inline3.value", 0.2)							-- 		Crit Chance | Vanilla = 0.23
	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerLegendary_inline4.floatValues", {20.0, 6.0})			-- UI | Crit Chance, Duration

	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerLegendaryPlus_inline3.value", 0.225)					-- 		Crit Chance | Vanilla = 0.25
	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerLegendaryPlus_inline4.floatValues", {22.5, 6.0})		-- UI | Crit Chance, Duration

	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerLegendaryPlusPlus_inline3.value", 0.25)				-- 		Crit Chance | Vanilla = 0.27
	TweakDB:SetFlat("Items.AdvancedKnifeSharpenerLegendaryPlusPlus_inline4.floatValues", {25.0, 6.0})	-- UI | Crit Chance, Duration

end)
