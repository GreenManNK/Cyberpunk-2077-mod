
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommon_inline0.value", 10.0)		-- Base Armor	 	  | Vanilla = 18.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommon_inline1.value", 10.0)		-- Armor per Tier	  | Vanilla = 9.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommon_inline2.value", 5.0)		-- Armor per TierPlus | Vanilla = 4.0

	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommon_inline5.startingThreshold", 3.0)					-- 		< RAM to trigger   | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommon_inline8.value", 25.0)								-- 		Armor when Low RAM | Vanilla = 36.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommon_inline9.floatValues", {3.0, 250.0})				-- UI | RAM to trigger, Armor Bonus %

	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommonPlus_inline1.startingThreshold", 4.0)				-- 		< RAM to trigger   | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommonPlus_inline4.value", 37.5)							-- 		Armor when Low RAM | Vanilla = 44.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameCommonPlus_inline5.floatValues", {4.0, 250.0})			-- UI | RAM to trigger, Armor Bonus %

	TweakDB:SetFlat("Items.AdvancedCogitoFrameUncommon_inline1.startingThreshold", 5.0)					-- 		< RAM to trigger   | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameUncommon_inline4.value", 50.0)							-- 		Armor when Low RAM | Vanilla = 57.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameUncommon_inline5.floatValues", {5.0, 250.0})				-- UI | RAM to trigger, Armor Bonus % 

	TweakDB:SetFlat("Items.AdvancedCogitoFrameUncommonPlus_inline1.startingThreshold", 6.0)				-- 		< RAM to trigger   | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameUncommonPlus_inline4.value", 62.5)						-- 		Armor when Low RAM | Vanilla = 65.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameUncommonPlus_inline5.floatValues", {6.0, 250.0})			-- UI | RAM to trigger, Armor Bonus %

	TweakDB:SetFlat("Items.AdvancedCogitoFrameRare_inline1.startingThreshold", 7.0)						-- 		< RAM to trigger   | Vanilla = 7.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameRare_inline4.value", 75.0)								-- 		Armor when Low RAM | Vanilla = 79.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameRare_inline5.floatValues", {7.0, 250.0})					-- UI | RAM to trigger, Armor Bonus %

	TweakDB:SetFlat("Items.AdvancedCogitoFrameRarePlus_inline1.startingThreshold", 8.0)					-- 		< RAM to trigger   | Vanilla = 7.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameRarePlus_inline4.value", 87.5)							-- 		Armor when Low RAM | Vanilla = 88.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameRarePlus_inline5.floatValues", {8.0, 250.0})				-- UI | RAM to trigger, Armor Bonus %

	TweakDB:SetFlat("Items.AdvancedCogitoFrameEpic_inline1.startingThreshold", 9.0)						-- 		< RAM to trigger   | Vanilla = 9.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameEpic_inline4.value", 100.0)								-- 		Armor when Low RAM | Vanilla = 104.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameEpic_inline5.floatValues", {9.0, 250.0})					-- UI | RAM to trigger, Armor Bonus %

	TweakDB:SetFlat("Items.AdvancedCogitoFrameEpicPlus_inline1.startingThreshold", 10.0)				-- 		< RAM to trigger   | Vanilla = 9.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameEpicPlus_inline4.value", 112.5)							-- 		Armor when Low RAM | Vanilla = 113.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameEpicPlus_inline5.floatValues", {10.0, 250.0})				-- UI | RAM to trigger, Armor Bonus %

	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendary_inline1.startingThreshold", 11.0)				-- 		< RAM to trigger   | Vanilla = 11.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendary_inline4.value", 125.0)							-- 		Armor when Low RAM | Vanilla = 130.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendary_inline5.floatValues", {11.0, 250.0})			-- UI | RAM to trigger, Armor Bonus % 

	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendaryPlus_inline1.startingThreshold", 12.0)			-- 		< RAM to trigger   | Vanilla = 11.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendaryPlus_inline4.value", 137.5)						-- 		Armor when Low RAM | Vanilla = 139.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendaryPlus_inline5.floatValues", {12.0, 250.0})		-- UI | RAM to trigger, Armor Bonus % 

	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendaryPlusPlus_inline1.startingThreshold", 13.0)		-- 		< RAM to trigger   | Vanilla = 13.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendaryPlusPlus_inline4.value", 150.0)					-- 		Armor when Low RAM | Vanilla = 155.0
	TweakDB:SetFlat("Items.AdvancedCogitoFrameLegendaryPlusPlus_inline5.floatValues", {13.0, 250.0})	-- UI | RAM to trigger, Armor Bonus % 

end)
