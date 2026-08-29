
registerForEvent('onInit', function()

	TweakDB:SetFlat("Perks.IsPlayerInCritHealth_inline0.value", 34.0)	-- HP to trigger | Vanilla = 25.0 | This may effect other "low hp" mechanics

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderCooldown_inline1.value", 60.0)					-- 		Base Cooldown | Vanilla = 60.0 | Iconic & None Iconic use this
	TweakDB:SetFlat("Items.AdvancedReflexRecorderCommon_inline4.floatValues", {60.0})				-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderCommonPlus_inline1.value", -5.0)					-- 		Cooldown reduction | Vanilla = -5.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderCommonPlus_inline5.floatValues", {55.0})			-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderUncommon_inline1.value", -5.0)						-- 		Cooldown reduction | Vanilla = -5.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderUncommon_inline5.floatValues", {55.0})				-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderUncommonPlus_inline1.value", -10.0)				-- 		Cooldown reduction | Vanilla = -5.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderUncommonPlus_inline5.floatValues", {50.0})			-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderRare_inline1.value", -10.0)						-- 		Cooldown reduction | Vanilla = -10.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderRare_inline5.floatValues", {50.0})					-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderRarePlus_inline1.value", -15.0)					-- 		Cooldown reduction | Vanilla = -10.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderRarePlus_inline5.floatValues", {45.0})				-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderEpic_inline1.value", -15.0)						-- 		Cooldown reduction | Vanilla = -15.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderEpic_inline5.floatValues", {45.0})					-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderEpicPlus_inline1.value", -20.0)					-- 		Cooldown reduction | Vanilla = -15.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderEpicPlus_inline5.floatValues", {40.0})				-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendary_inline1.value", -20.0)					-- 		Cooldown reduction | Vanilla = -20.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendary_inline5.floatValues", {40.0})			-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendaryPlus_inline1.value", -22.5)				-- 		Cooldown reduction | Vanilla = -20.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendaryPlus_inline5.floatValues", {37.5})		-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendaryPlusPlus_inline1.value", -25.0)			-- 		Cooldown reduction | Vanilla = -25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendaryPlusPlus_inline5.floatValues", {35.0})	-- UI | Cooldown

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffCommon_inline3.dilation", 0.8)			-- Time dilation | Vanilla = 0.8
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffCommon_inline3.duration", 3.5)			-- Duration 	 | Vanilla = 2.0
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffCommon_inline5.dilation", 0.8)			-- Time dilation | Vanilla = 0.8
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffCommon_inline5.duration", 4.025)			-- Duration 	 | Vanilla = 2.3 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffCommonPlus_inline3.dilation", 0.75)		-- Time dilation | Vanilla = 0.8
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffCommonPlus_inline3.duration", 3.5)		-- Duration 	 | Vanilla = 2.0
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffCommonPlus_inline5.dilation", 0.75)		-- Time dilation | Vanilla = 0.8
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffCommonPlus_inline5.duration", 4.025)		-- Duration 	 | Vanilla = 2.3 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffUncommon_inline3.dilation", 0.7)			-- Time dilation | Vanilla = 0.7
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffUncommon_inline3.duration", 3.5)			-- Duration 	 | Vanilla = 2.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffUncommon_inline5.dilation", 0.7)			-- Time dilation | Vanilla = 0.7
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffUncommon_inline5.duration", 4.025)		-- Duration 	 | Vanilla = 2.875 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffUncommonPlus_inline3.dilation", 0.65)		-- Time dilation | Vanilla = 0.7
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffUncommonPlus_inline3.duration", 3.5)		-- Duration 	 | Vanilla = 2.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffUncommonPlus_inline5.dilation", 0.65)		-- Time dilation | Vanilla = 0.7
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffUncommonPlus_inline5.duration", 4.025)	-- Duration 	 | Vanilla = 2.875 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffRare_inline3.dilation", 0.6)				-- Time dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffRare_inline3.duration", 3.5)				-- Duration 	 | Vanilla = 3.0
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffRare_inline5.dilation", 0.6)				-- Time dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffRare_inline5.duration", 4.025)			-- Duration 	 | Vanilla = 3.45 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffRarePlus_inline3.dilation", 0.55)			-- Time dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffRarePlus_inline3.duration", 3.5)			-- Duration 	 | Vanilla = 3.0
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffRarePlus_inline5.dilation", 0.55)			-- Time dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffRarePlus_inline5.duration", 4.025)		-- Duration 	 | Vanilla = 3.45 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffEpic_inline3.dilation", 0.5)				-- Time dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffEpic_inline3.duration", 3.5)				-- Duration 	 | Vanilla = 3.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffEpic_inline5.dilation", 0.5)				-- Time dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffEpic_inline5.duration", 4.025)			-- Duration 	 | Vanilla = 4.025 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffEpicPlus_inline3.dilation", 0.45)			-- Time dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffEpicPlus_inline3.duration", 3.5)			-- Duration 	 | Vanilla = 3.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffEpicPlus_inline5.dilation", 0.45)			-- Time dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffEpicPlus_inline5.duration", 4.025)		-- Duration 	 | Vanilla = 4.025 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffLegendary_inline3.dilation", 0.4)			-- Time dilation | Vanilla = 0.4
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffLegendary_inline3.duration", 3.5)			-- Duration 	 | Vanilla = 4.0
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffLegendary_inline5.dilation", 0.4)			-- Time dilation | Vanilla = 0.4
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffLegendary_inline5.duration", 4.025)		-- Duration 	 | Vanilla = 4.6 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffLegendaryPlus_inline3.dilation", 0.4)		-- Time dilation | Vanilla = 0.4
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffLegendaryPlus_inline3.duration", 4.0)		-- Duration 	 | Vanilla = 4.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffLegendaryPlus_inline5.dilation", 0.4)		-- Time dilation | Vanilla = 0.4
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderPlayerBuffLegendaryPlus_inline5.duration", 4.6)		-- Duration 	 | Vanilla = 5.1 	| +15% of above duration

	TweakDB:SetFlat("Items.AdvancedReflexRecorderCommon_inline2.floatValues", {20.0, 3.5, 35.0})			-- UI | Time dilation, duration, Hp to trigger | Vanilla = 20.0, 2.0, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderCommonPlus_inline3.floatValues", {25.0, 3.5, 35.0})		-- UI | Time dilation, duration, Hp to trigger | Vanilla = 20.0, 2.5, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderUncommon_inline3.floatValues", {30.0, 3.5, 35.0})			-- UI | Time dilation, duration, Hp to trigger | Vanilla = 30.0, 2.5, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderUncommonPlus_inline3.floatValues", {35.0, 3.5, 35.0})		-- UI | Time dilation, duration, Hp to trigger | Vanilla = 30.0, 3.0, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderRare_inline3.floatValues", {40.0, 3.5, 35.0})				-- UI | Time dilation, duration, Hp to trigger | Vanilla = 40.0, 3.0, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderRarePlus_inline3.floatValues", {45.0, 3.5, 35.0})			-- UI | Time dilation, duration, Hp to trigger | Vanilla = 40.0, 3.5, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderEpic_inline3.floatValues", {50.0, 3.5, 35.0})				-- UI | Time dilation, duration, Hp to trigger | Vanilla = 50.0, 3.5, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderEpicPlus_inline3.floatValues", {55.0, 3.5, 35.0})			-- UI | Time dilation, duration, Hp to trigger | Vanilla = 50.0, 4.0, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendary_inline3.floatValues", {60.0, 3.5, 35.0})			-- UI | Time dilation, duration, Hp to trigger | Vanilla = 60.0, 4.0, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendaryPlus_inline3.floatValues", {60.0, 4.0, 35.0})		-- UI | Time dilation, duration, Hp to trigger | Vanilla = 60.0, 4.5, 25.0
	TweakDB:SetFlat("Items.AdvancedReflexRecorderLegendaryPlusPlus_inline3.floatValues", {60.0, 4.0, 35.0})	-- UI | Time dilation, duration, Hp to trigger | Vanilla = 60.0, 4.0, 25.0

