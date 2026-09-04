// =====================================================================
//  COMBAT ARENA - REDscript layer
// =====================================================================
//  Provides the native-side services the CET Lua module drives:
//    * spawning / despawning tagged arena NPCs at world positions
//    * hostility, patrol and rally AI commands
//    * kill harvesting split by enemy class (feeds the eddie economy)
//    * equipped-item detection (the Braindance Wreath arena trigger)
//    * gameplay-vs-main-menu gating
//    * base-game styled onscreen notifications
//
//  Entity tags used:
//    CombatArena       - every hostile spawned by the arena
//    CombatArenaBoss   - bosses (ALSO carry CombatArena)
//    CombatArenaAlly   - friendly NPCs summoned with arena eddies
// =====================================================================

import Codeware.UI.*

public abstract class ArenaSpawner {

  // ===================================================================
  //  THE ENTRY HUB
  //
  //  The real interaction UI - the same bottom-of-screen choice hub a
  //  vendor or a door shows - fed straight into the UIInteractions
  //  blackboard. It renders the player's actual interact key on its own,
  //  so nothing about the key is hardcoded or even spelled out here.
  // ===================================================================

  public static func EntryHubId() -> Int32 { return 777001; }

  // Pushed every tick while stood in the entry room. Self-checking: if
  // our hub is already up it does nothing, and if a REAL interactable is
  // showing its own hub, ours politely waits rather than stomping it.
  public static func PushEntryHub() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let defs = GetAllBlackboardDefs();
    let bb = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);
    if !IsDefined(bb) { return; }

    let current: InteractionChoiceHubData =
      FromVariant<InteractionChoiceHubData>(bb.GetVariant(defs.UIInteractions.InteractionChoiceHub));
    if current.active { return; }

    let choice: InteractionChoiceData;
    choice.inputAction = n"Choice1";
    choice.isHoldAction = false;
    choice.localizedName = "Enter the Arena";
    ChoiceTypeWrapper.SetType(choice.type, gameinteractionsChoiceType.QuestImportant);
    // No caption icon: just the key and the text. (The old belief that a
    // caption part was required to render turned out to be wrong - the
    // real gate was the active-visualizer flag below.)

    let hub: InteractionChoiceHubData;
    hub.id = ArenaSpawner.EntryHubId();
    hub.active = true;
    hub.title = "COMBAT ARENA";
    ArrayPush(hub.choices, choice);

    bb.SetVariant(defs.UIInteractions.InteractionChoiceHub, ToVariant(hub), true);

    // The part every earlier attempt missed: the hub UI only lights up
    // (text visible, key icon shown) when VisualizersInfo names it the
    // ACTIVE visualizer - interactionsUI matches activeVisId against the
    // hub id. This is exactly what the game does at a vendor.
    let vis: VisualizersInfo;
    vis.activeVisId = ArenaSpawner.EntryHubId();
    ArrayPush(vis.visIds, ArenaSpawner.EntryHubId());
    bb.SetVariant(defs.UIInteractions.VisualizersInfo, ToVariant(vis), true);
  }

  public static func HideEntryHub() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let defs = GetAllBlackboardDefs();
    let bb = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);
    if !IsDefined(bb) { return; }

    // Only take down our own hub - never someone else's interaction.
    let current: InteractionChoiceHubData =
      FromVariant<InteractionChoiceHubData>(bb.GetVariant(defs.UIInteractions.InteractionChoiceHub));
    if current.active && current.id != ArenaSpawner.EntryHubId() { return; }

    let hub: InteractionChoiceHubData;
    hub.id = ArenaSpawner.EntryHubId();
    hub.active = false;
    bb.SetVariant(defs.UIInteractions.InteractionChoiceHub, ToVariant(hub), true);

    // Hand the visualizer slot back to the game.
    let vis: VisualizersInfo;
    vis.activeVisId = -1;
    bb.SetVariant(defs.UIInteractions.VisualizersInfo, ToVariant(vis), true);
  }

  // ===================================================================
  //  GATING
  // ===================================================================

  // True only when a save is actually loaded and the player exists.
  // Everything in the mod is gated behind this so nothing can fire
  // from the main menu / loading screens.
  public static func IsInGameplay() -> Bool {
    let gi = GetGameInstance();

    let srh = GameInstance.GetSystemRequestsHandler();
    if !IsDefined(srh) { return false; }
    if srh.IsPreGame() { return false; }

    let player = GetPlayer(gi);
    if !IsDefined(player) { return false; }
    if !player.IsPlayerControlled() { return false; }

    return true;
  }

  public static func IsPlayerInVehicle() -> Bool {
    let player = GetPlayer(GetGameInstance());
    if !IsDefined(player) { return false; }
    return VehicleComponent.IsMountedToVehicle(GetGameInstance(), player);
  }

  // ===================================================================
  //  COMMAND QUEUE
  //
  //  The only way into the arena is Mateo, the bartender at Lizzie's.
  //  His "Enter the Combat Arena" interaction, and the key bindings,
  //  both post a command here. There is no hotkey to enter and no
  //  wearable trigger - that entry point is gone by design.
  //
  //    1 = enter     2 = exit     3 = summon ally     4 = open terminal
  // ===================================================================

  public static func PostCommand(cmd: Int32) -> Void {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { service.pendingCommand = cmd; };
  }

  // Reads and clears in one go, so a command can never fire twice.
  public static func ConsumeCommand() -> Int32 {
    let service = ArenaSpawner.GetService();
    if !IsDefined(service) { return 0; }
    let cmd = service.pendingCommand;
    service.pendingCommand = 0;
    return cmd;
  }

  // -------------------------------------------------------------------
  //  THE ENTRY ROOM
  //
  //  A second way in, at a fixed spot in the back room at Lizzie's.
  //  Step inside the radius and the terminal key takes you straight in.
  //  This is a plain distance check, so nothing in TweakDB can filter it.
  // -------------------------------------------------------------------

  // Two ways in. Stand at either and the same hub appears.
  public static func EntryPositions() -> array<Vector4> {
    return [
      new Vector4(-1449.4084, 1337.6293, 119.1257, 1.0),
      new Vector4(-2433.7217, -2404.3230, 16.7225, 1.0)
    ];
  }

  public static func EntryRadius() -> Float {
    return 1.15;
  }

  public static func DistanceToEntry() -> Float {
    if !ArenaSpawner.IsInGameplay() { return 99999.0; }
    let p = GetPlayer(GetGameInstance()).GetWorldPosition();
    let entries = ArenaSpawner.EntryPositions();
    let best = 99999.0;
    let i = 0;
    while i < ArraySize(entries) {
      let d = Vector4.Distance(p, entries[i]);
      if d < best { best = d; };
      i += 1;
    };
    return best;
  }

  // Gun-shop icons on the minimap and world map, one per entrance,
  // re-registered fresh each session boot.
  public static func RegisterEntryMappins() -> Void {
    let service = ArenaSpawner.GetService();
    if !IsDefined(service) { return; }
    let ms = GameInstance.GetMappinSystem(GetGameInstance());
    if !IsDefined(ms) { return; }

    let i = 0;
    while i < ArraySize(service.mappinIds) {
      ms.UnregisterMappin(service.mappinIds[i]);
      i += 1;
    };
    ArrayClear(service.mappinIds);

    let entries = ArenaSpawner.EntryPositions();
    i = 0;
    while i < ArraySize(entries) {
      let md: MappinData;
      // Our own record (custom hover name). The GUNS vendor variant
      // files the pin under the map's Vendors group; the crossed-swords
      // icon is applied at the widget level by the controller wraps at
      // the bottom of this file, so the variant's own glyph never shows.
      // The exact registration shape that provably rendered: melee
      // variant + icon record via scriptData (the minimap POI
      // controller prefers m_textureID over the variant glyph).
      md.mappinType = t"Mappins.CombatArenaEntrance";
      md.variant = gamedataMappinVariant.ServicePointMeleeTrainerVariant;
      md.active = true;
      md.visibleThroughWalls = false;
      md.debugCaption = "Combat Arena Entrance";
      let iconData = new GameplayRoleMappinData();
      iconData.m_textureID = t"UIIcon.CombatArenaEntrance";
      md.scriptData = iconData;
      ArrayPush(service.mappinIds, ms.RegisterMappin(md, entries[i]));
      i += 1;
    };
    ModLog(n"CombatArena", "entry mappins registered: " + ToString(ArraySize(entries)));
  }

  // True when a mappin sits on one of our entrances - how the icon
  // wraps below recognize their pins without touching anything else.
  public static func IsEntryPinPosition(pos: Vector4) -> Bool {
    let entries = ArenaSpawner.EntryPositions();
    let i = 0;
    while i < ArraySize(entries) {
      if Vector4.Distance(pos, entries[i]) < 3.0 { return true; };
      i += 1;
    };
    return false;
  }

  public static func SetNearEntry(near: Bool) -> Void {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { service.nearEntry = near; };
  }

  public static func IsNearEntry() -> Bool {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { return service.nearEntry; };
    return false;
  }

  // ===================================================================
  //  SPAWNING
  // ===================================================================

  public static func CreateAt(recordID: TweakDBID, x: Float, y: Float, z: Float, tags: array<CName>, jitter: Float) -> Bool {
    if !ArenaSpawner.IsInGameplay() {
      ModLog(n"CombatArena", "Spawn refused: not in gameplay");
      return false;
    }

    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) {
      ModLog(n"CombatArena", "ERROR: DynamicEntitySystem not available");
      return false;
    }

    // Small jitter so a stack of NPCs never spawns inside one another.
    // Allies pass a tiny value because their position is already picked
    // deliberately - a big jitter was how they ended up on top of you.
    let spawnPos = new Vector4(
      x + RandRangeF(-jitter, jitter),
      y + RandRangeF(-jitter, jitter),
      z + 0.2,
      1.0
    );

    let angles = new EulerAngles();
    angles.Yaw = RandRangeF(0.0, 360.0);

    let npcSpec = new DynamicEntitySpec();
    npcSpec.recordID = recordID;
    npcSpec.position = spawnPos;
    npcSpec.orientation = EulerAngles.ToQuat(angles);
    npcSpec.persistState = false;
    npcSpec.persistSpawn = false;
    npcSpec.alwaysSpawned = true;
    npcSpec.spawnInView = true;
    npcSpec.tags = tags;

    entitySystem.CreateEntity(npcSpec);
    return true;
  }

  public static func SpawnEnemyAtPos(recordID: TweakDBID, x: Float, y: Float, z: Float) -> Bool {
    return ArenaSpawner.CreateAt(recordID, x, y, z, [n"CombatArena"], 1.5);
  }

  // Bosses carry BOTH tags: they are still arena enemies for hostility /
  // alive-count purposes, but are harvested separately so the economy can
  // pay out a boss bounty.
  public static func SpawnBossAtPos(recordID: TweakDBID, x: Float, y: Float, z: Float) -> Bool {
    return ArenaSpawner.CreateAt(recordID, x, y, z, [n"CombatArena", n"CombatArenaBoss"], 1.5);
  }

  // Elites carry an extra tag so the alive-caps can count them apart.
  public static func SpawnAllyAtPos(recordID: TweakDBID, x: Float, y: Float, z: Float, elite: Bool) -> Bool {
    if elite {
      return ArenaSpawner.CreateAt(recordID, x, y, z, [n"CombatArenaAlly", n"CombatArenaElite"], 0.35);
    };
    return ArenaSpawner.CreateAt(recordID, x, y, z, [n"CombatArenaAlly"], 0.35);
  }

  public static func TeleportPlayer(x: Float, y: Float, z: Float) -> Bool {
    if !ArenaSpawner.IsInGameplay() { return false; }
    let gi = GetGameInstance();
    let player = GetPlayer(gi);

    let pos = new Vector4(x, y, z + 0.2, 1.0);
    let angles = new EulerAngles();
    GameInstance.GetTeleportationFacility(gi).Teleport(player, pos, angles);
    return true;
  }

  // ===================================================================
  //  DESPAWNING
  // ===================================================================

  public static func DespawnAll() -> Void {
    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if IsDefined(entitySystem) {
      entitySystem.DeleteTagged(n"CombatArena");
      ModLog(n"CombatArena", "All arena enemies removed");
    };
  }

  public static func DespawnAllies() -> Void {
    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if IsDefined(entitySystem) {
      entitySystem.DeleteTagged(n"CombatArenaAlly");
      ModLog(n"CombatArena", "All arena allies removed");
    };
  }

  // ===================================================================
  //  KILL HARVESTING
  // ===================================================================

  public static func IsPuppetFinished(puppet: ref<ScriptedPuppet>, sps: ref<StatPoolsSystem>) -> Bool {
    if puppet.IsDead() { return true; }
    if ScriptedPuppet.IsDefeated(puppet) { return true; }

    let hp = sps.GetStatPoolValue(Cast<StatsObjectID>(puppet.GetEntityID()), gamedataStatPoolType.Health);
    if hp <= 1.00 { return true; }

    let npc = puppet as NPCPuppet;
    if IsDefined(npc) {
      let hls = npc.GetHighLevelStateFromBlackboard();
      if Equals(hls, gamedataNPCHighLevelState.Dead) { return true; }
      if Equals(hls, gamedataNPCHighLevelState.Unconscious) { return true; }
    };
    return false;
  }

  // Sweeps the arena, deletes everything that is down, and records how many
  // grunts vs bosses died into the service. Returns the total removed.
  //
  // Lua then reads GetLastGruntKills() / GetLastBossKills() to pay out.
  public static func HarvestDefeated() -> Int32 {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { service.ResetHarvest(); };

    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return 0; }

    let sps = GameInstance.GetStatPoolsSystem(GetGameInstance());

    // Pass 1: count downed bosses. Bosses carry both tags, so this is a
    // subset of the sweep below - no entity-identity comparison needed.
    let bossKills = 0;
    let bosses = entitySystem.GetTagged(n"CombatArenaBoss");
    let b = 0;
    while b < ArraySize(bosses) {
      let bossEntity = bosses[b];
      if IsDefined(bossEntity) {
        let bossPuppet = bossEntity as ScriptedPuppet;
        if IsDefined(bossPuppet) {
          if ArenaSpawner.IsPuppetFinished(bossPuppet, sps) { bossKills += 1; };
        };
      };
      b += 1;
    };

    // Pass 2: sweep and delete every downed arena enemy.
    let total = 0;
    let entities = entitySystem.GetTagged(n"CombatArena");
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let puppet = entity as ScriptedPuppet;
        if IsDefined(puppet) {
          if ArenaSpawner.IsPuppetFinished(puppet, sps) {
            // Force-kill first so nothing lingers in a downed-but-alive state.
            if !puppet.IsDead() {
              sps.RequestSettingStatPoolValue(
                Cast<StatsObjectID>(puppet.GetEntityID()),
                gamedataStatPoolType.Health, 0.00, puppet, true);
            };
            entitySystem.DeleteEntity(entity.GetEntityID());
            total += 1;
          };
        };
      };
      i += 1;
    };

    if bossKills > total { bossKills = total; };
    let grunts = total - bossKills;

    if IsDefined(service) { service.RecordHarvest(grunts, bossKills); };
    if total > 0 {
      ModLog(n"CombatArena", "Harvested " + ToString(grunts) + " grunts, " + ToString(bossKills) + " bosses");
    };
    return total;
  }

  public static func GetLastGruntKills() -> Int32 {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { return service.lastGruntKills; };
    return 0;
  }

  public static func GetLastBossKills() -> Int32 {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { return service.lastBossKills; };
    return 0;
  }

  public static func GetAliveArenaEnemyCount() -> Int32 {
    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return 0; }

    let sps = GameInstance.GetStatPoolsSystem(GetGameInstance());
    let entities = entitySystem.GetTagged(n"CombatArena");
    let alive = 0;
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let puppet = entity as ScriptedPuppet;
        if IsDefined(puppet) {
          if !ArenaSpawner.IsPuppetFinished(puppet, sps) { alive += 1; };
        };
      };
      i += 1;
    };
    return alive;
  }

  // Bosses carry both tags, so this is a subset of the arena count.
  public static func GetAliveBossCount() -> Int32 {
    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return 0; }

    let sps = GameInstance.GetStatPoolsSystem(GetGameInstance());
    let entities = entitySystem.GetTagged(n"CombatArenaBoss");
    let alive = 0;
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let puppet = entity as ScriptedPuppet;
        if IsDefined(puppet) {
          if !ArenaSpawner.IsPuppetFinished(puppet, sps) { alive += 1; };
        };
      };
      i += 1;
    };
    return alive;
  }

  public static func GetAliveEliteAllyCount() -> Int32 {
    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return 0; }

    let sps = GameInstance.GetStatPoolsSystem(GetGameInstance());
    let entities = entitySystem.GetTagged(n"CombatArenaElite");
    let alive = 0;
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let puppet = entity as ScriptedPuppet;
        if IsDefined(puppet) {
          if !ArenaSpawner.IsPuppetFinished(puppet, sps) { alive += 1; };
        };
      };
      i += 1;
    };
    return alive;
  }

  public static func GetAliveAllyCount() -> Int32 {
    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return 0; }

    let sps = GameInstance.GetStatPoolsSystem(GetGameInstance());
    let entities = entitySystem.GetTagged(n"CombatArenaAlly");
    let alive = 0;
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let puppet = entity as ScriptedPuppet;
        if IsDefined(puppet) {
          if !ArenaSpawner.IsPuppetFinished(puppet, sps) { alive += 1; };
        };
      };
      i += 1;
    };
    return alive;
  }

  public static func IsArenaPopulated() -> Bool {
    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return false; }
    return entitySystem.IsPopulated(n"CombatArena");
  }

  // ===================================================================
  //  AI - HOSTILITY, PATROL, RALLY
  // ===================================================================

  public static func MakeArenaEnemiesHostile() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let player = GetPlayer(GetGameInstance());

    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return; }

    let entities = entitySystem.GetTagged(n"CombatArena");
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let npc = entity as NPCPuppet;
        if IsDefined(npc) {
          let attAgent = npc.GetAttitudeAgent();
          if IsDefined(attAgent) {
            attAgent.SetAttitudeGroup(n"hostile");
            attAgent.SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
          };
        };
      };
      i += 1;
    };
  }

  // Walks non-combat enemies toward a random arena point so the arena
  // never feels static between engagements.
  public static func SendEnemiesToPatrolLocations() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }

    let service = ArenaSpawner.GetService();
    if !IsDefined(service) { return; }
    if ArraySize(service.patrolLocations) == 0 { return; }

    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return; }

    let entities = entitySystem.GetTagged(n"CombatArena");
    let sent = 0;
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let npc = entity as NPCPuppet;
        if IsDefined(npc) {
          if !npc.IsDead() && !NPCPuppet.IsInCombat(npc) {
            let locIdx = RandRange(0, ArraySize(service.patrolLocations));
            if ArenaSpawner.SendMoveTo(npc, service.patrolLocations[locIdx], moveMovementType.Walk) { sent += 1; };
          };
        };
      };
      i += 1;
    };
    ModLog(n"CombatArena", "Patrol: " + ToString(sent) + " enemies redirected");
  }

  // Keeps summoned allies near the player instead of wandering off.
  // Follow, never teleport: anyone further than 5m paths back to you,
  // at a run if they have fallen well behind.
  public static func RallyAllies() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let player = GetPlayer(GetGameInstance());
    let playerPos = player.GetWorldPosition();

    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return; }

    let entities = entitySystem.GetTagged(n"CombatArenaAlly");
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let npc = entity as NPCPuppet;
        if IsDefined(npc) {
          if !npc.IsDead() && !NPCPuppet.IsInCombat(npc) {
            // Short leash: react at 4m, run from 9m. The engine teleports
            // stray companions who fall far behind, so the answer is to
            // never let them fall far behind.
            let d = Vector4.Distance(npc.GetWorldPosition(), playerPos);
            if d > 4.0 {
              ArenaSpawner.SendMoveTo(npc, playerPos,
                d > 9.0 ? moveMovementType.Run : moveMovementType.Walk);
            };
          };
        };
      };
      i += 1;
    };
  }

  public static func SendMoveTo(npc: ref<NPCPuppet>, targetPos: Vector4, movement: moveMovementType) -> Bool {
    let aiComponent = npc.GetAIControllerComponent();
    if !IsDefined(aiComponent) { return false; }

    let moveCmd = new AIMoveToCommand();
    let targetSpec: AIPositionSpec;
    let wp: WorldPosition;
    WorldPosition.SetVector4(wp, targetPos);
    AIPositionSpec.SetWorldPosition(targetSpec, wp);
    moveCmd.movementTarget = targetSpec;
    moveCmd.movementType = movement;
    moveCmd.rotateEntityTowardsFacingTarget = false;
    moveCmd.desiredDistanceFromTarget = 3.0;
    moveCmd.finishWhenDestinationReached = true;
    moveCmd.ignoreNavigation = false;
    aiComponent.SendCommand(moveCmd);
    return true;
  }

  // Gunshot + CombatCall stim at the player: pulls idle enemies into the fight.
  public static func SendEnemiesToSearch(targetX: Float, targetY: Float, targetZ: Float) -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let player = GetPlayer(GetGameInstance());

    let entitySystem = GameInstance.GetDynamicEntitySystem();
    if !IsDefined(entitySystem) { return; }

    let targetPos = new Vector4(targetX, targetY, targetZ, 1.0);
    let entities = entitySystem.GetTagged(n"CombatArena");
    let i = 0;
    while i < ArraySize(entities) {
      let entity = entities[i];
      if IsDefined(entity) {
        let npc = entity as NPCPuppet;
        if IsDefined(npc) {
          if !npc.IsDead() {
            let stimEvent = new StimuliEvent();
            stimEvent.SetStimType(gamedataStimType.Gunshot);
            stimEvent.sourcePosition = targetPos;
            stimEvent.sourceObject = player;
            npc.QueueEvent(stimEvent);

            let combatStim = new StimuliEvent();
            combatStim.SetStimType(gamedataStimType.CombatCall);
            combatStim.sourcePosition = targetPos;
            combatStim.sourceObject = player;
            npc.QueueEvent(combatStim);

            let attAgent = npc.GetAttitudeAgent();
            if IsDefined(attAgent) {
              attAgent.SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
            };
          };
        };
      };
      i += 1;
    };
  }

  // ===================================================================
  //  PATROL POINT REGISTRY  (Lua cannot pass arrays, so points are added one by one)
  // ===================================================================

  public static func AddPatrolLocation(x: Float, y: Float, z: Float) -> Void {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) {
      ArrayPush(service.patrolLocations, new Vector4(x, y, z, 1.0));
    };
  }

  public static func ClearPatrolLocations() -> Void {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { ArrayClear(service.patrolLocations); };
  }

  // ===================================================================
  //  PLAYER
  // ===================================================================

  // Proper engine-level invulnerability instead of re-filling health each frame.
  public static func SetPlayerImmortal(enable: Bool) -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let gi = GetGameInstance();
    let player = GetPlayer(gi);

    let gms = GameInstance.GetGodModeSystem(gi);
    if !IsDefined(gms) { return; }

    if enable {
      gms.AddGodMode(player.GetEntityID(), gameGodModeType.Immortal, n"CombatArena");
    } else {
      gms.ClearGodMode(player.GetEntityID(), n"CombatArena");
    };
    ModLog(n"CombatArena", "Player immortality: " + ToString(enable));
  }

  // The terminal slows time and pushes a modal UI context while it is
  // open. If it is ever dismissed by a route that skips its own OnHide,
  // that state sticks: the world crawls and your weapons stop responding.
  // This forces it back to normal and is safe to call at any time.
  public static func ClearMenuState() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let gi = GetGameInstance();
    let player = GetPlayer(gi);

    TimeDilationHelper.SetTimeDilationWithProfile(player, "radialMenu", false, false);

    let uiSystem = GameInstance.GetUISystem(gi);
    if IsDefined(uiSystem) {
      uiSystem.PopGameContext(UIGameContext.ModalPopup);
      uiSystem.RestorePreviousVisualState(n"inkModalPopupState");
    };
    ModLog(n"CombatArena", "menu state cleared (time + input restored)");
  }

  // Roots the player in place during the entry sequence, standing in
  // for a chair animation until a proper workspot prop exists.
  public static func LockPlayerMovement(enable: Bool) -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let player = GetPlayer(GetGameInstance());
    if enable {
      StatusEffectHelper.ApplyStatusEffect(player, t"GameplayRestriction.NoMovement");
    } else {
      StatusEffectHelper.RemoveStatusEffect(player, t"GameplayRestriction.NoMovement");
    };
  }

  public static func HealPlayer() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let gi = GetGameInstance();
    let player = GetPlayer(gi);
    let sps = GameInstance.GetStatPoolsSystem(gi);
    if IsDefined(sps) {
      sps.RequestSettingStatPoolValue(
        Cast<StatsObjectID>(player.GetEntityID()),
        gamedataStatPoolType.Health, 100.0, player, true);
    };
  }

  // 0.0 - 100.0. Used to arm the Second Wind perk before a lethal hit lands.
  public static func GetPlayerHealthPercent() -> Float {
    if !ArenaSpawner.IsInGameplay() { return 100.0; }
    let gi = GetGameInstance();
    let player = GetPlayer(gi);
    let sps = GameInstance.GetStatPoolsSystem(gi);
    if !IsDefined(sps) { return 100.0; }
    return sps.GetStatPoolValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatPoolType.Health);
  }

  public static func IsPlayerDead() -> Bool {
    if !ArenaSpawner.IsInGameplay() { return false; }
    return GetPlayer(GetGameInstance()).IsDead();
  }

  public static func GetPlayerX() -> Float {
    if !ArenaSpawner.IsInGameplay() { return 0.0; }
    return GetPlayer(GetGameInstance()).GetWorldPosition().X;
  }

  public static func GetPlayerY() -> Float {
    if !ArenaSpawner.IsInGameplay() { return 0.0; }
    return GetPlayer(GetGameInstance()).GetWorldPosition().Y;
  }

  public static func GetPlayerZ() -> Float {
    if !ArenaSpawner.IsInGameplay() { return 0.0; }
    return GetPlayer(GetGameInstance()).GetWorldPosition().Z;
  }

  // ===================================================================
  //  DIFFICULTY
  // ===================================================================

  public static func SetEnemyHealthMultiplier(multiplier: Float) -> Void {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { service.SetHealthMultiplier(multiplier); };
  }

  // ===================================================================
  //  PRESENTATION
  // ===================================================================

  // Base-game onscreen message (same widget the game uses for
  // "AREA RESTRICTED" etc.) so arena callouts match the vanilla HUD.
  public static func Notify(text: String, duration: Float) -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let gi = GetGameInstance();

    let bb = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Notifications);
    if !IsDefined(bb) { return; }

    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = duration;
    msg.message = text;
    msg.isInstant = true;

    bb.SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
  }

  // Same as Notify but without the instant pop-in, so a message that is
  // refreshed on a timer does not visibly re-animate each time. Used for
  // the sticky prompts that must simply sit there.
  public static func NotifySticky(text: String, duration: Float) -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let bb = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(GetAllBlackboardDefs().UI_Notifications);
    if !IsDefined(bb) { return; }

    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = duration;
    msg.message = text;
    msg.isInstant = false;

    bb.SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
  }

  // Takes an onscreen message back down. Used to clear the entry prompt
  // when you step out of the room, so it can be shown once and held
  // rather than re-issued on a timer.
  public static func ClearNotify() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let bb = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(GetAllBlackboardDefs().UI_Notifications);
    if !IsDefined(bb) { return; }

    let msg: SimpleScreenMessage;
    msg.isShown = false;
    msg.duration = 0.1;
    msg.message = "";
    msg.isInstant = true;

    bb.SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(msg), true);
  }

  public static func PlaySound(soundName: CName) -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let gi = GetGameInstance();
    let player = GetPlayer(gi);
    GameInstance.GetAudioSystem(gi).Play(soundName, player.GetEntityID());
  }

  public static func PlayArenaMusic() -> Void {
    if !ArenaSpawner.IsInGameplay() { return; }
    let gi = GetGameInstance();
    let audioSys = GameInstance.GetAudioSystem(gi);
    let player = GetPlayer(gi);

    audioSys.NotifyGameTone(n"EnterCombat");
    audioSys.NotifyGameTone(n"EnterDangerous");
    audioSys.Play(n"ui_jingle_chip_malfunction", player.GetEntityID());
  }

  public static func StopArenaMusic() -> Void {
    let gi = GetGameInstance();
    let audioSys = GameInstance.GetAudioSystem(gi);
    if !IsDefined(audioSys) { return; }
    audioSys.NotifyGameTone(n"LeaveCombat");
    audioSys.NotifyGameTone(n"EnterPublic");
  }

  // ===================================================================
  //  ARENA STATE  (mirrored so the input listener knows when to react)
  // ===================================================================

  public static func SetArenaState(state: Int32) -> Void {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { service.arenaState = state; };
  }

  public static func GetArenaState() -> Int32 {
    let service = ArenaSpawner.GetService();
    if IsDefined(service) { return service.arenaState; };
    return 0;
  }

  // ===================================================================
  //  INTERNAL
  // ===================================================================

  public static func GetService() -> ref<ArenaKillService> {
    return GameInstance.GetScriptableServiceContainer().GetService(n"ArenaKillService") as ArenaKillService;
  }
}

