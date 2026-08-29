
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedSuddenAidCommon_inline13.value", 10.0)		-- Base Armor	 	  | Vanilla = 17.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidCommon_inline14.value", 10.0)		-- Armor per Tier	  | Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidCommon_inline15.value", 10.0)		-- Armor per TierPlus | Vanilla = 10.0

	TweakDB:SetFlat("BaseStatusEffect.SuddenAidBuff_inline3.value", 4.0)		-- Mitigation Duration | Vanilla = 4.0
	TweakDB:SetFlat("BaseStatusEffect.SuddenAidBuff_inline9.value", 6.0)		-- Cooldown? | Vanilla = 6.0
	TweakDB:SetFlat("BaseStatusEffect.SuddenAidCooldown_inline3.value", 5.0)	-- Cooldown? | Vanilla = 5.0

	TweakDB:SetFlat("Items.AdvancedSuddenAidCommon_inline4.valueToCheck", 35.0)						-- 		Hp to lose % 		| Vanilla = 35.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidCommon_inline4.timeFrame", 3.0)							-- 		Hp to lose Duration | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidCommon_inline7.value", 30.0)							-- 		Mitigation Chance   | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidCommon_inline8.floatValues", {35.0, 3.0, 30.0, 4.0})	-- UI | Hp lose %, Hp lose Duration, Miti Chance, Miti Duration
	TweakDB:SetFlat("Items.AdvancedSuddenAidCommon_inline10.floatValues", {6.0})					-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedSuddenAidUncommon_inline4.valueToCheck", 35.0)					-- 		Hp to lose % 		| Vanilla = 35.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidUncommon_inline4.timeFrame", 3.25)						-- 		Hp to lose Duration | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidUncommon_inline7.value", 35.0)							-- 		Mitigation Chance   | Vanilla = 35.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidUncommon_inline8.floatValues", {35.0, 3.25, 35.0, 4.0})	-- UI | Hp lose %, Hp lose Duration, Miti Chance, Miti Duration
	TweakDB:SetFlat("Items.AdvancedSuddenAidUncommon_inline10.floatValues", {6.0})					-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedSuddenAidRare_inline4.valueToCheck", 35.0)						-- 		Hp to lose % 		| Vanilla = 35.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidRare_inline4.timeFrame", 3.5)							-- 		Hp to lose Duration | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidRare_inline7.value", 40.0)								-- 		Mitigation Chance   | Vanilla = 40.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidRare_inline8.floatValues", {35.0, 3.5, 40.0, 4.0})		-- UI | Hp lose %, Hp lose Duration, Miti Chance, Miti Duration
	TweakDB:SetFlat("Items.AdvancedSuddenAidRare_inline10.floatValues", {6.0})						-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedSuddenAidEpic_inline4.valueToCheck", 35.0)						-- 		Hp to lose % 		| Vanilla = 35.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidEpic_inline4.timeFrame", 3.75)							-- 		Hp to lose Duration | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidEpic_inline7.value", 45.0)								-- 		Mitigation Chance   | Vanilla = 45.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidEpic_inline8.floatValues", {35.0, 3.75, 45.0, 4.0})		-- UI | Hp lose %, Hp lose Duration, Miti Chance, Miti Duration
	TweakDB:SetFlat("Items.AdvancedSuddenAidEpic_inline10.floatValues", {6.0})						-- UI | Cooldown

	TweakDB:SetFlat("Items.AdvancedSuddenAidLegendary_inline4.valueToCheck", 35.0)					-- 		Hp to lose %		| Vanilla = 35.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidLegendary_inline4.timeFrame", 4.0)						-- 		Hp to lose Duration | Vanilla = 3.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidLegendary_inline7.value", 50.0)							-- 		Mitigation Chance   | Vanilla = 50.0
	TweakDB:SetFlat("Items.AdvancedSuddenAidLegendary_inline8.floatValues", {35.0, 4.0, 50.0, 4.0})	-- UI | Hp lose %, Hp lose Duration, Miti Chance, Miti Duration
	TweakDB:SetFlat("Items.AdvancedSuddenAidLegendary_inline10.floatValues", {6.0})					-- UI | Cooldown

end)
