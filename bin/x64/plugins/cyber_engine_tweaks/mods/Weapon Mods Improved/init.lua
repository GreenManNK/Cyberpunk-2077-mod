-- init
registerForEvent('onInit', function()
-- Any Weapon
--	Pax | Tier 1 to 5
	TweakDB:SetFlat("Items.GenericMod1_Base_inline6.value", 1.2)				-- Damage outside of combat | Vanilla = 1.2
	TweakDB:SetFlat("Items.GenericMod1_LowTier_inline1.floatValues", {20.0})	-- UI | T1-4 | Damage outside of combat | Vanilla = 20.0
	TweakDB:SetFlat("Items.GenericMod1_HighTier_inline1.floatValues", {20.0})	-- UI |  T5  | Damage outside of combat | Vanilla = 20.0

	TweakDB:SetFlat("Items.GenericMod1_Base_inline0.value", -10.0)				-- Base Damage 			  | Vanilla = -10.0	| This + below value x value below that = UI
	TweakDB:SetFlat("Items.GenericMod1_Base_inline1.value", 2.5)				-- Damage gained per tier | Vanilla = 2.5	| Because
	TweakDB:SetFlat("Items.GenericMod1_Base_inline2.value", -1.0)				-- UI 					  | Vanilla = -1.0 	| Reasons

-- Ranged Weapon Only
--	Better Half | Tier 4 to 5
	TweakDB:SetFlat("Effectors.RangedMod1_CritEffector_inline3.ratioToCompare", 0.5)	-- Mag Capacity to trigger | Vanilla = 0.5	| under 50%, trigger the below bonuses

	TweakDB:SetFlat("Items.RangedMod1_Base_inline0.value", 10.0)						-- Crit Chance 	  | Vanilla = 10.0 | This + below value = Legendary Stat
	TweakDB:SetFlat("Items.RangedMod1_Legendary_inline0.value", 10.0)					-- Crit Chance T5 | Vanilla = 10.0

--	Shuffler | Tier 1 to 5 | Reload Time is handled by curve multipliers
	TweakDB:SetFlat("Items.RangedMod2_Base_inline0.value", 0.10)						-- Mag auto fill | Vanilla = 0.15
	TweakDB:SetFlat("Items.RangedMod2_Base_inline1.value", 0.10)						-- Mag auto fill per tier | Vanilla = 0.05

	TweakDB:SetFlat("Items.RangedMod2_Base_inline2.value", -0.25)						-- Equip Duration | Vanilla = -0.2
	TweakDB:SetFlat("Items.RangedMod2_Base_inline3.value", -0.25)						-- Unequip Duration | Vanilla = -0.2
	TweakDB:SetFlat("Items.RangedMod2_Base_inline6.floatValues", {25.0})				-- UI | Weapon Swap Speed | Vanilla = 20.0

--	Equalizer | Tier 1 to 5
	TweakDB:SetFlat("Items.RangedMod3_Base_inline0.value", 5.0)		-- Bonus damage against Elites | Vanilla = 4.0 | Why can't everything be this simple?
	TweakDB:SetFlat("Items.RangedMod3_Base_inline1.value", 5.0)		-- Bonus damage against Elites per tier | Vanilla = 4.0

-- AR/SMG/LMG Only
--	Big Mag | Tier 1 to 5
	TweakDB:SetFlat("Items.ARSMGLMGMod1_Base_inline0.value", 0.1)		-- Mag capacity bonus | Vanilla = 0.15
	TweakDB:SetFlat("Items.ARSMGLMGMod1_Base_inline1.value", 0.1)		-- Mag capacity bonus per tier | Vanilla = 0.1

	TweakDB:SetFlat("Items.ARSMGLMGMod1_Base_inline2.value", 0.1)		-- Reload time reduction | Vanilla = 0.2

--	Ready Steady | Tier 1 to 5
--	TweakDB:SetFlat("Items.ARSMGLMGMod2_Base_inline4.value", 1.0)			-- Horizontal Recoil | Vanilla = 1.0 | 100% Horizontal Recoil for T1 TO T4
--	TweakDB:SetFlat("Items.ARSMGLMGMod2_Base_HighTier_inline0.value", 0.0)	-- Horizontal Recoil | Vanilla = 0.0 |   0% Horizontal Recoil for T5

	TweakDB:SetFlat("Items.ARSMGLMGMod2_Base_inline0.value", 5.0)			-- Recoil Kick reduction | Vanilla = 3.0
	TweakDB:SetFlat("Items.ARSMGLMGMod2_Base_inline1.value", 5.0)			-- Recoil Kick reduction per tier | Vanilla = 3.0
	TweakDB:SetFlat("Items.ARSMGLMGMod2_Base_inline2.value", 5.0)			-- Recoil Kick reduction from cover | Vanilla = 7.0
	TweakDB:SetFlat("Items.ARSMGLMGMod2_Base_inline3.value", 5.0)			-- Recoil Kick reduction from cover per tier | Vanilla = 7.0

--	Focus Fire | Tier 1 to 5
	TweakDB:SetFlat("Items.ARSMGLMGMod3_Base_inline0.value", 10.0)				-- Hipfire Spread Reduction | Vanilla = 20.0
	TweakDB:SetFlat("Items.ARSMGLMGMod3_Base_inline1.value", 10.0)				-- Hipfire Spread Reduction per tier | Vanilla = 5.0

	TweakDB:SetFlat("Items.ARSMGLMGMod3_Base_inline2.value", -0.1)				-- Effective Range | Vanilla = -0.3
	TweakDB:SetFlat("Items.ARSMGLMGMod3_Base_inline11.floatValues", {10.0})		-- UI | Effective Range | Vanilla = 30.0

-- Pistol/Revolver Only
--	Pinpoint | Tier 1 to 5
	TweakDB:SetFlat("BaseStatusEffect.HGMod1_Buff_inline4.value", 10.0)			-- Stack duration | Vanilla = 5.0 | seconds

	TweakDB:SetFlat("Items.HGMod1_Base_inline6.value", 5.0)						-- Bullet Spread Reduction | Vanilla = 4.0
	TweakDB:SetFlat("Items.HGMod1_Base_inline7.value", 1.25)					-- Bullet Spread Reduction per tier | Vanilla = 0.5

	TweakDB:SetFlat("Items.HGMod1_Common_inline1.floatValues", {5.0, 10.0})		-- UI | Bullet Spread Reduction, Duration | Vanilla = 4.0, 5.0
	TweakDB:SetFlat("Items.HGMod1_Uncommon_inline1.floatValues", {6.25, 10.0})	-- UI | Bullet Spread Reduction, Duration | Vanilla = 4.5, 5.0
	TweakDB:SetFlat("Items.HGMod1_Rare_inline1.floatValues", {7.5, 10.0})		-- UI | Bullet Spread Reduction, Duration | Vanilla = 5.0, 5.0
	TweakDB:SetFlat("Items.HGMod1_Epic_inline1.floatValues", {8.75, 10.0})		-- UI | Bullet Spread Reduction, Duration | Vanilla = 5.5, 5.0
	TweakDB:SetFlat("Items.HGMod1_Legendary_inline1.floatValues", {10.0, 10.0})	-- UI | Bullet Spread Reduction, Duration | Vanilla = 6.0, 5.0

--	Zenith | Tier 1 to 5 | Everything except duration is handled by curve multipliers, there's literally no consistency.
	TweakDB:SetFlat("BaseStatusEffect.HGMod2_EquipBuff_inline2.value", 7.5)		-- Duration | Vanilla = 5.0 | seconds
	TweakDB:SetFlat("Items.HGMod2_Base_inline5.floatValues", {7.5})				-- UI | Duration | Vanilla = 5.0

--	Parallax | Tier 1 to 5
	TweakDB:SetFlat("Items.HGMod3_Base_LowTier_inline0.value", 12.5)		-- Effective Range | Vanilla = 11.0
	TweakDB:SetFlat("Items.HGMod3_Base_LowTier_inline1.value", 12.5)		-- Effective Range per tier | Vanilla = 8.0

	TweakDB:SetFlat("Items.HGMod3_Base_LowTier_inline2.value", 12.5)		-- Weapon Sway Reduction | Vanilla = 12.5
	TweakDB:SetFlat("Items.HGMod3_Base_LowTier_inline3.value", 12.5)		-- Weapon Sway Reduction per tier | Vanilla = 12.5

-- Shotgun Only
--	Vivisector | Tier 1 to 5 | Needed fixing, as it stacks with Kneel, also stacks with itself.
	TweakDB:SetFlat("BaseStatusEffect.ShotgunMod1_Buff_inline6.value", 1.25)	-- Torso Damage Bonus | Vanilla = 1.25
	TweakDB:SetFlat("Items.ShotgunMod1_Base_inline10.floatValues", {25.0})		-- UI | Torso Damage Bonus | Vanilla = 25.0

	TweakDB:SetFlat("Items.ShotgunMod1_Base_inline1.value", 5.0)				-- Torso Damage Bonus Duration | Vanilla = 3.0
	TweakDB:SetFlat("Items.ShotgunMod1_Base_inline2.value", 2.5)				-- Torso Damage Bonus Duration per tier | Vanilla = 0.5

	TweakDB:SetFlat("Items.ShotgunMod1_Base_inline3.value", 25.0)				-- Dismemberment chance | Vanilla = 20.0
	TweakDB:SetFlat("Items.ShotgunMod1_Base_inline4.value", 5.0)				-- Dismemberment chance per tier | Vanilla = 20.0

--	Kneel | Tier 5 | Remove the comments if you want to modify
--	TweakDB:SetFlat("BaseStatusEffect.ShotgunMod2_LeftLeg_inline8.dismembermentChance", 0.25)	-- Dismemberment & Inta-Kill Chance | Vanilla = 0.25
--	TweakDB:SetFlat("BaseStatusEffect.ShotgunMod2_RightLeg_inline8.dismembermentChance", 0.25)	-- Dismemberment & Inta-Kill Chance | Vanilla = 0.25
--	TweakDB:SetFlat("Items.ShotgunMod2_Base_inline12.floatValues", {25.0})						-- UI | Vanilla = 25.0

--	Condenser | Tier 1 to 5 | Handled by curve multipliers.

-- Sniper/Precision Rifle Only
--	Stabilizer | Tier 1 to 5 | Handled by curve multipliers.

--	Headtoll | Tier 1 to 5
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_Buff_inline8.value", 15.0)			-- Duration | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Base_inline10.floatValues", {15.0, 15.0})		-- UI | Duration, Unknown | Vanilla = 8.0, 15.0 | Fixes UI bug

	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_Kill_inline5.value", -0.25)			-- Fire Rate | Vanilla = -0.15
	TweakDB:SetFlat("Items.PRSRMod2_Common_inline5.floatValues", {25.0})			-- UI | Fire Rate | Vanilla = 15.0

	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_DoubleKill_inline3.value", -0.25)	-- Fire Rate | Vanilla = -0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_DoubleKill_inline4.value", -0.25)	-- Reload speed | Vanilla = -0.15
	TweakDB:SetFlat("Items.PRSRMod2_Uncommon_inline9.floatValues", {25.0})			-- UI | Fire Rate | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Uncommon_inline11.floatValues", {25.0})			-- UI | Reload speed | Vanilla = 15.0

	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_TrippleKill_inline4.value", -0.25)	-- Fire Rate | Vanilla = -0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_TrippleKill_inline5.value", -0.25)	-- Reload speed | Vanilla = -0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_TrippleKill_inline1.value", 0.25)	-- Move speed bonus | Vanilla = 0.15
	TweakDB:SetFlat("Items.PRSRMod2_Rare_inline11.floatValues", {25.0})				-- UI | Fire Rate | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Rare_inline13.floatValues", {25.0})				-- UI | Reload speed | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Rare_inline15.floatValues", {25.0})				-- UI | Move speed | Vanilla = 15.0

	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_QuadraKill_inline4.value", -0.25)	-- Fire Rate | Vanilla = -0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_QuadraKill_inline5.value", -0.25)	-- Reload speed | Vanilla = -0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_QuadraKill_inline1.value", 0.25)		-- Move speed bonus | Vanilla = 0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_QuadraKill_inline6.value", 25.0)		-- Crit Chance | Vanilla = 25.0
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_QuadraKill_inline7.value", 25.0)		-- Crit Damage | Vanilla = 25.0
	TweakDB:SetFlat("Items.PRSRMod2_Epic_inline13.floatValues", {25.0})				-- UI | Fire Rate | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Epic_inline15.floatValues", {25.0})				-- UI | Reload speed | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Epic_inline17.floatValues", {25.0})				-- UI | Move speed | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Epic_inline19.floatValues", {25.0, 25.0})		-- UI | Crit chance, Crit damage | Vanilla = 25.0, 25.0

	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_PentaKill_inline4.value", -0.25)		-- Fire Rate | Vanilla = -0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_PentaKill_inline5.value", -0.25)		-- Reload Time | Vanilla = -0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_PentaKill_inline1.value", 0.25)		-- Move speed bonus | Vanilla = 0.15
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_PentaKill_inline6.value", 25.0)		-- Crit Chance | Vanilla = 25.0
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_PentaKill_inline7.value", 25.0)		-- Crit Damage | Vanilla = 25.0
	TweakDB:SetFlat("BaseStatusEffect.PRSRMod2_PentaKill_inline10.value", 25.0)		-- Max Hp | Vanilla = 10.0
	TweakDB:SetFlat("Items.PRSRMod2_Legendary_inline13.floatValues", {25.0})		-- UI | Fire Rate | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Legendary_inline15.floatValues", {25.0})		-- UI | Reload speed | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Legendary_inline17.floatValues", {25.0})		-- UI | Move speed | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod2_Legendary_inline19.floatValues", {25.0, 25.0})	-- UI | Crit chance, Crit damage | Vanilla = 25.0, 25.0
	TweakDB:SetFlat("Items.PRSRMod2_Legendary_inline21.floatValues", {25.0})		-- UI | Max Hp | Vanilla = 10.0

