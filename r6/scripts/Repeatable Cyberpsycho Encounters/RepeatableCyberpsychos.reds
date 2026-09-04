// Repeatable Cyberpsycho Encounters v0.4.2
// Safety contract: this file never starts an activity, writes a quest fact,
// changes a journal entry, or invokes any original cyberpsycho quest phase.

public enum RepeatableCyberpsychoStatus {
  Cooldown = 0,
  Active = 1,
  Disabled = 2
}

public struct RepeatableCyberpsychoState {
  public let siteID: String;
  public let status: RepeatableCyberpsychoStatus;
  public let nextEligibleAt: Int32;
  public let cycle: Int32;
  public let bodyRewarded: Bool;
  public let bodyRewardPending: Bool;
  public let bodyRewardReadyAt: Int32;
  public let ownedActivation: Bool;
  public let vanillaEligible: Bool;
  public let cleanupReadyAt: Int32;
}

public class RepeatableCyberpsychoCommunityAction {
  public let spawner: String;
  public let entry: CName;
  public let phase: CName;
  public let bossSpawner: Bool;
  public let bossRecord: String;

  public static func New(spawner: String, entry: CName, phase: CName, bossSpawner: Bool, opt bossRecord: String) -> ref<RepeatableCyberpsychoCommunityAction> {
    let action: ref<RepeatableCyberpsychoCommunityAction> = new RepeatableCyberpsychoCommunityAction();
    action.spawner = spawner;
    action.entry = entry;
    action.phase = phase;
    action.bossSpawner = bossSpawner;
    action.bossRecord = bossRecord;
    return action;
  }
}

public class RepeatableCyberpsychoSpawnerRuntime {
  public let siteID: String;
  public let spawnerID: EntityID;
  public let bossSpawner: Bool;
  public let bossRecord: String;
}

public class RepeatableCyberpsychoBossRuntime {
  public let siteID: String;
  public let actorID: EntityID;
  public let fallback: Bool;
  public let combatPrepared: Bool;
}

public class RepeatableCyberpsychoPendingBossRuntime {
  public let siteID: String;
  public let actorID: EntityID;
  public let expectedRecord: String;
  public let age: Int32;
}

public abstract class RepeatableCyberpsychoDatabase {
  public static func SiteIDs() -> array<String> {
    return [
      "ma_bls_ina_se1_07", "ma_bls_ina_se1_08", "ma_bls_ina_se1_22",
      "ma_cct_dtn_03", "ma_cct_dtn_07", "ma_hey_spr_04",
      "ma_hey_spr_06", "ma_pac_cvi_08", "ma_pac_cvi_15",
      "ma_std_arr_06", "ma_std_rcr_11", "ma_wat_kab_02",
      "ma_wat_lch_06", "ma_wat_nid_03", "ma_wat_nid_15",
      "ma_wat_nid_22", "sts_wat_nid_01"
    ];
  }

  public static func Actions(siteID: String) -> array<ref<RepeatableCyberpsychoCommunityAction>> {
    switch siteID {
      case "ma_bls_ina_se1_07":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_bls_ina_se1_07_com", n"Cyberpsycho", n"A", true, "Character.ma_bls_ina_se1_07_cyberpsycho_1")];
      case "ma_bls_ina_se1_08":
        return [
          RepeatableCyberpsychoCommunityAction.New("#ma_bls_ina_se1_08_com", n"psycho", n"behind_door", true, "Character.ma_bls_ina_se1_08_cyberpsycho"),
          RepeatableCyberpsychoCommunityAction.New("#ma_bls_ina_se1_08_com", n"drone_01", n"drone_start", false),
          RepeatableCyberpsychoCommunityAction.New("#ma_bls_ina_se1_08_com", n"drone_02", n"drone_start", false)
        ];
      case "ma_bls_ina_se1_22":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_bls_ina_se1_22_com", n"psycho", n"default", true, "Character.ma_bls_ina_se1_22_psycho")];
      case "ma_cct_dtn_03":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_cct_dtn_03_com_cyberpsycho", n"None", n"default", true, "Character.ma_cct_dtn_03_cyberpsycho")];
      case "ma_cct_dtn_07":
        // phase_2 is the vanilla ground-level combat position. jump_down relies
        // on a one-shot quest signal and strands a replay boss on the scaffold.
        return [RepeatableCyberpsychoCommunityAction.New("#ma_cct_dtn_07_com", n"psycho", n"phase_2", true, "Character.ma_cct_dtn_07_cyberpsycho")];
      case "ma_hey_spr_04":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_hey_spr_04_com", n"cyberpsycho", n"A", true, "Character.ma_hey_spr_04_cyberpsycho")];
      case "ma_hey_spr_06":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_hey_spr_06_com", n"cyberpsycho", n"default", true, "Character.ma_hey_spr_06_cyberpsycho")];
      case "ma_pac_cvi_08":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_pac_cvi_08_com", n"cyberpsycho", n"A", true, "Character.ma_pac_cvi_08_psycho")];
      case "ma_pac_cvi_15":
        return [
          RepeatableCyberpsychoCommunityAction.New("#ma_pac_cvi_15_com", n"psycho", n"start", true, "Character.ma_pac_cvi_15_cyberpsycho"),
          RepeatableCyberpsychoCommunityAction.New("#ma_pac_cvi_15_com", n"goon_01", n"start", false),
          RepeatableCyberpsychoCommunityAction.New("#ma_pac_cvi_15_com", n"goon_02", n"start", false),
          RepeatableCyberpsychoCommunityAction.New("#ma_pac_cvi_15_com", n"droid_01", n"start", false),
          RepeatableCyberpsychoCommunityAction.New("#ma_pac_cvi_15_com", n"droid_02", n"start", false)
        ];
      case "ma_std_arr_06":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_std_arr_06_com_psycho", n"cyberpsycho", n"start", true, "Character.ma_std_arr_06_cyberpsycho")];
      case "ma_std_rcr_11":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_std_rcr_11_com", n"psycho", n"0spawn", true, "Character.ma_std_rcr_11_cyberpsycho")];
      case "ma_wat_kab_02":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_wat_kab_02_com_psycho", n"None", n"default", true, "Character.ma_wat_kab_02_cyberpsycho")];
      case "ma_wat_lch_06":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_wat_lch_06_com", n"enemy_001", n"default", true, "Character.ma_wat_lch_06_cyberpsycho")];
      case "ma_wat_nid_03":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_wat_nid_03_com", n"psycho", n"default", true, "Character.ma_wat_nid_03_shard_psycho")];
      case "ma_wat_nid_15":
        // The other three entries are pre-killed story bodies. Activating them
        // without the quest scene resurrects them as idle NPCs.
        return [RepeatableCyberpsychoCommunityAction.New("#ma_wat_nid_15_com", n"psycho", n"default", true, "Character.ma_wat_nid_15_psycho")];
      case "ma_wat_nid_22":
        return [RepeatableCyberpsychoCommunityAction.New("#ma_wat_nid_22_com", n"monk", n"default", true, "Character.ma_wat_nid_22_monk")];
      case "sts_wat_nid_01":
        return [RepeatableCyberpsychoCommunityAction.New("#nid_01_com_psycho", n"psycho", n"default", true, "Character.sts_wat_nid_01_cyberpsycho")];
    };
    return [];
  }

  public static func UsesDynamicBoss(siteID: String) -> Bool {
    // Reserved for a future site whose community cannot safely be replayed.
    // v0.4 powers and opens the verified one-shot quest doors instead.
    return false;
  }

