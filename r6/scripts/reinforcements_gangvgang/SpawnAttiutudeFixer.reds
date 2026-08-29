import Gibbon.GR.ReinforcementSystem.*
import Gibbon.GR.GangHandlers.*
import Gibbon.GR.Logging.*

@wrapMethod(NPCPuppet)
protected cb func OnGameAttached() -> Bool {
    let outcome = wrappedMethod();

    if NPCManager.HasTag(this.GetRecordID(), n"GRModPuppet") {
        let reinSystem: wref<GRReinforcementSystem> = GRReinforcementSystem.GetInstance(GetGameInstance());
        let factionHandler = reinSystem.GetFactionHandler(this);

        this.GRAttitudeFix(factionHandler.GetLastCaller(), factionHandler.GetLastTarget(), factionHandler.GetAttitudeGroup(), factionHandler.GetLastSecondaryTarget());
    }
    
    return outcome;
} 

func GRIsSameAffiliation(a: ref<ScriptedPuppet>, b: ref<ScriptedPuppet>) -> Bool {
    let recordA = TweakDBInterface.GetCharacterRecord(a.GetRecordID());
    let recordB = TweakDBInterface.GetCharacterRecord(b.GetRecordID());
    if !IsDefined(recordA) || !IsDefined(recordB) {
        return false;
    };
    return Equals(recordA.Affiliation().Type(), recordB.Affiliation().Type());
}

@addMethod(NPCPuppet)
protected final func GRSetHostileTowardsCombatant(combatant: ref<GameObject>) -> Void {
    if !IsDefined(this) || !IsDefined(combatant) {
        return;
    };
    let attitudeOwner: ref<AttitudeAgent> = this.GetAttitudeAgent();
    if !IsDefined(attitudeOwner) {
        return;
    };

    // guard against squads that end up mixing affiliations - never force hostility onto our own faction
    let attitudeCombatant: ref<AttitudeAgent> = combatant.GetAttitudeAgent();
    if IsDefined(attitudeCombatant) && !GRIsSameAffiliation(this, combatant as ScriptedPuppet) {
        attitudeOwner.SetAttitudeTowards(attitudeCombatant, EAIAttitude.AIA_Hostile);
    };

    let squadmates: array<wref<Entity>>;
    let squadmate: ref<GameObject>;
    let attitudeSquadmate: ref<AttitudeAgent>;
    let i: Int32;
    if AISquadHelper.GetSquadmates(combatant as ScriptedPuppet, squadmates) {
        i = 0;
        while i < ArraySize(squadmates) {
            squadmate = squadmates[i] as GameObject;
            if IsDefined(squadmate) {
                attitudeSquadmate = squadmate.GetAttitudeAgent();
                if IsDefined(attitudeSquadmate) && !GRIsSameAffiliation(this, squadmate as ScriptedPuppet) {
                    attitudeOwner.SetAttitudeTowards(attitudeSquadmate, EAIAttitude.AIA_Hostile);
                };
            };
            i += 1;
        };
    };
}

@addMethod(NPCPuppet)
protected final func GRAttitudeFix(caller: ref<GameObject>, target: ref<GameObject>, fallbackAttitudeGroup: CName, secondaryTarget: ref<GameObject>) -> Bool {
    let squadMember: ref<GameObject>;
    let i: Int32;
    let attitudeOwner: ref<AttitudeAgent>;
    let attitudeCaller: ref<AttitudeAgent>;
    let callerSquadMembers: array<wref<Entity>>;
    let squadBaseInterface: ref<PuppetSquadInterface>;
    if (IsDefined(this)) {
        attitudeOwner = this.GetAttitudeAgent();
    };
    if !IsDefined(attitudeOwner) {
        return false;
    };

    this.GRSetHostileTowardsCombatant(target);
    this.GRSetHostileTowardsCombatant(secondaryTarget);

    // If caller is not defined but owner attitude agent is available, set attitude group to the fallback from the gang handler
    if (!IsDefined(caller)) {
		GRLog("Caller is not defined, setting attitude group to fallback");
        attitudeOwner.SetAttitudeGroup(fallbackAttitudeGroup);
        return true;
    };

    attitudeCaller = caller.GetAttitudeAgent();
    if !IsDefined(attitudeCaller) {
        return false;
    };

    attitudeOwner.SetAttitudeGroup(attitudeCaller.GetAttitudeGroup());
    attitudeOwner.SetAttitudeTowards(attitudeCaller, EAIAttitude.AIA_Friendly);
    attitudeCaller.SetAttitudeTowards(attitudeOwner, EAIAttitude.AIA_Friendly);
    
    if AISquadHelper.GetSquadmates(caller as ScriptedPuppet, callerSquadMembers) {
        i = 0;
        while i < ArraySize(callerSquadMembers) {
			squadMember = callerSquadMembers[i] as GameObject;
			if IsDefined(squadMember) && squadMember != this {
				let attitudeSquadMember = squadMember.GetAttitudeAgent();
				if IsDefined(attitudeSquadMember) {
					attitudeOwner.SetAttitudeTowards(attitudeSquadMember, EAIAttitude.AIA_Friendly);
					attitudeSquadMember.SetAttitudeTowards(attitudeOwner, EAIAttitude.AIA_Friendly);
				};
			};
			i += 1;
        };
    };

    // Actually join the caller's AI squad structure so squad-level behaviours (shared threats, tickets) apply
    if (AISquadHelper.GetSquadBaseInterface(caller, squadBaseInterface)) {
        squadBaseInterface.Join(this);
    };

    return true;
}