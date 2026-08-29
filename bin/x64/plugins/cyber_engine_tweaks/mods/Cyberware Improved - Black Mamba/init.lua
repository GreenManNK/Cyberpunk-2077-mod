
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedViralVenomDebuffEffector.value", 0.5)	-- Poison Damage Mult | Vanilla = 0.1

	TweakDB:SetFlat("Items.AdvancedViralVenomRare_inline1.value", 1.1)								-- 		Damage to Poisoned Targets | Vanilla = 1.0
	TweakDB:SetFlat("Items.AdvancedViralVenomRare_inline2.floatValues", {50.0, 10.0})				-- UI | Poison Damage Mult, Damage to Poisoned Targets

	TweakDB:SetFlat("Items.AdvancedViralVenomRarePlus_inline2.value", 1.125)						-- 		Damage to Poisoned Targets | Vanilla = 1.115
	TweakDB:SetFlat("Items.AdvancedViralVenomRarePlus_inline3.floatValues", {50.0, 12.5})			-- UI | Poison Damage Mult, Damage to Poisoned Targets

	TweakDB:SetFlat("Items.AdvancedViralVenomEpic_inline1.value", 1.15)								-- 		Damage to Poisoned Targets | Vanilla = 1.14
	TweakDB:SetFlat("Items.AdvancedViralVenomEpic_inline2.floatValues", {50.0, 15.0})				-- UI | Poison Damage Mult, Damage to Poisoned Targets

	TweakDB:SetFlat("Items.AdvancedViralVenomEpicPlus_inline1.value", 1.175)						-- 		Damage to Poisoned Targets | Vanilla = 1.155
	TweakDB:SetFlat("Items.AdvancedViralVenomEpicPlus_inline2.floatValues", {50.0, 17.5})			-- UI | Poison Damage Mult, Damage to Poisoned Targets

	TweakDB:SetFlat("Items.AdvancedViralVenomLegendary_inline1.value", 1.2)							-- 		Damage to Poisoned Targets | Vanilla = 1.18
	TweakDB:SetFlat("Items.AdvancedViralVenomLegendary_inline2.floatValues", {50.0, 20.0})			-- UI | Poison Damage Mult, Damage to Poisoned Targets

	TweakDB:SetFlat("Items.AdvancedViralVenomLegendaryPlus_inline1.value", 1.225)					-- 		Damage to Poisoned Targets | Vanilla = 1.2
	TweakDB:SetFlat("Items.AdvancedViralVenomLegendaryPlus_inline2.floatValues", {50.0, 22.5})		-- UI | Poison Damage Mult, Damage to Poisoned Targets

	TweakDB:SetFlat("Items.AdvancedViralVenomLegendaryPlusPlus_inline1.value", 1.25)				-- 		Damage to Poisoned Targets | Vanilla = 1.22
	TweakDB:SetFlat("Items.AdvancedViralVenomLegendaryPlusPlus_inline2.floatValues", {50.0, 25.0})	-- UI | Poison Damage Mult, Damage to Poisoned Targets

end)
