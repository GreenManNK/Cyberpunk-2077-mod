module NightCityAllies.Migration

import NightCityAllies.*
import NightCityAllies.Event.Hooks.*
import NightCityAllies.Event.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.*
import NightCityAllies.Spawn.*
import NightCityAllies.Phone.*

// Helpers for updating to a newer mod version
// (!) Never delete migrations
public class V1_1_0 extends Migration {
    public func Run() -> Void {
        // Trigger spawn reroll
        TimeListeners.Get().Update();  
    }
}

public class V1_2_0 extends Migration {
    public func Run() -> Void {
        // Set all companions to base exp
        let i: Int32 = 0;
        while i < ArraySize(NCA.Persistence().m_companionRegistry) {
            NCA.Persistence().m_companionRegistry[i].exp = Cast<Int32>(ExpLogic.GetBaseXP());
            i += 1;
        }

        // Reroll spawns for new spawn locations
        NCA.Spawn().Reroll();
    }
}

public class V1_3_0 extends Migration {
    public func Run() -> Void {
        // Trigger quest unlock checks
        NCA.Events().OnQuestComplete();
    }
}

public class V1_3_4 extends Migration {
    public func Run() -> Void {
        let ps: ref<PersistenceSystem> = NCA.Persistence();
        let i: Int32 = 0;
        while i < ArraySize(ps.m_companionRegistry) {
            // pack chars that are not defined as merc become standby
            if (Equals(ps.m_companionRegistry[i].spawnState, CompanionSpawnState.Unacquired) 
            || Equals(ps.m_companionRegistry[i].spawnState, CompanionSpawnState.Spawned))
            && Equals(ps.m_companionRegistry[i].type, CompanionType.Undefined) {
                ps.m_companionRegistry[i].spawnState = CompanionSpawnState.Standby;
            }
            i += 1;
        }

    }
}

public class V1_4_4 extends Migration {
    // Up to 1.4.3 finishing an unlock conversation did not actually unlock the character:
    // the ConversationFinished handler in init.lua compared a CName against a Lua String, which is
    // never equal, so NCA:UnlockCharacter() was never reached. Players who declined the immediate
    // "commute" option were left with a finished conversation and a permanently locked character.
    //
    // Repair those saves: a finished unlock conversation means the character was earned.
    // Only Locked is touched - every other spawn state is left exactly as it is.
    //
    // Any finished conversation counts as an unlock conversation here, which is safe because a
    // conversation can only be triggered while the character is Standby (= already unlocked), or
    // while Locked if its trigger has allowForLocked - and only unlock conversations get that, via
    // NCA:UnlockConversation. So "finished conversation + still Locked" can only mean the unlock
    // never applied.
    // (!) If a conversation is ever added that can be finished BEFORE its character is unlocked
    // (allowLocked = true on NCA:SetConversationTrigger, or NCA:UnlockConversation(id, true)), this
    // would unlock that character by mistake and the migration needs an explicit unlock-conversation
    // flag instead.
    //
    // Characters that are supposed to be locked again by a quest (currently only Jackie, after the
    // Heist) are re-locked by the OnQuestComplete() pass at the end of EventBus.OnSessionStart,
    // which runs after Migrations.Run() in the same session start.
    public func Run() -> Void {
        let ps: ref<PersistenceSystem> = NCA.Persistence();
        let recordID: TweakDBID;
        let repaired: Int32 = 0;

        let i: Int32 = 0;
        while i < ArraySize(ps.m_conversationRegistry) {
            if Equals(ps.m_conversationRegistry[i].status, ConversationProgressionState.Finished) {
                if NCA.Phone().FindCompanionForConversation(ps.m_conversationRegistry[i].id, recordID) {
                    let index: Int32 = ps.GetIndex(recordID);
                    if index >= 0 {
                        if Equals(ps.m_companionRegistry[index].spawnState, CompanionSpawnState.Locked) {
                            ps.m_companionRegistry[index].spawnState = CompanionSpawnState.Standby;
                            repaired += 1;
                            NCA.CETLog("[NCA] V1.4.4: unlocked " + ps.m_companionRegistry[index].name
                                + " (finished conversation " + NameToString(ps.m_conversationRegistry[i].id) + ")");
                        }
                    }
                }
            }
            i += 1;
        }

        NCA.CETLog("[Update] V1.4.4: checked " + IntToString(ArraySize(ps.m_conversationRegistry))
            + " conversations, unlocked " + IntToString(repaired) + " character(s)");
    }
}

public class V1_5_0 extends Migration {
    public func Run() -> Void {
        let ps: ref<PersistenceSystem> = NCA.Persistence();
        let renamed: Int32 = 0;

        let i: Int32 = 0;
        while i < ArraySize(ps.m_timerRegistry) {
            if Equals(ps.m_timerRegistry[i].effect, n"nca_commute_complete") {
                ps.m_timerRegistry[i].effect = n"commute_complete";
                renamed += 1;
            } else if Equals(ps.m_timerRegistry[i].effect, n"nca_revive_after_death") {
                ps.m_timerRegistry[i].effect = n"revive_after_death";
                renamed += 1;
            } else if Equals(ps.m_timerRegistry[i].effect, n"nca_change_outfit") {
                ps.m_timerRegistry[i].effect = n"change_outfit";
                renamed += 1;
            }
            i += 1;
        }

        NCA.CETLog("[Update] V1.5.0: checked " + IntToString(ArraySize(ps.m_timerRegistry)) + " timers, renamed " + IntToString(renamed) + " effect(s)");
    }
}

public abstract class Migration {
    public func Run() -> Void;
}

public class Migrations {
    private static func GetMigrations() -> array<ref<Migration>> {
        return [
            new V1_1_0(),
            new V1_2_0(),
            new V1_3_0(),
            new V1_3_4(),
            new V1_4_4(),
            new V1_5_0()
        ];
    }

	public static func Run() -> Void {
        let migrations = Migrations.GetMigrations();
        let current: Int32 = NCA.Persistence().GetModVersion();
        let target: Int32 = ArraySize(migrations);
        while current < target {
            migrations[current].Run();
            current += 1;
            //NCA.CETLog("Migration version: " + ToString(current));
        }
        //NCA.Persistence().SetModVersion(current);
        NCA.Persistence().SetModVersion(target); // store the actual version not highest
	}
}