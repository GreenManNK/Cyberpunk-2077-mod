module Gibbon.GR.ReinforcementSystem

import Gibbon.GR.GangHandlers.*
import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.*
import Gibbon.GR.Logging.*

public class GRReinforcementSystem extends ScriptableSystem {
    private let m_tygerHandler: ref<GRTygersHandler>;
    private let m_scavHandler: ref<GRScavsHandler>;
    private let m_animalsHandler: ref<GRAnimalsHandler>;
    private let m_maelStormHandler: ref<GRMaelStromHandler>;
    private let m_arasakaHandler: ref<GRArasakaHandler>;
    private let m_voodooHandler: ref<GRVoodooHandler>;
    private let m_sixthHandler: ref<GRSixthStreetHandler>;
    private let m_militechHandler: ref<GRMilitechHandler>;
    private let m_valentinosHandler: ref<GRValentinosHandler>;
    private let m_barghestHandler: ref<GRBarghestHandler>;
    private let m_kangTaoHandler: ref<GRKangTaoHandler>;
    private let m_wraithsHandler: ref<GRWraithsHandler>;
    private let m_ncpdHandler: ref<GRNCPDHandler>;
    private let m_moxHandler: ref<GRMoxHandler>;
    private let m_aldecaldosHandler: ref<GRAldecaldosHandler>;
	private let m_gameAttachHandled: Bool = false;

    private let m_preventionSystem: ref<PreventionSystem>;
    private let m_questsSystem: ref<QuestsSystem>;
	private let m_delaySystem: ref<DelaySystem>;

	// shared cooldown applied to every non-authority gang when an authority intervention is dispatched,
	// so the law getting involved actually quiets things down instead of every other gang piling on
	private let m_authorityInterventionCooldownActive: Bool = false;
	private let m_authorityInterventionCooldownDuration: Float = 120.0;

    public let m_settings: ref<GRSettings>;

	public func OnAttach() -> Void {
		this.m_gameAttachHandled = false;
	}

    public final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        let theGame = GetGameInstance();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(theGame).Get(n"PreventionSystem") as PreventionSystem;
        this.m_questsSystem = GameInstance.GetQuestsSystem(theGame);
		this.m_delaySystem = GameInstance.GetDelaySystem(theGame);

        this.m_settings = GRSettings.GetInstance(theGame);

        this.m_sixthHandler = GRSixthStreetHandler.GetInstance(theGame);
        this.m_animalsHandler = GRAnimalsHandler.GetInstance(theGame);
        this.m_arasakaHandler = GRArasakaHandler.GetInstance(theGame);
        this.m_barghestHandler = GRBarghestHandler.GetInstance(theGame);
        this.m_maelStormHandler = GRMaelStromHandler.GetInstance(theGame);
        this.m_moxHandler = GRMoxHandler.GetInstance(theGame);
        this.m_militechHandler = GRMilitechHandler.GetInstance(theGame);
        this.m_ncpdHandler = GRNCPDHandler.GetInstance(theGame);
        this.m_scavHandler = GRScavsHandler.GetInstance(theGame);
        this.m_tygerHandler = GRTygersHandler.GetInstance(theGame);
        this.m_valentinosHandler = GRValentinosHandler.GetInstance(theGame);
        this.m_voodooHandler = GRVoodooHandler.GetInstance(theGame);
        this.m_wraithsHandler = GRWraithsHandler.GetInstance(theGame);
        this.m_kangTaoHandler = GRKangTaoHandler.GetInstance(theGame);
        this.m_aldecaldosHandler = GRAldecaldosHandler.GetInstance(theGame);

        // cause we're doing funky stuff with public and private bindings
        this.m_settings.ReconcileSettings();

