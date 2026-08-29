module CopKiller

// CET Commands:
// Game.ReportPoliceKills()
// Game.ReportCopCarKills()
// Game.ReportMaxTacKills()
// Game.ReportCitizensAllied()
// Game.ReportCopCarsLooted()
// Game.ReportCopsDisrespected()

public class CopKillerSS extends ScriptableSystem {

	public persistent let nCopsKilled: Uint32 = 0u;
	public persistent let nMaxTacKilled: Uint32 = 0u;
	public persistent let nCopsExecuted: Uint32 = 0u;
	public persistent let nMaxTacExecuted: Uint32 = 0u;
	public persistent let nCopCarsDestroyed: Uint32 = 0u;
	public persistent let nCitizensAllied: Uint32 = 0u;
	public persistent let nCopCarsLooted: Uint32 = 0u;
	public persistent let nCopsDisrespected: Uint32 = 0u;
	public persistent let nHeatsEvaded: Uint32 = 0u;
	public persistent let nHighestHeatScore: Uint32 = 0u;
	public persistent let nPrevCivilianTributeDay: array<Uint32>;

	public persistent let bDisrespect: Bool = false;
	public persistent let bMelissaRoryKilled: Bool = false;

	public let nPrevCopsKilled: Uint32 = 0u;
	public let nPrevMaxTacKilled: Uint32 = 0u;
	public let nPrevCopCarsDestroyed: Uint32 = 0u;
	public let nPrevCitizensAllied: Uint32 = 0u;
	public let nPrevCopCarsLooted: Uint32 = 0u;
	public let nPrevCiviliansKilled: Uint32 = 0u;

	public let bShowKilled: Bool = false;
	public let bShowDestroyed: Bool = false;
	public let bShowLooted: Bool = false;

	public let spawnedHostilesList: array<wref<NPCPuppet>>;
	public let spawnedFriendlyList: array<wref<NPCPuppet>>;

	public const let className: CName = n"DisrespectOpportunity";
	public const let buttonContextName: CName = n"isDisrespectInputHintDisplayed";
	public let bDisrespectButtonHeld: Bool = false;
	
	public const let fDisrespectRetarget: Float = 1.5;
	public const let fDisrespectCooldown: Float = 5.0;
	public let disrespectTarget: ref<NPCPuppet>;
	public let bDisrespectRetargetDelayActive: Bool = false;
	public let bDisrespectCooldownActive: Bool = false;

	public let dynamicWorkspotHandler: ref<DynamicWorkspotHandler>;
	public let angryReactWorkspotID: EntityID;
	public let angryReactWorkspot: ref<GameObject>;
	public let disrespectWorkspotID: EntityID;
	public let disrespectWorkspot: ref<GameObject>;

	public let strIntroductions: String = "Introductions";
	public let strDisrespect: String = "Disrespect";

	public let bDisrespectBeganHeat: Bool = false;

	public let bWelcomed: Bool = false;

	public func OnAttach() -> Void {
		if ArraySize(this.nPrevCivilianTributeDay) == 0 {
			this.nPrevCivilianTributeDay = [ 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u ];
		};
	}

	public func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
		let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
		if ssx.bMS_Introductions {
			this.dynamicWorkspotHandler = new DynamicWorkspotHandler();
			this.dynamicWorkspotHandler.des = GameInstance.GetDynamicEntitySystem();
			this.dynamicWorkspotHandler.CreateWorkspot( [ n"Disrespect" ] );
			this.dynamicWorkspotHandler.CreateWorkspot( [ n"AngryReact" ] );
			this.strIntroductions = GetLocalizedText(LocKeyToString(n"CopKiller_InputHint_Introductions"));
			this.strDisrespect = GetLocalizedText(LocKeyToString(n"CopKiller_InputHint_Disrespect"));
		};
		this.ClearNPCLists();
		this.nPrevCopsKilled		= this.nCopsKilled;
		this.nPrevMaxTacKilled		= this.nMaxTacKilled;
		this.nPrevCopCarsDestroyed	= this.nCopCarsDestroyed;
		this.nPrevCitizensAllied	= this.nCitizensAllied;
		this.nPrevCopCarsLooted		= this.nCopCarsLooted;
		if ssx.bPariah && ssx.bMS_Pariah {
			this.nPrevCiviliansKilled = Pariah_GetCivilianKills_Reflected();
		};
		if ssx.bMS_WelcomeMessages && !this.bWelcomed {
			let strWelcomeSuffixes: array<String> = this.GetWelcomeSuffix();
			let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(GetGameInstance());
			if IsDefined(qs) && (qs.GetFact(n"dlc6_slept_with_river") == 1 || qs.GetFact(n"sq029_river_had_sex") == 1 || qs.GetFact(n"q115_river_romance_chosen") == 1 || qs.GetFact(n"sq029_river_lover") == 1) && RandRange(0, 100) < 5 {
				strWelcomeSuffixes = [
					GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffixSecret_1")),
					GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffixSecret_2"))
				];
			};
			FTLog(GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomePrefix")) + " " + strWelcomeSuffixes[RandRange(0, ArraySize(strWelcomeSuffixes))]);
			this.bWelcomed = true;
		};
	}

	// ...
	
	public func GetCommonSuffix() -> array<String> = [
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_1")), // Authoritarians Annihilated
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_2")), // Badges Brutalized
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_3")), // Cops Killed
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_4")), // Five-O Flatlined
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_5")), // Hogs Harmed
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_6")), // Jackboots Judged
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_7")), // Lawmen Liquidated
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_8")), // Oppressors Obliterated
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_9")), // Pigs Perished
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CommonSuffix_10")) // Swine Silenced
	]

	public func GetRareSuffix() -> array<String> = [
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_1")),  // 12 86'd
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_2")),  // 12 187'd
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_3")),  // 12 Zeroed
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_4")),  // Authoritarians Aerated
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_5")),  // Badges Buried
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_6")),  // Badges Burned
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_7")),  // Bastards Butchered
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_8")),  // Blue Bloods Beat Down
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_9")),  // Blue Bloods Bled
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_10")), // Blue Bloods Bludgeoned
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_11")), // Clowns Cut Down
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_12")), // Fuzz Failed
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_13")), // Fuzz Felled
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_14")), // Fuzz Finished
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_15")), // Hogs Hit
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_16")), // Lawmen Laid Out
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_17")), // Lawmen Lit Up
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_18")), // NARCs Nulled
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_19")), // Oinkers Omitted
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_20")), // Oppressors Off'd
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_21")), // Pigs Peppered
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_22")), // Road Pirates Purged
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_23")), // Slavecatchers Slaughtered
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_24")), // Stormtroopers Slain
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_25")), // Stormtroopers Snuffed
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_26")), // Stormtroopers Stomped
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_27"))  // Wilburs Wasted // Charlotte's Web, LOL
	//	GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_RareSuffix_28"))  // Blue Lives Didn't Matter // Nexus Content Guidelines :(
	]

	public func GetMaxTacSuffix() -> array<String> = [
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_MaxTacSuffix_1")), // MaxTac Massacred
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_MaxTacSuffix_2")), // MaxTac Merc'd
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_MaxTacSuffix_3")), // MaxTac Murdered
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_MaxTacSuffix_4")), // MaxTac Murked
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_MaxTacSuffix_5"))  // MaxTac Mutilated
	]

	public func GetCopCarSuffix() -> array<String> = [
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_1")), // Clown Cars Crumbled
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_2")), // Clown Cars Crumpled
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_3")), // Cruisers Corrected
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_4")), // Cruisers Crushed
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_5")), // Sirens Silenced
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_6")), // Sirens Stifled
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_7")), // Sirens Suppressed
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_8")), // Squad Cars Shattered
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_9")), // Squad Cars Smashed
		GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarSuffix_10")) // Police Vehicles Vandalized
	]

	public func GetWelcomeSuffix() -> array<String> = [							 // Welcome to Cop Killer, the mod that ...
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_1")),  // ... believes in abolishing tyrants with heavy weaponry and extreme prejudice.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_2")),  // ... supposes the only place dominance is appropriate is in the bedroom.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_3")),  // ... assumes there are no dogs in Night City because police finally shot them all.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_4")),  // ... suggests police to do something more useful for society, like bagging groceries.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_5")),  // ... reveals the genuine application of the Second Amendment.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_6")),  // ... encourages you to find out if blue bloods spill their namesake.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_7")),  // ... requests massive cowards simply get different jobs.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_8")),  // ... will probably someday be featured in a news segment watched primarily by the elderly.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_9")),  // ... solves bullying with bullets.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_10")), // ... extrapolates 'do unto others'.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_11")), // ... reminds you to never do this sort of stuff at home. (But what if you did though, hahaha, imagine.)
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_12")), // ... loves thy badgeless neighbor.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_13")), // ... realizes all apples swiftly rot.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_14")), // ... knows 'one of the good ones', who has a pink slip.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_15")), // ... counts fucking police spouses as a legitimate hobby.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_16")), // ... gives zero fucks if "your uncle's a cop".
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_17")), // ... thinks "I was sooo scawwed tho" shouldn't be a valid legal defense.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_18")), // ... does pirouettes across the thin blue line.
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_19")), // ... refers to police friendly-fire incidents as "happy coincidences".
		GetLocalizedText(LocKeyToString(n"CopKiller_Logging_WelcomeSuffix_20"))  // ... cuts to the (police) chase.
	]

	public func ViableListNpc(npc: ref<NPCPuppet>) -> Bool {
		return IsDefined(npc) && ScriptedPuppet.IsActive(npc) && IsDefined(npc.GetPS()) && !npc.GetPS().GetIsDead();
	}

	public func UnlistNonviableNPCs() -> Void {
		let npc: ref<NPCPuppet>;
		let i: Int32 = 0;
		let a: Int32 = ArraySize(this.spawnedHostilesList);
		while i < a {
			npc = this.spawnedHostilesList[i];
			if !this.ViableListNpc(npc) {
				ArrayRemove(this.spawnedHostilesList, npc);
				a = ArraySize(this.spawnedHostilesList);
			} else {
				i += 1;
			};
		};
		i = 0;
		a = ArraySize(this.spawnedFriendlyList);
		while i < a {
			npc = this.spawnedFriendlyList[i];
			if !this.ViableListNpc(npc) {
				ArrayRemove(this.spawnedFriendlyList, npc);
				a = ArraySize(this.spawnedFriendlyList);
			} else {
				i += 1;
			};
		};
	}

	public func UnlistNPC(npc: ref<NPCPuppet>) -> Void {
		if ArrayContains(this.spawnedHostilesList, npc) {
			ArrayRemove(this.spawnedHostilesList, npc);
		} else if ArrayContains(this.spawnedFriendlyList, npc) {
			ArrayRemove(this.spawnedFriendlyList, npc);
		};
	}

	public func ClearNPCLists() -> Void {
		ArrayClear(this.spawnedHostilesList);
		ArrayClear(this.spawnedFriendlyList);
	}

	public static func GetSS() -> ref<CopKillerSS> {
		return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"CopKiller.CopKillerSS") as CopKillerSS;
	}

}

