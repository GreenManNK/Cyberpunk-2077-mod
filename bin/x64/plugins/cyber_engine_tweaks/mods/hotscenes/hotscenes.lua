-- Feb 20, 2026 by anygoodname.

--[[ DISCLAIMER:

This mod is a non-commercial fan creation intended for personal use only.

By using the word "republish" I mean both republish and redistribute in this disclaimer:
You're not allowed to republish the mod without my consent or against the Nexusmods rules.
You're not allowed to republish parts of this mod code or files without consent. Either mine either other authors.
You can modify the mod code or files for your personal use only.
By modifying the mod code or files, you acknowledge I cannot support the modified mod code or files.
You're not allowed to publish your modifications to the mod code or files without my consent.
You're not allowed to publicly propose unauthorized changes to the mod code or files.
You're not allowed to use any part of the mod code or files for commercial purposes, advertising or promotion of any kind.
You can use the mod code and files to learn how to code this game mods and improve your skills.
You can use parts the code or file modifications in your creations only by my consent and on a credit note.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--

local hotscenes = {
	datasetVer = 4.1,
	datasetSubVer = 6,
	rootFolder = 'base\\hotscenes\\Performers\\',
	rootFolderEp1 = 'base\\hotscenes\\performers_game2_ep1\\',
	femaleScenes = {
		['Glen']		= {id = 10, sceneName = "Glen", displayName = "Dark Matter", gender = 'female', priceTag = 3000,	approachLocation = {pos = Vector4.new(-334.60, 232.30, 188.92, 1), yaw =  -92.3}, journalPathHash = 3313083774, journalMappins = {3313083774, 3313806824},	tdbidPath = 'Character.hey_gle_prostitute_female.entityTemplatePath',	performerFullName = 'Brittany Hayes',	onscreenTitle = 'LocKey#44127', performerEntPath = 'base\\open_world\\characters\\vendors\\hey_gle_prostitute_female.ent', clipFactStr = 'hey_gle_female_rich_sex_clip', isAvailable = true,
						characterTdbidPath = 'Character.hey_gle_prostitute_female', prerequisiteFacts = {'sq017_mq028_start', 'hey_gle_f_prostitue_met', 'hey_gle_pro_m_dreams'}, alreadyMetFact = 'hey_gle_f_prostitue_met', overrideFacts = {'ue_metro_ncart_message_done', 'q101_enable_side_content', 'sq017_mq028_start'}, sceneOverrideAvaliabilityFacts = {'q004_lizzies_know_you', 'q004_nightclub_entered', 'q101_enable_side_content'}, sceneStartupWsLocation = Vector4.new(-331.036, 232.1392, 188.9, 1), sceneSupport = "default"},
		['Japantown']	= {id = 20, sceneName = "Japantown", displayName = "Jig-Jig St", gender = 'female', priceTag = 100,	approachLocation = {pos = Vector4.new(-653.43, 842.98,  19.28, 1), yaw = -117.1}, journalPathHash = 3545685165, journalMappins = {3545685165, 3128176060},	tdbidPath = 'Character.wbr_jpn_prostitute_female.entityTemplatePath',	performerFullName = 'Charlene Fox',		onscreenTitle = 'LocKey#44127', performerEntPath = 'base\\open_world\\characters\\vendors\\wbr_jpn_prostitute_female.ent', clipFactStr = 'wbr_jpn_female_poor_sex_clip', isAvailable = true,
						characterTdbidPath = 'Character.wbr_jpn_prostitute_female', prerequisiteFacts = {'q101_enable_side_content', 'q101_done', 'holo_takemura_calls_v_start_count', 'sq018_active', 'sq018_done', 'wbr_jpn_prostitue_f_met', 'wbr_jpn_prostitue_m_met'}, alreadyMetFact = 'wbr_jpn_prostitue_f_met', overrideFacts = {'ue_metro_ncart_message_done', 'q101_enable_side_content', 'wbr_jpn_prostitue_f_met'}, sceneOverrideAvaliabilityFacts = {'q004_lizzies_know_you', 'q004_nightclub_entered'}, sceneStartupWsLocation = Vector4.new(-650.5292, 841.6667, 19.35, 1), sceneSupport = "default"},
	},
	maleScenes = {
		['Glen']		= {id = 30, sceneName = "Glen",displayName = "Dark Matter", gender = 'male', priceTag = 3000,	approachLocation = {pos = Vector4.new(-315.793, 235.346, 188.918, 1), yaw = 48.75}, journalPathHash = 3313806824, journalMappins = {3313083774, 3313806824}, tdbidPath = 'Character.hey_gle_prostitute_male.entityTemplatePath', performerFullName = 'Logan Scott',	onscreenTitle = 'LocKey#48989', performerEntPath = 'base\\open_world\\characters\\vendors\\hey_gle_prostitute_male.ent', clipFactStr = 'hey_gle_male_rich_sex_clip',	isAvailable = true,
						characterTdbidPath = 'Character.hey_gle_prostitute_male', prerequisiteFacts = {'sq017_mq028_start', 'hey_gle_f_prostitue_met', 'hey_gle_pro_m_dreams'}, alreadyMetFact = 'hey_gle_pro_m_dreams', overrideFacts = {'ue_metro_ncart_message_done', 'q101_enable_side_content', 'sq017_mq028_start'}, sceneOverrideAvaliabilityFacts = {'q004_lizzies_know_you', 'q004_nightclub_entered', 'q101_enable_side_content'}, sceneStartupWsLocation = Vector4.new(-317.927, 237.2739, 188.908, 1)},
		['Japantown']	= {id = 40, sceneName = "Japantown", displayName = "Jig-Jig St", gender = 'male', priceTag = 100,		approachLocation = {pos = Vector4.new(-656.65, 849.81,  19.23, 1), yaw = 85.7}, journalPathHash = 3128176060, journalMappins = {3545685165, 3128176060}, tdbidPath = 'Character.wbr_jpn_prostitute_male.entityTemplatePath', performerFullName = 'Dusty Lowe',		onscreenTitle = 'LocKey#48989', performerEntPath = 'base\\open_world\\characters\\vendors\\wbr_jpn_prostitute_male.ent', clipFactStr = 'wbr_jpn_female_poor_sex_clip',	isAvailable = true,
						characterTdbidPath = 'Character.wbr_jpn_prostitute_male', prerequisiteFacts = {'q101_done', 'holo_takemura_calls_v_start_count', 'sq018_active', 'sq018_done', 'wbr_jpn_prostitue_f_met'}, alreadyMetFact = 'wbr_jpn_prostitue_m_met', overrideFacts = {'ue_metro_ncart_message_done', 'q101_enable_side_content', 'wbr_jpn_prostitue_m_met'}, sceneOverrideAvaliabilityFacts = {'q004_lizzies_know_you', 'q004_nightclub_entered'}, sceneStartupWsLocation = Vector4.new(-659.8824, 850.099, 19.5862, 1)},
	},
	femalePerformers = {
		['Glen']		= {gender = 'female', performerFullName = 'Brittany Hayes (Gle default)',	scenes = {['Glen'] = {performerEntPath = nil},											['Japantown'] = {performerEntPath = 'glen_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Japantown']	= {gender = 'female', performerFullName = 'Charlene Fox (Jpn default)',		scenes = {['Glen'] = {performerEntPath = 'japantown_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = nil}}, sceneSupport = "default"},
		['Evelyn_v2']	= {gender = 'female', performerFullName = 'Evelyn Parker', 	scenes = {['Glen'] = {performerEntPath = 'evelyn_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'evelyn_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Glen_v2']		= {gender = 'female', performerFullName = 'Brittany Hayes', scenes = {['Glen'] = {performerEntPath = 'glen_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'glen_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Meredith_v2']	= {gender = 'female', performerFullName = 'Meredith Stout',	scenes = {['Glen'] = {performerEntPath = 'meredith_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'meredith_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Ruby_v2']		= {gender = 'female', performerFullName = 'Ruby Collins ',	scenes = {['Glen'] = {performerEntPath = 'ruby_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'ruby_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Ruby_no_tatts_v2']	= {gender = 'female', performerFullName = 'Ruby Collins (no tattoos)',	scenes = {['Glen'] = {performerEntPath = 'ruby_no_tatts_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'ruby_no_tatts_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Skye_v2']		= {gender = 'female', performerFullName = 'Skye',			scenes = {['Glen'] = {performerEntPath = 'skye_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'skye_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Skye_fewer_tatts_v2']	= {gender = 'female', performerFullName = 'Skye (fewer tattoos)',	scenes = {['Glen'] = {performerEntPath = 'skye_fewer_tatts_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'skye_fewer_tatts_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Cheri_v2']	= {gender = 'female', performerFullName = 'Cheri Nowlin',	scenes = {['Glen'] = {performerEntPath = 'cheri_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'cheri_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Cheri_no_tatts_v2']	= {gender = 'female', performerFullName = 'Cheri Nowlin (no tattoos)',	scenes = {['Glen'] = {performerEntPath = 'cheri_no_tatts_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'cheri_no_tatts_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Emilie_v2']	= {gender = 'female', performerFullName = 'Emilie Massenat',scenes = {['Glen'] = {performerEntPath = 'emilie_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'emilie_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Emilie_no_tatts_v2']	= {gender = 'female', performerFullName = 'Emilie Massenat (no tattoos)',	scenes = {['Glen'] = {performerEntPath = 'emilie_no_tatts_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'emilie_no_tatts_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Hanako_v2']	= {gender = 'female', performerFullName = 'Hanako Arasaka',	scenes = {['Glen'] = {performerEntPath = 'hanako_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'hanako_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Maiko_v2']	= {gender = 'female', performerFullName = 'Maiko Maeda',	scenes = {['Glen'] = {performerEntPath = 'maiko_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'maiko_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Rachel_v2']	= {gender = 'female', performerFullName = 'Rachel Casich',	scenes = {['Glen'] = {performerEntPath = 'rachel_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'rachel_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Japantown_v2']= {gender = 'female', performerFullName = 'Charlene Fox',	scenes = {['Glen'] = {performerEntPath = 'japantown_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'japantown_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Alt_v2']		= {gender = 'female', performerFullName = 'Alt Cunningham',	scenes = {['Glen'] = {performerEntPath = 'alt_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'alt_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Judy_v2']		= {gender = 'female', performerFullName = 'Judy Alvarez',	scenes = {['Glen'] = {performerEntPath = 'judy_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'judy_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "Japantown"},
		['Judy_no_tatts_v2']	= {gender = 'female', performerFullName = 'Judy Alvarez (no tattoos)',	scenes = {['Glen'] = {performerEntPath = 'judy_no_tatts_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'judy_no_tatts_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "Japantown"},
		['Panam_v2']	= {gender = 'female', performerFullName = 'Panam Palmer',	scenes = {['Glen'] = {performerEntPath = 'panam_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'panam_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "Japantown"},
		['Panam_no_tatts_v2']	= {gender = 'female', performerFullName = 'Panam Palmer (no tattoos)',	scenes = {['Glen'] = {performerEntPath = 'panam_no_tatts_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'panam_no_tatts_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "Japantown"},
		['Rich_12_v2']	= {gender = 'female', performerFullName = 'Inessa Stepanova',scenes = {['Glen'] = {performerEntPath = 'rich_12_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'rich_12_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Rita_v2']		= {gender = 'female', performerFullName = 'Rita Wheeler',	scenes = {['Glen'] = {performerEntPath = 'rita_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'rita_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Doll_02_v2']	= {gender = 'female', performerFullName = 'Mya Hicks',		scenes = {['Glen'] = {performerEntPath = 'doll_02_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'doll_02_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['Carol_v2']	= {gender = 'female', performerFullName = 'Carol Emeka',	scenes = {['Glen'] = {performerEntPath = 'carol_v2_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'carol_v2_wbr_jpn_prostitute_female.ent'}}},
		['doll_06_v2']	= {gender = 'female', performerFullName = 'Tomiko Anno (Yakuza Doll)',	scenes = {['Glen'] = {performerEntPath = 'doll_06_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'doll_06_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['doll_08_v2']	= {gender = 'female', performerFullName = 'Kaitlyn Dixon (Yakuza Doll)',	scenes = {['Glen'] = {performerEntPath = 'doll_08_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'doll_08_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['doll_01_v2']	= {gender = 'female', performerFullName = 'Sara Stokes (Doll )',	scenes = {['Glen'] = {performerEntPath = 'doll_01_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'doll_01_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['prostitute_wa_02_v2']	= {gender = 'female', performerFullName = 'Eve',	scenes = {['Glen'] = {performerEntPath = 'prostitute_wa_02_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'prostitute_wa_02_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['blue_moon_v2']	= {gender = 'female', performerFullName = 'Blue Moon (Us Cracks)',	scenes = {['Glen'] = {performerEntPath = 'blue_moon_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'blue_moon_v2_wbr_jpn_prostitute_female.ent'}}},
		['red_menace_v2']	= {gender = 'female', performerFullName = 'Red Menace (Us Cracks)',	scenes = {['Glen'] = {performerEntPath = 'red_menace_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'red_menace_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "Japantown"},
		['purple_force_v2']	= {gender = 'female', performerFullName = 'Purple Force (Us Cracks)',	scenes = {['Glen'] = {performerEntPath = 'purple_force_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'purple_force_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "Japantown"},
		['q000_kid_hooker_v2']	= {gender = 'female', performerFullName = 'Sofia (Street Kid Intro)',	scenes = {['Glen'] = {performerEntPath = 'q000_kid_hooker_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'q000_kid_hooker_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['q108_atlantis_f_02_vending_machine_v2'] = {gender = 'female', performerFullName = 'Yishen Rhee (Atlantis)',	scenes = {['Glen'] = {performerEntPath = 'q108_atlantis_f_02_vending_machine_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'q108_atlantis_f_02_vending_machine_v2_wbr_jpn_prostitute_female.ent'}}},
		['q108_atlantis_hood_hottie_wa_04_v2'] = {gender = 'female', performerFullName = 'Candice Nabita (Atlantis)',	scenes = {['Glen'] = {performerEntPath = 'q108_atlantis_hood_hottie_wa_04_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'q108_atlantis_hood_hottie_wa_04_v2_wbr_jpn_prostitute_female.ent'}}},
		['bushido_x_grace_v2'] = {gender = 'female', performerFullName = 'Grace (Bushido X)',	scenes = {['Glen'] = {performerEntPath = 'bushido_x_grace_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'bushido_x_grace_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['judy']		= {gender = 'female', performerFullName = 'Judy Alvarez (vanilla)',	scenes = {['Glen'] = {performerEntPath = 'judy_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'judy_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "Japantown"},
		['panam']	= {gender = 'female', performerFullName = 'Panam Palmer (vanilla)',	scenes = {['Glen'] = {performerEntPath = 'panam_hey_gle_prostitute_female.ent'},		['Japantown'] = {performerEntPath = 'panam_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "Japantown"},
		['doll_01_v2_no_cbware']	= {gender = 'female', performerFullName = 'Sara Stokes (Doll no cbware)',	scenes = {['Glen'] = {performerEntPath = 'doll_01_v2_no_cbware_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'doll_01_v2_no_cbware_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['angie_v2']	= {gender = 'female', performerFullName = 'Angie (Pakeha) Mielech',	scenes = {['Glen'] = {performerEntPath = 'angie_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'angie_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['rich_20_v2']	= {gender = 'female', performerFullName = 'Jade Douglas',	scenes = {['Glen'] = {performerEntPath = 'rich_20_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'rich_20_v2_wbr_jpn_prostitute_female.ent'}}, sceneSupport = "default"},
		['denny_v2']	= {gender = 'female', performerFullName = 'Denny',	scenes = {['Glen'] = {performerEntPath = 'denny_v2_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'denny_v2_wbr_jpn_prostitute_female.ent'}}},
		['player'] = {gender = 'female', performerFullName = "You", scenes = {['Glen'] = {isPlayer = true},	['Japantown'] = {isPlayer = true}}, isPlayer = true},
		['player_incognito'] = {gender = 'female', performerFullName = 'I wonder who that could be...', performerAlternativeFullName = "You", scenes = {['Glen'] = {isPlayer = true},	['Japantown'] = {isPlayer = true}}, isPlayer = true, isPlayerIncognito = true},

		['bella_v2_ep1']= {gender = 'female', performerFullName = 'Aurora Cassel (PhL)',	scenes = {['Glen'] = {performerEntPath = 'bella_v2_ep1_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'bella_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'q303_07_siblings_asked', 'q303_08_paradise_inside_exit_lift'}},
		['alex_v2_ep1']	= {gender = 'female', performerFullName = 'Alena Xenakis (PhL)',	scenes = {['Glen'] = {performerEntPath = 'alex_v2_ep1_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'alex_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'q303_05_safehouse_majesty_picked_up', 'q303_08_paradise_inside_exit_lift'}},
		['myers_v2_ep1']= {gender = 'female', performerFullName = 'Rosalind Myers (PhL)',	scenes = {['Glen'] = {performerEntPath = 'myers_v2_ep1_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'myers_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'q302_done', 'q302_07_oath_done', 'q303_started'}, sceneSupport = "default"},
		['angie_v2_ep1']= {gender = 'female', performerFullName = 'Angelica Whelan (PhL)',	scenes = {['Glen'] = {performerEntPath = 'angie_v2_ep1_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'angie_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'mq306_leaving_ripper', 'mq306_finished', 'mq306_done'}, sceneSupport = "default"},
		['paradise_guest_01_v2_ep1'] = {gender = 'female', performerFullName = 'Sadie Moody (PhL)', scenes = {['Glen'] = {performerEntPath = 'paradise_guest_01_v2_ep1_hey_gle_prostitute_female.ent'},['Japantown'] = {performerEntPath = 'paradise_guest_01_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'q303_07_siblings_asked', 'q303_08_paradise_inside_exit_lift'}, sceneSupport = "default"},
		['songbird_v2_ep1'] = {gender = 'female', performerFullName = 'Song So Mi (PhL)', scenes = {['Glen'] = {performerEntPath = 'songbird_v2_ep1_hey_gle_prostitute_female.ent'},['Japantown'] = {performerEntPath = 'songbird_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'q303_07_siblings_asked', 'q303_08_paradise_inside_exit_lift'}, sceneSupport = "default"},
		['q301_vendor_crier_female_v2_ep1'] = {gender = 'female', performerFullName = 'Imogen (PhL)', scenes = {['Glen'] = {performerEntPath = 'q301_vendor_crier_female_v2_ep1_hey_gle_prostitute_female.ent'},['Japantown'] = {performerEntPath = 'q301_vendor_crier_female_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'q301_02_done', 'q301_03_done', 'q302_done'}, sceneSupport = "default"},
		['lina_v2_ep1'] = {gender = 'female', performerFullName = 'Lina Malina (PhL)', scenes = {['Glen'] = {performerEntPath = 'lina_v2_ep1_hey_gle_prostitute_female.ent'},['Japantown'] = {performerEntPath = 'lina_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'mq303_finale_cia', 'mq303_finale_lina_gift', 'mq303_done'}},
		['toolina_v2_ep1'] = {gender = 'female', performerFullName = 'Toolina (PhL)', scenes = {['Glen'] = {performerEntPath = 'toolina_v2_ep1_hey_gle_prostitute_fake_female_mb.ent'},['Japantown'] = {performerEntPath = 'toolina_v2_ep1_wbr_jpn_prostitute_fake_female_mb.ent'}}, isEp1 = true, prerequisiteFacts = {'mq303_finale_cia', 'mq303_finale_lina_gift', 'mq303_done'}},
		['alex_bartender_v2_ep1']	= {gender = 'female', performerFullName = 'Daphne (Alex undercover PhL)',	scenes = {['Glen'] = {performerEntPath = 'alex_bartender_v2_ep1_hey_gle_prostitute_female.ent'},	['Japantown'] = {performerEntPath = 'alex_bartender_v2_ep1_wbr_jpn_prostitute_female.ent'}}, isEp1 = true, prerequisiteFacts = {'q303_v_shows_coin', 'q303_alex_bar_guest_chat_ended', 'q303_alex_finished_drink'}},
	},
	malePerformers = {
		['Japantown']	= {gender = 'male', performerFullName = 'Dusty Lowe (Jpn default)',		scenes = {['Glen'] = {performerEntPath = 'japantown_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = nil}}},
		['Glen']		= {gender = 'male', performerFullName = 'Logan Scott (Gle default)',	scenes = {['Glen'] = {performerEntPath = nil},										['Japantown'] = {performerEntPath = 'glen_wbr_jpn_prostitute_male.ent'}}},
		['Kerry_v2']	= {gender = 'male', performerFullName = 'Kerry Eurodyne',	scenes = {['Glen'] = {performerEntPath = 'kerry_v2_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'kerry_v2_wbr_jpn_prostitute_male.ent'}}},
		['Kerry_no_tatts_v2']	= {gender = 'male', performerFullName = 'Kerry Eurodyne (no tattoos)',	scenes = {['Glen'] = {performerEntPath = 'kerry_no_tatts_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'kerry_no_tatts_v2_wbr_jpn_prostitute_male.ent'}}},
		['River_v2']	= {gender = 'male', performerFullName = 'River Ward',		scenes = {['Glen'] = {performerEntPath = 'river_v2_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'river_v2_wbr_jpn_prostitute_male.ent'}}},
		['Japantown_v2']= {gender = 'male', performerFullName = 'Dusty Lowe',		scenes = {['Glen'] = {performerEntPath = 'japantown_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'japantown_v2_wbr_jpn_prostitute_male.ent'}}},
		['Glen_v2']		= {gender = 'male', performerFullName = 'Logan Scott',		scenes = {['Glen'] = {performerEntPath = 'glen_v2_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'glen_v2_wbr_jpn_prostitute_male.ent'}}},
		['Tom_v2']		= {gender = 'male', performerFullName = 'Tom Caldera',		scenes = {['Glen'] = {performerEntPath = 'tom_v2_hey_gle_prostitute_male.ent'},			['Japantown'] = {performerEntPath = 'tom_v2_wbr_jpn_prostitute_male.ent'}}},
		['Stripper_v2']	= {gender = 'male', performerFullName = 'Stripper',			scenes = {['Glen'] = {performerEntPath = 'stripper_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'stripper_v2_wbr_jpn_prostitute_male.ent'}}},
		['Angel_v2']	= {gender = 'male', performerFullName = 'Angel',			scenes = {['Glen'] = {performerEntPath = 'angel_v2_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'angel_v2_wbr_jpn_prostitute_male.ent'}}},
		['Mateo_v2']	= {gender = 'male', performerFullName = 'Mateo Thiago',		scenes = {['Glen'] = {performerEntPath = 'mateo_v2_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'mateo_v2_wbr_jpn_prostitute_male.ent'}}},
		['Lyle_v2']		= {gender = 'male', performerFullName = 'Lyle Thompson',	scenes = {['Glen'] = {performerEntPath = 'thompson_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'thompson_v2_wbr_jpn_prostitute_male.ent'}}},
		['dino_v2']		= {gender = 'male', performerFullName = 'Dino Dinovic',	scenes = {['Glen'] = {performerEntPath = 'dino_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'dino_v2_wbr_jpn_prostitute_male.ent'}}},
		['dino_no_tatts_v2']	= {gender = 'male', performerFullName = 'Dino Dinovic (no tattoos)',	scenes = {['Glen'] = {performerEntPath = 'dino_no_tatts_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'dino_no_tatts_v2_wbr_jpn_prostitute_male.ent'}}},
		['doll_06_v2']	= {gender = 'male', performerFullName = 'Jitu Nweke (Jig-Jig St Doll)',	scenes = {['Glen'] = {performerEntPath = 'doll_06_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'doll_06_v2_wbr_jpn_prostitute_male.ent'}}},
		['kirk_v2']	= {gender = 'male', performerFullName = 'Kirk Sawyer',	scenes = {['Glen'] = {performerEntPath = 'kirk_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'kirk_v2_wbr_jpn_prostitute_male.ent'}}},
		['bushido_x_jake_v2']	= {gender = 'male', performerFullName = 'Jake (Bushido X)',	scenes = {['Glen'] = {performerEntPath = 'bushido_x_jake_v2_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'bushido_x_jake_v2_wbr_jpn_prostitute_male.ent'}}},
		['river_v2_mq055']	= {gender = 'male', performerFullName = 'River Ward (on date)',		scenes = {['Glen'] = {performerEntPath = 'river_v2_mq055_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'river_v2_mq055_wbr_jpn_prostitute_male.ent'}}},
		['frank_v2']	= {gender = 'male', performerFullName = 'Frank Nostra',		scenes = {['Glen'] = {performerEntPath = 'frank_v2_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'frank_v2_wbr_jpn_prostitute_male.ent'}}},
		['jenkins_v2']	= {gender = 'male', performerFullName = 'Arthur Jenkins',		scenes = {['Glen'] = {performerEntPath = 'jenkins_v2_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'jenkins_v2_wbr_jpn_prostitute_male.ent'}}},
		['fingers_v2']	= {gender = 'male', performerFullName = 'Fingers',		scenes = {['Glen'] = {performerEntPath = 'fingers_v2_hey_gle_prostitute_male.ent'},		['Japantown'] = {performerEntPath = 'fingers_v2_wbr_jpn_prostitute_male.ent'}}},
		['player'] = {gender = 'male', performerFullName = "You", scenes = {['Glen'] = {isPlayer = true},	['Japantown'] = {isPlayer = true}}, isPlayer = true},
		['player_incognito'] = {gender = 'male', performerFullName = 'I wonder who that could be...', performerAlternativeFullName = "You", scenes = {['Glen'] = {isPlayer = true},	['Japantown'] = {isPlayer = true}}, isPlayer = true, isPlayerIncognito = true},

		['ronald_v2_ep1'] = {gender = 'male', performerFullName = 'Ronald P. T. Malone (PhL)',	scenes = {['Glen'] = {performerEntPath = 'ronald_v2_ep1_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'ronald_v2_ep1_wbr_jpn_prostitute_male.ent'}}, isEp1 = true, prerequisiteFacts = {'q302_ronald_known', 'q302_05_ronald_counter', 'q302_ronald_messages_enabled'}},
		['sts_ep1_06__dealer_v2_ep1'] = {gender = 'male', performerFullName = 'Jack (PhL)',	scenes = {['Glen'] = {performerEntPath = 'sts_ep1_06__dealer_v2_ep1_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'sts_ep1_06__dealer_v2_ep1_wbr_jpn_prostitute_male.ent'}}, isEp1 = true, prerequisiteFacts = {'sts_ep1_06_friend_left', 'sts_ep1_06_drug_dealer_meeting', 'sts_ep1_06_finished', 'sts_ep1_06_done'}},
		['shank_v2_ep1'] = {gender = 'male', performerFullName = 'Shank (PhL)',	scenes = {['Glen'] = {performerEntPath = 'shank_v2_ep1_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'shank_v2_ep1_wbr_jpn_prostitute_male.ent'}}, isEp1 = true, prerequisiteFacts = {'mq303_finale_cia', 'mq303_finale_lina_gift', 'mq303_done'}},
		['tool_v2_ep1'] = {gender = 'male', performerFullName = 'Tool (PhL)',	scenes = {['Glen'] = {performerEntPath = 'tool_v2_ep1_hey_gle_prostitute_male_mb.ent'},	['Japantown'] = {performerEntPath = 'tool_v2_ep1_wbr_jpn_prostitute_male_mb.ent'}}, isEp1 = true, prerequisiteFacts = {'mq303_finale_cia', 'mq303_finale_lina_gift', 'mq303_done'}},
		['toolina_v2_ep1'] = {gender = 'male', performerFullName = 'Toolina (PhL)',	scenes = {['Glen'] = {performerEntPath = 'toolina_v2_ep1_hey_gle_prostitute_male_mb.ent'},	['Japantown'] = {performerEntPath = 'toolina_v2_ep1_wbr_jpn_prostitute_male_mb.ent'}}, isEp1 = true, prerequisiteFacts = {'mq303_finale_cia', 'mq303_finale_lina_gift', 'mq303_done'}},
		['theo_v2_ep1'] = {gender = 'male', performerFullName = 'Aymeric Cassel (PhL)',	scenes = {['Glen'] = {performerEntPath = 'theo_v2_ep1_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'theo_v2_ep1_wbr_jpn_prostitute_male.ent'}}, isEp1 = true, prerequisiteFacts = {'q303_07_siblings_asked', 'q303_08_paradise_inside_exit_lift'}},
		['hasan_v2_ep1'] = {gender = 'male', performerFullName = 'Hasan Demir (PhL)',	scenes = {['Glen'] = {performerEntPath = 'hasan_v2_ep1_hey_gle_prostitute_male.ent'},	['Japantown'] = {performerEntPath = 'hasan_v2_ep1_wbr_jpn_prostitute_male.ent'}}, isEp1 = true, prerequisiteFacts = {'sts_ep1_04_finished', 'ep1_04_hasan_free'}},
	},
	is_mq055_integration_supported = true,
	mq055_partnersByName = {
		judy = {entryHash = 3753461090, gender = 'female'},
		panam = {entryHash = 106697448, gender = 'female'},
		kerry = {entryHash = 1207149997, gender = 'male'},
		river = {entryHash = 3806144830, gender = 'male'},
	},
	mq055_partnersByEntryHash = {
		["3753461090"] = {name = 'judy', entryHash = 3753461090, gender = 'female'},
		["106697448"] = {name = 'panam', entryHash = 106697448, gender = 'female'},
		["1207149997"] = {name = 'kerry', entryHash = 1207149997, gender = 'male'},
		["3806144830"] = {name = 'river', entryHash = 3806144830, gender = 'male'},
	},
	mq055_performers = {
		judy = {'Judy_v2', 'Judy_no_tatts_v2', 'judy'},
		panam = {'Panam_v2', 'Panam_no_tatts_v2', 'panam'},
		kerry = {'Kerry_v2', 'Kerry_no_tatts_v2'},
		river = {'river_v2_mq055', 'River_v2'},
	},
	mq055_performers_prefer_vanilla = {
		judy = {'judy', 'Judy_no_tatts_v2', 'Judy_v2'},
		panam = {'panam', 'Panam_no_tatts_v2', 'Panam_v2'},
		kerry = {'Kerry_v2', 'Kerry_no_tatts_v2'},
		river = {'river_v2_mq055', 'River_v2'},
	},
	mq055_scenes = {
		defaultJapantown = {'Japantown'},
		defaultGlen = {'Glen'},
		apart_hey_gle = {'Glen', 'Japantown'},
		aph10 = {'Glen', 'Japantown'},
		arasaka_hotel = {'Glen', 'Japantown'},
		cct_dtn_05 = {'Glen', 'Japantown'},
		cct_dtn_apt_01 = {'Glen', 'Japantown'},
		dollhouse = {'Glen', 'Japantown'},
		kerry_villa = {'Glen', 'Japantown'},
		q203_penthouse = {'Glen', 'Japantown'},
		wbr_jpn_apt_01 = {'Glen', 'Japantown'},
	},
}
return hotscenes