  public static func HostileRadius(siteID: String) -> Float {
    switch siteID {
      case "ma_pac_cvi_08": return 70.0;
      case "ma_wat_lch_06": return 65.0;
      case "ma_wat_nid_15": return 65.0;
      case "ma_bls_ina_se1_22": return 65.0;
    };
    return 55.0;
  }

  public static func Position(siteID: String) -> Vector4 {
    switch siteID {
      case "ma_bls_ina_se1_07": return new Vector4(2682.5698, -1508.25, 64.96, 1.0);
      case "ma_bls_ina_se1_08": return new Vector4(2681.682, -546.2816, 104.04512, 1.0);
      case "ma_bls_ina_se1_22": return new Vector4(4823.2627, -1387.651, 143.0134, 1.0);
      case "ma_cct_dtn_03": return new Vector4(-2140.6445, 268.22052, 8.01, 1.0);
      case "ma_cct_dtn_07": return new Vector4(-1689.9946, 247.96243, 16.529, 1.0);
      case "ma_hey_spr_04": return new Vector4(-2263.3071, -1320.8014, 7.199726, 1.0);
      case "ma_hey_spr_06": return new Vector4(-2409.2646, -1088.9158, 12.809999, 1.0);
      case "ma_pac_cvi_08": return new Vector4(-2128.3938, -1505.7416, 12.0599985, 1.0);
      case "ma_pac_cvi_15": return new Vector4(-2237.3357, -1980.1117, 5.6502023, 1.0);
      case "ma_std_arr_06": return new Vector4(-641.89795, -1312.407, 8.023128, 1.0);
      case "ma_std_rcr_11": return new Vector4(308.94043, -1893.8796, -7.0, 1.0);
      case "ma_wat_kab_02": return new Vector4(-787.1592, 1879.7571, 47.759995, 1.0);
      case "ma_wat_lch_06": return new Vector4(-2050.7861, 1225.5829, 3.8899999, 1.0);
      case "ma_wat_nid_03": return new Vector4(-1713.779, 2222.7595, 18.429945, 1.0);
      case "ma_wat_nid_15": return new Vector4(-1530.0504, 2509.6418, 7.1501465, 1.0);
      case "ma_wat_nid_22": return new Vector4(-1053.5896, 2799.9705, 7.1354833, 1.0);
      case "sts_wat_nid_01": return new Vector4(-1216.8411, 2278.1885, 6.9746165, 1.0);
    };
    return new Vector4(0.0, 0.0, 0.0, 0.0);
  }

  public static func FinishedFact(siteID: String) -> String {
    switch siteID {
      case "ma_bls_ina_se1_07": return "ma_bls_ina_se1_07_finished";
      case "ma_bls_ina_se1_08": return "ma_bls_ina_se1_08_finished";
      case "ma_bls_ina_se1_22": return "ma_ina_se1_22_finished";
      case "ma_cct_dtn_03": return "ma_dtn_03_finished";
      case "ma_cct_dtn_07": return "ma_cct_dtn_07_finished";
      case "ma_hey_spr_04": return "ma_spr_04_finished";
      case "ma_hey_spr_06": return "ma_hey_spr_06_finished";
      case "ma_pac_cvi_08": return "ma_pac_cvi_08_finished";
      case "ma_pac_cvi_15": return "ma_pac_cvi_15_finished";
      case "ma_std_arr_06": return "ma_arr_06_finished";
      case "ma_std_rcr_11": return "ma_rcr_11_finished";
      case "ma_wat_kab_02": return "ma_kab_02_finished";
      case "ma_wat_lch_06": return "ma_wat_lch_06_finished";
      case "ma_wat_nid_03": return "ma_nid_03_finished";
      case "ma_wat_nid_15": return "ma_nid_15_finished";
      case "ma_wat_nid_22": return "ma_nid_22_finished";
      case "sts_wat_nid_01": return "nid_01_finished";
    };
    return "";
  }
}

public class RepeatableCyberpsychosSystem extends ScriptableSystem {
  private persistent let m_schemaVersion: Int32;
  // Retained only so v0.1.x saves deserialize cleanly. v0.2 starts automatically.
  private persistent let m_armed: Bool;
  private persistent let m_poolSize: Int32;
  private persistent let m_lockdownPoolSize: Int32;
  private persistent let m_cooldownHours: Float;
  private persistent let m_states: array<RepeatableCyberpsychoState>;
  private persistent let m_totalClears: Int32;
  private persistent let m_pendingCompletionRewards: Int32;
  private persistent let m_heightenedAwareness: Bool;
  private persistent let m_blockStealthTakedowns: Bool;

  private let m_spawners: array<ref<RepeatableCyberpsychoSpawnerRuntime>>;
  private let m_bosses: array<ref<RepeatableCyberpsychoBossRuntime>>;
  private let m_pendingBosses: array<ref<RepeatableCyberpsychoPendingBossRuntime>>;
  private let m_changeMappinColor: Bool;

