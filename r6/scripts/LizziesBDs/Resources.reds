// ************************************************************************************************
// ***  Lizzie's Braindances
// ***    Author: ArmanIII
// ***
// *** Please, if you will have unconquerable lust to edit this file (which I don't recommend),
// *** then please do not report any bugs you will encounter in the mod, because I don't want
// *** then spend X hours of searching of a bug which doesn't exist and in the end we find that
// *** it's all your fault. Help me save my nerves. Thanks.
// ***
// ************************************************************************************************

module LizziesBDs.Resources

import LizziesBDs.Classes.*
import LizziesBDs.Data.*

enum Sektory {
	Exterior_M2_0_0_5 = 0,
	Exterior_M9_6_1_2 = 1,
	Exterior_M5_3_0_3 = 2,
	Exterior_M3_1_0_4 = 3,
	Exterior_M18_13_2_1 = 4,
	Interior_4_16_3_1 = 5,
	Exterior_M26_16_0_0 = 6,
	Exterior_M26_15_0_0 = 7,
	Interior_M21_26_0_0 = 8,
	Interior_M11_13_0_1 = 9,
	Exterior_M2_M1_0_1 = 10,
	Exterior_M29_4_0_0 = 11,
	Quest_1d80ac67f39864eb = 12,
	Exterior_M13_3_0_1 = 13,
	Interior_51_M25_1_0 = 14,
	Interior_25_M13_0_1 = 15,
	Interior_M52_32_0_0 = 16,
	Prazdne = 100
}

public class LizziesBDsResources extends ScriptableService {
	public let poncInstalovan: Bool = false;
	public let bodInstalovan: Bool = false;
	public let letYouDownDataInstalovan: Bool = false;
	public let irwtsayhDataInstalovan: Bool = false;
	public let chiaaDataInstalovan: Bool = false;
	public let superpopulationInstalovan: Bool = false;
	public let incfInstalovan: Bool = false;

	private final func ErrLog(event: ref<ResourceEvent>) -> Void {
		let cesta: String = ResRef.ToString(event.GetPath());
		FTLog("[LizziesBDs] Error processing world sector: " + cesta + ", node count mismatch!");
	}

	@if(ModuleExists("INCF"))
	private final func INCF() -> Bool {
		return true;
	}

	@if(!ModuleExists("INCF"))
	private final func INCF() -> Bool {
		return false;
	}

