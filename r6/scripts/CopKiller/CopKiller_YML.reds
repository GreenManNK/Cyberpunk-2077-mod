module CopKiller

public class CopKillerTweaksSSX extends ScriptableService {

	public func CharList_Cops_Base_Records() -> array<TweakDBID> = [
		t"Character.bou_kurtz_base_drone_wyvern",
		t"Character.bou_kurtz_base_minotaur",
		t"Character.combat_tower_kurtz_base_drone_wyvern",
		t"Character.combat_tower_kurtz_base_minotaur",
		t"Character.combat_zone_gate_kurtz_base_drone_wyvern",
		t"Character.combat_zone_gate_kurtz_base_minotaur",
		t"Character.con_kurtz_base_drone_wyvern",
		t"Character.con_kurtz_base_minotaur",
		t"Character.hpark_kurtz_base_drone_wyvern",
		t"Character.hpark_kurtz_base_minotaur",
		t"Character.kurtz_base_drone_wyvern",
		t"Character.kurtz_base_minotaur",
		t"Character.maxtac_base",
		t"Character.mon_kurtz_base_drone_wyvern",
		t"Character.mon_kurtz_base_minotaur",
		t"Character.ncpd_base",
		t"Character.ncpd_base_android",
		t"Character.ncpd_base_drone_bombus",
		t"Character.ncpd_base_drone_wyvern",
		t"Character.ncpd_base_ma",
		t"Character.ncpd_base_mb",
		t"Character.ncpd_base_minotaur",
		t"Character.ncpd_base_wa",
		t"Character.netwatch_base_ma",
		t"Character.Police",
		t"Character.Policeman",
		t"Character.PolicemanBig",
		t"Character.PoliceWoman",
		t"Character.prevention_dogtown_base_drone_bombus",
		t"Character.prevention_dogtown_base_drone_wyvern",
		t"Character.prevnetion_dogtown_base_minotaur", // Mispelled, Unalphabetized
		t"Character.prevention_maxtac_av_base",
		t"Character.prevention_maxtac_base",
		t"Character.prevention_unit_android_base",
		t"Character.prevention_unit_base",
		t"Character.q302_patrol_prevention_dogtown_base_drone_bombus",
		t"Character.q302_patrol_prevention_dogtown_base_drone_wyvern",
		t"Character.q302_patrol_prevnetion_dogtown_base_minotaur", // Mispelled, Unalphabetized
		t"Character.security_base_android",
		t"Character.sta_kurtz_base_drone_wyvern",
		t"Character.sta_kurtz_base_minotaur"
	]

	public func CharList_Cops_Quest() -> array<TweakDBID> = [
		t"Character.California_Sheriff",
		t"Character.kab_ncpd_fake_police_ma", // Police Impersonator, NPC that argues w Tyger Claws in Kabuki, Stun Baton
		t"Character.ma_outposts_ncpd_dispatch",
		t"Character.ma_outposts_ncpd_soldier",
		t"Character.ma_wat_kab_02_ncpd",
		t"Character.ma_wat_lch_07_police_man",
		t"Character.mws_arr_03_cop",
		t"Character.mws_gang_retaliation_enemies_netwatch_leader_1",
		t"Character.mws_gang_retaliation_enemies_netwatch_leader_2",
		t"Character.mws_gang_retaliation_enemies_netwatch_sidekick_1",
		t"Character.mws_gang_retaliation_enemies_netwatch_sidekick_2",
		t"Character.mws_wat_04_cop",
		t"Character.mq005_police_officer_01",
		t"Character.mq005_police_officer_02",
		t"Character.mq005_police_officer_03",
		t"Character.mq010_barry",
		t"Character.mq010_policeman",
		t"Character.mq010_policewoman",
		t"Character.mq021_corpo",
		t"Character.mq021_shotgun_corpo",
		t"Character.mq030_max_tac_1",
		t"Character.mq030_max_tac_2",
		t"Character.mq030_max_tac_3",
		t"Character.mq030_max_tac_4",
		t"Character.mq030_max_tac_no_combat",
		t"Character.mq030_melisa",
		t"Character.mq305_post_netwatch",
		t"Character.mws_se5_03_enemy_01",
		t"Character.mws_wbr_02_supercop_mb",
		t"Character.ncpd_female_spokesperson",
		t"Character.q000_roadhouse_town_male_defender_pulsar",
		t"Character.q000_roadhouse_town_male_defender_tactician",
		t"Character.q000_roadhouse_town_male_defender_nova",
		t"Character.q001_holo_coroner",
		t"Character.q001_holo_police_officer",
		t"Character.q001_holo_tech_01",
		t"Character.q001_holo_tech_02",
		t"Character.q001_ncpd_minotaur",
		t"Character.q301_shuttle_ss_agent_ma",
		t"Character.q301_shuttle_ss_agent_wa",
		t"Character.q302_patrol_inVehicle_prevention_dogtown_rifle_ma",
		t"Character.q302_patrol_inVehicle_prevention_dogtown_rifle_wa",
		t"Character.q302_patrol_prevention_dogtown_droid_ma",
		t"Character.q302_patrol_prevention_dogtown_HMG_mb",
		t"Character.q302_patrol_prevention_dogtown_HMG_mb_barricade",
		t"Character.q302_patrol_prevention_dogtown_martial_fmelee3_fists_ma_rare",
		t"Character.q302_patrol_prevention_dogtown_martial_hmelee3_fists_mb_elite",
		t"Character.q302_patrol_prevention_dogtown_rifle_ma",
		t"Character.q302_patrol_prevention_dogtown_rifle_wa",
		t"Character.q302_patrol_prevention_dogtown_saratoga_ma",
		t"Character.q302_patrol_prevention_dogtown_saratoga_wa",
		t"Character.q302_patrol_prevention_dogtown_shotgun_ma",
		t"Character.q302_patrol_prevention_dogtown_shotgun_ma_barricade",
		t"Character.q302_patrol_prevention_recon_sniper2_achilles_ma_rare",
		t"Character.q303_lobby_prevention_guard_rifle_ma",
		t"Character.q303_lobby_prevention_guard_saratoga_ma",
		t"Character.q305_maxtac_heavy",
		t"Character.q305_maxtac_melee",
		t"Character.q305_maxtac_rifle_ma",
		t"Character.q305_maxtac_rifle_wa",
		t"Character.q305_maxtac_shotgun",
		t"Character.q305_maxtac_sniper",
		t"Character.q306_cloaked_hunter",
		t"Character.q306_orbital_air_failstate_guard",
		t"Character.sa_ep1_courier_introquest_buyer",
		t"Character.sa_ep1_courier_introquest_driver",
		t"Character.sa_ep1_courier_outro_undercover_police_01",
		t"Character.Sobchak",
		t"Character.spaceport_npcd_non_reaction_ma",
		t"Character.spaceport_npcd_non_reaction_wa",
		t"Character.sq017_chase_policeman",
		t"Character.sq023_policeman_road_block",
		t"Character.sq023_policewoman_road_block",
		t"Character.sq023_vasquez",
		t"Character.sts_ep1_06_cop",
		t"Character.sts_wat_kab_08_dave_hamill"
	]

	public func CharList_Cops_Melee() -> array<TweakDBID> = [
		t"Character.arr_ncpd_constable_melee1_baton_ma",
		t"Character.arr_ncpd_police_melee2_baton_ma",
		t"Character.cpz_ncpd_constable_melee1_baton_ma",
		t"Character.cpz_ncpd_police_melee2_baton_ma",
		t"Character.cvi_ncpd_constable_melee1_baton_ma",
		t"Character.dtn_ncpd_constable_melee1_baton_ma",
		t"Character.gle_ncpd_constable_melee1_baton_ma",
		t"Character.gle_ncpd_inspector_melee1_baton_ma",
		t"Character.hil_ncpd_constable_melee1_baton_ma",
		t"Character.jpn_ncpd_constable_melee1_baton_ma",
		t"Character.jpn_ncpd_police_melee2_baton_ma",
		t"Character.jpn_ncpd_police_melee2_baton_wa",
		t"Character.kab_ncpd_constable_melee1_baton_ma",
		t"Character.kab_ncpd_inspector_melee1_baton_ma",
		t"Character.kab_ncpd_police_melee2_baton_wa",
		t"Character.lch_ncpd_constable_melee1_baton_ma",
		t"Character.lch_ncpd_police_melee2_baton_ma",
		t"Character.lch_ncpd_police_melee2_baton_wa",
		t"Character.ncpd_constable_melee1_baton_ma",
		t"Character.ncpd_inspector_melee1_baton_ma",
		t"Character.ncpd_police_melee2_baton_ma",
		t"Character.ncpd_police_melee2_baton_wa",
		t"Character.nid_ncpd_constable_melee1_baton_ma",
		t"Character.nid_ncpd_inspector_melee1_baton_ma",
		t"Character.nid_ncpd_police_melee2_baton_ma",
		t"Character.nok_ncpd_constable_melee1_baton_ma",
		t"Character.rcr_ncpd_constable_melee1_baton_ma",
		t"Character.rey_ncpd_constable_melee1_baton_ma",
		t"Character.rey_ncpd_inspector_melee1_baton_ma",
		t"Character.spr_ncpd_constable_melee1_baton_ma",
		t"Character.spr_ncpd_police_melee2_baton_ma",
		t"Character.wwd_ncpd_constable_melee1_baton_ma"
	]

