-- init
registerForEvent('onInit', function()

	TweakDB:SetFlat("Items.MemoryReplenishmentIconicEpicCooldownEffector_inline2.value", 20.0) -- 10.0 Trigger at value %
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicEpicPlusCooldownEffector_inline2.value", 20.0) -- 10.0 Trigger at value %
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicLegendaryCooldownEffector_inline2.value", 20.0) -- 10.0 Trigger at value %
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicLegendaryPlusCooldownEffector_inline2.value", 20.0) -- 10.0 Trigger at value %
	TweakDB:SetFlat("Items.MemoryReplenishmentIconicLegendaryPlusPlusCooldownEffector_inline2.value", 20.0) -- 10.0 Trigger at value %

	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpic_inline6.statPoolValue", 35.0) -- RAM Recovery | Vanilla = 35.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpic_inline7.intValues", 20, 35) -- UI

	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpicPlus_inline2.statPoolValue", 37.5) -- RAM Recovery | Vanilla = 38.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerEpicPlus_inline3.intValues", 20, 37) -- UI

	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendary_inline2.statPoolValue", 40.0) -- RAM Recovery | Vanilla = 40.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendary_inline3.intValues", 20, 40) -- UI

	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlus_1_inline2.statPoolValue", 42.5) -- RAM Recovery | Vanilla = 42.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlus_1_inline3.intValues", 20, 42) -- UI

	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlusPlus_inline2.statPoolValue", 45.0) -- RAM Recovery | Vanilla = 45.0
	TweakDB:SetFlat("Items.IconicCamilloRamManagerLegendaryPlusPlus_inline3.intValues", 20, 45) -- UI

    print('Cyberware Improved - RAM Reallocator: Initialized')
end)
