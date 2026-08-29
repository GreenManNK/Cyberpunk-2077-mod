module CopKiller

import Codeware
import Codeware.Localization.*
import TweakXL

@if(ModuleExists("ModSettingsModule"))
import ModSettingsModule.*

@if(ModuleExists("Audioware"))
import Audioware.*

@if(ModuleExists("Atone"))
import Atone.*

@if(ModuleExists("LootingQoL"))
import LootingQoL.*

@if(ModuleExists("Pariah"))
import Pariah.*

@if(ModuleExists("PayToGo"))
import PayToGo.*

// @if(ModuleExists("Gibbon.GR.ReinforcementSystem"))
// import Gibbon.GR.ReinforcementSystem.*

// @if(ModuleExists("Threadscape"))
// import Threadscape.*

@if(ModuleExists("TheyWillRemember"))
import TheyWillRemember.*

enum eMaxTacOperator {
	Random		= 0,
	Heavy		= 1,
	Netrunner	= 2,
	Assault		= 3,
	Sniper		= 4,
	Mantis		= 5
}

// Mod Settings, Utils

public class CopKillerSSX extends ScriptableService {

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"") // CopKiller_MS_Enabled_Category
	@runtimeProperty("ModSettings.category.order",						"0")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_Enabled_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_Enabled_desc")
	public let bMS_Enabled: Bool										= true;

	// Reporting

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Reporting_Category")
	@runtimeProperty("ModSettings.category.order",						"1")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_ReportsAfterDeath_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_ReportsAfterDeath_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_ReportsAfterDeath: Bool								= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Reporting_Category")
	@runtimeProperty("ModSettings.category.order",						"1")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_ReportsAfterEvasion_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_ReportsAfterEvasion_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_ReportsAfterEvasion: Bool							= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Reporting_Category")
	@runtimeProperty("ModSettings.category.order",						"1")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_ReportCopCarKills_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_ReportCopCarKills_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_ReportsAfterEvasion")
	public let bMS_ReportCopCarKills: Bool								= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Reporting_Category")
	@runtimeProperty("ModSettings.category.order",						"1")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_ReportMaxTacKills_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_ReportMaxTacKills_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_ReportsAfterEvasion")
	public let bMS_ReportMaxTacKills: Bool								= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Reporting_Category")
	@runtimeProperty("ModSettings.category.order",						"1")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_ActivityLogReports_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_ActivityLogReports_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_ActivityLogReports: Bool								= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Reporting_Category")
	@runtimeProperty("ModSettings.category.order",						"1")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_WelcomeMessages_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_WelcomeMessages_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_WelcomeMessages: Bool								= true;

	// Combat Systems

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_Introductions_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_Introductions_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_Introductions: Bool									= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_SevereProblemWithAuthority_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_SevereProblemWithAuthority_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_SevereProblemWithAuthority: Bool						= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_SevereProblemWithAuthorityGUIStats_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_SevereProblemWithAuthorityGUIStats_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_SevereProblemWithAuthority")
	public let bMS_SevereProblemWithAuthorityGUIStats: Bool				= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_SevereProblemWithAuthorityGUIStars_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_SevereProblemWithAuthorityGUIStars_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_SevereProblemWithAuthority")
	public let bMS_SevereProblemWithAuthorityGUIStars: Bool				= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_AnarchistVanguard_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_AnarchistVanguard_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_AnarchistVanguard: Bool								= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_UnderfundedDeptMode_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_UnderfundedDeptMode_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_UnderfundedDeptMode: Bool							= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_UnderfundedDeptModeKillReq_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_UnderfundedDeptModeKillReq_desc")
	@runtimeProperty("ModSettings.step",								"50")
	@runtimeProperty("ModSettings.min",									"0")
	@runtimeProperty("ModSettings.max", 								"1000")
	@runtimeProperty("ModSettings.dependency",							"bMS_UnderfundedDeptMode")
	public let nMS_UnderfundedDeptModeKillReq: Int32					= 500;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_TraitorsAndBetrayers_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_TraitorsAndBetrayers_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_UnderfundedDeptMode")
	public let bMS_TraitorsAndBetrayers: Bool							= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_CustomizedMaxTacSquads_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_CustomizedMaxTacSquads_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_CustomizedMaxTacSquads: Bool							= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MaxTacOperatorOne_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MaxTacOperatorOne_desc")
	@runtimeProperty("ModSettings.displayValues.Random",				"CopKiller_MS_MaxTacOps_val0")
	@runtimeProperty("ModSettings.displayValues.Heavy",					"LocKey#93837") // MaxTac Operator - Heavy
	@runtimeProperty("ModSettings.displayValues.Netrunner",				"LocKey#93834") // MaxTac Operator - Netrunner
	@runtimeProperty("ModSettings.displayValues.Assault",				"LocKey#94194") // MaxTac Operator - Assault
	@runtimeProperty("ModSettings.displayValues.Sniper",				"LocKey#93833") // MaxTac Operator - Sniper
	@runtimeProperty("ModSettings.displayValues.Mantis",				"LocKey#93836") // MaxTac Operator - Mantis
	@runtimeProperty("ModSettings.dependency",							"bMS_CustomizedMaxTacSquads")
	public let eMS_MaxTacOperatorOne: eMaxTacOperator					= eMaxTacOperator.Random;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MaxTacOperatorTwo_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MaxTacOperatorTwo_desc")
	@runtimeProperty("ModSettings.displayValues.Random",				"CopKiller_MS_MaxTacOps_val0")
	@runtimeProperty("ModSettings.displayValues.Heavy",					"LocKey#93837") // MaxTac Operator - Heavy
	@runtimeProperty("ModSettings.displayValues.Netrunner",				"LocKey#93834") // MaxTac Operator - Netrunner
	@runtimeProperty("ModSettings.displayValues.Assault",				"LocKey#94194") // MaxTac Operator - Assault
	@runtimeProperty("ModSettings.displayValues.Sniper",				"LocKey#93833") // MaxTac Operator - Sniper
	@runtimeProperty("ModSettings.displayValues.Mantis",				"LocKey#93836") // MaxTac Operator - Mantis
	@runtimeProperty("ModSettings.dependency",							"bMS_CustomizedMaxTacSquads")
	public let eMS_MaxTacOperatorTwo: eMaxTacOperator					= eMaxTacOperator.Random;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MaxTacOperatorThree_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MaxTacOperatorThree_desc")
	@runtimeProperty("ModSettings.displayValues.Random",				"CopKiller_MS_MaxTacOps_val0")
	@runtimeProperty("ModSettings.displayValues.Heavy",					"LocKey#93837") // MaxTac Operator - Heavy
	@runtimeProperty("ModSettings.displayValues.Netrunner",				"LocKey#93834") // MaxTac Operator - Netrunner
	@runtimeProperty("ModSettings.displayValues.Assault",				"LocKey#94194") // MaxTac Operator - Assault
	@runtimeProperty("ModSettings.displayValues.Sniper",				"LocKey#93833") // MaxTac Operator - Sniper
	@runtimeProperty("ModSettings.displayValues.Mantis",				"LocKey#93836") // MaxTac Operator - Mantis
	@runtimeProperty("ModSettings.dependency",							"bMS_CustomizedMaxTacSquads")
	public let eMS_MaxTacOperatorThree: eMaxTacOperator					= eMaxTacOperator.Random;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MaxTacOperatorFour_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MaxTacOperatorFour_desc")
	@runtimeProperty("ModSettings.displayValues.Random",				"CopKiller_MS_MaxTacOps_val0")
	@runtimeProperty("ModSettings.displayValues.Heavy",					"LocKey#93837") // MaxTac Operator - Heavy
	@runtimeProperty("ModSettings.displayValues.Netrunner",				"LocKey#93834") // MaxTac Operator - Netrunner
	@runtimeProperty("ModSettings.displayValues.Assault",				"LocKey#94194") // MaxTac Operator - Assault
	@runtimeProperty("ModSettings.displayValues.Sniper",				"LocKey#93833") // MaxTac Operator - Sniper
	@runtimeProperty("ModSettings.displayValues.Mantis",				"LocKey#93836") // MaxTac Operator - Mantis
	@runtimeProperty("ModSettings.dependency",							"bMS_CustomizedMaxTacSquads")
	public let eMS_MaxTacOperatorFour: eMaxTacOperator					= eMaxTacOperator.Random;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MelissaRoryChance_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MelissaRoryChance_desc")
	@runtimeProperty("ModSettings.step",								"1")
	@runtimeProperty("ModSettings.min",									"0")
	@runtimeProperty("ModSettings.max", 								"100")
	@runtimeProperty("ModSettings.dependency",							"bMS_CustomizedMaxTacSquads")
	public let nMS_MelissaRoryChance: Int32								= 0;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_LethalIntent_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_LethalIntent_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_LethalIntent: Bool									= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_CombatSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"2")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_CodeThirty_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_CodeThirty_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_CodeThirty: Bool										= false;

	// Loot Systems

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_LootSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"3")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_StateAssetForfeiture_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_StateAssetForfeiture_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_StateAssetForfeiture: Bool							= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_LootSystems_Category")
	@runtimeProperty("ModSettings.category.order",						"3")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_AllBarghestAreCops_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_AllBarghestAreCops_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_AllBarghestAreCops: Bool								= false;

	// Rewards

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Rewards_Category")
	@runtimeProperty("ModSettings.category.order",						"4")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_StreetCredForCopsKilled_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_StreetCredForCopsKilled_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_StreetCredForCopsKilled: Bool						= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Rewards_Category")
	@runtimeProperty("ModSettings.category.order",						"4")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_ExperienceForCopsKilled_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_ExperienceForCopsKilled_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_ExperienceForCopsKilled: Bool						= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Rewards_Category")
	@runtimeProperty("ModSettings.category.order",						"4")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_NoExperienceForGangoons_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_NoExperienceForGangoons_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_ExperienceForCopsKilled")
	public let bMS_NoExperienceForGangoons: Bool						= true;

	// Loot

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_AmmunitionForCopsKilled_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_AmmunitionForCopsKilled_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_AmmunitionForCopsKilled: Bool						= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_CopsDropHeldWeapon_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_CopsDropHeldWeapon_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_CopsDropHeldWeapon: Bool								= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_CopsDropGlobalLoot_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_CopsDropGlobalLoot_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_CopsDropGlobalLoot: Bool								= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_EliteCopsDropHeldWeapon_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_EliteCopsDropHeldWeapon_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_EliteCopsDropHeldWeapon: Bool						= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_EliteCopsDropGlobalLoot_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_EliteCopsDropGlobalLoot_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_EliteCopsDropGlobalLoot: Bool						= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MaxTacDropHeldWeapon_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MaxTacDropHeldWeapon_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_MaxTacDropHeldWeapon: Bool							= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MaxTacDropGlobalLoot_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MaxTacDropGlobalLoot_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_MaxTacDropGlobalLoot: Bool							= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_BrokenWeaponDropChance_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_BrokenWeaponDropChance_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	@runtimeProperty("ModSettings.step",								"1")
	@runtimeProperty("ModSettings.min",									"0")
	@runtimeProperty("ModSettings.max", 								"100")
	public let nMS_BrokenWeaponDropChance: Int32						= 90;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Loot_Category")
	@runtimeProperty("ModSettings.category.order",						"5")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_BadgeArmorDrops_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_BadgeArmorDrops_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_BadgeArmorDrops: Bool								= false;

	// Mod Gameplay Ecosystem

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Ecosystem_Category")
	@runtimeProperty("ModSettings.category.order",						"6")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_Atone_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_Atone_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_Atone: Bool											= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Ecosystem_Category")
	@runtimeProperty("ModSettings.category.order",						"6")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_LootingQoL_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_LootingQoL_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_LootingQoL: Bool										= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Ecosystem_Category")
	@runtimeProperty("ModSettings.category.order",						"6")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_Pariah_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_Pariah_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_Pariah: Bool											= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Ecosystem_Category")
	@runtimeProperty("ModSettings.category.order",						"6")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_PayToGo_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_PayToGo_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_PayToGo: Bool										= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Ecosystem_Category")
	@runtimeProperty("ModSettings.category.order",						"6")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_RGvG_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_RGvG_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_RGvG: Bool											= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Ecosystem_Category")
	@runtimeProperty("ModSettings.category.order",						"6")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_Threadscape_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_Threadscape_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_Threadscape: Bool									= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Ecosystem_Category")
	@runtimeProperty("ModSettings.category.order",						"6")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_TWR_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_TWR_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_TWR: Bool											= true;

	// Audio

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Audio_Category")
	@runtimeProperty("ModSettings.category.order",						"7")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MutePoliceCombatMusic_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MutePoliceCombatMusic_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_MutePoliceCombatMusic: Bool							= false;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_Audio_Category")
	@runtimeProperty("ModSettings.category.order",						"7")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_MutePoliceHornsAndSirens_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_MutePoliceHornsAndSirens_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_MutePoliceHornsAndSirens: Bool						= false;

	// Bug Fixes

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_BugFixes_Category")
	@runtimeProperty("ModSettings.category.order",						"8")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_PoliceExecutionFix_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_PoliceExecutionFix_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_PoliceExecutionFix: Bool								= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_BugFixes_Category")
	@runtimeProperty("ModSettings.category.order",						"8")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_PoliceMinimapIconsFix_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_PoliceMinimapIconsFix_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_PoliceMinimapIconsFix: Bool							= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_BugFixes_Category")
	@runtimeProperty("ModSettings.category.order",						"8")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_PoliceBorderGuardsFix_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_PoliceBorderGuardsFix_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_PoliceBorderGuardsFix: Bool							= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_BugFixes_Category")
	@runtimeProperty("ModSettings.category.order",						"8")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_PoliceArchetypeNamesFix_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_PoliceArchetypeNamesFix_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_PoliceArchetypeNamesFix: Bool						= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_BugFixes_Category")
	@runtimeProperty("ModSettings.category.order",						"8")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_PoliceScannerNamesFix_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_PoliceScannerNamesFix_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_PoliceScannerNamesFix: Bool							= true;

	@runtimeProperty("ModSettings.mod",									"CopKiller_MS_mod_name")
	@runtimeProperty("ModSettings.category",							"CopKiller_MS_BugFixes_Category")
	@runtimeProperty("ModSettings.category.order",						"8")
	@runtimeProperty("ModSettings.displayName",							"CopKiller_MS_OfficerRarityFix_name")
	@runtimeProperty("ModSettings.description",							"CopKiller_MS_OfficerRarityFix_desc")
	@runtimeProperty("ModSettings.dependency",							"bMS_Enabled")
	public let bMS_OfficerRarityFix: Bool								= true;

	// ...

	@if(ModuleExists("ModSettingsModule"))
	protected func RegisterModSettingsListener() -> Void { ModSettings.RegisterListenerToClass(this); };

	@if(!ModuleExists("ModSettingsModule"))
	protected func RegisterModSettingsListener() -> Void { return; }

	@if(ModuleExists("ModSettingsModule"))
	protected func UnregisterModSettingsListener() -> Void { ModSettings.UnregisterListenerToClass(this); };

	@if(!ModuleExists("ModSettingsModule"))
	protected func UnregisterModSettingsListener() -> Void { return; }

	public let bModSettingsChangesPending: Bool = false;

	private cb func OnLoad() {
		this.RegisterModSettingsListener();
		this.bCopKillerNCPDFixesFilePresent	= GameFileExists("r6/scripts/CopKiller/CopKillerNCPDFixes.reds");
		this.ManageAudio();
	}

	@if(ModuleExists("ModSettingsModule"))
	private cb func OnInitialize() -> Void {
		let ecosystem: array<ref<ConfigVar>> = ModSettings.GetVars(n"CopKiller_MS_mod_name", n"CopKiller_MS_Ecosystem_Category");
		if ArraySize(ecosystem) == 7 {
			if IsDefined(ecosystem[0] as ModConfigVarBool) && !this.bAtone			{ (ecosystem[0] as ModConfigVarBool).SetValue(false); this.bModSettingsChangesPending = true; };
			if IsDefined(ecosystem[1] as ModConfigVarBool) && !this.bLootingQoL		{ (ecosystem[1] as ModConfigVarBool).SetValue(false); this.bModSettingsChangesPending = true; };
			if IsDefined(ecosystem[2] as ModConfigVarBool) && !this.bPariah			{ (ecosystem[2] as ModConfigVarBool).SetValue(false); this.bModSettingsChangesPending = true; };
			if IsDefined(ecosystem[3] as ModConfigVarBool) && !this.bPayToGo		{ (ecosystem[3] as ModConfigVarBool).SetValue(false); this.bModSettingsChangesPending = true; };
			if IsDefined(ecosystem[4] as ModConfigVarBool) && !this.bRGvG			{ (ecosystem[4] as ModConfigVarBool).SetValue(false); this.bModSettingsChangesPending = true; };
			if IsDefined(ecosystem[5] as ModConfigVarBool) && !this.bThreadscape	{ (ecosystem[5] as ModConfigVarBool).SetValue(false); this.bModSettingsChangesPending = true; };
			if IsDefined(ecosystem[6] as ModConfigVarBool) && !this.bTWR			{ (ecosystem[6] as ModConfigVarBool).SetValue(false); this.bModSettingsChangesPending = true; };
		};
	}

	private cb func OnUninitialize() -> Void {
		this.UnregisterModSettingsListener();
	}
	
	public let bCopKillerNCPDFixesFilePresent: Bool = false;
	public let bMelissaRoryChanceInit: Bool = false;
	public let bHeatDebugLogging: Bool = false;

	@if(!ModuleExists("Atone"))
	public const let bAtone: Bool = false;

	@if(ModuleExists("Atone"))
	public const let bAtone: Bool = true;

	public let bAtoneLogOnce: Bool = false;
	
	@if(!ModuleExists("LootingQoL"))
	public const let bLootingQoL: Bool = false;

	@if(ModuleExists("LootingQoL"))
	public const let bLootingQoL: Bool = true;

	public let bLootingQoLLogOnce: Bool = false;

	@if(!ModuleExists("MuteCombatMusic"))
	public const let bMuteCombatMusic: Bool = false;

	@if(ModuleExists("MuteCombatMusic"))
	public const let bMuteCombatMusic: Bool = true;

	@if(!ModuleExists("Pariah"))
	public const let bPariah: Bool = false;

	@if(ModuleExists("Pariah"))
	public const let bPariah: Bool = true;

	public let bPariahLogOnce: Bool = false;

	@if(!ModuleExists("PayToGo"))
	public const let bPayToGo: Bool = false;

	@if(ModuleExists("PayToGo"))
	public const let bPayToGo: Bool = true;

	public let bPayToGoLogOnce: Bool = false;

	@if(!ModuleExists("Gibbon.GR.ReinforcementSystem"))
	public const let bRGvG: Bool = false;

	@if(ModuleExists("Gibbon.GR.ReinforcementSystem"))
	public const let bRGvG: Bool = true;

