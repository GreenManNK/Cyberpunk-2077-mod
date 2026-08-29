
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.AdvancedT1000Common_inline5.value", -10.0) 	-- Base Armor | Vanilla = -30.0
	TweakDB:SetFlat("Items.AdvancedT1000Common_inline6.value", 10.0) 	-- Armor gained per tier | Vanilla = 30.0
	TweakDB:SetFlat("Items.AdvancedT1000Common_inline7.value", 10.0) 	-- Armor gained per tier plus | Vanilla = 30.0

	TweakDB:SetFlat("Items.AdvancedT1000Rare_inline1.value", 0.15)					-- 		Armor multipler | Vanilla = 0.08
	TweakDB:SetFlat("Items.AdvancedT1000Rare_inline2.floatValues", {15.0})			-- UI | Armor multipler 
	TweakDB:SetFlat("Items.AdvancedT1000Rare2_inline1.value", 0.175)				-- 		Perk Bonus | Armor multipler | Vanilla = 0.09
	TweakDB:SetFlat("Items.AdvancedT1000Rare2_inline2.floatValues", {17.5})			-- UI | Perk Bonus | Armor multipler 

	TweakDB:SetFlat("Items.AdvancedT1000Epic_inline1.value", 0.175)					-- 		Armor multipler | Vanilla = 0.1
	TweakDB:SetFlat("Items.AdvancedT1000Epic_inline2.floatValues", {17.5})			-- UI | Armor multipler
	TweakDB:SetFlat("Items.AdvancedT1000Epic2_inline1.value", 0.2)					-- 		Perk Bonus | Armor multipler | Vanilla = 0.11
	TweakDB:SetFlat("Items.AdvancedT1000Epic2_inline2.floatValues", {20.0})			-- UI | Perk Bonus | Armor multipler

	TweakDB:SetFlat("Items.AdvancedT1000Legendary_inline1.value", 0.2)				-- 		Armor multipler | Vanilla = 0.12
	TweakDB:SetFlat("Items.AdvancedT1000Legendary_inline2.floatValues", {20.0})		-- UI | Armor multipler
	TweakDB:SetFlat("Items.AdvancedT1000Legendary2_inline1.value", 0.225)			-- 		Perk Bonus | Armor multipler | Vanilla = 0.13
	TweakDB:SetFlat("Items.AdvancedT1000Legendary2_inline2.floatValues", {22.5})	-- UI | Perk Bonus | Armor multipler

--	Iconic
	TweakDB:SetFlat("Items.IconicAdvancedT1000Rare_inline1.value", 0.25)						-- 		Armor multipler | Vanilla = 0.25
	TweakDB:SetFlat("Items.IconicAdvancedT1000Rare_inline2.floatValues", {25.0})				-- UI | Armor multipler
	TweakDB:SetFlat("Items.IconicAdvancedT1000Rare2_inline1.value", 0.275)						-- 		Perk Bonus | Armor multipler | Vanilla = 0.27
	TweakDB:SetFlat("Items.IconicAdvancedT1000Rare2_inline2.floatValues", {27.5})				-- UI | Perk Bonus | Armor multipler

	TweakDB:SetFlat("Items.IconicAdvancedT1000RarePlus_inline1.value", 0.275)					-- 		Armor multipler | Vanilla = 0.28
	TweakDB:SetFlat("Items.IconicAdvancedT1000RarePlus_inline2.floatValues", {27.5})			-- UI | Armor multipler
	TweakDB:SetFlat("Items.IconicAdvancedT1000Rare2Plus_inline1.value", 0.3)					-- 		Perk Bonus | Armor multipler | Vanilla = 0.3
	TweakDB:SetFlat("Items.IconicAdvancedT1000Rare2Plus_inline2.floatValues", {30.0})			-- UI | Perk Bonus | Armor multipler

	TweakDB:SetFlat("Items.IconicAdvancedT1000Epic_inline1.value", 0.3)							-- 		Armor multipler | Vanilla = 0.31
	TweakDB:SetFlat("Items.IconicAdvancedT1000Epic_inline2.floatValues", {30.0})				-- UI | Armor multipler
	TweakDB:SetFlat("Items.IconicAdvancedT1000Epic2_inline1.value", 0.325)						-- 		Perk Bonus | Armor multipler | Vanilla = 0.33
	TweakDB:SetFlat("Items.IconicAdvancedT1000Epic2_inline2.floatValues", {32.5})				-- UI | Perk Bonus | Armor multipler

	TweakDB:SetFlat("Items.IconicAdvancedT1000EpicPlus_inline1.value", 0.325)					-- 		Armor multipler | Vanilla = 0.32
	TweakDB:SetFlat("Items.IconicAdvancedT1000EpicPlus_inline2.floatValues", {32.5})			-- UI | Armor multipler
	TweakDB:SetFlat("Items.IconicAdvancedT1000Epic2Plus_inline1.value", 0.35)					-- 		Perk Bonus | Armor multipler | Vanilla = 0.34
	TweakDB:SetFlat("Items.IconicAdvancedT1000Epic2Plus_inline2.floatValues", {35.0})			-- UI | Perk Bonus | Armor multipler

	TweakDB:SetFlat("Items.IconicAdvancedT1000Legendary_inline1.value", 0.35)					-- 		Armor multipler | Vanilla = 0.35
	TweakDB:SetFlat("Items.IconicAdvancedT1000Legendary_inline2.floatValues", {35.0})			-- UI | Armor multipler
	TweakDB:SetFlat("Items.IconicAdvancedT1000Legendary2_inline1.value", 0.375)					-- 		Perk Bonus | Armor multipler | Vanilla = 0.37
	TweakDB:SetFlat("Items.IconicAdvancedT1000Legendary2_inline2.floatValues", {37.5})			-- UI | Perk Bonus | Armor multipler

	TweakDB:SetFlat("Items.IconicAdvancedT1000LegendaryPlus_inline1.value", 0.375)				-- 		Armor multipler | Vanilla = 0.37
	TweakDB:SetFlat("Items.IconicAdvancedT1000LegendaryPlus_inline2.floatValues", {37.5})		-- UI | Armor multipler
	TweakDB:SetFlat("Items.IconicAdvancedT1000Legendary2Plus_inline1.value", 0.4)				-- 		Perk Bonus | Armor multipler | Vanilla = 0.39
	TweakDB:SetFlat("Items.IconicAdvancedT1000Legendary2Plus_inline2.floatValues", {40.0})		-- UI | Perk Bonus | Armor multipler

	TweakDB:SetFlat("Items.IconicAdvancedT1000LegendaryPlusPlus_inline1.value", 0.4)			-- 		Armor multipler | Vanilla = 0.4
	TweakDB:SetFlat("Items.IconicAdvancedT1000LegendaryPlusPlus_inline2.floatValues", {40.0})	-- UI | Armor multipler
	TweakDB:SetFlat("Items.IconicAdvancedT1000Legendary2PlusPlus_inline1.value", 0.425)			-- 		Perk Bonus | Armor multipler | Vanilla = 0.42
	TweakDB:SetFlat("Items.IconicAdvancedT1000Legendary2PlusPlus_inline2.floatValues", {42.5})	-- UI | Perk Bonus | Armor multipler

end)