		if !this.m_gameAttachHandled {
			this.HandleGameAttach();
		} else {
			this.ResetAllGangs();
		}
    }

	public func OnRestored(saveVersion: Int32, gameVersion: Int32) {
		if !this.m_gameAttachHandled {
			this.HandleGameAttach();
		}
    }
  
	// player attached is the last thing to happen so don't do any work in here
	//just set the flag so we know game logic can be run in OnPlayerAttach
	public func HandleGameAttach() -> Void { 
		if GameInstance.GetSystemRequestsHandler().IsPreGame() {
			return;
		}
		this.m_gameAttachHandled = true;
	}

    public func ResetAllGangs() -> Void {
        this.m_sixthHandler.ResetGang();
        this.m_animalsHandler.ResetGang();
        this.m_arasakaHandler.ResetGang();
        this.m_barghestHandler.ResetGang();
        this.m_maelStormHandler.ResetGang();
        this.m_moxHandler.ResetGang();
        this.m_militechHandler.ResetGang();
        this.m_ncpdHandler.ResetGang();
        this.m_scavHandler.ResetGang();
        this.m_tygerHandler.ResetGang();
        this.m_valentinosHandler.ResetGang();
        this.m_voodooHandler.ResetGang();
        this.m_wraithsHandler.ResetGang();
        this.m_kangTaoHandler.ResetGang();
        this.m_aldecaldosHandler.ResetGang();
        this.m_authorityInterventionCooldownActive = false;
    }

    public func OnSettingsChanged() -> Void {
        this.m_sixthHandler.SetIsDisabled(!this.m_settings.sixthStreetEnabled);
        this.m_animalsHandler.SetIsDisabled(!this.m_settings.animalsEnabled);
        this.m_arasakaHandler.SetIsDisabled(!this.m_settings.arasakaEnabled);
        this.m_barghestHandler.SetIsDisabled(!this.m_settings.barghestEnabled);
        this.m_maelStormHandler.SetIsDisabled(!this.m_settings.maelstromEnabled);
        this.m_moxHandler.SetIsDisabled(!this.m_settings.moxEnabled);
        this.m_militechHandler.SetIsDisabled(!this.m_settings.militechEnabled);
        this.m_ncpdHandler.SetIsDisabled(!this.m_settings.ncpdEnabled);
        this.m_scavHandler.SetIsDisabled(!this.m_settings.scavsEnabled);
        this.m_tygerHandler.SetIsDisabled(!this.m_settings.tygerClawsEnabled);
        this.m_valentinosHandler.SetIsDisabled(!this.m_settings.valentinosEnabled);
        this.m_voodooHandler.SetIsDisabled(!this.m_settings.voodooBoysEnabled);
        this.m_wraithsHandler.SetIsDisabled(!this.m_settings.wraithsEnabled);
        this.m_kangTaoHandler.SetIsDisabled(!this.m_settings.kangTaoEnabled);
        this.m_aldecaldosHandler.SetIsDisabled(!this.m_settings.aldecaldosEnabled);
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRReinforcementSystem> {
        let system: ref<GRReinforcementSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.ReinforcementSystem.GRReinforcementSystem") as GRReinforcementSystem;
        return system;
    }

    public func IsAuthorityInterventionCooldownActive() -> Bool {
        return this.m_authorityInterventionCooldownActive;
    }

    public func OnAuthorityInterventionCooldownEnd() -> Void {
        this.m_authorityInterventionCooldownActive = false;
    }

    public func ReinforcementsCalled(puppet: ref<ScriptedPuppet>, target: wref<GameObject>) -> Void {
        let distanceToPlayer = Vector4.Distance(puppet.GetWorldPosition(), GetPlayer(GetGameInstance()).GetWorldPosition());

        if distanceToPlayer > 50.0 {
            return;
        }

        let distanceToTarget = Vector4.Distance(puppet.GetWorldPosition(), target.GetWorldPosition());

        if distanceToTarget > 50.0 {
            return;
        }
        let puppetHandler = this.GetFactionHandler(puppet);
        if !IsDefined(puppetHandler) {
            return;
        }
        let targetPuppet = target as NPCPuppet;
        if !IsDefined(targetPuppet) {
            return;
        }
        puppetHandler.HandleReinforcementCall(puppet as NPCPuppet, targetPuppet);
    }

    private func ReinforcementsChecksCall(puppet: ref<ScriptedPuppet>, target: ref<GameObject>) -> Bool {
        let gi: GameInstance = puppet.GetGame();
        let player = GetPlayer(gi);

        if GameInstance
            .GetBlackboardSystem(gi)
            .GetLocalInstanced(player.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine)
            .GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier) > 1 {
            return false;
        }

        if (!IsDefined(target)) {
            return false;
        }

        if !puppet.IsNPC() || !puppet.IsHuman() {
            return false;
        }

        if player.IsReplacer() || player.IsJohnnyReplacer() {
            return false;
        }

        //No vendors
        if puppet.IsVendor() {
            return false;
        }

        //No kids blackbeard
        if (puppet as NPCPuppet).GetRecord().IsChild() {
            return false;
        }

        if (puppet as NPCPuppet).GetRecord().TagsContains(n"Reinforcements.VoodooMerc") {
            return false;
        }

        if (puppet as NPCPuppet).GetRecord().TagsContains(n"NoReinforcements") {
            return false;
        }

        //Check if NPC is ragdolling
        if (puppet as NPCPuppet).m_isRagdolling {
            return false;
        }

        if !this.m_settings.enabledWhenPlayerInCombat && player.IsInCombat() {
            return false;
        }

        if StatusEffectSystem.ObjectHasStatusEffect(player, t"GameplayRestriction.FistFight") {
            return false;
        }

        let npcRarity = (puppet as NPCPuppet).GetNPCRarity();
        if Equals(npcRarity, gamedataNPCRarity.MaxTac) || Equals(npcRarity, gamedataNPCRarity.Boss) {
            return false;
        }

        let currentDistrict = this.m_preventionSystem.GetCurrentDistrict();
        if !IsDefined(currentDistrict) {
            return false;
        }

        let record = currentDistrict.GetDistrictRecord();
        let nonoZones = [
            "LittleChina_Afterlife",
            "Dogtown_Akebono",
            "Northside_All_Foods",
            "CorpoPlaza_ArasakaTowerAtrium",
            "CorpoPlaza_ArasakaTowerCEOFloor",
            "CorpoPlaza_ArasakaTowerJenkins",
            "CorpoPlaza_ArasakaTowerJungle",
            "CorpoPlaza_ArasakaTowerLobby",
            "CorpoPlaza_ArasakaTowerNest",
            "CorpoPlaza_ArasakaTowerSaburoOffice",
            "CorpoPlaza_ArasakaTowerUnlistedFloors",
            "CorpoPlaza_ArasakaTowerUpperAtrium",
            "ArasakaWaterfront",
            "NorthOaks_Arasaka_Estate",
            "CharterHill_AuCabanon",
            "Coastview_BattysHotel",
            "Dogtown_Brooklyn",
            "Northside_CleanCut",
            "JapanTown_Clouds",
            "CorpoPlaza_Apartment",
            "Dogtown_Cynosure",
            "Vista_del_Rey_Delamain",
            "Dogtown_Expo",
            "JapanTown_FourthWallBdStudio",
            "RanchoCoronado_GunORama",
            "Dogtown_Hideout",
            "JapanTown_HiromisApartment",
            "NorthOaks_Kerry_Estate",
            "Kabuki_LizziesBar",
            "JapanTown_MegabuildingH8",
            "MorroRock",
            "Badlands_Spaceport",
            "MorroRock_NCX",
            "Northside_Apartment",
            "Kabuki_NoTellMotel",
            "LittleChina_Q101Cyberspace",
            "Northside_Totentaz",
            "LittleChina_VApartment",
            "Coastview_VDBChapel",
            "Coastview_VDBMaglev",
            "JapanTown_VR_Tutorial",
            "Northside_WNS"
        ];

        if ArrayContains(nonoZones, record.EnumName()) {
            return false;
        }

        if this.m_questsSystem.GetFact(n"q001_01_go_to_sleep_done") == 0 && this.m_questsSystem.GetFact(n"q005_johnny_chip_acquired") == 0 || this.m_questsSystem.GetFact(n"q115_point_of_no_return") == 1 {
            return false;
        }

        if GameInstance.GetRacingSystem(gi).IsRaceInProgress() {
            return false;
        }

        if !this.m_settings.enabledWhenPlayerIsPassenger && VehicleComponent.IsMountedToVehicle(player.GetGame(), player) {
            let vehicle = player.GetMountedVehicle();
            if IsDefined(vehicle) && vehicle.IsPlayerMounted() && !vehicle.IsPlayerDriver() {
                return false;
            }
        }

        let distanceToTarget = Vector4.Distance(puppet.GetWorldPosition(), target.GetWorldPosition());
        if distanceToTarget > 30.0 {
            return false;
        }
        return true;
    }

    public func GetFactionHandler(puppet: ref<ScriptedPuppet>) -> ref<GRGangHandler> {
        let affiliation = TweakDBInterface
            .GetCharacterRecord(puppet.GetRecordID())
            .Affiliation()
            .Type();
        switch affiliation {
            case gamedataAffiliation.TygerClaws:
                return this.m_tygerHandler;
            case gamedataAffiliation.Scavengers:
                return this.m_scavHandler;
            case gamedataAffiliation.Animals:
                return this.m_animalsHandler;
            case gamedataAffiliation.Maelstrom:
                return this.m_maelStormHandler;
            case gamedataAffiliation.Arasaka:
                return this.m_arasakaHandler;
            case gamedataAffiliation.VoodooBoys:
                return this.m_voodooHandler;
            case gamedataAffiliation.SixthStreet:
                return this.m_sixthHandler;
            case gamedataAffiliation.Militech:
                return this.m_militechHandler;
            case gamedataAffiliation.Valentinos:
                return this.m_valentinosHandler;
            case gamedataAffiliation.Barghest:
                return this.m_barghestHandler;
            case gamedataAffiliation.KangTao:
                return this.m_kangTaoHandler;
            case gamedataAffiliation.Wraiths:
                return this.m_wraithsHandler;
            case gamedataAffiliation.NCPD:
                return this.m_ncpdHandler;
            case gamedataAffiliation.TheMox:
                return this.m_moxHandler;
            case gamedataAffiliation.Aldecaldos:
                return this.m_aldecaldosHandler;
            default:
                return null;
        }
    }

    public func TryCallingReinforcements(puppet: ref<ScriptedPuppet>, target: wref<GameObject>) -> Void {
        if !this.ReinforcementsChecksCall(puppet, target) {
            return;
        }

		// there are a lot of stim events so just randomly throttle our logic
		if RandF() <= 0.1 {
            return;
        }
        
		let puppetHandler = this.GetFactionHandler(puppet);
		if !IsDefined(puppetHandler) {
			return;
		}
		let targetPuppet = target as ScriptedPuppet;
		// guard against friendly fire mistakenly registered as combat pulling in same-faction backup
		if IsDefined(targetPuppet) && this.GetFactionHandler(targetPuppet) == puppetHandler {
			return;
		}

		if puppetHandler.TryCallingReinforcements(puppet) {
			this.ReinforcementsCalled(puppet, target);
		}
    }

    // called by a gang handler's HandleReinforcementCall when its call is strong enough that the law might
    // show up instead of its own backup. Returns true if an authority faction took the call.
    public func TryDispatchAuthority(district: ref<District>, caller: ref<NPCPuppet>, target: ref<NPCPuppet>, callHeat: Int32) -> Bool {
        if !this.m_settings.authorityInterventionEnabled || !IsDefined(target) {
            return false;
        }

        let targetHandler = this.GetFactionHandler(target);
        if !IsDefined(targetHandler) || targetHandler.IsAuthorityFaction() {
            return false;
        }

        let clampedHeat = Min(callHeat, 20);
        if clampedHeat < 2 {
            return false;
        }

        let authorityHandler: ref<GRGangHandler>;
        let authorityHeat: Int32;
        let chanceMin: Int32;
        let chanceMax: Int32;

        if this.m_barghestHandler.IsConsideredTurf(district) {
            authorityHandler = this.m_barghestHandler;
            authorityHeat = clampedHeat * 2;
            chanceMin = 15;
            chanceMax = 50;
        } else if IsDistrictWithinZones(district, ["WestWindEstate", "Coastview"]) {
            authorityHandler = RandRange(0, 101) <= 50 ? this.m_ncpdHandler : this.m_kangTaoHandler;
            authorityHeat = clampedHeat * 2;
            chanceMin = 10;
            chanceMax = 20;
        } else {
            // ncpd, militech, kangtao, and arasaka all claim overlapping turf (CityCenter etc) -
            // gather whoever actually considers this district theirs and pick one at random
            let candidates: array<ref<GRGangHandler>> = [];
            if this.m_ncpdHandler.IsConsideredTurf(district) {
                ArrayPush(candidates, this.m_ncpdHandler);
            }
            if this.m_militechHandler.IsConsideredTurf(district) {
                ArrayPush(candidates, this.m_militechHandler);
            }
            if this.m_kangTaoHandler.IsConsideredTurf(district) {
                ArrayPush(candidates, this.m_kangTaoHandler);
            }
            if this.m_arasakaHandler.IsConsideredTurf(district) {
                ArrayPush(candidates, this.m_arasakaHandler);
            }

            if ArraySize(candidates) == 0 {
                // no claimed authority for this district - fall back to NCPD
                authorityHandler = this.m_ncpdHandler;
            } else {
                authorityHandler = candidates[RandRange(0, ArraySize(candidates) - 1)];
            }
            
            chanceMin = 25;
            chanceMax = 70;
            authorityHeat = clampedHeat * 2;
        }

        authorityHeat = Min(authorityHeat, 5);

        if !authorityHandler.IsAvailableForIntervention() {
            return false;
        }

        // square root curve chance to call the pigs
        let t: Float = Cast<Float>(clampedHeat - 2) / 18.0;
        let chance: Int32 = chanceMin + Cast<Int32>(Cast<Float>(chanceMax - chanceMin) * SqrtF(t));
        if RandRange(0, 101) > chance {
            return false;
        }

        authorityHandler.HandleAuthorityIntervention(caller, target, Min(authorityHeat, 20));

        this.m_authorityInterventionCooldownActive = true;
        this.m_delaySystem.DelayCallback(GRAuthorityInterventionCooldownEndCallback.Create(this), this.m_authorityInterventionCooldownDuration, true);

        return true;
    }
}

public class GRAuthorityInterventionCooldownEndCallback extends DelayCallback {
    let handler: wref<GRReinforcementSystem>;

    public static func Create(handler: ref<GRReinforcementSystem>) -> ref<GRAuthorityInterventionCooldownEndCallback> {
        let self: ref<GRAuthorityInterventionCooldownEndCallback> = new GRAuthorityInterventionCooldownEndCallback();
        self.handler = handler;
        return self;
    }

    public func Call() -> Void {
        if !IsDefined(this.handler) {
            return;
        }
        this.handler.OnAuthorityInterventionCooldownEnd();
    }
}