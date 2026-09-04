// =====================================================================
//  COMBAT ARENA - THE RUN
//
//  The whole game loop lives here now: state machine, wave planning,
//  spawn queue, clock, eddie economy, allies and perks.
//
//  There is no per-frame hook in REDscript, so the loop is driven by a
//  DelayCallback that reschedules itself on a fixed 0.25s tick. Fixed
//  step means the clock cannot drift with framerate.
// =====================================================================

// Each Boot() starts a new tick generation; a stale generation kills
// itself on its next fire. That makes restarting the loop always safe -
// no stuck aliveness flag, no double-rate ticking.
public class ArenaTick extends DelayCallback {
  public let gen: Int32;
  protected func Call() -> Void {
    let sys = ArenaSystem.Get();
    if IsDefined(sys) { sys.Tick(this.gen); };
  }
}

public class ArenaSystem extends ScriptableService {

  // ---------------------------------------------------------- tuning
  public static func TICK() -> Float { return 0.25; }
  public static func STARTING_SHARDS() -> Int32 { return 300; }
  public static func GRUNT_BASE() -> Int32 { return 12; }
  public static func GRUNT_PER_WAVE() -> Int32 { return 3; }
  public static func BOSS_BOUNTY() -> Int32 { return 250; }
  public static func WAVE_CLEAR_BASE() -> Int32 { return 50; }
  public static func COMBO_WINDOW() -> Float { return 6.0; }
  // Matched to the old mod's tuning, which you'd already dialled in.
  public static func SPAWN_DELAY() -> Float { return 1.5; }
  public static func WAVE_SETTLE() -> Float { return 5.0; }
  public static func SECOND_WIND_AT() -> Float { return 20.0; }

  // ----------------------------------------------------------- state
  //  0 idle | 1 lobby | 2 fighting | 3 results
  public let state: Int32;
  //  0 none | 1 victory | 2 timeout | 3 flatlined
  public let result: Int32;

  public let wave: Int32;
  public let totalWaves: Int32;
  public let enemiesAlive: Int32;
  public let timeLeft: Float;
  public let timeTotal: Float;

  public let shards: Int32;
  public let earned: Int32;
  public let spent: Int32;
  public let kills: Int32;
  public let bossKills: Int32;
  public let combo: Float;
  public let comboTimer: Float;
  public let peakCombo: Float;

  public let godMode: Bool;
  // Filthy Rich: shards pinned high, purchases free. The wallet as it
  // stood is remembered and restored when the cheat is switched off.
  public let richMode: Bool;
  public let playedThisVisit: Bool;
  private let richBackup: Int32;
  public let enemyHealthMult: Float;

  //  0 EASY | 1 NORMAL | 2 HARD | 3 DEATHMODE. Kept between runs.
  //  Only shapes the DEFAULT mode; gauntlet mode is its own config.
  public let difficulty: Int32;

  // Gauntlet mode - the old mod's custom-run options, verbatim:
  // wave count, enemies-per-wave CSV, boss count (Smasher always last,
  // extras land on random earlier waves), free starting crew, time cap.
  public let gauntletEnabled: Bool;
  public let gauntletWaves: Int32;
  public let gauntletCsv: String;
  public let gauntletBosses: Int32;
  public let gauntletAllies: Int32;
  public let gauntletTime: Int32;

  // The entry sequence: rooted, wired in, then dropped in.
  public let entering: Bool;
  private let entryLeft: Float;

  // The one open terminal window, if any.
  public let terminal: ref<ArenaTerminal>;

  // Crew hired this run - each member can only join once.
  public let hiredAllies: array<Int32>;

  // Persistent HUD line, attached by ArenaHudBuilder.
  public let hudText: wref<inkText>;

  private let tickGen: Int32;
  private let secondWind: Bool;
  private let beatTimer: Float;
  private let entryHintTimer: Float;
  private let wasNearEntry: Bool;
  private let pointOrder: array<Int32>;
  private let pointCursor: Int32;

  // Countdown before a wave starts, so you can sort your loadout.
  public let prepSeconds: Int32;
  private let prepLeft: Float;
  private let lastPrepShown: Int32;

  // Bodies are left where they fall, so kills are counted by watching the
  // alive count drop rather than by deleting corpses.
  private let lastAlive: Int32;
  private let lastAliveBoss: Int32;
  private let hudTimer: Float;
  private let spawnCooldown: Float;
  private let waveSettle: Float;
  private let hostilityTimer: Float;
  private let patrolTimer: Float;
  private let rallyTimer: Float;

  private let waveSizes: array<Int32>;
  private let bossWave: array<Int32>;        // parallel to spawn queue below
  private let queueIds: array<TweakDBID>;
  private let queueIsBoss: array<Bool>;

  private let givenWeapons: array<TweakDBID>;
  private let returnPos: Vector4;
  private let hasReturnPos: Bool;

  // Your own weapons, held while you are inside the arena.
  private let stashIds: array<ItemID>;
  private let stashQty: array<Int32>;

  // cached data
  private let weapons: array<ref<ArenaWeapon>>;
  private let allies: array<ref<ArenaAlly>>;
  private let perks: array<ref<ArenaPerk>>;
  private let points: array<Vector4>;

  // =================================================================
  //  LIFECYCLE
  // =================================================================

  private cb func OnLoad() {
    this.state = 0;
    this.result = 0;
    this.enemyHealthMult = 1.0;
    this.combo = 1.0;
    this.peakCombo = 1.0;
    this.tickGen = 0;
    this.prepSeconds = 10;
    this.difficulty = 1;
    this.gauntletEnabled = false;
    this.gauntletWaves = 4;
    this.gauntletCsv = "1,3,4,2,6";
    this.gauntletBosses = 1;
    this.gauntletAllies = 0;
    this.gauntletTime = 300;
    this.entering = false;

    this.weapons = ArenaData.Weapons();
    this.allies  = ArenaData.Allies();
    this.perks   = ArenaData.Perks();
    this.points  = ArenaData.ArenaPoints();

    ModLog(n"CombatArena", "=====================================");
    ModLog(n"CombatArena", "BUILD " + ArenaSystem.BUILD() + " loaded");
    ModLog(n"CombatArena", ToString(ArraySize(this.weapons)) + " weapons, "
      + ToString(ArraySize(this.allies)) + " allies");
    ModLog(n"CombatArena", "=====================================");
  }

  // Bumped every iteration so the log always says which build is live.
  public static func BUILD() -> String {
    return "47";
  }

  // Set the persistent HUD line. Empty hides it. No re-issuing, no
  // flicker - the widget just holds whatever it was last given.
  public func SetHud(line: String) -> Void {
    // Lazy attach: works identically on cold boot and hot reload.
    ArenaHudBuilder.Ensure();
    if !IsDefined(this.hudText) { return; }
    if Equals(line, "") {
      this.hudText.SetVisible(false);
      return;
    };
    this.hudText.SetText(line);
    this.hudText.SetVisible(true);
  }

  public static func Get() -> ref<ArenaSystem> {
    return GameInstance.GetScriptableServiceContainer().GetService(n"ArenaSystem") as ArenaSystem;
  }