// =====================================================================
//  Entry-room interact.
//
//  The one action still handled through the game's input contexts is
//  Choice1 - the interact key - which drives the entry hub's "Enter
//  the Arena" choice. All the mod's own keys (menu / exit / summon) are
//  raw keys chosen in Mod Settings, read through Codeware's input
//  events in ArenaKillService.OnKeyInput below.
// =====================================================================
public class ArenaInputListener {

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    let service = GameInstance.GetScriptableServiceContainer().GetService(n"ArenaKillService") as ArenaKillService;
    if !IsDefined(service) { return false; }

    // In the entry room, the game's own interact key takes you in - the
    // same key you use for everything else in the world.
    if service.arenaState == 0 && service.nearEntry {
      if ListenerAction.IsAction(action, n"Choice1") {
        let actionType = ListenerAction.GetType(action);
        if Equals(actionType, gameinputActionType.BUTTON_RELEASED)
           || Equals(actionType, gameinputActionType.BUTTON_HOLD_COMPLETE) {
          service.pendingCommand = 1;
        };
      };
    };

    return false;
  }
}

@addField(PlayerPuppet)
public let arenaInputListener: ref<ArenaInputListener>;

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();
  this.arenaInputListener = new ArenaInputListener();
  this.RegisterInputListener(this.arenaInputListener);

  let sys = ArenaSystem.Get();
  if IsDefined(sys) { sys.Boot(); };
}

