// Repeatable Increased Criminal Activity v0.1.4-alpha
// Standalone replay system for Phantom Liberty's three world strongholds.
// Safety contract: read original completion facts only. Never write/reset a
// vanilla fact, invoke a quest phase, change a journal entry, touch original
// containers, or mutate the separate post-completion communities.

public enum RICAStatus {
  Cooldown = 0,
  Active = 1,
  Disabled = 2
}

public struct RICASiteState {
  public let siteID: String;
  public let status: RICAStatus;
  public let lastClearedAt: Int32;
  public let cycle: Int32;
  public let ownedActivation: Bool;
  public let vanillaEligible: Bool;
  public let cleanupReadyAt: Int32;
  public let enabled: Bool;
  public let cooldownOverrideHours: Float;
  public let rosterPercentAtActivation: Int32;
  public let reinforcementsAtActivation: Bool;
}

public struct RICAPendingReward {
  public let serial: Int32;
  public let siteID: String;
  public let cycle: Int32;
}

public class RICACommunityAction {
  public let spawner: String;
  public let entry: CName;
  public let phase: CName;
  public let boss: Bool;
  public let reinforcement: Bool;

  public static func New(
    spawner: String,
    entry: CName,
    phase: CName,
    boss: Bool,
    reinforcement: Bool
  ) -> ref<RICACommunityAction> {
    let action: ref<RICACommunityAction> = new RICACommunityAction();
    action.spawner = spawner;
    action.entry = entry;
    action.phase = phase;
    action.boss = boss;
    action.reinforcement = reinforcement;
    return action;
  }
}

public class RICACommunityRuntime {
  public let siteID: String;
  public let spawnerID: EntityID;
}

public class RICAActorRuntime {
  public let siteID: String;
  public let actorID: EntityID;
  public let boss: Bool;
  public let bodyRewarded: Bool;
}

public abstract class RICADatabase {
  public static func SiteIDs() -> array<String> {
    return ["we_ep1_01", "we_ep1_05", "we_ep1_17"];
  }

  public static func FinishedFact(siteID: String) -> String {
    switch siteID {
      case "we_ep1_01": return "we_ep1_01_finished";
      case "we_ep1_05": return "we_ep1_05_finished";
      case "we_ep1_17": return "we_ep1_17_finished";
    };
    return "";
  }

  public static func BossRecord(siteID: String) -> TweakDBID {
    switch siteID {
      case "we_ep1_01": return t"Character.we_ep1_01_mini_boss_2nd_phase";
      case "we_ep1_05": return t"Character.we_ep1_05_mini_boss";
      case "we_ep1_17": return t"Character.we_ep1_17_miniboss";
    };
    let empty: TweakDBID;
    return empty;
  }

  public static func Position(siteID: String) -> Vector4 {
    switch siteID {
      case "we_ep1_01": return new Vector4(-2429.64, -2365.81, 10.95, 1.0);
      case "we_ep1_05": return new Vector4(-1418.849, -2642.115, 83.71233, 1.0);
      case "we_ep1_17": return new Vector4(-2263.553, -2917.408, 117.47, 1.0);
    };
    return new Vector4(0.0, 0.0, 0.0, 0.0);
  }