  public static func GetInstance(game: GameInstance) -> ref<RepeatableCyberpsychosSystem> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(
      n"RepeatableCyberpsychosSystem"
    ) as RepeatableCyberpsychosSystem;
  }

  private func OnAttach() -> Void {
    this.EnsureState();
    this.RebuildRuntimeSpawnerMap();
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    this.EnsureState();
    this.RebuildRuntimeSpawnerMap();
    this.Tick();
  }

  private final func OnPlayerDetach(request: ref<PlayerDetachRequest>) -> Void {
    ArrayClear(this.m_bosses);
    ArrayClear(this.m_pendingBosses);
  }

  private func EnsureState() -> Void {
    if this.m_schemaVersion <= 0 {
      this.m_schemaVersion = 1;
      this.m_poolSize = 8;
      this.m_lockdownPoolSize = 2;
      this.m_cooldownHours = 24.0;
    };
    if ArraySize(this.m_states) == 0 {
      for id in RepeatableCyberpsychoDatabase.SiteIDs() {
        let state: RepeatableCyberpsychoState;
        state.siteID = id;
        state.status = RepeatableCyberpsychoStatus.Disabled;
        state.nextEligibleAt = 0;
        state.cycle = 0;
        state.bodyRewarded = false;
        state.bodyRewardPending = false;
        state.bodyRewardReadyAt = 0;
        state.ownedActivation = false;
        state.vanillaEligible = false;
        ArrayPush(this.m_states, state);
      };
    };
    // Saved ScriptableSystem arrays are not automatically extended when a new
    // build adds sites. Reconcile against the canonical 17 every load so an
    // older 14-site save cannot permanently hide the final three markers.
    this.RecoverMissingSiteStates();

    if this.m_schemaVersion < 2 {
      this.MigrateFromManualActivation();
      this.m_schemaVersion = 2;
    };

    if this.m_schemaVersion < 3 {
      this.MigrateToStrictSchedule();
      this.m_heightenedAwareness = true;
      this.m_schemaVersion = 3;
    };

    if this.m_schemaVersion < 4 {
      this.MigrateToPhasedCommunities();
      this.m_schemaVersion = 4;
    };

    if this.m_schemaVersion < 5 {
      // v0.3 moves schedule ownership to CET's JSON configuration. No quest or
      // encounter reset is needed; JSON values are applied after save load.
      this.m_schemaVersion = 5;
    };

    if this.m_schemaVersion < 6 {
      // v0.3 injected loot while the spawn inventory was still being built.
      // Reset only mod reward bookkeeping; defeated sites are not re-awarded.
      let rewardIndex: Int32 = 0;
      while rewardIndex < ArraySize(this.m_states) {
        this.m_states[rewardIndex].bodyRewarded = false;
        this.m_states[rewardIndex].bodyRewardPending = false;
        this.m_states[rewardIndex].bodyRewardReadyAt = 0;
        rewardIndex += 1;
      };
      this.m_blockStealthTakedowns = true;
      this.m_schemaVersion = 6;
    };

    this.m_armed = true;
    this.m_poolSize = Max(0, Min(this.m_poolSize, 17));
    this.m_lockdownPoolSize = Max(0, Min(this.m_lockdownPoolSize, 5));
    this.m_cooldownHours = MaxF(1.0, MinF(this.m_cooldownHours, 720.0));
  }

  private func RecoverMissingSiteStates() -> Void {
    for id in RepeatableCyberpsychoDatabase.SiteIDs() {
      if this.FindState(id) < 0 {
        let state: RepeatableCyberpsychoState;
        let finished: Bool = this.IsOriginalFinished(id);
        state.siteID = id;
        state.status = finished
          ? RepeatableCyberpsychoStatus.Cooldown
          : RepeatableCyberpsychoStatus.Disabled;
        // A missing row on an established save is a mod migration defect, not
        // a newly completed Regina sighting. Make it immediately schedulable
        // when vanilla already confirms completion.
        state.nextEligibleAt = 0;
        state.cycle = 0;
        state.bodyRewarded = false;
        state.bodyRewardPending = false;
        state.bodyRewardReadyAt = 0;
        state.ownedActivation = false;
        state.vanillaEligible = finished;
        state.cleanupReadyAt = 0;
        ArrayPush(this.m_states, state);
      };
    };
  }

  private func MigrateToPhasedCommunities() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if this.m_states[i].vanillaEligible
        && this.m_states[i].ownedActivation
        && Equals(this.m_states[i].status, RepeatableCyberpsychoStatus.Active) {
        // v0.2.1 may have left only a subset of an active community alive.
        // Rebuild only mod-owned, already-finished replay sites so the new
        // explicit phases apply immediately without touching Regina's work.
        this.DeactivateSite(this.m_states[i].siteID);
        this.ActivateSite(this.m_states[i].siteID);
        this.m_states[i].bodyRewarded = false;
        this.m_states[i].bodyRewardPending = false;
        this.m_states[i].bodyRewardReadyAt = 0;
        this.m_states[i].cleanupReadyAt = 0;
        this.RemoveBoss(this.m_states[i].siteID);
      };
      i += 1;
    };
  }

  private func MigrateFromManualActivation() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      // A v0.1.x replay is safe to retire only when vanilla already marked that
      // specific sighting complete. For an unfinished sighting, release ownership
      // without deactivating its community so Regina's live activity stays intact.
      if Equals(this.m_states[i].status, RepeatableCyberpsychoStatus.Active)
        && this.m_states[i].ownedActivation
        && this.IsOriginalFinished(this.m_states[i].siteID) {
        this.DeactivateSite(this.m_states[i].siteID);
      };
      this.m_states[i].status = RepeatableCyberpsychoStatus.Disabled;
      this.m_states[i].nextEligibleAt = 0;
      this.m_states[i].ownedActivation = false;
      this.m_states[i].bodyRewarded = false;
      this.m_states[i].bodyRewardPending = false;
      this.m_states[i].bodyRewardReadyAt = 0;
      this.m_states[i].vanillaEligible = false;
      this.m_states[i].cleanupReadyAt = 0;
      i += 1;
    };
    this.m_lockdownPoolSize = 2;
    ArrayClear(this.m_bosses);
  }

  private func MigrateToStrictSchedule() -> Void {
    let now: Int32 = this.NowSeconds();
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      let finished: Bool = this.IsOriginalFinished(this.m_states[i].siteID);
      if this.m_states[i].ownedActivation && finished {
        this.DeactivateSite(this.m_states[i].siteID);
      };
      this.m_states[i].ownedActivation = false;
      this.m_states[i].bodyRewarded = false;
      this.m_states[i].bodyRewardPending = false;
      this.m_states[i].bodyRewardReadyAt = 0;
      this.m_states[i].cleanupReadyAt = 0;
      this.m_states[i].vanillaEligible = finished;
      if finished {
        this.m_states[i].status = RepeatableCyberpsychoStatus.Cooldown;
        this.m_states[i].nextEligibleAt = now
          + Cast<Int32>(this.m_cooldownHours * 3600.0);
      } else {
        this.m_states[i].status = RepeatableCyberpsychoStatus.Disabled;
        this.m_states[i].nextEligibleAt = 0;
      };
      i += 1;
    };
    ArrayClear(this.m_bosses);
  }

  public func GetPoolSize() -> Int32 { return this.m_poolSize; }
  public func GetLockdownPoolSize() -> Int32 { return this.m_lockdownPoolSize; }
  public func GetEffectivePoolSize() -> Int32 {
    return this.IsLockdown() ? this.m_lockdownPoolSize : this.m_poolSize;
  }
  public func GetCooldownHours() -> Float { return this.m_cooldownHours; }
  public func GetTotalClears() -> Int32 { return this.m_totalClears; }
  public func GetPendingCompletionRewards() -> Int32 { return this.m_pendingCompletionRewards; }
  public func GetTrackedSiteCount() -> Int32 { return ArraySize(this.m_states); }
  public func GetVanillaEligibleReplayCount() -> Int32 {
    let count: Int32 = 0;
    for siteID in RepeatableCyberpsychoDatabase.SiteIDs() {
      if this.IsVanillaEligible(siteID) { count += 1; };
    };
    return count;
  }
  public func GetActiveReplayCount() -> Int32 {
    let count: Int32 = 0;
    for state in this.m_states {
      if state.vanillaEligible
        && Equals(state.status, RepeatableCyberpsychoStatus.Active) {
        count += 1;
      };
    };
    return count;
  }
  public func GetSiteIDs() -> array<String> { return RepeatableCyberpsychoDatabase.SiteIDs(); }
  public func GetNowSeconds() -> Int32 { return this.NowSeconds(); }
  public func SetChangeMappinColor(value: Bool) -> Void { this.m_changeMappinColor = value; }
  public func GetChangeMappinColor() -> Bool { return this.m_changeMappinColor; }
  public func GetHeightenedAwareness() -> Bool { return this.m_heightenedAwareness; }
  public func GetBlockStealthTakedowns() -> Bool { return this.m_blockStealthTakedowns; }

  public func SetBlockStealthTakedowns(value: Bool) -> Void {
    this.m_blockStealthTakedowns = value;
  }

  public func SetHeightenedAwareness(value: Bool) -> Void {
    if Equals(value, this.m_heightenedAwareness) { return; };
    this.m_heightenedAwareness = value;
    if value {
      for boss in this.m_bosses {
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), boss.actorID
        ) as NPCPuppet;
        if IsDefined(npc) { this.PrepareReplayBoss(npc); };
      };
    };
  }

  public func IsOwnedMappinPosition(position: Vector4) -> Bool {
    for siteID in RepeatableCyberpsychoDatabase.SiteIDs() {
      if this.GetStatus(siteID) == EnumInt(RepeatableCyberpsychoStatus.Active)
        && Vector4.Distance2D(position, RepeatableCyberpsychoDatabase.Position(siteID)) < 2.0 {
        return true;
      };
    };
    return false;
  }

  public func SetPoolSize(value: Int32) -> Void {
    let bounded: Int32 = Max(0, Min(value, 17));
    if bounded == this.m_poolSize { return; };
    this.m_poolSize = bounded;
    this.Tick();
  }

  public func SetLockdownPoolSize(value: Int32) -> Void {
    let bounded: Int32 = Max(0, Min(value, 5));
    if bounded == this.m_lockdownPoolSize { return; };
    this.m_lockdownPoolSize = bounded;
    this.Tick();
  }

  public func SetCooldownHours(value: Float) -> Void {
    let bounded: Float = MaxF(1.0, MinF(value, 720.0));
    if bounded == this.m_cooldownHours { return; };

    // Rebase cooldowns already in progress. Previously a menu change affected
    // only future clears, leaving old 24-hour timestamps intact and making a
    // a newly selected shorter setting appear broken.
    let oldDuration: Int32 = Cast<Int32>(this.m_cooldownHours * 3600.0);
    let newDuration: Int32 = Cast<Int32>(bounded * 3600.0);
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if Equals(this.m_states[i].status, RepeatableCyberpsychoStatus.Cooldown)
        && this.m_states[i].nextEligibleAt > 0 {
        this.m_states[i].nextEligibleAt = Max(
          0, this.m_states[i].nextEligibleAt - oldDuration + newDuration
        );
      };
      i += 1;
    };
    this.m_cooldownHours = bounded;
    this.Tick();
  }

  public func GetStatus(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? EnumInt(this.m_states[index].status) : -1;
  }

  public func GetNextEligibleAt(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? this.m_states[index].nextEligibleAt : 0;
  }

  public func GetCleanupReadyAt(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? this.m_states[index].cleanupReadyAt : 0;
  }

  public func IsOwnedActivation(siteID: String) -> Bool {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 && this.m_states[index].ownedActivation;
  }

  public func GetCycle(siteID: String) -> Int32 {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 ? this.m_states[index].cycle : 0;
  }

  public func IsVanillaEligible(siteID: String) -> Bool {
    let index: Int32 = this.FindState(siteID);
    return index >= 0 && this.m_states[index].vanillaEligible;
  }

  public func IsLockdown() -> Bool {
    return GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFactStr("q005_done") <= 0;
  }

  private func IsOriginalFinished(siteID: String) -> Bool {
    let factName: String = RepeatableCyberpsychoDatabase.FinishedFact(siteID);
    if Equals(factName, "") { return false; };
    return GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFactStr(factName) > 0;
  }

  public func AcknowledgeCompletionReward() -> Void {
    if this.m_pendingCompletionRewards > 0 {
      this.m_pendingCompletionRewards -= 1;
    };
  }

  public func GetBossEntityID(siteID: String) -> EntityID {
    for boss in this.m_bosses {
      if Equals(boss.siteID, siteID) { return boss.actorID; };
    };
    let empty: EntityID;
    return empty;
  }

  public func HasPendingBoss(siteID: String) -> Bool {
    for pending in this.m_pendingBosses {
      if Equals(pending.siteID, siteID) { return true; };
    };
    return false;
  }

  public func NeedsCombatSetup(siteID: String) -> Bool {
    for boss in this.m_bosses {
      if Equals(boss.siteID, siteID) && !boss.combatPrepared {
        return EntityID.IsDefined(boss.actorID);
      };
    };
    return false;
  }

  public func MarkCombatPrepared(siteID: String) -> Void {
    for boss in this.m_bosses {
      if Equals(boss.siteID, siteID) { boss.combatPrepared = true; return; };
    };
  }

  public func NeedsBodyReward(siteID: String) -> Bool {
    let index: Int32 = this.FindState(siteID);
    if index < 0 || this.m_states[index].bodyRewarded
      || !this.m_states[index].bodyRewardPending
      || this.m_states[index].bodyRewardReadyAt > this.NowSeconds() {
      return false;
    };
    return EntityID.IsDefined(this.GetBossEntityID(siteID));
  }

  public func MarkBodyRewarded(siteID: String) -> Void {
    let index: Int32 = this.FindState(siteID);
    if index >= 0 {
      this.m_states[index].bodyRewarded = true;
      this.m_states[index].bodyRewardPending = false;
      this.m_states[index].bodyRewardReadyAt = 0;
    };
  }

  public func RuntimeTick() -> Void {
    this.ProcessPendingBosses();
    this.ApplyActiveDeviceStates();
    this.UpdateReplayAwareness();
  }

  public func Tick() -> Void {
    this.EnsureState();
    this.RuntimeTick();

    let now: Int32 = this.NowSeconds();
    this.RefreshVanillaEligibility(now);
    this.CleanupDefeatedSites(now);

    let active: Int32 = 0;
    let candidates: array<Int32>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if this.m_states[i].vanillaEligible
        && Equals(this.m_states[i].status, RepeatableCyberpsychoStatus.Active) {
        active += 1;
        if !this.m_states[i].ownedActivation {
          this.ActivateState(i);
        };
      } else {
        if Equals(this.m_states[i].status, RepeatableCyberpsychoStatus.Cooldown)
          && !this.m_states[i].ownedActivation
          && this.m_states[i].nextEligibleAt <= now {
          ArrayPush(candidates, i);
        };
      };
      i += 1;
    };

    let target: Int32 = this.GetEffectivePoolSize();
    while active > target {
      if !this.RetireOneActiveSite(now) { break; };
      active -= 1;
    };

    while active < target && ArraySize(candidates) > 0 {
      let choice: Int32 = RandRange(0, ArraySize(candidates));
      let stateIndex: Int32 = candidates[choice];
      ArrayErase(candidates, choice);
      this.ActivateState(stateIndex);
      active += 1;
    };
  }

  private func RefreshVanillaEligibility(now: Int32) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      let finished: Bool = this.IsOriginalFinished(this.m_states[i].siteID);
      if finished && !this.m_states[i].vanillaEligible {
        this.m_states[i].vanillaEligible = true;
        this.m_states[i].status = RepeatableCyberpsychoStatus.Cooldown;
        this.m_states[i].nextEligibleAt = now
          + Cast<Int32>(this.m_cooldownHours * 3600.0);
        this.m_states[i].ownedActivation = false;
        this.m_states[i].bodyRewarded = false;
        this.m_states[i].bodyRewardPending = false;
        this.m_states[i].bodyRewardReadyAt = 0;
        this.m_states[i].cleanupReadyAt = 0;
      } else {
        if !finished {
          // Never deactivate here. A reset or unfinished vanilla activity may now
          // own the same community, so the safe action is to stop tracking it.
          if Equals(this.m_states[i].status, RepeatableCyberpsychoStatus.Active) {
            this.RemoveBoss(this.m_states[i].siteID);
          };
          this.m_states[i].vanillaEligible = false;
          this.m_states[i].status = RepeatableCyberpsychoStatus.Disabled;
          this.m_states[i].nextEligibleAt = 0;
          this.m_states[i].ownedActivation = false;
          this.m_states[i].bodyRewarded = false;
          this.m_states[i].bodyRewardPending = false;
          this.m_states[i].bodyRewardReadyAt = 0;
          this.m_states[i].cleanupReadyAt = 0;
        };
      };
      i += 1;
    };
  }

  private func RetireOneActiveSite(now: Int32) -> Bool {
    let i: Int32 = ArraySize(this.m_states) - 1;
    while i >= 0 {
      if this.m_states[i].vanillaEligible
        && Equals(this.m_states[i].status, RepeatableCyberpsychoStatus.Active) {
        if this.m_states[i].ownedActivation {
          this.DeactivateSite(this.m_states[i].siteID);
        };
        this.m_states[i].status = RepeatableCyberpsychoStatus.Cooldown;
        this.m_states[i].nextEligibleAt = now;
        this.m_states[i].ownedActivation = false;
        this.m_states[i].bodyRewarded = false;
        this.m_states[i].bodyRewardPending = false;
        this.m_states[i].bodyRewardReadyAt = 0;
        this.m_states[i].cleanupReadyAt = 0;
        this.RemoveBoss(this.m_states[i].siteID);
        return true;
      };
      i -= 1;
    };
    return false;
  }

  private func ActivateState(index: Int32) -> Void {
    if !this.m_states[index].vanillaEligible { return; };
    this.ActivateSite(this.m_states[index].siteID);
    this.m_states[index].status = RepeatableCyberpsychoStatus.Active;
    this.m_states[index].ownedActivation = true;
    this.m_states[index].bodyRewarded = false;
    this.m_states[index].bodyRewardPending = false;
    this.m_states[index].bodyRewardReadyAt = 0;
    this.m_states[index].cleanupReadyAt = 0;
    this.m_states[index].cycle += 1;
  }

  private func ActivateSite(siteID: String) -> Void {
    let world: ref<WorldStateSystem> = GameInstance.GetWorldStateSystem();
    this.PrepareSiteEnvironment(siteID, world);
    for action in RepeatableCyberpsychoDatabase.Actions(siteID) {
      if !action.bossSpawner || !RepeatableCyberpsychoDatabase.UsesDynamicBoss(siteID) {
        world.SetCommunityPhase(CreateNodeRef(action.spawner), action.entry, action.phase);
        world.ActivateCommunity(CreateNodeRef(action.spawner), action.entry);
      };
    };
  }

  private func DeactivateSite(siteID: String) -> Void {
    let world: ref<WorldStateSystem> = GameInstance.GetWorldStateSystem();
    for action in RepeatableCyberpsychoDatabase.Actions(siteID) {
      world.DeactivateCommunity(CreateNodeRef(action.spawner), action.entry);
    };
    this.RestoreSiteEnvironment(siteID, world);
  }

  private func RestartVariant(world: ref<WorldStateSystem>, node: String, variant: CName) -> Void {
    world.TogglePrefabVariant(CreateNodeRef(node), variant, false);
    world.TogglePrefabVariant(CreateNodeRef(node), variant, true);
  }

  private func StopCommunity(world: ref<WorldStateSystem>, node: String) -> Void {
    world.DeactivateCommunity(CreateNodeRef(node), n"None");
  }

  private func StartCommunity(world: ref<WorldStateSystem>, node: String) -> Void {
    world.ActivateCommunity(CreateNodeRef(node), n"None");
  }

  private func StopPopulation(world: ref<WorldStateSystem>, node: String) -> Void {
    world.DeactivatePopulationSpawner(CreateNodeRef(node));
  }

  private func ApplyDeviceState(node: String, power: Bool, unlock: Bool, open: Bool, turnOn: Bool) -> Void {
    let empty: EntityID;
    let id: EntityID = Cast<EntityID>(ResolveNodeRefWithEntityID(CreateNodeRef(node), empty));
    if !EntityID.IsDefined(id) { return; };
    let device: ref<Device> = GameInstance.FindEntityByID(this.GetGameInstance(), id) as Device;
    if !IsDefined(device) || !IsDefined(device.GetDevicePS()) { return; };
    let devicePS: ref<ScriptableDeviceComponentPS> = device.GetDevicePS();
    if power { devicePS.RepeatableCyberpsychoForcePower(); };
    if turnOn { devicePS.RepeatableCyberpsychoForceON(); };
    if unlock || open {
      let doorPS: ref<DoorControllerPS> = devicePS as DoorControllerPS;
      if IsDefined(doorPS) {
        if unlock { doorPS.RepeatableCyberpsychoForceUnlock(); };
        if open { doorPS.RepeatableCyberpsychoForceOpen(); };
      };
    };
  }

  private func ApplyActiveDeviceStates() -> Void {
    // Device actions must be repeated after streaming because the original
    // quest nodes were one-shot. Calls are idempotent persistent-state actions.
    if this.GetStatus("ma_bls_ina_se1_08") == EnumInt(RepeatableCyberpsychoStatus.Active) {
      this.ApplyDeviceState("#ma_bls_ina_08_dvc_garage_door", true, true, true, false);
      this.ApplyDeviceState("#ma_bls_ina_08_turret_01", true, false, false, true);
      this.ApplyDeviceState("#ma_bls_ina_08_turret_02", true, false, false, true);
    };
    if this.GetStatus("ma_pac_cvi_15") == EnumInt(RepeatableCyberpsychoStatus.Active) {
      this.ApplyDeviceState("#ma_pac_cvi_15_dvc_garage_door", true, true, true, false);
    };
    if this.GetStatus("ma_std_arr_06") == EnumInt(RepeatableCyberpsychoStatus.Active) {
      this.ApplyDeviceState("#ma_std_arr_06_turret_01", true, false, false, true);
      this.ApplyDeviceState("#ma_std_arr_06_turret_02", true, false, false, true);
    };
    if this.GetStatus("sts_wat_nid_01") == EnumInt(RepeatableCyberpsychoStatus.Active) {
      this.ApplyDeviceState("#sts_wat_nid_01_door_01", true, true, true, false);
      this.ApplyDeviceState("#sts_wat_nid_door_02", true, true, true, false);
      this.ApplyDeviceState("#nid_01_hal_door", true, true, true, false);
    };
  }

  private func PrepareSiteEnvironment(siteID: String, world: ref<WorldStateSystem>) -> Void {
    switch siteID {
      case "ma_bls_ina_se1_07":
        this.RestartVariant(world, "#loc_ma_bls_ina_se1_07_devices", n"ma_bls_ina_se1_07_clues");
        break;
      case "ma_bls_ina_se1_08":
        // The finished quest can leave both garage vehicle spawners occupying
        // the combat workspot. Remove them before the replay boss is created.
        this.StopPopulation(world, "#ma_bls_ina_se1_08_vehicle_01");
        this.StopPopulation(world, "#ma_bls_ina_se1_08_vehicle_02");
        break;
      case "ma_bls_ina_se1_22":
        this.RestartVariant(world, "#loc_ma_bls_ina_se1_22_devices", n"quest_devices");
        this.RestartVariant(world, "#loc_ma_bls_ina_se1_22_devices", n"psycho_devices");
        break;
      case "ma_cct_dtn_03":
        this.StopCommunity(world, "$/03_night_city/#c_city_center/downtown/dtn_cs_prefab73SWZKQ/cs_cyberpsycho_disposal_openworld_001_prefabH62BISI/cs_cyberpsycho_disposal_com");
        // The flames are a real vanilla prefab, not a spawned actor. Rebuild
        // the mutually exclusive fire variants to their active-mission state.
        world.TogglePrefabVariant(CreateNodeRef("#loc_ma_cct_dtn_03_decoration"), n"Fire_off_decos", false);
        world.TogglePrefabVariant(CreateNodeRef("#loc_ma_cct_dtn_03_decoration"), n"Fire_decos", true);
        break;
      case "ma_cct_dtn_07":
        this.StopCommunity(world, "$/03_night_city/#c_city_center/downtown/dtn_cs_prefab73SWZKQ/cs_cyberpsycho_disposal_openworld_002_prefabH62BISI/cs_cyberpsycho_disposal_com");
        this.StopCommunity(world, "#cct_dtn_chat_006_com");
        break;
      case "ma_hey_spr_06":
        this.StopCommunity(world, "#ma_hey_spr_06_after_com");
        this.RestartVariant(world, "#ma_hey_spr_06_devices", n"psycho_active");
        break;
      case "ma_pac_cvi_08":
        this.StopCommunity(world, "#ma_pac_cvi_08_cs_cyberpsycho_disposal_com");
        this.StopCommunity(world, "#ma_pac_cvi_08_civ_com");
        this.StopPopulation(world, "#ma_pac_cvi_08_spwn_police_av_003");
        this.StopPopulation(world, "#ma_pac_cvi_08_spwn_police_av_02");
        this.StopPopulation(world, "#ma_pac_cvi_08_spwn_police_av_01");
        this.StopPopulation(world, "#ma_pac_cvi_08_ent_police_car_01");
        this.StopPopulation(world, "#ma_pac_cvi_08_ent_police_car_02");
        this.StopPopulation(world, "#ma_pac_cvi_08_ent_police_car_03");
        this.StopPopulation(world, "#ma_pac_cvi_08_ent_police_car_04");
        this.StopPopulation(world, "#ma_pac_cvi_08_ent_police_car_05");
        this.StopPopulation(world, "#ma_pac_cvi_08_ent_police_car_06");
        break;
      case "ma_pac_cvi_15":
        this.StopCommunity(world, "#ma_pac_cvi_15_after_com");
        // The aftermath variant owns the finished-quest locked interior state.
        world.TogglePrefabVariant(CreateNodeRef("#de_pac_cvi_05_devices"), n"cyberpsycho_aftermath", false);
        break;
      case "ma_std_arr_06":
        this.StopCommunity(world, "$/03_night_city/#c_santo_domingo/arroyo/arr_cs_prefab4OUIGHQ/cs_cyberpsycho_disposal_openworld_prefabRCXRD7A/cs_cyberpsycho_disposal_com");
        this.StopCommunity(world, "#ma_std_arr_06_com_homeless");
        this.RestartVariant(world, "#loc_ma_std_arr_06_devices", n"bodies");
        break;
      case "ma_std_rcr_11":
        this.StopCommunity(world, "$/03_night_city/#c_santo_domingo/rancho_coronado/rcr_cs_prefabROK3MDI/cs_cyberpsycho_disposal_openworld_002_prefabGU4CVFA/cs_cyberpsycho_disposal_com");
        break;
      case "ma_wat_kab_02":
        this.StopCommunity(world, "#ma_wat_kab_02_after_com");
        this.RestartVariant(world, "#loc_ma_wat_kab_02_audio", n"emitter");
        break;
      case "ma_wat_lch_06":
        this.StopCommunity(world, "#ma_wat_lch_06_after_police_com");
        this.StopPopulation(world, "#ma_wat_lch_06_max_tac_av");
        world.TogglePrefabVariant(CreateNodeRef("$/03_night_city/c_watson/little_china/loc_ma_wat_lch_06_prefabKZZAOYQ/loc_ma_wat_lch_06_devices_prefabEQDPGVY"), n"Police", false);
        break;
      case "ma_wat_nid_03":
        this.RestartVariant(world, "#loc_ma_wat_nid_03_devices", n"quest_devices");
        break;
      case "ma_wat_nid_22":
        this.StopCommunity(world, "#ma_wat_nid_22_com_fluff");
        this.StopPopulation(world, "#ma_wat_nid_22_spwn_maelstrom_car_01");
        this.StopPopulation(world, "#ma_wat_nid_22_spwn_maelstrom_car_02");
        this.StopPopulation(world, "#ma_wat_nid_22_spwn_maelstrom_car_03");
        break;
      case "sts_wat_nid_01":
        this.StopCommunity(world, "#nid_01_com");
        this.StopCommunity(world, "#nid_01_com_dead");
        // Do not re-enable the one-shot lockdown. It is the source of the
        // unpowered entrances after the original street story is finished.
        world.TogglePrefabVariant(CreateNodeRef("#nid_01_ext"), n"lockdown", false);
        this.RestartVariant(world, "$/03_night_city/c_watson/northside/loc_sts_wat_nid_01_prefab6GLBSFY/loc_sts_wat_nid_01_gameplay_prefabKISNQ5Q/loc_sts_wat_nid_01_loot_prefabFHW5XII", n"dead_moxies_var");
        break;
    };
  }

  private func RestoreSiteEnvironment(siteID: String, world: ref<WorldStateSystem>) -> Void {
    // Restore only finished-world ambience after the player has left. Vehicle,
    // police, victim, and lockdown spawners remain off so the next replay is clean.
    switch siteID {
      case "ma_cct_dtn_03":
        this.StartCommunity(world, "$/03_night_city/#c_city_center/downtown/dtn_cs_prefab73SWZKQ/cs_cyberpsycho_disposal_openworld_001_prefabH62BISI/cs_cyberpsycho_disposal_com");
        break;
      case "ma_cct_dtn_07":
        this.StartCommunity(world, "$/03_night_city/#c_city_center/downtown/dtn_cs_prefab73SWZKQ/cs_cyberpsycho_disposal_openworld_002_prefabH62BISI/cs_cyberpsycho_disposal_com");
        break;
      case "ma_hey_spr_06": this.StartCommunity(world, "#ma_hey_spr_06_after_com"); break;
      case "ma_pac_cvi_15": this.StartCommunity(world, "#ma_pac_cvi_15_after_com"); break;
      case "ma_std_arr_06":
        this.StartCommunity(world, "$/03_night_city/#c_santo_domingo/arroyo/arr_cs_prefab4OUIGHQ/cs_cyberpsycho_disposal_openworld_prefabRCXRD7A/cs_cyberpsycho_disposal_com");
        break;
      case "ma_std_rcr_11":
        this.StartCommunity(world, "$/03_night_city/#c_santo_domingo/rancho_coronado/rcr_cs_prefabROK3MDI/cs_cyberpsycho_disposal_openworld_002_prefabGU4CVFA/cs_cyberpsycho_disposal_com");
        break;
      case "ma_wat_kab_02": this.StartCommunity(world, "#ma_wat_kab_02_after_com"); break;
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

  private func RebuildRuntimeSpawnerMap() -> Void {
    ArrayClear(this.m_spawners);
    let empty: EntityID;
    for siteID in RepeatableCyberpsychoDatabase.SiteIDs() {
      for action in RepeatableCyberpsychoDatabase.Actions(siteID) {
        let runtime: ref<RepeatableCyberpsychoSpawnerRuntime> = new RepeatableCyberpsychoSpawnerRuntime();
        runtime.siteID = siteID;
        runtime.spawnerID = Cast<EntityID>(ResolveNodeRefWithEntityID(CreateNodeRef(action.spawner), empty));
        runtime.bossSpawner = action.bossSpawner;
        runtime.bossRecord = action.bossRecord;
        ArrayPush(this.m_spawners, runtime);
      };
    };
  }

  public func OnSpawnerEvent(proxy: ref<CommunityProxyPS>, evt: ref<gameEntitySpawnerEvent>) -> Void {
    if NotEquals(evt.eventType, gameEntitySpawnerEventType.Spawn) { return; };
    let proxyID: EntityID = PersistentID.ExtractEntityID(proxy.GetID());
    for runtime in this.m_spawners {
      if runtime.bossSpawner && Equals(runtime.spawnerID, proxyID)
        && this.GetStatus(runtime.siteID) == EnumInt(RepeatableCyberpsychoStatus.Active) {
        // The spawner callback commonly arrives one or more frames before the
        // NPC is discoverable by entity ID. Queue it and resolve after attach;
        // otherwise the fallback watchdog can create a second copy.
        this.QueuePendingBoss(runtime.siteID, evt.spawnedEntityId, runtime.bossRecord);
      };
    };
  }

  private func QueuePendingBoss(siteID: String, actorID: EntityID, expectedRecord: String) -> Void {
    for pending in this.m_pendingBosses {
      if Equals(pending.actorID, actorID) { return; };
    };
    let pending: ref<RepeatableCyberpsychoPendingBossRuntime> = new RepeatableCyberpsychoPendingBossRuntime();
    pending.siteID = siteID;
    pending.actorID = actorID;
    pending.expectedRecord = expectedRecord;
    pending.age = 0;
    ArrayPush(this.m_pendingBosses, pending);
    this.ProcessPendingBosses();
  }

  private func ProcessPendingBosses() -> Void {
    let i: Int32 = ArraySize(this.m_pendingBosses) - 1;
    while i >= 0 {
      let pending: ref<RepeatableCyberpsychoPendingBossRuntime> = this.m_pendingBosses[i];
      pending.age += 1;
      if this.GetStatus(pending.siteID) != EnumInt(RepeatableCyberpsychoStatus.Active) {
        ArrayErase(this.m_pendingBosses, i);
      } else {
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), pending.actorID
        ) as NPCPuppet;
        if IsDefined(npc) && this.LooksLikeCyberpsycho(npc, pending.expectedRecord) {
          if this.RememberBoss(pending.siteID, npc.GetEntityID(), false) {
            this.PrepareReplayBoss(npc);
          };
          ArrayErase(this.m_pendingBosses, i);
        } else {
          if pending.age > 90 { ArrayErase(this.m_pendingBosses, i); };
        };
      };
      i -= 1;
    };
  }

  public func RegisterFallbackBoss(siteID: String, actorID: EntityID) -> Bool {
    let index: Int32 = this.FindState(siteID);
    if index < 0 || !this.m_states[index].vanillaEligible
      || NotEquals(this.m_states[index].status, RepeatableCyberpsychoStatus.Active) {
      return false;
    };

    let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
      this.GetGameInstance(), actorID
    ) as NPCPuppet;
    if !IsDefined(npc) { return false; };
    for boss in this.m_bosses {
      if Equals(boss.siteID, siteID) && !boss.fallback {
        let original: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), boss.actorID
        ) as NPCPuppet;
        if IsDefined(original) { return false; };
      };
    };
    for action in RepeatableCyberpsychoDatabase.Actions(siteID) {
      if action.bossSpawner && this.LooksLikeCyberpsycho(npc, action.bossRecord) {
        if this.RememberBoss(siteID, actorID, true) {
          this.PrepareReplayBoss(npc);
          return true;
        };
      };
    };
    return false;
  }

  private func LooksLikeCyberpsycho(npc: ref<NPCPuppet>, expectedRecord: String) -> Bool {
    let recordName: String = TDBID.ToStringDEBUG(npc.GetRecordID());
    if NotEquals(expectedRecord, "") { return Equals(recordName, expectedRecord); };
    if npc.IsBoss() || Equals(npc.GetNPCRarity(), gamedataNPCRarity.Boss) { return true; };
    return StrContains(UTF8StrLower(recordName), "psycho");
  }

  private func PrepareReplayBoss(npc: ref<NPCPuppet>) -> Void {
    if this.m_heightenedAwareness {
      // Remove stale avoid-LOS delay, but never clear freshly established
      // threats. Clearing here was why bosses returned to idle/faced away.
      npc.GetAIControllerComponent().GetActionBlackboard().SetFloat(
        GetAllBlackboardDefs().AIAction.avoidLOSTimeStamp, 0.00
      );
    };
    GameObject.ChangeAttitudeToHostile(npc, GetPlayer(this.GetGameInstance()));
  }

  private func RememberBoss(siteID: String, actorID: EntityID, fallback: Bool) -> Bool {
    for boss in this.m_bosses {
      if Equals(boss.siteID, siteID) {
        if !fallback && boss.fallback {
          boss.actorID = actorID;
          boss.fallback = false;
          boss.combatPrepared = false;
          return true;
        };
        let current: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), boss.actorID
        ) as NPCPuppet;
        if IsDefined(current) && NotEquals(boss.actorID, actorID) { return false; };
        boss.actorID = actorID;
        boss.fallback = fallback;
        boss.combatPrepared = false;
        return true;
      };
    };
    let boss: ref<RepeatableCyberpsychoBossRuntime> = new RepeatableCyberpsychoBossRuntime();
    boss.siteID = siteID;
    boss.actorID = actorID;
    boss.fallback = fallback;
    boss.combatPrepared = false;
    ArrayPush(this.m_bosses, boss);
    return true;
  }

  private func EngageReplayBoss(npc: ref<NPCPuppet>, player: ref<PlayerPuppet>) -> Void {
    if !IsDefined(npc) || !IsDefined(player) { return; };
    AIActionHelper.TryChangingAttitudeToHostile(npc, player);
    GameObject.ChangeAttitudeToHostile(npc, player);
    NPCStatesComponent.AlertPuppet(npc);
    npc.GetTargetTrackerComponent().AddThreat(
      player, true, player.GetWorldPosition(), 1.00, -1.00, false
    );
  }

  private func UpdateReplayAwareness() -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    if !IsDefined(player) { return; };
    for boss in this.m_bosses {
      if this.GetStatus(boss.siteID) == EnumInt(RepeatableCyberpsychoStatus.Active) {
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), boss.actorID
        ) as NPCPuppet;
        if IsDefined(npc) {
          let distance: Float = Vector4.Distance2D(npc.GetWorldPosition(), player.GetWorldPosition());
          let radius: Float = this.m_heightenedAwareness
            ? RepeatableCyberpsychoDatabase.HostileRadius(boss.siteID)
            : 18.0;
          if distance <= radius || (this.m_blockStealthTakedowns && distance <= 4.5) {
            this.EngageReplayBoss(npc, player);
          };
        };
      };
    };
  }

  public func ShouldBlockTakedown(npc: ref<NPCPuppet>) -> Bool {
    if !this.m_blockStealthTakedowns || !IsDefined(npc) { return false; };
    for boss in this.m_bosses {
      if Equals(boss.actorID, npc.GetEntityID())
        && this.GetStatus(boss.siteID) == EnumInt(RepeatableCyberpsychoStatus.Active) {
        return true;
      };
    };
    return false;
  }

  public func CounterTakedown(npc: ref<NPCPuppet>) -> Void {
    this.EngageReplayBoss(npc, GetPlayer(this.GetGameInstance()));
  }

  public func OnBossDefeated(npc: ref<NPCPuppet>) -> Void {
    if !IsDefined(npc) { return; };
    for boss in this.m_bosses {
      if Equals(boss.actorID, npc.GetEntityID()) {
        this.CompleteSite(boss.siteID);
        return;
      };
    };
  }

  private func CompleteSite(siteID: String) -> Void {
    let index: Int32 = this.FindState(siteID);
    if index < 0 || NotEquals(this.m_states[index].status, RepeatableCyberpsychoStatus.Active) { return; };

    let now: Int32 = this.NowSeconds();
    this.m_states[index].status = RepeatableCyberpsychoStatus.Cooldown;
    this.m_states[index].nextEligibleAt = now
      + Cast<Int32>(this.m_cooldownHours * 3600.0);
    // The NPC inventory is stable only after the defeated/unconscious state is
    // committed. CET injects configured body loot after this short delay.
    this.m_states[index].bodyRewardPending = true;
    this.m_states[index].bodyRewardReadyAt = now + 2;
    // Keep the mod-owned community alive long enough for the normal defeated
    // body, nonlethal state, and inventory to remain in the world. Cleanup waits
    // at least two in-game minutes and then requires the player to leave the area.
    this.m_states[index].cleanupReadyAt = now + 120;
    this.m_totalClears += 1;
    this.m_pendingCompletionRewards += 1;
    this.Tick();
  }

  private func CleanupDefeatedSites(now: Int32) -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
    let i: Int32 = 0;
    while i < ArraySize(this.m_states) {
      if Equals(this.m_states[i].status, RepeatableCyberpsychoStatus.Cooldown)
        && this.m_states[i].ownedActivation
        && this.m_states[i].cleanupReadyAt > 0
        && this.m_states[i].cleanupReadyAt <= now {
        let bossID: EntityID = this.GetBossEntityID(this.m_states[i].siteID);
        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(
          this.GetGameInstance(), bossID
        ) as NPCPuppet;
        let canClean: Bool = !IsDefined(npc);
        if IsDefined(npc) && IsDefined(player) {
          canClean = Vector4.Distance2D(npc.GetWorldPosition(), player.GetWorldPosition()) > 120.0;
        };
        if canClean {
          this.DeactivateSite(this.m_states[i].siteID);
          this.m_states[i].ownedActivation = false;
          this.m_states[i].cleanupReadyAt = 0;
          this.RemoveBoss(this.m_states[i].siteID);
        };
      };
      i += 1;
    };
  }

  private func RemoveBoss(siteID: String) -> Void {
    let i: Int32 = ArraySize(this.m_bosses) - 1;
    while i >= 0 {
      if Equals(this.m_bosses[i].siteID, siteID) { ArrayErase(this.m_bosses, i); };
      i -= 1;
    };
    let pendingIndex: Int32 = ArraySize(this.m_pendingBosses) - 1;
    while pendingIndex >= 0 {
      if Equals(this.m_pendingBosses[pendingIndex].siteID, siteID) {
        ArrayErase(this.m_pendingBosses, pendingIndex);
      };
      pendingIndex -= 1;
    };
  }
}

