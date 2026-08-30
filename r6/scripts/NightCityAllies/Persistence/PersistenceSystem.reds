module NightCityAllies.Persistence

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Settings.*
import NightCityAllies.Util.*
       
// 
// Database for persistent mod data
//

public enum ConversationProgressionState {
    Locked = 0,
    Active = 1,
    Finished = 2
}

public enum CompanionSpawnState {
    Invalid = 0,        // mod detected not installed character etc
    Locked = 1,         // for unlock conditions
    Unacquired = 2,     // companions that are not acquired
    Spawned = 3,        // (!) DEPRECATED companions that are not acquired but spawned eg in the afterlife "hire mes" (Unacquired can be spawned)
    Squad = 4,          // companions that are actively following
    Standby = 5,        // companions that are acquired but not spawned
    Roaming = 6,        // (!) DEPRECATED companions that are spawned but not in the squad eg. roaming the city (Standby can roam)
    Unavailable = 7,    // out of town, injured, in a mission, etc - basically any temporary state that would prevent a companion from being in the squad, but they are still acquired and should not be treated as unacquired or locked
    Commuting = 8       // for mercs that are on their way to the player, but haven't arrived yet - basically a temporary state between standby and squad
}

public enum CompanionRarity {
    Common = 0,
    Rare = 1,
    Elite = 2,
    Legendary = 3,
    Special = 4         // never spawns - for non merc chars
}

public enum CompanionType {
    Undefined = 0,
    Regular = 1,
    Mercenary = 2,
    Robot = 3
}

public struct CompanionModData {
    public let isRegistered: Bool;
    public let name: String;
    public let rarity: CompanionRarity;
    public persistent let type: CompanionType; 
    public persistent let recordID: TweakDBID;
    public persistent let spawnState: CompanionSpawnState;
    public persistent let level: Int32;
    public persistent let exp: Int32;
    public persistent let friendship: Int32;
    public persistent let love: Int32;
    public persistent let equippedOutfit: Int32;
    public persistent let currentLocation: CName;
    public persistent let currentSpot: CName;
    public persistent let currentInteractionIndex: Int32;
}

public struct CommpanionOutfit {
    public persistent let companionId: TweakDBID;
    public persistent let tag: CName;
    public persistent let outfitId: Int32;
}

public struct ConversationProgression {
    public persistent let id: CName;
    public persistent let status: ConversationProgressionState;
    public persistent let node: CName;
    public persistent let day: Int32;
    public persistent let hour: Int32;
    public persistent let minute: Int32;
}

public struct StaticModData {
    public persistent let modVersion: Int32;
    //TODO move -> private persistent let lastUpdateDay: Int32;
    //TODO move -> private persistent let lastUpdateHour: Int32;
}

public struct NCATimerData {
    public persistent let id: CName;
    public persistent let timeLeft: Int32;
    public persistent let effect: CName;
    public persistent let subject: TweakDBID;
}

public class PersistenceSystem extends ScriptableSystem {
    public persistent let m_companionRegistry: array<CompanionModData>;
    public persistent let m_conversationRegistry: array<ConversationProgression>;
    public persistent let m_timerRegistry: array<NCATimerData>;
    public persistent let m_companionOutfitRegistry: array<CommpanionOutfit>;
    public persistent let m_staticData: StaticModData;

    public func GetModVersion() -> Int32 {
        return this.m_staticData.modVersion;
    }

    public func SetModVersion(version: Int32) {
        this.m_staticData.modVersion = version;
    }

    public func Invalidate() -> Void {
        let purged: Bool = false;
        let i: Int32 = ArraySize(this.m_companionRegistry) - 1;
        while i >= 0 {
            if (this.IsValid(this.m_companionRegistry[i])) {
                if (Equals(this.m_companionRegistry[i].spawnState, CompanionSpawnState.Invalid)) {
                    this.m_companionRegistry[i].spawnState = CompanionSpawnState.Unacquired;
                    //NCA.CETLog("Re-validated character: ");
                }
            } else {
                //this.m_companionRegistry[i].spawnState = CompanionSpawnState.Invalid;
                ArrayErase(this.m_companionRegistry, i);
                purged = true;
            }
            i -= 1;
        }

        if (purged) {
            NCA.NPC().RefreshCompanionIds();
        }
    }