  private func StartTicking() {
    this.tickGen += 1;
    let tick = new ArenaTick();
    tick.gen = this.tickGen;
    GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(tick, ArenaSystem.TICK(), false);
  }

  // Called when the player attaches - on every session, including after
  // quitting to menu mid-run. Cleans up anything a torn-down session
  // could have left behind, then starts a fresh tick generation.
  public func Boot() -> Void {
    // If a previous run ended abruptly, hand your weapons back now.
    // (Must run before ColdReset zeroes the stash bookkeeping.)
    this.RestoreOwnWeapons();
    this.ColdReset();
    ArenaSpawner.ClearMenuState();
    // A quit mid-entry must not leave you rooted or half-committed.
    this.entering = false;
    ArenaSpawner.LockPlayerMovement(false);
    let svc = ArenaSpawner.GetService();
    if IsDefined(svc) {
      svc.exitHolding = false;
      svc.pendingCommand = 0;
    };
    // Entrance map pins: through Custom Map Markers when installed
    // (named, colored, both maps), otherwise the built-in service pins.
    if CombatArenaCmmAvailable() {
      CombatArenaRegisterCmmMarkers(ArenaSpawner.EntryPositions());
    } else {
      ArenaSpawner.RegisterEntryMappins();
    };
    this.StartTicking();
    ModLog(n"CombatArena", "Boot: tick generation " + ToString(this.tickGen));
  }

  // This service outlives save files - it is alive for the whole game
  // process. Booting into a session while the arena is still "live" in
  // memory means the player loaded another save mid-visit: the save
  // file is authoritative, the arena state is stale garbage. Drop it
  // cold - no payout, no teleport, no touching the loaded inventory.
  private func ColdReset() -> Void {
    if this.state == 0 { return; }
    ModLog(n"CombatArena", "Boot with stale arena state " + ToString(this.state)
      + " - save was loaded mid-visit, cold reset");
    ArenaSpawner.DespawnAll();
    ArenaSpawner.DespawnAllies();
    ArenaSpawner.SetEnemyHealthMultiplier(1.0);
    this.terminal = null;
    ArrayClear(this.givenWeapons);
    this.state = 0;
    this.result = 0;
    this.shards = 0;
    this.secondWind = false;
    this.hasReturnPos = false;
    this.playedThisVisit = false;
    this.godMode = false;
    this.richMode = false;
    this.ResetScore();
    this.SetHud("");
  }

  // =================================================================
  //  DATA ACCESS  (used by the terminal UI)
  // =================================================================

  public func GetWeapons() -> array<ref<ArenaWeapon>> { return this.weapons; }
  public func GetAllies() -> array<ref<ArenaAlly>> { return this.allies; }
  public func GetPerks() -> array<ref<ArenaPerk>> { return this.perks; }

  public func CanAfford(price: Int32) -> Bool { return this.shards >= price; }

  public func IsHired(index: Int32) -> Bool {
    let i = 0;
    while i < ArraySize(this.hiredAllies) {
      if this.hiredAllies[i] == index { return true; };
      i += 1;
    };
    return false;
  }

  // Elite = the heavy hitters: tier 3 and up (1400+ shards), plus the
  // Minotaur and the Wraith Raider, which punch above their price.
  public func IsEliteAlly(index: Int32) -> Bool {
    let a = this.allies[index];
    if a.tier >= 3 { return true; };
    if Equals(a.name, "Militech Minotaur") { return true; };
    if Equals(a.name, "Wraith Raider") { return true; };
    return false;
  }

  // Elites are capped at TWO HIRES PER RUN - death does not refund one.
  public func HiredEliteCount() -> Int32 {
    let count = 0;
    let i = 0;
    while i < ArraySize(this.hiredAllies) {
      if this.IsEliteAlly(this.hiredAllies[i]) { count += 1; };
      i += 1;
    };
    return count;
  }

  // Regulars are capped at three ALIVE at once - a death frees a slot.
  public func AliveRegularAllies() -> Int32 {
    let regulars = ArenaSpawner.GetAliveAllyCount() - ArenaSpawner.GetAliveEliteAllyCount();
    if regulars < 0 { regulars = 0; };
    return regulars;
  }

  // Cheapest-but-best ally you can currently pay for, have not already
  // hired, and have quota for.
  public func BestAffordableAlly() -> ref<ArenaAlly> {
    let elitesFull = this.HiredEliteCount() >= 2;
    let regularsFull = this.AliveRegularAllies() >= 3;
    let best: ref<ArenaAlly>;
    let bestPrice = -1;
    let i = 0;
    while i < ArraySize(this.allies) {
      let a = this.allies[i];
      let blocked = this.IsEliteAlly(i) ? elitesFull : regularsFull;
      if a.price <= this.shards && a.price > bestPrice && !this.IsHired(i) && !blocked {
        best = a;
        bestPrice = a.price;
      };
      i += 1;
    };
    return best;
  }

  // =================================================================
  //  ENTRY / EXIT
  // =================================================================

  // Step 1: the ritual. You are rooted where you stand, the braindance
  // wire-up plays for 3 seconds, then CompleteEntry drops you in.
  public func EnterArena() -> Void {
    ModLog(n"CombatArena", "EnterArena() called, state=" + ToString(this.state));
    if this.state != 0 || this.entering {
      ModLog(n"CombatArena", "  refused: not idle");
      return;
    };
    if !ArenaSpawner.IsInGameplay() {
      ModLog(n"CombatArena", "  refused: not in gameplay");
      return;
    };

    if ArenaSpawner.IsPlayerInVehicle() {
      ModLog(n"CombatArena", "  refused: in vehicle");
      ArenaSpawner.Notify("GET OUT OF THE VEHICLE FIRST", 3.0);
      return;
    };

    ArenaSpawner.HideEntryHub();
    this.entering = true;
    this.entryLeft = 3.0;
    ArenaSpawner.LockPlayerMovement(true);
    // The braindance wire-up sound, but no voice line - V stays quiet.
    ArenaSpawner.PlaySound(n"g_sc_bd_rewind_forward");
    ArenaSpawner.Notify("ENTERING ARENA ...", 2.5);
    ModLog(n"CombatArena", "  entry sequence started");
  }

