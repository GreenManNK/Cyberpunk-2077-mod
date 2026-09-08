-- =============================================================================
-- Night City Finance — CET module (v1.0.0)
-- =============================================================================
-- Sole responsibility: when Redscript signals an armed loan-shark ambush,
-- spawn 3 Animals goons near V outdoors using PreventionSpawnSystem and put
-- them into combat via a Combat-stim broadcast. Best-effort despawn after
-- 4 minutes.
--
-- Redscript bridge:
--   Game.NCF_LoanSharkAmbushPending() -> Bool        (poll source)
--   Game.NCF_LoanSharkAmbushFired()                  (called after spawn)
--   Game.NCF_PlayerIsOutdoorSafe() -> Int32          (1 = safe to spawn)
--   Game.NCF_DebugForceLoanSharkAmbush()             (test trigger)
--
-- Architecture:
--   Single spawn backend (PreventionSpawnSystem:RequestUnitSpawn) is the only
--   path that visibly produces NPCs in our test installs. Codeware's
--   DynamicEntitySystem returned valid IDs but the entities never rendered;
--   that path was removed in v1.0.0.
--
--   Hostility is achieved via StimBroadcasterComponent.BroadcastStim with the
--   Combat stim type. Animals are hostile-faction by default to V, so the
--   stim alone is enough to put them in combat — no per-puppet AI commands
--   are needed (and Prevention doesn't return puppet handles anyway, only
--   request IDs). The broadcast is repeated at 1s / 2.5s / 4s to catch goons
--   that stream in late.
-- =============================================================================

local NCF = {}

-- ---------------------------------------------------------------------------
-- Cron — minimal local scheduler. Public CET pattern.
-- ---------------------------------------------------------------------------
local Cron = {}
Cron._tasks = {}

function Cron.After(seconds, fn)
  table.insert(Cron._tasks, { at = os.clock() + seconds, fn = fn, repeating = false })
end

function Cron.Every(seconds, fn)
  table.insert(Cron._tasks, {
    at = os.clock() + seconds, interval = seconds, fn = fn, repeating = true
  })
end

function Cron._tick()
  local now = os.clock()
  local i = 1
  while i <= #Cron._tasks do
    local t = Cron._tasks[i]
    if now >= t.at then
      pcall(t.fn)
      if t.repeating then
        t.at = now + t.interval
        i = i + 1
      else
        table.remove(Cron._tasks, i)
      end
    else
      i = i + 1
    end
  end
end

-- ---------------------------------------------------------------------------
-- Character record pools.
--
-- Animals records VERIFIED via TweakDB enumeration in patch 2.31:
--   for _, r in ipairs(TweakDB:GetRecords("gamedataCharacter_Record")) do
--     local s = TDBID.ToStringDEBUG(r:GetID())
--     if string.find(s, "animals", 1, true) then print(s) end end
-- 142 Animals records exist; the ones below were picked for variety.
-- Naming convention: <area_prefix>_animals_<role><tier>_<weapon>_<gender>[_rarity]
-- ---------------------------------------------------------------------------
local ANIMALS_GRUNT_POOL = {
  "Character.animals_grunt1_ranged1_pulsar_mb",
  "Character.animals_grunt2_hmelee2_fists_wba_rare",
  "Character.dtn_animals_grunt1_melee1_baseball_mb",
  "Character.cpz_animals_bouncer2_melee2_fists_mb",
  "Character.wwd_animals_grunt2_hmelee2_fists_wba_rare",
}
local ANIMALS_ELITE_POOL = {
  "Character.animals_elite2_hmelee2_hammer_mba_rare",
  "Character.animals_bouncer2_hmelee2_hammer_mba_rare",
  "Character.cvi_animals_grunt2_shotgun2_igla_wba_rare",
}