	public func CharList_Cops_Ranged() -> array<TweakDBID> = [
		t"Character.arr_ncpd_constable_ranged1_lexington_ma",
		t"Character.arr_ncpd_inspector_ranged1_lexington_ma",
		t"Character.arr_ncpd_investigator_officer_omaha_ma",
		t"Character.arr_ncpd_investigator_officer_omaha_wa",
		t"Character.arr_ncpd_police_ranged2_copperhead_ma",
		t"Character.arr_ncpd_police_ranged2_lexington_ma",
		t"Character.arr_ncpd_police_ranged2_saratoga_ma",
		t"Character.cpz_ncpd_constable_ranged1_lexington_ma",
		t"Character.cpz_ncpd_inspector_ranged1_lexington_ma",
		t"Character.cpz_ncpd_investigator_officer_omaha_ma",
		t"Character.cpz_ncpd_police_ranged2_copperhead_ma",
		t"Character.cpz_ncpd_police_ranged2_lexington_ma",
		t"Character.cpz_ncpd_police_ranged2_saratoga_ma",
		t"Character.cvi_ncpd_inspector_ranged1_lexington_ma",
		t"Character.cvi_ncpd_investigator_officer_omaha_ma",
		t"Character.cvi_ncpd_police_ranged2_copperhead_ma",
		t"Character.cvi_ncpd_police_ranged2_lexington_ma",
		t"Character.cvi_ncpd_police_ranged2_saratoga_ma",
		t"Character.dtn_ncpd_constable_ranged1_lexington_ma",
		t"Character.dtn_ncpd_inspector_ranged1_lexington_ma",
		t"Character.dtn_ncpd_investigator_officer_omaha_ma",
		t"Character.dtn_ncpd_police_ranged2_copperhead_ma",
		t"Character.dtn_ncpd_police_ranged2_lexington_ma",
		t"Character.dtn_ncpd_police_ranged2_saratoga_ma",
		t"Character.gle_ncpd_constable_ranged1_lexington_ma",
		t"Character.gle_ncpd_inspector_ranged1_lexington_ma",
		t"Character.gle_ncpd_investigator_officer_omaha_ma",
		t"Character.gle_ncpd_investigator_officer_omaha_wa",
		t"Character.gle_ncpd_police_ranged2_copperhead_ma",
		t"Character.gle_ncpd_police_ranged2_copperhead_wa",
		t"Character.gle_ncpd_police_ranged2_lexington_ma",
		t"Character.gle_ncpd_police_ranged2_saratoga_ma",
		t"Character.hil_ncpd_constable_ranged1_lexington_ma",
		t"Character.hil_ncpd_inspector_ranged1_lexington_ma",
		t"Character.hil_ncpd_investigator_officer_omaha_ma",
		t"Character.hil_ncpd_police_ranged2_copperhead_ma",
		t"Character.hil_ncpd_police_ranged2_lexington_ma",
		t"Character.hil_ncpd_police_ranged2_saratoga_ma",
		t"Character.jpn_ncpd_constable_ranged1_lexington_ma",
		t"Character.jpn_ncpd_inspector_ranged1_lexington_ma",
		t"Character.jpn_ncpd_investigator_officer_omaha_ma",
		t"Character.jpn_ncpd_investigator_officer_omaha_wa",
		t"Character.jpn_ncpd_police_ranged2_copperhead_ma",
		t"Character.jpn_ncpd_police_ranged2_lexington_ma",
		t"Character.jpn_ncpd_police_ranged2_lexington_wa",
		t"Character.jpn_ncpd_police_ranged2_saratoga_ma",
		t"Character.kab_ncpd_constable_ranged1_lexington_ma",
		t"Character.kab_ncpd_hazmat_ranged1_lexington_ma",
		t"Character.kab_ncpd_inspector_ranged1_lexington_ma",
		t"Character.kab_ncpd_investigator_officer_omaha_ma",
		t"Character.kab_ncpd_investigator_officer_omaha_wa",
		t"Character.kab_ncpd_police_ranged2_copperhead_ma",
		t"Character.kab_ncpd_police_ranged2_lexington_ma",
		t"Character.kab_ncpd_police_ranged2_saratoga_ma",
		t"Character.lch_ncpd_hazmat_ranged1_lexington_ma",
		t"Character.lch_ncpd_inspector_ranged1_lexington_ma",
		t"Character.lch_ncpd_investigator_officer_omaha_ma",
		t"Character.lch_ncpd_investigator_officer_omaha_wa",
		t"Character.lch_ncpd_police_ranged2_copperhead_ma",
		t"Character.lch_ncpd_police_ranged2_lexington_ma",
		t"Character.lch_ncpd_police_ranged2_lexington_wa",
		t"Character.lch_ncpd_police_ranged2_saratoga_ma",
		t"Character.lch_ncpd_police_ranged2_saratoga_wa",
		t"Character.ncpd_biker_ranged2_omaha_ma",
		t"Character.ncpd_constable_ranged1_lexington_ma",
		t"Character.ncpd_hazmat_ranged1_lexington_ma",
		t"Character.ncpd_inspector_ranged1_lexington_ma",
		t"Character.ncpd_investigator_officer_omaha_ma",
		t"Character.ncpd_investigator_officer_omaha_wa",
		t"Character.ncpd_police_ranged2_copperhead_ma",
		t"Character.ncpd_police_ranged2_copperhead_wa",
		t"Character.ncpd_police_ranged2_lexington_ma",
		t"Character.ncpd_police_ranged2_lexington_wa",
		t"Character.ncpd_police_ranged2_saratoga_ma",
		t"Character.ncpd_police_ranged2_saratoga_wa",
		t"Character.nid_ncpd_constable_ranged1_lexington_ma",
		t"Character.nid_ncpd_hazmat_ranged1_lexington_ma",
		t"Character.nid_ncpd_inspector_ranged1_lexington_ma",
		t"Character.nid_ncpd_investigator_officer_omaha_ma",
		t"Character.nid_ncpd_investigator_officer_omaha_wa",
		t"Character.nid_ncpd_police_ranged2_copperhead_ma",
		t"Character.nid_ncpd_police_ranged2_copperhead_wa",
		t"Character.nid_ncpd_police_ranged2_lexington_ma",
		t"Character.nid_ncpd_police_ranged2_saratoga_ma",
		t"Character.nok_ncpd_constable_ranged1_lexington_ma",
		t"Character.nok_ncpd_inspector_ranged1_lexington_ma",
		t"Character.nok_ncpd_investigator_officer_omaha_ma",
		t"Character.nok_ncpd_police_ranged2_copperhead_ma",
		t"Character.nok_ncpd_police_ranged2_lexington_ma",
		t"Character.nok_ncpd_police_ranged2_saratoga_ma",
		t"Character.prevention_biker_handgun_ma",
		t"Character.prevention_biker_rifle_ma",
		t"Character.prevention_biker_shotgun_ma",
		t"Character.prevention_police_handgun_ma",
		t"Character.prevention_police_handgun_wa",
		t"Character.prevention_police_rifle_ma",
		t"Character.prevention_police_rifle_wa",
		t"Character.prevention_police_shotgun_ma",
		t"Character.prevention_police_shotgun_wa",
		t"Character.rcr_ncpd_constable_ranged1_lexington_ma",
		t"Character.rcr_ncpd_inspector_ranged1_lexington_ma",
		t"Character.rcr_ncpd_investigator_officer_omaha_ma",
		t"Character.rcr_ncpd_police_ranged2_copperhead_ma",
		t"Character.rcr_ncpd_police_ranged2_lexington_ma",
		t"Character.rcr_ncpd_police_ranged2_saratoga_ma",
		t"Character.rey_ncpd_constable_ranged1_lexington_ma",
		t"Character.rey_ncpd_inspector_ranged1_lexington_ma",
		t"Character.rey_ncpd_investigator_officer_omaha_ma",
		t"Character.rey_ncpd_investigator_officer_omaha_wa",
		t"Character.rey_ncpd_police_ranged2_copperhead_ma",
		t"Character.rey_ncpd_police_ranged2_lexington_ma",
		t"Character.rey_ncpd_police_ranged2_lexington_wa",
		t"Character.rey_ncpd_police_ranged2_saratoga_ma",
		t"Character.spr_ncpd_constable_ranged1_lexington_ma",
		t"Character.spr_ncpd_inspector_ranged1_lexington_ma",
		t"Character.spr_ncpd_investigator_officer_omaha_ma",
		t"Character.spr_ncpd_police_ranged2_copperhead_ma",
		t"Character.spr_ncpd_police_ranged2_lexington_ma",
		t"Character.spr_ncpd_police_ranged2_saratoga_ma",
		t"Character.spr_ncpd_police_ranged2_saratoga_wa",
		t"Character.wwd_ncpd_inspector_ranged1_lexington_ma",
		t"Character.wwd_ncpd_investigator_officer_omaha_ma",
		t"Character.wwd_ncpd_police_ranged2_lexington_ma",
		t"Character.wwd_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_BadlandsMilitech_Ranged() -> array<TweakDBID> = [
		t"Character.prevention_militech_HMG_mb", // HMG
		t"Character.prevention_militech_rifle_ma",
		t"Character.prevention_militech_shotgun_mah",
		t"Character.prevention_militech_smg_ma",
		t"Character.prevention_militech_sniper_ma"
	]

	public func CharList_Barghest_NonPrevention_Ranged() -> array<TweakDBID> = [
		t"Character.airdrop_custom_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.airdrop_custom_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.bou_kurtz_elite2_shotgun2_shotgun_ma_rare",
		t"Character.bou_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.bou_kurtz_elite3_shotgun3_shotgun_ma_elite",
		t"Character.bou_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.bou_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.bou_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.bou_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.bou_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.bou_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.bou_kurtz_rifle_flashlight_ma",
		t"Character.bou_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.bou_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.bou_kurtz_tech_franged2_handgun_ma_rare",
		t"Character.bou_kurtz_tech_franged2_handgun_wa_rare",
		t"Character.combat_tower_kurtz_elite2_shotgun2_shotgun_ma_rare",
		t"Character.combat_tower_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.combat_tower_kurtz_elite3_shotgun3_shotgun_ma_elite",
		t"Character.combat_tower_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.combat_tower_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.combat_tower_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.combat_tower_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.combat_tower_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.combat_tower_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.combat_tower_kurtz_rifle_flashlight_ma",
		t"Character.combat_tower_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.combat_tower_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.combat_tower_kurtz_tech_franged2_handgun_ma_rare",
		t"Character.combat_tower_kurtz_tech_franged2_handgun_wa_rare",
		t"Character.combat_zone_gate_kurtz_elite2_shotgun2_shotgun_ma_rare",
		t"Character.combat_zone_gate_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.combat_zone_gate_kurtz_elite3_shotgun3_shotgun_ma_elite",
		t"Character.combat_zone_gate_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.combat_zone_gate_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.combat_zone_gate_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.combat_zone_gate_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.combat_zone_gate_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.combat_zone_gate_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.combat_zone_gate_kurtz_rifle_flashlight_ma",
		t"Character.combat_zone_gate_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.combat_zone_gate_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.combat_zone_gate_kurtz_tech_franged2_handgun_ma_rare",
		t"Character.combat_zone_gate_kurtz_tech_franged2_handgun_wa_rare",
		t"Character.con_kurtz_elite2_shotgun2_shotgun_ma_rare",
		t"Character.con_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.con_kurtz_elite3_shotgun3_shotgun_ma_elite",
		t"Character.con_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.con_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.con_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.con_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.con_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.con_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.con_kurtz_rifle_flashlight_ma",
		t"Character.con_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.con_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.con_kurtz_tech_franged2_handgun_ma_rare",
		t"Character.con_kurtz_tech_franged2_handgun_wa_rare",
		t"Character.high_kurtz_elite2_shotgun2_shotgun_ma_rare",
		t"Character.high_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.high_kurtz_elite3_shotgun3_shotgun_ma_elite",
		t"Character.high_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.high_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.high_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.high_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.high_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.high_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.high_kurtz_rifle_flashlight_ma",
		t"Character.high_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.high_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.high_kurtz_tech_franged2_handgun_ma_rare",
		t"Character.high_kurtz_tech_franged2_handgun_wa_rare",
		t"Character.hpark_kurtz_elite2_shotgun2_shotgun_ma_rare",
		t"Character.hpark_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.hpark_kurtz_elite3_shotgun3_shotgun_ma_elite",
		t"Character.hpark_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.hpark_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.hpark_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.hpark_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.hpark_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.hpark_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.hpark_kurtz_rifle_flashlight_ma",
		t"Character.hpark_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.hpark_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.hpark_kurtz_tech_franged2_handgun_ma_rare",
		t"Character.hpark_kurtz_tech_franged2_handgun_wa_rare",
		t"Character.kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.kurtz_elite3_gunner3_LMG_mb_elite",
		t"Character.kurtz_grunt1_ranged1_handgun_ma",
		t"Character.kurtz_grunt1_ranged1_handgun_wa",
		t"Character.kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.kurtz_mirror", // HMG
		t"Character.kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.kurtz_rifle_flashlight_ma",
		t"Character.kurtz_rifle_flashlight2_ma",
		t"Character.kurtz_rifle_flashlight3_ma",
		t"Character.kurtz_soldier1_generic_ranged2_rifle_wa",
		t"Character.kurtz_soldier1_ranged2_rifle_ma",
		t"Character.kurtz_soldier1_ranged2_rifle_wa",
		t"Character.kurtz_soldier2_generic_ranged3_rifle_ma",
		t"Character.kurtz_soldier2_shotgun2_shotgun_ma_rare",
		t"Character.kurtz_soldier2_shotgun3_shotgun_ma",
		t"Character.kurtz_tech_franged2_handgun_ma_rare",
		t"Character.kurtz_v2_grunt1_ranged1_saratoga_ma",
		t"Character.kurtz_v2_grunt1_ranged1_saratoga_wa",
		t"Character.mon_kurtz_elite2_shotgun2_shotgun_ma_rare",
		t"Character.mon_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.mon_kurtz_elite3_shotgun3_shotgun_ma_elite",
		t"Character.mon_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.mon_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.mon_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.mon_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.mon_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.mon_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.mon_kurtz_rifle_flashlight_ma",
		t"Character.mon_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.mon_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.mon_kurtz_tech_franged2_handgun_ma_rare",
		t"Character.mon_kurtz_tech_franged2_handgun_wa_rare",
		t"Character.mws_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.mws_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.mws_loop_enemies_kurtz_ranged2_rifle_wa",
		t"Character.sta_kurtz_elite2_shotgun2_shotgun_ma_rare",
		t"Character.sta_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.sta_kurtz_elite3_shotgun3_shotgun_ma_elite",
		t"Character.sta_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.sta_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.sta_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.sta_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.sta_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.sta_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.sta_kurtz_rifle_flashlight_ma",
		t"Character.sta_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.sta_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.sta_kurtz_tech_franged2_handgun_ma_rare",
		t"Character.sta_kurtz_tech_franged2_handgun_wa_rare",
		t"Character.we_ep1_01_kurtz_elite3_gunner3_HMG_mb_elite", // HMG
		t"Character.we_ep1_01_kurtz_grunt1_ranged1_handgun_ma",
		t"Character.we_ep1_01_kurtz_grunt1_ranged1_handgun_wa",
		t"Character.we_ep1_01_kurtz_grunt1_ranged1_saratoga_ma",
		t"Character.we_ep1_01_kurtz_grunt1_ranged1_saratoga_wa",
		t"Character.we_ep1_01_kurtz_netrunner2_netrunner2_lexington_ma_rare",
		t"Character.we_ep1_01_kurtz_recon_sniper2_achilles_ma_rare",
		t"Character.we_ep1_01_kurtz_rifle_flashlight_ma",
		t"Character.we_ep1_01_kurtz_soldier1_ranged2_rifle_ma",
		t"Character.we_ep1_01_kurtz_soldier1_ranged2_rifle_wa",
		t"Character.we_ep1_01_kurtz_soldier2_shotgun2_shotgun_ma_rare",
		t"Character.we_ep1_01_kurtz_tech_franged2_handgun_ma_rare"
	]

