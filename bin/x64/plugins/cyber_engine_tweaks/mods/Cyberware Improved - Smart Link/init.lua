
registerForEvent('onInit', function()

--  [ EDIT THE VALUES ON THE LEFT | VANILLA VALUES ARE ON THE RIGHT ]
-- RAM Removal
	TweakDB:SetFlat("Items.AdvancedSmartLinkCommon_inline7.localizedDescription", "LocKey#0")	-- LocKey#92412

-- Max RAM
	TweakDB:SetFlat("Items.AdvancedSmartLinkCommon_inline6.value", 0.0)						-- Max RAM | Vanilla = 1.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkCommon_inline7.floatValues", {0.0})				-- UI | None

	TweakDB:SetFlat("Items.AdvancedSmartLinkCommonPlus_inline6.value", 0.5)					-- Max RAM | Vanilla = 1.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkCommonPlus_inline7.floatValues", {0.5})			-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedSmartLinkUncommon_inline6.value", 1.0)					-- Max RAM | Vanilla = 1.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkUncommon_inline7.floatValues", {1.0})			-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedSmartLinkUncommonPlus_inline6.value", 2.0)				-- Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkUncommonPlus_inline7.floatValues", {2.0})		-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedSmartLinkRare_inline11.value", 2.0)						-- Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkRare_inline12.floatValues", {2.0})				-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedSmartLinkRarePlus_inline11.value", 2.0)					-- Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkRarePlus_inline12.floatValues", {2.0})			-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedSmartLinkEpic_inline11.value", 2.0)						-- Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkEpic_inline12.floatValues", {2.0})				-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendary_inline11.value", 2.0)					-- Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendary_inline12.floatValues", {2.0})			-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlus_inline11.value", 2.0)				-- Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlus_inline12.floatValues", {2.0})		-- UI | Max RAM

	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlusPlus_inline11.value", 2.0)			-- Max RAM | Vanilla = 2.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlusPlus_inline12.floatValues", {2.0})	-- UI | Max RAM

-- Target Lock Duration / Crit Damage
	TweakDB:SetFlat("Items.AdvancedSmartLinkRare_inline4.value", 0.1)								-- Un-Lock Duration | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedSmartLinkRare_inline5.value", 0.1)								-- Un-Lock Duration | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedSmartLinkRare_inline6.value", 5.0)								-- Crit Damage      | Vanilla = 5.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkRare_inline7.floatValues", {10.0, 5.0})					-- UI | Un-Lock Duration, Crit Damage

	TweakDB:SetFlat("Items.AdvancedSmartLinkRarePlus_inline4.value", 0.1)							-- Un-Lock Duration | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedSmartLinkRarePlus_inline5.value", 0.1)							-- Un-Lock Duration | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedSmartLinkRarePlus_inline6.value", 7.5)							-- Crit Damage   	| Vanilla = 7.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkRarePlus_inline7.floatValues", {10.0, 7.5})				-- UI | Un-Lock Duration, Crit Damage

	TweakDB:SetFlat("Items.AdvancedSmartLinkEpic_inline4.value", 0.15)								-- Un-Lock Duration | Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedSmartLinkEpic_inline5.value", 0.15)								-- Un-Lock Duration | Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedSmartLinkEpic_inline6.value", 7.5)								-- Crit Damage   	| Vanilla = 7.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkEpic_inline7.floatValues", {15.0, 7.5})					-- UI | Un-Lock Duration, Crit Damage

	TweakDB:SetFlat("Items.AdvancedSmartLinkEpicPlus_inline4.value", 0.15)							-- Un-Lock Duration | Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedSmartLinkEpicPlus_inline5.value", 0.15)							-- Un-Lock Duration | Vanilla = 0.15
	TweakDB:SetFlat("Items.AdvancedSmartLinkEpicPlus_inline6.value", 10.0)							-- Crit Damage   	| Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkEpicPlus_inline7.floatValues", {15.0, 10.0})			-- UI | Un-Lock Duration, Crit Damage

	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendary_inline4.value", 0.2)							-- Un-Lock Duration | Vanilla = 0.2
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendary_inline5.value", 0.2)							-- Un-Lock Duration | Vanilla = 0.2
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendary_inline6.value", 10.0)							-- Crit Damage   	| Vanilla = 10.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendary_inline7.floatValues", {20.0, 10.0})			-- UI | Un-Lock Duration, Crit Damage

	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlus_inline4.value", 0.2)						-- Un-Lock Duration | Vanilla = 0.2
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlus_inline5.value", 0.2)						-- Un-Lock Duration | Vanilla = 0.2
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlus_inline6.value", 12.5)						-- Crit Damage   	| Vanilla = 12.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlus_inline7.floatValues", {20.0, 12.5})		-- UI | Un-Lock Duration, Crit Damage

	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlusPlus_inline4.value", 0.2)					-- Un-Lock Duration | Vanilla = 0.2
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlusPlus_inline5.value", 0.2)					-- Un-Lock Duration | Vanilla = 0.2
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlusPlus_inline6.value", 15.0)					-- Crit Damage   	| Vanilla = 15.0
	TweakDB:SetFlat("Items.AdvancedSmartLinkLegendaryPlusPlus_inline7.floatValues", {20.0, 15.0})	-- UI | Un-Lock Duration, Crit Damage