// Backstop for the flatline. Immortality should floor health at 1 and
// let the tick catch it, but if a hit ever does register as a death
// while a run is live, this turns it into an arena flatline instead of
// the game's death screen.
@wrapMethod(PlayerPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let sys = ArenaSystem.Get();
  if IsDefined(sys) {
    if sys.state == 2 {
      ModLog(n"CombatArena", "OnDeath intercepted during run - flatlining to menu");
      sys.Flatline();
      return true;
    };
  };
  return wrappedMethod(evt);
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
  wrappedMethod();
  if IsDefined(this.arenaInputListener) {
    this.UnregisterInputListener(this.arenaInputListener);
    this.arenaInputListener = null;
  };
}

// =====================================================================
//  The bartender's interaction.
//
//  r6/tweaks/CombatArena.yaml appends Interactions.CombatArenaJackIn to
//  Character.wat_kab_foodshop_02. When it is chosen, the game raises an
//  InteractionChoiceEvent on the puppet; we catch it here and post the
//  enter command. Every other interaction on every other NPC passes
//  straight through untouched.
// =====================================================================
//
//  choiceMetaData.tweakDBName is a String, not a CName - confirmed by
//  compiling a probe that assigned it to all three candidate types and
//  seeing which one the compiler accepted. The first version of this
//  compared it against a CName literal, which the compiler flagged as
//  "comparing unrelated types" and would have silently never matched.
//
//  Substring rather than equality because the field may arrive bare or
//  namespace-qualified, and either of our two records could name it.
//
@wrapMethod(ScriptedPuppet)
protected cb func OnInteraction(evt: ref<InteractionChoiceEvent>) -> Bool {
  let choiceName: String = evt.choice.choiceMetaData.tweakDBName;
  if StrContains(choiceName, "CombatArenaJackIn") || StrContains(choiceName, "CombatArenaChoice") {
    ModLog(n"CombatArena", "Arena entry chosen at the bar (" + choiceName + ")");
    let sys = ArenaSystem.Get();
    if IsDefined(sys) { sys.EnterArena(); };
    return true;
  };
  return wrappedMethod(evt);
}

