// ************************************************************************************************
// ***  Hangout Romances
// ***    Author: ArmanIII
// ************************************************************************************************

public static exec func HangoutsRomancesDebug(gi: GameInstance) -> Void {
	let questsSystem: wref<QuestsSystem> = gi.GetQuestsSystem();

	let mainStatus: Int32 = questsSystem.GetFact(n"a3_hangout_romances_running");
	let mainStatusStr: String = "";
	if mainStatus == 0 { mainStatusStr = "not active"; }
	if mainStatus == 1 { mainStatusStr = "active, waiting for scene launch and selecting hangout partner condition"; }
	if mainStatus == 2 { mainStatusStr = "active, waiting for hangout conditions"; }
	
	FTLog("===============================");
	FTLog("====Hangouts Romances Debug====");
	FTLog("===============================");
	FTLog("Main mod status: " + mainStatusStr);
	FTLog("If a condition below was met, it's showing true, otherwise false.");
	FTLog("----");

	let partner_mq055_judy: Int32 = questsSystem.GetFact(n"mq055_judy");
	let partner_mq055_kerry: Int32 = questsSystem.GetFact(n"mq055_kerry");
	let partner_mq055_panam: Int32 = questsSystem.GetFact(n"mq055_panam");
	let partner_mq055_river: Int32 = questsSystem.GetFact(n"mq055_river");

	let selPartner: String = "-";
	if partner_mq055_judy > 0 { selPartner = "Judy"; }
	if partner_mq055_kerry > 0 { selPartner = "Kerry"; }
	if partner_mq055_panam > 0 { selPartner = "Panam"; }
	if partner_mq055_river > 0 { selPartner = "River"; }

	FTLog("Selected partner: " + selPartner);
	FTLog("----");

	FTLog("[H10 apartment]");
	let megabuilding_mq055_default_off: Int32 = questsSystem.GetFact(n"mq055_default_off");
	let megabuilding_mq055_cuddle_loop_finished: Int32 = questsSystem.GetFact(n"mq055_cuddle_loop_finished");
	let megabuilding_mq055_shower: Int32 = questsSystem.GetFact(n"mq055_shower");
	let megabuilding_mq055_v_sits_sofa: Int32 = questsSystem.GetFact(n"mq055_v_sits_sofa");

	FTLog("-Default state: " + (megabuilding_mq055_default_off == 0 ? "True" : "False"));
	FTLog("-Cuddle finished: " + (megabuilding_mq055_cuddle_loop_finished > 0 ? "True" : "False"));
	FTLog("-Shower finished: " + (megabuilding_mq055_shower == 1 ? "True" : "False"));
	FTLog("-Player not siting: " + (megabuilding_mq055_v_sits_sofa == 0 ? "True" : "False"));
	FTLog("----");

	FTLog("[Northside Apartment]");
	let northside_mq055_02_intimate_action_on: Int32 = questsSystem.GetFact(n"mq055_02_intimate_action_on");
	let northside_mq055_02_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_02_cuddleloop_done");
	let northside_mq055_02_shower_done_judy: Int32 = questsSystem.GetFact(n"mq055_02_shower_done_judy");
	let northside_mq055_02_shower_done_kerry: Int32 = questsSystem.GetFact(n"mq055_02_shower_done_kerry");
	let northside_mq055_02_shower_done_panam: Int32 = questsSystem.GetFact(n"mq055_02_shower_done_panam");
	let northside_mq055_02_shower_done_river: Int32 = questsSystem.GetFact(n"mq055_02_shower_done_river");
	let northside_mq055_02_player_sits: Int32 = questsSystem.GetFact(n"mq055_02_player_sits");

	FTLog("-Intimate / interaction not active: " + (northside_mq055_02_intimate_action_on == 0 ? "True" : "False"));
	FTLog("-Cuddle finished: " + (northside_mq055_02_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-[Judy] Shower finished: " + (northside_mq055_02_shower_done_judy == 1 ? "True" : "False"));
	FTLog("-[Kerry] Shower finished: " + (northside_mq055_02_shower_done_kerry == 1 ? "True" : "False"));
	FTLog("-[Panam] Shower finished: " + (northside_mq055_02_shower_done_panam == 1 ? "True" : "False"));
	FTLog("-[River] Shower finished: " + (northside_mq055_02_shower_done_river == 1 ? "True" : "False"));
	FTLog("-Player not siting: " + (northside_mq055_02_player_sits == 0 ? "True" : "False"));
	FTLog("----");

	FTLog("[Japantown Apartment]");
	let japantown_mq055_03_intimate_action_on: Int32 = questsSystem.GetFact(n"mq055_03_intimate_action_on");
	let japantown_mq055_03_kill_loop_npc: Int32 = questsSystem.GetFact(n"mq055_03_kill_loop_npc");
	let japantown_mq055_03_judy_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_03_judy_cuddleloop_done");
	let japantown_mq055_03_kerry_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_03_kerry_cuddleloop_done");
	let japantown_mq055_03_panam_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_03_panam_cuddleloop_done");
	let japantown_mq055_03_river_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_03_river_cuddleloop_done");
	let japantown_mq055_03_shower_done_npc: Int32 = questsSystem.GetFact(n"mq055_03_shower_done_npc");
	let japantown_mq055_03_player_sits: Int32 = questsSystem.GetFact(n"mq055_03_player_sits");

	FTLog("-Intimate / interaction not active: " + (japantown_mq055_03_intimate_action_on == 0 ? "True" : "False"));
	FTLog("-NPC is free: " + (japantown_mq055_03_kill_loop_npc == 0 ? "True" : "False"));
	FTLog("-[Judy] Cuddle finished: " + (japantown_mq055_03_judy_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-[Kerry] Cuddle finished: " + (japantown_mq055_03_kerry_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-[Panam] Cuddle finished: " + (japantown_mq055_03_panam_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-[River] Cuddle finished: " + (japantown_mq055_03_river_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-Shower finished: " + (japantown_mq055_03_shower_done_npc == 1 ? "True" : "False"));
	FTLog("-Player not siting: " + (japantown_mq055_03_player_sits == 0 ? "True" : "False"));
	FTLog("----");

	FTLog("[Glen Apartment]");
	let heywood_mq055_pc_trigger_active: Int32 = questsSystem.GetFact(n"mq055_pc_trigger_active");
	let heywood_mq055_04_intimate_action_on: Int32 = questsSystem.GetFact(n"mq055_04_intimate_action_on");
	let heywood_mq055_default_active: Int32 = questsSystem.GetFact(n"mq055_default_active");
	let heywood_mq055_04_judy_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_04_judy_cuddleloop_done");
	let heywood_mq055_04_kerry_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_04_kerry_cuddleloop_done");
	let heywood_mq055_04_panam_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_04_panam_cuddleloop_done");
	let heywood_mq055_04_river_cuddleloop_done: Int32 = questsSystem.GetFact(n"mq055_04_river_cuddleloop_done");
	let heywood_mq055_04_shower_done_judy: Int32 = questsSystem.GetFact(n"mq055_04_shower_done_judy");
	let heywood_mq055_04_shower_done_kerry: Int32 = questsSystem.GetFact(n"mq055_04_shower_done_kerry");
	let heywood_mq055_04_shower_done_panam: Int32 = questsSystem.GetFact(n"mq055_04_shower_done_panam");
	let heywood_mq055_04_shower_done_river: Int32 = questsSystem.GetFact(n"mq055_04_shower_done_river");
	let heywood_mq055_04_player_sits: Int32 = questsSystem.GetFact(n"mq055_04_player_sits");

	FTLog("-PC trigger: " + (heywood_mq055_pc_trigger_active == 0 ? "True" : "False"));
	FTLog("-Intimate / interaction not active: " + (heywood_mq055_04_intimate_action_on == 0 ? "True" : "False"));
	FTLog("-Idle state, not action is active: " + (heywood_mq055_default_active == 0 ? "True" : "False"));
	FTLog("-[Judy] Cuddle finished: " + (heywood_mq055_04_judy_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-[Kerry] Cuddle finished: " + (heywood_mq055_04_kerry_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-[Panam] Cuddle finished: " + (heywood_mq055_04_panam_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-[River] Cuddle finished: " + (heywood_mq055_04_river_cuddleloop_done == 1 ? "True" : "False"));
	FTLog("-[Judy] Shower finished: " + (heywood_mq055_04_shower_done_judy == 1 ? "True" : "False"));
	FTLog("-[Kerry] Shower finished: " + (heywood_mq055_04_shower_done_kerry == 1 ? "True" : "False"));
	FTLog("-[Panam] Shower finished: " + (heywood_mq055_04_shower_done_panam == 1 ? "True" : "False"));
	FTLog("-[River] Shower finished: " + (heywood_mq055_04_shower_done_river == 1 ? "True" : "False"));
	FTLog("-Player not siting: " + (heywood_mq055_04_player_sits == 0 ? "True" : "False"));
	FTLog("----");

	FTLog("[Corpo Plaza Apartment]");
	let downtown_mq055_05_intimate_action_on: Int32 = questsSystem.GetFact(n"mq055_05_intimate_action_on");
	let downtown_mq055_05_npc_sleeps: Int32 = questsSystem.GetFact(n"mq055_05_npc_sleeps");
	let downtown_mq055_05_kill_loop_npc: Int32 = questsSystem.GetFact(n"mq055_05_kill_loop_npc");
	let downtown_mq055_cuddle_loop_finished: Int32 = questsSystem.GetFact(n"mq055_cuddle_loop_finished");
	let downtown_mq055_05_shower_done_npc: Int32 = questsSystem.GetFact(n"mq055_05_shower_done_npc");
	let downtown_mq055_05_player_sits: Int32 = questsSystem.GetFact(n"mq055_05_player_sits");

	FTLog("-Intimate / interaction not active: " + (downtown_mq055_05_intimate_action_on == 0 ? "True" : "False"));
	FTLog("-NPC is not sleeping: " + (downtown_mq055_05_npc_sleeps == 0 ? "True" : "False"));
	FTLog("-NPC is free: " + (downtown_mq055_05_kill_loop_npc == 0 ? "True" : "False"));
	FTLog("-Cuddle finished: " + (downtown_mq055_cuddle_loop_finished == 1 ? "True" : "False"));
	FTLog("-Shower finished: " + (downtown_mq055_05_shower_done_npc == 1 ? "True" : "False"));
	FTLog("-Player not siting: " + (downtown_mq055_05_player_sits == 0 ? "True" : "False"));

	FTLog("===============================");
}