  // Step 2: the drop. Everything that used to happen instantly.
  private func CompleteEntry() -> Void {
    ArenaSpawner.LockPlayerMovement(false);
    ArenaSpawner.PlaySound(n"g_sc_bd_rewind_forward_end");
    if this.state != 0 || !ArenaSpawner.IsInGameplay() { return; }

    // Remember where we were standing so exiting puts us back.
    this.returnPos = GetPlayer(GetGameInstance()).GetWorldPosition();
    this.hasReturnPos = true;

    ArenaSpawner.DespawnAll();
    ArenaSpawner.DespawnAllies();
    ArrayClear(this.givenWeapons);
    this.StashOwnWeapons();

    // The stake is your own money now: up to $300 of real eddies buys
    // your shards (all you have, if you carry less). It comes back out
    // only on a winning exit.
    let gi = GetGameInstance();
    let ts = GameInstance.GetTransactionSystem(gi);
    let buyIn = ts.GetItemQuantity(GetPlayer(gi), ItemID.FromTDBID(t"Items.money"));
    if buyIn > ArenaSystem.STARTING_SHARDS() { buyIn = ArenaSystem.STARTING_SHARDS(); };
    if buyIn > 0 { ts.RemoveItemByTDBID(GetPlayer(gi), t"Items.money", buyIn); };
    this.shards = buyIn;
    this.playedThisVisit = false;
    this.ResetScore();

    // Drop somewhere random in the arena.
    let drop = this.points[RandRange(0, ArraySize(this.points))];
    ArenaSpawner.TeleportPlayer(drop.X, drop.Y, drop.Z);

    this.PushPatrolPoints();
    this.state = 1;
    this.result = 0;
    this.ApplyGodMode();
    this.StartTicking();

    ArenaSpawner.PlaySound(n"ui_loading_bar_stop");
    ArenaSpawner.Notify("ENTERED THE ARENA // BUY-IN: -$" + ToString(this.shards), 4.0);

    ModLog(n"CombatArena", "  entered OK, opening terminal");

    // The terminal comes up on arrival, the way a shop or a BD does.
    ArenaTerminal.Open();
  }

  public func ExitArena() -> Void {
    if this.state == 0 { return; }

    // The pot is your own buy-in grown, and it pays out in real eddies
    // only when you leave on a WIN. Losing - or bailing mid-run -
    // forfeits everything; exiting before ever starting a run just
    // hands the remaining buy-in back. Filthy Rich money is the BD's,
    // not yours - no payout while it is on.
    // A winning pot pays out scaled by how hard you had it: x0.25 easy,
    // x0.75 normal, x1 hard, x2 deathmode. The untouched-visit refund
    // is not winnings and goes back 1:1.
    let payout = 0;
    if !this.richMode {
      if !this.playedThisVisit {
        payout = this.shards;
      } else {
        if this.result == 1 {
          payout = Cast<Int32>(Cast<Float>(this.shards) * this.ReturnMult());
        };
      };
    };
    let forfeited = payout == 0 && this.shards > 0 && !this.richMode;
    if payout > 0 {
      let gi = GetGameInstance();
      GameInstance.GetTransactionSystem(gi)
        .GiveItemByTDBID(GetPlayer(gi), t"Items.money", payout);
    };

    ArenaSpawner.DespawnAll();
    ArenaSpawner.DespawnAllies();
    this.StripWeapons();
    this.RestoreOwnWeapons();
    ArenaSpawner.StopArenaMusic();
    ArenaSpawner.SetPlayerImmortal(false);
    ArenaSpawner.HealPlayer();

    if this.hasReturnPos {
      ArenaSpawner.TeleportPlayer(this.returnPos.X, this.returnPos.Y, this.returnPos.Z);
    };
    this.hasReturnPos = false;

    this.state = 0;
    this.result = 0;
    this.shards = 0;
    this.secondWind = false;
    this.ResetScore();
    this.SetHud("");

    ArenaSpawner.PlaySound(n"ui_menu_close");
    if payout > 0 && !this.playedThisVisit {
      ArenaSpawner.Notify("EXITED THE ARENA // BUY-IN RETURNED: +$" + ToString(payout), 4.0);
    } else {
      if payout > 0 {
        ArenaSpawner.Notify("EXITED THE ARENA // WINNINGS PAID: +$" + ToString(payout), 4.0);
      } else {
        if forfeited {
          ArenaSpawner.Notify("EXITED THE ARENA // POT FORFEITED", 4.0);
        } else {
          ArenaSpawner.Notify("EXITED THE ARENA", 3.0);
        };
      };
    };
    ModLog(n"CombatArena", "ExitArena: payout " + ToString(payout)
      + " result " + ToString(this.result));
  }

  private func ResetScore() {
    this.kills = 0;
    this.bossKills = 0;
    this.earned = 0;
    this.spent = 0;
    this.combo = 1.0;
    this.comboTimer = 0.0;
    this.peakCombo = 1.0;
    this.wave = 1;
    this.enemiesAlive = 0;
    ArrayClear(this.queueIds);
    ArrayClear(this.queueIsBoss);
    ArrayClear(this.hiredAllies);
  }

  // =================================================================
  //  RUN LIFECYCLE
  // =================================================================

  public func StartRun() -> Void {
    if this.state != 1 && this.state != 3 { return; }

    ArenaSpawner.DespawnAll();
    ArenaSpawner.DespawnAllies();

    // Keep leftover shards; only the scoreboard resets.
    let keep = this.shards;
    this.ResetScore();
    this.shards = keep;

    if this.gauntletEnabled {
      // The old mod's custom run, exactly: your wave list, your bosses,
      // your clock. Difficulty presets stay out of it.
      this.waveSizes = this.ResolveGauntletWaves();
      this.totalWaves = ArraySize(this.waveSizes);
      this.PlanBosses();
      this.timeTotal = Cast<Float>(this.gauntletTime);
      if this.timeTotal < 30.0 { this.timeTotal = 30.0; };
    } else {
      this.waveSizes = ArenaData.WaveSizes();
      // Easy trims a body off each wave; Hard and Deathmode add them.
      // The final 0-size wave is Smasher alone and stays that way.
      let adj = 0;
      if this.difficulty == 0 { adj = -1; };
      if this.difficulty == 2 { adj = 1; };
      if this.difficulty == 3 { adj = 2; };
      if adj != 0 {
        let wi = 0;
        while wi < ArraySize(this.waveSizes) {
          if this.waveSizes[wi] > 0 {
            this.waveSizes[wi] += adj;
            if this.waveSizes[wi] < 1 { this.waveSizes[wi] = 1; };
          };
          wi += 1;
        };
      };
      this.totalWaves = ArraySize(this.waveSizes);
      this.PlanBosses();
      this.timeTotal = ArenaData.RunSeconds();
    };
    this.timeLeft = this.timeTotal;
    ModLog(n"CombatArena", "run: " + (this.gauntletEnabled ? "GAUNTLET " : "")
      + ToString(this.totalWaves) + " waves, " + ToString(Cast<Int32>(this.timeTotal)) + "s");
    this.prepLeft = Cast<Float>(this.prepSeconds);
    this.lastPrepShown = -1;
    this.lastAlive = 0;
    this.lastAliveBoss = 0;
    this.state = 2;
    this.result = 0;
    this.playedThisVisit = true;
    this.secondWind = false;
    this.spawnCooldown = 0.0;
    this.hostilityTimer = 3.0;
    this.patrolTimer = 10.0;
    this.rallyTimer = 6.0;

    // Make absolutely sure the terminal is shut and the world is running
    // at normal speed before the first wave lands.
    if IsDefined(this.terminal) {
      this.terminal.Close();
      this.terminal = null;
    };
    ArenaSpawner.ClearMenuState();

    ArenaSpawner.HealPlayer();
    ArenaSpawner.SetEnemyHealthMultiplier(this.ScaledEnemyHealth());
    this.PushPatrolPoints();
    ArenaSpawner.PlayArenaMusic();

    // Immortal for the whole run. Flatlining is handled by us at low
    // health so you drop back into the arena menu instead of the game's
    // death screen and a full reload.
    ArenaSpawner.SetPlayerImmortal(true);

    this.QueueWave(1);
    if this.gauntletEnabled { this.SpawnGauntletCrew(); };
    ArenaSpawner.PlaySound(n"ui_hacking_access_granted");
    this.StartTicking();
  }