	public func CharList_Barghest_Ranged() -> array<TweakDBID> = [
		t"Character.prevention_dogtown_HMG_mb", // HMG
		t"Character.prevention_dogtown_rifle_ma",
		t"Character.prevention_dogtown_rifle_wa",
		t"Character.prevention_dogtown_saratoga_ma",
		t"Character.prevention_dogtown_saratoga_wa",
		t"Character.prevention_dogtown_shotgun_ma"
	]

	public func CharList_BorderGuards_Melee() -> array<TweakDBID> = [
		t"Character.max_border_guards_baton"
	]

	public func CharList_BorderGuards_Ranged() -> array<TweakDBID> = [
		t"Character.max_border_guards",
		t"Character.max_border_guards_shotgun",
		t"Character.prevention_border_guards",
		t"Character.prevention_border_guards_shotgun"
	]

	public func CharList_Enforcers_Ranged() -> array<TweakDBID> = [
		t"Character.arr_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.arr_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.cpz_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.cpz_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.dtn_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.dtn_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.gle_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.gle_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.hil_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.hil_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.jpn_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.jpn_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.kab_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.kab_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.lch_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.lch_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.ncpd_police_shotgun3_crusher_mb_elite",
		t"Character.nid_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.nid_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.nok_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.nok_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.prevention_enforcer_lmg_mb",
		t"Character.prevention_enforcer_rifle_ma",
		t"Character.prevention_enforcer_shotgun_ma",
		t"Character.prevention_recon_sniper2_achilles_ma_rare",
		t"Character.rcr_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.rcr_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.rey_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.rey_ncpd_hwp_gunner2_defender_mb_rare",
		t"Character.spr_ncpd_enforcer_shotgun2_tactician_ma_rare",
		t"Character.spr_ncpd_hwp_gunner2_defender_mb_rare"
	]

	public func CharList_Enforcers_Cyberware() -> array<TweakDBID> = [
		// RGvG adds an NCPD Cyberware unit
	]

	public func CharList_Enforcers_Barghest_NonPrevention_Cyberware() -> array<TweakDBID> = [
		t"Character.bou_kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.combat_tower_kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.combat_zone_gate_kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.con_kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.high_kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.hpark_kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.kurtz_martial_fmelee3_fists_ma_rare",
		t"Character.kurtz_martial_hmelee3_fists_mb_elite",
		t"Character.kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.mon_kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.sta_kurtz_strongarms_hmelee3_fists_mb_elite",
		t"Character.we_ep1_01_kurtz_martial_fmelee3_fists_ma_rare",
		t"Character.we_ep1_01_kurtz_martial_hmelee3_fists_mb_elite",
		t"Character.we_ep1_01_kurtz_strongarms_hmelee3_fists_mb_elite"
	]

	public func CharList_Enforcers_Barghest_Cyberware() -> array<TweakDBID> = [
		t"Character.prevention_dogtown_martial_fmelee3_fists_ma_rare",
		t"Character.prevention_dogtown_martial_hmelee3_fists_mb_elite"
	]

	public func CharList_Androids() -> array<TweakDBID> = [
		t"Character.arr_ncpd_android_android2_ajax_ma",
		t"Character.cpz_ncpd_android_android2_ajax_ma",
		t"Character.dtn_ncpd_android_android2_ajax_ma",
		t"Character.gle_ncpd_android_android2_ajax_ma",
		t"Character.hil_ncpd_android_android2_ajax_ma",
		t"Character.jpn_ncpd_android_android2_ajax_ma",
		t"Character.kab_ncpd_android_android2_ajax_ma",
		t"Character.lch_ncpd_android_android2_ajax_ma",
		t"Character.ncpd_android_android2_ajax_ma",
		t"Character.ncpd_android_android2_lexington_ma",
		t"Character.nid_ncpd_android_android2_ajax_ma",
		t"Character.nok_ncpd_android_android2_ajax_ma",
		t"Character.prevention_android_rifle_ma",
		t"Character.prevention_dogtown_droid_ma",
		t"Character.rcr_ncpd_android_android2_ajax_ma",
		t"Character.rey_ncpd_android_android2_ajax_ma",
		t"Character.spr_ncpd_android_android2_ajax_ma"
	]

	public func CharList_Barghest_NonPrevention_Mechs() -> array<TweakDBID> = [
		t"Character.bou_kurtz_exo",
		t"Character.combat_tower_kurtz_exo",
		t"Character.combat_zone_gate_kurtz_exo",
		t"Character.con_kurtz_exo",
		t"Character.hpark_kurtz_exo",
		t"Character.kurtz_exo",
		t"Character.kurtz_minotaur",
		t"Character.mon_kurtz_exo",
		t"Character.sta_kurtz_exo"
	]

	public func CharList_Mechs() -> array<TweakDBID> = [
		t"Character.arr_ncpd_drone_wyvern",
		t"Character.bls_ne_militech_minotaur",
		t"Character.bls_se_militech_minotaur",
		t"Character.cpz_ncpd_drone_wyvern",
		t"Character.cvi_netwatch_drone_bombus_medium",
		t"Character.dtn_ncpd_drone_wyvern",
		t"Character.gle_ncpd_drone_wyvern",
		t"Character.hil_ncpd_drone_wyvern",
		t"Character.jpn_ncpd_drone_wyvern",
		t"Character.kab_ncpd_drone_wyvern",
		t"Character.lch_ncpd_drone_wyvern",
		t"Character.max_border_minotaur",
		t"Character.max_border_drone_octant",
		t"Character.ncpd_drone_bombus_medium",
		t"Character.ncpd_drone_wyvern_hard",
		t"Character.ncpd_minotaur",
		t"Character.nid_ncpd_drone_wyvern",
		t"Character.nok_ncpd_drone_wyvern",
		t"Character.prevention_unit_octant_drone",
		t"Character.prevention_unit_wyvern_drone",
		t"Character.prevention_unit_wyvern_drone_mercs",
		t"Character.rcr_ncpd_drone_wyvern",
		t"Character.rey_ncpd_drone_wyvern",
		t"Character.spr_ncpd_drone_wyvern",
		t"Character.wat_roadblock_militech_minotaur"
	]

	public func CharList_Netwatch() -> array<TweakDBID> = [
		t"Character.cpz_netwatch_agent_netrunner3_omaha_elite",
		t"Character.cvi_netwatch_agent_netrunner3_omaha_elite",
		t"Character.kab_netwatch_agent_netrunner3_omaha_elite",
		t"Character.netwatch_agent_netrunner3_omaha_elite",
		t"Character.nid_netwatch_agent_netrunner3_omaha_elite"
	]

	public func CharList_MaxTac_Cyberware() -> array<TweakDBID> = [
		t"Character.maxtac_av_mantis_wa",
		t"Character.maxtac_av_mantis_wa_2nd_wave",
		t"Character.maxtac_melee_ma_elite"
	]

	public func CharList_MaxTac_Ranged() -> array<TweakDBID> = [
		t"Character.maxtac_av_LMG_mb",
		t"Character.maxtac_av_LMG_mb_2nd_wave",
		t"Character.maxtac_av_netrunner_ma",
		t"Character.maxtac_av_netrunner_ma_2nd_wave",
		t"Character.maxtac_av_riffle_ma",
		t"Character.maxtac_av_riffle_ma_2nd_wave",
		t"Character.maxtac_av_sniper_wa_elite",
		t"Character.maxtac_av_sniper_wa_elite_2nd_wave",
		t"Character.maxtac_gunner_mb_elite", // HMG
		t"Character.maxtac_rifle_ma_elite",
		t"Character.maxtac_rifle_wa_elite",
		t"Character.maxtac_shotgun_ma_elite",
		t"Character.maxtac_sniper_wa_elite",
		t"Character.prevention_av_maxtac_rifle_ma",
		t"Character.prevention_av_maxtac_rifle_wa",
		t"Character.prevention_maxtac_rifle_ma",
		t"Character.prevention_maxtac_rifle_wa"
	]

	public func CharList_UnderfundedHeatOneUnits() -> array<TweakDBID> = [
		t"Character.prevention_police_handgun_ma",
		t"Character.prevention_police_handgun_wa"
	]

	public func CharList_UnderfundedHeatTwoUnits() -> array<TweakDBID> = [
		t"Character.prevention_police_handgun_ma",
		t"Character.prevention_police_handgun_wa",
		t"Character.prevention_police_shotgun_ma",
		t"Character.prevention_police_shotgun_wa",
		t"Character.prevention_police_rifle_ma",
		t"Character.prevention_police_rifle_wa"
	]

	public func CharList_UnderfundedHeatThreeUnits() -> array<TweakDBID> = [
		t"Character.prevention_police_shotgun_ma",
		t"Character.prevention_police_shotgun_wa",
		t"Character.prevention_police_rifle_ma",
		t"Character.prevention_police_rifle_wa"
	]

	public func CharList_UnderfundedHeatFourUnits() -> array<TweakDBID> = [
		t"Character.prevention_police_shotgun_ma",
		t"Character.prevention_police_shotgun_wa",
		t"Character.prevention_police_rifle_ma",
		t"Character.prevention_police_rifle_wa",
		t"Character.prevention_android_rifle_ma"
	]

	public func CharList_UnderfundedHeatFiveUnits() -> array<TweakDBID> = [
		t"Character.prevention_android_rifle_ma",
		t"Character.prevention_enforcer_shotgun_ma",
		t"Character.prevention_enforcer_rifle_ma"
	]

	public func CharList_Prevention_BountyHunters() -> array<TweakDBID> = [
		t"Character.prevention_aldecaldo_rifle_ma",
		t"Character.prevention_aldecaldo_rifle_wa",
		t"Character.prevention_aldecaldo_shotgun_ma",
		t"Character.prevention_bountyhunter_netrunner_wa",
		t"Character.prevention_bountyhunter_rifle_ma",
		t"Character.prevention_bountyhunter_rifle_wa",
		t"Character.prevention_bountyhunter_shotgun_mb",
		t"Character.prevention_bountyhunter_smg_ma",
		t"Character.prevention_bountyhunter_smg_wa"
	]

	public func CharList_Prevention_BountyHunters_NightCity() -> array<TweakDBID> = [
		t"Character.prevention_bountyhunter_netrunner_wa",
		t"Character.prevention_bountyhunter_rifle_ma",
		t"Character.prevention_bountyhunter_rifle_wa",
		t"Character.prevention_bountyhunter_shotgun_mb",
		t"Character.prevention_bountyhunter_smg_ma",
		t"Character.prevention_bountyhunter_smg_wa"
	]

	public func CharList_Prevention_BountyHunters_Badlands() -> array<TweakDBID> = [
		t"Character.prevention_aldecaldo_rifle_ma",
		t"Character.prevention_aldecaldo_rifle_wa",
		t"Character.prevention_aldecaldo_shotgun_ma"
	]