  public static func Actions(siteID: String) -> array<ref<RICACommunityAction>> {
    switch siteID {
      case "we_ep1_01":
        return [
          RICACommunityAction.New("#we_ep1_01_boss_2nd_phase_com", n"boss", n"default", true, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_001", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_003", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_005", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_006", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_007", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_008", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_011", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_012", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_014", n"default", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_018", n"a", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_021", n"a", false, false),
          RICACommunityAction.New("#we_ep1_01_combat_com_1st_loop", n"enemy_022", n"default", false, false)
        ];
      case "we_ep1_05":
        return [
          RICACommunityAction.New("#we_ep1_05_com", n"boss", n"default", true, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_001", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_002", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_003", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_005", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_006", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_007", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_008", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_009", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_010", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_011", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_012", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_014", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"enemy_017", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com", n"netrunner", n"default", false, false),
          RICACommunityAction.New("#we_ep1_05_com_reinf", n"drone_01", n"a", false, true),
          RICACommunityAction.New("#we_ep1_05_com_reinf", n"drone_02", n"a", false, true),
          RICACommunityAction.New("#we_ep1_05_com_reinf", n"netrunner", n"a", false, true)
        ];
      case "we_ep1_17":
        return [
          RICACommunityAction.New("#we_ep1_17_com", n"boss_drone", n"a", true, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_01", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_02", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_03", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_04", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_05", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_06", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_07", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_08", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_09", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_10", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_11", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_12", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_13", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_14", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_15", n"a", false, false),
          RICACommunityAction.New("#we_ep1_17_com", n"enemy_16", n"a", false, false)
        ];
    };
    return [];
  }
}

public class RepeatableIncreasedCriminalActivitySystem extends ScriptableSystem {
  private persistent let m_schemaVersion: Int32;
  private persistent let m_enabled: Bool;
  private persistent let m_poolSize: Int32;
  private persistent let m_cooldownHours: Float;
  private persistent let m_rosterPercent: Int32;
  private persistent let m_reinforcements: Bool;
  private persistent let m_cleanupSeconds: Int32;
  private persistent let m_cleanupDistance: Float;
  private persistent let m_heightenedAwareness: Bool;
  private persistent let m_selectionCursor: Int32;
  private persistent let m_totalClears: Int32;
  private persistent let m_rewardSerial: Int32;
  private persistent let m_pendingRewards: array<RICAPendingReward>;
  private persistent let m_states: array<RICASiteState>;

  private persistent let m_regularHealth: Float;
  private persistent let m_regularDamage: Float;
  private persistent let m_regularArmor: Float;
  private persistent let m_regularQuickhack: Float;
  private persistent let m_bossHealth: Float;
  private persistent let m_bossDamage: Float;
  private persistent let m_bossArmor: Float;
  private persistent let m_bossQuickhack: Float;
  private persistent let m_growthPerClear: Float;
  private persistent let m_growthCap: Int32;

  private let m_communities: array<ref<RICACommunityRuntime>>;
  private let m_actors: array<ref<RICAActorRuntime>>;
  private let m_changeMappinColor: Bool;

  public static func GetInstance(game: GameInstance) -> ref<RepeatableIncreasedCriminalActivitySystem> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(
      n"RepeatableIncreasedCriminalActivitySystem"
    ) as RepeatableIncreasedCriminalActivitySystem;
  }

  private func OnAttach() -> Void {
    this.EnsureState();
    this.RebuildRuntimeCommunityMap();
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    this.EnsureState();
    this.RebuildRuntimeCommunityMap();
    this.Tick();
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    ArrayClear(this.m_actors);
  }

  private func EnsureState() -> Void {
    let freshState: Bool = this.m_schemaVersion <= 0;
    if this.m_schemaVersion <= 0 {
      this.m_schemaVersion = 1;
      this.m_enabled = true;
      this.m_poolSize = 1;
      this.m_cooldownHours = 36.0;
      this.m_rosterPercent = 75;
      this.m_reinforcements = true;
      this.m_cleanupSeconds = 120;
      this.m_cleanupDistance = 150.0;
      this.m_heightenedAwareness = true;
      this.m_regularHealth = 1.15;
      this.m_regularDamage = 1.10;
      this.m_regularArmor = 1.00;
      this.m_regularQuickhack = 1.00;
      this.m_bossHealth = 1.50;
      this.m_bossDamage = 1.25;
      this.m_bossArmor = 1.10;
      this.m_bossQuickhack = 1.10;
      this.m_growthPerClear = 0.0;
      this.m_growthCap = 20;
    };

    if ArraySize(this.m_states) == 0 {
      for id in RICADatabase.SiteIDs() {
        let state: RICASiteState;
        state.siteID = id;
        state.status = RICAStatus.Disabled;
        state.lastClearedAt = 0;
        state.cycle = 0;
        state.ownedActivation = false;
        state.vanillaEligible = false;
        state.cleanupReadyAt = 0;
        state.enabled = true;
        state.cooldownOverrideHours = 0.0;
        state.rosterPercentAtActivation = 75;
        state.reinforcementsAtActivation = true;
        ArrayPush(this.m_states, state);
      };
    };

    // Persistent ScriptableSystem arrays are not extended automatically. A
    // partial row set can therefore make a configured three-site pool top out
    // at two forever. Reconcile against the canonical database on every load.
    this.RecoverMissingSiteStates();
    if this.m_schemaVersion < 2 {
      if !freshState { this.RecoverNeverActivatedFinishedSites(); };
      this.m_schemaVersion = 2;
    };

    this.m_poolSize = Max(0, Min(this.m_poolSize, 3));
    this.m_cooldownHours = MaxF(1.0, MinF(this.m_cooldownHours, 720.0));
    this.m_rosterPercent = Max(25, Min(this.m_rosterPercent, 100));
    this.m_cleanupSeconds = Max(30, Min(this.m_cleanupSeconds, 900));
    this.m_cleanupDistance = MaxF(100.0, MinF(this.m_cleanupDistance, 500.0));
    this.m_growthPerClear = MaxF(0.0, MinF(this.m_growthPerClear, 0.10));
    this.m_growthCap = Max(0, Min(this.m_growthCap, 100));
  }

  private func RecoverMissingSiteStates() -> Void {
    for id in RICADatabase.SiteIDs() {
      if this.FindState(id) < 0 {
        let state: RICASiteState;
        let finished: Bool = this.IsOriginalFinished(id);
        state.siteID = id;
        state.status = finished ? RICAStatus.Cooldown : RICAStatus.Disabled;
        // This row was lost by mod persistence, not newly completed in vanilla.
        // A finished recovered site can refill the requested pool immediately.
        state.lastClearedAt = 0;
        state.cycle = 0;
        state.ownedActivation = false;
        state.vanillaEligible = finished;
        state.cleanupReadyAt = 0;
        state.enabled = true;
        state.cooldownOverrideHours = 0.0;
        state.rosterPercentAtActivation = this.m_rosterPercent;
        state.reinforcementsAtActivation = this.m_reinforcements;
        ArrayPush(this.m_states, state);
      };
    };
  }

  private func RecoverNeverActivatedFinishedSites() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if this.m_states[i].cycle == 0
        && !this.m_states[i].ownedActivation
        && this.m_states[i].enabled
        && this.IsOriginalFinished(this.m_states[i].siteID) {
        // v0.1.1 could retain a bad initial wait on the one row that never
        // entered the pool. Do not alter any site that has actually replayed.
        this.m_states[i].vanillaEligible = true;
        this.m_states[i].status = RICAStatus.Cooldown;
        this.m_states[i].lastClearedAt = 0;
        this.m_states[i].cleanupReadyAt = 0;
      };
      i += 1;
    };
  }