  // =================================================================
  //  DIFFICULTY
  //  Easy pays fat stacks for soft targets; Deathmode pays coupons for
  //  bullet sponges with extra bosses. Normal is the old tuning.
  // =================================================================

  public func DiffName() -> String {
    if this.difficulty == 0 { return "EASY"; };
    if this.difficulty == 2 { return "HARD"; };
    if this.difficulty == 3 { return "DEATHMODE"; };
    return "NORMAL";
  }

  private func DiffHealthMult() -> Float {
    if this.gauntletEnabled { return 1.0; };
    if this.difficulty == 0 { return 0.85; };
    if this.difficulty == 2 { return 1.60; };
    if this.difficulty == 3 { return 2.10; };
    return 1.20;
  }

  // Share of the pot a WINNING exit pays out, by difficulty. The house
  // skims easy runs and doubles deathmode ones.
  private func ReturnMult() -> Float {
    if this.gauntletEnabled { return 1.0; };
    if this.difficulty == 0 { return 0.25; };
    if this.difficulty == 2 { return 1.0; };
    if this.difficulty == 3 { return 2.0; };
    return 0.75;
  }

  private func DiffPayMult() -> Float {
    if this.gauntletEnabled { return 1.0; };
    if this.difficulty == 0 { return 1.60; };
    if this.difficulty == 2 { return 0.85; };
    if this.difficulty == 3 { return 0.70; };
    return 1.0;
  }

  // Enemies start soft and toughen as you get richer, then stop. Shards
  // earned this session is the yardstick: it tracks how well you are
  // actually doing rather than just how long you have survived.
  private func ScaledEnemyHealth() -> Float {
    let scale = 0.65 + Cast<Float>(this.earned) / 4000.0;
    if scale > 2.0 { scale = 2.0; };
    return scale * this.enemyHealthMult * this.DiffHealthMult();
  }

  // Full health back immediately, then straight to the terminal. Public
  // so the OnDeath backstop can call it too.
  public func Flatline() -> Void {
    if this.state != 2 { return; }
    ArenaSpawner.HealPlayer();
    this.EndRun(3);
  }

  private func EndRun(outcome: Int32) {
    this.state = 3;
    this.result = outcome;
    ArenaSpawner.DespawnAll();
    ArenaSpawner.DespawnAllies();
    ArenaSpawner.StopArenaMusic();
    ArenaSpawner.HealPlayer();
    ArenaSpawner.ClearNotify();

    // Flatlining puts you back on your feet in the arena with the
    // terminal open, not on the game's death screen.
    ArenaTerminal.Open();

    if outcome == 1 {
      ArenaSpawner.Notify("ARENA CLEARED // " + ToString(this.kills) + " KILLS", 5.0);
      ArenaSpawner.PlaySound(n"ui_loot_rarity_legendary");
    } else {
      if outcome == 3 {
        ArenaSpawner.Notify("YOU DIED", 5.0);
        ArenaSpawner.PlaySound(n"ui_death");
      } else {
        ArenaSpawner.Notify("TIME'S UP // " + ToString(this.kills) + " KILLS", 5.0);
        ArenaSpawner.PlaySound(n"ui_jingle_chip_malfunction");
      };
    };
  }

  // "1,3,4,2,6" -> wave sizes. Falls back to the default pattern cycled
  // out to the wave count when the CSV is empty or unparseable, and is
  // truncated to the wave count - the old mod's exact resolution rules.
  private func ResolveGauntletWaves() -> array<Int32> {
    let out: array<Int32>;
    let parts = StrSplit(this.gauntletCsv, ",");
    let i = 0;
    while i < ArraySize(parts) {
      let n = StringToInt(parts[i]);
      if n > 0 && n <= 20 { ArrayPush(out, n); };
      i += 1;
    };
    if ArraySize(out) == 0 {
      let pattern = ArenaData.WaveSizes();
      let k = 0;
      let pi = 0;
      while k < this.gauntletWaves {
        // Cycle 1,3,5 - skipping the boss-only 0 entry.
        if pattern[pi % ArraySize(pattern)] > 0 {
          ArrayPush(out, pattern[pi % ArraySize(pattern)]);
          k += 1;
        };
        pi += 1;
      };
    };
    while ArraySize(out) > this.gauntletWaves {
      ArrayPop(out);
    };
    return out;
  }

  // bossWave[w] = how many pool bosses spawn in wave w+1. Adam Smasher
  // is implicit in the final wave, always, in both modes - QueueWave
  // adds him on top. Gauntlet scatters its extra bosses over random
  // earlier waves the way the old mod did; the difficulty presets place
  // theirs deterministically.
  private func PlanBosses() {
    ArrayClear(this.bossWave);
    let i = 0;
    while i < this.totalWaves {
      ArrayPush(this.bossWave, 0);
      i += 1;
    };

    if this.gauntletEnabled {
      let extras = this.gauntletBosses - 1;
      if extras > 0 && this.totalWaves > 1 {
        let e = 0;
        while e < extras {
          this.bossWave[RandRange(0, this.totalWaves - 1)] += 1;
          e += 1;
        };
      };
    } else {
      if this.difficulty == 2 && this.totalWaves >= 3 { this.bossWave[2] = 1; };
      if this.difficulty == 3 && this.totalWaves >= 4 {
        this.bossWave[1] = 1;
        this.bossWave[3] = 1;
      };
    };
  }

  // The old mod picked DISTINCT spawn points per wave via a shuffle, so
  // enemies never stack on one spot. Restoring that: shuffle once per
  // wave and deal points off the top.
  private func ShufflePoints() {
    ArrayClear(this.pointOrder);
    let i = 0;
    while i < ArraySize(this.points) {
      ArrayPush(this.pointOrder, i);
      i += 1;
    };
    let k = ArraySize(this.pointOrder) - 1;
    while k > 0 {
      let j = RandRange(0, k + 1);
      let tmp = this.pointOrder[k];
      this.pointOrder[k] = this.pointOrder[j];
      this.pointOrder[j] = tmp;
      k -= 1;
    };
    this.pointCursor = 0;
  }

  // Nothing spawns on top of you. Walks the shuffled order looking for a
  // point far enough away; if every point is close (you are stood in the
  // middle of a small arena) it takes the furthest one rather than
  // dropping an enemy in your lap.
  private func NextPoint() -> Vector4 {
    if ArraySize(this.pointOrder) == 0 { this.ShufflePoints(); };

    let playerPos = GetPlayer(GetGameInstance()).GetWorldPosition();
    let minDist = 12.0;

    let best: Vector4;
    let bestDist = -1.0;
    let tried = 0;

    while tried < ArraySize(this.pointOrder) {
      let idx = this.pointOrder[this.pointCursor % ArraySize(this.pointOrder)];
      this.pointCursor += 1;
      tried += 1;

      let candidate = this.points[idx];
      let d = Vector4.Distance(playerPos, candidate);
      if d >= minDist { return candidate; };

      if d > bestDist {
        bestDist = d;
        best = candidate;
      };
    };

    ModLog(n"CombatArena", "no point >= " + ToString(minDist) + "m from player, using " + ToString(bestDist) + "m");
    return best;
  }

