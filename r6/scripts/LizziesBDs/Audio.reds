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

module LizziesBDs.Audio

class LizziesBDsAudio extends ScriptableService {
	private cb func OnLoad() {
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Loaded", this, n"OnEventsMetadataReady")
			.AddTarget(ResourceTarget.Path(r"base\\sound\\event\\eventsmetadata.json"));
		GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Loaded", this, n"OnVOLanguageDataMapReady")
			.AddTarget(ResourceTarget.Path(r"base\\localization\\volanguagedatamap.json"));
		/*GameInstance.GetCallbackSystem()
			.RegisterCallback(n"Resource/Load", this, n"OnSoundBanksReady")
			.AddTarget(ResourceTarget.Path(r"base\\sound\\event\\soundbanks.json"));*/
	}

	private cb func OnVOLanguageDataMapReady(event: ref<ResourceEvent>) {
		let jsonResource = event.GetResource() as JsonResource;
		let arr = jsonResource.root as locVoLanguageDataMap;

		let path0: ResourceAsyncRef;
		ResourceAsyncRef.SetPath(path0, r"mod\\arman3_lizzies_bds\\localization\\de-de\\voiceovermap.json");
		ArrayPush(arr.entries[0].voMapChunks, path0);

		let path1: ResourceAsyncRef;
		ResourceAsyncRef.SetPath(path1, r"mod\\arman3_lizzies_bds\\localization\\en-us\\voiceovermap.json");
		ArrayPush(arr.entries[1].voMapChunks, path1);
		ArrayPush(arr.entries[2].voMapChunks, path1);
		ArrayPush(arr.entries[3].voMapChunks, path1);
		ArrayPush(arr.entries[4].voMapChunks, path1);
		ArrayPush(arr.entries[5].voMapChunks, path1);
		ArrayPush(arr.entries[6].voMapChunks, path1);
		ArrayPush(arr.entries[7].voMapChunks, path1);
		ArrayPush(arr.entries[8].voMapChunks, path1);
		ArrayPush(arr.entries[9].voMapChunks, path1);
		ArrayPush(arr.entries[10].voMapChunks, path1);
		
		let path11: ResourceAsyncRef;
		ResourceAsyncRef.SetPath(path11, r"mod\\arman3_lizzies_bds\\localization\\common\\voiceovermap.json");
		ArrayPush(arr.entries[11].voMapChunks, path11);
	}

	/*private cb func OnSoundBanksReady(event: ref<ResourceEvent>) {
		let jsonResource = event.GetResource() as SoundBanksJson;
		
		let sb: Int32 = ArraySize(jsonResource.soundBanks);
		ArrayResize(jsonResource.soundBanks, sb + 1);

		jsonResource.soundBanks[sb].name = n"lizziesbds_soundbank";
		jsonResource.soundBanks[sb].isResident = true;
		jsonResource.soundBanks[sb].resourcePath = r"base\\sound\\soundbanks\\lizziesbds_soundbank.bnk";
	}*/