//	public let bRGvGLogOnce: Bool = false;

	@if(!ModuleExists("Threadscape"))
	public const let bThreadscape: Bool = false;

	@if(ModuleExists("Threadscape"))
	public const let bThreadscape: Bool = true;

	public let bThreadscapeOnce: Bool = false;

	@if(!ModuleExists("TheyWillRemember"))
	public const let bTWR: Bool = false;

	@if(ModuleExists("TheyWillRemember"))
	public const let bTWR: Bool = true;

	public let bTWRLogOnce: Bool = false;

	// Audio

	@if(!ModuleExists("Audioware"))
	protected func ManageAudio() -> Void { return; }

	@if(ModuleExists("Audioware"))
	protected func ManageAudio() -> Void {
		let audioManager: ref<AudioEventManager> = new AudioEventManager();
		if !IsDefined(audioManager) { return; };
		if !this.bMuteCombatMusic && this.bMS_MutePoliceCombatMusic {
			let muteList: array<CName> = MuteList_PoliceCombatMusic();
			for m in muteList {
				if StrContains(NameToString(m), "_STOP_") {
					audioManager.MuteSpecific(m, audioEventActionType.StopSound);
				} else {
					audioManager.Mute(m);
				};
			};
		};
		if this.bMS_MutePoliceHornsAndSirens {
			let muteList: array<CName> = MuteList_PoliceHornsAndSirens();
			for m in muteList {
				if StrEndsWith(NameToString(m), "_stop") {
					audioManager.MuteSpecific(m, audioEventActionType.StopSound);
				} else {
					audioManager.Mute(m);
				};
			};
		};
	}

	// ...

	public static func GetSSX() -> ref<CopKillerSSX> {
		return GameInstance.GetScriptableServiceContainer().GetService(n"CopKiller.CopKillerSSX") as CopKillerSSX;
	}

}

