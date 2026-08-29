
registerForEvent('onInit', function()

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorCooldown_inline2.value", 0.0)		-- Time dilation if combat triggers | Vanilla = 1.0

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorCooldown_inline1.value", 30.0)					-- 		Cooldown | Vanilla = 60.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorUncommon_inline5.floatValues", {30.0})			-- UI | Cooldown
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorUncommonPlus_inline5.floatValues", {30.0})		-- UI | Cooldown
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorRare_inline5.floatValues", {30.0})				-- UI | Cooldown
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorRarePlus_inline5.floatValues", {30.0})			-- UI | Cooldown
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorEpic_inline5.floatValues", {30.0})				-- UI | Cooldown
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorEpicPlus_inline5.floatValues", {30.0})			-- UI | Cooldown
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendary_inline5.floatValues", {30.0})			-- UI | Cooldown
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendaryPlus_inline5.floatValues", {30.0})		-- UI | Cooldown
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendaryPlusPlus_inline5.floatValues", {30.0})	-- UI | Cooldown

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffUncommon_inline3.dilation", 0.8)					-- 		Time Dilation | Vanilla = 0.8
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffUncommon_inline3.duration", 2.5)					-- 		Duration 	  | Vanilla = 2.0
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffUncommon_inline5.dilation", 0.8)					-- 		Time Dilation | Vanilla = 0.8
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffUncommon_inline5.duration", 2.875)				-- 		Duration 	  | Vanilla = 2.3	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorUncommon_inline2.detectionStep", 50.0)						-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorUncommon_inline3.floatValues", {20.0, 2.5, 50.0})				-- UI | Dilation, Duration, Detection

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffUncommonPlus_inline3.dilation", 0.75)			-- 		Time Dilation | Vanilla = 0.8
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffUncommonPlus_inline3.duration", 2.5)				-- 		Duration 	  | Vanilla = 2.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffUncommonPlus_inline5.dilation", 0.75)			-- 		Time Dilation | Vanilla = 0.8
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffUncommonPlus_inline5.duration", 2.875)			-- 		Duration 	  | Vanilla = 2.875	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorUncommonPlus_inline2.detectionStep", 50.0)					-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorUncommonPlus_inline3.floatValues", {25.0, 2.5, 50.0})			-- UI | Time Dilation, Duration, Detection Trigger | Vanilla = 20.0, 2.5, 50.0

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffRare_inline3.dilation", 0.7)						-- 		Time Dilation | Vanilla = 0.7
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffRare_inline3.duration", 2.5)						-- 		Duration 	  | Vanilla = 2.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffRare_inline5.dilation", 0.7)						-- 		Time Dilation | Vanilla = 0.7
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffRare_inline5.duration", 2.875)					-- 		Duration 	  | Vanilla = 2.875	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorRare_inline2.detectionStep", 50.0)							-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorRare_inline3.floatValues", {30.0, 2.5, 50.0})					-- UI | Dilation, Duration, Detection

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffRarePlus_inline3.dilation", 0.65)				-- 		Time Dilation | Vanilla = 0.7
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffRarePlus_inline3.duration", 2.5)					-- 		Duration 	  | Vanilla = 3.0
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffRarePlus_inline5.dilation", 0.65)				-- 		Time Dilation | Vanilla = 0.7
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffRarePlus_inline5.duration", 2.875)				-- 		Duration 	  | Vanilla = 3.45	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorRarePlus_inline2.detectionStep", 50.0)						-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorRarePlus_inline3.floatValues", {35.0, 2.5, 50.0})				-- UI | Dilation, Duration, Detection

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffEpic_inline3.dilation", 0.6)						-- 		Time Dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffEpic_inline3.duration", 2.5)						-- 		Duration 	  | Vanilla = 3.0
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffEpic_inline5.dilation", 0.6)						-- 		Time Dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffEpic_inline5.duration", 2.875)					-- 		Duration 	  | Vanilla = 3.45	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorEpic_inline2.detectionStep", 50.0)							-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorEpic_inline3.floatValues", {40.0, 2.5, 50.0})					-- UI | Dilation, Duration, Detection

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffEpicPlus_inline3.dilation", 0.55)				-- 		Time Dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffEpicPlus_inline3.duration", 2.5)					-- 		Duration 	  | Vanilla = 3.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffEpicPlus_inline5.dilation", 0.55)				-- 		Time Dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffEpicPlus_inline5.duration", 2.875)				-- 		Duration 	  | Vanilla = 4.025	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorEpicPlus_inline2.detectionStep", 50.0)						-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorEpicPlus_inline3.floatValues", {45.0, 2.5, 50.0})				-- UI | Dilation, Duration, Detection

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendary_inline3.dilation", 0.5)				-- 		Time Dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendary_inline3.duration", 2.5)				-- 		Duration 	  | Vanilla = 3.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendary_inline5.dilation", 0.5)				-- 		Time Dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendary_inline5.duration", 2.875)				-- 		Duration 	  | Vanilla = 4.025	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendary_inline2.detectionStep", 50.0)						-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendary_inline3.floatValues", {50.0, 2.5, 50.0})			-- UI | Dilation, Duration, Detection

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendaryPlus_inline3.dilation", 0.5)			-- 		Time Dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendaryPlus_inline3.duration", 2.75)			-- 		Duration 	  | Vanilla = 4.0
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendaryPlus_inline5.dilation", 0.5)			-- 		Time Dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendaryPlus_inline5.duration", 3.15)			-- 		Duration 	  | Vanilla = 4.6	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendaryPlus_inline2.detectionStep", 50.0)					-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendaryPlus_inline3.floatValues", {50.0, 2.75, 50.0})		-- UI | Dilation, Duration, Detection

	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendaryPlusPlus_inline3.dilation", 0.5)		-- 		Time Dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendaryPlusPlus_inline3.duration", 3.0)		-- 		Duration 	  | Vanilla = 4.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendaryPlusPlus_inline5.dilation", 0.5)		-- 		Time Dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.SynapticAcceleratorPlayerBuffLegendaryPlusPlus_inline5.duration", 3.4)		-- 		Duration 	  | Vanilla = 5.175	| +15% of above duration
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendaryPlusPlus_inline2.detectionStep", 50.0)				-- 		Detection %	  | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSynapticAcceleratorLegendaryPlusPlus_inline3.floatValues", {50.0, 3.0, 50.0})	-- UI | Dilation, Duration, Detection

end)