--	Fleetshot | Tier 1 to 5 | Armor Pen is handled by curve multipliers
--	TweakDB:SetFlat("Items.PRSRMod3_Base_inline7.statType", "BaseStats.CycleTime_BurstModifier")	-- Stat Type | Vanilla = "BaseStats.ArmorPenetrationBonus" | Remove Armor Penetration Reduction

	TweakDB:SetFlat("Items.PRSRMod3_Base_inline0.value", 30.0)										-- Stamina cost reduction | Vanilla = 15.0
	TweakDB:SetFlat("Items.PRSRMod3_Base_inline1.value", 5.0)										-- Stamina cost reduction per tier | Vanilla = 5.0

-- Power Weapon Only
--	Pyro | Tier 1 to 5 | Converted damage is handled by curve multipliers
	TweakDB:SetFlat("Items.PowerMod1_Base_inline0.value", 5.0)		-- Burn chance | Vanilla = 3.0
	TweakDB:SetFlat("Items.PowerMod1_Base_inline1.value", 2.5)		-- Burn chance per tier | Vanilla = 3.0

	TweakDB:SetFlat("Items.PowerMod1_Common_inline3.floatValues", {50.0})		-- UI | Converted Damage | Vanilla = 15.0
	TweakDB:SetFlat("Items.PowerMod1_Uncommon_inline5.floatValues", {50.0})		-- UI | Converted Damage | Vanilla = 20.0
	TweakDB:SetFlat("Items.PowerMod1_Rare_inline5.floatValues", {50.0})			-- UI | Converted Damage | Vanilla = 25.0
	TweakDB:SetFlat("Items.PowerMod1_Epic_inline5.floatValues", {50.0})			-- UI | Converted Damage | Vanilla = 30.0
	TweakDB:SetFlat("Items.PowerMod1_Legendary_inline3.floatValues", {50.0})	-- UI | Converted Damage | Vanilla = 50.0 | UI bug