@addMethod(ScriptableDeviceComponentPS)
public final func RepeatableCyberpsychoForcePower() -> Void {
  this.QueuePSEvent(this, this.ActionQuestForcePower());
}

@addMethod(DoorControllerPS)
public final func RepeatableCyberpsychoForceUnlock() -> Void {
  this.QueuePSEvent(this, this.ActionQuestForceUnlock());
}

@addMethod(DoorControllerPS)
public final func RepeatableCyberpsychoForceOpen() -> Void {
  this.QueuePSEvent(this, this.ActionQuestForceOpen());
}

@addMethod(ScriptableDeviceComponentPS)
public final func RepeatableCyberpsychoForceON() -> Void {
  this.QueuePSEvent(this, this.ActionQuestForceON());
}

@wrapMethod(gamestateMachineComponent)
protected cb func OnStartTakedownEvent(evt: ref<StartTakedownEvent>) -> Bool {
  let target: ref<NPCPuppet> = evt.target as NPCPuppet;
  let player: ref<PlayerPuppet> = this.GetEntity() as PlayerPuppet;
  if IsDefined(player) && IsDefined(target) {
    let system: ref<RepeatableCyberpsychosSystem> = RepeatableCyberpsychosSystem.GetInstance(player.GetGame());
    if IsDefined(system) && system.ShouldBlockTakedown(target) {
      // Cancel the takedown state before damage is applied, then use the normal
      // threat system so the psycho turns and counterattacks immediately.
      system.CounterTakedown(target);
      return false;
    };
  };
  return wrappedMethod(evt);
}