// =====================================================================
//  Service holding the mod's mutable native-side state.
//  (REDscript has no static mutable fields, hence the service.)
// =====================================================================
public class ArenaKillService extends ScriptableService {
  private let healthMultiplier: Float;
  public let patrolLocations: array<Vector4>;
  public let lastGruntKills: Int32;
  public let lastBossKills: Int32;
  public let pendingCommand: Int32;

  // Mirrored arena state: 0 idle, 1 lobby, 2 fighting, 3 results.
  public let arenaState: Int32;
  // True while stood next to Mateo, so the terminal key can take you in.
  public let nearEntry: Bool;

  // Exit is a hold; the tick accumulates while the key is down.
  public let exitHolding: Bool;
  public let exitHeld: Float;

  // Map pins for the two entrances.
  public let mappinIds: array<NewMappinID>;

  private cb func OnLoad() {
    this.healthMultiplier = 1.0;
    this.lastGruntKills = 0;
    this.lastBossKills = 0;
    this.pendingCommand = 0;
    this.arenaState = 0;
    this.exitHolding = false;

    GameInstance.GetCallbackSystem()
      .RegisterCallback(n"Entity/AfterAttach", this, n"OnArenaEntityAttached")
      .AddTarget(DynamicEntityTarget.Tag(n"CombatArena"));

    GameInstance.GetCallbackSystem()
      .RegisterCallback(n"Entity/AfterAttach", this, n"OnAllyEntityAttached")
      .AddTarget(DynamicEntityTarget.Tag(n"CombatArenaAlly"));

    // Raw key events for the Mod Settings bindings. These fire in every
    // input context - gameplay, popup, anywhere - which is exactly what
    // lets the menu key close the terminal it opened.
    GameInstance.GetCallbackSystem()
      .RegisterCallback(n"Input/Key", this, n"OnKeyInput");
  }