  public func GetEnabled() -> Bool { return this.m_enabled; }
  public func GetPoolSize() -> Int32 { return this.m_poolSize; }
  public func GetEffectivePoolSize() -> Int32 { return this.m_enabled ? this.m_poolSize : 0; }
  public func GetCooldownHours() -> Float { return this.m_cooldownHours; }
  public func GetRosterPercent() -> Int32 { return this.m_rosterPercent; }
  public func GetReinforcements() -> Bool { return this.m_reinforcements; }
  public func GetCleanupSeconds() -> Int32 { return this.m_cleanupSeconds; }
  public func GetCleanupDistance() -> Float { return this.m_cleanupDistance; }
  public func GetHeightenedAwareness() -> Bool { return this.m_heightenedAwareness; }
  public func GetTotalClears() -> Int32 { return this.m_totalClears; }
  public func GetTrackedSiteCount() -> Int32 { return ArraySize(this.m_states); }
  public func GetVanillaEligibleReplayCount() -> Int32 {
    let count: Int32 = 0;
    for siteID in RICADatabase.SiteIDs() {
      if this.IsVanillaEligible(siteID) { count += 1; };
    };
    return count;
  }
  public func GetNowSeconds() -> Int32 { return this.NowSeconds(); }
  public func GetSiteIDs() -> array<String> { return RICADatabase.SiteIDs(); }
  public func SetChangeMappinColor(value: Bool) -> Void { this.m_changeMappinColor = value; }
  public func GetChangeMappinColor() -> Bool { return this.m_changeMappinColor; }

  public func SetEnabled(value: Bool) -> Void {
    if Equals(value, this.m_enabled) { return; };
    this.m_enabled = value;
    if !value { this.RetireOwnedEvents(); } else { this.Tick(); };
  }

  public func SetPoolSize(value: Int32) -> Void {
    value = Max(0, Min(value, 3));
    if Equals(this.m_poolSize, value) { return; };
    this.m_poolSize = value;
    this.Tick();
  }

  public func SetCooldownHours(value: Float) -> Void {
    value = MaxF(1.0, MinF(value, 720.0));
    if Equals(this.m_cooldownHours, value) { return; };
    this.m_cooldownHours = value;
    this.Tick();
  }

  public func SetRosterPercent(value: Int32) -> Void {
    this.m_rosterPercent = Max(25, Min(value, 100));
  }

  public func SetReinforcements(value: Bool) -> Void {
    this.m_reinforcements = value;
  }

  public func SetCleanupSeconds(value: Int32) -> Void {
    this.m_cleanupSeconds = Max(30, Min(value, 900));
  }

  public func SetCleanupDistance(value: Float) -> Void {
    this.m_cleanupDistance = MaxF(100.0, MinF(value, 500.0));
  }

  public func SetHeightenedAwareness(value: Bool) -> Void {
    if Equals(value, this.m_heightenedAwareness) { return; };
    this.m_heightenedAwareness = value;
    this.ReapplyCombatSettings();
  }

  public func SetRegularCombat(health: Float, damage: Float, armor: Float, quickhack: Float) -> Void {
    health = MaxF(0.50, MinF(health, 5.00));
    damage = MaxF(0.50, MinF(damage, 5.00));
    armor = MaxF(0.50, MinF(armor, 5.00));
    quickhack = MaxF(0.50, MinF(quickhack, 5.00));
    if Equals(this.m_regularHealth, health)
      && Equals(this.m_regularDamage, damage)
      && Equals(this.m_regularArmor, armor)
      && Equals(this.m_regularQuickhack, quickhack) { return; };
    this.m_regularHealth = health;
    this.m_regularDamage = damage;
    this.m_regularArmor = armor;
    this.m_regularQuickhack = quickhack;
    this.ReapplyCombatSettings();
  }

  public func SetBossCombat(health: Float, damage: Float, armor: Float, quickhack: Float) -> Void {
    health = MaxF(0.50, MinF(health, 10.00));
    damage = MaxF(0.50, MinF(damage, 5.00));
    armor = MaxF(0.50, MinF(armor, 5.00));
    quickhack = MaxF(0.50, MinF(quickhack, 5.00));
    if Equals(this.m_bossHealth, health)
      && Equals(this.m_bossDamage, damage)
      && Equals(this.m_bossArmor, armor)
      && Equals(this.m_bossQuickhack, quickhack) { return; };
    this.m_bossHealth = health;
    this.m_bossDamage = damage;
    this.m_bossArmor = armor;
    this.m_bossQuickhack = quickhack;
    this.ReapplyCombatSettings();
  }