  private func QueueWave(w: Int32) {
    ArrayClear(this.queueIds);
    ArrayClear(this.queueIsBoss);
    this.ShufflePoints();

    let count = this.waveSizes[w - 1];
    let heavyChance = MinF(0.55, 0.05 + Cast<Float>(w - 1) * 0.12);
    if !this.gauntletEnabled {
      if this.difficulty == 0 { heavyChance = heavyChance * 0.5; };
      if this.difficulty == 2 { heavyChance = MinF(0.65, heavyChance + 0.12); };
      if this.difficulty == 3 { heavyChance = MinF(0.75, heavyChance + 0.25); };
    };

    let i = 0;
    while i < count {
      let id: TweakDBID;
      if RandRangeF(0.0, 1.0) < heavyChance {
        let heavies = ArenaData.Heavies();
        id = heavies[RandRange(0, ArraySize(heavies))];
      } else {
        let grunts = ArenaData.Grunts();
        id = grunts[RandRange(0, ArraySize(grunts))];
      };
      ArrayPush(this.queueIds, id);
      ArrayPush(this.queueIsBoss, false);
      i += 1;
    };

    // Adam Smasher always closes the show.
    if w == this.totalWaves {
      ArrayPush(this.queueIds, ArenaData.FinalBoss());
      ArrayPush(this.queueIsBoss, true);
    };
    let extra = this.bossWave[w - 1];
    let b = 0;
    while b < extra {
      let pool = ArenaData.Bosses();
      ArrayPush(this.queueIds, pool[RandRange(0, ArraySize(pool))]);
      ArrayPush(this.queueIsBoss, true);
      b += 1;
    };

    this.enemiesAlive = 0;
    this.waveSettle = 0.0;
  }

  private func AdvanceWave() {
    let bonus = ArenaSystem.WAVE_CLEAR_BASE() * this.wave;
    this.Credit(bonus);
    ArenaSpawner.PlaySound(n"ui_loot_cash_picking");

    if this.wave >= this.totalWaves {
      this.EndRun(1);
      return;
    };

    this.wave += 1;
    ArenaSpawner.DespawnAll();
    this.PushPatrolPoints();
    this.QueueWave(this.wave);
    this.spawnCooldown = 2.0;
    this.patrolTimer = 10.0;

    // Enemies toughen as your take grows, then stop.
    ArenaSpawner.SetEnemyHealthMultiplier(this.ScaledEnemyHealth());

    // Same breather before every wave, so you can restock.
    this.prepLeft = Cast<Float>(this.prepSeconds);
    this.lastPrepShown = -1;
  }

  private func SpawnNext() {
    if ArraySize(this.queueIds) == 0 { return; }

    let id = this.queueIds[0];
    let isBoss = this.queueIsBoss[0];
    ArrayErase(this.queueIds, 0);
    ArrayErase(this.queueIsBoss, 0);

    let p = this.NextPoint();
    let ok: Bool;
    if isBoss {
      ok = ArenaSpawner.SpawnBossAtPos(id, p.X, p.Y, p.Z);
    } else {
      ok = ArenaSpawner.SpawnEnemyAtPos(id, p.X, p.Y, p.Z);
    };
    if ok {
      this.enemiesAlive += 1;
      this.lastAlive += 1;
      if isBoss { this.lastAliveBoss += 1; };
    };

    if ArraySize(this.queueIds) == 0 {
      this.waveSettle = ArenaSystem.WAVE_SETTLE();
    };
  }

  private func PushPatrolPoints() {
    ArenaSpawner.ClearPatrolLocations();
    let i = 0;
    while i < ArraySize(this.points) {
      ArenaSpawner.AddPatrolLocation(this.points[i].X, this.points[i].Y, this.points[i].Z);
      i += 1;
    };
  }

  // =================================================================
  //  ECONOMY
  // =================================================================

  private func Credit(amount: Int32) -> Int32 {
    if amount <= 0 { return 0; }
    this.shards += amount;
    this.earned += amount;
    return amount;
  }

  public func Spend(price: Int32) -> Bool {
    if this.richMode { return true; }
    if this.shards < price { return false; }
    this.shards -= price;
    this.spent += price;
    return true;
  }

  private func BumpCombo() {
    this.combo = MinF(4.0, this.combo + 0.5);
    this.comboTimer = ArenaSystem.COMBO_WINDOW();
    if this.combo > this.peakCombo { this.peakCombo = this.combo; };
  }

  private func PayKills(grunts: Int32, bosses: Int32) {
    if grunts + bosses <= 0 { return; }

    let pay = this.DiffPayMult();
    let gained = 0;
    let i = 0;
    while i < grunts {
      this.BumpCombo();
      // Every kill rolls $15-50; tougher enemies pull the floor up.
      // Later waves field meaner records and higher difficulties field
      // meaner everything, so both raise the minimum roll.
      let lo = 15 + (this.wave - 1) * 4 + this.difficulty * 3;
      if lo > 40 { lo = 40; };
      gained += this.Credit(RandRange(lo, 51));
      i += 1;
    };
    i = 0;
    while i < bosses {
      this.BumpCombo();
      gained += this.Credit(Cast<Int32>(Cast<Float>(ArenaSystem.BOSS_BOUNTY()) * this.combo * pay));
      i += 1;
    };

    this.kills += grunts + bosses;
    this.bossKills += bosses;

    // Every kill pays on screen, so the economy is never invisible.
    if bosses > 0 {
      ArenaSpawner.Notify("BOSS DOWN  //  +$" + ToString(gained), 2.5);
      ArenaSpawner.PlaySound(n"ui_loot_rarity_legendary");
    } else {
      ArenaSpawner.Notify("+$" + ToString(gained), 1.5);
      ArenaSpawner.PlaySound(n"ui_loot_cash_picking");
    };
  }

  // =================================================================
  //  SHOPPING
  // =================================================================

  public func BuyWeapon(index: Int32) -> Bool {
    if index < 0 || index >= ArraySize(this.weapons) { return false; }
    let w = this.weapons[index];
    if !this.Spend(w.price) { return false; }

    let ts = GameInstance.GetTransactionSystem(GetGameInstance());
    let player = GetPlayer(GetGameInstance());
    ts.GiveItemByTDBID(player, w.id, 1);
    ArrayPush(this.givenWeapons, w.id);

    ArenaSpawner.PlaySound(n"ui_loot_gun");
    ArenaSpawner.Notify(StrUpper(w.name) + " ACQUIRED", 2.0);
    return true;
  }