  private cb func OnKeyInput(evt: ref<KeyInputEvent>) {
    // Inert outside the arena; the entry room runs on the interact key.
    if this.arenaState == 0 { return; }

    let settings = ArenaSettings.Get();
    if !IsDefined(settings) { return; }

    let key = evt.GetKey();
    let action = evt.GetAction();

    if Equals(key, settings.ArenaMenuKey) {
      if Equals(action, EInputAction.IACT_Release) {
        this.pendingCommand = 4;
      };
      return;
    };

    if Equals(key, settings.ArenaSummonKey) {
      if Equals(action, EInputAction.IACT_Release) {
        ModLog(n"CombatArena", "summon key released -> cmd 3");
        this.pendingCommand = 3;
      };
      return;
    };

    if Equals(key, settings.ArenaExitKey) {
      if Equals(action, EInputAction.IACT_Press) {
        this.exitHolding = true;
        this.exitHeld = 0.0;
      };
      if Equals(action, EInputAction.IACT_Release) {
        this.exitHolding = false;
      };
    };
  }

  public func SetHealthMultiplier(mult: Float) -> Void {
    this.healthMultiplier = mult;
  }

  public func ResetHarvest() -> Void {
    this.lastGruntKills = 0;
    this.lastBossKills = 0;
  }