  public func SetGrowth(perClear: Float, cap: Int32) -> Void {
    perClear = MaxF(0.0, MinF(perClear, 0.10));
    cap = Max(0, Min(cap, 100));
    if Equals(this.m_growthPerClear, perClear) && Equals(this.m_growthCap, cap) { return; };
    this.m_growthPerClear = perClear;
    this.m_growthCap = cap;
    this.ReapplyCombatSettings();
  }

  public func GetStatus(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? EnumInt(this.m_states[index].status) : -1;
  }

  public func GetCycle(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? this.m_states[index].cycle : 0;
  }

  public func GetLastClearedAt(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? this.m_states[index].lastClearedAt : 0;
  }

  public func GetNextEligibleAt(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    if index < 0 || !this.m_states[index].vanillaEligible { return 0; };
    return this.m_states[index].lastClearedAt + Cast<Int32>(this.GetCooldownForIndex(index) * 3600.0);
  }

  public func IsVanillaEligible(siteID: String) -> Bool {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 && this.m_states[index].vanillaEligible;
  }

  public func GetSiteEnabled(siteID: String) -> Bool {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 && this.m_states[index].enabled;
  }

  public func SetSiteEnabled(siteID: String, value: Bool) -> Void {
    let index: Int32 = this.FindState(siteID);
    if index < 0 || Equals(this.m_states[index].enabled, value) { return; };
    if !value && this.m_states[index].ownedActivation {
      this.DeactivateState(index);
    };
    this.m_states[index].enabled = value;
    if !value { this.m_states[index].status = RICAStatus.Disabled; };
    this.Tick();
  }

  public func GetSiteCooldownOverride(siteID: String) -> Float {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? this.m_states[index].cooldownOverrideHours : 0.0;
  }

  public func IsOwnedActivation(siteID: String) -> Bool {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 && this.m_states[index].ownedActivation;
  }

  public func GetCleanupReadyAt(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? this.m_states[index].cleanupReadyAt : 0;
  }

  public func GetPlayerDistance(siteID: String) -> Float {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if !IsDefined(player) { return -1.0; };
    return Vector4.Distance2D(RICADatabase.Position(siteID), player.GetWorldPosition());
  }

  public func GetTrackedActorCount(siteID: String) -> Int32 {
    let count: Int32 = 0;
    for actor in this.m_actors {
      if Equals(actor.siteID, siteID) { count += 1; };
    };
    return count;
  }