	private cb func OnEventsMetadataReady(event: ref<ResourceEvent>) {
		let jsonResource = event.GetResource() as JsonResource;
		let arr = jsonResource.root as audioAudioEventArray;

		let ev: Int32 = ArraySize(arr.events);
		ArrayResize(arr.events, ev + 105);

		let sw: Int32 = ArraySize(arr.switch);
		ArrayResize(arr.switch, sw + 31);

		let sg: Int32 = ArraySize(arr.switchGroup);
		ArrayResize(arr.switchGroup, sg + 11);

		let gp: Int32 = ArraySize(arr.gameParameter);
		ArrayResize(arr.gameParameter, gp + 2);

		// ======================================================
		// Volume game parameter for moaning VOs
		arr.gameParameter[gp].isLooping = false;
		arr.gameParameter[gp].maxAttenuation = 0;
		arr.gameParameter[gp].maxDuration = 0;
		arr.gameParameter[gp].minDuration = 0;
		arr.gameParameter[gp].redId = n"lizzies_bds_perf_volume";
		arr.gameParameter[gp].wwiseId = 812734666u;
		gp += 1;

		// Volume game parameter for story moaning VOs
		arr.gameParameter[gp].isLooping = false;
		arr.gameParameter[gp].maxAttenuation = 0;
		arr.gameParameter[gp].maxDuration = 0;
		arr.gameParameter[gp].minDuration = 0;
		arr.gameParameter[gp].redId = n"lizzies_bds_perf2_volume";
		arr.gameParameter[gp].wwiseId = 1439422938u;
		gp += 1;
		// ======================================================

		// ======================================================
		// CHIAA Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_chiaa_play";
		arr.events[ev].wwiseId = 1092309417u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_chiaa_stop";
		arr.events[ev].wwiseId = 2614726351u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_chiaa_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Ferris Wheel Sound
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sfx_ferris_wheel_play";
		arr.events[ev].wwiseId = 1878136320u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sfx_ferris_wheel_stop";
		arr.events[ev].wwiseId = 221395330u;
		ArrayPush(arr.events[ev].stopActionEvents, n"lizzies_bds_sfx_ferris_wheel_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Circus Minimus Music
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_circus_minimus_play";
		arr.events[ev].wwiseId = 3261433343u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_circus_minimus_stop";
		arr.events[ev].wwiseId = 2794218013u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_circus_minimus_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Dive Music
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_beach_house_dive_play";
		arr.events[ev].wwiseId = 3837749426u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_beach_house_dive_stop";
		arr.events[ev].wwiseId = 1212762924u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_beach_house_dive_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// This Fffire Music
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_this_fffire_play";
		arr.events[ev].wwiseId = 1668039108u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_this_fffire_stop";
		arr.events[ev].wwiseId = 145519038u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_this_fffire_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Bells of Laguna Bend Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_bells_of_laguna_bend_play";
		arr.events[ev].wwiseId = 3157280240u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_bells_of_laguna_bend_stop";
		arr.events[ev].wwiseId = 1464185234u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_bells_of_laguna_bend_play");
		ev += 1;
		
		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_bells_of_laguna_bend_end";
		arr.switch[sw].wwiseId = 2736466604u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_bells_of_laguna_bend";
		arr.switchGroup[sg].wwiseId = 1886990582u;
		sg += 1;
		// ======================================================

		// ======================================================
		// SQ027 Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_sq027_play";
		arr.events[ev].wwiseId = 972798358u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_sq027_stop";
		arr.events[ev].wwiseId = 1703335720u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_sq027_play");
		ev += 1;
		
		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_sq027_loop";
		arr.switch[sw].wwiseId = 1501081203u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_sq027_scene";
		arr.switch[sw].wwiseId = 1530733971u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_sq027";
		arr.switchGroup[sg].wwiseId = 3774653250u;
		sg += 1;
		// ======================================================

		// ======================================================
		// Us Cracks Stuff
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 60;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_us_cracks_emitter";
		arr.events[ev].wwiseId = 2637351045u;
		ev += 1;

		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 60;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_us_cracks_emitter_delayed";
		arr.events[ev].wwiseId = 3574594042u;
		ev += 1;

		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 60;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_us_cracks_emitter_low_occl";
		arr.events[ev].wwiseId = 2634508442u;
		ev += 1;

		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_uscracks_play";
		arr.events[ev].wwiseId = 1897785622u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_uscracks_stop";
		arr.events[ev].wwiseId = 2628322984u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_uscracks_play");
		ev += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_uscracks_userfriendly";
		arr.switch[sw].wwiseId = 1138925403u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_uscracks_offtheleash";
		arr.switch[sw].wwiseId = 3836600886u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_uscracks";
		arr.switchGroup[sg].wwiseId = 2687060412u;
		sg += 1;

		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_crowd_play";
		arr.events[ev].wwiseId = 739078840u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_crowd_stop";
		arr.events[ev].wwiseId = 3111526154u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_crowd_play");
		ev += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_crowd_weak";
		arr.switch[sw].wwiseId = 26119415u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_crowd_welcome";
		arr.switch[sw].wwiseId = 932172157u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_crowd_silent";
		arr.switch[sw].wwiseId = 3208962112u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_crowd_end";
		arr.switch[sw].wwiseId = 3470470226u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_crowd";
		arr.switchGroup[sg].wwiseId = 1711967052u;
		sg += 1;
		// ======================================================

		// ======================================================
		// Beach EE Music
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_beach_ee_play";
		arr.events[ev].wwiseId = 2845617507u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_beach_ee_stop";
		arr.events[ev].wwiseId = 907194665u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_beach_ee_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Let You Down BD Video Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 257;
		arr.events[ev].minDuration = 257;
		arr.events[ev].redId = n"mus_lizzies_bds_let_you_down_video_play";
		arr.events[ev].wwiseId = 160763139u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_let_you_down_video_stop";
		arr.events[ev].wwiseId = 2517204681u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_let_you_down_video_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// I Really Want To Stay At Your House BD Video Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 246;
		arr.events[ev].minDuration = 246;
		arr.events[ev].redId = n"mus_lizzies_bds_irwtsayh_video_play";
		arr.events[ev].wwiseId = 1120557864u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_irwtsayh_video_stop";
		arr.events[ev].wwiseId = 3498228122u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_irwtsayh_video_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Let You Down Music
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_let_you_down_play";
		arr.events[ev].wwiseId = 1619214867u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_let_you_down_stop";
		arr.events[ev].wwiseId = 749337081u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_let_you_down_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// I Really Want To Stay At Your House Music
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_irwtsayh_play";
		arr.events[ev].wwiseId = 221364944u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_irwtsayh_stop";
		arr.events[ev].wwiseId = 2864814194u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_irwtsayh_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Q50 Glitch
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_q50_play";
		arr.events[ev].wwiseId = 3834831391u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_q50_stop";
		arr.events[ev].wwiseId = 3367513149u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_q50_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Q105 Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_q105_mus_play";
		arr.events[ev].wwiseId = 3576799764u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_q105_mus_stop";
		arr.events[ev].wwiseId = 985735150u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_q105_mus_play");
		ev += 1;
		
		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_q105_main_stopped";
		arr.switch[sw].wwiseId = 452256008u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_q105_main_play";
		arr.switch[sw].wwiseId = 1889140867u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_q105_main";
		arr.switchGroup[sg].wwiseId = 3993675850u;
		sg += 1;
		
		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_q105_ambient_romance";
		arr.switch[sw].wwiseId = 2269763961u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_q105_ambient_play";
		arr.switch[sw].wwiseId = 1635364724u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_q105_ambient";
		arr.switchGroup[sg].wwiseId = 4238127603u;
		sg += 1;
		// ======================================================

		// ======================================================
		// Q108 Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_q108_mus_play";
		arr.events[ev].wwiseId = 1245952507u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_q108_mus_stop";
		arr.events[ev].wwiseId = 115415217u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_q108_mus_play");
		ev += 1;
		
		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_q108_exit_loop";
		arr.switch[sw].wwiseId = 250857751u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_q108_end_part";
		arr.switch[sw].wwiseId = 1286617575u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_q108";
		arr.switchGroup[sg].wwiseId = 103569283u;
		sg += 1;
		// ======================================================

		// ======================================================
		// SQ030 Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_sq030_full_play";
		arr.events[ev].wwiseId = 3042939184u;
		ev += 1;

		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_sq030_loop_play";
		arr.events[ev].wwiseId = 632967107u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_sq030_stop";
		arr.events[ev].wwiseId = 347670328u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_sq030_full_play");
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_sq030_loop_play");
		ev += 1;
		
		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_sq030_exit_loop";
		arr.switch[sw].wwiseId = 1282699638u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_sq030";
		arr.switchGroup[sg].wwiseId = 3757875666u;
		sg += 1;
		// ======================================================

		// ======================================================
		// SQ031 Music
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_sq031_mus_play";
		arr.events[ev].wwiseId = 2890932577u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_sq031_mus_stop";
		arr.events[ev].wwiseId = 957604919u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_sq031_mus_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// MQ014 Music
		arr.events[ev].isLooping = true;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_mq014_mus_play";
		arr.events[ev].wwiseId = 2016345766u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_mq014_mus_stop";
		arr.events[ev].wwiseId = 3867450264u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_mq014_mus_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Hole In The Sun Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_hole_in_the_sun_play";
		arr.events[ev].wwiseId = 1673817736u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_hole_in_the_sun_stop";
		arr.events[ev].wwiseId = 4051385082u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_hole_in_the_sun_play");
		ev += 1;
		
		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_hole_in_the_sun_loop";
		arr.switch[sw].wwiseId = 1233803817u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_hole_in_the_sun_end";
		arr.switch[sw].wwiseId = 3236597710u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_hole_in_the_sun";
		arr.switchGroup[sg].wwiseId = 3695813592u;
		sg += 1;
		// ======================================================

		// ======================================================
		// Midnight Eye Music
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_midnight_eye_play";
		arr.events[ev].wwiseId = 1568062063u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_midnight_eye_stop";
		arr.events[ev].wwiseId = 4285589613u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_midnight_eye_play");
		ev += 1;
		
		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_midnight_eye_end";
		arr.switch[sw].wwiseId = 1873556309u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_midnight_eye_loop";
		arr.switch[sw].wwiseId = 608720128u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_midnight_eye";
		arr.switchGroup[sg].wwiseId = 3928392291u;
		sg += 1;
		// ======================================================

		// ======================================================
		// Music 01
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_music_01_play";
		arr.events[ev].wwiseId = 2519536634u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"mus_lizzies_bds_music_01_stop";
		arr.events[ev].wwiseId = 3960092164u;
		ArrayPush(arr.events[ev].stopActionEvents, n"mus_lizzies_bds_music_01_play");
		ev += 1;
		// ======================================================

		// ======================================================
		// Toilet SFX
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sfx_toilet";
		arr.events[ev].wwiseId = 1947018303u;
		ev += 1;
		// ======================================================
		
		// ======================================================
		// SQ027 SFX
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sfx_sq027_v";
		arr.events[ev].wwiseId = 406965666u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sfx_sq027_panam";
		arr.events[ev].wwiseId = 3980130403u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sfx_sq027_stop";
		arr.events[ev].wwiseId = 3293361716u;
		ArrayPush(arr.events[ev].stopActionEvents, n"lizzies_bds_sfx_sq027_v");
		ArrayPush(arr.events[ev].stopActionEvents, n"lizzies_bds_sfx_sq027_panam");
		ev += 1;
		// ======================================================

		// ======================================================
		// Moaning VOs
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_moaning_open_long";
		arr.events[ev].wwiseId = 968031499u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_moaning_open_short";
		arr.events[ev].wwiseId = 3073408837u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_moaning_shut_long";
		arr.events[ev].wwiseId = 4283650505u;
		ev += 1;

		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_moaning_shut_short";
		arr.events[ev].wwiseId = 1757705951u;
		ev += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_female_01";
		arr.switch[sw].wwiseId = 468195407u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_female_01_robot";
		arr.switch[sw].wwiseId = 1425717678u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_female_02";
		arr.switch[sw].wwiseId = 468195404u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_female_02_robot";
		arr.switch[sw].wwiseId = 3830895289u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_male_01";
		arr.switch[sw].wwiseId = 3034419454u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_male_01_robot";
		arr.switch[sw].wwiseId = 3253851191u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_male_02";
		arr.switch[sw].wwiseId = 3034419453u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_male_02_robot";
		arr.switch[sw].wwiseId = 3569679536u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_female_jpn_01";
		arr.switch[sw].wwiseId = 876234044u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_off";
		arr.switch[sw].wwiseId = 2660528614u;
		sw += 1;

		arr.switch[sw].isLooping = false;
		arr.switch[sw].maxAttenuation = 0;
		arr.switch[sw].maxDuration = 0;
		arr.switch[sw].minDuration = 0;
		arr.switch[sw].redId = n"lizzies_bds_sw_moaning_female_stout_01";
		arr.switch[sw].wwiseId = 4231785497u;
		sw += 1;

		arr.switchGroup[sg].isLooping = false;
		arr.switchGroup[sg].maxAttenuation = 0;
		arr.switchGroup[sg].maxDuration = 0;
		arr.switchGroup[sg].minDuration = 0;
		arr.switchGroup[sg].redId = n"lizzies_bds_sg_moaning_type";
		arr.switchGroup[sg].wwiseId = 3787252791u;
		sg += 1;
		// ======================================================
		
		// ======================================================
		// Story Moaning VOs
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq30_judy_vo_01";
		arr.events[ev].wwiseId = 2456050214u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq30_judy_vo_02";
		arr.events[ev].wwiseId = 2456050213u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq30_judy_vo_03";
		arr.events[ev].wwiseId = 2456050212u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq30_judy_vo_04";
		arr.events[ev].wwiseId = 2456050211u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq30_judy_vo_05";
		arr.events[ev].wwiseId = 2456050210u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq30_v_vo_01";
		arr.events[ev].wwiseId = 3242382102u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_alt_vo_01";
		arr.events[ev].wwiseId = 1498126718u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_alt_vo_02";
		arr.events[ev].wwiseId = 1498126717u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_alt_vo_03";
		arr.events[ev].wwiseId = 1498126716u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_alt_vo_04";
		arr.events[ev].wwiseId = 1498126715u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_alt_vo_05";
		arr.events[ev].wwiseId = 1498126714u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_alt_vo_06";
		arr.events[ev].wwiseId = 1498126713u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_alt_vo_07";
		arr.events[ev].wwiseId = 1498126712u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_johnny_vo_01";
		arr.events[ev].wwiseId = 2721801021u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_johnny_vo_02";
		arr.events[ev].wwiseId = 2721801022u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_johnny_vo_03";
		arr.events[ev].wwiseId = 2721801023u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_johnny_vo_04";
		arr.events[ev].wwiseId = 2721801016u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_johnny_vo_05";
		arr.events[ev].wwiseId = 2721801017u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_johnny_vo_06";
		arr.events[ev].wwiseId = 2721801018u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_q108_johnny_vo_07";
		arr.events[ev].wwiseId = 2721801019u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq028_v_vo_01";
		arr.events[ev].wwiseId = 2717854493u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq028_v_vo_02";
		arr.events[ev].wwiseId = 2717854494u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq028_v_vo_03";
		arr.events[ev].wwiseId = 2717854495u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq028_v_vo_04";
		arr.events[ev].wwiseId = 2717854488u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_river_vo_01";
		arr.events[ev].wwiseId = 2518130692u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_river_vo_02";
		arr.events[ev].wwiseId = 2518130695u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_river_vo_03";
		arr.events[ev].wwiseId = 2518130694u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_river_vo_04";
		arr.events[ev].wwiseId = 2518130689u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_river_vo_05";
		arr.events[ev].wwiseId = 2518130688u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_river_vo_06";
		arr.events[ev].wwiseId = 2518130691u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_river_vo_07";
		arr.events[ev].wwiseId = 2518130690u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_v_vo_01";
		arr.events[ev].wwiseId = 2403814364u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_v_vo_02";
		arr.events[ev].wwiseId = 2403814367u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_v_vo_03";
		arr.events[ev].wwiseId = 2403814366u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq029_v_vo_04";
		arr.events[ev].wwiseId = 2403814361u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_johnny_lines_01";
		arr.events[ev].wwiseId = 3343189443u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_johnny_lines_02";
		arr.events[ev].wwiseId = 3343189440u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_johnny_lines_04";
		arr.events[ev].wwiseId = 3343189446u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_johnny_lines_05";
		arr.events[ev].wwiseId = 3343189447u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_johnny_lines_06";
		arr.events[ev].wwiseId = 3343189444u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_johnny_lines_07";
		arr.events[ev].wwiseId = 3343189445u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_johnny_lines_08";
		arr.events[ev].wwiseId = 3343189450u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_rogue_lines_01";
		arr.events[ev].wwiseId = 918631091u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_rogue_lines_02";
		arr.events[ev].wwiseId = 918631088u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_rogue_lines_03";
		arr.events[ev].wwiseId = 918631089u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_rogue_lines_04";
		arr.events[ev].wwiseId = 918631094u;
		ev += 1;
		
		arr.events[ev].isLooping = false;
		arr.events[ev].maxAttenuation = 0;
		arr.events[ev].maxDuration = 0;
		arr.events[ev].minDuration = 0;
		arr.events[ev].redId = n"lizzies_bds_sq031_rogue_lines_05";
		arr.events[ev].wwiseId = 918631095u;
		ev += 1;
		// ======================================================
	}
}