// Mod Settings Changes

@if(ModuleExists("ModSettingsModule"))
@wrapMethod(SingleplayerMenuGameController)
protected cb func OnInitialize() -> Bool {
	wrappedMethod();
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if ssx.bModSettingsChangesPending {
		ModSettings.AcceptChanges();
		ssx.bModSettingsChangesPending = false;
	};
}

// Mod Gameplay Ecosystem, Outgoing

@addMethod(PlayerPuppet)
public static func CopKiller_GetPoliceKills() -> Uint32 { return CopKillerSS.GetSS().nCopsKilled; }

@addMethod(PlayerPuppet)
public static func CopKiller_GetPoliceExecuted() -> Uint32 { return CopKillerSS.GetSS().nCopsExecuted; }

@addMethod(PlayerPuppet)
public static func CopKiller_GetMaxTacKills() -> Uint32 { return CopKillerSS.GetSS().nMaxTacKilled; }

@addMethod(PlayerPuppet)
public static func CopKiller_GetMaxTacExecuted() -> Uint32 { return CopKillerSS.GetSS().nMaxTacExecuted; }

@addMethod(PlayerPuppet)
public static func CopKiller_GetCitizensAllied() -> Uint32 { return CopKillerSS.GetSS().nCitizensAllied; }

@addMethod(PlayerPuppet)
public static func CopKiller_GetHeatsEvaded() -> Uint32 { return CopKillerSS.GetSS().nHeatsEvaded; }