  public func IsBossLoaded(siteID: String) -> Bool {
    for actor in this.m_actors {
      if Equals(actor.siteID, siteID) && actor.boss {
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), actor.actorID
        ) as NPCPuppet;
        if IsDefined(npc) { return true; };
      };
    };
    return false;
  }

  public func SetSiteCooldownOverride(siteID: String, value: Float) -> Void {
    let index: Int32 = this.FindState(siteID);
    if index < 0 { return; };
    value = MaxF(0.0, MinF(value, 720.0));
    if Equals(this.m_states[index].cooldownOverrideHours, value) { return; };
    this.m_states[index].cooldownOverrideHours = value;
    this.Tick();
  }

  public func GetActiveReplayCount() -> Int32 {
    let count: Int32 = 0;
    for state in this.m_states {
      if state.vanillaEligible && Equals(state.status, RICAStatus.Active) { count += 1; };
    };
    return count;
  }

  public func IsOwnedMappinPosition(position: Vector4) -> Bool {
    for siteID in RICADatabase.SiteIDs() {
      if this.GetStatus(siteID) == EnumInt(RICAStatus.Active)
        && Vector4.Distance2D(position, RICADatabase.Position(siteID)) < 2.0 {
        return true;
      };
    };
    return false;
  }

  private func IsOriginalFinished(siteID: String) -> Bool {
    let factName: String = RICADatabase.FinishedFact(siteID);
    if Equals(factName, "") { return false; };
    return GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFactStr(factName) > 0;
  }

  private func GetCooldownForIndex(index: Int32) -> Float {
    return this.m_states[index].cooldownOverrideHours > 0.0
      ? this.m_states[index].cooldownOverrideHours
      : this.m_cooldownHours;
  }

  private func IsEligibleAt(index: Int32, now: Int32) -> Bool {
    if !this.m_enabled || !this.m_states[index].enabled || !this.m_states[index].vanillaEligible {
      return false;
    };
    return now >= this.m_states[index].lastClearedAt
      + Cast<Int32>(this.GetCooldownForIndex(index) * 3600.0);
  }

  public func Tick() -> Void {
    this.EnsureState();
    let now: Int32 = this.NowSeconds();
    this.RefreshVanillaEligibility(now);
    this.CleanupDefeatedSites(now);
    if !this.m_enabled { return; };

    let active: Int32 = 0;
    let candidates: array<Int32>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if this.m_states[i].enabled
        && this.m_states[i].vanillaEligible
        && Equals(this.m_states[i].status, RICAStatus.Active) {
        active += 1;
      } else {
        if !this.m_states[i].ownedActivation && this.IsEligibleAt(i, now) {
          this.m_states[i].status = RICAStatus.Cooldown;
          ArrayPush(candidates, i);
        };
      };
      i += 1;
    };

    let target: Int32 = this.GetEffectivePoolSize();
    while active > target {
      if !this.RetireOneUnstreamedActiveSite() { break; };
      active -= 1;
    };

    while active < target && ArraySize(candidates) > 0 {
      let size: Int32 = ArraySize(candidates);
      let choice: Int32 = this.m_selectionCursor - (this.m_selectionCursor / size) * size;
      let stateIndex: Int32 = candidates[choice];
      ArrayErase(candidates, choice);
      this.m_selectionCursor += 1;
      if this.ActivateState(stateIndex) { active += 1; };
    };
  }

  private func RefreshVanillaEligibility(now: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      let finished: Bool = this.IsOriginalFinished(this.m_states[i].siteID);
      if finished && !this.m_states[i].vanillaEligible {
        this.m_states[i].vanillaEligible = true;
        this.m_states[i].lastClearedAt = now;
        this.m_states[i].status = this.m_states[i].enabled ? RICAStatus.Cooldown : RICAStatus.Disabled;
        this.m_states[i].ownedActivation = false;
        this.m_states[i].cleanupReadyAt = 0;
      } else {
        if !finished && this.m_states[i].vanillaEligible {
          // Another mod may have reopened the original quest. Do not deactivate
          // the shared first-run entries when vanilla ownership is ambiguous.
          this.ReleaseSiteActors(this.m_states[i].siteID);
          this.RemoveSiteActors(this.m_states[i].siteID);
          this.m_states[i].vanillaEligible = false;
          this.m_states[i].status = RICAStatus.Disabled;
          this.m_states[i].ownedActivation = false;
          this.m_states[i].cleanupReadyAt = 0;
        };
      };
      i += 1;
    };
  }

  private func ActivateState(index: Int32) -> Bool {
    if !this.IsOriginalFinished(this.m_states[index].siteID) { return false; };
    this.m_states[index].cycle += 1;
    this.m_states[index].rosterPercentAtActivation = this.m_rosterPercent;
    this.m_states[index].reinforcementsAtActivation = this.m_reinforcements;
    this.m_states[index].status = RICAStatus.Active;
    this.m_states[index].ownedActivation = true;
    this.m_states[index].cleanupReadyAt = 0;
    this.ActivateSite(
      this.m_states[index].siteID,
      this.m_states[index].rosterPercentAtActivation,
      this.m_states[index].reinforcementsAtActivation
    );
    return true;
  }

  private func CountOrdinaryActions(actions: array<ref<RICACommunityAction>>, reinforcements: Bool) -> Int32 {
    let count: Int32 = 0;
    for action in actions {
      if !action.boss && !action.reinforcement { count += 1; };
    };
    return count;
  }

  private func ShouldUseAction(
    action: ref<RICACommunityAction>,
    ordinaryIndex: Int32,
    targetOrdinary: Int32,
    reinforcements: Bool
  ) -> Bool {
    if action.boss { return true; };
    if action.reinforcement { return reinforcements; };
    return ordinaryIndex < targetOrdinary;
  }

  private func ActivateSite(siteID: String, rosterPercent: Int32, reinforcements: Bool) -> Void {
    let world: ref<WorldStateSystem> = GameInstance.GetWorldStateSystem();
    let actions: array<ref<RICACommunityAction>> = RICADatabase.Actions(siteID);
    let ordinaryCount: Int32 = this.CountOrdinaryActions(actions, reinforcements);
    let targetOrdinary: Int32 = Max(1, (ordinaryCount * rosterPercent + 99) / 100);
    let ordinaryIndex: Int32 = 0;
    for action in actions {
      if this.ShouldUseAction(action, ordinaryIndex, targetOrdinary, reinforcements) {
        world.SetCommunityPhase(CreateNodeRef(action.spawner), action.entry, action.phase);
        world.ActivateCommunity(CreateNodeRef(action.spawner), action.entry);
      };
      if !action.boss && !action.reinforcement { ordinaryIndex += 1; };
    };
  }

  private func DeactivateState(index: Int32) -> Void {
    if this.m_states[index].ownedActivation && this.m_states[index].vanillaEligible {
      this.ReleaseSiteActors(this.m_states[index].siteID);
      this.DeactivateSite(
        this.m_states[index].siteID,
        this.m_states[index].rosterPercentAtActivation,
        this.m_states[index].reinforcementsAtActivation
      );
    };
    this.RemoveSiteActors(this.m_states[index].siteID);
    this.m_states[index].ownedActivation = false;
    this.m_states[index].cleanupReadyAt = 0;
    this.m_states[index].status = this.m_states[index].enabled
      ? RICAStatus.Cooldown
      : RICAStatus.Disabled;
  }

  private func DeactivateSite(siteID: String, rosterPercent: Int32, reinforcements: Bool) -> Void {
    let world: ref<WorldStateSystem> = GameInstance.GetWorldStateSystem();
    let actions: array<ref<RICACommunityAction>> = RICADatabase.Actions(siteID);
    let ordinaryCount: Int32 = this.CountOrdinaryActions(actions, reinforcements);
    let targetOrdinary: Int32 = Max(1, (ordinaryCount * rosterPercent + 99) / 100);
    let ordinaryIndex: Int32 = 0;
    for action in actions {
      if this.ShouldUseAction(action, ordinaryIndex, targetOrdinary, reinforcements) {
        world.DeactivateCommunity(CreateNodeRef(action.spawner), action.entry);
      };
      if !action.boss && !action.reinforcement { ordinaryIndex += 1; };
    };
  }

  private func RetireOneUnstreamedActiveSite() -> Bool {
    let i: Int32 = ArraySize(this.m_states) - 1;
    while i >= 0 {
      if Equals(this.m_states[i].status, RICAStatus.Active)
        && !this.HasSiteActors(this.m_states[i].siteID) {
        this.DeactivateState(i);
        return true;
      };
      i -= 1;
    };
    return false;
  }

  public func RetireOwnedEvents() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if this.m_states[i].ownedActivation { this.DeactivateState(i); };
      i += 1;
    };
  }

  public func Reconcile() -> Void {
    ArrayClear(this.m_actors);
    this.RebuildRuntimeCommunityMap();
    this.Tick();
  }

  private func CompleteSite(siteID: String) -> Void {
    let index: Int32 = this.FindState(siteID);
    if index < 0 || NotEquals(this.m_states[index].status, RICAStatus.Active) { return; };
    let now: Int32 = this.NowSeconds();
    this.m_states[index].status = RICAStatus.Cooldown;
    this.m_states[index].lastClearedAt = now;
    this.m_states[index].cleanupReadyAt = now + this.m_cleanupSeconds;
    this.m_totalClears += 1;
    this.m_rewardSerial += 1;
    let reward: RICAPendingReward;
    reward.serial = this.m_rewardSerial;
    reward.siteID = siteID;
    reward.cycle = this.m_states[index].cycle;
    ArrayPush(this.m_pendingRewards, reward);
    this.Tick();
  }

  private func CleanupDefeatedSites(now: Int32) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if this.m_states[i].ownedActivation
        && Equals(this.m_states[i].status, RICAStatus.Cooldown)
        && this.m_states[i].cleanupReadyAt > 0
        && this.m_states[i].cleanupReadyAt <= now {
        let canClean: Bool = !IsDefined(player);
        if IsDefined(player) {
          canClean = Vector4.Distance2D(
            RICADatabase.Position(this.m_states[i].siteID),
            player.GetWorldPosition()
          ) > this.m_cleanupDistance;
        };
        if canClean { this.DeactivateState(i); };
      };
      i += 1;
    };
  }

  public func GetPendingRewardCount() -> Int32 { return ArraySize(this.m_pendingRewards); }

  public func GetPendingRewardSerial() -> Int32 {
    return ArraySize(this.m_pendingRewards) > 0 ? this.m_pendingRewards[0].serial : 0;
  }

  public func GetPendingRewardSiteID() -> String {
    return ArraySize(this.m_pendingRewards) > 0 ? this.m_pendingRewards[0].siteID : "";
  }

  public func GetPendingRewardCycle() -> Int32 {
    return ArraySize(this.m_pendingRewards) > 0 ? this.m_pendingRewards[0].cycle : 0;
  }

  public func AcknowledgeCompletionReward(serial: Int32) -> Void {
    if ArraySize(this.m_pendingRewards) > 0 && Equals(this.m_pendingRewards[0].serial, serial) {
      ArrayErase(this.m_pendingRewards, 0);
    };
  }

  public func GetPendingBodyRewardEntityID() -> EntityID {
    for actor in this.m_actors {
      let index: Int32 = this.FindState(actor.siteID);
      if index >= 0 && this.m_states[index].ownedActivation {
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), actor.actorID
        ) as NPCPuppet;
        if IsDefined(npc)
          && !actor.bodyRewarded
          && !StatusEffectSystem.ObjectHasStatusEffect(npc, t"BaseStatusEffect.RICABodyRewardedEffect") {
          return actor.actorID;
        };
      };
    };
    let empty: EntityID;
    return empty;
  }

  public func GetPendingBodyRewardSiteID() -> String {
    let entityID: EntityID = this.GetPendingBodyRewardEntityID();
    if !EntityID.IsDefined(entityID) { return ""; };
    for actor in this.m_actors {
      if Equals(actor.actorID, entityID) { return actor.siteID; };
    };
    return "";
  }

  public func MarkBodyRewarded(actorID: EntityID) -> Void {
    for actor in this.m_actors {
      if Equals(actor.actorID, actorID) { actor.bodyRewarded = true; };
    };
    let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(this.GetGameInstance(), actorID) as NPCPuppet;
    if IsDefined(npc)
      && !StatusEffectSystem.ObjectHasStatusEffect(npc, t"BaseStatusEffect.RICABodyRewardedEffect") {
      StatusEffectHelper.ApplyStatusEffect(npc, t"BaseStatusEffect.RICABodyRewardedEffect");
    };
  }

  private func RebuildRuntimeCommunityMap() -> Void {
    ArrayClear(this.m_communities);
    let empty: EntityID;
    for siteID in RICADatabase.SiteIDs() {
      for action in RICADatabase.Actions(siteID) {
        let spawnerID: EntityID = Cast<EntityID>(ResolveNodeRefWithEntityID(
          CreateNodeRef(action.spawner), empty
        ));
        if !this.HasCommunityRuntime(siteID, spawnerID) {
          let runtime: ref<RICACommunityRuntime> = new RICACommunityRuntime();
          runtime.siteID = siteID;
          runtime.spawnerID = spawnerID;
          ArrayPush(this.m_communities, runtime);
        };
      };
    };
  }

  private func HasCommunityRuntime(siteID: String, spawnerID: EntityID) -> Bool {
    for runtime in this.m_communities {
      if Equals(runtime.siteID, siteID) && Equals(runtime.spawnerID, spawnerID) { return true; };
    };
    return false;
  }

  public func OnSpawnerEvent(proxy: ref<CommunityProxyPS>, evt: ref<gameEntitySpawnerEvent>) -> Void {
    if NotEquals(evt.eventType, gameEntitySpawnerEventType.Spawn) { return; };
    let proxyID: EntityID = PersistentID.ExtractEntityID(proxy.GetID());
    for runtime in this.m_communities {
      if Equals(runtime.spawnerID, proxyID)
        && this.GetStatus(runtime.siteID) == EnumInt(RICAStatus.Active) {
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), evt.spawnedEntityId
        ) as NPCPuppet;
        if IsDefined(npc) {
          let boss: Bool = Equals(npc.GetRecordID(), RICADatabase.BossRecord(runtime.siteID));
          this.RememberActor(runtime.siteID, npc.GetEntityID(), boss);
          this.PrepareReplayActor(npc, runtime.siteID, boss);
        };
        return;
      };
    };
  }

  private func RememberActor(siteID: String, actorID: EntityID, boss: Bool) -> Void {
    for actor in this.m_actors {
      if Equals(actor.actorID, actorID) {
        actor.siteID = siteID;
        actor.boss = boss;
        return;
      };
    };
    let actor: ref<RICAActorRuntime> = new RICAActorRuntime();
    actor.siteID = siteID;
    actor.actorID = actorID;
    actor.boss = boss;
    actor.bodyRewarded = false;
    ArrayPush(this.m_actors, actor);
  }

  private func PrepareReplayActor(npc: ref<NPCPuppet>, siteID: String, boss: Bool) -> Void {
    let index: Int32 = this.FindState(siteID);
    if index < 0 { return; };
    let growthCycles: Int32 = Max(0, Min(this.m_states[index].cycle - 1, this.m_growthCap));
    let growth: Float = 1.0 + Cast<Float>(growthCycles) * this.m_growthPerClear;
    let health: Float = (boss ? this.m_bossHealth : this.m_regularHealth) * growth;
    let damage: Float = (boss ? this.m_bossDamage : this.m_regularDamage) * growth;
    let armor: Float = (boss ? this.m_bossArmor : this.m_regularArmor) * growth;
    let quickhack: Float = (boss ? this.m_bossQuickhack : this.m_regularQuickhack) * growth;

    this.SetScaleStat(npc, t"BaseStats.RICAEnemyHealthScale", health - 1.0);
    this.SetScaleStat(npc, t"BaseStats.RICAEnemyDamageScale", damage - 1.0);
    this.SetScaleStat(npc, t"BaseStats.RICAEnemyArmorScale", armor - 1.0);
    this.SetScaleStat(npc, t"BaseStats.RICAEnemyQuickhackScale", quickhack - 1.0);
    if !StatusEffectSystem.ObjectHasStatusEffect(npc, t"BaseStatusEffect.RICAEnemyEffect") {
      StatusEffectHelper.ApplyStatusEffect(npc, t"BaseStatusEffect.RICAEnemyEffect");
    };
    if this.m_heightenedAwareness {
      npc.GetAIControllerComponent().GetActionBlackboard().SetFloat(
        GetAllBlackboardDefs().AIAction.avoidLOSTimeStamp, 0.00
      );
      npc.GetTargetTrackerComponent().ClearThreats();
    };
    GameObject.ChangeAttitudeToHostile(npc, GetPlayer(this.GetGameInstance()));
  }

  private func SetScaleStat(npc: ref<NPCPuppet>, recordID: TweakDBID, value: Float) -> Void {
    let record = TweakDBInterface.GetStatRecord(recordID);
    if !IsDefined(record) { return; };
    let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let objectID: StatsObjectID = Cast(npc.GetEntityID());
    stats.RemoveSavedModifiers(objectID, record.StatType());
    stats.AddSavedModifier(
      objectID,
      RPGManager.CreateStatModifier(record.StatType(), gameStatModifierType.Additive, value)
    );
  }

  private func ReleaseReplayActor(npc: ref<NPCPuppet>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(npc, t"BaseStatusEffect.RICAEnemyEffect");
    StatusEffectHelper.RemoveStatusEffect(npc, t"BaseStatusEffect.RICABodyRewardedEffect");
    let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let objectID: StatsObjectID = Cast(npc.GetEntityID());
    for recordID in [
      t"BaseStats.RICAEnemyHealthScale",
      t"BaseStats.RICAEnemyDamageScale",
      t"BaseStats.RICAEnemyArmorScale",
      t"BaseStats.RICAEnemyQuickhackScale"
    ] {
      let record = TweakDBInterface.GetStatRecord(recordID);
      if IsDefined(record) { stats.RemoveSavedModifiers(objectID, record.StatType()); };
    };
  }

  private func ReapplyCombatSettings() -> Void {
    for actor in this.m_actors {
      let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
        this.GetGameInstance(), actor.actorID
      ) as NPCPuppet;
      if IsDefined(npc) { this.PrepareReplayActor(npc, actor.siteID, actor.boss); };
    };
  }

  private func ReleaseSiteActors(siteID: String) -> Void {
    for actor in this.m_actors {
      if Equals(actor.siteID, siteID) {
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), actor.actorID
        ) as NPCPuppet;
        if IsDefined(npc) { this.ReleaseReplayActor(npc); };
      };
    };
  }

  private func HasSiteActors(siteID: String) -> Bool {
    for actor in this.m_actors {
      if Equals(actor.siteID, siteID) {
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), actor.actorID
        ) as NPCPuppet;
        if IsDefined(npc) { return true; };
      };
    };
    return false;
  }

  private func RemoveSiteActors(siteID: String) -> Void {
    let i: Int32 = ArraySize(this.m_actors) - 1;
    while i >= 0 {
      if Equals(this.m_actors[i].siteID, siteID) { ArrayErase(this.m_actors, i); };
      i -= 1;
    };
  }

  public func OnActorDefeated(npc: ref<NPCPuppet>) -> Void {
    if !IsDefined(npc) { return; };
    for actor in this.m_actors {
      if Equals(actor.actorID, npc.GetEntityID()) && actor.boss {
        this.CompleteSite(actor.siteID);
        return;
      };
    };
  }

  private func FindState(siteID: String) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if Equals(this.m_states[i].siteID, siteID) { return i; };
      i += 1;
    };
    return -1;
  }

  private func NowSeconds() -> Int32 {
    return GameTime.GetSeconds(GameInstance.GetGameTime(this.GetGameInstance()));
  }
}

