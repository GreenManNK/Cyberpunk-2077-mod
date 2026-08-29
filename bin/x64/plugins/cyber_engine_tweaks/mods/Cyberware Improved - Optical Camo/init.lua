
registerForEvent('onInit', function()

-- Armor
	TweakDB:SetFlat("Items.AdvancedOpticalCamoCommon_inline12.value", 0.0)	-- Base Armor	 	  | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoCommon_inline13.value", 10.0)	-- Armor per Tier	  | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoCommon_inline14.value", 5.0)	-- Armor per TierPlus | Vanilla = 5.0

-- Stats
	TweakDB:SetFlat("Effectors.AttachCloakVisionBlockerUncommon.visionBlockerDetectionModifier", 0.5)	-- 		Visibility Mult | Vanilla = 0.7
	TweakDB:SetFlat("Items.AdvancedOpticalCamoUncommon_inline2.value", 7.0)								-- 		Invis Duration  | Vanilla = 4.0
	TweakDB:SetFlat("BaseStatusEffect.OpticalCamoPlayerBuffUncommon_inline1.value", 7.0)				-- 		Invis Duration  | Vanilla = 4.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoUncommon_inline7.intValues", {50, 7})						-- UI | Invisibility, Invis Duration

	TweakDB:SetFlat("Items.AdvancedOpticalCamoUncommonPlus_inline2.value", 7.0)							-- 		Invis Duration  | Vanilla = 4.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoUncommonPlus_inline7.intValues", {50, 7})					-- UI | Invisibility, Invis Duration

	TweakDB:SetFlat("Effectors.AttachCloakVisionBlockerRare.visionBlockerDetectionModifier", 0.4)		-- 		Visibility Mult | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedOpticalCamoRare_inline2.value", 7.0)									-- 		Invis Duration | Vanilla = 5.0
	TweakDB:SetFlat("BaseStatusEffect.OpticalCamoPlayerBuffRare_inline1.value", 7.0)					-- 		Invis Duration | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoRare_inline7.intValues", {60, 7})							-- UI | Invisibility, Invis Duration

	TweakDB:SetFlat("Items.AdvancedOpticalCamoRarePlus_inline2.value", 7.0)								-- 		Invis Duration  | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoRarePlus_inline7.intValues", {60, 7})						-- UI | Invisibility, Invis Duration

	TweakDB:SetFlat("Effectors.AttachCloakVisionBlockerEpic.visionBlockerDetectionModifier", 0.3)		-- 		Visibility Mult | Vanilla = 0.3
	TweakDB:SetFlat("Items.AdvancedOpticalCamoEpic_inline2.value", 7.0)									-- 		Invis Duration | Vanilla = 6.0
	TweakDB:SetFlat("BaseStatusEffect.OpticalCamoPlayerBuffEpic_inline1.value", 7.0)					-- 		Invis Duration | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoEpic_inline6.intValues", {70, 7})							-- UI | Invisibility, Invis Duration

	TweakDB:SetFlat("Items.AdvancedOpticalCamoEpicPlus_inline4.value", 7.0)								-- 		Invis Duration  | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoEpicPlus_inline6.intValues", {70, 7})						-- UI | Invisibility, Invis Duration

	TweakDB:SetFlat("Effectors.AttachCloakVisionBlockerLegendary.visionBlockerDetectionModifier", 0.2)	-- 		Visibility Mult | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendary_inline2.value", 7.0)							-- 		Invis Duration | Vanilla = 7.0
	TweakDB:SetFlat("BaseStatusEffect.OpticalCamoPlayerBuffLegendary_inline1.value", 7.0)				-- 		Invis Duration | Vanilla = 7.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendary_inline7.intValues", {80, 7})					-- UI | Invisibility, Invis Duration

	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendaryPlus_inline2.value", 7.0)						-- 		Invis Duration  | Vanilla = 7.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendaryPlus_inline7.intValues", {80, 7})				-- UI | Invisibility, Invis Duration

	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendaryPlusPlus_inline2.value", 7.0)					-- 		Invis Duration  | Vanilla = 7.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendaryPlusPlus_inline7.intValues", {80, 7})			-- UI | Invisibility, Invis Duration

-- Cooldown
	TweakDB:SetFlat("Items.AdvancedOpticalCamoUncommon_inline1.value", 70.0)					-- 		Cooldown Duration | Vanilla = 70.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoUncommon_inline13.floatValues", {70.0})			-- UI | Cooldown Duration 

	TweakDB:SetFlat("Items.AdvancedOpticalCamoUncommonPlus_inline1.value", 65.0)				-- 		Cooldown Duration | Vanilla = 70.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoUncommonPlus_inline13.floatValues", {65.0})		-- UI | Cooldown Duration 

	TweakDB:SetFlat("Items.AdvancedOpticalCamoRare_inline1.value", 65.0)						-- 		Cooldown Duration | Vanilla = 60.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoRare_inline13.floatValues", {65.0})				-- UI | Cooldown Duration 

	TweakDB:SetFlat("Items.AdvancedOpticalCamoRarePlus_inline1.value", 60.0)					-- 		Cooldown Duration | Vanilla = 60.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoRarePlus_inline13.floatValues", {60.0})			-- UI | Cooldown Duration 

	TweakDB:SetFlat("Items.AdvancedOpticalCamoEpic_inline1.value", 60.0)						-- 		Cooldown Duration | Vanilla = 55.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoEpic_inline12.floatValues", {60.0})				-- UI | Cooldown Duration 

	TweakDB:SetFlat("Items.AdvancedOpticalCamoEpicPlus_inline1.value", 55.0)					-- 		Cooldown Duration | Vanilla = 55.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoEpicPlus_inline12.floatValues", {55.0})			-- UI | Cooldown Duration 

	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendary_inline1.value", 55.0)					-- 		Cooldown Duration | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendary_inline13.floatValues", {55.0})			-- UI | Cooldown Duration 

	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendaryPlus_inline1.value", 50.0)				-- 		Cooldown Duration | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendaryPlus_inline13.floatValues", {50.0})		-- UI | Cooldown Duration 

	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendaryPlusPlus_inline1.value", 45.0)			-- 		Cooldown Duration | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedOpticalCamoLegendaryPlusPlus_inline13.floatValues", {45.0})	-- UI | Cooldown Duration 

end)