@wrapMethod(StatusEffectHelper)
public final static func ApplyStatusEffect(target: wref<GameObject>, statusEffectID: TweakDBID, opt delay: Float) -> Bool {
	let bWasDefeated = Equals(statusEffectID, t"BaseStatusEffect.Defeated");
	let bResult: Bool = wrappedMethod(target, statusEffectID, delay);
	if bWasDefeated && CopKillerSSX.GetSSX().bMS_LethalIntent {
		let npc: wref<NPCPuppet> = target as NPCPuppet;
		if IsTargetPolice(npc) {
			npc.Kill(GetPlayer(GetGameInstance()));
		};
	};
	return bResult;
}

@wrapMethod(NPCPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
	let bResult: Bool = wrappedMethod(evt);
	if CopKillerSSX.GetSSX().bMS_LethalIntent {
		if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.Defeated) {
			let player: ref<PlayerPuppet> = GetPlayer(this.GetGame());
			if IsTargetPolice(this) && Equals(evt.instigatorEntityID, player.GetEntityID()) {
				switch (this.m_hitHistory.GetLastDamageType(player)) {
					case gamedataAttackType.ChargedWhipAttack:
					case gamedataAttackType.Explosion:
					case gamedataAttackType.Hack:
					case gamedataAttackType.Melee:
					case gamedataAttackType.PressureWave:
					case gamedataAttackType.QuickMelee:
					case gamedataAttackType.Ranged:
					case gamedataAttackType.Reflect:
					case gamedataAttackType.StrongMelee:
					case gamedataAttackType.Thrown:
					case gamedataAttackType.WhipAttack:
						this.Kill(player);
						break;
				};
			};
		};
	};
	return bResult;
}

@wrapMethod(ScriptedPuppet)
protected func OnDied() -> Void {
	let npc: wref<NPCPuppet> = this as NPCPuppet;
	let npcPS: ref<ScriptedPuppetPS> = npc.GetPS();
	if !IsDefined(npc) || !IsDefined(npcPS) || !IsDefined(npc.m_myKiller) {
		wrappedMethod();
		return;
	};
	let bWasDefeated: Bool = !npc.m_shouldBeDefeated && npcPS.GetWasIncapacitated() && ScriptedPuppet.IsAlive(npc);
	wrappedMethod();
	let bWasKilled: Bool = npcPS.GetIsDead();
	let bWasExecuted: Bool = bWasDefeated && bWasKilled;
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	let game: GameInstance = GetGameInstance();
	let player: ref<PlayerPuppet> = GetPlayer(game);
	let bKillerIsPlayer: Bool = npc.m_myKiller.IsPlayer() || npc.m_myKiller.IsPlayerControlled() || npc.m_myKiller.IsReplacer();
	let bKillerIsAllied: Bool = npc.m_myKiller.IsNPC() && isAlliedWithPlayer(npc.m_myKiller as NPCPuppet, player);
	if bWasKilled && IsTargetPolice(npc) && (bKillerIsPlayer || bKillerIsAllied) {
		let bMaxTac: Bool = Equals(npc.GetNPCRarity(), gamedataNPCRarity.MaxTac);
		if !ss.bShowKilled {
			ss.nPrevCopsKilled = ss.nCopsKilled;
			ss.nPrevMaxTacKilled = ss.nMaxTacKilled;
		};
		ss.nCopsKilled += 1u;
		if ss.nCopsKilled <= 250u && ss.nCopsKilled % 50u == 0u {
			player.CopKiller_SetSevereProblemWithAuthorityDamageLevel();
		};
		if bWasExecuted {
			ss.nCopsExecuted += 1u;
		};
		if bMaxTac {
			ss.nMaxTacKilled += 1u;
			if bWasExecuted {
				ss.nMaxTacExecuted += 1u;
			};
			if Equals(npc.GetRecordID(), t"Character.mq030_melisa") {
				ss.bMelissaRoryKilled = true;
			};
		};
		ss.bShowKilled = true;
		let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
		let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);
		if ssx.bMS_ActivityLogReports && IsDefined(ds) {
			if !bMaxTac {
				let callback: ref<CopsKilledMessageCallback> = new CopsKilledMessageCallback();
				callback.bActivityLog = true;
				ds.DelayCallback(callback, 0.0);
			} else {
				let callback: ref<MaxTacKilledMessageCallback> = new MaxTacKilledMessageCallback();
				callback.bActivityLog = true;
				ds.DelayCallback(callback, 0.0);
			};
		};
		if ssx.bAtone && ssx.bMS_Atone && ssx.bMS_StreetCredForCopsKilled {
			let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(game);
			if IsDefined(stats) {
				let statsID: StatsObjectID = Cast<StatsObjectID>(npc.GetEntityID());
				let fEnemyLV: Float = stats.GetStatValue(statsID, gamedataStatType.Level);
				let fEnemyPL: Float = stats.GetStatValue(statsID, gamedataStatType.PowerLevel);
				let fStreetCredExpReward: Float = ClampF(MaxF(fEnemyLV, fEnemyPL), 0.0, 1000.0);
				let cID: TweakDBID = npc.GetRecordID();
				let tssx: ref<CopKillerTweaksSSX> = CopKillerTweaksSSX.GetSSX();
				let tElite_Enforcers_Ranged: array<TweakDBID> = tssx.CharList_Enforcers_Ranged();
				let tElite_Enforcers_Cyberware: array<TweakDBID> = tssx.CharList_Enforcers_Cyberware();
				let tElite_Netwatch: array<TweakDBID> = tssx.CharList_Netwatch();
				let bElite: Bool = !bMaxTac && 
					(ArrayContains(tElite_Enforcers_Ranged, cID) || ArrayContains(tElite_Enforcers_Cyberware, cID) || ArrayContains(tElite_Netwatch, cID));
				if bMaxTac {
					fStreetCredExpReward *= 3.0;
				} else if bElite {
					fStreetCredExpReward *= 1.5;
				} else {
					fStreetCredExpReward /= 1.5;
				};
				if fStreetCredExpReward >= 1.0 {
					Atone_GiveStreetCredExpReward_Reflected(Cast<Int32>(fStreetCredExpReward));
				};
			};
		};
	};
}

@wrapMethod(ScriptedPuppet)
public final const func AwardsExperience() -> Bool {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if ssx.bMS_ExperienceForCopsKilled {
		return this.IsPrevention() || (ssx.bMS_NoExperienceForGangoons && !IsTargetGangAffiliated(this as NPCPuppet));
	};
	return wrappedMethod();
}

@wrapMethod(VehicleComponent)
private final func ExplodeVehicle(instigator: wref<GameObject>) -> Void {
	let game: GameInstance = GetGameInstance();
	let vcps: ref<VehicleComponentPS> = this.GetPS();
	let veh: wref<VehicleObject> = this.GetVehicle();
	let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
	if !IsDefined(vcps) || !IsDefined(ps) || !IsDefined(veh) {
		wrappedMethod(instigator);
		return;
	};
	let bNotPrevDestroyed: Bool = !vcps.GetHasExploded();
	wrappedMethod(instigator);
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if bNotPrevDestroyed && vcps.GetHasExploded() && instigator.IsPlayer() {
		let nHeatStage: Int32 = EnumInt(ps.GetHeatStage());
		if !IsTargetPolice(veh) {
			let ppDistrictTDBID: TweakDBID = ps.m_preventionPreset.GetRecordID();
			if TDBID.IsValid(ppDistrictTDBID) {
				let district: wref<District> = ps.GetCurrentDistrict();
				if IsDefined(district) && IsDefined(district.m_districtRecord) {
					if IsSubDistrictRich(district.m_districtRecord.Type()) && nHeatStage < 1 && !StatusEffectSystem.ObjectHasStatusEffectWithTag(instigator, n"Cloak") {
						ps.ChangeHeatStage(EPreventionHeatStage.Heat_1, "EnterCombat");
					};
				};
			};
			return;
		} else if nHeatStage < 2 && !StatusEffectSystem.ObjectHasStatusEffectWithTag(instigator, n"Cloak") {
			ps.ChangeHeatStage(EPreventionHeatStage.Heat_2, "EnterCombat");
		};
		
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		if !ss.bShowDestroyed {
			ss.nPrevCopCarsDestroyed = ss.nCopCarsDestroyed;
		};
		ss.nCopCarsDestroyed += 1u;
		ss.bShowDestroyed = true;
		let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);
		if ssx.bMS_ActivityLogReports && IsDefined(ds) {
			let callback: ref<CopCarsDestroyedMessageCallback> = new CopCarsDestroyedMessageCallback();
			callback.bActivityLog = true;
			ds.DelayCallback(callback, 0.0);
		};
		let dd: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(instigator);
		let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(game);
		if ssx.bMS_AnarchistVanguard && IsDefined(dd) && IsDefined(stats) {
			let npcStats: StatsObjectID;
			ss.UnlistNonviableNPCs();
			for npc in ss.spawnedFriendlyList {
				npcStats = Cast<StatsObjectID>(npc.GetEntityID());
				stats.AddModifier(npcStats, RPGManager.CreateStatModifier(gamedataStatType.Health,		gameStatModifierType.Additive, 10.0));
				stats.AddModifier(npcStats, RPGManager.CreateStatModifier(gamedataStatType.Armor,		gameStatModifierType.Additive, 10.0));
				stats.AddModifier(npcStats, RPGManager.CreateStatModifier(gamedataStatType.NPCDamage,	gameStatModifierType.Additive, 10.0));
				stats.AddModifier(npcStats, RPGManager.CreateStatModifier(gamedataStatType.Accuracy,	gameStatModifierType.Additive, 10.0));
			};
			ss.nPrevCitizensAllied = ss.nCitizensAllied;
			for npc in ss.spawnedHostilesList {
				if Vector4.Distance(npc.GetWorldPosition(), instigator.GetWorldPosition()) < 100.0 {
					let nStreetCred: Int32 = (!ssx.bAtone || !ssx.bMS_Atone)
						? dd.GetProficiencyLevel(gamedataProficiencyType.StreetCred) 
						: dd.GetProficiencyLevel(gamedataProficiencyType.StreetCred) + Cast<Int32>(Atone_GetStreetCredLevelsReset_Reflected());
					let bAlly: Bool = (!ssx.bTWR || !ssx.bMS_TWR)
						? RandRange(0, 100) < nStreetCred * 2
						: RandRange(0, 100) < (nStreetCred * 2) + TWR_CheckFactionCred_Reflected(npc);
					if bAlly {
						let aaJoiner: ref<AttitudeAgent> = npc.GetAttitudeAgent();
						let aaPlayer: ref<AttitudeAgent> = instigator.GetAttitudeAgent();
						if IsDefined(aaJoiner) && IsDefined(aaPlayer) {
							aaJoiner.SetAttitudeGroupUnsavable(aaPlayer.GetAttitudeGroup());
							ArrayRemove(ss.spawnedHostilesList, npc);
							ArrayPush(ss.spawnedFriendlyList, npc);
							ss.nCitizensAllied += 1u;
							let cmd: ref<AIFollowTargetCommand> = new AIFollowTargetCommand();
							cmd.removeAfterCombat				= true;
							cmd.ignoreInCombat					= false;
							cmd.alwaysUseStealth				= false;
							cmd.movementType					= moveMovementType.Sprint;
							cmd.stopWhenDestinationReached		= true;
							cmd.desiredDistance					= 10.0;
							cmd.tolerance						= 2.5;
							cmd.teleport						= false;
							cmd.target							= instigator;
							AIComponent.SendCommand(npc, cmd);
							let cmd: ref<AIMoveToCommand> = new AIMoveToCommand();
							cmd.removeAfterCombat				= true;
							cmd.ignoreInCombat					= false;
							cmd.alwaysUseStealth				= false;
							cmd.movementType					= moveMovementType.Sprint;
							cmd.finishWhenDestinationReached	= true;
							cmd.desiredDistanceFromTarget		= 10.0;
							cmd.ignoreNavigation				= true;
							cmd.useStart						= false;
							cmd.useStop							= false;
							AIPositionSpec.SetEntity(cmd.movementTarget, instigator);
							AIComponent.SendCommand(npc, cmd);
							npcStats = Cast<StatsObjectID>(npc.GetEntityID());
							let fAllyBonus: Float = (!ssx.bTWR || !ssx.bMS_TWR) ? 25.0 : 50.0;
							stats.AddModifier(npcStats, RPGManager.CreateStatModifier(gamedataStatType.Health,		gameStatModifierType.Additive, fAllyBonus));
							stats.AddModifier(npcStats, RPGManager.CreateStatModifier(gamedataStatType.Armor,		gameStatModifierType.Additive, fAllyBonus));
							stats.AddModifier(npcStats, RPGManager.CreateStatModifier(gamedataStatType.NPCDamage,	gameStatModifierType.Additive, fAllyBonus));
							stats.AddModifier(npcStats, RPGManager.CreateStatModifier(gamedataStatType.Accuracy,	gameStatModifierType.Additive, fAllyBonus));
							RPGManager.ApplyAbility(npc, TweakDBInterface.GetGameplayAbilityRecord(t"CanRegenInCombat"));
							RPGManager.ApplyAbility(npc, TweakDBInterface.GetGameplayAbilityRecord(t"HasFireproofSkin")); // CDPR pathing + burning cars
						};
					};
				};
			};
			if ssx.bMS_ActivityLogReports && IsDefined(ds) && ss.nPrevCitizensAllied < ss.nCitizensAllied {
				ds.DelayCallback(new CitizensAlliedMessageCallback(), 0.0);
			};
		};
	};
}