@wrapMethod(CommunityProxyPS)
public final func OnGameEntitySpawnerEvent(evt: ref<gameEntitySpawnerEvent>) -> EntityNotificationType {
  let result: EntityNotificationType = wrappedMethod(evt);
  let system: ref<RepeatableIncreasedCriminalActivitySystem> =
    RepeatableIncreasedCriminalActivitySystem.GetInstance(this.GetGameInstance());
  if IsDefined(system) { system.OnSpawnerEvent(this, evt); };
  return result;
}

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  let system: ref<RepeatableIncreasedCriminalActivitySystem> =
    RepeatableIncreasedCriminalActivitySystem.GetInstance(this.GetGame());
  if IsDefined(system) { system.OnActorDefeated(this); };
  return result;
}

@wrapMethod(NPCPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  if IsDefined(evt) && IsDefined(evt.staticData) {
    let status: String = UTF8StrLower(TDBID.ToStringDEBUG(evt.staticData.GetID()));
    if StrContains(status, "defeated") || StrContains(status, "unconscious") {
      let system: ref<RepeatableIncreasedCriminalActivitySystem> =
        RepeatableIncreasedCriminalActivitySystem.GetInstance(this.GetGame());
      if IsDefined(system) { system.OnActorDefeated(this); };
    };
  };
  return result;
}

