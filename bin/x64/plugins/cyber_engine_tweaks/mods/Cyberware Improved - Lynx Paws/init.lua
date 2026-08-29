
registerForEvent('onInit', function()

--  [ EDIT THE VALUES ON THE LEFT | VANILLA VALUES ARE ON THE RIGHT ]
	TweakDB:SetFlat("Items.AdvancedCatPawsUncommon_inline8.value", 0.0)		-- Base Armor		  | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedCatPawsUncommon_inline9.value", 4.0)		-- Armor per Tier	  | Vanilla = 6.0
	TweakDB:SetFlat("Items.AdvancedCatPawsUncommon_inline10.value", 8.0)	-- Armor per TierPlus | Vanilla = 6.0

	TweakDB:SetFlat("Items.AdvancedCatPawsUncommon_inline12.value", 0.5)	-- Fall Damage Reduction | Vanilla = 0.2

	TweakDB:SetFlat("Items.AdvancedCatPawsUncommon_inline1.value", 0.8)									-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsUncommon_inline4.value", 0.1)									-- Stealth Movement Speed Bonus	 | Vanilla = 0.06
	TweakDB:SetFlat("Items.AdvancedCatPawsUncommon_inline5.floatValues", {20.0, 10.0, 50.0})			-- UI | Noise, Speed, Fall Damage

	TweakDB:SetFlat("Items.AdvancedCatPawsUncommonPlus_inline1.value", 0.8)								-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsUncommonPlus_inline4.value", 0.125)							-- Stealth Movement Speed Bonus	 | Vanilla = 0.06
	TweakDB:SetFlat("Items.AdvancedCatPawsUncommonPlus_inline5.floatValues", {20.0, 12.5, 50.0})		-- UI | Noise, Speed, Fall Damage

	TweakDB:SetFlat("Items.AdvancedCatPawsRare_inline1.value", 0.7)										-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsRare_inline4.value", 0.125)									-- Stealth Movement Speed Bonus	 | Vanilla = 0.08
	TweakDB:SetFlat("Items.AdvancedCatPawsRare_inline5.floatValues", {30.0, 12.5, 50.0})				-- UI | Noise, Speed, Fall Damage

	TweakDB:SetFlat("Items.AdvancedCatPawsRarePlus_inline1.value", 0.7)									-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsRarePlus_inline4.value", 0.15)								-- Stealth Movement Speed Bonus	 | Vanilla = 0.08
	TweakDB:SetFlat("Items.AdvancedCatPawsRarePlus_inline5.floatValues", {30.0, 15.0, 50.0})			-- UI | Noise, Speed, Fall Damage

	TweakDB:SetFlat("Items.AdvancedCatPawsEpic_inline1.value", 0.6)										-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsEpic_inline4.value", 0.15)									-- Stealth Movement Speed Bonus	 | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedCatPawsEpic_inline5.floatValues", {40.0, 15.0, 50.0})				-- UI | Noise, Speed, Fall Damage

	TweakDB:SetFlat("Items.AdvancedCatPawsEpicPlus_inline1.value", 0.6)									-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsEpicPlus_inline4.value", 0.175)								-- Stealth Movement Speed Bonus	 | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedCatPawsEpicPlus_inline5.floatValues", {40.0, 17.5, 50.0})			-- UI | Noise, Speed, Fall Damage

	TweakDB:SetFlat("Items.AdvancedCatPawsLegendary_inline1.value", 0.5)								-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsLegendary_inline4.value", 0.175)								-- Stealth Movement Speed Bonus	 | Vanilla = 0.12
	TweakDB:SetFlat("Items.AdvancedCatPawsLegendary_inline5.floatValues", {50.0, 17.5, 50.0})			-- UI | Noise, Speed, Fall Damage

	TweakDB:SetFlat("Items.AdvancedCatPawsLegendaryPlus_inline1.value", 0.5)							-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsLegendaryPlus_inline4.value", 0.1875)							-- Stealth Movement Speed Bonus	 | Vanilla = 0.12
	TweakDB:SetFlat("Items.AdvancedCatPawsLegendaryPlus_inline5.floatValues", {50.0, 18.75, 50.0})		-- UI | Noise, Speed, Fall Damage

	TweakDB:SetFlat("Items.AdvancedCatPawsLegendaryPlusPlus_inline1.value", 0.5)						-- Movement Noise Multiplier 	 | Vanilla = 0.5
	TweakDB:SetFlat("Items.AdvancedCatPawsLegendaryPlusPlus_inline4.value", 0.2)						-- Stealth Movement Speed Bonus	 | Vanilla = 0.12
	TweakDB:SetFlat("Items.AdvancedCatPawsLegendaryPlusPlus_inline5.floatValues", {50.0, 20.0, 50.0})	-- UI | Noise, Speed, Fall Damage

end)