public func setAllyAttitudes(cop: ref<NPCPuppet>) -> Void {
	let aaCops: ref<AttitudeAgent> = cop.GetAttitudeAgent();
	let aaAlly: ref<AttitudeAgent>;
	let aaPrev: ref<AttitudeAgent>;
	for ally in CopKillerSS.GetSS().spawnedFriendlyList {
		aaAlly = ally.GetAttitudeAgent();
		if !Equals(aaAlly.GetAttitudeTowards(aaCops), EAIAttitude.AIA_Hostile) {
			aaAlly.SetAttitudeTowards(aaCops, EAIAttitude.AIA_Hostile);
			aaAlly.SetAttitudeTowardsAgentGroup(aaCops, aaAlly, EAIAttitude.AIA_Hostile);
		};
		if IsDefined(aaPrev) && !Equals(aaAlly.GetAttitudeTowards(aaPrev), EAIAttitude.AIA_Friendly) {
			aaAlly.SetAttitudeTowards(aaPrev, EAIAttitude.AIA_Friendly);
			aaAlly.SetAttitudeTowardsAgentGroup(aaPrev, aaAlly, EAIAttitude.AIA_Friendly);
		};
		aaPrev = ally.GetAttitudeAgent();
	};
}

@wrapMethod(PlayerPuppet)
protected cb func OnBeingTarget(evt: ref<OnBeingTarget>) -> Bool {
	let npc: ref<NPCPuppet> = evt.objectThatTargets as NPCPuppet;
	if IsDefined(npc) && npc.IsPrevention() {
		setAllyAttitudes(npc);
	};
	return wrappedMethod(evt);
}

@wrapMethod(DamageSystem)
private func ProcessLocalizedDamage(hitEvent: ref<gameHitEvent>) -> Void {
	if IsDefined(hitEvent) && CopKillerSSX.GetSSX().bMS_AnarchistVanguard {
		let attackData: ref<AttackData> = hitEvent.attackData;
		if IsDefined(attackData) {
			let target: wref<NPCPuppet> = hitEvent.target as NPCPuppet;
			let instigator: wref<NPCPuppet> = attackData.instigator as NPCPuppet;
			if IsDefined(instigator) && IsDefined(target) && IsTargetPolice(target) {
				if ArrayContains(CopKillerSS.GetSS().spawnedFriendlyList, instigator) {
					if IsDefined(target.m_visionComponent) {
						for rr in target.m_visionComponent.m_activeRevealRequests {
							switch (rr.reason) {
								case n"PingQuickhack":	attackData.additionalCritChance += 5.0; break;
								case n"tag":			attackData.additionalCritChance += 5.0; break;
							};
						};
					} else if StatusEffectSystem.ObjectHasStatusEffectWithTag(target, n"Ping") {
						attackData.additionalCritChance += 5.0;
					};
				} else if instigator.IsPlayer() {
					setAllyAttitudes(target);
				};
			};
		};
	};
	wrappedMethod(hitEvent);
}

@wrapMethod(NPCPuppet)
protected cb func OnPostInitialize(evt: ref<entPostInitializeEvent>) -> Bool {
	let bResult: Bool = wrappedMethod(evt);
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if ssx.bMS_AnarchistVanguard {
		if ss.ViableListNpc(this) && CanTargetAlly(this) && !this.IsQuest() && !this.IsVendor() && !this.IsCharacterChildren() && !this.IsBoss() {
			ArrayPush(ss.spawnedHostilesList, this);
		};
	};
	if ssx.bMelissaRoryChanceInit {
		let charRecord: ref<Character_Record> = this.GetRecord();
		let charTDBID: TweakDBID = IsDefined(charRecord) ? charRecord.GetID() : t"";
		if Equals(charTDBID, t"Character.mq030_melisa") && !Equals(GetCurrentDistrict(), gamedataDistrict.Downtown_Jinguji) {
			let game: GameInstance = GetGameInstance();
			let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
			if IsDefined(ps) && EnumInt(ps.GetHeatStage()) > 0 {
				let player: ref<PlayerPuppet> = GetPlayer(game);
				if IsDefined(player) {
					GameObject.ChangeAttitudeToHostile(this, player);
					AIActionHelper.TryStartCombatWithTarget(this, player);
				};
			};
		};
	};
	return bResult;
}

@wrapMethod(NPCPuppet)
protected cb func OnPreUninitialize(evt: ref<entPreUninitializeEvent>) -> Bool {
	CopKillerSS.GetSS().UnlistNPC(this);
	return wrappedMethod(evt);
}

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
	CopKillerSS.GetSS().UnlistNPC(this);
	return wrappedMethod(evt);
}

@wrapMethod(FastTravelComponent)
protected cb func OnFastTravelAction(evt: ref<FastTravelDeviceAction>) -> Bool {
	CopKillerSS.GetSS().ClearNPCLists();
	return wrappedMethod(evt);
}

