
registerForEvent('onInit', function()

--  [ EDIT THE VALUES ON THE LEFT | VANILLA VALUES ARE ON THE RIGHT ]
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsCommon_inline19.value", 0.0)	-- Base Armor		  | Vanilla = 14.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsCommon_inline20.value", 10.0)	-- Armor per Tier	  | Vanilla = 8.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsCommon_inline21.value", 5.0)	-- Armor per TierPlus | Vanilla = 8.0

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommon_inline12.minStacks", 10.0)					-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommon_inline12.maxStacks", 30.0)					-- Movement Speed Bonus Max Stacks | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommon_inline12.statPoolStep", 5.0)					-- Movement Speed Bonus Stat Step  | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommon_inline1.floatValues", {30.0, 10.0})			-- UI | Max Stacks, Min Stacks

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommonPlus_inline12.minStacks", 11.0)				-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommonPlus_inline12.maxStacks", 30.0)				-- Movement Speed Bonus Max Stacks | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommonPlus_inline12.statPoolStep", 4.76)				-- Movement Speed Bonus Stat Step  | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommonPlus_inline1.floatValues", {30.0, 11.0})		-- UI | Max Stacks, Min Stacks

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsRare_inline12.minStacks", 11.0)						-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsRare_inline12.maxStacks", 40.0)						-- Movement Speed Bonus Max Stacks | Vanilla = 40.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsRare_inline12.statPoolStep", 3.44)						-- Movement Speed Bonus Stat Step  | Vanilla = 3.333
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsRare_inline1.floatValues", {40.0, 11.0})				-- UI | Max Stacks, Min Stacks

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsRarePlus_inline12.minStacks", 12.0)					-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsRarePlus_inline12.maxStacks", 40.0)					-- Movement Speed Bonus Max Stacks | Vanilla = 40.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsRarePlus_inline12.statPoolStep", 3.57)					-- Movement Speed Bonus Stat Step  | Vanilla = 3.333
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsRarePlus_inline1.floatValues", {40.0, 12.0})			-- UI | Max Stacks, Min Stacks

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsEpic_inline12.minStacks", 12.0)						-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsEpic_inline12.maxStacks", 50.0)						-- Movement Speed Bonus Max Stacks | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsEpic_inline12.statPoolStep", 2.63)						-- Movement Speed Bonus Stat Step  | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsEpic_inline1.floatValues", {50.0, 12.0})				-- UI | Max Stacks, Min Stacks

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsEpicPlus_inline12.minStacks", 13.0)					-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsEpicPlus_inline12.maxStacks", 50.0)					-- Movement Speed Bonus Max Stacks | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsEpicPlus_inline12.statPoolStep", 2.7)					-- Movement Speed Bonus Stat Step  | Vanilla = 2.5
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsEpicPlus_inline1.floatValues", {50.0, 13.0})			-- UI | Max Stacks, Min Stacks

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendary_inline12.minStacks", 13.0)					-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendary_inline12.maxStacks", 60.0)					-- Movement Speed Bonus Max Stacks | Vanilla = 60.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendary_inline12.statPoolStep", 2.12)				-- Movement Speed Bonus Stat Step  | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendary_inline1.floatValues", {60.0, 13.0})			-- UI | Max Stacks, Min Stacks

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendaryPlus_inline12.minStacks", 14.0)				-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendaryPlus_inline12.maxStacks", 60.0)				-- Movement Speed Bonus Max Stacks | Vanilla = 60.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendaryPlus_inline12.statPoolStep", 2.17)			-- Movement Speed Bonus Stat Step  | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendaryPlus_inline1.floatValues", {60.0, 14.0})		-- UI | Max Stacks, Min Stacks

	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendaryPlusPlus_inline12.minStacks", 15.0)			-- Movement Speed Bonus Min Stacks | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendaryPlusPlus_inline12.maxStacks", 60.0)			-- Movement Speed Bonus Max Stacks | Vanilla = 60.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendaryPlusPlus_inline12.statPoolStep", 2.22)		-- Movement Speed Bonus Stat Step  | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsLegendaryPlusPlus_inline1.floatValues", {60.0, 15.0})	-- UI | Max Stacks, Min Stacks

--	Commented out because duration is defined in the LocKey
--	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommon_inline3.value", 20.0)	-- Regen % Per Second | Vanilla = 20.0
--	TweakDB:SetFlat("Items.AdvancedJenkinsTendonsUncommon_inline4.value", 20.0)	-- Decay % Per Second | Vanilla = 20.0
end)