local function randElem(t) return t[math.random(1, #t)] end

-- ---------------------------------------------------------------------------
-- Ground snapping. Casts a ray straight down from above the candidate spawn
-- point to find the actual world surface. Without this, goons spawn at the
-- player's exact Z, which is wrong on any uneven terrain — sidewalks, ramps,
-- raised dividers, mid-block planters all sit higher than the road the
-- player is standing on.
--
-- Uses `gamestateMachineGameScriptInterface:RaycastWithASingleGroup`, which
-- is the script-friendly wrapper (returns a result object with IsValid +
-- .position). Pattern lifted from World Builder's editor.lua. The interface
-- is captured by observing LocomotionEventsTransition.OnUpdate (set up in
-- onInit) and lives in `cachedInterface` for as long as the player is in
-- locomotion — i.e. always, while a save is loaded.
--
-- "PlayerBlocker" collision group hits walkable world geometry (roads,
-- sidewalks, buildings, doors, terrain) and ignores characters and small
-- dynamic props. Cast window: from +5m above to -5m below the input Z.
-- Returns the surface Z, or the input Z if the interface isn't ready yet
-- or the cast misses (no static surface in the window — typically over
-- water, off-map, or in an unstreamed cell).
-- ---------------------------------------------------------------------------
local cachedInterface = nil

local function groundSnapZ(x, y, z)
  if not cachedInterface then return z end
  local from = Vector4.new(x, y, z + 5.0, 1.0)
  local to = Vector4.new(x, y, z - 5.0, 1.0)
  local ok, result = pcall(function()
    return cachedInterface:RaycastWithASingleGroup(from, to, "PlayerBlocker")
  end)
  if ok and result and result:IsValid() then
    local hitPos = result.position
    if hitPos and hitPos.z then
      return hitPos.z
    end
  end
  return z
end

-- ---------------------------------------------------------------------------
-- Position sampling: generic ring around the player.
--
-- Evenly-spaced angles around a circle, with small random jitter so the
-- formation doesn't look identical every time. Each position is ground-
-- snapped via a downward raycast so goons spawn on the actual surface
-- rather than at the player's Z (which is wrong wherever terrain isn't
-- perfectly flat).
-- ---------------------------------------------------------------------------
local function sampleRingPositions(playerPos, count, minRadius, maxRadius)
  local positions = {}
  if count <= 0 then return positions end
  local step = (math.pi * 2) / count
  local startOffset = math.random() * math.pi * 2  -- rotate the whole ring
  for i = 0, count - 1 do
    local angle = startOffset + step * i + (math.random() - 0.5) * 0.3
    local radius = minRadius + math.random() * (maxRadius - minRadius)
    local x = playerPos.x + math.cos(angle) * radius
    local y = playerPos.y + math.sin(angle) * radius
    local z = groundSnapZ(x, y, playerPos.z)
    table.insert(positions, { x = x, y = y, z = z })
  end
  return positions
end

-- ---------------------------------------------------------------------------
-- Spawn one NPC at a position. Returns true on success, false otherwise.
-- ---------------------------------------------------------------------------
local function spawnOne(recordPath, pos)
  local sys = Game.GetPreventionSpawnSystem()
  if not sys then return false end
  local wt = WorldTransform.new()
  wt:SetPosition(Vector4.new(pos.x, pos.y, pos.z, 1.0))
  local ok = pcall(function()
    sys:RequestUnitSpawn(TweakDBID.new(recordPath), wt)
  end)
  return ok
end

-- ---------------------------------------------------------------------------
-- Aggression. Single mechanism: broadcast a Combat stim from V at 50m radius.
-- Animals are hostile-faction by default, so receiving this stim makes them
-- engage immediately. Repeated at 1s / 2.5s / 4s to catch goons that finish
-- streaming in later than the first pulse.
-- ---------------------------------------------------------------------------
local function broadcastCombat(player)
  pcall(function()
    StimBroadcasterComponent.BroadcastStim(
      player,
      Enum.new("gamedataStimType", "Combat"),
      50.0
    )
  end)
end

-- ---------------------------------------------------------------------------
-- Optional warning popup so the player understands what just happened.
-- ---------------------------------------------------------------------------
local function showAmbushWarning()
  pcall(function()
    local msg = SimpleScreenMessage.new()
    msg.isShown = true
    msg.duration = 5.0
    msg.message = "ANIMALS — Croyle sent some boys to collect."
    msg.type = Enum.new("SimpleMessageType", "Negative")
    Game.GetBlackboardSystem():Get(GetAllBlackboardDefs().UI_Notifications)
      :SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage,
        ToVariant(msg), true)
  end)
end

-- ---------------------------------------------------------------------------
-- The actual ambush trigger.
-- ---------------------------------------------------------------------------
local DESPAWN_AFTER_SECONDS = 4 * 60