@wrapMethod(PreventionSystem)
private final func ChangeHeatStage(newHeatStage: EPreventionHeatStage, heatChangeReason: String) -> Void {

	let nPrevHeatStage: Int32 = EnumInt(this.m_heatStage);
	wrappedMethod(newHeatStage, heatChangeReason);
	let game: GameInstance = this.GetGame();
	let player: ref<PlayerPuppet> = GetPlayer(game);
	if !IsDefined(player) { return; };
	if nPrevHeatStage == 0 { player.CopKiller_SetSevereProblemWithAuthorityDamageLevel(); return; };
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bMS_Enabled || EnumInt(this.m_heatStage) != 0 { return; };
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();

	ss.nHeatsEvaded += 1u;

	let nCopKillsDuringHeat: Uint32			= ss.nCopsKilled - ss.nPrevCopsKilled;
	let nCopCarsLootedDuringHeat: Uint32	= ss.nCopCarsLooted - ss.nPrevCopCarsLooted;
	let nCopCarsDestroyedDuringHeat: Uint32	= ss.nCopCarsDestroyed - ss.nPrevCopCarsDestroyed;
	let nMaxTacKillsDuringHeat: Uint32		= ss.nMaxTacKilled - ss.nPrevMaxTacKilled;
	let nCivilianKillsDuringHeat: Uint32	= Pariah_GetCivilianKills_Reflected() - ss.nPrevCiviliansKilled;
	let nDisrespectBonus: Uint32			= ss.bDisrespectBeganHeat ? 1u : 0u;

	// Heat Scoring

	let nHeatMayhemScore: Uint32 = Cast<Uint32>(nPrevHeatStage) * (
		nDisrespectBonus + 						// 1 pt.   / Police Disrespected
		nCopCarsLootedDuringHeat +				// 1 pt.   / Police Vehicle Looted
		(nCopKillsDuringHeat * 2u) + 			// 2 pt.   / Police Kill
		(nCopCarsDestroyedDuringHeat * 3u) + 	// 3 pts.  / Police Vehicle Destroyed
		(nMaxTacKillsDuringHeat * 15u)			// 15 pts. / MaxTac kill
	);
	if nHeatMayhemScore > ss.nHighestHeatScore { ss.nHighestHeatScore = nHeatMayhemScore; };

	// Anarchist Vanguard Clean-Up

	if ArraySize(ss.spawnedFriendlyList) > 0 {
		let ai: ref<AIHumanComponent>;
		for npc in ss.spawnedFriendlyList {
			ai = npc.GetAIControllerComponent();
			if IsDefined(ai) {
				AIActiveCommandList.Remove(ai.m_activeCommands, n"AIFollowTargetCommand");
				AIActiveCommandList.Remove(ai.m_activeCommands, n"AIMoveToCommand");
			};
		};
		ss.UnlistNonviableNPCs();
	};

	// Post-Heat Stat Reporting

	if ss.bShowKilled && ssx.bMS_ReportsAfterEvasion {
		let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);
		if IsDefined(ds) {
			let fCallbackDelay: Float = 0.0;
			if nCopKillsDuringHeat > 0u {
				ds.DelayCallback(new CopsKilledMessageCallback(), fCallbackDelay);
				fCallbackDelay += 4.0;
			};
			if ssx.bMS_ReportCopCarKills && ss.bShowDestroyed && nCopCarsDestroyedDuringHeat > 0u {
				ds.DelayCallback(new CopCarsDestroyedMessageCallback(), fCallbackDelay);
				fCallbackDelay += 4.0;
			};
			if ssx.bMS_ReportMaxTacKills && nMaxTacKillsDuringHeat > 0u {
				ds.DelayCallback(new MaxTacKilledMessageCallback(), fCallbackDelay);
				fCallbackDelay += 4.0;
			};
			if ssx.bPariah && ssx.bMS_Pariah && nCivilianKillsDuringHeat > 0u {
				CiviliansKilledMessageCallback.Exec(nCivilianKillsDuringHeat, ds, fCallbackDelay);
			};
		};
		ss.bShowKilled		= false;
		ss.bShowDestroyed	= false;
		ss.bShowLooted		= false;
	};

	// Pariah Zero Collateral Damage Tribute

	let district: wref<District> = this.GetCurrentDistrict();
	let districtType: gamedataDistrict = IsDefined(district) && IsDefined(district.m_districtRecord) ? district.m_districtRecord.Type() : gamedataDistrict.Invalid;
	let nCurrentDay: Uint32 = Cast<Uint32>(GameTime.Days(GameInstance.GetGameTime(game)));
	let bNewDistrictOrDay: Bool = false;

	switch (districtType) {
		case gamedataDistrict.Arroyo:			bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[0];  ss.nPrevCivilianTributeDay[0]  = nCurrentDay; break;
		case gamedataDistrict.Badlands:																			  ss.nPrevCivilianTributeDay[1]  = nCurrentDay; break;
		case gamedataDistrict.CharterHill:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[2];  ss.nPrevCivilianTributeDay[2]  = nCurrentDay; break;
		case gamedataDistrict.Coastview:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[3];  ss.nPrevCivilianTributeDay[3]  = nCurrentDay; break;
		case gamedataDistrict.CorpoPlaza:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[4];  ss.nPrevCivilianTributeDay[4]  = nCurrentDay; break;
		case gamedataDistrict.Dogtown:			bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[5] && ssx.bMS_AllBarghestAreCops;
																												  ss.nPrevCivilianTributeDay[5]  = nCurrentDay; break;
		case gamedataDistrict.Downtown:			bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[6];  ss.nPrevCivilianTributeDay[6]  = nCurrentDay; break;
		case gamedataDistrict.Glen:				bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[7];  ss.nPrevCivilianTributeDay[7]  = nCurrentDay; break;
		case gamedataDistrict.JapanTown:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[8];  ss.nPrevCivilianTributeDay[8]  = nCurrentDay; break;
		case gamedataDistrict.Kabuki:			bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[9];  ss.nPrevCivilianTributeDay[9]  = nCurrentDay; break;
		case gamedataDistrict.LittleChina:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[10]; ss.nPrevCivilianTributeDay[10] = nCurrentDay; break;
		case gamedataDistrict.NorthOaks:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[11]; ss.nPrevCivilianTributeDay[11] = nCurrentDay; break;
		case gamedataDistrict.Northside:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[12]; ss.nPrevCivilianTributeDay[12] = nCurrentDay; break;
		case gamedataDistrict.RanchoCoronado:	bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[13]; ss.nPrevCivilianTributeDay[13] = nCurrentDay; break;
		case gamedataDistrict.VistaDelRey:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[14]; ss.nPrevCivilianTributeDay[14] = nCurrentDay; break;
		case gamedataDistrict.Wellsprings:		bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[15]; ss.nPrevCivilianTributeDay[15] = nCurrentDay; break;
		case gamedataDistrict.WestWindEstate:	bNewDistrictOrDay = nCurrentDay > ss.nPrevCivilianTributeDay[16]; ss.nPrevCivilianTributeDay[16] = nCurrentDay; break;
		default:
			ss.bDisrespectBeganHeat = false;
			ss.nPrevCiviliansKilled += nCivilianKillsDuringHeat;
			return;
	};
	
	if ssx.bPariah && ssx.bMS_Pariah && bNewDistrictOrDay && nCivilianKillsDuringHeat == 0u {
		let al: ref<ActivityLogSystem> = GameInstance.GetActivityLogSystem(game);
		let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
		if IsDefined(ts) && IsDefined(al) {
			if ssx.bAtone && ssx.bMS_Atone && nHeatMayhemScore >= 4u {
				Atone_GiveStreetCredExpReward_Reflected(Cast<Int32>(nHeatMayhemScore / 4u));
			};
			al.AddLog(GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CiviliansTribute")));
			if nHeatMayhemScore >= 100u { // Prolonged Carnage
				let itemListTIDs: array<TweakDBID> = ArrayShuffle(CopKillerTweaksSSX.GetSSX().ItemList_CivQualityItemDonations());
				let r: Int32 = RandRange(0, ArraySize(itemListTIDs));
				let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(itemListTIDs[r]);
				while (!TDBID.IsValid(itemListTIDs[r]) || !IsDefined(itemRecord)) { // No DLC = Roll a vanilla item
					r = RandRange(0, ArraySize(itemListTIDs));
					itemRecord = TweakDBInterface.GetItemRecord(itemListTIDs[r]);
				};
				ts.GiveItemByTDBID(player, itemListTIDs[r], 1);
				GameObject.PlaySoundEvent(player, n"ui_loot_generic");
			} else if nHeatMayhemScore >= 50u { // Extended Engagement
				let nDonors: Int32 = RandRange(3, 6);
				let nEddies: Int32 = 0;
				let i: Int32 = 0;
				while (i < nDonors) {
					nEddies += RandRange(1, 11);
					i += 1;
				};
				ts.GiveItemByTDBID(player, t"Items.money", nEddies); // 1-10 Eddies / 3-5 Donors = 3-50 Eddies
				al.AddLog(nDonors + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CiviliansTribute_Money_Suffix")));
				GameObject.PlaySoundEvent(player, n"ui_loot_money");
			} else { // Short Skirmish
				if ssx.bAtone && ssx.bMS_Atone && TDBID.IsValid(t"Items.Atone_ConfessionCoin") && RandRange(0, 100) < 5 {
					ts.GiveItemByTDBID(player, t"Items.Atone_ConfessionCoin", 1);
					GameObject.PlaySoundEvent(player, n"ui_loot_generic");
				} else {
					let tssx: ref<CopKillerTweaksSSX> = CopKillerTweaksSSX.GetSSX();
					let itemListTIDs: array<TweakDBID> = ArrayShuffle(tssx.ItemList_CivMealDonations());
					ts.GiveItemByTDBID(player, itemListTIDs[RandRange(0, ArraySize(itemListTIDs))], 1);
					itemListTIDs = ArrayShuffle(tssx.ItemList_CivDrinkDonations());
					ts.GiveItemByTDBID(player, itemListTIDs[RandRange(0, ArraySize(itemListTIDs))], 1);
					GameObject.PlaySoundEvent(player, n"ui_loot_take_all");
				};
			};
		};
	};
	
	if ssx.bHeatDebugLogging {
		FTLog(" ");
		FTLog(
			"Day " + ToString(nCurrentDay) + ", " + StrReplace(ToString(districtType), "gamedataDistrict.", "") + ":\n" +
				"\t" + "Heat Score: " + ToString(nHeatMayhemScore) + "\n" + 
				"\t" + "High Score: " + ToString(ss.nHighestHeatScore) + "\n" + 
					"\t\t" + ToString(ss.nHeatsEvaded) + " Heats Evaded (Total)\n" + 
					"\t\t" + ToString(nDisrespectBonus) + " Cops Disrespected\n" + 
					"\t\t" + ToString(nCopKillsDuringHeat) + " Cops Killed\n" + 
					"\t\t" + ToString(nCopCarsLootedDuringHeat) + " Cop Cars Looted\n" + 
					"\t\t" + ToString(nCopCarsDestroyedDuringHeat) + " Cop Cars Destroyed\n" + 
					"\t\t" + ToString(nMaxTacKillsDuringHeat) + " MaxTac Killed\n" + 
					"\t\t" + ToString(nCivilianKillsDuringHeat) + " Civilians Killed"
		);
		FTLog(" ");
	};

	ss.bDisrespectBeganHeat = false;
	ss.nPrevCiviliansKilled += nCivilianKillsDuringHeat;
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnSenseVisibilityEvent(evt: ref<SenseVisibilityEvent>) -> Bool {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if ssx.bPayToGo && ssx.bMS_PayToGo && evt.isVisible {
		if ssx.bTWR && ssx.bMS_TWR && !TWR_IsPlayerID_Reflected() {
			return wrappedMethod(evt);
		};
		let npc: ref<ScriptedPuppet> = this.GetOwnerPuppet();
		if evt.target.IsPlayer() && IsDefined(npc) && IsTargetPolice(npc) && Vector4.Distance(evt.target.GetWorldPosition(), npc.GetWorldPosition()) <= 5.0 {
			let dd: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(evt.target);
			if IsDefined(dd) {
				let nStreetCred: Int32 = Min(99, (!ssx.bAtone || !ssx.bMS_Atone)
					? dd.GetProficiencyLevel(gamedataProficiencyType.StreetCred) 
					: dd.GetProficiencyLevel(gamedataProficiencyType.StreetCred) + Cast<Int32>(Atone_GetStreetCredLevelsReset_Reflected()));
				if PayToGo_GetTravelDebt_Reflected() >= Cast<Uint32>(1000 + (((nStreetCred - (nStreetCred % 10)) / 10) * 1000)) { // +1k every 10 levels, 10k max
					return AIActionHelper.TryStartCombatWithTarget(npc, evt.target);
				};
			};
		};
	};
	if ssx.bMS_CodeThirty && evt.isVisible && evt.target.IsPlayer() && this.IsTargetArmed(evt.target) {
		let npc: ref<ScriptedPuppet> = this.GetOwnerPuppet();
		if IsDefined(npc) && IsTargetPolice(npc) && Vector4.Distance(evt.target.GetWorldPosition(), npc.GetWorldPosition()) <= 5.0 {
			return AIActionHelper.TryStartCombatWithTarget(npc, evt.target);
		};
	};
	return wrappedMethod(evt);
}

// Police Kill Reporting
// ... CET Command also includes the number of police executed

public class CopsKilledMessageCallback extends DelayCallback {

	public let bActivityLog: Bool = false;

	public func Call() -> Void {
		let game: GameInstance = GetGameInstance();
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		let msg: SimpleScreenMessage;
		let msgSuffix: array<String> = (RandRange(0, 100) < 75) ? ss.GetCommonSuffix() : ss.GetRareSuffix();
		msg.message = CopKiller_CommaFormatUint32ToString(ss.nCopsKilled) + " " + msgSuffix[RandRange(0, ArraySize(msgSuffix))] + " (+" + ToString(ss.nCopsKilled - ss.nPrevCopsKilled) + ")";
		if !this.bActivityLog {
			msg.isShown		= true;
			msg.isInstant	= true;
			msg.duration	= 3.5;
			msg.type		= SimpleMessageType.Neutral;
			GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
		} else {
			GameInstance.GetActivityLogSystem(game).AddLog(msg.message);
		};
	}

}

@addMethod(GameInstance)
public static func ReportPoliceKills(game: GameInstance) -> Void {
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	let msg: SimpleScreenMessage;
	let msgSuffix: array<String> = (RandRange(0, 100) < 85) ? ss.GetCommonSuffix() : ss.GetRareSuffix();
	msg.isShown		= true;
	msg.message		= CopKiller_CommaFormatUint32ToString(ss.nCopsKilled) + " " + msgSuffix[RandRange(0, ArraySize(msgSuffix))] + " (" + CopKiller_CommaFormatUint32ToString(ss.nCopsExecuted) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilled_Executed")) + ")";
	msg.duration	= 3.5;
	msg.type		= SimpleMessageType.Neutral;
	GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
}

// MaxTac Kill Reporting
// ... CET Command also includes the number of MaxTac executed

public class MaxTacKilledMessageCallback extends DelayCallback {

	public let bActivityLog: Bool = false;

	public func Call() -> Void {
		let game: GameInstance = GetGameInstance();
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		let msg: SimpleScreenMessage;
		let msgSuffix: array<String> = ss.GetMaxTacSuffix();
		msg.message = CopKiller_CommaFormatUint32ToString(ss.nMaxTacKilled) + " " + msgSuffix[RandRange(0, ArraySize(msgSuffix))] + " (+" + ToString(ss.nMaxTacKilled - ss.nPrevMaxTacKilled) + ")";
		if !this.bActivityLog {
			msg.isShown		= true;
			msg.duration	= 3.5;
			msg.type		= SimpleMessageType.Neutral;
			GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
		} else {
			GameInstance.GetActivityLogSystem(game).AddLog(msg.message);
		};
	}
	
}

@addMethod(GameInstance)
public static func ReportMaxTacKills(game: GameInstance) -> Void {
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	let msg: SimpleScreenMessage;
	let msgSuffix: array<String> = ss.GetMaxTacSuffix();
	msg.isShown		= true;
	msg.message		= CopKiller_CommaFormatUint32ToString(ss.nMaxTacKilled) + " " + msgSuffix[RandRange(0, ArraySize(msgSuffix))] + " (" + CopKiller_CommaFormatUint32ToString(ss.nMaxTacExecuted) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilled_Executed")) + ")";
	msg.duration	= 3.5;
	msg.type		= SimpleMessageType.Neutral;
	GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
}