--	Swiss Cheese | Tier 2 to 5 | Handled by curve multipliers

--	Critochet | Tier 1 to 5
	TweakDB:SetFlat("Items.PowerMod3_Base_inline0.value", 0.15)			-- Ricochet crit chance | Vanilla = 0.1
	TweakDB:SetFlat("Items.PowerMod3_Base_inline1.value", 0.025)		-- Ricochet crit chance per tier | Vanilla = 0.05

-- Smart Weapon Only
--	Headhopper | Tier 4 to 5 | Lock on speed handled by curve multipliers
	TweakDB:SetFlat("Items.SmartMod1_Base_inline1.value", 1.0)		-- Bonus lock-on targets | Vanilla = 1.0
	TweakDB:SetFlat("Items.SmartMod1_Base_inline3.value", 0.1)		-- Bonus headshot damage | Vanilla = 0.1
	TweakDB:SetFlat("Items.SmartMod1_Legendary_inline0.value", 1.0)	-- Bonus lock-on targets | Vanilla = 1.0
	TweakDB:SetFlat("Items.SmartMod1_Legendary_inline1.value", 0.1)	-- Bonus headshot damage | Vanilla = 0.1

--	Gambiteer | Tier 1 to 5 | Armor pen handled by curve multipliers
	TweakDB:SetFlat("Items.SmartMod2_Base_inline0.value", -0.1)			-- Smart-Lock hit probability | Vanilla = -0.1
	TweakDB:SetFlat("Items.SmartMod2_Base_inline6.floatValues", {10.0})	-- UI | Smart-Lock hit probability | Vanilla = 20.0 | Fixed UI bug

	TweakDB:SetFlat("Items.SmartMod2_Base_inline1.value", 10.0)			-- Bullet velocity | Vanilla = 20.0
	TweakDB:SetFlat("Items.SmartMod2_Base_inline2.value", 10.0)			-- Bullet velocity per tier | Vanilla = 7.5