@wrapMethod(CommunityProxyPS)
public final func OnGameEntitySpawnerEvent(evt: ref<gameEntitySpawnerEvent>) -> EntityNotificationType {
  let result: EntityNotificationType = wrappedMethod(evt);
  let system: ref<RepeatableCyberpsychosSystem> = RepeatableCyberpsychosSystem.GetInstance(this.GetGameInstance());
  if IsDefined(system) { system.OnSpawnerEvent(this, evt); };
  return result;
}

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  let system: ref<RepeatableCyberpsychosSystem> = RepeatableCyberpsychosSystem.GetInstance(this.GetGame());
  if IsDefined(system) { system.OnBossDefeated(this); };
  return result;
}

@wrapMethod(NPCPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  if IsDefined(evt) && IsDefined(evt.staticData) {
    let status: String = UTF8StrLower(TDBID.ToStringDEBUG(evt.staticData.GetID()));
    if StrContains(status, "defeated") || StrContains(status, "unconscious") {
      let system: ref<RepeatableCyberpsychosSystem> = RepeatableCyberpsychosSystem.GetInstance(this.GetGame());
      if IsDefined(system) { system.OnBossDefeated(this); };
    };
  };
  return result;
}

@wrapMethod(BaseWorldMapMappinController)
protected cb func OnIntro() -> Bool {
  let result: Bool = wrappedMethod();
  this.ApplyRepeatableCyberpsychoColor(this.GetWidget(inkWidgetPath.Build(n"Canvas")));
  return result;
}