// Police Vehicle Destruction Reporting

public class CopCarsDestroyedMessageCallback extends DelayCallback {

	public let bActivityLog: Bool = false;

	public func Call() -> Void {
		let game: GameInstance = GetGameInstance();
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		let msg: SimpleScreenMessage;
		let msgSuffix: array<String> = ss.GetCopCarSuffix();
		msg.message = CopKiller_CommaFormatUint32ToString(ss.nCopCarsDestroyed) + " " + msgSuffix[RandRange(0, ArraySize(msgSuffix))] + " (+" + ToString(ss.nCopCarsDestroyed - ss.nPrevCopCarsDestroyed) + ")";
		if !this.bActivityLog {
			msg.isShown		= true;
			msg.duration	= 3.5;
			msg.type		= SimpleMessageType.Neutral;
			GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
		} else {
			GameInstance.GetActivityLogSystem(game).AddLog(msg.message);
		};
	}

}

@addMethod(GameInstance)
public static func ReportCopCarKills(game: GameInstance) -> Void {
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	let msg: SimpleScreenMessage;
	let msgSuffix: array<String> = ss.GetCopCarSuffix();
	msg.isShown		= true;
	msg.message		= CopKiller_CommaFormatUint32ToString(ss.nCopCarsDestroyed) + " " + msgSuffix[RandRange(0, ArraySize(msgSuffix))];
	msg.duration	= 3.5;
	msg.type		= SimpleMessageType.Neutral;
	GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
}

// Police Vehicles Looted Reporting

public class CopCarsLootedMessageCallback extends DelayCallback {

	public func Call() -> Void {
		GameInstance.GetActivityLogSystem(GetGameInstance()).AddLog(CopKiller_CommaFormatUint32ToString(CopKillerSS.GetSS().nCopCarsLooted) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarsLootedSuffix"))); // Police Vehicles Plundered
	}

}

@addMethod(GameInstance)
public static func ReportCopCarsLooted(game: GameInstance) -> Void {
	let msg: SimpleScreenMessage;
	msg.isShown		= true;
	msg.message		= CopKiller_CommaFormatUint32ToString(CopKillerSS.GetSS().nCopCarsLooted) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopCarsLootedSuffix")); // Police Vehicles Plundered
	msg.duration	= 3.5;
	msg.type		= SimpleMessageType.Neutral;
	GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
}

// Citizens Allied Reporting

public class CitizensAlliedMessageCallback extends DelayCallback {

	public func Call() -> Void {
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		GameInstance.GetActivityLogSystem(GetGameInstance()).AddLog(CopKiller_CommaFormatUint32ToString(ss.nCitizensAllied) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CitizensAlliedSuffix")) + " (+" + ToString(ss.nCitizensAllied - ss.nPrevCitizensAllied) + ")"); // joined forces with you to overthrow police
	}

}

@addMethod(GameInstance)
public static func ReportCitizensAllied(game: GameInstance) -> Void {
	let msg: SimpleScreenMessage;
	msg.isShown		= true;
	msg.message		= CopKiller_CommaFormatUint32ToString(CopKillerSS.GetSS().nCitizensAllied) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CitizensAlliedSuffix")); // joined forces with you to overthrow police
	msg.duration	= 3.5;
	msg.type		= SimpleMessageType.Neutral;
	GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
}

// Police Disrespected Reporting

public class CopsDisrespectedMessageCallback extends DelayCallback {

	public func Call() -> Void {
		GameInstance.GetActivityLogSystem(GetGameInstance()).AddLog(CopKiller_CommaFormatUint32ToString(CopKillerSS.GetSS().nCopsDisrespected) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsDisrespectedSuffix"))); // Police Disrespected
	}

}

@addMethod(GameInstance)
public static func ReportCopsDisrespected(game: GameInstance) -> Void {
	let msg: SimpleScreenMessage;
	msg.isShown		= true;
	msg.message		= CopKiller_CommaFormatUint32ToString(CopKillerSS.GetSS().nCopsDisrespected) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsDisrespectedSuffix")); // Police Disrespected
	msg.duration	= 3.5;
	msg.type		= SimpleMessageType.Neutral;
	GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
}

// Citizens Killed Reporting (Pariah)

public class CiviliansKilledMessageCallback extends DelayCallback {

	let nCivilianKillsDuringHeat: Uint32 = 0u;

	public func Call() -> Void {
		let msg: SimpleScreenMessage;
		msg.isShown		= true;
		msg.message		= CopKiller_CommaFormatUint32ToString(this.nCivilianKillsDuringHeat) + " " + GetLocalizedText(LocKeyToString(this.nCivilianKillsDuringHeat == 1u ? n"CopKiller_Reporting_CiviliansKilledSuffix_Singular" : n"CopKiller_Reporting_CiviliansKilledSuffix_Plural"));
		msg.duration	= 3.5;
		msg.type		= SimpleMessageType.Neutral;
		GameInstance.GetBlackboardSystem(GetGameInstance()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
	}

	public static func Exec(nCivilianKillsDuringHeat: Uint32, ds: ref<DelaySystem>, fDelay: Float) -> DelayID {
		let callback: ref<CiviliansKilledMessageCallback> = new CiviliansKilledMessageCallback();
		callback.nCivilianKillsDuringHeat = nCivilianKillsDuringHeat;
		return ds.DelayCallback(callback, fDelay);
	}

}

// On-Death Police Kill Reporting

@wrapMethod(PlayerPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
	if CopKillerSSX.GetSSX().bMS_ReportsAfterDeath {
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		let nCopsJustKilled: Uint32 = ss.nCopsKilled - ss.nPrevCopsKilled;
		if ss.bShowKilled && nCopsJustKilled > 0u {
			let game: GameInstance = this.GetGame();
			let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
			if IsDefined(ps) && EnumInt(ps.GetHeatStage()) > 0 {
				let msg: SimpleScreenMessage;
				msg.isShown		= true;
				msg.isInstant	= true;
				msg.message		= RandRange(0, 100) < 85 
					? GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeathPrefix_1")) + " " + ToString(nCopsJustKilled) + " " + (nCopsJustKilled == 1u ? GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeath_Singular")) : GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeath_Plural"))) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeath_And")) + " " + ToString(ss.nMaxTacKilled - ss.nPrevMaxTacKilled) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeathSuffix_1"))
					: GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeathPrefix_2")) + " " + ToString(nCopsJustKilled) + " " + (nCopsJustKilled == 1u ? GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeath_Singular")) : GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeath_Plural"))) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeath_And")) + " " + ToString(ss.nMaxTacKilled - ss.nPrevMaxTacKilled) + " " + GetLocalizedText(LocKeyToString(n"CopKiller_Reporting_CopsKilledDeathSuffix_2"));
				msg.duration	= 3.5;
				msg.type		= SimpleMessageType.Reveal;
				GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
			};
		};
		ss.bShowKilled		= false;
		ss.bShowDestroyed	= false;
		ss.bShowLooted		= false;
	};
	return wrappedMethod(evt);
}

// ...

@addField(PlayerPuppet)
public let m_CopKillerDamageLevel: Int32 = 0;

@addField(PlayerPuppet)
public let m_CopKillerDamageBonus: Float = 0.0;

