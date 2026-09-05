module NightCityAllies.Event

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.UI.*
import NightCityAllies.UI.Interactions.*
import NightCityAllies.Npc.*
import NightCityAllies.Spawn.*
import NightCityAllies.Event.Hooks.*
import NightCityAllies.Migration.*
import NightCityAllies.Phone.*
import NightCityAllies.Util.*
import NightCityAllies.Location.*
import NightCityAllies.Timer.*
import NightCityAllies.Effect.*
import NightCityAllies.Settings.*

public class EventBus extends ScriptableSystem {
    public final func OnChangeDistrict(district: gamedataDistrict) -> Void {
        NCA.Location().CheckLocationChange();
    }
    public final func OnEnterApartment(location: gamedataDistrict) -> Void {}
    public final func OnExitApartment(location: gamedataDistrict) -> Void {}
    public final func OnEnterLocation(location: ref<NCALocation>) -> Void {
        NCA.Context().location = location.tag;

        NCA.NPC().SpawnLocationCharacters(location);

        //set explore for all squad members
        let squad: array<ref<NpcHandle>> = NCA.NPC().GetSquad();
        let i: Int32 = 0;
        while i < ArraySize(squad) {
            squad[i].currentArea = n"";
            squad[i].SetExploreLocationBehavior(location);
            i += 1;
        };
    }
    public final func OnExitLocation(location: ref<NCALocation>) -> Void {
        NCA.Context().location = n"";

        let squad: array<ref<NpcHandle>> = NCA.NPC().GetSquad();
        let i: Int32 = 0;
        while i < ArraySize(squad) {
            squad[i].DetermineBehavior();
            i += 1;
        };

        NCA.NPC().DespawnLocationCharacters(location);
    }
    public final func OnEnterElevator() -> Void {
        let squad: array<ref<NpcHandle>> = NCA.NPC().GetSquad();
        let i: Int32 = 0;
        while i < ArraySize(squad) {
            squad[i].SetElevatorBehavior();
            i += 1;
        };
    }
    public final func OnExitElevator() -> Void {
        let squad: array<ref<NpcHandle>> = NCA.NPC().GetSquad();
        let i: Int32 = 0;
        while i < ArraySize(squad) {
            squad[i].DetermineBehavior();
            i += 1;
        };
    }
    public final func OnSpawnReroll() -> Void {
        NCA.Spawn().Reroll();
    }
    public final func OnCombatStart() -> Void {
        NCA.Damage().StartCombat();
        NCA.UI().RefreshVisibility();

        let squad: array<ref<NpcHandle>> = NCA.NPC().GetSquad();
        let i: Int32 = 0;
        while i < ArraySize(squad) {
            squad[i].SetCombatBehavior();
            i += 1;
        };
    }
    public final func OnCombatEnd() -> Void {
        NCA.Damage().StopCombat();
        NCA.UI().RefreshVisibility();

        let combatExp: Float = Cast<Float>(NCA.Damage().ConsumeCombatExp());
        let squad: array<ref<NpcHandle>> = NCA.NPC().GetSquad();
        let squadSize: Int32 = ArraySize(squad);
        if squadSize <= 0 {
            return;
        }

        let totalDamage: Float = NCA.Damage().GetTotalSquadDamage();
        let baseExp: Float = combatExp * NCAConstants.CombatExpBaseRate();
        let contributionPool: Float = combatExp * NCAConstants.CombatExpContributionRate();

        let i: Int32 = 0;
        while i < squadSize {
            let share: Float = 0.0;
            if totalDamage > 0.0 {
                let stats: SquadDamageStats = NCA.Damage().GetStats(squad[i]);
                share = stats.totalDamage / totalDamage;
            }

            squad[i].AddExp(Cast<Int32>(baseExp + contributionPool * share));
            squad[i].ApplyLevel(); // scale to the new level
            squad[i].DetermineBehavior(); // back into the seat when in a car, see NpcHandle
            i += 1;
        }; // works while out of car companions are despawned, check if changing it
    }
    public final func OnCompanionDeath(npc: ref<NpcHandle>) -> Void {
        NCA.NPC().RemoveHandle(npc);
        npc.Despawn(); // TODO after timer

		NCA.Persistence().SetState(npc.GetRecordID(), CompanionSpawnState.Unavailable);
        NCA.Timer().StartTimer(StringToName(npc.GetName() + "_deathTimer"), 0, 2, 30, n"revive_after_death", npc.GetRecordID());
        //NCA.CETLog("Companion " + npc.GetName() + " died, starting revive timer");
    }
    public final func OnCompanionDealDamage(npc: ref<NpcHandle>, evt: ref<gameHitEvent>) -> Void {
        NCA.Damage().RecordHit(npc, evt);
        let stats: SquadDamageStats = NCA.Damage().GetStats(npc);
        npc.OnDealDamage(stats); // the damage itself only pays out at combat end, see OnCombatEnd
    }
    public final func OnCompanionTakeDamage(npc: ref<NpcHandle>, evt: ref<gameHitEvent>) -> Void {
        //NCA.Damage().RecordHit(npc, evt);
        let stats: SquadDamageStats = NCA.Damage().GetStats(npc);
        npc.OnTakeDamage(stats); // stub.
    }
    public final func OnQuestStart() -> Void {}
    public final func OnQuestComplete() -> Void {}
    public final func OnEnterVehicle(vehicle: ref<VehicleObject>) -> Void {
        NCA.Context().vehicle = vehicle;
        NCA.NPC().EnterVehicle(vehicle);
    }
    public final func OnExitVehicle(vehicle: ref<VehicleObject>) -> Void {
        NCA.NPC().RespawnAll();
        NCA.NPC().ExitVehicle(vehicle);
        NCA.Context().vehicle = null;
    }
    public final func OnContextChange(context: ref<ContextSystem>) -> Void {}
    public final func OnFastTravelStart() -> Void {
        NCA.NPC().DespawnAll(true);
    }
    public final func OnFastTravelComplete() -> Void {
        if (NCA.Context().isRestrictedTier) {
            return;
        }

        if (NCA.Context().isInCar) {
            NCA.NPC().RespawnInVehicle();
        } else {
            NCA.NPC().RespawnAll();
        }
    }
    public final func OnSessionStart() -> Void {
        Migrations.Run();
        NCA.Persistence().Invalidate();
        NCA.Phone().InvalidateConversations();

        if (!NCA.Context().isRestrictedTier) {
            if (NCA.Context().isInCar) {
                NCA.NPC().RespawnInVehicle();
            } else {
                NCA.NPC().RespawnAll();
            }
        }

        NCA.UI().ActivateWidgetsAfterSessionStart();
        NCA.UI().Open();
        BlackboardListeners.Register();

        // add default effects
        NCA.Effect().RegisterEffect(NCAReviveEffect.Create(n"revive_after_death"));
        NCA.Effect().RegisterEffect(NCACommuteCompleteEffect.Create(n"commute_complete"));
        NCA.Effect().RegisterEffect(NCAChangeOutfitEffect.Create(n"change_outfit"));
        NCA.Effect().RegisterEffect(NCASpawnEffect.Create(n"spawn"));
        NCA.Effect().RegisterEffect(NCACommuteEffect.Create(n"commute"));
        NCA.Effect().RegisterEffect(NCAUnlockCharacterEffect.Create(n"unlock"));
        NCA.Effect().RegisterEffect(NCAMakeHireableEffect.Create(n"unlock_merc"));
        NCA.Effect().RegisterEffect(NCAAddFriendshipEffect.Create(n"friendship+", 3));
        NCA.Effect().RegisterEffect(NCAAddFriendshipEffect.Create(n"friendship++", 15));
        NCA.Effect().RegisterEffect(NCAAddFriendshipEffect.Create(n"friendship+++", 50));
        NCA.Effect().RegisterEffect(NCAAddFriendshipEffect.Create(n"friendship-", -3));
        NCA.Effect().RegisterEffect(NCAAddFriendshipEffect.Create(n"friendship--", -15));
        NCA.Effect().RegisterEffect(NCAAddFriendshipEffect.Create(n"friendship---", -50));
        NCA.Effect().RegisterEffect(NCAAddLoveEffect.Create(n"love+", 3));
        NCA.Effect().RegisterEffect(NCAAddLoveEffect.Create(n"love++", 15));
        NCA.Effect().RegisterEffect(NCAAddLoveEffect.Create(n"love+++", 50));
        NCA.Effect().RegisterEffect(NCAAddLoveEffect.Create(n"love-", -3));
        NCA.Effect().RegisterEffect(NCAAddLoveEffect.Create(n"love--", -15));
        NCA.Effect().RegisterEffect(NCAAddLoveEffect.Create(n"love---", -50));

        // add interaction menu entries
        NCA.InteractionMenu().ClearEntries();
        NCA.InteractionMenu().RegisterEntry(new NCAHireEntry());
        //NCA.InteractionMenu().RegisterEntry(new NCAGreetEntry()); // TODO social submenu
        NCA.InteractionMenu().RegisterEntry(new NCARoutineEntry());
        NCA.InteractionMenu().RegisterEntry(new NCAJoinSquadEntry());
        NCA.InteractionMenu().RegisterEntry(new NCAFollowEntry());
        NCA.InteractionMenu().RegisterEntry(new NCAHoldPositionEntry());
        NCA.InteractionMenu().RegisterEntry(new NCAStayHereEntry());
        NCA.InteractionMenu().RegisterEntry(new NCAEquipEntry());
        NCA.InteractionMenu().RegisterEntry(new NCAEquipmentPanelEntry());
        NCA.InteractionMenu().RegisterEntry(new NCASendAwayEntry());

        // detect active location
        NCA.Location().RestoreLocationAfterLoad();

        // start timers
        TimeListeners.Get().Start();

        // Force questlock check for newly installed chars
        this.OnQuestComplete();
    }