@wrapMethod(BaseWorldMapMappinController)
protected cb func OnIntro() -> Bool {
  let result: Bool = wrappedMethod();
  this.ApplyRICAMappinColor(this.GetWidget(inkWidgetPath.Build(n"Canvas")));
  return result;
}

@wrapMethod(QuestMappinController)
protected cb func OnIntro() -> Bool {
  let result: Bool = wrappedMethod();
  this.ApplyRICAMappinColor(this.GetRootWidget());
  return result;
}

@wrapMethod(MinimapPOIMappinController)
protected func Intro() -> Void {
  wrappedMethod();
  this.ApplyRICAMappinColor(this.GetWidget(inkWidgetPath.Build(n"Canvas")));
}

@addMethod(BaseMappinBaseController)
protected func ApplyRICAMappinColor(widget: ref<inkWidget>) -> Void {
  let system: ref<RepeatableIncreasedCriminalActivitySystem> =
    RepeatableIncreasedCriminalActivitySystem.GetInstance(GetGameInstance());
  if !IsDefined(system) || !system.GetChangeMappinColor() || !IsDefined(this.GetMappin()) { return; };
  if system.IsOwnedMappinPosition(this.GetMappin().GetWorldPosition()) {
    this.TintRICAChildren(widget);
  };
}

@addMethod(BaseMappinBaseController)
protected func TintRICAChildren(widget: ref<inkWidget>) -> Void {
  if !IsDefined(widget) { return; };
  let container: ref<inkCompoundWidget> = widget as inkCompoundWidget;
  if IsDefined(container) {
    let i: Int32 = 0;
    while i < container.GetNumChildren() {
      this.TintRICAChildren(container.GetWidget(i));
      i += 1;
    };
  } else {
    if IsDefined(widget as inkImage) || IsDefined(widget as inkText) {
      widget.SetTintColor(new HDRColor(0.82, 0.32, 1.0, 1.0));
    };
  };
}