--	Panorama | Tier 1 to 5 | Initial Lock-on Time handled by curve multipliers
	TweakDB:SetFlat("Items.SmartMod3_Base_inline0.value", 10.0)		-- Smart Zone size | Vanilla = 10.0
	TweakDB:SetFlat("Items.SmartMod3_Base_inline1.value", 2.5)		-- Smart Zone size per tier | Vanilla = 2.5

	TweakDB:SetFlat("Items.SmartMod3_Base_inline11.value", 0.1)		-- Bonus lock-on time | Vanilla = 0.1
	TweakDB:SetFlat("Items.SmartMod3_Base_inline13.value", 0.1)		-- Bonus lock-on time | Vanilla = 0.1
	TweakDB:SetFlat("Items.SmartMod3_Base_inline12.value", 0.1)		-- Bonus lock-on time per tier | Vanilla = 0.05
	TweakDB:SetFlat("Items.SmartMod3_Base_inline14.value", 0.1)		-- Bonus lock-on time per tier | Vanilla = 0.05

-- Tech Weapon Only
--	Wallpuncher | Tier 5
	TweakDB:SetFlat("Items.ChimeraTechMod_inline4.value", 0.5)				-- Charge Time 	   | Vanilla = 0.5	| Use math to keep the charge time normal
	TweakDB:SetFlat("Items.ChimeraTechMod_inline5.value", 2.0)				-- Charge Capacity | Vanilla = 2.0	| 		if changing these values

	TweakDB:SetFlat("Items.ChimeraTechMod_inline7.value", 0.50)				-- Armor pen | Vanilla = 1.0

	TweakDB:SetFlat("Items.ChimeraTechMod_inline12.intValues", {200, 50})	-- UI | Charge Capacity, Armor pen | Vanilla = 200, 100