	public func CharList_NCPD_SubDistrict_Arroyo_SantoDomingo() -> array<TweakDBID> = [
		// Melee
		t"Character.arr_ncpd_constable_melee1_baton_ma",
		t"Character.arr_ncpd_police_melee2_baton_ma",
		// Ranged
		t"Character.arr_ncpd_constable_ranged1_lexington_ma",
		t"Character.arr_ncpd_inspector_ranged1_lexington_ma",
		t"Character.arr_ncpd_investigator_officer_omaha_ma",
		t"Character.arr_ncpd_investigator_officer_omaha_wa",
		t"Character.arr_ncpd_police_ranged2_copperhead_ma",
		t"Character.arr_ncpd_police_ranged2_lexington_ma",
		t"Character.arr_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_CorpoPlaza_CityCenter() -> array<TweakDBID> = [
		// Melee
		t"Character.cpz_ncpd_constable_melee1_baton_ma",
		t"Character.cpz_ncpd_police_melee2_baton_ma",
		// Ranged
		t"Character.cpz_ncpd_constable_ranged1_lexington_ma",
		t"Character.cpz_ncpd_inspector_ranged1_lexington_ma",
		t"Character.cpz_ncpd_investigator_officer_omaha_ma",
		t"Character.cpz_ncpd_police_ranged2_copperhead_ma",
		t"Character.cpz_ncpd_police_ranged2_lexington_ma",
		t"Character.cpz_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_Coastview_Pacifica() -> array<TweakDBID> = [
		// Melee
		t"Character.cvi_ncpd_constable_melee1_baton_ma",
		// Ranged
		t"Character.cvi_ncpd_inspector_ranged1_lexington_ma",
		t"Character.cvi_ncpd_investigator_officer_omaha_ma",
		t"Character.cvi_ncpd_police_ranged2_copperhead_ma",
		t"Character.cvi_ncpd_police_ranged2_lexington_ma",
		t"Character.cvi_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_Downtown_CityCenter() -> array<TweakDBID> = [
		// Melee
		t"Character.dtn_ncpd_constable_melee1_baton_ma",
		// Ranged
		t"Character.dtn_ncpd_constable_ranged1_lexington_ma",
		t"Character.dtn_ncpd_inspector_ranged1_lexington_ma",
		t"Character.dtn_ncpd_investigator_officer_omaha_ma",
		t"Character.dtn_ncpd_police_ranged2_copperhead_ma",
		t"Character.dtn_ncpd_police_ranged2_lexington_ma",
		t"Character.dtn_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_TheGlen_Heywood() -> array<TweakDBID> = [
		// Melee
		t"Character.gle_ncpd_constable_melee1_baton_ma",
		t"Character.gle_ncpd_inspector_melee1_baton_ma",
		// Ranged
		t"Character.gle_ncpd_constable_ranged1_lexington_ma",
		t"Character.gle_ncpd_inspector_ranged1_lexington_ma",
		t"Character.gle_ncpd_investigator_officer_omaha_ma",
		t"Character.gle_ncpd_investigator_officer_omaha_wa",
		t"Character.gle_ncpd_police_ranged2_copperhead_ma",
		t"Character.gle_ncpd_police_ranged2_copperhead_wa",
		t"Character.gle_ncpd_police_ranged2_lexington_ma",
		t"Character.gle_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_CharterHill_Westbrook() -> array<TweakDBID> = [
		// Melee
		t"Character.hil_ncpd_constable_melee1_baton_ma",
		// Ranged
		t"Character.hil_ncpd_constable_ranged1_lexington_ma",
		t"Character.hil_ncpd_inspector_ranged1_lexington_ma",
		t"Character.hil_ncpd_investigator_officer_omaha_ma",
		t"Character.hil_ncpd_police_ranged2_copperhead_ma",
		t"Character.hil_ncpd_police_ranged2_lexington_ma",
		t"Character.hil_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_Japantown_Westbrook() -> array<TweakDBID> = [
		// Melee
		t"Character.jpn_ncpd_constable_melee1_baton_ma",
		t"Character.jpn_ncpd_police_melee2_baton_ma",
		t"Character.jpn_ncpd_police_melee2_baton_wa",
		// Ranged
		t"Character.jpn_ncpd_constable_ranged1_lexington_ma",
		t"Character.jpn_ncpd_inspector_ranged1_lexington_ma",
		t"Character.jpn_ncpd_investigator_officer_omaha_ma",
		t"Character.jpn_ncpd_investigator_officer_omaha_wa",
		t"Character.jpn_ncpd_police_ranged2_copperhead_ma",
		t"Character.jpn_ncpd_police_ranged2_lexington_ma",
		t"Character.jpn_ncpd_police_ranged2_lexington_wa",
		t"Character.jpn_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_Kabuki_Watson() -> array<TweakDBID> = [
		// Melee
		t"Character.kab_ncpd_constable_melee1_baton_ma",
		t"Character.kab_ncpd_inspector_melee1_baton_ma",
		t"Character.kab_ncpd_police_melee2_baton_wa",
		// Ranged
		t"Character.kab_ncpd_constable_ranged1_lexington_ma",
		t"Character.kab_ncpd_hazmat_ranged1_lexington_ma",
		t"Character.kab_ncpd_inspector_ranged1_lexington_ma",
		t"Character.kab_ncpd_investigator_officer_omaha_ma",
		t"Character.kab_ncpd_investigator_officer_omaha_wa",
		t"Character.kab_ncpd_police_ranged2_copperhead_ma",
		t"Character.kab_ncpd_police_ranged2_lexington_ma",
		t"Character.kab_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_LittleChina_Watson() -> array<TweakDBID> = [
		// Melee
		t"Character.lch_ncpd_constable_melee1_baton_ma",
		t"Character.lch_ncpd_police_melee2_baton_ma",
		t"Character.lch_ncpd_police_melee2_baton_wa",
		// Ranged
		t"Character.lch_ncpd_hazmat_ranged1_lexington_ma",
		t"Character.lch_ncpd_inspector_ranged1_lexington_ma",
		t"Character.lch_ncpd_investigator_officer_omaha_ma",
		t"Character.lch_ncpd_investigator_officer_omaha_wa",
		t"Character.lch_ncpd_police_ranged2_copperhead_ma",
		t"Character.lch_ncpd_police_ranged2_lexington_ma",
		t"Character.lch_ncpd_police_ranged2_lexington_wa",
		t"Character.lch_ncpd_police_ranged2_saratoga_ma",
		t"Character.lch_ncpd_police_ranged2_saratoga_wa"
	]

	public func CharList_NCPD_SubDistrict_Northside_Watson() -> array<TweakDBID> = [
		// Melee
		t"Character.nid_ncpd_constable_melee1_baton_ma",
		t"Character.nid_ncpd_inspector_melee1_baton_ma",
		t"Character.nid_ncpd_police_melee2_baton_ma",
		// Ranged
		t"Character.nid_ncpd_constable_ranged1_lexington_ma",
		t"Character.nid_ncpd_hazmat_ranged1_lexington_ma",
		t"Character.nid_ncpd_inspector_ranged1_lexington_ma",
		t"Character.nid_ncpd_investigator_officer_omaha_ma",
		t"Character.nid_ncpd_investigator_officer_omaha_wa",
		t"Character.nid_ncpd_police_ranged2_copperhead_ma",
		t"Character.nid_ncpd_police_ranged2_copperhead_wa",
		t"Character.nid_ncpd_police_ranged2_lexington_ma",
		t"Character.nid_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_NorthOak_Westbrook() -> array<TweakDBID> = [
		// Melee
		t"Character.nok_ncpd_constable_melee1_baton_ma",
		// Ranged
		t"Character.nok_ncpd_constable_ranged1_lexington_ma",
		t"Character.nok_ncpd_inspector_ranged1_lexington_ma",
		t"Character.nok_ncpd_investigator_officer_omaha_ma",
		t"Character.nok_ncpd_police_ranged2_copperhead_ma",
		t"Character.nok_ncpd_police_ranged2_lexington_ma",
		t"Character.nok_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_RanchoCoronado_SantoDomingo() -> array<TweakDBID> = [
		// Melee
		t"Character.rcr_ncpd_constable_melee1_baton_ma",
		// Ranged
		t"Character.rcr_ncpd_constable_ranged1_lexington_ma",
		t"Character.rcr_ncpd_inspector_ranged1_lexington_ma",
		t"Character.rcr_ncpd_investigator_officer_omaha_ma",
		t"Character.rcr_ncpd_police_ranged2_copperhead_ma",
		t"Character.rcr_ncpd_police_ranged2_lexington_ma",
		t"Character.rcr_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_VistaDelRey_Heywood() -> array<TweakDBID> = [
		// Melee
		t"Character.rey_ncpd_constable_melee1_baton_ma",
		t"Character.rey_ncpd_inspector_melee1_baton_ma",
		// Ranged
		t"Character.rey_ncpd_constable_ranged1_lexington_ma",
		t"Character.rey_ncpd_inspector_ranged1_lexington_ma",
		t"Character.rey_ncpd_investigator_officer_omaha_ma",
		t"Character.rey_ncpd_investigator_officer_omaha_wa",
		t"Character.rey_ncpd_police_ranged2_copperhead_ma",
		t"Character.rey_ncpd_police_ranged2_lexington_ma",
		t"Character.rey_ncpd_police_ranged2_lexington_wa",
		t"Character.rey_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_NCPD_SubDistrict_Wellsprings_Heywood() -> array<TweakDBID> = [
		// Melee
		t"Character.spr_ncpd_constable_melee1_baton_ma",
		t"Character.spr_ncpd_police_melee2_baton_ma",
		// Ranged
		t"Character.spr_ncpd_constable_ranged1_lexington_ma",
		t"Character.spr_ncpd_inspector_ranged1_lexington_ma",
		t"Character.spr_ncpd_investigator_officer_omaha_ma",
		t"Character.spr_ncpd_police_ranged2_copperhead_ma",
		t"Character.spr_ncpd_police_ranged2_lexington_ma",
		t"Character.spr_ncpd_police_ranged2_saratoga_ma",
		t"Character.spr_ncpd_police_ranged2_saratoga_wa"
	]

	public func CharList_NCPD_SubDistrict_WestWindEstate_Pacifica() -> array<TweakDBID> = [
		// Melee
		t"Character.wwd_ncpd_constable_melee1_baton_ma",
		// Ranged
		t"Character.wwd_ncpd_inspector_ranged1_lexington_ma",
		t"Character.wwd_ncpd_investigator_officer_omaha_ma",
		t"Character.wwd_ncpd_police_ranged2_lexington_ma",
		t"Character.wwd_ncpd_police_ranged2_saratoga_ma"
	]