local function fireAmbush()
  local player = Game.GetPlayer()
  if not player then return false end
  local pos = player:GetWorldPosition()
  if not pos then return false end

  -- Re-check the safety gate at the LAST possible moment. The pollLoop
  -- already checked, but up to 5s elapsed since then — V may have entered
  -- a vehicle, started a phone-driven scene, etc. Cheap RTTI call.
  local stillSafe = 0
  pcall(function() stillSafe = Game.NCF_PlayerIsOutdoorSafe() end)
  if stillSafe ~= 1 then
    print("[NCF][AMBUSH] aborted at spawn-time gate (player no longer outdoor-safe)")
    return false
  end

  local positions = sampleRingPositions(pos, 3, 12.0, 18.0)
  local successCount = 0

  -- 2 grunts + 1 elite. Order doesn't matter; positions are random.
  local records = {
    randElem(ANIMALS_GRUNT_POOL),
    randElem(ANIMALS_GRUNT_POOL),
    randElem(ANIMALS_ELITE_POOL),
  }
  for i, p in ipairs(positions) do
    if spawnOne(records[i], p) then
      successCount = successCount + 1
      print(("[NCF][AMBUSH] spawn ok record=%s"):format(records[i]))
    else
      print(("[NCF][AMBUSH] spawn FAILED record=%s"):format(records[i]))
    end
  end

  if successCount == 0 then
    print("[NCF][AMBUSH] all spawn attempts failed; aborting")
    return false
  end

  -- Combat stim pulses — three rounds to catch late-streaming goons.
  Cron.After(1.0, function() broadcastCombat(player) end)
  Cron.After(2.5, function() broadcastCombat(player) end)
  Cron.After(4.0, function() broadcastCombat(player) end)

  -- Best-effort despawn after the window. Prevention manages its own
  -- cleanup via the wanted-cooldown pipeline; this is a no-op safety net.
  Cron.After(DESPAWN_AFTER_SECONDS, function()
    -- Nothing to explicitly delete — Prevention owns the entities.
    -- Logged so we know the ambush window has fully ended.
    print("[NCF][AMBUSH] despawn window elapsed")
  end)

  showAmbushWarning()
  return true
end

-- ---------------------------------------------------------------------------
-- Polling. Calls into Redscript bridge every 5s; cheap.
-- ---------------------------------------------------------------------------
local POLL_INTERVAL = 5.0
local _pollDebug = false

local function pollLoop()
  local pending = false
  pcall(function() pending = Game.NCF_LoanSharkAmbushPending() end)
  if _pollDebug then print("[NCF][POLL] pending=", pending) end
  if not pending then return end

  local outdoorSafe = 0
  pcall(function() outdoorSafe = Game.NCF_PlayerIsOutdoorSafe() end)
  if _pollDebug then print("[NCF][POLL] outdoorSafe=", outdoorSafe) end
  if outdoorSafe ~= 1 then return end

  local player = Game.GetPlayer()
  if not player then return end

  -- gamePSMCombat enum: 0=Default, 1=InCombat, 2=OutOfCombat, 3=Stealth.
  -- Only InCombat (1) blocks an ambush.
  local inCombat = false
  pcall(function()
    inCombat = player:GetPlayerStateMachineBlackboard()
                    :GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == 1
  end)
  if _pollDebug then print("[NCF][POLL] inCombat=", inCombat) end
  if inCombat then return end

  local mounted = false
  pcall(function() mounted = player:GetMountedVehicle() ~= nil end)
  if _pollDebug then print("[NCF][POLL] mounted=", mounted) end
  if mounted then return end

  print("[NCF][AMBUSH] firing ambush")

  -- Only clear the pending flag on actual success — if fireAmbush bails on
  -- its spawn-time safety re-check (player entered a scene/vehicle in the
  -- 5s since the poll), we want the next poll to retry.
  local ok, errOrResult = pcall(fireAmbush)
  if not ok then
    print("[NCF][AMBUSH] fireAmbush ERRORED: " .. tostring(errOrResult))
    return
  end
  if not errOrResult then
    print("[NCF][AMBUSH] fireAmbush returned false; leaving pending armed for next poll")
    return
  end
  pcall(function() Game.NCF_LoanSharkAmbushFired() end)
end

-- Debug toggle exposed for CET console: NCF.SetPollDebug(true)
NCF.SetPollDebug = function(on) _pollDebug = on; print("[NCF] pollDebug =", on) end


-- ---------------------------------------------------------------------------
-- CET registration
-- ---------------------------------------------------------------------------
registerForEvent("onInit", function()
  print("[NCF] init: PreventionSpawnSystem ambush driver ready")
  -- Capture the gamestateMachineGameScriptInterface used by RaycastWithASingleGroup.
  -- Pattern lifted from World Builder's editor.lua. The interface is passed to every
  -- LocomotionEventsTransition update tick — fires constantly while the player is
  -- moving or standing in the world. We just stash the latest handle.
  Observe("LocomotionEventsTransition", "OnUpdate", function(_, _, _, interface)
    cachedInterface = interface
  end)
  Cron.Every(POLL_INTERVAL, pollLoop)

end)

registerForEvent("onUpdate", function(delta)
  Cron._tick()
end)

registerForEvent("onShutdown", function()
  -- Prevention owns its entities and cleans them up on shutdown. Nothing
  -- to do here.
end)

return NCF