--	Spinetickler | Tier 1 to 5
	TweakDB:SetFlat("Items.TechMod1_Base_inline0.value", 10.0)		-- EMP chance | Vanilla = 10.0
	TweakDB:SetFlat("Items.TechMod1_Base_inline1.value", 10.0)		-- EMP chance per tier | Vanilla = 10.0

--	C-Thru | Tier 1 to 5 | Handled by curve multipliers
	TweakDB:SetFlat("Items.TechMod2_Common_inline3.floatValues", {15.0, 15.0})		-- UI | Charge Threshhold, Damage Penalty Ignored | Vanilla = 15.0, 15.0
	TweakDB:SetFlat("Items.TechMod2_Uncommon_inline5.floatValues", {17.5, 17.5})	-- UI | Charge Threshhold, Damage Penalty Ignored | Vanilla = 20.0, 15.0
	TweakDB:SetFlat("Items.TechMod2_Rare_inline5.floatValues", {20.0, 20.0})		-- UI | Charge Threshhold, Damage Penalty Ignored | Vanilla = 20.0, 20.0
	TweakDB:SetFlat("Items.TechMod2_Epic_inline5.floatValues", {22.5, 22.5})		-- UI | Charge Threshhold, Damage Penalty Ignored | Vanilla = 25.0, 20.0
	TweakDB:SetFlat("Items.TechMod2_Legendary_inline3.floatValues", {25.0, 25.0})	-- UI | Charge Threshhold, Damage Penalty Ignored | Vanilla = 25.0, 25.0