--	Iconic
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderRare_inline1.value", -10.0)							-- 		Cooldown reduction | Vanilla = -10.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderRare_inline5.floatValues", {50.0})					-- UI | Cooldown

	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderRarePlus_inline1.value", -15.0)						-- 		Cooldown reduction | Vanilla = -10.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderRarePlus_inline5.floatValues", {45.0})				-- UI | Cooldown

	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderEpic_inline1.value", -15.0)							-- 		Cooldown reduction | Vanilla = -15.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderEpic_inline5.floatValues", {45.0})					-- UI | Cooldown

	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderEpicPlus_inline1.value", -20.0)						-- 		Cooldown reduction | Vanilla = -15.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderEpicPlus_inline5.floatValues", {40.0})				-- UI | Cooldown

	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendary_inline1.value", -20.0)						-- 		Cooldown reduction | Vanilla = -20.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendary_inline5.floatValues", {40.0})				-- UI | Cooldown

	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendaryPlus_inline1.value", -22.5)					-- 		Cooldown reduction | Vanilla = -20.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendaryPlus_inline5.floatValues", {37.5})			-- UI | Cooldown

	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendaryPlusPlus_inline1.value", -25.0)				-- 		Cooldown reduction | Vanilla = -25.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendaryPlusPlus_inline5.floatValues", {35.0})		-- UI | Cooldown

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffRare_inline3.dilation", 0.6)			-- Time dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffRare_inline3.duration", 3.5)			-- Duration 	 | Vanilla = 3.0
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffRare_inline5.dilation", 0.6)			-- Time dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffRare_inline5.duration", 4.025)			-- Duration 	 | Vanilla = 3.45 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffRarePlus_inline3.dilation", 0.55)		-- Time dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffRarePlus_inline3.duration", 3.5)		-- Duration 	 | Vanilla = 3.0
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffRarePlus_inline5.dilation", 0.55)		-- Time dilation | Vanilla = 0.6
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffRarePlus_inline5.duration", 4.025)		-- Duration 	 | Vanilla = 3.45 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffEpic_inline3.dilation", 0.5)			-- Time dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffEpic_inline3.duration", 3.5)			-- Duration 	 | Vanilla = 3.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffEpic_inline5.dilation", 0.5)			-- Time dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffEpic_inline5.duration", 4.025)			-- Duration 	 | Vanilla = 4.025 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffEpicPlus_inline3.dilation", 0.45)		-- Time dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffEpicPlus_inline3.duration", 3.5)		-- Duration 	 | Vanilla = 3.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffEpicPlus_inline5.dilation", 0.45)		-- Time dilation | Vanilla = 0.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffEpicPlus_inline5.duration", 4.025)		-- Duration 	 | Vanilla = 4.025 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffLegendary_inline3.dilation", 0.4)		-- Time dilation | Vanilla = 0.4
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffLegendary_inline3.duration", 3.5)		-- Duration 	 | Vanilla = 4.0
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffLegendary_inline5.dilation", 0.4)		-- Time dilation | Vanilla = 0.4
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffLegendary_inline5.duration", 4.025)		-- Duration 	 | Vanilla = 4.6 	| +15% of above duration

	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffLegendaryPlus_inline3.dilation", 0.4)	-- Time dilation | Vanilla = 0.4
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffLegendaryPlus_inline3.duration", 4.0)	-- Duration 	 | Vanilla = 4.5
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffLegendaryPlus_inline5.dilation", 0.4)	-- Time dilation | Vanilla = 0.4
	TweakDB:SetFlat("BaseStatusEffect.ReflexRecorderIconicPlayerBuffLegendaryPlus_inline5.duration", 4.6)	-- Duration 	 | Vanilla = 5.1 	| +15% of above duration

	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderRare_inline3.floatValues", {40.0, 3.5})				-- UI | Time dilation, duration | Vanilla = 40.0, 3.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderRarePlus_inline3.floatValues", {45.0, 3.5})			-- UI | Time dilation, duration | Vanilla = 40.0, 3.5
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderEpic_inline3.floatValues", {50.0, 3.5})				-- UI | Time dilation, duration | Vanilla = 50.0, 3.5
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderEpicPlus_inline3.floatValues", {55.0, 3.5})			-- UI | Time dilation, duration | Vanilla = 50.0, 4.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendary_inline3.floatValues", {60.0, 3.5})			-- UI | Time dilation, duration | Vanilla = 60.0, 4.0
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendaryPlus_inline3.floatValues", {60.0, 4.0})		-- UI | Time dilation, duration | Vanilla = 60.0, 4.5
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendaryPlusPlus_inline3.floatValues", {60.0, 4.0})	-- UI | Time dilation, duration | Vanilla = 60.0, 4.5

	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderRare_inline3.intValues", {35})					-- UI | Hp to trigger | Vanilla = 25 | Same as None Iconic
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderRarePlus_inline3.intValues", {35})				-- UI | Hp to trigger | Vanilla = 25 | Same as None Iconic
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderEpic_inline3.intValues", {35})					-- UI | Hp to trigger | Vanilla = 25 | Same as None Iconic
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderEpicPlus_inline3.intValues", {35})				-- UI | Hp to trigger | Vanilla = 25 | Same as None Iconic
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendary_inline3.intValues", {35})				-- UI | Hp to trigger | Vanilla = 25 | Same as None Iconic
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendaryPlus_inline3.intValues", {35})			-- UI | Hp to trigger | Vanilla = 25 | Same as None Iconic
	TweakDB:SetFlat("Items.IconicAdvancedReflexRecorderLegendaryPlusPlus_inline3.intValues", {35})		-- UI | Hp to trigger | Vanilla = 25 | Same as None Iconic

end)