@addField(PlayerPuppet)
public let m_CopKillerDamageMod: ref<gameConstantStatModifierData>;

@addMethod(PlayerPuppet)
public func CopKiller_SetSevereProblemWithAuthorityDamageLevel() -> Void {
	let dd: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this);
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bMS_Enabled || !ssx.bMS_SevereProblemWithAuthority || !IsDefined(dd) {
		this.m_CopKillerDamageLevel = 0;
		return;
	};
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	let nStreetCred: Uint32 = (!ssx.bAtone || !ssx.bMS_Atone)
		? Cast<Uint32>(dd.GetProficiencyLevel(gamedataProficiencyType.StreetCred)) 
		: Cast<Uint32>(dd.GetProficiencyLevel(gamedataProficiencyType.StreetCred)) + Atone_GetStreetCredLevelsReset_Reflected();
	let nCopsKilled: Uint32 = CopKillerSS.GetSS().nCopsKilled;
	if        nCopsKilled >= 250u && nStreetCred >= 50u {
		this.m_CopKillerDamageLevel = 5;
	} else if nCopsKilled >= 200u && nStreetCred >= 40u {
		this.m_CopKillerDamageLevel = 4;
	} else if nCopsKilled >= 150u && nStreetCred >= 30u {
		this.m_CopKillerDamageLevel = 3;
	} else if nCopsKilled >= 100u && nStreetCred >= 20u {
		this.m_CopKillerDamageLevel = 2;
	} else if nCopsKilled >= 50u  && nStreetCred >= 10u {
		this.m_CopKillerDamageLevel = 1;
	} else {
		this.m_CopKillerDamageLevel = 0;
	};
}

@wrapMethod(DamageSystem)
private final func Process(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
	let game: GameInstance = GetGameInstance();
	let attackData: ref<AttackData> = hitEvent.attackData;
	let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(game);
	if !CopKillerSSX.GetSSX().bMS_SevereProblemWithAuthority || !IsDefined(attackData) || !IsDefined(stats) {
		wrappedMethod(hitEvent, cache);
		return;
	};
	let player: wref<PlayerPuppet> = attackData.instigator as PlayerPuppet;
	let invalidMod: ref<gameConstantStatModifierData>;
	if IsDefined(player) && IsDefined(hitEvent.target) && IsTargetPolice(hitEvent.target) {
		let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
		if IsDefined(ps) {
			player.m_CopKillerDamageBonus = Cast<Float>(EnumInt(ps.GetHeatStage()) * player.m_CopKillerDamageLevel) / 100.0;
			player.m_CopKillerDamageMod = RPGManager.CreateStatModifier(gamedataStatType.AllDamageDonePercentBonus, gameStatModifierType.Additive, player.m_CopKillerDamageBonus) as gameConstantStatModifierData;
			if !Equals(player.m_CopKillerDamageMod, invalidMod) && player.m_CopKillerDamageBonus > 0.0 {
				stats.AddModifier(Cast<StatsObjectID>(player.GetEntityID()), player.m_CopKillerDamageMod);
			};
		};
	};
	wrappedMethod(hitEvent, cache);
	if IsDefined(player) && !Equals(player.m_CopKillerDamageMod, invalidMod) {
		if stats.RemoveModifier(Cast<StatsObjectID>(player.GetEntityID()), player.m_CopKillerDamageMod) {
			player.m_CopKillerDamageBonus	= 0.0;
			player.m_CopKillerDamageMod		= invalidMod;
		};
	};
}

@wrapMethod(StatsStreetCredReward)
protected cb func OnHoverOver(evt: ref<inkPointerEvent>) -> Bool {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bMS_SevereProblemWithAuthority || !ssx.bMS_SevereProblemWithAuthorityGUIStats {
		return wrappedMethod(evt);
	};
	let bResult: Bool = wrappedMethod(evt);
	let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let data: ref<LevelRewardDisplayData> = (widget.GetController() as StatsStreetCredRewardItem).GetRewardData();
	let tooltipData: ref<MessageTooltipData> = new MessageTooltipData();
	tooltipData.Title = GetLocalizedText(data.description);
	tooltipData.TitleLocalizationPackage = data.locPackage;
	switch (data.level) {
		case 10: tooltipData.Title += "\n" + GetLocalizedText(LocKeyToString(n"CopKiller_StreetCredProgression_10")); break;
		case 20: tooltipData.Title += "\n" + GetLocalizedText(LocKeyToString(n"CopKiller_StreetCredProgression_20")); break;
		case 30: tooltipData.Title += "\n" + GetLocalizedText(LocKeyToString(n"CopKiller_StreetCredProgression_30")); break;
		case 40: tooltipData.Title += "\n" + GetLocalizedText(LocKeyToString(n"CopKiller_StreetCredProgression_40")); break;
		case 50: tooltipData.Title += "\n" + GetLocalizedText(LocKeyToString(n"CopKiller_StreetCredProgression_50")); break;
	};
	if IsDefined(this.m_tooltipsManager) {
		this.m_tooltipsManager.ShowTooltipAtWidget(this.m_tooltipIndex, widget, tooltipData, gameuiETooltipPlacement.RightCenter, false, inkMargin(40.0, 0.0, 0.0, 0.0));
	};
	return bResult;
}

@wrapMethod(WantedBarGameController)
protected cb func OnWantedStateChange(value: CName) -> Bool {
	let bResult: Bool = wrappedMethod(value);
	this.CopKiller_SetSevereProblemWithAuthorityStarsTint();
	return bResult;
}

@wrapMethod(WantedBarGameController)
public final func UpdateWantedBar(newWantedLevel: Int32) -> Void {
	wrappedMethod(newWantedLevel);
	this.CopKiller_SetSevereProblemWithAuthorityStarsTint();
}

@addMethod(WantedBarGameController)
public func CopKiller_SetSevereProblemWithAuthorityStarsTint() -> Void {
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !ssx.bMS_Enabled || !ssx.bMS_SevereProblemWithAuthority || !ssx.bMS_SevereProblemWithAuthorityGUIStars { return; };
	let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
	let dmgLevel: Int32 = IsDefined(player) ? player.m_CopKillerDamageLevel : 0;
	let Red: HDRColor = HDRColor(1.0, 0.2, 0.25, 1.0); // E3 Red
	let Blu: HDRColor = HDRColor(0.301960796, 0.690196097, 0.647058845, 1.0); // Default Wanted Star Blue
	let star: wref<StarController>;
	let i: Int32 = 0;
	while i < 5 {
		star = inkWidgetRef.GetController(this.starsWidget[i]) as StarController; // new_bar/holder/levels_holder/bounty_level_1/STAR/star
		if IsDefined(star) {
			inkWidgetRef.SetTintColor(star.m_icon, dmgLevel > i ? Red : Blu);
		};
		i += 1;
	};
}