	public func CharList_OfficerRarity() -> array<TweakDBID> = [
		t"Character.arr_03_officer",
		t"Character.cpz_security_netrunner_m_hard",
		t"Character.gle_01_tucker",
		t"Character.gle_04_valentinos_officer",
		t"Character.gle_sixthstreet_hooligan_ranged1_saratoga_wa",
		t"Character.ina_04_militech_officer",
		t"Character.kab_06_Blake",
		t"Character.kabuki_tyger_claw_officer_rifle_fast",
		t"Character.ma_cct_dtn_01_John_Lipczynsky",
		t"Character.maelstrom_officer_officer_lexington_ma",
		t"Character.militech_officer_officer_omaha_ma",
		t"Character.mq002_scavenger_leader",
		t"Character.mws_hey_07_tyger_claws_officergangster_officer_nue_ma",
		t"Character.nid_03_enemy_offices",
		t"Character.nid_101_maelstrom_rfle",
		t"Character.q003_meat_factory_officer_maelstrom_grunt2_ranged2_ajax_ma",
		t"Character.q104_arasaka_operator_leader",
		t"Character.q104_arasaka_operator_smg_officer",
		t"Character.q105_bds_officer_scavenger_grunt3_netrunner2_nova_ma_rare",
		t"Character.q105_dollhouse_officer_tyger_claws_martial_fmelee2_katana_ma_rare",
		t"Character.q110_animals_mall_west_wing_zone_officer",
		t"Character.q110_esc_officer_voodooboys_grunt1coat_shotgun2_palica_ma",
		t"Character.q110_netwatch_agent",
		t"Character.q112_arasaka_agent_officer",
		t"Character.q112_arasaka_agent_rifle_flashlight_officer",
		t"Character.q112_arasaka_sniper_01_officer",
		t"Character.q112_infiltration_arasaka_guard_officer",
		t"Character.q112_infiltration_arasaka_guard_officer_ninja",
		t"Character.q112_parade_officer_soldier1_ranged3_masamune_mah_rare",
		t"Character.q113_arasaka_jungle_terminator_officer",
		t"Character.q113_ceo_floor_officer",
		t"Character.q113_estate_mansion_guard_officer",
		t"Character.q113_estate_mansion_netrunner",
		t"Character.q113_jungle_guard_friendly",
		t"Character.q113_jungle_guard_friendly_female",
		t"Character.q114_arasaka_manufacturing_officer",
		t"Character.q114_militech_broadcast",
		t"Character.q114_militech_guard_officer",
		t"Character.q114_militech_response_officer",
		t"Character.q115_arasaka_atrium_officer",
		t"Character.q115_arasaka_jungle_officer",
		t"Character.q115_arasaka_nest_officer",
		t"Character.rcr_sixthstreet_hooligan_ranged1_saratoga_wa",
		t"Character.rcr_sixthstreet_patrol2_melee2_baton_wa",
		t"Character.security_officer_officer_nue_ma",
		t"Character.sq004_raffen_shiv_boss_alpha",
		t"Character.sq004_raffen_shiv_boss_gamma",
		t"Character.sq006_maelstrom_officer",
		t"Character.sq011_maelstrom_officer",
		t"Character.sq012_animal_officer",
		t"Character.sq012_animal_officer_beta_female",
		t"Character.sq018_rey_01_gustavo",
		t"Character.sq021_wraith_handgun_officer",
		t"Character.sq026_hiromis_officer_tyger_claws_officergangster_officer_nue_ma",
		t"Character.sq027_militech_escort_officer",
		t"Character.sq031_maelstrom_standard_melee",
		t"Character.sq031_maelstrom_standard_melee_beta",
		t"Character.sq031_maelstrom_strong_LMG",
		t"Character.sts_bls_ina_101_arden_bentzen",
		t"Character.sts_cct_dtn_02_dozy",
		t"Character.sts_hey_gle_06_6th_street_officer",
		t"Character.sts_hey_rey_01_gustavo",
		t"Character.sts_hey_rey_02_valentinos_officer_officer_overture_ma",
		t"Character.sts_hey_rey_08_karubo",
		t"Character.sts_hey_rey_09_officer",
		t"Character.sts_hey_rey_101_mark_fayard",
		t"Character.sts_hey_spr_01_jose",
		t"Character.sts_hey_spr_06_rebeca_price",
		t"Character.sts_std_arr_01_sixthstreet_officer_officer_overture_ma",
		t"Character.sts_std_rcr_01_vic_vega",
		t"Character.sts_wat_kab_07_jotaro",
		t"Character.sts_wat_kab_08_dave_hamill",
		t"Character.sts_wat_kab_101_enemy_scav_officer_shotgun2",
		t"Character.sts_wat_kab_107_taki_kenmochi",
		t"Character.sts_wat_nid_02_tygerclaw_officer",
		t"Character.sts_wat_nid_06_enemy_officer",
		t"Character.sts_wat_nid_07_enemy_strong_shotgun",
		t"Character.sts_wat_nid_102_tygerclaw_officer",
		t"Character.sts_wbr_hil_06_wyatt_alken",
		t"Character.sts_wbr_hil_101_enemy_security_officer",
		t"Character.sts_wbr_jpn_05_tygerclaw_officer",
		t"Character.tyger_claws_officerbiker_officer_nue_ma",
		t"Character.tyger_claws_officergangster_officer_nue_ma",
		t"Character.wst_ep1_ctz_107_mausser",
		t"TEST.OfficerEnemy"
	]

//	@if(ModuleExists("Gibbon.GR.ReinforcementSystem"))
/*	public func CharList_RGvG_All() -> array<TweakDBID> = [			// r6\tweaks\reinforcements_gangvgang\characters\0_ncpd.yaml
		t"Character.GR_ncpd_android_android2_ajax_ma",				// $base: Character.ncpd_android_android2_ajax_ma
		t"Character.GR_ncpd_android_android2_lexington_ma",			// $base: Character.ncpd_android_android2_lexington_ma
		t"Character.GR_ncpd_biker_ranged2_omaha_ma",				// $base: Character.ncpd_biker_ranged2_omaha_ma
		t"Character.GR_ncpd_constable_melee1_baton_ma",				// $base: Character.ncpd_constable_melee1_baton_ma
		t"Character.GR_ncpd_constable_ranged1_lexington_ma",		// $base: Character.ncpd_constable_ranged1_lexington_ma
		t"Character.GR_ncpd_elite_ajax",							// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.Preset_Ajax_Default
		t"Character.GR_ncpd_elite_crusher",							// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.Preset_Crusher_Default
		t"Character.GR_ncpd_elite_gorilla",							// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.NPC_Strong_Arms
		t"Character.GR_ncpd_elite_hmg",								// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.Preset_HMG_Default
		t"Character.GR_ncpd_elite_kolac",							// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.Preset_Kolac_Default
		t"Character.GR_ncpd_enforcer_shotgun2_tactician_ma_rare",	// $base: Character.ncpd_enforcer_shotgun2_tactician_ma_rare
		t"Character.GR_ncpd_hwp_gunner2_defender_mb_rare",			// $base: Character.ncpd_hwp_gunner2_defender_mb_rare
		t"Character.GR_ncpd_inspector_ranged1_lexington_ma",		// $base: Character.ncpd_inspector_ranged1_lexington_ma
		t"Character.GR_ncpd_investigator_officer_omaha_ma",			// $base: Character.ncpd_investigator_officer_omaha_ma
		t"Character.GR_ncpd_investigator_officer_omaha_wa",			// $base: Character.ncpd_investigator_officer_omaha_wa
		t"Character.GR_ncpd_police_melee2_baton_ma",				// $base: Character.ncpd_police_melee2_baton_ma
		t"Character.GR_ncpd_police_melee2_baton_wa",				// $base: Character.ncpd_police_melee2_baton_wa
		t"Character.GR_ncpd_police_ranged2_copperhead_ma",			// $base: Character.ncpd_police_ranged2_copperhead_ma
		t"Character.GR_ncpd_police_ranged2_copperhead_wa",			// $base: Character.ncpd_police_ranged2_copperhead_wa
		t"Character.GR_ncpd_police_ranged2_lexington_ma",			// $base: Character.ncpd_police_ranged2_lexington_ma
		t"Character.GR_ncpd_police_ranged2_lexington_wa",			// $base: Character.ncpd_police_ranged2_lexington_wa
		t"Character.GR_ncpd_police_ranged2_saratoga_ma",			// $base: Character.ncpd_police_ranged2_saratoga_ma
		t"Character.GR_ncpd_police_ranged2_saratoga_wa",			// $base: Character.ncpd_police_ranged2_saratoga_wa
		t"Character.GR_ncpd_police_shotgun3_crusher_mb_elite"		// $base: Character.ncpd_police_shotgun3_crusher_mb_elite
	]*/

//	@if(ModuleExists("Gibbon.GR.ReinforcementSystem"))
	public func CharList_RGvG_Cops_Melee() -> array<TweakDBID> = [
		t"Character.GR_ncpd_constable_melee1_baton_ma",				// $base: Character.ncpd_constable_melee1_baton_ma
		t"Character.GR_ncpd_police_melee2_baton_ma",				// $base: Character.ncpd_police_melee2_baton_ma
		t"Character.GR_ncpd_police_melee2_baton_wa"					// $base: Character.ncpd_police_melee2_baton_wa
	]

//	@if(ModuleExists("Gibbon.GR.ReinforcementSystem"))
	public func CharList_RGvG_Cops_Ranged() -> array<TweakDBID> = [
		t"Character.GR_ncpd_biker_ranged2_omaha_ma",				// $base: Character.ncpd_biker_ranged2_omaha_ma
		t"Character.GR_ncpd_constable_ranged1_lexington_ma",		// $base: Character.ncpd_constable_ranged1_lexington_ma
		t"Character.GR_ncpd_inspector_ranged1_lexington_ma",		// $base: Character.ncpd_inspector_ranged1_lexington_ma
		t"Character.GR_ncpd_investigator_officer_omaha_ma",			// $base: Character.ncpd_investigator_officer_omaha_ma
		t"Character.GR_ncpd_investigator_officer_omaha_wa",			// $base: Character.ncpd_investigator_officer_omaha_wa
		t"Character.GR_ncpd_police_ranged2_copperhead_ma",			// $base: Character.ncpd_police_ranged2_copperhead_ma
		t"Character.GR_ncpd_police_ranged2_copperhead_wa",			// $base: Character.ncpd_police_ranged2_copperhead_wa
		t"Character.GR_ncpd_police_ranged2_lexington_ma",			// $base: Character.ncpd_police_ranged2_lexington_ma
		t"Character.GR_ncpd_police_ranged2_lexington_wa",			// $base: Character.ncpd_police_ranged2_lexington_wa
		t"Character.GR_ncpd_police_ranged2_saratoga_ma",			// $base: Character.ncpd_police_ranged2_saratoga_ma
		t"Character.GR_ncpd_police_ranged2_saratoga_wa"				// $base: Character.ncpd_police_ranged2_saratoga_wa
	]

//	@if(ModuleExists("Gibbon.GR.ReinforcementSystem"))
	public func CharList_RGvG_Enforcers_Ranged() -> array<TweakDBID> = [
		t"Character.GR_ncpd_elite_ajax",							// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.Preset_Ajax_Default
		t"Character.GR_ncpd_elite_crusher",							// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.Preset_Crusher_Default
		t"Character.GR_ncpd_elite_hmg",								// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.Preset_HMG_Default
		t"Character.GR_ncpd_elite_kolac",							// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.Preset_Kolac_Default
		t"Character.GR_ncpd_enforcer_shotgun2_tactician_ma_rare",	// $base: Character.ncpd_enforcer_shotgun2_tactician_ma_rare
		t"Character.GR_ncpd_hwp_gunner2_defender_mb_rare",			// $base: Character.ncpd_hwp_gunner2_defender_mb_rare
		t"Character.GR_ncpd_police_shotgun3_crusher_mb_elite"		// $base: Character.ncpd_police_shotgun3_crusher_mb_elite
	]

//	@if(ModuleExists("Gibbon.GR.ReinforcementSystem"))
	public func CharList_RGvG_Enforcers_Cyberware() -> array<TweakDBID> = [
		t"Character.GR_ncpd_elite_gorilla"							// $base: Character.ncpd_hwp_gunner2_defender_mb_rare, with Items.NPC_Strong_Arms
	]

//	@if(ModuleExists("Gibbon.GR.ReinforcementSystem"))
	public func CharList_RGvG_Androids() -> array<TweakDBID> = [
		t"Character.GR_ncpd_android_android2_ajax_ma",				// $base: Character.ncpd_android_android2_ajax_ma
		t"Character.GR_ncpd_android_android2_lexington_ma"			// $base: Character.ncpd_android_android2_lexington_ma
	]

	public func VehicleList_MaxTacAVs() -> array<TweakDBID> = [
		t"Vehicle.max_tac_av1",
		t"Vehicle.max_tac_av2",
		t"Vehicle.max_tac_av3",
		t"Vehicle.max_tac_av_2nd_wave",
		t"Vehicle.max_tac_av_2nd_wave1",
		t"Vehicle.max_tac_av_2nd_wave2",
		t"Vehicle.max_tac_av_2nd_wave3"
	]

	public func ItemList_JunkDrops() -> array<TweakDBID> = [
		t"Items.GenericJunkItem7",		// Flare
		t"Items.ScavengersJunkItem2",	// Handcuffs
		t"Items.SexToyJunkItem5",		// Protector
		t"Items.MilitechJunkItem1",		// Thigh Holster
		t"Items.ScavengersJunkItem3"	// Used Airhypo
	]

	public func ItemList_JunkDrops_Trunks() -> array<TweakDBID> = [
		t"Items.WraithsJunkItem2",		// Bloody Bandage
		t"Items.GenericGangJunkItem5",	// Bloody Knife
		t"Items.NomadsJunkItem1",		// Brake Fluid
		t"Items.GenericPoorJunkItem4",	// Damaged Clothes
		t"Items.GenericJunkItem7",		// Flare
		t"Items.ScavengersJunkItem2",	// Handcuffs
		t"Items.GenericJunkItem14",		// Lottery Scratchcard
		t"Items.VoodooBoysJunkItem2",	// Luminescent Chalk
		t"Items.GenericJunkItem4",		// Medical Gauze
		t"Items.MilitechJunkItem2",		// Military Pocket Knife
		t"Items.SixthStreetJunkItem1",	// NUSA Pin
		t"Items.SouvenirJunkItem3",		// Shell Casing Keychain
		t"Items.SixthStreetJunkItem2",	// Shortwave Transmitter
		t"Items.MilitechJunkItem1",		// Thigh Holster
		t"Items.WraithsJunkItem1"		// Tire Iron
	]