  public func SummonAlly(index: Int32) -> Bool {
    if index < 0 || index >= ArraySize(this.allies) { return false; }
    if this.IsHired(index) {
      ArenaSpawner.Notify("ALREADY ON THE CREW THIS RUN", 2.0);
      return false;
    };
    let elite = this.IsEliteAlly(index);
    if elite && this.HiredEliteCount() >= 2 {
      ArenaSpawner.Notify("ONLY 2 ELITES PER RUN", 2.0);
      return false;
    };
    if !elite && this.AliveRegularAllies() >= 3 {
      ArenaSpawner.Notify("CREW FULL - 3 AT A TIME", 2.0);
      return false;
    };
    let a = this.allies[index];
    if !this.Spend(a.price) { return false; }

    let p = this.AllyRingSpot();
    ModLog(n"CombatArena", "summoning " + a.name + " at " + ToString(p.X) + ", " + ToString(p.Y));
    if !ArenaSpawner.SpawnAllyAtPos(a.id, p.X, p.Y, p.Z, elite) {
      // Refund if the spawn was refused.
      this.shards += a.price;
      this.spent -= a.price;
      return false;
    };

    ArrayPush(this.hiredAllies, index);
    ArenaSpawner.Notify(StrUpper(a.name) + " JOINED THE FIGHT", 3.0);
    if a.price >= 900 {
      ArenaSpawner.PlaySound(n"ui_loot_rarity_legendary");
    } else {
      ArenaSpawner.PlaySound(n"ui_hacking_access_granted");
    };
    return true;
  }

  // A candidate is inside the arena when it sits near one of the mapped
  // arena points - the same points enemies spawn on, which are inside
  // by definition.
  private func IsInsideArena(p: Vector4) -> Bool {
    let i = 0;
    while i < ArraySize(this.points) {
      if Vector4.Distance(p, this.points[i]) <= 12.0 { return true; };
      i += 1;
    };
    return false;
  }

  // A ring around you: never closer than 4m, never further than 10m,
  // never stacked on another crew member, and ALWAYS inside the arena -
  // a spot outside the walls is re-rolled, and if the dice keep failing
  // the nearest mapped arena point is used instead.
  private func AllyRingSpot() -> Vector4 {
    let pp = GetPlayer(GetGameInstance()).GetWorldPosition();
    let others = GameInstance.GetDynamicEntitySystem().GetTagged(n"CombatArenaAlly");
    let p: Vector4;
    let attempt = 0;
    while attempt < 16 {
      let bearing = RandRangeF(0.0, 6.2832);
      let dist = RandRangeF(5.0, 9.0);
      p = new Vector4(pp.X + CosF(bearing) * dist, pp.Y + SinF(bearing) * dist, pp.Z, 1.0);
      let ok = this.IsInsideArena(p);
      let oi = 0;
      while ok && oi < ArraySize(others) {
        if IsDefined(others[oi]) {
          if Vector4.Distance(others[oi].GetWorldPosition(), p) < 3.0 { ok = false; };
        };
        oi += 1;
      };
      if ok { return p; };
      attempt += 1;
    };

    // Fallback: the mapped arena point closest to the player.
    let best = this.points[0];
    let bestD = Vector4.Distance(pp, best);
    let i = 1;
    while i < ArraySize(this.points) {
      let d = Vector4.Distance(pp, this.points[i]);
      if d < bestD {
        bestD = d;
        best = this.points[i];
      };
      i += 1;
    };
    ModLog(n"CombatArena", "ring spot fell back to nearest arena point");
    return best;
  }

  // Gauntlet's free starting crew: random DISTINCT picks from the ally
  // pool. The once-per-run rule and both quota caps apply to freebies.
  private func SpawnGauntletCrew() {
    let n = 0;
    while n < this.gauntletAllies && ArraySize(this.hiredAllies) < ArraySize(this.allies) {
      let idx = RandRange(0, ArraySize(this.allies));
      let tries = 0;
      while (this.IsHired(idx)
          || (this.IsEliteAlly(idx) && this.HiredEliteCount() >= 2)
          || (!this.IsEliteAlly(idx) && this.AliveRegularAllies() >= 3))
          && tries < 40 {
        idx = RandRange(0, ArraySize(this.allies));
        tries += 1;
      };
      if tries >= 40 { break; };
      let a = this.allies[idx];
      let p = this.AllyRingSpot();
      ArenaSpawner.SpawnAllyAtPos(a.id, p.X, p.Y, p.Z, this.IsEliteAlly(idx));
      ArrayPush(this.hiredAllies, idx);
      ModLog(n"CombatArena", "gauntlet crew: " + a.name);
      n += 1;
    };
    if this.gauntletAllies > 0 {
      ArenaSpawner.Notify("CREW OF " + ToString(this.gauntletAllies) + " DEPLOYED", 3.0);
    };
  }

  // Called by the summon key binding: no menu, best choom you can afford.
  public func QuickSummon() -> Void {
    ModLog(n"CombatArena", "QuickSummon, state=" + ToString(this.state) + " shards=" + ToString(this.shards));
    if this.state != 2 {
      ArenaSpawner.Notify("SUMMON WORKS DURING A WAVE", 2.0);
      return;
    }
    let best = this.BestAffordableAlly();
    if !IsDefined(best) {
      ArenaSpawner.Notify("NOT ENOUGH EDDIES", 2.0);
      ArenaSpawner.PlaySound(n"ui_hacking_access_denied");
      return;
    };
    let i = 0;
    while i < ArraySize(this.allies) {
      if Equals(this.allies[i].name, best.name) {
        this.SummonAlly(i);
        return;
      };
      i += 1;
    };
  }

  public func BuyPerk(index: Int32) -> Bool {
    if index < 0 || index >= ArraySize(this.perks) { return false; }
    let p = this.perks[index];
    if !this.Spend(p.price) { return false; }

    if Equals(p.key, n"heal") {
      ArenaSpawner.HealPlayer();
      ArenaSpawner.Notify("PATCHED UP", 2.5);
    } else {
      if Equals(p.key, n"time") {
        this.timeLeft += 60.0;
        if this.timeLeft > this.timeTotal { this.timeTotal = this.timeLeft; };
        ArenaSpawner.Notify("+60 SECONDS", 2.5);
      } else {
        if Equals(p.key, n"revive") {
          this.secondWind = true;
          ArenaSpawner.Notify("SECOND WIND ARMED", 2.5);
        } else {
          // airdrop: a random iconic, free of charge on top of the perk
          let pool = this.weapons;
          let pick = pool[RandRange(0, ArraySize(pool))];
          let ts = GameInstance.GetTransactionSystem(GetGameInstance());
          ts.GiveItemByTDBID(GetPlayer(GetGameInstance()), pick.id, 1);
          ArrayPush(this.givenWeapons, pick.id);
          ArenaSpawner.Notify("AIRDROP: " + StrUpper(pick.name), 3.0);
        };
      };
    };
    ArenaSpawner.PlaySound(n"ui_loot_generic");
    return true;
  }

  public func SetGodMode(enabled: Bool) -> Void {
    this.godMode = enabled;
    this.ApplyGodMode();
  }

  public func SetRichMode(enabled: Bool) -> Void {
    if Equals(enabled, this.richMode) { return; }
    if enabled {
      this.richBackup = this.shards;
      this.richMode = true;
    } else {
      this.richMode = false;
      this.shards = this.richBackup;
    };
  }

  private func ApplyGodMode() {
    ArenaSpawner.SetPlayerImmortal(this.godMode);
  }