  public func RecordHarvest(grunts: Int32, bosses: Int32) -> Void {
    this.lastGruntKills = grunts;
    this.lastBossKills = bosses;
  }

  private cb func OnArenaEntityAttached(event: ref<EntityLifecycleEvent>) {
    let entity = event.GetEntity();
    if !IsDefined(entity) { return; }

    let npc = entity as NPCPuppet;
    if !IsDefined(npc) { return; }

    let player = GetPlayer(GetGameInstance());
    if !IsDefined(player) { return; }

    let attAgent = npc.GetAttitudeAgent();
    if IsDefined(attAgent) {
      attAgent.SetAttitudeGroup(n"hostile");
      attAgent.SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
    };

    if this.healthMultiplier != 1.0 {
      let sps = GameInstance.GetStatPoolsSystem(GetGameInstance());
      if IsDefined(sps) {
        let eid = Cast<StatsObjectID>(npc.GetEntityID());
        let currentHealth = sps.GetStatPoolValue(eid, gamedataStatPoolType.Health);
        if currentHealth > 0.0 {
          sps.RequestSettingStatPoolValue(eid, gamedataStatPoolType.Health,
            currentHealth * this.healthMultiplier, npc, false);
        };
      };
    };

    // AI needs a moment after attach before it will accept move commands.
    let callback = new ArenaPatrolCallback();
    callback.npcEntityID = npc.GetEntityID();
    callback.isAlly = false;
    GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(callback, 3.0, false);
  }