@addMethod(PlayerPuppet)
public static func CopKiller_IsAlliedWithPlayer(npc: ref<NPCPuppet>) -> Bool { return IsDefined(npc) && ArrayContains(CopKillerSS.GetSS().spawnedFriendlyList, npc); }

// Mod Gameplay Ecosystem, Incoming

public func Atone_GiveStreetCredExpReward_Reflected(amount: Int32) -> Void {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bAtone || !ssx.bMS_Atone { return; }
	let callable = Reflection.GetGlobalFunction(n"PlayerPuppet::GiveStreetCredExpReward;Int32");
	if IsDefined(callable) {
		callable.Call( [ amount ] );
	} else if !ssx.bAtoneLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_Atone_error")));
		ssx.bAtoneLogOnce = true;
	};
}

public func Atone_GetStreetCredLevelsReset_Reflected() -> Uint32 {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bAtone || !ssx.bMS_Atone { return 0u; }
	let callable = Reflection.GetGlobalFunction(n"PlayerPuppet::GetStreetCredLevelsReset;");
	if IsDefined(callable) {
		return FromVariant<Uint32>(callable.Call());
	} else if !ssx.bAtoneLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_Atone_error")));
		ssx.bAtoneLogOnce = true;
	};
	return 0u;
}

public func LootingQoL_SetCustomDisplayName_Reflected(gameObject: ref<GameObject>, s: String) -> Void {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bLootingQoL || !ssx.bMS_LootingQoL { return; }
	let rclass = Reflection.GetClass(n"gameObject");
	let prop = rclass.GetProperty(n"customDisplayName"); // m_customDisplayName
	if IsDefined(prop) {
		prop.SetValue(ToVariant(gameObject), ToVariant(s));
	} else if !ssx.bLootingQoLLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_LootingQoL_error")));
		ssx.bLootingQoLLogOnce = true;
	};
}