  // ---------------------------------------------------------------
  //  YOUR OWN GEAR
  //
  //  The arena is a clean slate: your weapons are held at the door and
  //  handed back when you leave, so the only guns in a run are the ones
  //  you paid shards for.
  //
  //  Only weapons are touched. Clothing, cyberware, quest items and
  //  consumables are left completely alone.
  // ---------------------------------------------------------------

  private func StashOwnWeapons() {
    let gi = GetGameInstance();
    let player = GetPlayer(gi);
    let ts = GameInstance.GetTransactionSystem(gi);

    // Anything still held from a previous run goes back first, so a
    // crash mid-arena cannot compound into a second stash.
    this.RestoreOwnWeapons();

    let items: array<wref<gameItemData>>;
    ts.GetItemList(player, items);

    let i = 0;
    while i < ArraySize(items) {
      let data = items[i];
      if IsDefined(data) {
        let id = data.GetID();
        if RPGManager.IsItemWeapon(id) {
          ArrayPush(this.stashIds, id);
          ArrayPush(this.stashQty, data.GetQuantity());
        };
      };
      i += 1;
    };

    let j = 0;
    while j < ArraySize(this.stashIds) {
      ts.RemoveItem(player, this.stashIds[j], this.stashQty[j]);
      j += 1;
    };
    ModLog(n"CombatArena", "stashed " + ToString(ArraySize(this.stashIds)) + " of your weapons");
  }

  public func RestoreOwnWeapons() -> Void {
    if ArraySize(this.stashIds) == 0 { return; }

    let gi = GetGameInstance();
    let player = GetPlayer(gi);
    if !IsDefined(player) { return; }
    let ts = GameInstance.GetTransactionSystem(gi);

    let i = 0;
    while i < ArraySize(this.stashIds) {
      ts.GiveItem(player, this.stashIds[i], this.stashQty[i]);
      i += 1;
    };
    ModLog(n"CombatArena", "returned " + ToString(ArraySize(this.stashIds)) + " of your weapons");
    ArrayClear(this.stashIds);
    ArrayClear(this.stashQty);
  }

  // Everything bought inside the arena leaves with the arena, so a run
  // can never be used to smuggle iconics into a save.
  //
  // Matching is by TweakDB record over the live inventory, not by
  // reconstructing ItemIDs: items granted by the transaction system get
  // their own seeds, so a rebuilt ItemID quietly fails to match and the
  // weapon walks out with the player. That was exactly the bug.
  private func StripWeapons() {
    let gi = GetGameInstance();
    let player = GetPlayer(gi);
    if !IsDefined(player) { ArrayClear(this.givenWeapons); return; }

    let ts = GameInstance.GetTransactionSystem(gi);
    let items: array<wref<gameItemData>>;
    ts.GetItemList(player, items);

    let removed = 0;
    let i = 0;
    while i < ArraySize(items) {
      let data = items[i];
      if IsDefined(data) {
        let tdbid = ItemID.GetTDBID(data.GetID());
        let j = 0;
        while j < ArraySize(this.givenWeapons) {
          if tdbid == this.givenWeapons[j] {
            ts.RemoveItem(player, data.GetID(), data.GetQuantity());
            removed += 1;
            break;
          };
          j += 1;
        };
      };
      i += 1;
    };
    ModLog(n"CombatArena", "stripped " + ToString(removed) + " arena-bought items");
    ArrayClear(this.givenWeapons);
  }

  // =================================================================
  //  THE TICK
  // =================================================================

  public func Tick(gen: Int32) -> Void {
    // A stale generation (pre-reboot) dies quietly; the fresh one runs.
    if gen != this.tickGen { return; }
    let dt = ArenaSystem.TICK();

    // Drain whatever the bartender or the key bindings posted.
    let cmd = ArenaSpawner.ConsumeCommand();
    if cmd == 1 { this.EnterArena(); }
    else {
      if cmd == 2 { this.ExitArena(); }
      else {
        if cmd == 3 { this.QuickSummon(); }
        else {
          if cmd == 4 {
            // In the entry room this is the way in; inside, it is the menu.
            if this.state == 0 {
              if ArenaSpawner.IsNearEntry() { this.EnterArena(); };
            } else {
              ArenaTerminal.Toggle();
            };
          };
        };
      };
    };

    if !ArenaSpawner.IsInGameplay() {
      // Kicked to a menu or a save reloaded: drop the run quietly, but
      // KEEP TICKING - a tick that stopped here could never restart,
      // which is why the arena used to go dead after quitting to menu.
      if this.state != 0 {
        this.state = 0;
        this.shards = 0;
        ArrayClear(this.givenWeapons);
        this.ResetScore();
      };
      this.entering = false;
      this.wasNearEntry = false;
      let idleTick = new ArenaTick();
      idleTick.gen = gen;
      GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(idleTick, 1.0, false);
      return;
    };

    ArenaSpawner.SetArenaState(this.state);

    // Filthy Rich keeps the wallet topped up.
    if this.richMode && this.state != 0 && this.shards < 99999 {
      this.shards = 99999;
    };

    // While idle, watch the entry room. Stepping inside brings up the
    // real interaction hub - the same UI a vendor shows - with "Enter
    // into the Arena" on the player's own interact key.
    if this.state == 0 {
      let dist = ArenaSpawner.DistanceToEntry();
      let near = dist <= ArenaSpawner.EntryRadius();

      if NotEquals(near, this.wasNearEntry) {
        this.wasNearEntry = near;
        ModLog(n"CombatArena", (near ? "entered" : "left") + " entry room, dist " + ToString(dist));
        if !near { ArenaSpawner.HideEntryHub(); };
      };
      // Re-asserted every tick while inside: self-checking, so it only
      // actually writes when the hub is missing. Hidden while the
      // entry sequence runs - you are already committed.
      if near && !this.entering { ArenaSpawner.PushEntryHub(); };

      ArenaSpawner.SetNearEntry(near);
    } else {
      if this.wasNearEntry {
        ArenaSpawner.HideEntryHub();
        this.wasNearEntry = false;
      };
      ArenaSpawner.SetNearEntry(false);
    };

    // The entry ritual: three rooted seconds with the wire-up sound,
    // then the drop. The ENTERING ARENA callout covers the wait; no
    // countdown clutter.
    if this.entering {
      this.entryLeft -= dt;
      if this.entryLeft <= 0.0 {
        this.entering = false;
        this.CompleteEntry();
      };
    };

    // Exit is a held key; the raw input marks the hold and the tick
    // does the timing, so a lethal 10-to-0 frame can never slip past.
    let svc = ArenaSpawner.GetService();
    if IsDefined(svc) && svc.exitHolding {
      if this.state == 0 {
        svc.exitHolding = false;
      } else {
        svc.exitHeld += dt;
        if svc.exitHeld >= 0.6 {
          svc.exitHolding = false;
          this.ExitArena();
        };
      };
    };

    if this.state == 2 { this.TickFight(dt); };

    // In the lobby and on the results screen only the wallet shows -
    // one clean number, nothing else.
    if this.state == 1 || this.state == 3 {
      this.hudTimer -= dt;
      if this.hudTimer <= 0.0 {
        this.hudTimer = 1.0;
        this.SetHud("$" + ToString(this.shards));
      };
    };

    // Keep ticking while there is anything to do; idle costs one call
    // per quarter second and nothing else.
    let nextTick = new ArenaTick();
    nextTick.gen = gen;
    GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(nextTick, ArenaSystem.TICK(), false);
  }