--	Supercharger | Tier 1 to 5
	TweakDB:SetFlat("Items.TechMod3_Base_inline3.value", -0.05)		-- Armor pen | Vanilla = -0.15

	TweakDB:SetFlat("Items.TechMod3_Base_inline0.value", 15.0)		-- Charge Speed | Vanilla = 10.0
	TweakDB:SetFlat("Items.TechMod3_Base_inline1.value", 2.5)		-- Charge Speed per tier | Vanilla = 2.5

	TweakDB:SetFlat("Items.TechMod3_Base_inline4.value", 15.0)		-- Stamina cost reduction | Vanilla = 4.0
	TweakDB:SetFlat("Items.TechMod3_Base_inline5.value", 2.5)		-- Stamina cost reduction per tier | Vanilla = 4.0

-- Melee Weapon Only
--	Severance | Tier 5
	TweakDB:SetFlat("Prereqs.ChimeraMeleeMod_Prereq_inline2.valueToCheck", 50.0)						-- Hp trigger threshold | Vanilla = 50.0 | Less than or equal to

	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_HeadBlade_inline1.dismembermentChance", 0.25)		-- Head, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_HeadBlunt_inline1.dismembermentChance", 0.25)		-- Head, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_LeftArmBlade_inline1.dismembermentChance", 0.25)	--  Arm, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_LeftArmBlunt_inline1.dismembermentChance", 0.25)	--  Arm, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_RightLegBlade_inline1.dismembermentChance", 0.25)	--  Arm, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_RightLegBlunt_inline1.dismembermentChance", 0.25)	--  Arm, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_LeftLegBlade_inline3.dismembermentChance", 0.25)	--  Leg, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_LeftLegBlunt_inline3.dismembermentChance", 0.25)	--  Leg, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_RightLegBlade_inline1.dismembermentChance", 0.25)	--  Leg, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("BaseStatusEffect.ChimeraMeleeMod_RightLegBlunt_inline1.dismembermentChance", 0.25)	--  Leg, Dismemberment/Insta kill chance | Vanilla = 0.2

	TweakDB:SetFlat("Effectors.ChimeraMeleeMod_BladeDismemberEffector.dismembermentChance", 0.25)		-- ????, Dismemberment/Insta kill chance | Vanilla = 0.2
	TweakDB:SetFlat("Effectors.ChimeraMeleeMod_BluntDismemberEffector.dismembermentChance", 0.25)		-- ????, Dismemberment/Insta kill chance | Vanilla = 0.2

	TweakDB:SetFlat("Items.ChimeraMeleeMod_inline9.intValues", {50, 25})								-- UI | Hp trigger threshold, Chance to trigger |Vanilla = 50, 20

--	Airstrike | Tier 1 to 5 | Handled by curve multipliers

--	Cyclone | Tier 1 to 5
	TweakDB:SetFlat("Items.MeleeMod2_Base_inline0.value", 3.0)							-- Combo Duration | Vanilla = 2.0 | seconds
	TweakDB:SetFlat("Items.MeleeMod2_Base_inline1.value", 0.25)							-- Combo Duration per tier | Vanilla = 0.5 | seconds

	TweakDB:SetFlat("BaseStatusEffect.MeleeMod2_AttackSpeedBuff_inline8.value", 0.05)	-- Attack speed bonus | Vanilla = 0.05 
	TweakDB:SetFlat("BaseStatusEffect.MeleeMod2_AttackSpeedBuff_inline3.value", 2.5)	-- Attack speed bonus duration | Vanilla = 2.0 | seconds
	TweakDB:SetFlat("Items.MeleeMod2_Base_inline19.floatValues", {5.0, 2.5})			-- UI | Attack speed bonus, Attack speed bonus duration | Vanilla = 5.0, 2.0

--	Silencio | Tier 1 to 5 | Handled by curve multipliers

-- Blade Weapon Only
--	Bleedout | Tier 1 to 5
	TweakDB:SetFlat("Items.BladeMod1_Base_inline0.value", 20.0)	-- Bleeding crit chance | Vanilla = 20.0
	TweakDB:SetFlat("Items.BladeMod1_Base_inline1.value", 20.0)	-- Bleeding crit chance per tier | Vanilla = 20.0