public func LootingQoL_SetCustomFactionName_Reflected(gameObject: ref<GameObject>, s: String) -> Void {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bLootingQoL || !ssx.bMS_LootingQoL { return; }
	let rclass = Reflection.GetClass(n"gameObject");
	let prop = rclass.GetProperty(n"customFactionName"); // m_customFactionName
	if IsDefined(prop) {
		prop.SetValue(ToVariant(gameObject), ToVariant(s));
	} else if !ssx.bLootingQoLLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_LootingQoL_error")));
		ssx.bLootingQoLLogOnce = true;
	};
}

public func Pariah_GetCivilianKills_Reflected() -> Uint32 {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bPariah || !ssx.bMS_Pariah { return 0u; }
	let callable = Reflection.GetGlobalFunction(n"PlayerPuppet::Pariah_GetCivilianKills;");
	if IsDefined(callable) {
		return FromVariant<Uint32>(callable.Call());
	} else if !ssx.bPariahLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_Pariah_error")));
		ssx.bPariahLogOnce = true;
	};
	return 0u;
}

public func PayToGo_GetTravelDebt_Reflected() -> Uint32 {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bPayToGo || !ssx.bMS_PayToGo { return 0u; }
	let callable = Reflection.GetGlobalFunction(n"PlayerPuppet::PayToGo_GetTravelDebt;");
	if IsDefined(callable) {
		return FromVariant<Uint32>(callable.Call());
	} else if !ssx.bPayToGoLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_PayToGo_error")));
		ssx.bPayToGoLogOnce = true;
	};
	return 0u;
}

public func Threadscape_GetRandomModClothing_Reflected(amt: Int32) -> array<TweakDBID> {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bThreadscape || !ssx.bMS_Threadscape { return []; };
	let callable = Reflection.GetGlobalFunction(n"PlayerPuppet::Threadscape_GetRandomModClothing;Int32");
	if IsDefined(callable) {
		return FromVariant<array<TweakDBID>>(callable.Call( [ amt ] ));
	} else if !ssx.bThreadscapeOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_Threadscape_error")));
		ssx.bThreadscapeOnce = true;
	};
	return [];
}

public func TWR_CheckFactionCred_Reflected(npc: ref<NPCPuppet>) -> Int32 {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bTWR || !ssx.bMS_TWR { return 0; }
	let callable = Reflection.GetGlobalFunction(n"PlayerPuppet::TWR_CheckFactionCred;NPCPuppet");
	if IsDefined(callable) {
		return FromVariant<Int32>(callable.Call( [ npc ] )); // returns -100 (or less, depending on faction kills) to 100, where positive is friendlier
	} else if !ssx.bTWRLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_TWR_error")));
		ssx.bTWRLogOnce = true;
	};
	return 0;
}

public func TWR_IsPlayerID_Reflected() -> Bool {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bTWR || !ssx.bMS_TWR { return true; }
	let callable = Reflection.GetGlobalFunction(n"PlayerPuppet::TWR_IsPlayerID;");
	if IsDefined(callable) {
		return FromVariant<Bool>(callable.Call());
	} else if !ssx.bTWRLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_TWR_error")));
		ssx.bTWRLogOnce = true;
	};
	return true;
}

public func TWR_HostilityQuery_Reflected(faction: gamedataAffiliation) -> Int32 {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bTWR || !ssx.bMS_TWR { return -1; }
	let callable = Reflection.GetGlobalFunction(n"TheyWillRemember.TWRQuery;gamedataAffiliation");
	if IsDefined(callable) {
		return FromVariant<Int32>(callable.Call( [ faction ] )); // returns -2 if not ID, -1 if not hostile, or a positive number of remembered kills
	} else if !ssx.bTWRLogOnce {
		FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_MS_TWR_error")));
		ssx.bTWRLogOnce = true;
	};
	return -1;
}

// Heat Scoring

@addMethod(GameInstance)
public static func ToggleHeatDebug(game: GameInstance) -> Void {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	ssx.bHeatDebugLogging = !ssx.bHeatDebugLogging;
	FTLog("[Cop Killer] Heat Debug Logging: " + (ssx.bHeatDebugLogging ? "ON" : "OFF"));
}

// Utility Funcs