	public func ItemList_PervDrops_Trunks() -> array<TweakDBID> = [
		t"Items.CopKiller_PervCopBD",	// BD
		t"Items.GenericJunkItem26",		// Candles
		t"Items.GenericRichJunkItem1",	// Champagne Bucket
		t"Items.GenericJunkItem28",		// Condoms
		t"Items.Tech_02_old_01",		// Dated BD Wreath
		t"Items.SexToyJunkItem1",		// Gag
		t"Items.ScavengersJunkItem2",	// Handcuffs
		t"Items.SexToyJunkItem6",		// Luv Compartment
		t"Items.GenericJunkItem24",		// Pack of Cigarettes
		t"Items.GenericJunkItem17",		// Perfume
		t"Items.SexToyJunkItem3",		// Pilomancer 3000
		t"Items.SexToyJunkItem5",		// Protector
		t"Items.SexToyJunkItem2",		// Studded Dildo
		t"Items.MoxiesJunkItem2",		// Torn Fishnets
		t"Items.SexToyJunkItem4"		// Trans-Anal Exxxpress
	]

	public func ItemList_AddictDrops() -> array<TweakDBID> = [
		// Drugs
		t"Items.Blackmarket_HealthBooster",			// AssKick
		t"Items.BlackLaceV0",						// Black Lace V0
	//	t"Items.BlackLaceV1",						// Black Lace V1
		t"Items.Blackmarket_StaminaBooster",		// Jellytricity
		t"Items.Blackmarket_CarryCapacityBooster",	// Ol' Donkey
		t"Items.Blackmarket_MemoryBooster",			// RAM Nugs
		// Alcohol
		t"Items.MediumQualityAlcohol2",				// O'Dickin Whiskey
		t"Items.MediumQualityAlcohol4",				// Conine
		t"Items.MediumQualityAlcohol5",				// Joe Tiel's Okie Hooch
		t"Items.MediumQualityAlcohol6",				// Papa Garcin
		t"Items.MediumQualityAlcohol7"				// Blue Grass
	]

	public func ItemList_CivQualityItemDonations() -> array<TweakDBID> = [
		// Top-Shelf Alcohol
		t"Items.TopQualityAlcohol1",				// Calavera Feliz
		t"Items.TopQualityAlcohol2",				// Chateau Delen 2012
		t"Items.TopQualityAlcohol3",				// Armagnac Massy
		t"Items.TopQualityAlcohol4",				// Sake Utagawa
		t"Items.TopQualityAlcohol5",				// Baalbek Arak
		t"Items.TopQualityAlcohol6",				// ROMVLVS GIN
		t"Items.TopQualityAlcohol7",				// Paul Night
		// Weapon Mods: Melee
		t"MeleeMod1_Legendary",						// Airstrike
		t"MeleeMod2_Legendary",						// Cyclone
		t"MeleeMod3_Legendary",						// Silencio
		// Weapon Mods: Ranged
		t"RangedMod1_Legendary",					// Better Half
		t"RangedMod2_Legendary",					// Shuffler
		t"RangedMod3_Legendary",					// Equalizer
		// Weapon Mods: Thrown
		t"ThrowMod1_Legendary",						// Boomerang
		t"ThrowMod2_Legendary",						// Zero-G
		t"ThrowMod3_Legendary",						// Javelin
		// Phantom Liberty: Illegal Food
		t"Item.CarFood1",							// Hot Roddy's Road-Ready Coffee (recalled)
		t"Item.CombatFood1",						// Devildick Pepper Chips
		t"Item.CombatFood2",						// Creatine-Loaded Protein Log
		t"Item.CombatFood3",						// Dolphin Jerky
		t"Item.HealthFood1",						// Comrade Kolya's Premium Black Caviar
		t"Item.HealthFood2",						// Militech MRE (expired)
		t"Item.HealthFood3",						// Hefty Chef Fettuccine Alfredo XXL (discontinued)
		t"Item.NetrunnerFood1",						// Bzzzzt! Energy Drink (recalled)
		t"Item.NetrunnerFood2",						// Phish & Chips
		t"Item.StealthFood1"						// Exotic flora and fungi mystery bag
	]

	public func ItemList_CivMealDonations() -> array<TweakDBID> = [
		// Cheap Food
		t"Items.LowQualityFood1",					// EEZYBEEF
	//	t"Items.LowQualityFood2",					// ???
		t"Items.LowQualityFood3",					// Hawt Dawg
	//	t"Items.LowQualityFood4",					// ???
		t"Items.LowQualityFood5",					// Moonchies
		t"Items.LowQualityFood6",					// Mr. Whitey
		t"Items.LowQualityFood7",					// Orgiatic Omniflave
		t"Items.LowQualityFood8",					// Pop-Turd
		t"Items.LowQualityFood9",					// Sojasil Dynamite
		t"Items.LowQualityFood10",					// Wontons
	//	t"Items.LowQualityFood11",					// Cat Food
		t"Items.LowQualityFood12",					// Holobites Grape Pie
		t"Items.LowQualityFood13",					// Holobites Mint Pie
		t"Items.LowQualityFood14",					// Holobites Peach Pie
		t"Items.LowQualityFood15",					// Orgiatic Salsa Agave
		t"Items.LowQualityFood16",					// Orgiatic Vinegar Chili
		t"Items.LowQualityFood17",					// Moonchies Andromeda
		t"Items.LowQualityFood18",					// Moonchies Pulsar
		t"Items.LowQualityFood19",					// Moonchies Sour Planet
		t"Items.LowQualityFood20",					// Leelou Beans Lagoon
		t"Items.LowQualityFood21",					// Leelou Beans Meyer Lemon
		t"Items.LowQualityFood22",					// Leelou Beans Plantain
		t"Items.LowQualityFood23",					// Leelou Beans Tropical
		t"Items.LowQualityFood24",					// Sojasil Eruption
		t"Items.LowQualityFood25",					// Sojasil Molotov Cocktail
		t"Items.LowQualityFood26",					// Sojasil Nitroglycerin
		t"Items.LowQualityFood27",					// Sojasil Radioactive
		t"Items.LowQualityFood28",					// Sojasil Second Impact
		// Decent Food
		t"Items.MediumQualityFood1",				// SynthSnack
		t"Items.MediumQualityFood2",				// RaMMMMen
		t"Items.MediumQualityFood3",				// Slaughterhouse Jerky
		t"Items.MediumQualityFood4",				// Burrito XXL
		t"Items.MediumQualityFood5",				// Meat Delight
		t"Items.MediumQualityFood6",				// Veggie Delight
		t"Items.MediumQualityFood7",				// Slaughterhouse Prime
		t"Items.MediumQualityFood8",				// Yikes! Tofu Bar
		t"Items.MediumQualityFood9",				// Ave Saitan
		t"Items.MediumQualityFood10",				// Jambalaya
		t"Items.MediumQualityFood11",				// Mr. Whitey Mint
		t"Items.MediumQualityFood12",				// Burrito XXL Rosado
		t"Items.MediumQualityFood13",				// Burrito XXL Turquesa
		t"Items.MediumQualityFood14",				// Mr. Whitey Crystal
		t"Items.MediumQualityFood15",				// Mr. Whitey Spiced
		t"Items.MediumQualityFood16",				// Taco
		t"Items.MediumQualityFood17",				// Shwabshwab Grape
		t"Items.MediumQualityFood18",				// Shwabshwab Ketchup
		t"Items.MediumQualityFood19",				// Shwabshwab Blue
		t"Items.MediumQualityFood20"				// Slaughterhouse Veggie
	]

	public func ItemList_CivDrinkDonations() -> array<TweakDBID> = [
		// Cheap Alcohol
		t"Items.LowQualityAlcohol1",				// Abydos Classic
		t"Items.LowQualityAlcohol2",				// Abydos King Size
		t"Items.LowQualityAlcohol3",				// Broseph Ale
		t"Items.LowQualityAlcohol4",				// Broseph Lager
		t"Items.LowQualityAlcohol5",				// 21st Stout
		t"Items.LowQualityAlcohol6",				// Bumelant
		t"Items.LowQualityAlcohol7",				// Chirrisco
		t"Items.LowQualityAlcohol8",				// Pitorro
		t"Items.LowQualityAlcohol9",				// Tequila Especial
		// Cheap Beverages
		t"Items.LowQualityDrink1",					// Matapang Coffee
		t"Items.LowQualityDrink2",					// Matapang Decaf
		t"Items.LowQualityDrink3",					// Dairing Dairy "Milkshake"
		t"Items.LowQualityDrink4",					// Spunky Monkey
		t"Items.LowQualityDrink5",					// Spunky Monkey Mint
		t"Items.LowQualityDrink6",					// Cirrus Cola Classic
		t"Items.LowQualityDrink7",					// Cirrus Cola Corn and Lemon
		t"Items.LowQualityDrink8",					// Cirrus Cola Blood Breeze
		t"Items.LowQualityDrink9",					// NiCola Blue
		t"Items.LowQualityDrink10",					// NiCola
		t"Items.LowQualityDrink11",					// Coffee
		t"Items.LowQualityDrink12",					// Coffee with Syn-Milk
		t"Items.LowQualityDrink13"					// Latte
	]

	public func ItemList_BadgeArmorSet() -> array<TweakDBID> = [
		t"Items.Cop_01_Set_Glasses",	// Holo-Tinted Badge Goggles
		t"Items.Cop_01_Set_Jacket",		// Heavy-Duty Aramid-Reinforced Badge Coat
		t"Items.Cop_01_Set_Pants",		// Anti-Puncture NeoTac Pants with Composite Lining
		t"Items.Cop_01_Set_Boots"		// Waterproof Badge Combat Boots
	]

	public static func GetSSX() -> ref<CopKillerTweaksSSX> {
		return GameInstance.GetScriptableServiceContainer().GetService(n"CopKiller.CopKillerTweaksSSX") as CopKillerTweaksSSX;
	}

}

public class CopKillerYML extends ScriptableTweak {