  private cb func OnAllyEntityAttached(event: ref<EntityLifecycleEvent>) {
    let entity = event.GetEntity();
    if !IsDefined(entity) { return; }

    let player = GetPlayer(GetGameInstance());
    if !IsDefined(player) { return; }

    // NPCPuppet covers humans; gamePuppet also covers drones and mechs.
    let attAgent: ref<AttitudeAgent>;
    let npc = entity as NPCPuppet;
    if IsDefined(npc) {
      attAgent = npc.GetAttitudeAgent();
    } else {
      let puppet = entity as gamePuppet;
      if IsDefined(puppet) { attAgent = puppet.GetAttitudeAgent(); };
    };

    if !IsDefined(attAgent) {
      ModLog(n"CombatArena", "Ally attached but has no attitude agent");
      return;
    };

    ModLog(n"CombatArena", "ALLY SPAWNED OK: " + NameToString(entity.GetClassName()));

    attAgent.SetAttitudeGroup(n"player");
    attAgent.SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);

    if IsDefined(npc) {
      let callback = new ArenaPatrolCallback();
      callback.npcEntityID = npc.GetEntityID();
      callback.isAlly = true;
      GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(callback, 2.0, false);
    };
  }
}

// =====================================================================
//  Repeating movement callback.
//  Enemies wander the arena; allies stick close to the player.
//  Either way it stops as soon as the NPC finds a fight.
// =====================================================================
public class ArenaPatrolCallback extends DelayCallback {
  public let npcEntityID: EntityID;
  public let isAlly: Bool;