public func IsTargetPolice(target: wref<GameObject>) -> Bool {
	if !IsDefined(target) { return false; };
	if target.IsPrevention() {
		return true;
	};
	let type: gamedataAffiliation = gamedataAffiliation.Invalid;
	if target.IsNPC() {
		let targetNPC: wref<NPCPuppet> = target as NPCPuppet;
		if targetNPC.IsCharacterPolice() || Equals(targetNPC.GetNPCRarity(), gamedataNPCRarity.MaxTac) {
			return true;
		} else if IsDefined(targetNPC.GetRecord()) && IsDefined(targetNPC.GetRecord().Affiliation()) {
			type = targetNPC.GetRecord().Affiliation().Type();
		};
	} else if target.IsVehicle() {
		let targetVeh: wref<VehicleObject> = target as VehicleObject;
		if IsDefined(targetVeh.GetRecord()) && IsDefined(targetVeh.GetRecord().Affiliation()) {
			type = targetVeh.GetRecord().Affiliation().Type();
		};
	} else {
		return false;
	};
	return Equals(type, gamedataAffiliation.NCPD) || Equals(type, gamedataAffiliation.NetWatch) || 
		(CopKillerSSX.GetSSX().bMS_AllBarghestAreCops && Equals(type, gamedataAffiliation.Barghest));
}

public func IsTargetABeatCop(npc: wref<NPCPuppet>) -> Bool {
	let record: ref<Character_Record> = IsDefined(npc) ? npc.GetRecord() : null;
	let name: String = IsDefined(record) ? GetLocalizedText(LocKeyToString(record.DisplayName())) : "";
	return Equals(name, GetLocalizedText(LocKeyToString(n"LocKey#22675"))) || Equals(name, GetLocalizedText(LocKeyToString(n"LocKey#42635")));
}

public func IsTargetGangAffiliated(target: wref<NPCPuppet>) -> Bool {
	if !IsDefined(target) { return false; };
	let npcTDBID: TweakDBID = target.GetRecordID();
	if TDBID.IsValid(npcTDBID) {
		let charRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(npcTDBID);
		if IsDefined(charRecord) {
			let affiliation: wref<Affiliation_Record> = charRecord.Affiliation();
			if IsDefined(affiliation) {
				switch (affiliation.Type()) {
					case gamedataAffiliation.AfterlifeMercs:
					case gamedataAffiliation.Animals:
					case gamedataAffiliation.Maelstrom:
					case gamedataAffiliation.Scavengers:
					case gamedataAffiliation.SixthStreet:
					case gamedataAffiliation.TheMox:
					case gamedataAffiliation.TygerClaws:
					case gamedataAffiliation.Valentinos:
					case gamedataAffiliation.VoodooBoys:
					case gamedataAffiliation.Wraiths:
						return true;
				};
			};
		};
	};
	return false;
}

public func IsTargetABountyHunter(target: wref<NPCPuppet>) -> Bool {
	if !IsDefined(target) { return false; };
	let npcTDBID: TweakDBID = target.GetRecordID();
	if TDBID.IsValid(npcTDBID) {
		let tBountyHunters: array<TweakDBID> = CopKillerTweaksSSX.GetSSX().CharList_Prevention_BountyHunters();
		return ArrayContains(tBountyHunters, npcTDBID);
	};
	return false;
}

public func CanTargetAlly(target: wref<NPCPuppet>) -> Bool {
	if !IsDefined(target) { return false; };
	let npcTDBID: TweakDBID = target.GetRecordID();
	if TDBID.IsValid(npcTDBID) {
		if  StrContains(TDBID.ToStringDEBUG(npcTDBID), ".q")  || 
			StrContains(TDBID.ToStringDEBUG(npcTDBID), ".mq") || 
			StrContains(TDBID.ToStringDEBUG(npcTDBID), ".sq") {
			return false;
		};
		let charRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(npcTDBID);
		if IsDefined(charRecord) {
			if charRecord.TagsContains(n"Invulnerable") || !IsDefined(charRecord.PrimaryEquipment()) {
				return false;
			};
			let baseAttitudeGroup: String = NameToString(charRecord.BaseAttitudeGroup());
			return IsTargetGangAffiliated(target) && 
				(StrContains(baseAttitudeGroup, "_ow") || Equals(baseAttitudeGroup, "friendly") || Equals(baseAttitudeGroup, "neutral"));
		};
	};
	return false;
}

public func isAlliedWithPlayer(npc: wref<NPCPuppet>, player: wref<PlayerPuppet>) -> Bool {
	if !CopKillerSSX.GetSSX().bMS_AnarchistVanguard || !IsDefined(npc) || !IsDefined(player) || !ArrayContains(CopKillerSS.GetSS().spawnedFriendlyList, npc) { return false; };
	let aaNpc: ref<AttitudeAgent> = npc.GetAttitudeAgent();
	let aaPlayer: ref<AttitudeAgent> = player.GetAttitudeAgent();
	return IsDefined(aaNpc) && IsDefined(aaPlayer) && Equals(aaNpc.GetAttitudeTowards(aaPlayer), EAIAttitude.AIA_Friendly);
}

public func GetCurrentDistrict() -> gamedataDistrict {
	let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"PreventionSystem") as PreventionSystem;
	if !IsDefined(ps) { return gamedataDistrict.Invalid; };
	let district: wref<District> = ps.GetCurrentDistrict();
	return IsDefined(district) && IsDefined(district.m_districtRecord) ? district.m_districtRecord.Type() : gamedataDistrict.Invalid;
}

public func IsSubDistrictRich(subdistrict: gamedataDistrict) -> Bool {
	switch (subdistrict) {
		case gamedataDistrict.CharterHill:
		case gamedataDistrict.CorpoPlaza:
		case gamedataDistrict.Downtown:
		case gamedataDistrict.NorthOaks:
			return true;
	};
	return false;
}