	protected cb func OnApply() -> Void {

		let ussx: ref<CopKillerSSX>			= CopKillerSSX.GetSSX();
		let tssx: ref<CopKillerTweaksSSX>	= CopKillerTweaksSSX.GetSSX();

		// Character Arrays

		let tCops_NCPD_Ranged: array<TweakDBID>									= tssx.CharList_Cops_Ranged();
		let tCops_NCPD_Melee: array<TweakDBID>									= tssx.CharList_Cops_Melee();
		let tCops_Badlands_Ranged: array<TweakDBID>								= tssx.CharList_BadlandsMilitech_Ranged();
		let tCops_Barghest_NonPrevention_Ranged: array<TweakDBID>				= tssx.CharList_Barghest_NonPrevention_Ranged();
		let tCops_Barghest_Ranged: array<TweakDBID>								= tssx.CharList_Barghest_Ranged();
		let tCops_BorderGuards_Melee: array<TweakDBID>							= tssx.CharList_BorderGuards_Melee();
		let tCops_BorderGuards_Ranged: array<TweakDBID>							= tssx.CharList_BorderGuards_Ranged();
		let tElite_Enforcers_Ranged: array<TweakDBID>							= tssx.CharList_Enforcers_Ranged();
		let tElite_Enforcers_Cyberware: array<TweakDBID>						= tssx.CharList_Enforcers_Cyberware();
		let tElite_Enforcers_Barghest_NonPrevention_Cyberware: array<TweakDBID>	= tssx.CharList_Enforcers_Barghest_NonPrevention_Cyberware();
		let tElite_Enforcers_Barghest_Cyberware: array<TweakDBID>				= tssx.CharList_Enforcers_Barghest_Cyberware();
		let tElite_Androids: array<TweakDBID>									= tssx.CharList_Androids();
		let tElite_Barghest_NonPrevention_Mechs: array<TweakDBID>				= tssx.CharList_Barghest_NonPrevention_Mechs();
		let tElite_Mechs: array<TweakDBID>										= tssx.CharList_Mechs();
		let tElite_Netwatch: array<TweakDBID>									= tssx.CharList_Netwatch();
		let tMaxTac_Ranged: array<TweakDBID>									= tssx.CharList_MaxTac_Ranged();
		let tMaxTac_Cyberware: array<TweakDBID>									= tssx.CharList_MaxTac_Cyberware();

		if ussx.bMS_AllBarghestAreCops {
			for character in tCops_Barghest_NonPrevention_Ranged				{ ArrayPush(tCops_Barghest_Ranged, character); };
			for character in tElite_Enforcers_Barghest_NonPrevention_Cyberware	{ ArrayPush(tElite_Enforcers_Barghest_Cyberware, character); };
			for character in tElite_Barghest_NonPrevention_Mechs				{ ArrayPush(tElite_Mechs, character); };
		};

		let tBountyHunters: array<TweakDBID>;

		if ussx.bMS_TraitorsAndBetrayers {
			tBountyHunters														= tssx.CharList_Prevention_BountyHunters();
		};

		if ussx.bRGvG && ussx.bMS_RGvG {

			let tRGvG_NCPD_Ranged: array<TweakDBID>								= tssx.CharList_RGvG_Cops_Ranged();
			let tRGvG_NCPD_Melee: array<TweakDBID>								= tssx.CharList_RGvG_Cops_Melee();
			let tRGvG_Elite_Enforcers_Ranged: array<TweakDBID>					= tssx.CharList_RGvG_Enforcers_Ranged();
			let tRGvG_Elite_Enforcers_Cyberware: array<TweakDBID>				= tssx.CharList_RGvG_Enforcers_Cyberware();
			let tRGvG_Elite_Androids: array<TweakDBID>							= tssx.CharList_RGvG_Androids();

			for character in tRGvG_NCPD_Ranged									{ if TDBID.IsValid(character) { ArrayPush(tCops_NCPD_Ranged, character); }; };
			for character in tRGvG_NCPD_Melee									{ if TDBID.IsValid(character) { ArrayPush(tCops_NCPD_Melee, character); }; };
			for character in tRGvG_Elite_Enforcers_Ranged						{ if TDBID.IsValid(character) { ArrayPush(tElite_Enforcers_Ranged, character); }; };
			for character in tRGvG_Elite_Enforcers_Cyberware					{ if TDBID.IsValid(character) { ArrayPush(tElite_Enforcers_Cyberware, character); }; };
			for character in tRGvG_Elite_Androids								{ if TDBID.IsValid(character) { ArrayPush(tElite_Androids, character); }; };

			ArrayClear(tRGvG_NCPD_Ranged);
			ArrayClear(tRGvG_NCPD_Melee);
			ArrayClear(tRGvG_Elite_Enforcers_Ranged);
			ArrayClear(tRGvG_Elite_Enforcers_Cyberware);
			ArrayClear(tRGvG_Elite_Androids);

		};

		let tAllCops: array<TweakDBID>;
		for character in tCops_NCPD_Ranged										{ ArrayPush(tAllCops, character); };
		for character in tCops_NCPD_Melee										{ ArrayPush(tAllCops, character); };
		for character in tCops_Badlands_Ranged									{ ArrayPush(tAllCops, character); };
		for character in tCops_Barghest_Ranged									{ ArrayPush(tAllCops, character); };
		for character in tCops_BorderGuards_Melee								{ ArrayPush(tAllCops, character); };
		for character in tCops_BorderGuards_Ranged								{ ArrayPush(tAllCops, character); };
		for character in tElite_Enforcers_Ranged								{ ArrayPush(tAllCops, character); };
		for character in tElite_Enforcers_Cyberware								{ ArrayPush(tAllCops, character); };
		for character in tElite_Enforcers_Barghest_Cyberware					{ ArrayPush(tAllCops, character); };
		for character in tElite_Androids										{ ArrayPush(tAllCops, character); };
		for character in tElite_Mechs											{ ArrayPush(tAllCops, character); };
		for character in tElite_Netwatch										{ ArrayPush(tAllCops, character); };
		for character in tMaxTac_Ranged											{ ArrayPush(tAllCops, character); };
		for character in tMaxTac_Cyberware										{ ArrayPush(tAllCops, character); };

		// Paranoia

		let tBaseCops: array<TweakDBID>											= tssx.CharList_Cops_Base_Records();
		let tQuestCops: array<TweakDBID>										= tssx.CharList_Cops_Quest();

		for character in tBaseCops	{ if ArrayContains(tAllCops, character) { ArrayRemove(tAllCops, character); }; };
		for character in tQuestCops	{ if ArrayContains(tAllCops, character) { ArrayRemove(tAllCops, character); }; };

		ArrayClear(tBaseCops);
		ArrayClear(tQuestCops);

		// ...

		if !ussx.bCopKillerNCPDFixesFilePresent {

			// Vanilla Bug Fix: Some Border Guards were not considered Police (causing NPCPuppet::IsCharacterPolice() to return false)

			if ussx.bMS_PoliceBorderGuardsFix {

				TweakDBManager.SetFlat(n"Character.max_border_guards.reactionPreset", t"ReactionPresets.Police_Aggressive");
				TweakDBManager.SetFlat(n"Character.max_border_guards_shotgun.reactionPreset", t"ReactionPresets.Police_Aggressive");
				TweakDBManager.SetFlat(n"Character.max_border_guards_baton.reactionPreset", t"ReactionPresets.Police_Aggressive");
				TweakDBManager.SetFlat(n"Character.max_border_minotaur.reactionPreset", t"ReactionPresets.Police_Aggressive");
				TweakDBManager.SetFlat(n"Character.max_border_drone_octant.reactionPreset", t"ReactionPresets.Police_Aggressive");

				TweakDBManager.SetFlat(n"Character.max_border_guards.threatTrackingPreset", t"TargetTracking.PreventionUnitPreset");
				TweakDBManager.SetFlat(n"Character.max_border_guards_shotgun.threatTrackingPreset", t"TargetTracking.PreventionUnitPreset");
				TweakDBManager.SetFlat(n"Character.max_border_guards_baton.threatTrackingPreset", t"TargetTracking.PreventionUnitPreset");
				TweakDBManager.SetFlat(n"Character.max_border_minotaur.threatTrackingPreset", t"TargetTracking.PreventionUnitPreset");
				TweakDBManager.SetFlat(n"Character.max_border_drone_octant.threatTrackingPreset", t"TargetTracking.PreventionUnitPreset");

				TweakDBManager.SetFlat(n"Character.max_border_guards.sensePreset", t"Senses.PreventionRelaxed");
				TweakDBManager.SetFlat(n"Character.max_border_guards_shotgun.sensePreset", t"Senses.PreventionRelaxed");
				TweakDBManager.SetFlat(n"Character.max_border_guards_baton.sensePreset", t"Senses.PreventionRelaxed");
				TweakDBManager.SetFlat(n"Character.max_border_minotaur.sensePreset", t"Senses.PreventionRelaxed");
				TweakDBManager.SetFlat(n"Character.max_border_drone_octant.sensePreset", t"Senses.PreventionRelaxed");

				TweakDBManager.SetFlat(n"Character.max_border_guards.alertedSensesPreset", "PreventionAlerted");
				TweakDBManager.SetFlat(n"Character.max_border_guards_shotgun.alertedSensesPreset", "PreventionAlerted");
				TweakDBManager.SetFlat(n"Character.max_border_guards_baton.alertedSensesPreset", "PreventionAlerted");
				TweakDBManager.SetFlat(n"Character.max_border_minotaur.alertedSensesPreset", "PreventionAlerted");
				TweakDBManager.SetFlat(n"Character.max_border_drone_octant.alertedSensesPreset", "PreventionAlerted");

				TweakDBManager.SetFlat(n"Character.max_border_guards.combatSensesPreset", "PreventionCombat");
				TweakDBManager.SetFlat(n"Character.max_border_guards_shotgun.combatSensesPreset", "PreventionCombat");
				TweakDBManager.SetFlat(n"Character.max_border_guards_baton.combatSensesPreset", "PreventionCombat");
				TweakDBManager.SetFlat(n"Character.max_border_minotaur.combatSensesPreset", "PreventionCombat");
				TweakDBManager.SetFlat(n"Character.max_border_drone_octant.combatSensesPreset", "PreventionCombat");

				TweakDBManager.SetFlat(n"Character.max_border_guards.relaxedSensesPreset", "PreventionRelaxed");
				TweakDBManager.SetFlat(n"Character.max_border_guards_shotgun.relaxedSensesPreset", "PreventionRelaxed");
				TweakDBManager.SetFlat(n"Character.max_border_guards_baton.relaxedSensesPreset", "PreventionRelaxed");
				TweakDBManager.SetFlat(n"Character.max_border_minotaur.relaxedSensesPreset", "PreventionRelaxed");
				TweakDBManager.SetFlat(n"Character.max_border_drone_octant.relaxedSensesPreset", "PreventionRelaxed");

			};

			// Vanilla Bug Fix: Some police had missing or incorrect archetype names

			if ussx.bMS_PoliceArchetypeNamesFix {

				TweakDBManager.SetFlat(n"ArchetypeType.GenericRangedT2.localizedName", n"LocKey#42635"); // "Patrol Officer"
				TweakDBManager.UpdateRecord(t"ArchetypeType.GenericRangedT2");
				TweakDBManager.SetFlat(n"ArchetypeData.GenericRangedT2.type", t"ArchetypeType.GenericRangedT2");
				TweakDBManager.UpdateRecord(t"ArchetypeData.GenericRangedT2");

				TweakDBManager.SetFlat(n"ArchetypeType.ShotgunnerT2.localizedName", n"LocKey#42635"); // "Patrol Officer"
				TweakDBManager.UpdateRecord(t"ArchetypeType.ShotgunnerT2");
				TweakDBManager.SetFlat(n"ArchetypeData.ShotgunnerT2.type", t"ArchetypeType.ShotgunnerT2");
				TweakDBManager.UpdateRecord(t"ArchetypeData.ShotgunnerT2");

				TweakDBManager.SetFlat(n"ArchetypeType.GenericRangedT3.localizedName", n"LocKey#22675"); // "Beat Cop"
				TweakDBManager.UpdateRecord(t"ArchetypeType.GenericRangedT3");
				TweakDBManager.SetFlat(n"ArchetypeData.GenericRangedT3.type", t"ArchetypeType.GenericRangedT3");
				TweakDBManager.UpdateRecord(t"ArchetypeData.GenericRangedT3");

				TweakDBManager.SetFlat(n"ArchetypeType.ShotgunnerT3.localizedName", n"LocKey#22675"); // "Beat Cop"
				TweakDBManager.UpdateRecord(t"ArchetypeType.ShotgunnerT3");
				TweakDBManager.SetFlat(n"ArchetypeData.ShotgunnerT3.type", t"ArchetypeType.ShotgunnerT3");
				TweakDBManager.UpdateRecord(t"ArchetypeData.ShotgunnerT3");

				TweakDBManager.SetFlat(n"Character.ncpd_enforcer_shotgun2_tactician_ma_rare_inline5.localizedName", n"LocKey#22682"); // "MaxTac Enforcer" to "Tactical Officer"

			};

			// Vanilla Bug Fix: Some NCPD names in scanner contain duplicates (eg. "Patrol Officer Patrol Officer")

			if ussx.bMS_PoliceScannerNamesFix {

				TweakDBManager.SetFlat(n"Character.prevention_police_rifle_ma.skipDisplayArchetype", true);
				TweakDBManager.SetFlat(n"Character.prevention_police_rifle_wa.skipDisplayArchetype", true);

			};

			// Vanilla Bug Fix: Some characters had the depreciated "Officer" rarity [NOT strictly a police fix]

			if ussx.bMS_OfficerRarityFix {

				for character in tssx.CharList_OfficerRarity() {
					if Equals(FromVariant<TweakDBID>(TweakDBInterface.GetFlat(character + t".rarity")), t"NPCRarity.Officer") {
						TweakDBManager.SetFlat(TweakToName(character + t".rarity"), t"NPCRarity.Rare");
						TweakDBManager.UpdateRecord(character);
					};
				};

			};

		};

		// Customized MaxTac Squad Composition

		if ussx.bMS_CustomizedMaxTacSquads {
			for vehicle in tssx.VehicleList_MaxTacAVs() {
				let i: Int32 = 0;
				let eMaxTacOp: eMaxTacOperator = eMaxTacOperator.Random;
				let MaxTacRecord: TweakDBID;
				let MaxTacRecords: array<TweakDBID>;
				while i < 4 {
					switch (i) {
						case 0: eMaxTacOp = ussx.eMS_MaxTacOperatorOne;		break;
						case 1: eMaxTacOp = ussx.eMS_MaxTacOperatorTwo;		break;
						case 2: eMaxTacOp = ussx.eMS_MaxTacOperatorThree;	break;
						case 3: eMaxTacOp = ussx.eMS_MaxTacOperatorFour;	break;
					};
					if Equals(eMaxTacOp, eMaxTacOperator.Random) {
						eMaxTacOp = IntEnum<eMaxTacOperator>(RandRange(1, 6));
					};
					switch (eMaxTacOp) {
						case eMaxTacOperator.Heavy:		MaxTacRecord = t"Character.maxtac_av_LMG_mb";			break;
						case eMaxTacOperator.Netrunner:	MaxTacRecord = t"Character.maxtac_av_netrunner_ma";		break;
						case eMaxTacOperator.Assault:	MaxTacRecord = t"Character.maxtac_av_riffle_ma";		break;
						case eMaxTacOperator.Sniper:	MaxTacRecord = t"Character.maxtac_av_sniper_wa_elite";	break;
						case eMaxTacOperator.Mantis:	MaxTacRecord = t"Character.maxtac_av_mantis_wa";		break;
					};
					if StrContains(TDBID.ToStringDEBUG(vehicle), "_2nd_wave") {
						if i == 3 && RandRange(0, 100) < ussx.nMS_MelissaRoryChance {
							MaxTacRecord = t"Character.mq030_melisa";
							ussx.bMelissaRoryChanceInit = true;
						} else {
							MaxTacRecord += t"_2nd_wave";
						};
					};
					ArrayPush(MaxTacRecords, MaxTacRecord);
					i += 1;
				};
				TweakDBManager.SetFlat(TweakToName(vehicle + t".preventionPassengers"), ToVariant(MaxTacRecords));
				TweakDBManager.UpdateRecord(vehicle);
			};
		};

		// Items

		if TweakDBManager.CloneRecord(n"Items.CopKiller_PervCopBD", t"Items.mq036_unmarked_bd_cartridge") {
			TweakDBManager.SetFlat(n"Items.CopKiller_PervCopBD.displayName", n"LocKey#CopKiller_PervCopBD_name");
			TweakDBManager.SetFlat(n"Items.CopKiller_PervCopBD.localizedDescription", n"LocKey#CopKiller_PervCopBD_desc");
			TweakDBManager.SetFlat(n"Items.CopKiller_PervCopBD.itemType", n"ItemType.Gen_Junk");
			let equipAreas: array<TweakDBID>;
			TweakDBManager.SetFlat(n"Items.CopKiller_PervCopBD.equipAreas", ToVariant(equipAreas));
			let objectActions: array<TweakDBID> = FromVariant<array<TweakDBID>>(TweakDBInterface.GetFlat(t"Items.mq036_unmarked_bd_cartridge.objectActions"));
			ArrayPush(objectActions, t"ItemAction.Disassemble");
			ArrayPush(objectActions, t"ItemAction.JunkDisassemble");
			TweakDBManager.SetFlat(n"Items.CopKiller_PervCopBD.objectActions", ToVariant(objectActions));
			let tags: array<CName> = FromVariant<array<CName>>(TweakDBInterface.GetFlat(t"Items.mq036_unmarked_bd_cartridge.tags"));
			ArrayRemove(tags, n"Quest");
			ArrayPush(tags, n"Junk");
			ArrayPush(tags, n"LootIconsExt_Part_braindance");
			TweakDBManager.SetFlat(n"Items.CopKiller_PervCopBD.tags", ToVariant(tags));
			TweakDBManager.UpdateRecord(t"Items.CopKiller_PervCopBD");
		};

		if TweakDBManager.CreateRecord(n"Loot.CopKiller_Confiscated_Datashard_01_ItemAction", n"gamedataItemAction_Record") {
			TweakDBManager.SetFlat(n"Loot.CopKiller_Confiscated_Datashard_01_ItemAction.actionName", n"Read");
			TweakDBManager.SetFlat(n"Loot.CopKiller_Confiscated_Datashard_01_ItemAction.hackCategory", t"HackCategory.NotAHack");
			TweakDBManager.SetFlat(n"Loot.CopKiller_Confiscated_Datashard_01_ItemAction.journalEntry", "onscreens/emails/quests/minor_quests/datashards/shards/CopKiller_Confiscated_Datashard_01");
			TweakDBManager.SetFlat(n"Loot.CopKiller_Confiscated_Datashard_01_ItemAction.objectActionType", t"ObjectActionType.Item");
			TweakDBManager.SetFlat(n"Loot.CopKiller_Confiscated_Datashard_01_ItemAction.removeAfterUse", true);
			TweakDBManager.UpdateRecord(t"Loot.CopKiller_Confiscated_Datashard_01_ItemAction");
			if TweakDBManager.CloneRecord(n"Items.CopKiller_Confiscated_Datashard_01", t"Items.ma_wbr_hil_05_onscreen_01_shard") {
				TweakDBManager.SetFlat(n"Items.CopKiller_Confiscated_Datashard_01.displayName", n"LocKey#999999999000"); // LocKey#CopKiller_Confiscated_Datashard_01_name
				TweakDBManager.SetFlat(n"Items.CopKiller_Confiscated_Datashard_01.localizedDescription", n"LocKey#999999999001"); // LocKey#CopKiller_Confiscated_Datashard_01_desc
				TweakDBManager.SetFlat(n"Items.CopKiller_Confiscated_Datashard_01.friendlyName", "");
				TweakDBManager.SetFlat(n"Items.CopKiller_Confiscated_Datashard_01.itemSecondaryAction", t"Loot.CopKiller_Confiscated_Datashard_01_ItemAction");
				let tags: array<CName> = FromVariant<array<CName>>(TweakDBInterface.GetFlat(t"Items.ma_wbr_hil_05_onscreen_01_shard.tags"));
				ArrayPush(tags, n"LootIconsExt_Part_shard");
				TweakDBManager.SetFlat(n"Items.CopKiller_Confiscated_Datashard_01.tags", ToVariant(tags));
				TweakDBManager.UpdateRecord(t"Items.CopKiller_Confiscated_Datashard_01");
			};
		};

		// Set Empty Loot Table

		if TweakDBManager.CreateRecord(n"LootTables.CopKiller_Empty", n"gamedataLootTable_Record") {
			TweakDBManager.SetFlat(n"LootTables.CopKiller_Empty.lootGenerationType", "dropChance");
			if TweakDBManager.CreateRecord(n"Loot.CopKiller_Empty", n"gamedataLootItem_Record") {
				TweakDBManager.SetFlat(n"Loot.CopKiller_Empty.dropChance", 1.0);
				TweakDBManager.SetFlat(n"Loot.CopKiller_Empty.itemID", t"Items.money");
				TweakDBManager.SetFlat(n"Loot.CopKiller_Empty.quantityModifiers", [ t"Price.PriceMultiplier" ] );
				TweakDBManager.UpdateRecord(t"Loot.CopKiller_Empty");
				TweakDBManager.SetFlat(n"LootTables.CopKiller_Empty.lootItems", [ t"Loot.CopKiller_Empty" ] );
				TweakDBManager.UpdateRecord(t"LootTables.CopKiller_Empty");
				for character in tAllCops {
					if Equals(FromVariant<TweakDBID>(TweakDBInterface.GetFlat(character + t".lootDrop")), t"LootTables.Empty") {
						TweakDBManager.SetFlat(TweakToName(character + t".lootDrop"), t"LootTables.CopKiller_Empty");
					};
				};
				if ussx.bMS_TraitorsAndBetrayers {
					for character in tBountyHunters {
						if Equals(FromVariant<TweakDBID>(TweakDBInterface.GetFlat(character + t".lootDrop")), t"LootTables.Empty") {
							TweakDBManager.SetFlat(TweakToName(character + t".lootDrop"), t"LootTables.CopKiller_Empty");
						};
					};
				};
			};
		};

		// Weapon Drops

		if ussx.bMS_CopsDropHeldWeapon {
			let tCops: array<TweakDBID> = tCops_NCPD_Ranged;
			for character in tCops_NCPD_Melee						{ ArrayPush(tCops, character); };
			for character in tCops_Badlands_Ranged					{ ArrayPush(tCops, character); };
			for character in tCops_Barghest_Ranged					{ ArrayPush(tCops, character); };
			for character in tCops_BorderGuards_Melee				{ ArrayPush(tCops, character); };
			for character in tCops_BorderGuards_Ranged				{ ArrayPush(tCops, character); };
			for character in tCops {
				TweakDBManager.SetFlat(TweakToName(character + t".dropsWeaponOnDeath"), true);
			};
		};

		if ussx.bMS_EliteCopsDropHeldWeapon {
			let tElite: array<TweakDBID> = tElite_Enforcers_Ranged;
			for character in tElite_Androids						{ ArrayPush(tElite, character); };
			for character in tElite_Netwatch						{ ArrayPush(tElite, character); };
			if ussx.bMS_TraitorsAndBetrayers {
				for character in tBountyHunters						{ ArrayPush(tElite, character); };
			};
			for character in tElite {
				TweakDBManager.SetFlat(TweakToName(character + t".dropsWeaponOnDeath"), true);
			};
		};

		if ussx.bMS_MaxTacDropHeldWeapon {
			for character in tMaxTac_Ranged {
				TweakDBManager.SetFlat(TweakToName(character + t".dropsWeaponOnDeath"), true);
			};
		};

		// Global Drops

		if ussx.bMS_CopsDropGlobalLoot {
			let tCops: array<TweakDBID> = tCops_NCPD_Ranged;
			for character in tCops_NCPD_Melee						{ ArrayPush(tCops, character); };
			for character in tCops_Badlands_Ranged					{ ArrayPush(tCops, character); };
			for character in tCops_Barghest_Ranged					{ ArrayPush(tCops, character); };
			for character in tCops_BorderGuards_Melee				{ ArrayPush(tCops, character); };
			for character in tCops_BorderGuards_Ranged				{ ArrayPush(tCops, character); };
			for character in tCops {
				TweakDBManager.SetFlat(TweakToName(character + t".dropsControlledLoot"), true);
			};
		};

		if ussx.bMS_EliteCopsDropGlobalLoot {
			let tElite: array<TweakDBID> = tElite_Enforcers_Ranged;
			for character in tElite_Enforcers_Cyberware				{ ArrayPush(tElite, character); };
			for character in tElite_Enforcers_Barghest_Cyberware	{ ArrayPush(tElite, character); };
			for character in tElite_Androids						{ ArrayPush(tElite, character); };
			for character in tElite_Mechs							{ ArrayPush(tElite, character); };
			for character in tElite_Netwatch						{ ArrayPush(tElite, character); };
			if ussx.bMS_TraitorsAndBetrayers {
				for character in tBountyHunters						{ ArrayPush(tElite, character); };
			};
			for character in tElite {
				TweakDBManager.SetFlat(TweakToName(character + t".dropsControlledLoot"), true);
			};
		};

		if ussx.bMS_MaxTacDropGlobalLoot {
			let tMaxTac: array<TweakDBID> = tMaxTac_Ranged;
			for character in tMaxTac_Cyberware						{ ArrayPush(tMaxTac, character); };
			for character in tMaxTac {
				TweakDBManager.SetFlat(TweakToName(character + t".dropsControlledLoot"), true);
			};
		};

		// Character Record Updates

		for character in tAllCops { TweakDBManager.UpdateRecord(character); };

		if ussx.bMS_TraitorsAndBetrayers {
			for character in tBountyHunters { TweakDBManager.UpdateRecord(character); };
		};

		ArrayClear(tAllCops);
		ArrayClear(tBountyHunters);

	}

}