--	Tattoo: Tyger Claws Dermal Imprint
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooRare_inline2.value", -0.1)								-- Lock Duration | Vanilla = -0.1
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooRare_inline3.value", -0.1)								-- Lock Duration | Vanilla = -0.1
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooRare_inline12.floatValues", {10.0, 20.0})				-- UI | Lock Duration, Targetting Area

	TweakDB:SetFlat("Items.AdvancedYakuzaTattooRarePlus_inline2.value", -0.125)							-- Lock Duration | Vanilla = -0.1
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooRarePlus_inline3.value", -0.125)							-- Lock Duration | Vanilla = -0.1
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooRarePlus_inline12.floatValues", {12.5, 20.0})			-- UI | Lock Duration, Targetting Area

	TweakDB:SetFlat("Items.AdvancedYakuzaTattooEpic_inline2.value", -0.15)								-- Lock Duration | Vanilla = -0.15
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooEpic_inline3.value", -0.15)								-- Lock Duration | Vanilla = -0.15
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooEpic_inline12.floatValues", {15.0, 20.0})				-- UI | Lock Duration, Targetting Area

	TweakDB:SetFlat("Items.AdvancedYakuzaTattooEpicPlus_inline2.value", -0.175)							-- Lock Duration | Vanilla = -0.15
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooEpicPlus_inline3.value", -0.175)							-- Lock Duration | Vanilla = -0.15
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooEpicPlus_inline12.floatValues", {17.5, 20.0})			-- UI | Lock Duration, Targetting Area

	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendary_inline2.value", -0.2)							-- Lock Duration | Vanilla = -0.2
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendary_inline3.value", -0.2)							-- Lock Duration | Vanilla = -0.2
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendary_inline12.floatValues", {20.0, 20.0})			-- UI | Lock Duration, Targetting Area

	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendaryPlus_inline2.value", -0.225)					-- Lock Duration | Vanilla = -0.2
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendaryPlus_inline3.value", -0.225)					-- Lock Duration | Vanilla = -0.2
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendaryPlus_inline12.floatValues", {22.5, 20.0})		-- UI | Lock Duration, Targetting Area

	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendaryPlusPlus_inline2.value", -0.25)					-- Lock Duration | Vanilla = -0.2
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendaryPlusPlus_inline3.value", -0.25)					-- Lock Duration | Vanilla = -0.2
	TweakDB:SetFlat("Items.AdvancedYakuzaTattooLegendaryPlusPlus_inline12.floatValues", {25.0, 20.0})	-- UI | Lock Duration, Targetting Area

end)