	private cb func OnLoad() {
		this.poncInstalovan = GameInstance.GetResourceDepot().ResourceExists(r"pinkydude\\pleasures_of_nightcity\\anims_vol1\\workspots\\cowgirl\\ponc_synced_cowgirl_01_a.workspot");
		this.bodInstalovan = GameInstance.GetResourceDepot().ResourceExists(r"dp77\\x_dicks\\meshes\\i1_penis_regular_pma.mesh");
		this.letYouDownDataInstalovan = GameInstance.GetResourceDepot().ResourceExists(r"mod\\arman3_lizzies_bds\\movies\\let_you_down.bk2");
		this.irwtsayhDataInstalovan = GameInstance.GetResourceDepot().ResourceExists(r"mod\\arman3_lizzies_bds\\movies\\i_really_want_to_stay_at_your_house.bk2");
		this.chiaaDataInstalovan = GameInstance.GetResourceDepot().ResourceExists(r"mod\\arman3_lizzies_bds\\environment\\lizzies_bds_chiaa_bg.mesh");
		this.superpopulationInstalovan =
			GameInstance.GetResourceDepot().ArchiveExists("Superpopulation.archive") ||
			GameInstance.GetResourceDepot().ArchiveExists("Superpopulation Undrivable.archive") ||
			GameInstance.GetResourceDepot().ArchiveExists("Superpopulation E3 preset.archive") ||
			GameInstance.GetResourceDepot().ArchiveExists("Superpopulation Vanilla NPC Draw distance.archive");
		this.incfInstalovan = this.INCF();

		// ===============================================================================================================================
		// Konpeki Visuals
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M2_0_0_5")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-2_0_0_5.streamingsector"));
			
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M9_6_1_2")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-9_6_1_2.streamingsector"));
			
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M5_3_0_3")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-5_3_0_3.streamingsector"));
			
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M3_1_0_4")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-3_1_0_4.streamingsector"));
			
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M18_13_2_1")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-18_13_2_1.streamingsector"));
		// ===============================================================================================================================

		// ===============================================================================================================================
		// Arasaka Estate duvet
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Interior_4_16_3_1")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_4_16_3_1.streamingsector"));
		// ===============================================================================================================================

		// ===============================================================================================================================
		// Us Cracks - Riot sound emitters, DJ table
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M26_16_0_0")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-26_16_0_0.streamingsector"));
			
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M26_15_0_0")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-26_15_0_0.streamingsector"));
			
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Interior_M52_32_0_0")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_-52_32_0_0.streamingsector"));
		// ===============================================================================================================================

		// ===============================================================================================================================
		// Jig-Jig Street
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Interior_M21_26_0_0")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_-21_26_0_0.streamingsector"));
			
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Interior_M11_13_0_1")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_-11_13_0_1.streamingsector"));
		// ===============================================================================================================================
		
		// ===============================================================================================================================
		// Places of Night City - Bar in Charter Hill
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M2_M1_0_1")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-2_-1_0_1.streamingsector"));
		// ===============================================================================================================================
		
		// ===============================================================================================================================
		// Places of Night City - Bar in Downtown
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M29_4_0_0")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-29_4_0_0.streamingsector"));
		// ===============================================================================================================================
		
		// ===============================================================================================================================
		// Places of Night City - Afterlife Bar
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Quest_1d80ac67f39864eb")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\quest_1d80ac67f39864eb.streamingsector"));
		// ===============================================================================================================================
		
		// ===============================================================================================================================
		// Date - Empathy Club sit spot
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Exterior_M13_3_0_1")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-13_3_0_1.streamingsector"));
		// ===============================================================================================================================
		
		// ===============================================================================================================================
		// Sunset Motel
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Interior_51_M25_1_0")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_51_-25_1_0.streamingsector"));
			
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Ready", this, n"OnReady_Interior_25_M13_0_1")
			.AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_25_-13_0_1.streamingsector"));
		// ===============================================================================================================================

		// ===============================================================================================================================
		// ===============================================================================================================================
		// ===============================================================================================================================

		// ===============================================================================================================================
		// Dynamic preview
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnLoaded_Preview")
			.AddTarget(ResourceTarget.Path(r"mod\\arman3_lizzies_bds\\gameplay\\gui\\preview\\preview.dtex"));
		// ===============================================================================================================================

		// ===============================================================================================================================
		// Heywood apartment interactions scene
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnLoaded_DLC6_Apart_Hey_Gle_Interactions")
			.AddTarget(ResourceTarget.Path(r"dlc\\dlc6_apart\\loc_dlc6_apart_hey_gle\\quest\\scenes\\dlc6_apart_hey_gle_interactions.scene"));
		// ===============================================================================================================================

		// ===============================================================================================================================
		// Roller coaster scene
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnLoaded_MQ006_02_Finale")
			.AddTarget(ResourceTarget.Path(r"base\\quest\\minor_quests\\mq006\\scenes\\mq006_02_finale.scene"));
		// ===============================================================================================================================

		// ===============================================================================================================================
		// Facial scene
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnLoaded_Facial")
			.AddTarget(ResourceTarget.Path(r"mod\\arman3_lizzies_bds\\quest\\scenes\\lizzies_bds_oblicej.scene"));
		// ===============================================================================================================================

	}

	private cb func OnReady_Exterior_M2_0_0_5(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M2_0_0_5, event);
	}

	private cb func OnReady_Exterior_M9_6_1_2(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M9_6_1_2, event);
	}

	private cb func OnReady_Exterior_M5_3_0_3(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M5_3_0_3, event);
	}

	private cb func OnReady_Exterior_M3_1_0_4(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M3_1_0_4, event);
	}

	private cb func OnReady_Exterior_M18_13_2_1(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M18_13_2_1, event);
	}

	private cb func OnReady_Interior_4_16_3_1(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Interior_4_16_3_1, event);
	}

	private cb func OnReady_Exterior_M26_16_0_0(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M26_16_0_0, event);
	}

	private cb func OnReady_Exterior_M26_15_0_0(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M26_15_0_0, event);
	}

	private cb func OnReady_Interior_M52_32_0_0(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Interior_M52_32_0_0, event);
	}

	private cb func OnReady_Interior_M21_26_0_0(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Interior_M21_26_0_0, event);
	}

	private cb func OnReady_Interior_M11_13_0_1(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Interior_M11_13_0_1, event);
	}

	private cb func OnReady_Exterior_M2_M1_0_1(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M2_M1_0_1, event);
	}

	private cb func OnReady_Exterior_M29_4_0_0(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M29_4_0_0, event);
	}

	private cb func OnReady_Quest_1d80ac67f39864eb(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Quest_1d80ac67f39864eb, event);
	}

	private cb func OnReady_Exterior_M13_3_0_1(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Exterior_M13_3_0_1, event);
	}

	private cb func OnReady_Interior_51_M25_1_0(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Interior_51_M25_1_0, event);
	}

	private cb func OnReady_Interior_25_M13_0_1(event: ref<ResourceEvent>) {
		this.NastavitSektor(Sektory.Interior_25_M13_0_1, event);
	}

	private final func NastavitSektor(typ: Sektory, event: ref<ResourceEvent>) -> Void {
		let sector: ref<worldStreamingSector> = event.GetResource() as worldStreamingSector;

		if
			Equals(typ, Sektory.Exterior_M2_0_0_5) ||
			Equals(typ, Sektory.Exterior_M9_6_1_2) ||
			Equals(typ, Sektory.Exterior_M5_3_0_3) ||
			Equals(typ, Sektory.Exterior_M3_1_0_4) ||
			Equals(typ, Sektory.Exterior_M18_13_2_1)
		{
			let q005_done: Bool = GameInstance.GetQuestsSystem(GetGameInstance()).GetFact(n"q005_done") > 0;
			if q005_done {
				
				if Equals(typ, Sektory.Exterior_M2_0_0_5) {
					if sector.GetNodeSetupCount() == 105 {
						this.ZpracovatUzel(0, event, 99, n"worldTriggerAreaNode"); //{T_lockdown}
						this.ZpracovatUzel(0, event, 71, n"worldTriggerAreaNode"); //trigger

						//let nodes = sector.GetNodes();
						//let node = nodes[95] as worldTriggerAreaNode;
						//if IsDefined(node) {  }
					} else { this.ErrLog(event); }
				}
				
				if Equals(typ, Sektory.Exterior_M9_6_1_2) {
					if sector.GetNodeSetupCount() == 1664 {
						this.ZpracovatUzel(0, event, 65, n"worldTriggerAreaNode"); //{T_penthouse}
						this.ZpracovatUzel(0, event, 1662, n"worldTriggerAreaNode"); //{T_lock_exposure_exterior}
					} else { this.ErrLog(event); }
				}
				
				if Equals(typ, Sektory.Exterior_M5_3_0_3) {
					if sector.GetNodeSetupCount() == 1740 {
						this.ZpracovatUzel(0, event, 1727, n"worldTriggerAreaNode"); //{T_rain_fog}
					} else { this.ErrLog(event); }
				}
				
				if Equals(typ, Sektory.Exterior_M3_1_0_4) {
					if sector.GetNodeSetupCount() == 249 {
						this.ZpracovatUzel(0, event, 247, n"worldTriggerAreaNode"); //{T_rain_fog}
					} else { this.ErrLog(event); }
				}
				
				if Equals(typ, Sektory.Exterior_M18_13_2_1) {
					if sector.GetNodeSetupCount() == 775 {
						this.ZpracovatUzel(0, event, 774, n"worldTriggerAreaNode"); //{exposure_lock}
					} else { this.ErrLog(event); }
				}
			}
		}
		else if Equals(typ, Sektory.Interior_4_16_3_1) {
			if sector.GetNodeSetupCount() == 233 {
				this.ZpracovatUzel(1, event, 30, n"worldStaticMeshNode", "$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_arasaka_estate_duvet");
			} else { this.ErrLog(event); }
		}
		else if
			Equals(typ, Sektory.Interior_M21_26_0_0) ||
			Equals(typ, Sektory.Interior_M11_13_0_1)
		{
			if Equals(typ, Sektory.Interior_M21_26_0_0) {
				if sector.GetNodeSetupCount() == 402 {
					this.ZpracovatUzel(0, event, 321, n"worldInstancedMeshNode");
					this.ZpracovatUzel(0, event, 327, n"worldInstancedMeshNode");
					this.ZpracovatUzel(0, event, 166, n"worldStaticMeshNode");
					this.ZpracovatUzel(0, event, 326, n"worldInstancedMeshNode");
					this.ZpracovatUzel(0, event, 318, n"worldInstancedMeshNode");
					this.ZpracovatUzel(0, event, 161, n"worldStaticMeshNode");
					this.ZpracovatUzel(0, event, 169, n"worldStaticMeshNode");
					this.ZpracovatUzel(0, event, 225, n"worldStaticMeshNode");
					this.ZpracovatUzel(0, event, 150, n"worldStaticMeshNode");
					this.ZpracovatUzel(0, event, 293, n"worldStaticMeshNode");
					this.ZpracovatUzel(0, event, 149, n"worldStaticMeshNode");
					this.ZpracovatUzel(0, event, 317, n"worldInstancedMeshNode");
					this.ZpracovatUzel(0, event, 322, n"worldInstancedMeshNode");
				} else { this.ErrLog(event); }
			}
			
			if Equals(typ, Sektory.Interior_M11_13_0_1) {
				if sector.GetNodeSetupCount() == 22 {
					this.ZpracovatUzel(0, event, 6, n"worldEntityNode");
				} else { this.ErrLog(event); }
			}
		}
		else if Equals(typ, Sektory.Exterior_M26_16_0_0) {
			if sector.GetNodeSetupCount() == 654 {
				this.ZpracovatUzel(0, event, 241, n"worldStaticSoundEmitterNode");
				this.ZpracovatUzel(0, event, 242, n"worldStaticSoundEmitterNode");
				this.ZpracovatUzel(0, event, 243, n"worldStaticSoundEmitterNode");
				this.ZpracovatUzel(0, event, 244, n"worldStaticSoundEmitterNode");

				this.ZpracovatUzel(0, event, 226, n"worldInstancedDestructibleMeshNode"); //poor_bar_stool_a
				this.ZpracovatUzel(0, event, 208, n"worldInstancedDestructibleMeshNode"); //drink_bottle_i_beer
				this.ZpracovatUzel(0, event, 209, n"worldInstancedDestructibleMeshNode"); //drink_bottle_i_beer
				this.ZpracovatUzel(0, event, 219, n"worldInstancedDestructibleMeshNode"); //military_grade_laptop_a_screen
				this.ZpracovatUzel(0, event, 205, n"worldInstancedDestructibleMeshNode"); //microphone_a_arm_short_a
				this.ZpracovatUzel(0, event, 202, n"worldInstancedDestructibleMeshNode"); //microphone_a
				this.ZpracovatUzel(0, event, 206, n"worldInstancedDestructibleMeshNode"); //microphone_a_stand_short_a_001
				this.ZpracovatUzel(0, event, 216, n"worldInstancedDestructibleMeshNode"); //router_a_003
				this.ZpracovatUzel(0, event, 304, n"worldStaticMeshNode"); //decal_wall_stickers_u
				this.ZpracovatUzel(0, event, 207, n"worldInstancedDestructibleMeshNode"); //drink_bottle_i_beer
				this.ZpracovatUzel(0, event, 393, n"worldInstancedMeshNode"); //
				this.ZpracovatUzel(0, event, 227, n"worldInstancedDestructibleMeshNode"); //military_grade_laptop_a_body_002
				this.ZpracovatUzel(0, event, 220, n"worldInstancedDestructibleMeshNode"); //military_grade_laptop_a_screen_002
				this.ZpracovatUzel(0, event, 233, n"worldInstancedDestructibleMeshNode"); //speaker_a_single_a
				this.ZpracovatUzel(0, event, 305, n"worldStaticMeshNode"); //cable_connector_a_med_001
				this.ZpracovatUzel(0, event, 328, n"worldStaticMeshNode"); //arasaka_computing_unit_b
				this.ZpracovatUzel(0, event, 310, n"worldStaticMeshNode"); //cable_connector_a_plug_big_001
				this.ZpracovatUzel(0, event, 311, n"worldStaticMeshNode"); //cable_connector_a_plug_big
				this.ZpracovatUzel(0, event, 306, n"worldStaticMeshNode"); //cable_connector_a_med
				this.ZpracovatUzel(0, event, 345, n"worldStaticMeshNode"); //cable_9m_90_right_a
				this.ZpracovatUzel(0, event, 360, n"worldStaticMeshNode"); //cable_9m_0_right_a
				this.ZpracovatUzel(0, event, 327, n"worldStaticMeshNode"); //arasaka_airconditioner_a_exterior
				this.ZpracovatUzel(0, event, 324, n"worldStaticMeshNode"); //router_a_002
				this.ZpracovatUzel(0, event, 332, n"worldStaticMeshNode"); //kitsch_dj_set_b
				this.ZpracovatUzel(0, event, 318, n"worldStaticMeshNode"); //router_b
				this.ZpracovatUzel(0, event, 315, n"worldStaticMeshNode"); //kitsch_dj_set_b_part_c
				this.ZpracovatUzel(0, event, 307, n"worldStaticMeshNode"); //decal_wall_stickers_m
				this.ZpracovatUzel(0, event, 321, n"worldStaticMeshNode"); //kitsch_dj_set_b_part_b
				this.ZpracovatUzel(0, event, 320, n"worldStaticMeshNode"); //kitsch_dj_set_b_part_b_rev
				this.ZpracovatUzel(0, event, 314, n"worldStaticMeshNode"); //kitsch_dj_set_b_part_c_rev
				this.ZpracovatUzel(0, event, 317, n"worldStaticMeshNode"); //kitsch_dj_set_a_part_c
				this.ZpracovatUzel(0, event, 322, n"worldStaticMeshNode"); //kitsch_dj_set_a_part_b_rev
				this.ZpracovatUzel(0, event, 316, n"worldStaticMeshNode"); //kitsch_dj_set_a_part_c_rev
				this.ZpracovatUzel(0, event, 349, n"worldStaticMeshNode"); //keyboard_b
				this.ZpracovatUzel(0, event, 411, n"worldInstancedMeshNode"); //
				this.ZpracovatUzel(0, event, 412, n"worldInstancedMeshNode"); //
				this.ZpracovatUzel(0, event, 319, n"worldStaticMeshNode"); //router_a
				this.ZpracovatUzel(0, event, 333, n"worldStaticMeshNode"); //kitsch_dj_set_a
				this.ZpracovatUzel(0, event, 417, n"worldInstancedMeshNode"); //
				this.ZpracovatUzel(0, event, 435, n"worldInstancedMeshNode"); //
				this.ZpracovatUzel(0, event, 406, n"worldInstancedMeshNode"); //
			} else { this.ErrLog(event); }
		}
		else if Equals(typ, Sektory.Exterior_M26_15_0_0) {
			if sector.GetNodeSetupCount() == 1737 {
				this.ZpracovatUzel(0, event, 813, n"worldStaticSoundEmitterNode");
			} else { this.ErrLog(event); }
		}
		else if Equals(typ, Sektory.Interior_M52_32_0_0) {
			if sector.GetNodeSetupCount() == 161 {
				this.ZpracovatUzel(0, event, 2, n"worldInstancedDestructibleMeshNode"); //microphone_a_arm_short_a_003
				this.ZpracovatUzel(0, event, 1, n"worldInstancedDestructibleMeshNode"); //microphone_a_003
				this.ZpracovatUzel(0, event, 10, n"worldInstancedDestructibleMeshNode"); //microphone_a_stand_tall_a_003
			} else { this.ErrLog(event); }
		}
		else if Equals(typ, Sektory.Exterior_M2_M1_0_1) {
			if sector.GetNodeSetupCount() == 3661 {
				this.ZpracovatUzel(2, event, 250, n"worldAISpotNode", "", new Vector4(-238.529388, -52.9806099, -2.801166415, 0.0), new Quaternion(0.0, 0.0, 0.99619472, -0.0871557444));
				this.ZpracovatUzel(2, event, 251, n"worldAISpotNode", "", new Vector4(-239.949707, -53.4665565, -2.801828027, 0.0), new Quaternion(0.0, 0.0, 0.963630497, -0.267238379));
			} else { this.ErrLog(event); }
		}
		else if Equals(typ, Sektory.Exterior_M29_4_0_0) {
			if sector.GetNodeSetupCount() == 1675 {
				this.ZpracovatUzel(2, event, 33, n"worldAISpotNode", "", new Vector4(-1820.12781, 294.202393, 5.5783596, 0.0), new Quaternion(0.0, 0.0, 0.342020035, 0.939692676));
				this.ZpracovatUzel(2, event, 41, n"worldAISpotNode", "", new Vector4(-1820.23975, 295.532074, 5.5783596, 0.0), new Quaternion(0.0, 0.0, -0.965925872, -0.258819163));
			} else { this.ErrLog(event); }
		}
		else if Equals(typ, Sektory.Quest_1d80ac67f39864eb) {
			if sector.GetNodeSetupCount() == 120 {
				this.ZpracovatUzel(2, event, 57, n"worldAISpotNode", "", new Vector4(-1437.773, 1009.132, 16.5, 0.0), new Quaternion(0.0, 0.0, 0.656, 0.755));
				this.ZpracovatUzel(2, event, 26, n"worldAISpotNode", "", new Vector4(-1438.213, 1010.512, 16.5, 0.0), new Quaternion(0.0, 0.0, 0.636, 0.772));
				this.ZpracovatUzel(2, event, 39, n"worldAISpotNode", "", new Vector4(-1438.903, 1010.732, 16.51, 0.0), new Quaternion(0.0, 0.0, 0.993, 0.122));
				this.ZpracovatUzel(2, event, 46, n"worldAISpotNode", "", new Vector4(-1443.863, 1010.012, 16.490, 0.0), new Quaternion(0.0, 0.0, -0.078, 0.997));
			} else { this.ErrLog(event); }
		}
		else if Equals(typ, Sektory.Exterior_M13_3_0_1) {
			if sector.GetNodeSetupCount() == 547 {
				this.ZpracovatUzel(2, event, 146, n"worldAISpotNode", "", new Vector4(-1625.349, 393.332, 8.110, 0.0), new Quaternion(0.0, 0.0, 0.999, 0.052));
			} else { this.ErrLog(event); }
		}
		else if
			Equals(typ, Sektory.Interior_51_M25_1_0) ||
			Equals(typ, Sektory.Interior_25_M13_0_1)
		{
			if Equals(typ, Sektory.Interior_51_M25_1_0) {
				if sector.GetNodeSetupCount() == 396 {
					this.ZpracovatUzel(0, event, 34, n"worldStaticDecalNode");
					this.ZpracovatUzel(0, event, 22, n"worldStaticDecalNode");
					this.ZpracovatUzel(0, event, 39, n"worldStaticDecalNode");
					this.ZpracovatUzel(0, event, 355, n"worldInstancedMeshNode");
					this.ZpracovatUzel(0, event, 21, n"worldStaticDecalNode");
					this.ZpracovatUzel(0, event, 354, n"worldInstancedMeshNode");
					this.ZpracovatUzel(0, event, 60, n"worldStaticDecalNode");
					this.ZpracovatUzel(0, event, 267, n"worldStaticMeshNode");
					this.ZpracovatUzel(0, event, 353, n"worldInstancedMeshNode");
					this.ZpracovatUzel(0, event, 47, n"worldStaticDecalNode");
				} else { this.ErrLog(event); }
			}
			
			if Equals(typ, Sektory.Interior_25_M13_0_1) {
				if sector.GetNodeSetupCount() == 108 {
					this.ZpracovatUzel(0, event, 52, n"worldStaticMeshNode");
				} else { this.ErrLog(event); }
			}
		}
		/*else if Equals(typ, Sektory.Exterior_M26_16_0_0) {
			let sector: ref<worldStreamingSector> = event.GetResource() as worldStreamingSector;
			if sector.GetNodeSetupCount() == 654 {
				sector.GetNodeSetup(241).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_uscracks_riot_emitter_01"));
				sector.GetNodeSetup(242).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_uscracks_riot_emitter_02"));
				sector.GetNodeSetup(243).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_uscracks_riot_emitter_03"));
				sector.GetNodeSetup(244).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_uscracks_riot_emitter_04"));
			} else { this.ErrLog(typ); }
		}
		else if Equals(typ, Sektory.Exterior_M26_15_0_0) {
			let sector: ref<worldStreamingSector> = event.GetResource() as worldStreamingSector;
			if sector.GetNodeSetupCount() == 1737 {
				sector.GetNodeSetup(813).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_uscracks_riot_emitter_05"));
			} else { this.ErrLog(typ); }
		}
		else if
			Equals(typ, Sektory.Interior_M21_26_0_0) ||
			Equals(typ, Sektory.Interior_M11_13_0_1)
		{
			let sector: ref<worldStreamingSector> = event.GetResource() as worldStreamingSector;
			
			if Equals(typ, Sektory.Interior_M21_26_0_0) {
				if sector.GetNodeSetupCount() == 402 {
					sector.GetNodeSetup(321).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_01"));
					sector.GetNodeSetup(327).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_02"));
					sector.GetNodeSetup(166).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_03"));
					sector.GetNodeSetup(326).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_04"));
					sector.GetNodeSetup(318).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_05"));
					sector.GetNodeSetup(161).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_06"));
					sector.GetNodeSetup(169).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_07"));
					sector.GetNodeSetup(225).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_08"));
					sector.GetNodeSetup(150).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_09"));
					sector.GetNodeSetup(293).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_10"));
					sector.GetNodeSetup(149).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_11"));
					sector.GetNodeSetup(317).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_12"));
					sector.GetNodeSetup(322).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_13"));
				} else { this.ErrLog(typ); }
			}
			
			if Equals(typ, Sektory.Interior_M11_13_0_1) {
				if sector.GetNodeSetupCount() == 22 {
					sector.GetNodeSetup(6).SetNodeRef(CreateNodeRef("$/03_night_city/ArmanIII/#LizziesBDs_Various/#lizzies_bds_jigjig_room_14"));
				} else { this.ErrLog(typ); }
			}
		}*/
	}

	private func ZpracovatUzel(akce: Int32, event: ref<ResourceEvent>, index: Int32, ocekavanyTyp: CName, opt uzelRef: String, opt povaPozice: Vector4, opt povaRotace: Quaternion) -> Void {
		let sektor: ref<worldStreamingSector> = event.GetResource() as worldStreamingSector;
		let nodeSetup: ref<WorldNodeSetupWrapper> = sektor.GetNodeSetup(index);
		let node: ref<worldNode> = nodeSetup.GetNode();
		let trida: CName = node.GetClassName();

		if NotEquals(trida, ocekavanyTyp) {
			let cesta: String = ResRef.ToString(event.GetPath());
			FTLog("[LizziesBDs] Error processing world sector: " + cesta + ", Node: #" + index + ", Expected type: " + NameToString(ocekavanyTyp) + ", Got: " + NameToString(trida));
			return;
		}

		if Equals(trida, n"worldInstancedMeshNode") {
			let nodeInst: ref<worldInstancedMeshNode> = node as worldInstancedMeshNode;
			//nodeInst.worldTransformsBuffer.numElements = 0u;
			nodeInst.isVisibleInGame = false;
		} else {
			if akce == 0 {
				let zeroPos: Vector4 = new Vector4(0.0, 0.0, -10000.0, 0);
				nodeSetup.SetPosition(zeroPos);
			}
			if akce == 1 {
				nodeSetup.SetNodeRef(CreateNodeRef(uzelRef));
			}
			if akce == 2 {
				nodeSetup.SetPosition(povaPozice);
				nodeSetup.SetOrientation(povaRotace);
			}
		}
	}
	
	private cb func OnLoaded_MQ006_02_Finale(event: ref<ResourceEvent>) {
		let scnSceneResource: ref<scnSceneResource> = event.GetResource() as scnSceneResource;

		let i = 0;
		while i < ArraySize(scnSceneResource.sceneGraph.graph) {
			let nodeCasted: ref<scnQuestNode> = scnSceneResource.sceneGraph.graph[i] as scnQuestNode;
			if IsDefined(nodeCasted) {
				if nodeCasted.nodeId.id == 1091u {
					let nodeCastedDef: ref<questPauseConditionNodeDefinition> = nodeCasted.questNode as questPauseConditionNodeDefinition;
					if IsDefined(nodeCastedDef) {
						let logicalCond: ref<questLogicalCondition> = new questLogicalCondition();
						logicalCond.operation = questLogicalOperation.AND;
						logicalCond.conditions = [];

						let condCameraFocus: ref<questCameraFocus_ConditionType> = new questCameraFocus_ConditionType();
						condCameraFocus.onScreenTest = true;
						condCameraFocus.timeInterval = 0.2;
						condCameraFocus.angleTolerance = 30;
						condCameraFocus.inverted = false;
						condCameraFocus.zoomed = false;
						condCameraFocus.useFrustrumCheck = false;

						let entRef: EntityReference;
						entRef.reference = CreateNodeRef("#mq006_rollercoaster_cart_001");
						condCameraFocus.objectRef = entRef;

						let systemCondition: ref<questSystemCondition> = new questSystemCondition();
						systemCondition.type = condCameraFocus;
						ArrayPush(logicalCond.conditions, systemCondition);


						let varComparison: ref<questVarComparison_ConditionType> = new questVarComparison_ConditionType();
						varComparison.comparisonType = EComparisonType.Equal;
						varComparison.factName = "lizzies_bds_active";
						varComparison.value = 0;

						let factCondition: ref<questFactsDBCondition> = new questFactsDBCondition();
						factCondition.type = varComparison;
						ArrayPush(logicalCond.conditions, factCondition);


						nodeCastedDef.condition = logicalCond;
						i = 9999;
					}
				}
			}
			i += 1;
		}
	}
	
	private cb func OnLoaded_DLC6_Apart_Hey_Gle_Interactions(event: ref<ResourceEvent>) {
		let scnSceneResource: ref<scnSceneResource> = event.GetResource() as scnSceneResource;

		let i = 0;
		while i < ArraySize(scnSceneResource.sceneGraph.graph) {
			let nodeCasted: ref<scnQuestNode> = scnSceneResource.sceneGraph.graph[i] as scnQuestNode;
			if IsDefined(nodeCasted) {
				if nodeCasted.nodeId.id == 1112u {
					let nodeCastedDef: ref<questPauseConditionNodeDefinition> = nodeCasted.questNode as questPauseConditionNodeDefinition;
					if IsDefined(nodeCastedDef) {
						let logicalCond: ref<questLogicalCondition> = new questLogicalCondition();
						logicalCond.operation = questLogicalOperation.OR;
						logicalCond.conditions = [];

						let condTrigger: ref<questTriggerCondition> = new questTriggerCondition();
						condTrigger.isPlayerActivator = true;
						condTrigger.triggerAreaRef = CreateNodeRef("#dlc6_apart_hey_gle_tr_apartment");
						condTrigger.type = questTriggerConditionType.IsOutside;

						let entRef: EntityReference;
						condTrigger.activatorRef = entRef;

						ArrayPush(logicalCond.conditions, condTrigger);


						let varComparison: ref<questVarComparison_ConditionType> = new questVarComparison_ConditionType();
						varComparison.comparisonType = EComparisonType.Equal;
						varComparison.factName = "apartment_on";
						varComparison.value = 0;

						let factCondition: ref<questFactsDBCondition> = new questFactsDBCondition();
						factCondition.type = varComparison;
						ArrayPush(logicalCond.conditions, factCondition);


						nodeCastedDef.condition = logicalCond;
						i = 9999;
					}
				}
			}
			i += 1;
		}
	}
	
	private cb func OnLoaded_Facial(event: ref<ResourceEvent>) {
		let sceneResource: ref<scnSceneResource> = event.GetResource() as scnSceneResource;
		let i = 0;
		while i < ArraySize(sceneResource.sceneGraph.graph) {
			let sectionNode = sceneResource.sceneGraph.graph[i] as scnSectionNode;
			if IsDefined(sectionNode) {
				let j = 0;
				while j < ArraySize(sectionNode.events) {
					let event = sectionNode.events[j] as scnChangeIdleAnimEvent;
					if IsDefined(event) {
						let index: Int32 = -1;

						if event.id.id == 4166884328588238848ul { index = 0; }
						else if event.id.id == 4166884328588238847ul { index = 1; }
						else if event.id.id == 4166884328588238846ul { index = 2; }
						else if event.id.id == 4166884328588238845ul { index = 3; }
						else if event.id.id == 4166884328588238844ul { index = 4; }
						else if event.id.id == 4166884328588238843ul { index = 5; }

						if index >= 0 {
							let oblicejKlid: Int32 = GameInstance.GetQuestsSystem(GetGameInstance()).GetFact(StringToName(Konstanty.FaktVybranyOblicejKlid() + ToString(index)));
							let oblicejPoza: Int32 = GameInstance.GetQuestsSystem(GetGameInstance()).GetFact(StringToName(Konstanty.FaktVybranyOblicejPoza() + ToString(index)));
							let oblicejKlidVaha: Int32 = GameInstance.GetQuestsSystem(GetGameInstance()).GetFact(StringToName(Konstanty.FaktVybranyOblicejKlidVaha() + ToString(index)));
							let oblicejPozaVaha: Int32 = GameInstance.GetQuestsSystem(GetGameInstance()).GetFact(StringToName(Konstanty.FaktVybranyOblicejPozaVaha() + ToString(index)));

							let data: array<CName> = DataPoleOblicejeAnimace(oblicejKlid, oblicejPoza);

							oblicejKlidVaha = 10 - oblicejKlidVaha;
							oblicejPozaVaha = 10 - oblicejPozaVaha;

							event.bakedFacialTransition.facialKey_Female = data[2];
							event.bakedFacialTransition.facialKey_Male = data[3];
							event.bakedFacialTransition.toIdleFemale = data[0];
							event.bakedFacialTransition.toIdleMale = data[1];
							
							event.bakedFacialTransition.facialKeyWeight = Cast<Float>(oblicejPozaVaha) / 10.0;
							event.bakedFacialTransition.toIdleWeight = Cast<Float>(oblicejKlidVaha) / 10.0;
						}
					}
					j += 1;
				}
			}
			i += 1;
		}
	}
	
	private cb func OnLoaded_Preview(event: ref<ResourceEvent>) {
		let nastaveni: Int32 = GameInstance.GetQuestsSystem(GetGameInstance()).GetFact(Konstanty.FaktNastaveniDynNahledKvalita());
		if nastaveni > 0 {
			let dynamicTexture: ref<DynamicTexture> = event.GetResource() as DynamicTexture;
			if nastaveni == 1 {
				dynamicTexture.scaleToViewport = false;
				dynamicTexture.height = 768u;
				dynamicTexture.width = 738u;
			}
			if nastaveni == 2 {
				dynamicTexture.scaleToViewport = false;
				dynamicTexture.height = 512u;
				dynamicTexture.width = 492u;
			}
			if nastaveni == 3 {
				dynamicTexture.scaleToViewport = false;
				dynamicTexture.height = 256u;
				dynamicTexture.width = 246u;
			}
		}
	}
}