public func TweakToName(tweak: TweakDBID) -> CName { return StringToName(TDBID.ToStringDEBUG(tweak)); }
public func NameToTweak(name: CName) -> TweakDBID { return TDBID.Create(NameToString(name)); }

// --- Comma-Delineation ----------
// ... by Demon9ne; You are welcome to copy this and use it anywhere. Credit in a comment alongside it would be appreciated.

public func CopKiller_CommaFormatUint32ToString(value: Uint32) -> String {
	return CopKiller_CommaFormatUint64ToString(Cast<Uint64>(value));
}

public func CopKiller_CommaFormatUint64ToString(value: Uint64) -> String {
	let s: String = ToString(value);
	let i: Int32 = 3;
	let l: Int32 = StrLen(s);
	while i < l {
		s = StrLeft(s, l - i) + "," + StrRight(s, i);
		l += 1;
		i += 4;
	};
	return s;
}

// --- ArrayShuffle ----------
// ... by Demon9ne; You are welcome to copy this and use it anywhere. Credit in a comment alongside it would be appreciated.

public func ArrayShuffle(a: array<TweakDBID>) -> array<TweakDBID> {
	let i: Int32 = 0;
	let s: Int32 = ArraySize(a);
	while i < s {
		let temp: TweakDBID = a[i];
		let rand: Int32 = RandRange(0, s);
		a[i] = a[rand];
		a[rand] = temp;
		i += 1;
	};
	return a;
}

// Vanilla Bug Fix: You were able to kill police execution style and not become wanted

@if(!ModuleExists("InColdBloodFix"))
@wrapMethod(ScriptedPuppet)
protected func OnDied() -> Void {
	let npc: wref<NPCPuppet> = this as NPCPuppet;
	let npcPS: ref<ScriptedPuppetPS> = npc.GetPS();
	if !CopKillerSSX.GetSSX().bMS_PoliceExecutionFix || !IsDefined(npc) || !IsDefined(npcPS) {
		wrappedMethod();
		return;
	};
	let bWasDefeated: Bool = !npc.m_shouldBeDefeated && npcPS.GetWasIncapacitated() && ScriptedPuppet.IsAlive(npc);
	wrappedMethod();
	let bWasKilled: Bool = npcPS.GetIsDead();
	let bWasExecuted: Bool = bWasDefeated && bWasKilled;
	if bWasExecuted && npc.m_myKiller.IsPlayer() && Equals(npc.GetNPCType(), gamedataNPCType.Human) {
		InColdBloodNPCExecutionFix(npc);
	};
}

@if(ModuleExists("InColdBloodFix"))
public func InColdBloodNPCExecutionFix(killedNPC: wref<NPCPuppet>) -> Void {
	return;
}

@if(!ModuleExists("InColdBloodFix"))
public static func InColdBloodNPCExecutionFix(killedNPC: wref<NPCPuppet>) -> Void {
	let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"PreventionSystem") as PreventionSystem;
	let nHeatStage: Int32 = IsDefined(ps) ? EnumInt(ps.GetHeatStage()) : 6;
	if nHeatStage > 5 {
		return;
	};
	let cRecord: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(killedNPC.GetRecordID());
	let affiliation: wref<Affiliation_Record> = IsDefined(cRecord) ? cRecord.Affiliation() : null;
	if !IsDefined(affiliation) {
		if killedNPC.IsCharacterPolice() {
			if Equals(killedNPC.GetNPCRarity(), gamedataNPCRarity.MaxTac) && nHeatStage < 5 {
				ps.ChangeHeatStage(EPreventionHeatStage.Heat_5, "EnterCombat");
			} else if nHeatStage < 3 {
				ps.ChangeHeatStage(EPreventionHeatStage.Heat_3, "EnterCombat");
			};
		};
		return;
    };
	switch (affiliation.Type()) {
		case gamedataAffiliation.NetWatch:
		case gamedataAffiliation.TraumaTeam:
			if nHeatStage < 4 {
				ps.ChangeHeatStage(EPreventionHeatStage.Heat_4, "EnterCombat");
			};
			return;
		case gamedataAffiliation.NCPD:
			if Equals(killedNPC.GetNPCRarity(), gamedataNPCRarity.MaxTac) && nHeatStage < 5 {
				ps.ChangeHeatStage(EPreventionHeatStage.Heat_5, "EnterCombat");
			} else if nHeatStage < 3 {
				ps.ChangeHeatStage(EPreventionHeatStage.Heat_3, "EnterCombat");
			};
			return;
		case gamedataAffiliation.Militech:
		case gamedataAffiliation.Barghest:
		case gamedataAffiliation.NUSA:
			if killedNPC.IsCharacterPolice() && nHeatStage < 3 {
				ps.ChangeHeatStage(EPreventionHeatStage.Heat_3, "EnterCombat");
			};
			return;
	};
}

// Vanilla Bug Fix: Police icons could appear on minimap with no police present

@wrapMethod(MinimapStubMappinController)
protected func Intro() -> Void {
	wrappedMethod();
	if CopKillerSSX.GetSSX().bMS_PoliceMinimapIconsFix {
		this.CopKiller_Update();
	};
}

@addMethod(MinimapStubMappinController)
protected func CopKiller_SetWidgetsVisibility(bVisible: Bool, bRegularVisible: Bool, bVehicleVisible: Bool, bABVisible: Bool) -> Void {
	inkWidgetRef.SetVisible(this.iconWidget, bVisible);
	inkWidgetRef.SetVisible(this.clampArrowWidget, bVisible);
	inkWidgetRef.SetVisible(this.m_regularIconContainer, bRegularVisible);
	inkWidgetRef.SetVisible(this.m_preventionVehicleIconContainer, bVehicleVisible);
	if IsDefined(this.m_aboveWidget) { this.m_aboveWidget.SetVisible(bABVisible); };
	if IsDefined(this.m_belowWidget) { this.m_belowWidget.SetVisible(bABVisible); };
}