    public final func OnTick(deltaTime: Float) -> Void {
        NCA.Location().CheckOnTick();
        NCA.NPC().Tick(deltaTime);
        NCA.UI().RefreshSquadHeader(); // TODO this can be event driven
        NCA.InteractionMenu().OnTick();
    }

    public final func OnDayPassed() -> Void {
    }

    public final func OnHourPassed() -> Void {
        if (NCA.Context().hour % NCA.Settings().mercRespawnTime == 0) { // 0, 6, 12, 18 - ignored when using timeskip
            NCA.Events().OnSpawnReroll();
        }
    }
    public final func OnConversationFinished(id: CName) -> Void {}
    public final func OnMinutePassed() -> Void {
        NCA.Phone().TriggerRandomConversation();
        NCA.Timer().TickTimers(1);
    }
    public final func OnTimeSkip(minutes: Int32) {
        NCA.Events().OnSpawnReroll(); // TODO check 6h
        NCA.Phone().TriggerRandomConversation();
        NCA.Phone().TriggerRandomConversation();
        NCA.Timer().TickTimers(minutes);
    }
    public final func OnSessionEnd() -> Void {
        NCA.NPC().DespawnAll(true); // game does it anyways
        BlackboardListeners.Unregister();
        TimeListeners.Get().Stop();
    }
    public final func OnEnterMenu() -> Void {
        NCA.UI().Close();
    }
    public final func OnExitMenu() -> Void {
        NCA.UI().Open();
    }
    public final func OnCompanionMounted(npc: ref<NpcHandle>, seat: CName) -> Void {
        if (NCA.Context().isInCombat) {
            npc.SetCombatBehavior();
        }
    }
    public final func OnCompanionJoinSquad(npc: ref<NpcHandle>) -> Void {}
    public final func OnCompanionLeaveSquad(npc: ref<NpcHandle>) -> Void {}
    public final func OnCompanionStateChanged(npc: ref<NpcHandle>) -> Void {
        NCA.InteractionMenu().RefreshFor(npc);
    }
    // Lua cb
    public final func OnBuildInteractionMenu(npc: ref<NpcHandle>, token: Int32) -> Void {}
    public final func OnLuaInteractionSelected(npc: ref<NpcHandle>, id: Int32) -> Void {}
    public final func OnCompanionEnterProximity(npc: ref<NpcHandle>) -> Void {
        npc.playerProximity = true;
        NCA.InteractionMenu().OnProximityChanged(npc);
    }
    public final func OnCompanionExitProximity(npc: ref<NpcHandle>) -> Void {
        npc.playerProximity = false;
        NCA.InteractionMenu().OnProximityChanged(npc);
    }
    public final func OnLookAtCompanion(npc: ref<NpcHandle>) -> Void {
        NCA.InteractionMenu().OnLookAtChanged(npc);
    }
    public final func OnLookAtCompanionEnd(npc: ref<NpcHandle>) -> Void {
        NCA.InteractionMenu().OnLookAtChanged(null);
    }
    public final func OnEnterRestrictedTier() -> Void {
        NCA.NPC().DespawnAll(true);
    }
    public final func OnExitRestrictedTier() -> Void {
        if (!NCA.Context().isInCar) {
            NCA.NPC().RespawnAll();
        }
    }
}