  protected func Call() -> Void {
    let gi = GetGameInstance();
    let player = GetPlayer(gi);
    if !IsDefined(player) { return; }

    let entity = GameInstance.FindEntityByID(gi, this.npcEntityID);
    if !IsDefined(entity) { return; }

    let npc = entity as NPCPuppet;
    if !IsDefined(npc) { return; }
    if npc.IsDead() { return; }

    // In combat: hands off, the combat AI is doing better than we would.
    if NPCPuppet.IsInCombat(npc) {
      let retry = new ArenaPatrolCallback();
      retry.npcEntityID = this.npcEntityID;
      retry.isAlly = this.isAlly;
      GameInstance.GetDelaySystem(gi).DelayCallback(retry, 8.0, false);
      return;
    };

    let attAgent = npc.GetAttitudeAgent();
    if IsDefined(attAgent) {
      if this.isAlly {
        attAgent.SetAttitudeGroup(n"player");
        attAgent.SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);
      } else {
        attAgent.SetAttitudeGroup(n"hostile");
        attAgent.SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
      };
    };

    let targetPos: Vector4;
    let movement = moveMovementType.Walk;
    if this.isAlly {
      // Follow on a short leash: hold inside 4m, run from 9m out. Kept
      // deliberately tight because the engine teleports companions who
      // fall far behind - staying close means it never has a reason to.
      let d = Vector4.Distance(npc.GetWorldPosition(), player.GetWorldPosition());
      if d <= 4.0 {
        let idleNext = new ArenaPatrolCallback();
        idleNext.npcEntityID = this.npcEntityID;
        idleNext.isAlly = true;
        GameInstance.GetDelaySystem(gi).DelayCallback(idleNext, 2.0, false);
        return;
      };
      if d > 9.0 { movement = moveMovementType.Run; };
      targetPos = player.GetWorldPosition();
    } else {
      let service = GameInstance.GetScriptableServiceContainer().GetService(n"ArenaKillService") as ArenaKillService;
      if !IsDefined(service) { return; }
      if ArraySize(service.patrolLocations) == 0 { return; }

      // 1-in-4 enemies head straight for the player; the rest reposition.
      if RandRange(0, 4) == 3 {
        targetPos = player.GetWorldPosition();
      } else {
        targetPos = service.patrolLocations[RandRange(0, ArraySize(service.patrolLocations))];
      };
    };

    let aiComponent = npc.GetAIControllerComponent();
    if IsDefined(aiComponent) {
      let moveCmd = new AIMoveToCommand();
      let targetSpec: AIPositionSpec;
      let wp: WorldPosition;
      WorldPosition.SetVector4(wp, targetPos);
      AIPositionSpec.SetWorldPosition(targetSpec, wp);
      moveCmd.movementTarget = targetSpec;
      moveCmd.movementType = movement;
      moveCmd.rotateEntityTowardsFacingTarget = false;
      moveCmd.desiredDistanceFromTarget = this.isAlly ? 3.0 : 1.0;
      moveCmd.finishWhenDestinationReached = true;
      moveCmd.ignoreNavigation = false;
      aiComponent.SendCommand(moveCmd);
    };

    let nextCallback = new ArenaPatrolCallback();
    nextCallback.npcEntityID = this.npcEntityID;
    nextCallback.isAlly = this.isAlly;
    let delay = this.isAlly ? 2.0 : Cast<Float>(RandRange(5000, 20000)) / 1000.0;
    GameInstance.GetDelaySystem(gi).DelayCallback(nextCallback, delay, false);
  }
}


// (The widget-level icon wraps are removed for now: they are one of the
//  two suspects for the pins disappearing, and this build isolates the
//  cause by restoring exactly the configuration that last rendered.)
