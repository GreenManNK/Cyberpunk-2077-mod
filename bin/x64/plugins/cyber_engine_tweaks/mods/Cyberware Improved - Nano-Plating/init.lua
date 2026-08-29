
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesCommon_inline16.value", 20.0)	-- Base Armor	 	  | Vanilla = 28.0
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesCommon_inline17.value", 10.0)	-- Armor per Tier	  | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesCommon_inline18.value", 10.0)	-- Armor per TierPlus | Vanilla = 10.0

	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesUncommon_inline2.chanceToTrigger", 0.07)						-- 		Block Chance 				  | Vanilla = 0.04
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesUncommon_inline13.value", 1.5)									-- 		Duration 					  | Vanilla = 1.4
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesUncommon_inline2.nanoPlatesStacks", 2)							-- 		Max Projectiles to Block 	  | Vanilla = 3
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesUncommon_inline2.timeWindow", 5.0)								-- 		Max Projectile Block Duration | Vanilla = 6.5
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesUncommon_inline1.floatValues", {7.0, 100.0, 1.5, 2.0, 5.0})	-- UI | Block Chance, Block Chance Bonus, Duration, Max Projectile, Max Projectile Duration

	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesRare_inline2.chanceToTrigger", 0.08)							-- 		Block Chance 				  | Vanilla = 0.05
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesRare_inline13.value", 1.5)										-- 		Duration 					  | Vanilla = 1.5
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesRare_inline2.nanoPlatesStacks", 3)								-- 		Max Projectiles to Block 	  | Vanilla = 3
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesRare_inline2.timeWindow", 5.0)									-- 		Max Projectile Block Duration | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesRare_inline1.floatValues", {8.0, 100.0, 1.5, 3.0, 5.0})		-- UI | Block Chance, Block Chance Bonus, Duration, Max Projectile, Max Projectile Duration

	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesEpic_inline2.chanceToTrigger", 0.09)							-- 		Block Chance 				  | Vanilla = 0.06
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesEpic_inline13.value", 1.5)										-- 		Duration 					  | Vanilla = 1.6
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesEpic_inline2.nanoPlatesStacks", 4)								-- 		Max Projectiles to Block 	  | Vanilla = 3
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesEpic_inline2.timeWindow", 5.0)									-- 		Max Projectile Block Duration | Vanilla = 5.5
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesEpic_inline1.floatValues", {9.0, 100.0, 1.5, 4.0, 5.0})		-- UI | Block Chance, Block Chance Bonus, Duration, Max Projectile, Max Projectile Duration

	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesLegendary_inline2.chanceToTrigger", 0.1)						-- 		Block Chance 				  | Vanilla = 0.07
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesLegendary_inline13.value", 1.5)								-- 		Duration 					  | Vanilla = 1.7
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesLegendary_inline2.nanoPlatesStacks", 5)						-- 		Max Projectiles to Block 	  | Vanilla = 3
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesLegendary_inline2.timeWindow", 5.0)							-- 		Max Projectile Block Duration | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedNanoTechPlatesLegendary_inline1.floatValues", {10.0, 100.0, 1.5, 5.0, 5.0})	-- UI | Block Chance, Block Chance Bonus, Duration, Max Projectile, Max Projectile Duration

end)