--	Slice 'Em Up | Tier 5
	TweakDB:SetFlat("BaseStatusEffect.BladeMod2_FinisherBuff_inline4.value", 20.0)	-- Finisher susceptibility | Vanilla = 20.0
	TweakDB:SetFlat("BaseStatusEffect.BladeMod2_FinisherBuff_inline2.value", 7.5)	-- Duration | Vanilla = 5.0 | seconds
	TweakDB:SetFlat("Items.BladeMod2_Base_inline8.floatValues", {20.0, 7.5})		-- UI | Finisher susceptibility, Duration | Vanilla = 20.0, 5.0

--	Haemocide | Tier 1 to 5
	TweakDB:SetFlat("Items.BladeMod3_Base_inline0.value", 1.0)	-- Bleeding duration bonus | Vanilla = 1.0 | seconds
	TweakDB:SetFlat("Items.BladeMod3_Base_inline1.value", 1.0)	-- Bleeding duration bonus per tier | Vanilla = 0.5 | seconds

	TweakDB:SetFlat("Items.BladeMod3_Base_inline2.value", 5.0)	-- Crit chance | Vanilla = 5.0
	TweakDB:SetFlat("Items.BladeMod3_Base_inline3.value", 1.25)	-- Crit chance per tier | Vanilla = 2.0

	TweakDB:SetFlat("Items.BladeMod3_Base_inline4.value", -7.5)	-- Base damage | Vanilla = -20.0
	TweakDB:SetFlat("Items.BladeMod3_Base_inline5.value", 1.25)	-- Base damage per tier | Vanilla = 2.5

-- Blunt Weapon Only
--	K.O. | Tier 1 to 5 | Knockback chance & Stamina cost handled by curve multipliers
	TweakDB:SetFlat("Items.BluntMod1_Base_inline4.value", 15.0)					-- Attack speed reduction | Vanilla = 20.0
	TweakDB:SetFlat("Items.BluntMod1_Base_inline6.value", 25.0)					-- Damage bonus | Vanilla = 25.0
	TweakDB:SetFlat("Items.BluntMod1_Base_inline11.floatValues", {15.0, 25.0})	-- Attack speed reduction, Damage bonus | Vanilla = 20.0, 25.0

--	Bloodbruiser | Tier 1 to 5
	TweakDB:SetFlat("Items.BluntMod2_Base_inline0.value", 50.0)	-- % of stun chance converted to bleed chance | Vanilla = 60.0 | e.g: 20% stun chance at 50.0 conversion = 10% chance to cause bleed
	TweakDB:SetFlat("Items.BluntMod2_Base_inline1.value", 25.0)	-- Stun chance converted to Bleed chance % per tier | Vanilla = 10.0

--	Barbarian | Tier 4 to 5 | Handled by curve multipliers
	TweakDB:SetFlat("Items.BluntMod3_Epic_inline1.intValues", {25})			-- UI | Bonus Damage vs Stunned Target | Vanilla = 20
	TweakDB:SetFlat("Items.BluntMod3_Legendary_inline1.intValues", {50})	-- UI | Bonus Damage vs Stunned Target | Vanilla = 40

-- Throwable Weapon Only
--	Boomerang | Tier 1 to 5 | Handled by curve multipliers

--	Zero-G | Tier 3 to 5 | Handled by curve multipliers
	TweakDB:SetFlat("Items.ThrowMod2_Rare_inline1.floatValues", {30.0})			-- UI | Range Bonus | Vanilla = 10.0
	TweakDB:SetFlat("Items.ThrowMod2_Epic_inline1.floatValues", {40.0})			-- UI | Range Bonus | Vanilla = 25.0
	TweakDB:SetFlat("Items.ThrowMod2_Legendary_inline3.floatValues", {50.0})	-- UI | Range Bonus | Vanilla = 50.0

--	Javelin | Tier 1 to 5
	TweakDB:SetFlat("Items.ThrowMod3_Base_inline0.value", -0.1)			-- Effective Range | Vanilla = -20.0
	TweakDB:SetFlat("Items.ThrowMod3_Base_inline7.floatValues", {10.0})	-- UI | Effective Range | Vanilla = 20.0

	TweakDB:SetFlat("Items.ThrowMod3_Base_inline1.value", 15.0)			-- Armor Penetration | Vanilla = 15.0
	TweakDB:SetFlat("Items.ThrowMod3_Base_inline2.value", 2.5)			-- Armor Penetration per tier | Vanilla = 2.5

    print('Weapon Mods Improved: Initialized')
end)