  public func MenuKeyLabel() -> String {
    // Whatever the user picked in Mod Settings; Z out of the box.
    let settings = ArenaSettings.Get();
    if IsDefined(settings) { return ArenaSettings.KeyName(settings.ArenaMenuKey); }
    return "Z";
  }

  private func PushStatsHud() {
    let mins = Cast<Int32>(this.timeLeft) / 60;
    let secs = Cast<Int32>(this.timeLeft) % 60;
    let clock = ToString(mins) + (secs < 10 ? ":0" : ":") + ToString(secs);

    this.SetHud(
      "WAVE " + ToString(this.wave) + "/" + ToString(this.totalWaves)
      + "     ENEMIES " + ToString(this.enemiesAlive)
      + "     " + clock
      + "\n$" + ToString(this.shards));
  }

  private func TickFight(dt: Float) {
    // ---- pre-wave countdown: nothing spawns, clock is not running
    if this.prepLeft > 0.0 {
      this.prepLeft -= dt;
      let secs = Cast<Int32>(this.prepLeft) + 1;
      if secs < 1 { secs = 1; };
      if secs != this.lastPrepShown {
        this.lastPrepShown = secs;
        this.SetHud("WAVE " + ToString(this.wave) + " STARTING IN " + ToString(secs)
          + "\n$" + ToString(this.shards));
      };
      if this.prepLeft <= 0.0 {
        this.prepLeft = 0.0;
        ArenaSpawner.Notify("WAVE " + ToString(this.wave), 2.5);
        ArenaSpawner.PlaySound(n"ui_hacking_access_granted");
      };
      return;
    };

    // ---- combo decay
    if this.comboTimer > 0.0 {
      this.comboTimer -= dt;
      if this.comboTimer <= 0.0 { this.combo = 1.0; };
    };

    // ---- clock, with callouts on the way down so the terminal is not
    //      the only place the time is visible
    let before = this.timeLeft;
    this.timeLeft -= dt;
    if this.timeLeft <= 0.0 {
      this.timeLeft = 0.0;
      this.EndRun(2);
      return;
    };
    if before > 60.0 && this.timeLeft <= 60.0 {
      ArenaSpawner.Notify("60 SECONDS", 2.5);
    };
    if before > 30.0 && this.timeLeft <= 30.0 {
      ArenaSpawner.Notify("30 SECONDS", 2.5);
      ArenaSpawner.PlaySound(n"ui_jingle_chip_malfunction");
    };
    if before > 10.0 && this.timeLeft <= 10.0 {
      ArenaSpawner.Notify("10 SECONDS", 2.5);
    };

    // ---- player condition
    //  You are engine-immortal in here, so health bottoms out instead of
    //  killing you. We treat that as the flatline ourselves, which keeps
    //  you in the arena rather than on the death screen.
    let hp = ArenaSpawner.GetPlayerHealthPercent();
    if this.secondWind && hp > 0.0 && hp <= ArenaSystem.SECOND_WIND_AT() {
      this.secondWind = false;
      ArenaSpawner.HealPlayer();
      ArenaSpawner.Notify("SECOND WIND", 3.0);
      ArenaSpawner.PlaySound(n"ui_jingle_chip_malfunction");
    };
    // Immortality floors health at 1 rather than killing you, so there is
    // no window to miss: however hard the hit lands, you sit at 1 until
    // this sees it. PlayerPuppet.OnDeath is wrapped as a second net.
    if !this.godMode && hp <= 1.0 {
      this.Flatline();
      return;
    };

    // ---- spawning
    if ArraySize(this.queueIds) > 0 {
      this.spawnCooldown -= dt;
      if this.spawnCooldown <= 0.0 {
        this.SpawnNext();
        this.spawnCooldown = ArenaSystem.SPAWN_DELAY();
      };
    };

    // ---- AI upkeep
    //
    //  Setting attitude alone is not enough to start a fight: an NPC that
    //  hates you still has to notice you. The original pushed a Gunshot
    //  and CombatCall stim from the player's position every few seconds,
    //  which is what actually pulls them into combat. Restoring that.
    this.hostilityTimer -= dt;
    if this.hostilityTimer <= 0.0 {
      this.hostilityTimer = 3.0;
      if this.enemiesAlive > 0 {
        ArenaSpawner.MakeArenaEnemiesHostile();
        let p = GetPlayer(GetGameInstance()).GetWorldPosition();
        ArenaSpawner.SendEnemiesToSearch(p.X, p.Y, p.Z);
      };
    };

    this.patrolTimer -= dt;
    if this.patrolTimer <= 0.0 {
      this.patrolTimer = 10.0;
      if this.enemiesAlive > 0 { ArenaSpawner.SendEnemiesToPatrolLocations(); };
    };

    this.rallyTimer -= dt;
    if this.rallyTimer <= 0.0 {
      this.rallyTimer = 6.0;
      ArenaSpawner.RallyAllies();
    };

    // (The terminal may stay open mid-wave: shopping in slow-mo between
    //  volleys is part of the game now. The old watchdog that forced it
    //  shut every tick is gone - it was why nothing could be bought once
    //  a wave was live.)

    // ---- heartbeat so I can see the fight actually running
    this.beatTimer -= dt;
    if this.beatTimer <= 0.0 {
      this.beatTimer = 5.0;
      ModLog(n"CombatArena", "fight: wave " + ToString(this.wave)
        + " alive " + ToString(this.enemiesAlive)
        + " queued " + ToString(ArraySize(this.queueIds))
        + " time " + ToString(Cast<Int32>(this.timeLeft)));
    };

    // ---- stats line. Updating a widget's text does not re-animate it,
    //      so this can tick every second without flickering.
    this.hudTimer -= dt;
    if this.hudTimer <= 0.0 {
      this.hudTimer = 1.0;
      this.PushStatsHud();
    };

    // ---- give the wave a moment to settle before counting it clear
    if this.waveSettle > 0.0 {
      this.waveSettle -= dt;
      return;
    };

    // ---- kills, counted by watching the alive count fall.
    //      Nothing is deleted, so bodies stay where they drop until the
    //      wave ends.
    let alive = ArenaSpawner.GetAliveArenaEnemyCount();
    let aliveBoss = ArenaSpawner.GetAliveBossCount();

    let died = this.lastAlive - alive;
    let diedBoss = this.lastAliveBoss - aliveBoss;
    if died > 0 {
      if diedBoss < 0 { diedBoss = 0; };
      if diedBoss > died { diedBoss = died; };
      this.PayKills(died - diedBoss, diedBoss);
    };
    this.lastAlive = alive;
    this.lastAliveBoss = aliveBoss;
    this.enemiesAlive = alive;

    if ArraySize(this.queueIds) == 0 && alive <= 0 {
      this.enemiesAlive = 0;
      // Clear the bodies now the wave is done.
      ArenaSpawner.DespawnAll();
      this.lastAlive = 0;
      this.lastAliveBoss = 0;
      this.AdvanceWave();
    };
  }
}