@wrapMethod(PreventionSystem)
private final func TryGetUnitDataFromVehicleRecord(vehicleRecord: wref<Vehicle_Record>, const recordsCount: Int32, recordIDs: script_ref<array<TweakDBID>>) -> Bool {
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	let ssx: ref<CopKillerSSX> = CopKillerSSX.GetSSX();
	if !IsDefined(vehicleRecord) || !ssx.bMS_UnderfundedDeptMode || (ssx.bMS_UnderfundedDeptMode && ssx.nMS_UnderfundedDeptModeKillReq > 0 && ss.nCopsKilled < Cast<Uint32>(ssx.nMS_UnderfundedDeptModeKillReq)) {
		return wrappedMethod(vehicleRecord, recordsCount, recordIDs);
	};
	if vehicleRecord.GetPreventionPassengersCount() > 0 {
		let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"PreventionSystem") as PreventionSystem;
		if IsDefined(ps) {
			let ppDistrictTDBID: TweakDBID = ps.m_preventionPreset.GetRecordID();
			if Equals(ppDistrictTDBID, t"PreventionData.NCPD") || Equals(ppDistrictTDBID, t"PreventionData.NCPDLowSec") {
				let tssx: ref<CopKillerTweaksSSX> = CopKillerTweaksSSX.GetSSX();
				let charRecordPool: array<TweakDBID>;
				let bAddUnits: Bool = false;
				switch (EnumInt(ps.GetHeatStage())) {
					case 1: charRecordPool = tssx.CharList_UnderfundedHeatOneUnits();   break;
					case 2: charRecordPool = tssx.CharList_UnderfundedHeatTwoUnits();   bAddUnits = true; break;
					case 3: charRecordPool = tssx.CharList_UnderfundedHeatThreeUnits(); bAddUnits = true; break;
					case 4: charRecordPool = tssx.CharList_UnderfundedHeatFourUnits();  break;
					case 5: charRecordPool = tssx.CharList_UnderfundedHeatFiveUnits();  break;
				};
				let district: wref<District> = ps.GetCurrentDistrict();
				if bAddUnits {
					if IsDefined(district) && IsDefined(district.m_districtRecord) {
						switch (district.m_districtRecord.Type()) {
							case gamedataDistrict.Arroyo:			for c in tssx.CharList_NCPD_SubDistrict_Arroyo_SantoDomingo()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.CharterHill:		for c in tssx.CharList_NCPD_SubDistrict_CharterHill_Westbrook()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.Coastview:		for c in tssx.CharList_NCPD_SubDistrict_Coastview_Pacifica()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.CorpoPlaza:		for c in tssx.CharList_NCPD_SubDistrict_CorpoPlaza_CityCenter()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.Downtown:			for c in tssx.CharList_NCPD_SubDistrict_Downtown_CityCenter()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.Glen:				for c in tssx.CharList_NCPD_SubDistrict_TheGlen_Heywood()				{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.JapanTown:		for c in tssx.CharList_NCPD_SubDistrict_Japantown_Westbrook()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.Kabuki:			for c in tssx.CharList_NCPD_SubDistrict_Kabuki_Watson()					{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.LittleChina:		for c in tssx.CharList_NCPD_SubDistrict_LittleChina_Watson()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.NorthOaks:		for c in tssx.CharList_NCPD_SubDistrict_NorthOak_Westbrook()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.Northside:		for c in tssx.CharList_NCPD_SubDistrict_Northside_Watson()				{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.RanchoCoronado:	for c in tssx.CharList_NCPD_SubDistrict_RanchoCoronado_SantoDomingo()	{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.VistaDelRey:		for c in tssx.CharList_NCPD_SubDistrict_VistaDelRey_Heywood()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.Wellsprings:		for c in tssx.CharList_NCPD_SubDistrict_Wellsprings_Heywood()			{ ArrayPush(charRecordPool, c); }; break;
							case gamedataDistrict.WestWindEstate:	for c in tssx.CharList_NCPD_SubDistrict_WestWindEstate_Pacifica()		{ ArrayPush(charRecordPool, c); }; break;
						};
					};
				};
				if ArraySize(charRecordPool) > 0 {
					if ssx.bMS_TraitorsAndBetrayers && RandRange(0, 100) < 25 {
						let tBountyHunters: array<TweakDBID> = 
							IsDefined(district) && IsDefined(district.m_districtRecord) && Equals(district.m_districtRecord.Type(), gamedataDistrict.Badlands)
								? tssx.CharList_Prevention_BountyHunters_Badlands()
								: tssx.CharList_Prevention_BountyHunters_NightCity();
						ArrayInsert(charRecordPool, 0, tBountyHunters[RandRange(0, ArraySize(tBountyHunters))]);
					};
					let i: Int32 = 0;
					while i < recordsCount {
						ArrayPush(Deref(recordIDs), charRecordPool[RandRange(0, ArraySize(charRecordPool))]);
						i += 1;
					};
					return true;
				};
			};
		};
	};
	return wrappedMethod(vehicleRecord, recordsCount, recordIDs);
}

public class DisrespectWorkspotStartCallback extends DelayCallback {

	let des: ref<DynamicEntitySystem>;
	let wss: ref<WorkspotGameSystem>;
	let ds: ref<DelaySystem>;
	let user: ref<ScriptedPuppet>;
	let workspot: ref<GameObject>;
	let animName: CName;
	let fDuration: Float;

	public func Call() -> Void {
		DynamicWorkspotHandler.TeleportToUser(this.user, this.workspot);
		if this.user.IsPlayer() {
			this.wss.PlayInDevice(this.workspot, this.user);
		} else {
			this.wss.PlayInDeviceSimple(this.workspot, this.user, false, n"ck_workspot_base", n"", n"", 0.0, WorkspotSlidingBehaviour.DontPlayAtResourcePosition, null);
		};
		this.wss.SendJumpToAnimEnt(this.user, this.animName, true);
		DisrespectWorkspotEndCallback.Exec(this.des, this.wss, this.ds, this.user, this.workspot, this.animName, this.fDuration);
	}

	public static func Exec(des: ref<DynamicEntitySystem>, wss: ref<WorkspotGameSystem>, ds: ref<DelaySystem>, user: ref<ScriptedPuppet>, workspot: ref<GameObject>, animName: CName, fDuration: Float, fDelay: Float) -> DelayID {
		let callback: ref<DisrespectWorkspotStartCallback> = new DisrespectWorkspotStartCallback();
		callback.des		= des;
		callback.wss		= wss;
		callback.ds			= ds;
		callback.user		= user;
		callback.workspot	= workspot;
		callback.animName	= animName;
		callback.fDuration	= fDuration;
		return ds.DelayCallback(callback, fDelay, true);
	}

}

public class DisrespectWorkspotEndCallback extends DelayCallback {

	let des: ref<DynamicEntitySystem>;
	let wss: ref<WorkspotGameSystem>;
	let ds: ref<DelaySystem>;
	let user: ref<ScriptedPuppet>;
	let workspot: ref<GameObject>;
	let animName: CName;

	public func Call() -> Void {
		this.wss.StopInDevice(this.user);
		let tags: array<CName> = this.des.GetTags(this.workspot.GetEntityID());
		if this.user.IsPlayer() {
			if Equals(tags[0], n"Disrespect") {
				GameInstance.GetStatusEffectSystem(this.user.GetGame()).RemoveStatusEffect(this.user.GetEntityID(), t"GameplayRestriction.NoCombat");
				let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
				if DisrespectOpportunity.WillDisrespectedTargetEngagePlayer(this.user as PlayerPuppet, ss.disrespectTarget) {
					ss.bDisrespectBeganHeat = AIActionHelper.TryStartCombatWithTarget(ss.disrespectTarget, this.user);
				};
				ss.disrespectTarget = null;
				ss.nCopsDisrespected += 1u;
				if CopKillerSSX.GetSSX().bMS_ActivityLogReports && IsDefined(this.ds) {
					this.ds.DelayCallback(new CopsDisrespectedMessageCallback(), 0.0);
				};
				ss.bDisrespect = true;
			};
		} else {
			if Equals(tags[0], n"AngryReact") && !StrContains(NameToString(this.animName), "stop") {
				GameInstance.GetStatusEffectSystem(this.user.GetGame()).ApplyStatusEffect(this.user.GetEntityID(), t"WorkspotStatus.SyncAnimation"); // Once/Target Hack
			};
		};
	}

	public static func Exec(des: ref<DynamicEntitySystem>, wss: ref<WorkspotGameSystem>, ds: ref<DelaySystem>, user: ref<ScriptedPuppet>, workspot: ref<GameObject>, animName: CName, fDelay: Float) -> DelayID {
		let callback: ref<DisrespectWorkspotEndCallback> = new DisrespectWorkspotEndCallback();
		callback.des		= des;
		callback.wss		= wss;
		callback.ds			= ds;
		callback.user		= user;
		callback.workspot	= workspot;
		callback.animName	= animName;
		return ds.DelayCallback(callback, fDelay, true);
	}

}

public class DisrespectEndCooldownCallback extends DelayCallback {

	public func Call() -> Void {
		CopKillerSS.GetSS().bDisrespectCooldownActive = false;
	}

}

public class DisrespectAllowRetargetCallback extends DelayCallback {

	public func Call() -> Void {
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		ss.bDisrespectRetargetDelayActive = IsDefined(ss.disrespectTarget) && ss.bDisrespectButtonHeld;
	}

}

public class DisrespectOpportunity {

	public static func CanDisrespect() -> Bool {
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		return IsDefined(ss.disrespectTarget) && !ss.bDisrespectCooldownActive ? true : false;
	}

	public static func PlayDisrespect() -> Void {
		let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
		let game: GameInstance = GetGameInstance();
		let player: ref<PlayerPuppet> = GetPlayer(game);
		if IsDefined(player) && IsDefined(ss.dynamicWorkspotHandler) && IsDefined(ss.disrespectTarget) {
			ss.dynamicWorkspotHandler.ActivateWorkspot(ss.disrespectTarget, ss.angryReactWorkspot, 1.033, true);
			GameInstance.GetStatusEffectSystem(game).ApplyStatusEffect(player.GetEntityID(), t"GameplayRestriction.NoCombat");
			let localAimRequest: AimRequest;
			localAimRequest.lookAtTarget		= ss.disrespectTarget.GetWorldPosition();
			localAimRequest.lookAtTarget.Z		+= 1.5;
			localAimRequest.duration			= 0.33;
			localAimRequest.precision			= 0.01;
			localAimRequest.adjustPitch			= true;
			localAimRequest.adjustYaw			= true;
			localAimRequest.endOnTargetReached	= true;
			GameInstance.GetTargetingSystem(game).BreakAimSnap(player);
			GameInstance.GetTargetingSystem(game).LookAt(player, localAimRequest);
			DisrespectOpportunity.PlayDisrespectAudio(player);
			ss.dynamicWorkspotHandler.ActivateWorkspot(player, ss.disrespectWorkspot);
		};
	}

	@if(!ModuleExists("Audioware"))
	public static func PlayDisrespectAudio(player: ref<PlayerPuppet>) -> Void {
		ChatterHelper.PlayVoiceOver(player, Equals(player.GetGender(), n"Male") ? n"v_sq017_m_192828f86229f000" : n"v_sq017_f_192828f86229f000"); // Broken
	}

	@if(ModuleExists("Audioware"))
	public static func PlayDisrespectAudio(player: ref<PlayerPuppet>) -> Void {
		let audioware: ref<AudioSystemExt> = GameInstance.GetAudioSystemExt(player.GetGame());
		if IsDefined(audioware) {
			switch (RandRange(0, 5)) {
				case 0:
					break;
				case 1:
					audioware.Play(Equals(player.GetGender(), n"Male") ? n"ck_v_sq017_m_192828f86229f000" : n"ck_v_sq017_f_192828f86229f000"); // "Know what? Fuck off."
					break;
				case 2:
					audioware.Play(Equals(player.GetGender(), n"Male") ? n"ck_v_q110_m_17101b0f90351000" : n"ck_v_q110_f_17101b0f90351000"); // "I fucking dare you."
					break;
				case 3:
					audioware.Play(Equals(player.GetGender(), n"Male") ? n"ck_v_sq012_m_1ae890cc1f2b6000" : n"ck_v_sq012_f_1ae890cc1f2b6000"); // "You. Fuck. Off."
					break;
				case 4:
					audioware.Play(Equals(player.GetGender(), n"Male") ? n"ck_v_vs_vset_delamain_m_1b62d5ff7f2fc004" : n"ck_v_vs_vset_delamain_f_1b62d5ff7f2fc004"); // "Hm. What's this?"
					break;
			};
		};
	}

	public static func WillDisrespectedTargetEngagePlayer(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Bool {
		if StatusEffectSystem.ObjectHasStatusEffectWithTag(player, n"Cloak") || ScriptedPuppet.IsBlinded(npc) {
			return false;
		};
		let dd: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
		return player.IsNaked() || (IsDefined(dd) && dd.GetProficiencyLevel(gamedataProficiencyType.StreetCred) < 25) ? true : false;
	}

}

public class DynamicWorkspotHandler {

	public let des: ref<DynamicEntitySystem>;

	public func CreateWorkspot(tags: array<CName>) -> Void {
		if ArraySize(tags) > 0 {
			this.des.RegisterListener(tags[0], this, n"OnUpdate");
			let spec: ref<DynamicEntitySpec> = new DynamicEntitySpec();
			spec.tags			= tags;
			spec.templatePath	= r"demon9ne\\copkiller\\workspots\\workspot_anim.ent";
			spec.alwaysSpawned	= true;
			this.des.CreateEntity(spec);
		};
	}

	private cb func OnUpdate(event: ref<DynamicEntityEvent>) -> Void {
		if IsDefined(event) && Equals(event.GetEventType(), DynamicEntityEventType.Spawned) {
			let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
			switch (event.GetEntityTag()) {
				case n"Disrespect": ss.disrespectWorkspotID = event.GetEntityID(); ss.disrespectWorkspot = this.des.GetEntity(ss.disrespectWorkspotID) as GameObject; break;
				case n"AngryReact": ss.angryReactWorkspotID = event.GetEntityID(); ss.angryReactWorkspot = this.des.GetEntity(ss.angryReactWorkspotID) as GameObject; break;
			};
		};
	}

	public static func TeleportToUser(user: ref<ScriptedPuppet>, workspot: ref<GameObject>) -> Void {
		let transform: WorldTransform = user.GetWorldTransform(); // transform.SetPosition(user.GetWorldPosition());
		let angles: EulerAngles = user.IsPlayer()
			? Vector4.ToRotation(Matrix.GetDirectionVector((user as PlayerPuppet).GetFPPCameraComponent().GetLocalToWorld()))
			: Quaternion.ToEulerAngles(user.GetWorldOrientation());
		angles.Pitch	= 0.0;
		angles.Roll		= 0.0;
		angles.Yaw		= angles.Yaw + 180.0;
		WorldTransform.SetOrientationEuler(transform, angles); // transform.SetOrientationEuler(angles);
		workspot.SetWorldTransform(transform);
	}

	public func ActivateWorkspot(user: ref<ScriptedPuppet>, workspot: ref<GameObject>, opt fStart: Float, opt bHaltAnim: Bool) -> Void {
		let game: GameInstance = user.GetGame();
		let wss: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(game);
		let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);
		if IsDefined(wss) && IsDefined(ds) {
			let animName: CName = n"";
			let fDuration: Float = 0.0;
			let tags: array<CName> = this.des.GetTags(workspot.GetEntityID());
			if Equals(tags[0], n"Disrespect") {
				animName = n"stand__2h_on_sides__01__lh_fuck_you__01";
				fDuration = 2.066;
			} else if Equals(tags[0], n"AngryReact") {
				wss.StopInDevice(user);
				let cmc: ref<CrowdMemberBaseComponent> = user.GetCrowdMemberComponent();
				if IsDefined(cmc) {
					cmc.AllowWorkspotsUsage(true);
				};
				switch (RandRange(1, 4)) {
				//	case 0: animName = n"stand__2h_on_sides__01__stop__angry__01";			fDuration = 5.000; break; // Cut down from 9.000
					case 1: animName = n"stand__2h_on_sides__01__what__angry__01";			fDuration = 5.166; break;
					case 2: animName = n"stand__2h_on_sides__01__what_is_this__angry__01";	fDuration = 4.533; break;
					case 3: animName = n"stand__2h_on_sides__01__whatever__disgusted__01";	fDuration = 5.599; break;
				};
				let rc: ref<ReactionManagerComponent> = user.GetStimReactionComponent();
				if IsDefined(rc) && rc.CanTriggerExpressionLookAt() {
					rc.ActivateReactionLookAt(GetPlayer(game), false, true, fDuration + fStart, true, false);
				};
				if fStart > 0.05 && bHaltAnim {
					DisrespectWorkspotStartCallback.Exec(this.des, wss, ds, user, workspot, n"stand__2h_on_sides__01__stop__angry__01", fStart - 0.05, 0.0);
				};
			};
			if !Equals(animName, n"") {
				DisrespectWorkspotStartCallback.Exec(this.des, wss, ds, user, workspot, animName, fDuration, fStart);
			};
		};
	}

}

@wrapMethod(PlayerPuppet)
private final func UpdateLookAtObject(target: ref<GameObject>) -> Void {
	wrappedMethod(target);
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	if !CopKillerSSX.GetSSX().bMS_Introductions || ss.bDisrespectButtonHeld || ss.bDisrespectRetargetDelayActive || ss.bDisrespectCooldownActive {
		return;
	};
	let npc: ref<NPCPuppet> = target as NPCPuppet;
	if !IsDefined(npc) {
		ss.disrespectTarget = null;
		return;
	};
	let game: GameInstance = this.GetGame();
	let sc: ref<SenseComponent> = npc.GetSensesComponent();
	let sm: ref<SenseManager> = GameInstance.GetSenseManager(game);
	let rmc: ref<ReactionManagerComponent> = npc.m_reactionComponent;
	if !IsDefined(sc) || !IsDefined(sm) || !IsDefined(rmc) || this.m_inCrouch || npc.m_isRagdolling {
		ss.disrespectTarget = null;
		return;
	};
	if !IsTargetPolice(npc) || !npc.IsHuman() || !ScriptedPuppet.IsAlive(npc) || VehicleComponent.IsMountedToVehicle(game, npc) {
		ss.disrespectTarget = null;
		return;
	};
	if rmc.IsPlayerFearThreat() || this.IsInCombat() || VehicleSystem.IsPlayerInVehicle(game) {
		ss.disrespectTarget = null;
		return;
	}
	if !rmc.IsTargetClose(this, 7.5) || !rmc.TargetVerticalCheck(this) {
		ss.disrespectTarget = null;
		return;
	};
	ss.disrespectTarget = sc.m_enabledSenses
		? (ReactionManagerComponent.IsTargetInFrontOfSource(this, npc, 60.00) && sm.IsObjectVisible(npc.GetEntityID(), this.GetEntityID()) ? npc : null)
		: (ReactionManagerComponent.IsTargetInFrontOfSource(this, npc, 60.00) && ReactionManagerComponent.IsTargetInFrontOfSource(npc, this, 60.00) ? npc : null);
	if IsDefined(ss.disrespectTarget) {
		ss.bDisrespectRetargetDelayActive = true;
		let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);
		if IsDefined(ds) {
			ds.DelayCallback(new DisrespectAllowRetargetCallback(), ss.fDisrespectRetarget);
		};
	};
}

@wrapMethod(BaseContextEvents)
private final func UpdateHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
	if this.ShouldForceRefreshInputHints(stateContext) || !DisrespectOpportunity.CanDisrespect() {
		this.CopKiller_RemoveDisrespectInputHints(stateContext, scriptInterface);
	}
	wrappedMethod(stateContext, scriptInterface);
}

@wrapMethod(InputContextTransitionEvents)
protected final func SetBaseContextInputHints(context: ActiveBaseContext, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
	let bDisrespect: Bool = DisrespectOpportunity.CanDisrespect();
	if (Equals(context, ActiveBaseContext.Locomotion) || Equals(context, ActiveBaseContext.None)) && bDisrespect {
		if !stateContext.GetBoolParameter(CopKillerSS.GetSS().buttonContextName, true) {
			this.CopKiller_ShowDisrespectInputHints(stateContext, scriptInterface);
		}
	} else if !bDisrespect {
		if stateContext.GetBoolParameter(CopKillerSS.GetSS().buttonContextName, true) {
			this.CopKiller_RemoveDisrespectInputHints(stateContext, scriptInterface);
		}
	}
	wrappedMethod(context, stateContext, scriptInterface);
}

@addMethod(InputContextTransitionEvents)
protected final func CopKiller_ShowDisrespectInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	this.ShowInputHint(scriptInterface, n"Choice1_Hold", ss.className, ss.bDisrespect ? ss.strDisrespect : ss.strIntroductions, inkInputHintHoldIndicationType.Hold, true, -2147483647);
	this.CopKiller_SetHiddenDisrespectInput(scriptInterface, n"Reload", ss.className, inkInputHintHoldIndicationType.Press);
	stateContext.SetPermanentBoolParameter(ss.buttonContextName, true, true);
}

