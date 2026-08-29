
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismCommon_inline0.value", 25.0)	-- Base Armor 		   | Vanilla = 28.0
	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismCommon_inline1.value", 15.0)	-- Armor Per Tier 	   | Vanilla = 16.0
	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismCommon_inline2.value", 15.0)	-- Armor Per Tier Plus | Vanilla = 16.0

	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismCommon_inline5.value", 0.11)				-- 		Shock Chance | Vanilla = 0.1
	TweakDB:SetFlat("Attacks.ElectroshockMechanismExplosionCommon_inline0.value", 200.0)			-- 		Shock Damage | Vanilla = 140.0
	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismCommon_inline7.intValues", {11, 200})		-- UI | Chance, Damage

	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismUncommon_inline1.value", 0.12)				-- 		Shock Chance | Vanilla = 0.1
	TweakDB:SetFlat("Attacks.ElectroshockMechanismExplosionUncommon_inline0.value", 275.0)			-- 		Shock Damage | Vanilla = 180.0
	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismUncommon_inline3.intValues", {12, 275})		-- UI | Chance, Damage

	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismRare_inline1.value", 0.13)					-- 		Shock Chance | Vanilla = 0.1
	TweakDB:SetFlat("Attacks.ElectroshockMechanismExplosionRare_inline0.value", 350.0)				-- 		Shock Damage | Vanilla = 270.0
	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismRare_inline3.intValues", {13, 350})			-- UI | Chance, Damage

	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismEpic_inline1.value", 0.14)					-- 		Shock Chance | Vanilla = 0.1
	TweakDB:SetFlat("Attacks.ElectroshockMechanismExplosionEpic_inline0.value", 425.0)				-- 		Shock Damage | Vanilla = 370.0
	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismEpic_inline3.intValues", {14, 425})			-- UI | Chance, Damage

	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismLegendary_inline1.value", 0.15)				-- 		Shock Chance | Vanilla = 0.1
	TweakDB:SetFlat("Attacks.ElectroshockMechanismExplosionLegendary_inline0.value", 500.0)			-- 		Shock Damage | Vanilla = 500.0
	TweakDB:SetFlat("Items.AdvancedElectroshockMechanismLegendary_inline3.intValues", {15, 500})	-- UI | Chance, Damage

end)
