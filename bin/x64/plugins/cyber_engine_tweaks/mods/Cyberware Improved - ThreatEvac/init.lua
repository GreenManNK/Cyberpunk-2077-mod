
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommon_inline1.statPoolStep", 2.72)					-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommon_inline1.minStacks", 2.0)						-- Min Stacks | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommon_inline1.maxStacks", 20.0)						-- Max Stacks | Vanilla = 15.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommon_inline1.startingThreshold", 50.0)				-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommon_inline2.floatValues", {2.0, 20.0})				-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommon_inline2.intValues", {50})						-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommonPlus_inline1.statPoolStep", 1.81)				-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommonPlus_inline1.minStacks", 3.0)					-- Min Stacks | Vanilla = 7.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommonPlus_inline1.maxStacks", 30.0)					-- Max Stacks | Vanilla = 17.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommonPlus_inline1.startingThreshold", 50.0)			-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommonPlus_inline2.floatValues", {3.0, 30.0})			-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanCommonPlus_inline2.intValues", {50})					-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommon_inline1.statPoolStep", 1.36)					-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommon_inline1.minStacks", 4.0)						-- Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommon_inline1.maxStacks", 40.0)					-- Max Stacks | Vanilla = 20.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommon_inline1.startingThreshold", 50.0)			-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommon_inline2.floatValues", {4.0, 40.0})			-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommon_inline2.intValues", {50})					-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommonPlus_inline1.statPoolStep", 1.08)				-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommonPlus_inline1.minStacks", 5.0)					-- Min Stacks | Vanilla = 12.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommonPlus_inline1.maxStacks", 50.0)				-- Max Stacks | Vanilla = 22.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommonPlus_inline1.startingThreshold", 50.0)		-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommonPlus_inline2.floatValues", {5.0, 50.0})		-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanUncommonPlus_inline2.intValues", {50})				-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRare_inline1.statPoolStep", 0.87)						-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRare_inline1.minStacks", 6.0)							-- Min Stacks | Vanilla = 15.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRare_inline1.maxStacks", 60.0)						-- Max Stacks | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRare_inline1.startingThreshold", 50.0)				-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRare_inline2.floatValues", {6.0, 60.0})				-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRare_inline2.intValues", {50})						-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRarePlus_inline1.statPoolStep", 0.77)					-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRarePlus_inline1.minStacks", 7.0)						-- Min Stacks | Vanilla = 17.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRarePlus_inline1.maxStacks", 70.0)					-- Max Stacks | Vanilla = 27.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRarePlus_inline1.startingThreshold", 50.0)			-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRarePlus_inline2.floatValues", {7.0, 70.0})			-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanRarePlus_inline2.intValues", {50})					-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpic_inline1.statPoolStep", 0.68)						-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpic_inline1.minStacks", 8.0)							-- Min Stacks | Vanilla = 20.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpic_inline1.maxStacks", 80.0)						-- Max Stacks | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpic_inline1.startingThreshold", 50.0)				-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpic_inline2.floatValues", {8.0, 80.0})				-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpic_inline2.intValues", {50})						-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpicPlus_inline1.statPoolStep", 0.6)					-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpicPlus_inline1.minStacks", 9.0)						-- Min Stacks | Vanilla = 22.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpicPlus_inline1.maxStacks", 90.0)					-- Max Stacks | Vanilla = 32.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpicPlus_inline1.startingThreshold", 50.0)			-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpicPlus_inline2.floatValues", {9.0, 90.0})			-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanEpicPlus_inline2.intValues", {50})					-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendary_inline1.statPoolStep", 0.54)				-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendary_inline1.minStacks", 10.0)					-- Min Stacks | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendary_inline1.maxStacks", 100.0)					-- Max Stacks | Vanilla = 35.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendary_inline1.startingThreshold", 50.0)			-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendary_inline2.floatValues", {10.0, 100.0})		-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendary_inline2.intValues", {50})					-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlus_inline1.statPoolStep", 0.49)			-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlus_inline1.minStacks", 11.0)				-- Min Stacks | Vanilla = 27.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlus_inline1.maxStacks", 110.0)				-- Max Stacks | Vanilla = 37.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlus_inline1.startingThreshold", 50.0)		-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlus_inline2.floatValues", {11.0, 110.0})	-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlus_inline2.intValues", {50})				-- UI | Health Threshold

	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlusPlus_inline1.statPoolStep", 0.45)			-- Health Threshold change per stack | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlusPlus_inline1.minStacks", 12.0)				-- Min Stacks | Vanilla = 29.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlusPlus_inline1.maxStacks", 120.0)				-- Max Stacks | Vanilla = 39.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlusPlus_inline1.startingThreshold", 50.0)		-- Health Threshold | Vanilla = 25.0
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlusPlus_inline2.floatValues", {12.0, 120.0})	-- UI | Move Speed, Max Move Speed
	TweakDB:SetFlat("Items.AdvancedCatchMeIfYouCanLegendaryPlusPlus_inline2.intValues", {50})				-- UI | Health Threshold

end)