@wrapMethod(QuestMappinController)
protected cb func OnIntro() -> Bool {
  let result: Bool = wrappedMethod();
  this.ApplyRepeatableCyberpsychoColor(this.GetRootWidget());
  return result;
}

@wrapMethod(MinimapPOIMappinController)
protected func Intro() -> Void {
  wrappedMethod();
  this.ApplyRepeatableCyberpsychoColor(this.GetWidget(inkWidgetPath.Build(n"Canvas")));
}

@addMethod(BaseMappinBaseController)
protected func ApplyRepeatableCyberpsychoColor(widget: ref<inkWidget>) -> Void {
  let system: ref<RepeatableCyberpsychosSystem> = RepeatableCyberpsychosSystem.GetInstance(GetGameInstance());
  if !IsDefined(system) || !system.GetChangeMappinColor() || !IsDefined(this.GetMappin()) { return; };
  if system.IsOwnedMappinPosition(this.GetMappin().GetWorldPosition()) {
    this.TintRepeatableCyberpsychoChildren(widget);
  };
}

@addMethod(BaseMappinBaseController)
protected func TintRepeatableCyberpsychoChildren(widget: ref<inkWidget>) -> Void {
  if !IsDefined(widget) { return; };
  let container: ref<inkCompoundWidget> = widget as inkCompoundWidget;
  if IsDefined(container) {
    let i: Int32 = 0;
    while i < container.GetNumChildren() {
      this.TintRepeatableCyberpsychoChildren(container.GetWidget(i));
      i += 1;
    };
  } else {
    if IsDefined(widget as inkImage) || IsDefined(widget as inkText) {
      // Purple keeps replay sightings distinct from original blue Regina pins.
      widget.SetTintColor(new HDRColor(0.82, 0.32, 1.0, 1.0));
    };
  };
}