    public func GetFriendship(recordID: TweakDBID) -> Int32 {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            return this.m_companionRegistry[index].friendship;
        }
        return -1;
    }

    public func GetLove(recordID: TweakDBID) -> Int32 {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            return this.m_companionRegistry[index].love;
        }
        return -1;
    }

    public func AddFriendship(recordID: TweakDBID, value: Int32) -> Void {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            this.m_companionRegistry[index].friendship += value;
            if (this.m_companionRegistry[index].friendship > 100) {
                this.m_companionRegistry[index].friendship = 100;
            }
        }
    }

    public func AddLove(recordID: TweakDBID, value: Int32) -> Void {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            this.m_companionRegistry[index].love += value;
            if (this.m_companionRegistry[index].love > 100) {
                this.m_companionRegistry[index].love = 100;
            }
        }
    }

    // Set counterparts to the Add* pair above, for tooling that edits a value rather than nudging it.
    // Clamped at both ends because the caller is a text field, not gameplay - Add only ever needs the
    // upper bound since nothing in the mod subtracts.
    public func SetFriendship(recordID: TweakDBID, value: Int32) -> Void {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            this.m_companionRegistry[index].friendship = Clamp(value, 0, 100);
        }
    }

    public func SetLove(recordID: TweakDBID, value: Int32) -> Void {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            this.m_companionRegistry[index].love = Clamp(value, 0, 100);
        }
    }

    // Level is derived, never stored independently - AddExp recomputes it the same way. So there is
    // deliberately no SetLevel: setting one would be overwritten by the next exp gain.
    public func SetExp(recordID: TweakDBID, value: Int32) -> Void {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            let exp: Int32 = value < 0 ? 0 : value;
            this.m_companionRegistry[index].exp = exp;
            this.m_companionRegistry[index].level = ExpLogic.GetLevelFromExp(exp);
        }
    }

    public func SetState(record: String, state: String) -> Void {
        this.SetState(TDBID.Create(record), NCA.Util().StringToCompanionSpawnState(state));
    }

    // ⚠ Uniquely named, and it has to stay that way. Both SetState overloads take two arguments, so
    // a Lua caller passing two strings does not reliably reach the String one - the marshaller can
    // just as well pick (TweakDBID, CompanionSpawnState) and convert the state string to an enum
    // itself, which never runs StringToCompanionSpawnState and lands on the wrong state entirely.
    // Returns whether the companion was found, so a caller can tell a no-op from a change.
    public func SetSpawnStateString(record: String, state: String) -> Bool {
        let recordID: TweakDBID = TDBID.Create(record);
        if (this.GetIndex(recordID) < 0) {
            return false;
        }
        this.SetState(recordID, NCA.Util().StringToCompanionSpawnState(state));
        return true;
    }

    public func SetState(recordID: TweakDBID, state: CompanionSpawnState) -> Void {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            this.m_companionRegistry[index].spawnState = state;
            //NCA.CETLog("Set state of " + this.m_companionRegistry[index].name + " to " + ToString(state));
            return;
        }

        NCA.CETLog("ERROR Companion not found for recordID " + TDBID.ToStringDEBUG(recordID) + ", can't set state to " + ToString(state));
    }

    public func SetUnacquired(recordID: TweakDBID) -> Bool {
        let didUnlock: Bool = this.UnlockCharacter(recordID);
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            this.m_companionRegistry[index].spawnState = CompanionSpawnState.Unacquired;
        }
        return didUnlock;
    }

    public func UnlockCharacter(recordID: TweakDBID) -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.m_companionRegistry) {
            if Equals(this.m_companionRegistry[i].recordID, recordID) {
                if !Equals(this.m_companionRegistry[i].spawnState, CompanionSpawnState.Squad)  {
                    this.m_companionRegistry[i].spawnState = CompanionSpawnState.Standby;
                };
                return true;
            }
            i += 1;
        };
        return false;
    }

    public func LockCharacter(record: String) -> Bool {
        return this.LockCharacter(TDBID.Create(record));
    }

    public func LockCharacter(recordID: TweakDBID) -> Bool {
        let i: Int32 = 0;
        while i < ArraySize(this.m_companionRegistry) {
            if Equals(this.m_companionRegistry[i].recordID, recordID) {
                this.m_companionRegistry[i].spawnState = CompanionSpawnState.Locked;
                // TODO despawn if squad? idk.. maybe just make sure it executes before respawns
                // test case: go into heist with jackie as companion, he should not respawn after
                return true;
            };
            i += 1;
        };
        return false;
    }

    public func UnlockAll() -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_companionRegistry) {
            if Equals(this.m_companionRegistry[i].spawnState, CompanionSpawnState.Unacquired)
            || Equals(this.m_companionRegistry[i].spawnState, CompanionSpawnState.Locked) {
                this.m_companionRegistry[i].spawnState = CompanionSpawnState.Standby;
            };
            i += 1;
        };
    }

    private func ResolveRecordDisplayName(record: String) -> String {
        let key: CName = TweakDBInterface.GetLocKey(TDBID.Create(record + ".displayName"), n"");

        if IsNameValid(key) {
            let resolved: String = GetLocalizedTextByKey(key);

            if NotEquals(resolved, "") {
                return resolved;
            }
        }

        //NCA.CETLog("WARNING No displayName on " + record + ", falling back to the record name");
        return record;
    }

    public func RegisterCharacterFromString(record: String, name: String, opt isLocked: Bool, opt appearance: Int32, opt rarity: String, opt type: String) -> Int32 {
        return this.RegisterCharacter(
            TDBID.Create(record), 
            Equals(name, "") ? this.ResolveRecordDisplayName(record) : name,
            isLocked,
            appearance,
            NCA.Util().StringToRarity(rarity),
            NCA.Util().StringToCompanionType(type)
        );
    }

    public func RegisterCharacter(recordID: TweakDBID, name: String, opt isLocked: Bool, opt appearance: Int32, opt rarity: CompanionRarity, opt type: CompanionType) -> Int32 {
        if (!IsDefined(TweakDBInterface.GetCharacterRecord(recordID))) {
            NCA.CETLog("Character record not found: " + ToString(recordID) + " " + name);
            return -1;
        }

        let spawnState: CompanionSpawnState = isLocked ? CompanionSpawnState.Locked : CompanionSpawnState.Unacquired;

        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            this.m_companionRegistry[index].isRegistered = true;
            this.m_companionRegistry[index].name = name; // <- workaround because many npcs have no name
            
            // if the character is locked, make sure the appearance is updated from the config
            if Equals(this.m_companionRegistry[index].spawnState, CompanionSpawnState.Unacquired)
            || Equals(this.m_companionRegistry[index].spawnState, CompanionSpawnState.Locked) {
                this.m_companionRegistry[index].equippedOutfit = appearance;
                this.m_companionRegistry[index].spawnState = spawnState; // <- make sure a char is locked if someone still has a .json
            }

            // TEMP: Set all robots and undefined from merc to standby
            if Equals(this.m_companionRegistry[index].spawnState, CompanionSpawnState.Unacquired)
            && (
                Equals(type, CompanionType.Robot) ||
                Equals(type, CompanionType.Undefined)
            ){
                this.m_companionRegistry[index].spawnState = CompanionSpawnState.Standby;
            }

            this.m_companionRegistry[index].type = type;
            this.m_companionRegistry[index].rarity = rarity;

            return index;
        }

        return this.PushCompanionData(new CompanionModData(
            true,                              // isRegistered
            name,                              // name
            rarity,                            // rarity
            type,                              // type
            recordID,                          // recordID
            spawnState,                        // spawnState
            1,                                 // level
            Cast<Int32>(ExpLogic.GetBaseXP()), // exp
            0,                                 // friendship
            0,                                 // love
            appearance,                        // equippedOutfit
            n"",                               // currentLocation
            n"",                               // currentSpot
            -1                                 // currentInteractionIndex
        ));
    }

    public func RegisterCompanionOutfitString(companionRecord: String, tag: String, outfitId: Int32) -> Void {
        this.RegisterCompanionOutfit(TDBID.Create(companionRecord), StringToName(tag), outfitId);
    }

    public func RegisterCompanionOutfit(companionId: TweakDBID, tag: CName, outfitId: Int32) -> Void {
        if (this.GetIndex(companionId) < 0) {
            NCA.CETLog("ERROR Companion not found for recordID " + TDBID.ToStringDEBUG(companionId) + ", can't register outfit " + IntToString(outfitId));
            return;
        }

        let index: Int32 = this.GetCompanionOutfitIndex(companionId, tag);
        if (index >= 0) {
            //NCA.CETLog("WARNING Companion outfit already registered for companion " + TDBID.ToStringDEBUG(companionId) + " and tag " + NameToString(tag) + ", can't register outfit " + IntToString(outfitId));
            return;
        }

        ArrayPush(this.m_companionOutfitRegistry, new CommpanionOutfit(
            companionId, // companionId
            tag,         // tag
            outfitId     // outfitId
        ));        
    }

    public func ChangeCompanionOutfit(companionId: TweakDBID, tag: CName, outfitId: Int32) -> Void {
        let index: Int32 = this.GetCompanionOutfitIndex(companionId, tag);
        if (index < 0) {
            this.RegisterCompanionOutfit(companionId, tag, outfitId);
            return;
        }

        this.m_companionOutfitRegistry[index].outfitId = outfitId;
    }

    public func GetCompanionOutfitIndex(companionId: TweakDBID, tag: CName) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_companionOutfitRegistry) {
            if Equals(this.m_companionOutfitRegistry[i].companionId, companionId)
            && Equals(this.m_companionOutfitRegistry[i].tag, tag) {
                return i;
            };
            i += 1;
        };
        return -1;
    }

    public func GetCompanionOutfit(companionId: TweakDBID, tag: CName) -> Int32 {
        let index: Int32 = this.GetCompanionOutfitIndex(companionId, tag);
        if (index < 0) {
            return -1;
        }

        return this.m_companionOutfitRegistry[index].outfitId;
    }

    // Reading an outfit without a live NpcHandle, for tooling that has to show a value for a character
    // who is not spawned. -1 for "nothing registered under that tag", same as GetCompanionOutfit.
    public func GetCompanionOutfitString(record: String, tag: String) -> Int32 {
        return this.GetCompanionOutfit(TDBID.Create(record), StringToName(tag));
    }

    public func HasCompanionOutfit(companionId: TweakDBID, tag: CName) -> Bool {
        let index: Int32 = this.GetCompanionOutfitIndex(companionId, tag);
        return index >= 0;
    }

    public func RegisterConversation(id: CName) -> Int32 {
        let index: Int32 = this.GetConversationIndex(id);

        if (index >= 0) {
            return index;
        }

        let data: ConversationProgression = new ConversationProgression(
            id,                                   // id
            ConversationProgressionState.Locked,  // state
            n"start",                             // current node
            0, 0, 0                               // time
        );

        ArrayPush(this.m_conversationRegistry, data);

        return ArraySize(this.m_conversationRegistry) - 1;
    }

    public func PushCompanionData(data: CompanionModData) -> Int32 {
        ArrayPush(this.m_companionRegistry, data);

        return ArraySize(this.m_companionRegistry) - 1;
    }

    // --- Editor support ---------------------------------------------------------------------
    // Read only. todo make editable

    public func GetConversations() -> array<ConversationProgression> {
        return this.m_conversationRegistry;
    }

    public func GetTimers() -> array<NCATimerData> {
        return this.m_timerRegistry;
    }

    public func GetConversationStatus(id: CName) -> ConversationProgressionState {
        let index: Int32 = this.GetConversationIndex(id);
        if (index < 0) {
            return ConversationProgressionState.Locked;
        }
        return this.m_conversationRegistry[index].status;
    }

    // For Invalidate
    public func RemoveConversationsNotIn(known: array<CName>) -> Int32 {
        let dropped: Int32 = 0;

        let i: Int32 = ArraySize(this.m_conversationRegistry) - 1;
        while i >= 0 {
            if !ArrayContains(known, this.m_conversationRegistry[i].id) {
                NCA.CETLog("Dropping conversation " + NameToString(this.m_conversationRegistry[i].id)
                    + " (" + ToString(this.m_conversationRegistry[i].status) + ", node "
                    + NameToString(this.m_conversationRegistry[i].node) + ")");
                ArrayErase(this.m_conversationRegistry, i);
                dropped += 1;
            }
            i -= 1;
        }

        return dropped;
    }

    public func GetConversationIndex(id: CName) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_conversationRegistry) {
            if Equals(this.m_conversationRegistry[i].id, id) {
                return i;
            };
            i += 1;
        };
        return -1;
    }

    public func UnlockConversation(id: CName, opt allowRepeat: Bool) -> Bool {
        let index: Int32 = this.GetConversationIndex(id);
        if (index < 0) {
            NCA.CETLog("ERROR: Conversation not found: " + NameToString(id));
            return false;
        }

        if Equals(this.m_conversationRegistry[index].status, ConversationProgressionState.Finished) {
            if (!allowRepeat || !NCA.Settings().repeatableConversations) {
                return false;
            }
            //NCA.CETLog("ERROR: Conversation can't unlock, already finished: " + NameToString(id));
        }

        if Equals(this.m_conversationRegistry[index].status, ConversationProgressionState.Active) {
            //NCA.CETLog("ERROR: Conversation can't unlock, already active: " + NameToString(id));
            return false;
        }

        this.m_conversationRegistry[index].status = ConversationProgressionState.Active;
        //this.m_conversationRegistry[index].time = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();

        let time: GameTime = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTime();
        this.m_conversationRegistry[index].day = GameTime.Days(time);
        this.m_conversationRegistry[index].hour = GameTime.Hours(time);
        this.m_conversationRegistry[index].minute = GameTime.Minutes(time);

        this.m_conversationRegistry[index].node = n"start";
        //NCA.CETLog("Unlocked Convo " + NameToString(id));
        return true;
    }

    public func LockConversation(id: CName) -> Void {
        let index: Int32 = this.GetConversationIndex(id);
        if (index < 0) {
            NCA.CETLog("ERROR: Conversation not found: " + NameToString(id));
            return;
        }
        //NCA.CETLog("Locked Convo " + NameToString(id));
        this.m_conversationRegistry[index].status = ConversationProgressionState.Locked;
    }

    private func IsValid(companion: CompanionModData) -> Bool {
        let record = TweakDBInterface.GetCharacterRecord(companion.recordID);
        switch (true) {
            case !companion.isRegistered:
                return false;
            
            case !IsDefined(record):
                NCA.CETLog("ERROR: Invalid character record");
                return false;

            case record.IsChild():
            case record.IsLightCrowd():
            case record.IsCrowd():
                NCA.CETLog("ERROR: Unusable npc type");
                return false;

            default:
                return true;
        }
    }

    // --- Editor support ---------------------------------------------------------------------
    //
    // Registering a character already updates one that exists, so adding needs nothing new. These
    // two cover the rest of it.

    // Name, rarity and type only. Deliberately leaves spawnState and all progression alone: those
    // belong to the save, not to the character's declaration.
    public func UpdateCharacterString(record: String, name: String, rarity: String, type: String) -> Bool {
        let index: Int32 = this.GetIndex(TDBID.Create(record));
        if (index < 0) {
            return false;
        }

        this.m_companionRegistry[index].name = name;
        this.m_companionRegistry[index].rarity = NCA.Util().StringToRarity(rarity);
        this.m_companionRegistry[index].type = NCA.Util().StringToCompanionType(type);
        return true;
    }

    // Companion progression for tooling, in the same shape as UpdateCharacterString: one call taking
    // a record string, because Lua cannot build a TweakDBID. Level is not a parameter - SetExp derives
    // it. Returns whether the companion was found, so a caller can tell a no-op from a change.
    public func UpdateProgressionString(record: String, exp: Int32, friendship: Int32, love: Int32) -> Bool {
        let recordID: TweakDBID = TDBID.Create(record);
        if (this.GetIndex(recordID) < 0) {
            return false;
        }

        this.SetExp(recordID, exp);
        this.SetFriendship(recordID, friendship);
        this.SetLove(recordID, love);
        return true;
    }

    // ⚠ There is deliberately no RemoveCharacter. Erasing shifts every index after it, and the index
    // is cached in NpcHandle.m_companionId - and, since this mod is a dependency for others, quite
    // possibly outside this project too. Nothing here can refresh a consumer it does not know about,
    // so a mid-session erase would break them silently. Registry entries are added, never removed;
    // a character leaves play by module or by spawn state.

    public func GetIndex(id: TweakDBID) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.m_companionRegistry) {
            if Equals(this.m_companionRegistry[i].recordID, id) {
                return i;
            };
            i += 1;
        };
        return -1;
    }

    public func GetCompanions() -> array<CompanionModData> { 
        return this.m_companionRegistry;
    }

    public func GetStandbyCompanions() -> array<CompanionModData> {
        if (NCA.Settings().unlockAll) {
            return this.GetCompanions();
        }

        return this.GetCompanionsBySpawnState(CompanionSpawnState.Standby);
    }

    public func GetUnacquiredCompanions() -> array<CompanionModData> {
        return this.GetCompanionsBySpawnState(CompanionSpawnState.Unacquired);
    }

    public func GetSquadCompanions() -> array<CompanionModData> {
        return this.GetCompanionsBySpawnState(CompanionSpawnState.Squad);
    }

    public func GetSpawnedCompanions() -> array<CompanionModData> {
        return this.GetCompanionsBySpawnState(CompanionSpawnState.Spawned);
    }

    public func GetCommutingCompanions() -> array<CompanionModData> {
        return this.GetCompanionsBySpawnState(CompanionSpawnState.Commuting);
    }

    public func GetUnavailableCompanions() -> array<CompanionModData> {
        return this.GetCompanionsBySpawnState(CompanionSpawnState.Unavailable);
    }

    public func GetCompanionsBySpawnState(state: CompanionSpawnState) -> array<CompanionModData> {
        let result: array<CompanionModData>;
        let i: Int32 = 0;

        while i < ArraySize(this.m_companionRegistry) {
            if Equals(this.m_companionRegistry[i].spawnState, state) {
                ArrayPush(result, this.m_companionRegistry[i]);
            };
            i += 1;
        };
        
        return result;
    }

    public func GetCompanionsByLocation(location: CName) -> array<CompanionModData> {
        let result: array<CompanionModData>;
        let i: Int32 = 0;

        while i < ArraySize(this.m_companionRegistry) {
            if Equals(this.m_companionRegistry[i].currentLocation, location) {
                ArrayPush(result, this.m_companionRegistry[i]);
            };
            i += 1;
        };
        
        return result;
    }

    public func GetCompanionName(recordID: TweakDBID) -> String {
        let index: Int32 = this.GetIndex(recordID);
        if (index >= 0) {
            return this.m_companionRegistry[index].name;
        }
        return "";
    }
    
    public func ClearAllSpawnLocations() -> Void { 
        let i: Int32 = 0;
        while i < ArraySize(this.m_companionRegistry) {
            this.m_companionRegistry[i].currentLocation = n"";
            this.m_companionRegistry[i].currentSpot = n"";
            this.m_companionRegistry[i].currentInteractionIndex = -1;
            i += 1;
        };
    }

    public func ClearUnacquiredSpawnLocations() -> Void { 
        let i: Int32 = 0;
        while i < ArraySize(this.m_companionRegistry) {
            if Equals(this.m_companionRegistry[i].spawnState, CompanionSpawnState.Unacquired) {
                this.m_companionRegistry[i].currentLocation = n"";
                this.m_companionRegistry[i].currentSpot = n"";
                this.m_companionRegistry[i].currentInteractionIndex = -1;
            };
            i += 1;
        };
    }

    public func ClearSpawnLocation(id: TweakDBID) -> Void { 
        this.AssignSpawnLocation(id, n"", n"");
    }

    public func AssignSpawnLocation(id: TweakDBID, location: CName, spot: CName) -> Void {
        let index: Int32 = this.GetIndex(id);
        if index >= 0 {
            this.m_companionRegistry[index].currentLocation = location;
            this.m_companionRegistry[index].currentSpot = spot;
            this.m_companionRegistry[index].currentInteractionIndex = -1;
            //NCA.CETLog("   -> " + NameToString(spot) + " -> " + this.m_companionRegistry[index].name);
        };
    }

    public func Reset() {
        ArrayClear(this.m_companionRegistry);
        ArrayClear(this.m_conversationRegistry);
    }

    public func Dump() -> Void {
        this.DumpConversations();
        this.DumpCompanions();
        this.DumpTimers();
    }

    public func DumpCompanions() -> Void {
        let i: Int32 = 0;
        let count: Int32 = ArraySize(this.m_companionRegistry);
        let e: CompanionModData;
        let stateStr: String;

        NCA.CETLog("==== Companion Dump (" + IntToString(count) + ") ====");
        while i < count {
            //this.CETDump(this.m_companionRegistry[i])^;
            e = this.m_companionRegistry[i];

            NCA.CETLog(
                "[" + IntToString(i) + "] " +
                e.name +
                " - " + TDBID.ToStringDEBUG(e.recordID) +
                " - " + ToString(e.spawnState) +
                " " + ToString(e.rarity) +
                " " + ToString(e.type) +
                "   // Lvl " + IntToString(e.level) +
                " - Exp " + IntToString(e.exp) +
                " - Fri " + IntToString(e.friendship) +
                " - Lov " + IntToString(e.friendship) +
                " - Spt " + ToString(e.currentSpot)
            );

            i += 1;
        };
    }

    private func DumpConversations() -> Void {
        let i: Int32 = 0;
        let count: Int32 = ArraySize(this.m_conversationRegistry);
        let e: ConversationProgression;
        let stateStr: String;

        NCA.CETLog("==== Conversations Dump (" + IntToString(count) + ") ====");
        while i < count {
            //this.CETDump(this.m_companionRegistry[i])^;
            e = this.m_conversationRegistry[i];

            NCA.CETLog(
                "[" + IntToString(i) + "] " +
                NameToString(e.id) +
                " - " + NameToString(e.node) +
                " - " + ToString(e.status)
            );

            i += 1;
        };
    }

    private func DumpTimers() -> Void {
        let i: Int32 = 0;
        let count: Int32 = ArraySize(this.m_timerRegistry);
        let e: NCATimerData;

        NCA.CETLog("==== Timers Dump (" + IntToString(count) + ") ====");
        while i < count {
            e = this.m_timerRegistry[i];

            NCA.CETLog(
                "[" + IntToString(i) + "] " +
                NameToString(e.id) +
                " - " + ToString(e.timeLeft) +
                " - " + NameToString(e.effect) +
                " - " + TDBID.ToStringDEBUG(e.subject)
            );

            i += 1;
        };
    }

    public func CETDump(data: CompanionModData) {}
}