@addMethod(InputContextTransitionEvents)
protected final func CopKiller_SetHiddenDisrespectInput(scriptInterface: ref<StateGameScriptInterface>, actionName: CName, source: CName, opt holdIndicationType: inkInputHintHoldIndicationType) -> Void {
	let data: InputHintData;
    data.action							= actionName;
    data.source							= source;
    data.localizedLabel					= "";
	data.holdIndicationType				= holdIndicationType;
	let evt: ref<UpdateInputHintEvent>	= new UpdateInputHintEvent();
    evt.data							= data;
    evt.show							= false;
    evt.targetHintContainer				= n"GameplayInputHelper";
    scriptInterface.GetUISystem().QueueEvent(evt);
}

@addMethod(InputContextTransitionEvents)
protected final func CopKiller_RemoveDisrespectInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	this.RemoveInputHintsBySource(scriptInterface, ss.className);
	stateContext.RemovePermanentBoolParameter(ss.buttonContextName);
	ss.bDisrespectRetargetDelayActive = false;
	ss.disrespectTarget = null;
}

@wrapMethod(InputContextTransitionEvents)
protected final func RemoveAllInputHints(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
	this.CopKiller_RemoveDisrespectInputHints(stateContext, scriptInterface);
	wrappedMethod(stateContext, scriptInterface);
}

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
	let actionName: CName				= ListenerAction.GetName(action);
	let actionType: gameinputActionType	= ListenerAction.GetType(action);
	let ss: ref<CopKillerSS> = CopKillerSS.GetSS();
	if Equals(actionName, n"Reload") {
		if Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
			ss.bDisrespectButtonHeld = true;
		} else if Equals(actionType, gameinputActionType.BUTTON_RELEASED) {
			ss.bDisrespectButtonHeld = false;
		};
	} else if Equals(actionName, n"Choice1_Hold") && Equals(actionType, gameinputActionType.BUTTON_HOLD_COMPLETE) {
		DisrespectOpportunity.PlayDisrespect();
		let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(GetGameInstance());
		if IsDefined(ds) {
			ss.bDisrespectCooldownActive = true;
			ds.DelayCallback(new DisrespectEndCooldownCallback(), ss.fDisrespectCooldown);
		};
	};
	return wrappedMethod(action, consumer);
}

@if(!ModuleExists("GamepadButtonHoldIndicatorFix"))
@wrapMethod(GamepadHoldIndicatorGameController)
protected func HoldStart() -> Void {
	if Equals(inkWidgetRef.GetName(this.m_image), n"progress") && StrContains(this.m_partName, "icon_circle_anim_") {
		inkWidgetRef.SetAnchor(this.m_image, inkEAnchor.Centered);
		inkWidgetRef.SetHAlign(this.m_image, inkEHorizontalAlign.Center);
		inkWidgetRef.SetVAlign(this.m_image, inkEVerticalAlign.Center);
		inkWidgetRef.SetAnchorPoint(this.m_image, new Vector2(0.5, 0.5));
		inkWidgetRef.SetMargin(this.m_image, new inkMargin(0, 0, 0, 0));
		inkWidgetRef.SetPadding(this.m_image, new inkMargin(0, 0, 0, 0));
		inkWidgetRef.SetRenderTransformPivot(this.m_image, new Vector2(0.5, 0.5));
		let rootWidget: wref<inkWidget> = this.GetRootWidget();
		rootWidget.SetAnchor(inkEAnchor.Centered);
		rootWidget.SetHAlign(inkEHorizontalAlign.Center);
		rootWidget.SetVAlign(inkEVerticalAlign.Center);
		rootWidget.SetAnchorPoint(new Vector2(0.5, 0.5));
		rootWidget.SetMargin(new inkMargin(0, 0, 0, 0));
		rootWidget.SetPadding(new inkMargin(0, 0, 0, 0));
		rootWidget.SetRenderTransformPivot(new Vector2(0.5, 0.5));
	};
	wrappedMethod();
}