@addMethod(MinimapStubMappinController)
protected func CopKiller_Update() -> Void {
	if !IsDefined(this.m_stubMappin) {
		return;
	};
	let type: gameStubMappinType = this.m_stubMappin.GetStubMappinType();
	if !Equals(type, gameStubMappinType.Police) && !Equals(type, gameStubMappinType.PoliceVehicle) {
		return;
	};
	let bVisible: Bool = false;
	let game: GameInstance = GetGameInstance();
	let entityID: EntityID = this.m_stubMappin.GetEntityID();
	let entity: ref<Entity> = !Equals(entityID, EMPTY_ENTITY_ID()) ? GameInstance.FindEntityByID(game, entityID) : null;
	if IsDefined(entity as ScriptedPuppet) {
		bVisible = entity.IsAttached() && ScriptedPuppet.IsActive(entity as GameObject) && ScriptedPuppet.IsAlive(entity as ScriptedPuppet);
		this.CopKiller_SetWidgetsVisibility(bVisible, bVisible, false, bVisible);
	} else if IsDefined(entity as VehicleObject) {
		bVisible = entity.IsAttached() && VehicleComponent.HasActiveDriverMounted(game, entityID) && ScriptedPuppet.IsAlive(VehicleComponent.GetDriver(game, entity as VehicleObject, entityID) as ScriptedPuppet);
		this.CopKiller_SetWidgetsVisibility(bVisible, false, bVisible, bVisible);
	} else if IsDefined(entity as SensorDevice) {
		bVisible = entity.IsAttached() && IsDefined((entity as SensorDevice).m_senseComponent) && (entity as SensorDevice).m_senseComponent.IsEnabled();
		this.CopKiller_SetWidgetsVisibility(bVisible, bVisible, false, bVisible);
	};
	if bVisible {
		super.Update();
		this.SetupStubWidget();
	} else {
		this.CopKiller_SetWidgetsVisibility(false, false, false, false);
		if IsDefined(this.GetRootWidget()) {
			this.GetRootWidget().SetVisible(false);
			this.GetRootWidget().SetOpacity(0.0);
			(this.GetRootWidget() as inkCompoundWidget).RemoveAllChildren();
		};
	};
}

// Vanilla Bug Fix: MaxTac mini-boss Melissa Rory's name was misspelled

@if(ModuleExists("Codeware"))
public class LocalizationProvider extends ModLocalizationProvider {
	public func GetPackage(language: CName) -> ref<ModLocalizationPackage> { return new LocalizationPackageAllLanguages(); }
	public func GetFallback() -> CName = n"";
}

@if(ModuleExists("Codeware"))
public class LocalizationPackageAllLanguages extends ModLocalizationPackage {
	protected func DefineTexts() -> Void {
		this.Text("Story-base-gameplay-static_data-database-characters-npcs-records-quest-minor_quests-mq030-mq030_cyberpsycho_fullDisplayName", "Melissa Rory"); // LocKey#33514
	}
}

// Audio Arrays

public func MuteList_PoliceCombatMusic() -> array<CName> = [
	n"mus_ow_police_calm",
	n"mus_ow_police_START_silent",
	n"mus_ow_police_STOP_silent",
	n"mus_ow_police_tense"
]

public func MuteList_PoliceHornsAndSirens() -> array<CName> = [
	
	// Ambient

//	n"amb_g_city_el_signals_police_short_rnd_01",
//	n"amb_g_city_el_signals_police_siren_short_01",

	// Vehicles

	n"v_car_archer_hella_police_horn",
	n"v_car_archer_hella_police_horn_stop",
	n"v_car_archer_hella_police_horn_traffic",
	n"v_car_archer_hella_police_siren_start",
	n"v_car_archer_hella_police_siren_stop",
	n"v_car_archer_hella_police_siren_traffic_start",
	n"v_car_archer_hella_police_siren_traffic_stop",

	n"v_car_chevalier_emperor_police_horn",
	n"v_car_chevalier_emperor_police_horn_stop",
	n"v_car_chevalier_emperor_police_horn_traffic",
	n"v_car_chevalier_emperor_police_siren_start",
	n"v_car_chevalier_emperor_police_siren_stop",
	n"v_car_chevalier_emperor_police_siren_traffic_start",
	n"v_car_chevalier_emperor_police_siren_traffic_stop",

	n"v_car_militech_hellhound_police_horn",
	n"v_car_militech_hellhound_police_horn_stop",
	n"v_car_militech_hellhound_police_horn_traffic",
	n"v_car_militech_hellhound_police_siren_start",
	n"v_car_militech_hellhound_police_siren_stop",
	n"v_car_militech_hellhound_police_siren_traffic_start",
	n"v_car_militech_hellhound_police_siren_traffic_stop",

	n"v_car_thorton_merrimac_police_horn",
	n"v_car_thorton_merrimac_police_horn_stop",
	n"v_car_thorton_merrimac_police_horn_traffic",
	n"v_car_thorton_merrimac_police_siren_start",
	n"v_car_thorton_merrimac_police_siren_stop",
	n"v_car_thorton_merrimac_police_siren_traffic_start",
	n"v_car_thorton_merrimac_police_siren_traffic_stop",

	n"v_car_villefort_cortes_police_horn",
	n"v_car_villefort_cortes_police_horn_stop",
	n"v_car_villefort_cortes_police_horn_traffic",
	n"v_car_villefort_cortes_police_siren_start",
	n"v_car_villefort_cortes_police_siren_stop",
	n"v_car_villefort_cortes_police_siren_traffic_start",
	n"v_car_villefort_cortes_police_siren_traffic_stop",

	// Traffic

	n"v_car_traffic_police_sirens"
	
]
