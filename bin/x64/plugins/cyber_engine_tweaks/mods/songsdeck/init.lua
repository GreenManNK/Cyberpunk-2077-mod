local Cron = require("External/Cron")
local GameSession = require("External/GameSession")
local BlackwallUpload = require("BlackwallUpload")

local MOD_NAME = "Songbird's Deck"

-- blackwall screen effects to use
-- p_songbird_sickness.effect for intro, not whole time; similar to johnny effects very cool
-- q306_black_wall_screen_gmp.effect persistent status effect
-- q306_blackawall_[fast/short].effect quick screen effects
-- blackwall_force_screen and blackwall_use_force
-- black_wall_activate_drone cant tell if is player effect
-- holo_somi_spawn or despawn kinda sounds cool
-- slider_time_dilation
-- blackwall_onscreen_slider_death

-- Use ent effect 4 from myers bc it has sound, sparks from duty free
-- Duty free non sparks is also cool, use effect 1 for longevity
-- q304_songbird_hack_effect effect 3 large area does not dissipate
-- q306 lightning effect also cool, all effects do different lighting strikes, very fast, probably should be slowed and do some type of random spawn
-- q306 sparks end scene larger sparks, some lighting; also fast
local HORIZON_ENT = "base\\fx\\blackwall_horizon_fx_intro_anim_BHI.ent"
local EFFECT_ENT_ALT = "base\\fx\\q306_blackwall_duty_free_gate_sparks_and_textures_BHI.ent"
local SPARKS_AND_BASE = "base\\fx\\q306_myers_gate_blackwall_spark_and_textures_BHI.ent"
local SONGBIRD_LARGE_AREA = "base\\fx\\q304_songbird_hack_effect_BHI.ent"
local BASE_INTENSE = "base\\fx\\q306_blackwall_duty_free_gate_text_BHI.ent"
-- No autospawn, must be triggered by object reference after being created
local LIGHTNING = "base\\fx\\q306_lightning_zaps_BHI.ent"

local INTRO_EFFECT = "base\\fx\\p_songbird_sickness_BHI.effect"
local PERSISTENT_STATUS_EFFECT = "base\\fx\\q306_black_wall_screen_gmp_BHI.effect"
local FORCE_SCREEN = "base\\fx\\blackwall_force_screen_BHI.effect"
local USE_FORCE = "base\\fx\\blackwall_use_force_BHI.effect"

local EFFECT_OUTRO_SOUND = "base\\fx\\q304_holo_somi_spawn_BHI.effect"
local EFFECT_OUTRO_VIS = "base\\fx\\q304_blackwall_onscreen_lab_longer_BHI.effect"

local BLACKWALL_VIDEO_PATH = "base\\videores\\blackwall_infected_screen_BHI.bk2"

local DEBUG = true
local cooldown = {}
local cooldownSeconds = 2.0

local RADIUS = 50
local VEHICLE_RADIUS = 50
local VEHICLE_ON = true

local activeFx = {}
local followingPlayerFx = {}
local playerFxFollowTimer = nil
local activeBlackwallEntityIds = {}
local activeNetowrkController = nil
local carryingWoundedF = false
local isDeckEquipped = false

local overdriveOccuring = false
local soundLoopTimer = nil

local RAM_DRAIN_PER_TICK = 0.2
local RAM_DRAIN_INTERVAL = 0.1
local HP_PER_RAM_UNIT = 10.0
local MIN_HEALTH_FLOOR = 10.0
local BLACKWALL_ENTITY_DESPAWN = true
local BLACKWALL_ENTITY_DESPAWN_TIME = 30.0

local REVENGE_TYPE = 2 -- 1 = none, 2 = always, 3 = whendownlink

local PER_PULSE_DRAIN = false
local PER_PULSE_RAM_DRAIN_AMOUNT = 2.0

local GAMEPLAY_MECHANICS_ENABLED = true
local KNOCKDOWN_ENABLED = true
local CYBERWAREEX_COMPATIBILITY = false
local HOLD_TAB_TO_TRIGGER = false
local HOLD_SECONDS = 2.0

local TIME_SCALE = 0.65

local cyberwareex_enabled = false
local scanning  = false
local drainTimer = nil

local actionLog = false

-- Dark Future integration
local DARK_FUTURE_ENABLED = false
local energySystem = nil
local nerveSystem = nil

local function distSq(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  local dz = a.z - b.z
  return dx * dx + dy * dy + dz * dz
end

local function isDefined(value)
  return value ~= nil and IsDefined(value)
end

local function log(msg)
  if DEBUG then
    print("[" .. MOD_NAME .. "] " .. tostring(msg))
  end
end

local function callDeviceMethod(deviceType, methodName, fn)
  local ok, err = pcall(fn)

  if not ok then
    log(tostring(deviceType) .. " " .. tostring(methodName)
      .. " failed: " .. tostring(err))
    return false
  end

  log(tostring(deviceType) .. " " .. tostring(methodName) .. " executed")
  return true
end

-- Sensor devices dealt with through AccessPoint path not general search
---@param ent Device
local function resolveDeviceAction(ent)
  if ent:IsA("Device") and not ent:IsA("SensorDevice") then
    if ent:IsA("Radio") then
      return callDeviceMethod("radio", "ApplyElectricDamage", function()
        ---@diagnostic disable-next-line: undefined-field
        return ent:ApplyElectricDamage()
      end)
    end
    if ent:IsA("Speaker") then
      return callDeviceMethod("speaker", "TurnOffDevice", function()
        return ent:TurnOffDevice()
      end)
    end
    if ent:IsA("TV") then
      return callDeviceMethod("tv", "BlackwallStartGlitching", function()
          ---@type TVControllerPS
          ---@diagnostic disable-next-line: assign-type-mismatch
          local tvController = ent:GetDevicePS()
          if not tvController or not tvController:IsA("TVControllerPS") then return end
          log("Got TV controller" .. Game.NameToString(tvController:GetClassName()))
          log(tvController:GetDefaultGlitchVideoPath():ToString())
          tvController.defaultGlitchVideoPath = redResourceReferenceScriptToken.FromString(BLACKWALL_VIDEO_PATH)
          log(tvController:GetDefaultGlitchVideoPath():ToString())
          ent:StartGlitching(EGlitchState.DEFAULT, 1.0)
          log("Started glitching")
      end)
    end
    if ent:IsA("ExplosiveDevice") then
      return callDeviceMethod("explosive_device", "Explode", function()
        ---@type ExplosiveDeviceControllerPS
        ---@diagnostic disable-next-line: assign-type-mismatch
        local devicePS = ent:GetDevicePS()
        if not devicePS then return false end
        local act = devicePS:ActionForceDetonate()
        if not act then return false end
        ---@diagnostic disable-next-line: missing-parameter
        return devicePS:ExecutePSAction(act)
      end)
    end
    return callDeviceMethod("generic", "StartGlitching", function()
      ---@diagnostic disable-next-line: missing-parameter
      return ent:StartGlitching(EGlitchState.DEFAULT)
    end)
  end
  return false
end

---@param targetPart TS_TargetPartInfo
local function getEntityFromTargetPart(targetPart)
  if not targetPart then return nil end
  local component = targetPart:GetComponent()
  if not isDefined(component) then return nil end
  local ent = component:GetEntity()
  if not isDefined(ent) then return nil end
  return ent
end

local TURRET_ENEMY_RANGE = 60.0

--- TSQ_EnemyNPC + not-friendly / aggressive / alive — broader than GetHostileThreats.
local function queryEnemyNPCsNear(instigator, maxDistance)
  local targetingSystem = Game.GetTargetingSystem()
  if not targetingSystem or not isDefined(instigator) then return {} end

  local searchQuery = TSQ_EnemyNPC()
  searchQuery.maxDistance = maxDistance or TURRET_ENEMY_RANGE
  searchQuery.testedSet = TargetingSet.Complete
  searchQuery.searchFilter = TSF_And(
    TSF_Not(gametargetingSystemSearchFilterMaskValue.Att_Friendly),
    TSF_Any(gametargetingSystemSearchFilterMaskValue.Sp_Aggressive),
    TSF_Any(gametargetingSystemSearchFilterMaskValue.St_Alive)
  )

  local success, targetParts = targetingSystem:GetTargetParts(instigator, searchQuery)
  if not success or not targetParts then return {} end

  local entities = {}
  local seen = {}
  for _, targetPart in ipairs(targetParts) do
    local ent = getEntityFromTargetPart(targetPart)
    if ent and ent:IsA("ScriptedPuppet") and not ent:IsPlayer() then
      local key = tostring(ent:GetEntityID().hash)
      if not seen[key] then
        seen[key] = true
        table.insert(entities, ent)
      end
    end
  end
  return entities
end

local function isTurretTargetStillValid(ent)
  if not isDefined(ent) then return false end
  if ent.IsDead and ent:IsDead() then return false end
  if ScriptedPuppet and ScriptedPuppet.IsDefeated and ScriptedPuppet.IsDefeated(ent) then return false end
  if ScriptedPuppet and ScriptedPuppet.IsUnconscious and ScriptedPuppet.IsUnconscious(ent) then return false end
  return true
end

--- Mark all nearby EnemyNPCs Hostile toward the turret, force-engage nearest.
local function armTurretOnEnemyNPCs(turret)
  if not isDefined(turret) or not turret:IsA("SecurityTurret") then return 0 end

  local enemies = queryEnemyNPCsNear(turret, TURRET_ENEMY_RANGE)
  if #enemies == 0 then
    enemies = queryEnemyNPCsNear(Game.GetPlayer(), TURRET_ENEMY_RANGE)
  end

  local turretPos = turret:GetWorldPosition()
  local nearest, nearestDist = nil, nil
  for _, enemy in ipairs(enemies) do
    if isTurretTargetStillValid(enemy) then
      pcall(function() turret:SongsDeckMarkHostile(enemy) end)
      local d = Vector4.Distance(turretPos, enemy:GetWorldPosition())
      if not nearestDist or d < nearestDist then
        nearest, nearestDist = enemy, d
      end
    end
  end

  local current = nil
  pcall(function()
    if turret.GetCurrentlyFollowedTarget then
      current = turret:GetCurrentlyFollowedTarget()
    end
  end)

  if nearest and not isTurretTargetStillValid(current) then
    pcall(function() turret:SongsDeckForceEngageTarget(nearest) end)
  elseif nearest and isDefined(current) then
    -- Keep current lock; still refresh hostility on the crowd.
    pcall(function() turret:ReevaluateTargets() end)
  end

  log("turret TSQ EnemyNPC armed count=" .. tostring(#enemies)
    .. (nearest and (" nearestDist=" .. string.format("%.1f", nearestDist)) or " (none)"))
  return #enemies
end

-- Do NOT use this for network hacks. Use the accesspoint descendants.
local function queryNearbyEntities(instigator, maxDistance, quickhackableOnly, npcOnly)
  local qhFilter = quickhackableOnly or false
  local npcFilter = npcOnly or false
  local targetingSystem = Game.GetTargetingSystem()
  if not targetingSystem or not instigator then return {} end

  local searchQuery = (npcFilter and TSQ_NPC() or TSQ_ALL())
  searchQuery.maxDistance = maxDistance or RADIUS
  searchQuery.testedSet = TargetingSet.Complete
  if qhFilter then
    searchQuery.searchFilter = TSF_Quickhackable()
  end

  local success, targetParts = targetingSystem:GetTargetParts(instigator, searchQuery)
  if not success or not targetParts then return {} end


  local entities = {}
  local seen = {}

  for _, targetPart in ipairs(targetParts) do
    local ent = getEntityFromTargetPart(targetPart)
    if ent then
      local key = tostring(ent:GetEntityID().hash)
      if not seen[key] then
        seen[key] = true
        table.insert(entities, ent)
      end
    end
  end

  return entities
end

local aProxies = {}

-- Cyberdeck UI State Management
local function setAbilityBlackwallDownlinkActive()
  -- to set: inkFlexWidget # Cyberdeck state ActiveUninterruptible, fg red, decor red, onUse sub red, glowcontainer red
  log("Setting ability blackwall downlink active")
  ---@diagnostic disable-next-line: undefined-field
  local gameInkSystem = GameInstance.GetInkSystem()
  if not gameInkSystem then log("Game Ink System not found") return end
  log("Game Ink System found")
  local hudRootControllers = gameInkSystem:GetLayer("inkHUDLayer"):GetGameControllers()
  if not hudRootControllers then log("HUD Root Controllers not found") return end
  for _, controller in ipairs(hudRootControllers) do
    if Game.NameToString(controller:GetClassName()) == "ChargedHotkeyItemCyberwareController" then
      log("Charged Hotkey Item Cyberware Controller found")
      local cwWidget = controller:GetRootWidget()
      if not cwWidget then log("CW Widget not found") return end
      log("CW Widget found")
      if GAMEPLAY_MECHANICS_ENABLED then
        cwWidget:SetState("ActiveUninterruptible")
      else
        cwWidget:SetState("ActiveInterruptible")
      end
      local glowWidget =cwWidget:GetWidget("GlowContainer"):GetWidget("outerGlow")
      glowWidget:SetTintColor(255,0,0,255)
      -- pulse anim
      local animDef = inkAnimDef.new()
      local animOpts = inkanimPlaybackOptions.new()
      local pulse = inkAnimTransparency.new()
      pulse:SetStartDelay(0.0)
      pulse:SetDuration(0.8)
      pulse:SetStartTransparency(1.0)
      pulse:SetEndTransparency(0.1)
      pulse:SetType(inkanimInterpolationType.Linear)
      pulse:SetMode(inkanimInterpolationMode.EasyIn)
      animDef:AddInterpolator(pulse)
      animOpts.loopInfinite = true
      animOpts.loopType = inkanimLoopType.PingPong
      -- end pulse anim
      table.insert(aProxies, glowWidget:PlayAnimationWithOptions(animDef, animOpts))
      local wrapper_rb = cwWidget:GetWidget("wrapper_RB"):GetWidget("item_wrapper")
      local fgWidget = wrapper_rb:GetWidget("fg")
      fgWidget:SetTintColor(255,0,0,255)
      local decorWidget = wrapper_rb:GetWidget("decor")
      decorWidget:SetTintColor(255,0,0,255)
      return
    end
  end
end

local function setAbilityBlackwallDownlinkInactive()
  log("Setting ability blackwall downlink inactive")
  ---@diagnostic disable-next-line: undefined-field
  local gameInkSystem = GameInstance.GetInkSystem()
  if not gameInkSystem then log("Game Ink System not found") return end
  log("Game Ink System found")
  local hudRootControllers = gameInkSystem:GetLayer("inkHUDLayer"):GetGameControllers()
  if not hudRootControllers then log("HUD Root Controllers not found") return end
  for _, controller in ipairs(hudRootControllers) do
    if Game.NameToString(controller:GetClassName()) == "ChargedHotkeyItemCyberwareController" then
      log("Charged Hotkey Item Cyberware Controller found")
      local cwWidget = controller:GetRootWidget()
      if not cwWidget then log("CW Widget not found") return end
      log("CW Widget found")
      cwWidget:SetState("Default")
      local glowWidget = cwWidget:GetWidget("GlowContainer"):GetWidget("outerGlow")
      for _, proxy in ipairs(aProxies) do
        if IsDefined(proxy) then
          proxy:Stop()
        end
      end
      glowWidget:SetOpacity(0.0)
    end
  end
end
local function now()
  return os.clock()
end

local function getTargetId(target)
  if target and target.GetEntityID then
    return tostring(target:GetEntityID().hash)
  end
  log("getTargetId failed: invalid target or missing GetEntityID")
  return "unknown"
end

local function getLookAtObject()
  local player = Game.GetPlayer()
  if not player then return nil end

  local ts = Game.GetTargetingSystem()
  if not ts then return nil end

  -- false LOS/false transparent usually gives the actual looked-at GameObject.
  return ts:GetLookAtObject(player, false, false)
end

local function rememberBlackwallEntity(entityID)
  if entityID then
    table.insert(activeBlackwallEntityIds, entityID)
  end
end

local function despawnBlackwallEntities(entityIds)
  ---@diagnostic disable-next-line: undefined-field
  local des = Game.GetDynamicEntitySystem()
  if not des then
    log("despawnBlackwallEntities failed: DynamicEntitySystem unavailable")
    return
  end

  local count = 0
  for _, entityID in ipairs(entityIds or {}) do
    local ok, result = pcall(function()
      return des:DeleteEntity(entityID)
    end)

    if ok and result ~= false then
      count = count + 1
    end

    if not ok then
      log("despawnBlackwallEntities failed: " .. tostring(result))
    end
  end

  log("despawned blackwall effect entities: " .. tostring(count))
end

local function scheduleBlackwallEntityDespawn(delaySeconds)
  if delaySeconds == 0.0 then activeBlackwallEntityIds = {} return end
  if #activeBlackwallEntityIds == 0 then return end

  local entityIds = activeBlackwallEntityIds
  activeBlackwallEntityIds = {}

  ---@diagnostic disable-next-line: missing-parameter
  Cron.After(delaySeconds or 30.0, function()
    despawnBlackwallEntities(entityIds)
  end)

  log("scheduled blackwall effect entity despawn in "
    .. tostring(delaySeconds or 30.0) .. "s: " .. tostring(#entityIds))
end

local function spawnEffectAt(target)
  if not target then
    log("No target")
    return
  end

  if not target.GetWorldPosition then
    log("Target has no world position")
    return
  end

  local id = getTargetId(target)
  local t = now()

  if cooldown[id] and (t - cooldown[id]) < cooldownSeconds then
    return
  end

  cooldown[id] = t

  local pos = target:GetWorldPosition()
  local rot = nil

  if target.GetWorldOrientation then
    rot = target:GetWorldOrientation()
  end
  ---@diagnostic disable: inject-field
  local sparksSpec = NewObject("DynamicEntitySpec")
  ---@diagnostic disable-next-line: assign-type-mismatch
  sparksSpec.templatePath = SPARKS_AND_BASE
  sparksSpec.position = pos

  if rot then
    sparksSpec.orientation = rot
  end

  sparksSpec.tags = { CName.new("BlackwallHackFX") }

  local hackSpec = NewObject("DynamicEntitySpec")
  ---@diagnostic disable-next-line: assign-type-mismatch
  hackSpec.templatePath = SONGBIRD_LARGE_AREA
  hackSpec.position = pos

  if rot then
    hackSpec.orientation = rot
  end

  hackSpec.tags = { CName.new("BlackwallHackFX") }

  ---@diagnostic disable: undefined-field
  local des = Game.GetDynamicEntitySystem()
  if not des then
    log("DynamicEntitySystem unavailable. Is Codeware installed/loaded?")
    return
  end

  rememberBlackwallEntity(des:CreateEntity(sparksSpec))
  rememberBlackwallEntity(des:CreateEntity(hackSpec))

  log("Spawned effect at " .. id .. " using " .. SPARKS_AND_BASE)
end

local function explodeVehicle(vehicle)
  if not vehicle or not IsDefined(vehicle) then return end
  local vehicleComponent = vehicle:GetVehicleComponent()
  if not vehicleComponent then return end
  local ok, err = pcall(function()
    local event = VehicleExplodeEvent.new()
    return vehicleComponent:QueueEntityEvent(event)
  end)
  if not ok then
    log("Failed to explode vehicle: " .. tostring(err))
  end
end

-- Compare classname to device list, check if vehicle. VEHICLE_ON is a settings flag not an instance flag.
local function classifyNearbyEntities(entities, playerPos)
  local deviceMatches = {}
  local vehicleEntities = {}
  local radiusSq = RADIUS * RADIUS
  local vehicleRadiusSq = VEHICLE_RADIUS * VEHICLE_RADIUS

  for _, ent in ipairs(entities) do
    local ok, err = pcall(function()
      local posOk, pos = pcall(function()
        return ent:GetWorldPosition()
      end)

      if not posOk then return end

      local distanceSq = distSq(playerPos, pos)

      local action = resolveDeviceAction(ent)

      if action and distanceSq <= radiusSq then
        table.insert(deviceMatches, { entity = ent, action = action })
      end

      if VEHICLE_ON and distanceSq <= vehicleRadiusSq and ent:IsA("VehicleObject") then
        table.insert(vehicleEntities, ent)
      end
    end)

    if not ok then
      log("classifyNearbyEntities failed for entity: " .. tostring(err))
    end
  end

  return deviceMatches, vehicleEntities
end

local function applyToNearbyVehicles(vehicleEntities)
  if not VEHICLE_ON then return end

  for _, ent in ipairs(vehicleEntities) do
    local ok, err = pcall(function()
      spawnEffectAt(ent)
      explodeVehicle(ent)
    end)

    if not ok then
      log("applyToNearbyVehicles failed for entity: " .. tostring(err))
    end
  end
end

local function applyToNearbyDevices(deviceMatches)
  for _, match in ipairs(deviceMatches) do
    local ok, err = pcall(function()
      spawnEffectAt(match.entity)

      local actionOk, actionErr = pcall(match.action, match.entity)
      if not actionOk then
        log("applyToNearbyDevices action failed: " .. tostring(actionErr))
      end
    end)

    if not ok then
      log("applyToNearbyDevices failed for entity: " .. tostring(err))
    end
  end
end

-- Blow shit up logic start point - at some point resolve entity list with the quickhackable TSQ filter
local function pulseNearbyDevicesAndVehicles()
  local player = Game.GetPlayer()
  if not player then return end

  local playerPos = player:GetWorldPosition()
  local queryRadius = math.max(RADIUS, VEHICLE_RADIUS)
  local entities = queryNearbyEntities(player, queryRadius, true)
  local deviceMatches, vehicleEntities = classifyNearbyEntities(entities, playerPos)

  applyToNearbyDevices(deviceMatches)
  applyToNearbyVehicles(vehicleEntities)
end

local function playSound(entity, soundName)
  if not entity or not isDefined(entity) then
    log("playSound failed: invalid entity")
    return false
  end

  if not soundName then
    log("playSound failed: missing sound name")
    return false
  end

  local ok, err = pcall(function()
    local soundEvent = SoundPlayEvent.new()
    soundEvent.soundName = CName.new(soundName)
    entity:QueueEvent(soundEvent)
  end)

  if not ok then
    log("playSound failed for " .. tostring(soundName) .. ": " .. tostring(err))
    return false
  end

  log("played sound " .. tostring(soundName))
  return true
end

local TIME_KEY = "BlackwallHackFX_Time"

local function getTimeKey()
  return TIME_KEY
end

local function slowTime(scale)
  local ts = Game.GetTimeSystem()
  if not ts then
    log("slowTime failed: TimeSystem unavailable")
    return
  end

  local timeKey = getTimeKey()
  if not timeKey then log("Failed to get time key") return end

  local timeScale = scale or 0.35
  local ok, err = pcall(function()
    ---@diagnostic disable-next-line: missing-parameter
    return ts:SetTimeDilation(timeKey, timeScale)
  end)

  if ok then
    log("slowTime applied scale=" .. tostring(timeScale))
  else
    log("slowTime failed: " .. tostring(err))
  end
end

local function restoreTime()
  local ts = Game.GetTimeSystem()
  if not ts then
    log("restoreTime failed: TimeSystem unavailable")
    return
  end

  local timeKey = getTimeKey()
  if not timeKey then log("Failed to get time key") return end

  local ok, err = pcall(function()
    ---@diagnostic disable-next-line: missing-parameter
    return ts:UnsetTimeDilation(timeKey)
  end)

  if ok then
    log("restoreTime cleared")
  else
    log("restoreTime failed: " .. tostring(err))
  end
end

-- Make mech hostile towards nearby EnemyNPCs (TSQ), not just tracked combat threats.
---@param puppet ScriptedPuppet
---@param player PlayerPuppet
local function setPuppetHostileTowardsPlayerHostiles(puppet, player, range)
  if not isDefined(puppet) or not isDefined(player) then return 0 end

  local puppetAttitude = puppet:GetAttitudeAgent()
  if not puppetAttitude then return 0 end

  local marked = {}
  local count = 0
  local firstHostile = nil
  local function markHostile(ent)
    if not isDefined(ent) or ent == player or ent == puppet then return end
    if not ent:IsA("ScriptedPuppet") then return end
    if not isTurretTargetStillValid(ent) then return end
    local key = tostring(ent:GetEntityID().hash)
    if marked[key] then return end

    local targetAttitude = ent:GetAttitudeAgent()
    if not targetAttitude then return end

    puppetAttitude:SetAttitudeTowardsAgentGroup(
      targetAttitude, puppetAttitude, EAIAttitude.AIA_Hostile)
    puppetAttitude:SetAttitudeTowards(targetAttitude, EAIAttitude.AIA_Hostile)

    marked[key] = true
    count = count + 1
    if not firstHostile then
      firstHostile = ent
    end
  end

  local scanRange = range or RADIUS
  local enemies = queryEnemyNPCsNear(puppet, scanRange)
  if #enemies == 0 then
    enemies = queryEnemyNPCsNear(player, scanRange)
  end
  for _, ent in ipairs(enemies) do
    markHostile(ent)
  end

  -- Kick combat AI so it doesn't wait for senses to catch up.
  if firstHostile and puppet.reactionComponent then
    puppet.reactionComponent:TriggerCombat(firstHostile)
  end

  log("mech hostile towards " .. tostring(count) .. " EnemyNPCs (TSQ)")
  return count
end

---@param npc ScriptedPuppet
local function aggroORctrlNPC(npc, nwDebug)
  debug = nwDebug or false
  local player = Game.GetPlayer()
  if not isDefined(player) or not isDefined(npc) then return false end
  if not npc:IsA("ScriptedPuppet") then return false end
  if ScriptedPuppet.IsDefeated(npc) or ScriptedPuppet.IsUnconscious(npc) then
    log("NPC is defeated or unconscious")
    log(tostring(npc:GetNPCType()))
    return false
  end

  local npcType = npc:GetNPCType()
  local isMechLike = npcType == gamedataNPCType.Mech
    or npcType == gamedataNPCType.Drone
    or npcType == gamedataNPCType.Android
    or npc:IsMechanical()

  -- this exclusion may not do anything, test at some point
  if not isMechLike then
    local aiController = npc:GetAIControllerComponent()
    if aiController then
      aiController:SetAIRole(AIRole.new())
      aiController:OnAttach()
    end
  end

  local npcAttitude = npc:GetAttitudeAgent()
  local playerAttitude = player:GetAttitudeAgent()
  if not (npcAttitude and playerAttitude) then return false end

  local playerAttitudeGroup = playerAttitude:GetAttitudeGroup()

  if debug then
    log("Setting attitude")
    log("NPC is of type: " .. Game.NameToString(npc:GetClassName()))
    log(tostring(npcType))
  end

  if isMechLike then
    npcAttitude:SetAttitudeTowards(playerAttitude, EAIAttitude.AIA_Friendly)
    npcAttitude:SetAttitudeGroup(playerAttitudeGroup)
    -- Turret equivalent of SetHostileTowardsPlayerHostiles + ReevaluateTargets.
    setPuppetHostileTowardsPlayerHostiles(npc, player, RADIUS)
    return true
  end

  if npcAttitude:GetAttitudeTowards(playerAttitude) == EAIAttitude.AIA_Friendly then
    return false
  end

  npcAttitude:SetAttitudeGroup("Hostile")
  npcAttitude:SetAttitudeTowards(playerAttitude, EAIAttitude.AIA_Hostile)

  if npc.reactionComponent then
    npc.reactionComponent:TriggerCombat(player)
  end

  return true
end

local function knockDown()
  if not KNOCKDOWN_ENABLED then return end
  local player = Game.GetPlayer()
  if not isDefined(player) then return end
  StatusEffectHelper.ApplyStatusEffect(player, "BaseStatusEffect.VehicleKnockdown", 0.0)
end

local function aggravateNearbyEnemies(range, nwDebug)
  debug = nwDebug or false
  local player = Game.GetPlayer()
  if not isDefined(player) then return 0 end

  local radius = range or RADIUS
  local entities = queryNearbyEntities(player, radius, false, true)
  local count = 0
  local mechSeen = 0

  log("aggravateNearbyEnemies: scanned " .. tostring(#entities) .. " entities (radius=" .. tostring(radius) .. ")")

  for _, ent in ipairs(entities) do
    if ent:IsA("ScriptedPuppet") then
      local npcType = ent:GetNPCType()
      log("aggravate candidate: " .. Game.NameToString(ent:GetClassName())
        .. " npcType=" .. tostring(npcType))
      if npcType == gamedataNPCType.Mech then
        mechSeen = mechSeen + 1
      end

      if aggroORctrlNPC(ent, debug) then
        count = count + 1
      end
    end
  end

  log("aggravated nearby scripted puppets: " .. tostring(count)
    .. " (mechs seen in scan: " .. tostring(mechSeen) .. ")")
  return count
end

local function playerWorldTransform(player)
  local transform = WorldTransform.new()
  transform:SetOrientation(player:GetWorldOrientation())
  transform:SetPosition(player:GetWorldPosition())
  return transform
end

local function stopAllPlayerFxFollow()
  followingPlayerFx = {}
  if playerFxFollowTimer then
    Cron.Halt(playerFxFollowTimer)
    playerFxFollowTimer = nil
  end
end

local function releaseFollowingPlayerFx(fx)
  for i, tracked in ipairs(followingPlayerFx) do
    if tracked == fx then
      table.remove(followingPlayerFx, i)
      return
    end
  end
end

local function startPlayerFxFollow()
  if playerFxFollowTimer then return end

  playerFxFollowTimer = Cron.Every(0.0, function()
    local player = Game.GetPlayer()
    if not player then return end

    local transform = playerWorldTransform(player)
    local i = 1

    while i <= #followingPlayerFx do
      local fx = followingPlayerFx[i]
      if not IsDefined(fx) or not fx:IsValid() then
        table.remove(followingPlayerFx, i)
      else
        fx:UpdateTransform(transform)
        i = i + 1
      end
    end

    if #followingPlayerFx == 0 then
      Cron.Halt(playerFxFollowTimer)
      playerFxFollowTimer = nil
    end
  end, true)
end

local function trackFollowingPlayerFx(fx)
  if not IsDefined(fx) then return end
  table.insert(followingPlayerFx, fx)
  startPlayerFxFollow()
end

local function breakPlayerFx(fx)
  releaseFollowingPlayerFx(fx)
  if IsDefined(fx) then
    fx:BreakLoop()
  end
end

local function playPlayerFx(name, followPlayer)
  if followPlayer == nil then
    followPlayer = true
  end

  local player = Game.GetPlayer()
  if not player then return end

  local fxSystem = Game.GetFxSystem()
  if not fxSystem then
    log("FxSystem unavailable")
    return
  end

  local fxParticle = gameFxResource.new({ effect = name })
  local fx = fxSystem:SpawnEffect(fxParticle, playerWorldTransform(player), true)
  table.insert(activeFx, fx)

  if followPlayer then
    trackFollowingPlayerFx(fx)
  end

  return fx
end

local function spawnPlayerFX()
  local player = Game.GetPlayer()
  if not player then return end

  playSound(player, "vfx_blackwall_start_first")

  local wasAlreadyUsingCarryWrapper = StatusEffectSystem.ObjectHasStatusEffect(
  player,
    "GameplayRestriction.BodyCarryingWoundedSoldier"
  )

  if not wasAlreadyUsingCarryWrapper then
    Game.SetAnimWrapperWeight(player, "carry_woundedSoldier", 1.0)
    carryingWoundedF = true
  end

  local introFx = playPlayerFx(INTRO_EFFECT)

  playPlayerFx(USE_FORCE, false)
  GameInstance.GetAudioSystem():Play("blackwall_deck_voiceover_".. math.random(1, 2), player:GetEntityID(), "Blackwall")
  

  Cron.After(2.5, function()
    if not overdriveOccuring then return end

    if IsDefined(introFx) then
      breakPlayerFx(introFx)
    end

    playSound(player, "scene_lowpass_state_set_on")
    playSound(player, "q303_blackwall_amb")

    BlackwallUpload.Execute()
    Cron.After(1.0, function()
      if not overdriveOccuring then return end
      pulseNearbyDevicesAndVehicles()
    end, true)
    aggravateNearbyEnemies(RADIUS * 0.8)
    Cron.After(0.5, function()
      if not overdriveOccuring then return end

      aggravateNearbyEnemies(RADIUS * 0.8)
    end, true)

    playPlayerFx(FORCE_SCREEN)

    if soundLoopTimer then
      Cron.Halt(soundLoopTimer)
    end
    soundLoopTimer = Cron.Every(3.0, function()
      if not overdriveOccuring then
        if soundLoopTimer then
          Cron.Halt(soundLoopTimer)
          soundLoopTimer = nil
        end
        return
      end

      playPlayerFx(USE_FORCE, false)
    end, true)
  end, true)
end 

local function triggerBlackwallOverdrive()
  overdriveOccuring = true
  Cron.After(2.5, function()
    slowTime(TIME_SCALE)
  end, true)
  spawnPlayerFX()
end 

local function endBlackwallOverdrive()
  overdriveOccuring = false
  local currentPlayer = Game.GetPlayer()
  playSound(currentPlayer, "scene_lowpass_state_set_off")
  playSound(currentPlayer, "q303_blackwall_amb_stop")
  restoreTime()
  if soundLoopTimer then
    Cron.Halt(soundLoopTimer)
    soundLoopTimer = nil
  end
  for _, fx in ipairs(activeFx) do
    breakPlayerFx(fx)
  end
  stopAllPlayerFxFollow()
  playPlayerFx(EFFECT_OUTRO_VIS, false)
  playPlayerFx(EFFECT_OUTRO_SOUND, false)
  knockDown()
  activeFx = {}
  scheduleBlackwallEntityDespawn(BLACKWALL_ENTITY_DESPAWN and BLACKWALL_ENTITY_DESPAWN_TIME or 0.0)
  if carryingWoundedF then
    if isDefined(currentPlayer) then
      Game.SetAnimWrapperWeight(currentPlayer, "carry_woundedSoldier", 0.0)
    end
    carryingWoundedF = false
  end
end

registerHotkey(
    "blackwall_fx_debug_trigger",
    "Blackwall FX: Debug Trigger",
    triggerBlackwallOverdrive
)

registerHotkey(
    "blackwall_fx_debug_end",
    "Blackwall FX: End Debug Effects",
    endBlackwallOverdrive
)

registerHotkey("baseeffectdebugging", "Base Effect Debugging", function()
  log("Trying to play deck voiceover")
  local player = Game.GetPlayer()
  if not isDefined(player) then return end
  local audioSystem = GameInstance.GetAudioSystem()
  if not audioSystem then return end
  log("AudioSystem found")
  audioSystem:Play(CName.new("blackwall_deck_voiceover"), player:GetEntityID(), CName.new("Blackwall"))
end)

local function checkSongsDeckEquipped()
  cyberwareex_enabled = false
  local equippedCW = {}
  local equipped = false
  log("Checking if Songs Deck is equipped")
  local player = Game.GetPlayer()
  if not player then log("Player not found") return false end
  log("Player found")
  local equippedCW0 = player:GetEquipmentSystem():GetItemInEquipSlot(player, gamedataEquipmentArea.SystemReplacementCW, 0)
  equippedCW[1] = equippedCW0
  if CYBERWAREEX_COMPATIBILITY then
  local equippedCW1 = player:GetEquipmentSystem():GetItemInEquipSlot(player, gamedataEquipmentArea.SystemReplacementCW, 1)
    equippedCW[2] = equippedCW1
    local equippedCW2 = player:GetEquipmentSystem():GetItemInEquipSlot(player, gamedataEquipmentArea.SystemReplacementCW, 2)
    equippedCW[3] = equippedCW2
  end
  log("Didn't crash from cyberware checks! ===============================================================================")
  if not equippedCW[1] and not equippedCW[2] and not equippedCW[3] then log("No equipped Cyberware") return false end
  if not equippedCW[1] then log("No equipped Cyberware in slot 0") end
  if not equippedCW[2] then log("No equipped Cyberware in slot 1") end
  if not equippedCW[3] then log("No equipped Cyberware in slot 2") end
  log("Equipped Cyberware found")
  for i, equippedCW in ipairs(equippedCW) do
    local cwRecord = TweakDB:GetRecord(equippedCW:GetTDBID()) 
    if not cwRecord then log("Cyberware record not found") else
      log("Checking Cyberware slot #" .. tostring(i))
      for _, tag in ipairs(cwRecord:Tags()) do
        log("Tag: " .. Game.NameToString(tag))
        local normalizedTag = Game.NameToString(tag)
        if normalizedTag == "Sandevistan" or normalizedTag == "Berserk" then
          cyberwareex_enabled = true
        end
        if normalizedTag == "BlackwallInterface" then
          equipped = true
        end
      end
    end
  end
  log("cwex enabled: " .. tostring(cyberwareex_enabled) .. "songsdeck equipped: " .. tostring(equipped))
  return equipped
end

local function checkSecurityArea()
  local player = Game.GetPlayer()
  local secArea = player.securityAreaTypeE3HACK
  if secArea then
    if secArea == ESecurityAreaType.SAFE then log("Safe area") return false end
    if secArea == ESecurityAreaType.DISABLED then log("Disabled area") return true end
    if secArea == ESecurityAreaType.RESTRICTED then log("Restricted area") return true end
    if secArea == ESecurityAreaType.DANGEROUS then log("Dangerous area") return true end
  else
    log("No sec area")
    return false
  end
end

registerHotkey("check_songs_deck_equipped", "Check Songs Deck Equipped", checkSongsDeckEquipped)

---@type redEvent
local show_event = nil
---@type redEvent
local hide_event = nil

---@type redEvent
local show_ch_event = nil
---@type redEvent
local hide_ch_event = nil

---@type redEvent
local show_scr_event = nil
---@type redEvent
local hide_scr_event = nil

local hintfallback = false

local function hideExistingHintWidgets()
  local layer = Game.GetInkSystem():GetLayer(CName.new("inkHUDLayer"))
  if not layer then return end
  for _, controller in ipairs(layer:GetGameControllers()) do
      if controller and controller:ToString() == "gameuiInputHintManagerGameController" then
          local hints = controller:GetRootCompoundWidget()
              :GetWidget("mainContainer")
              :GetWidget("hints")
          if not hints then return end
          for i = 0, 5 do
              local widget = hints:GetWidget(i)
              if widget == nil then break end
              local widgetText = widget:GetWidget("hint"):GetWidget("wrapper"):GetWidget("label"):GetText()
              if widgetText ~= "Unleash the Blackwall" or widgetText ~= "Dismiss Enemies" then
                widget:SetVisible(false)
                log("Hiding widget: " .. widgetText)
              end
          end
          return
      end
  end
end

local function showExistingHintWidgets()
  local layer = Game.GetInkSystem():GetLayer(CName.new("inkHUDLayer"))
  if not layer then return end
  for _, controller in ipairs(layer:GetGameControllers()) do
      if controller and controller:ToString() == "gameuiInputHintManagerGameController" then
          local hints = controller:GetRootCompoundWidget()
              :GetWidget("mainContainer")
              :GetWidget("hints")
          if not hints then return end

          for i = 0, 6 do
              local widget = hints:GetWidget(i)
              if widget == nil then break end
              widget:SetVisible(true)
          end
          hintfallback = false
          return
      end
  end
end

registerHotkey("show_existing_hint_widgets", "Show Existing Hint Widgets", showExistingHintWidgets)
registerHotkey("hide_existing_hint_widgets", "Hide Existing Hint Widgets", hideExistingHintWidgets)
local function buildEvents()
    show_event = UpdateInputHintMultipleEvent.new()
    hide_event = UpdateInputHintMultipleEvent.new()
    show_event.targetHintContainer = CName.new("GameplayInputHelper")
    hide_event.targetHintContainer = CName.new("GameplayInputHelper")
    local hint = InputHintData.new()
    hint.source = CName.new("SongsDeck_LeftClick")
    hint.action = CName.new("RangedAttack")
    hint.localizedLabel = "Unleash the Blackwall"
    hint.holdIndicationType = inkInputHintHoldIndicationType.Press
    hint.enableHoldAnimation = false
    hint.sortingPriority = 100
    local hint2 = InputHintData.new()
    hint2.source = CName.new("SongsDeck_RightClick")
    hint2.action = CName.new("MeleeAttack")
    hint2.localizedLabel = "Dismiss Enemies"
    hint2.holdIndicationType = inkInputHintHoldIndicationType.Press
    hint2.enableHoldAnimation = false
    hint2.sortingPriority = 99
    show_event:AddInputHint(hint, true)
    show_event:AddInputHint(hint2, true)
    hide_event:AddInputHint(hint, false)
    hide_event:AddInputHint(hint2, false)
end

local function buildCHEvents()
  show_ch_event = UpdateInputHintMultipleEvent.new()
  hide_ch_event = UpdateInputHintMultipleEvent.new()
  show_ch_event.targetHintContainer = CName.new("GameplayInputHelper")
  hide_ch_event.targetHintContainer = CName.new("GameplayInputHelper")
  local hint = InputHintData.new()
  hint.source = CName.new("SongsDeck_CameraControlRelease")
  hint.action = CName.new("StopDeviceControl")
  hint.localizedLabel = "Release Camera Control"
  hint.holdIndicationType = inkInputHintHoldIndicationType.Press
  hint.enableHoldAnimation = false
  hint.sortingPriority = 100
  show_ch_event:AddInputHint(hint, true)
  hide_ch_event:AddInputHint(hint, false)
end

local hideHintTimer = nil

local function showCHHint()
  if not show_ch_event then buildCHEvents() end
  Game.GetUISystem():QueueEvent(show_ch_event)
end

local function hideCHHint()
  if not hide_ch_event then buildCHEvents() end
  Game.GetUISystem():QueueEvent(hide_ch_event)
end

local function showRLHint()
    if not show_event then buildEvents() end
    Game.GetUISystem():QueueEvent(show_event)
    hideExistingHintWidgets()
    hideHintTimer = Cron.Every(2.0, function()
      hideExistingHintWidgets()
    end, true)
end
local function hideRLHint()
    if hide_event then
        Game.GetUISystem():QueueEvent(hide_event)
    end
    Cron.Halt(hideHintTimer)
    hideHintTimer = nil
    showExistingHintWidgets()
end

local function triggerBlackwallSideEffectsHeavy()
  local player = Game.GetPlayer()
  if not player then return end

  local ok, err = pcall(function()
    local system = Game.GetScriptableSystemsContainer():Get(CName.new("HauntedGunVFXSystem"))
    if not system then
      print("[" .. MOD_NAME .. "] HauntedGunVFXSystem not found — is BlackwallSideEffects installed?")
      return
    end
    system:StartBlackwallEffect(player, 10)
  end)

  if not ok then
    log("BlackwallSideEffects trigger failed: " .. tostring(err))
  end
end

local function getPlayerPools()
  local player = Game.GetPlayer()
  if not player then return nil end
  --log("Player found")
  local sps = Game.GetStatPoolsSystem()
  if not sps then return nil end
  --log("StatPoolsSystem found")
  local ownerID = player:GetEntityID()
  --log("OwnerID found")
  return player, sps, ownerID
end

local function getRAM(sps, owner)
  return sps:GetStatPoolValue(owner, gamedataStatPoolType.Memory)
end

local function getHealth(sps, owner)
  return sps:GetStatPoolValue(owner, gamedataStatPoolType.Health)
end

local function changeRAM(sps, owner, player, delta)
  sps:RequestChangingStatPoolValue(owner, gamedataStatPoolType.Memory, delta, player, false)
end

local function setRAMEmpty(sps, owner, player)
  local value = -getRAM(sps, owner)
  sps:RequestChangingStatPoolValue(owner, gamedataStatPoolType.Memory, value, player, false)
end

local function changeHealth(sps, owner, player, delta)
  sps:RequestChangingStatPoolValue(owner, gamedataStatPoolType.Health, delta, player, false)
end

local function stopDrain()
  if drainTimer then
    Cron.Halt(drainTimer)
    drainTimer = nil
  end
end

local lowHealthFX = nil
local ramDrainedFully = false
local isPerPulseDrainOccuring = false
local function startDrain()
  stopDrain()

  drainTimer = Cron.Every(RAM_DRAIN_INTERVAL, function()
    if isPerPulseDrainOccuring then
      return
    end
    if not overdriveOccuring then
      stopDrain()
      return
    end
    local player, sps, ownerID = getPlayerPools()
    if not player or not sps or not ownerID then return end
    local ram = getRAM(sps, ownerID)
    local health = getHealth(sps, ownerID)
    if ramDrainedFully then
      setRAMEmpty(sps, ownerID, player)
    end
    if ram > 0 and ramDrainedFully == false then
      local drain = math.min(RAM_DRAIN_PER_TICK, ram)
      changeRAM(sps, ownerID, player, -drain)
      if ram - drain <= 0 and ramDrainedFully == false then
        lowHealthFX = playPlayerFx(INTRO_EFFECT)
        ramDrainedFully = true
      end
    else
      local hpCost = RAM_DRAIN_PER_TICK * HP_PER_RAM_UNIT
      local newHP = math.max(health - hpCost, MIN_HEALTH_FLOOR)
      if newHP <= MIN_HEALTH_FLOOR then
        if lowHealthFX then
          breakPlayerFx(lowHealthFX)
          lowHealthFX = nil
        end
        ramDrainedFully = false
        stopDrain()
        endBlackwallOverdrive()
        setAbilityBlackwallDownlinkInactive()
        hideRLHint()
        triggerBlackwallSideEffectsHeavy()
        return
      end
      changeHealth(sps, ownerID, player, -hpCost)
    end

  end, true)
end

local function perPulseDrain()
  if not PER_PULSE_DRAIN then return end
  isPerPulseDrainOccuring = true
  local player, sps, ownerID = getPlayerPools()
  if not player or not sps or not ownerID then return end
  local ram = getRAM(sps, ownerID)
  local health = getHealth(sps, ownerID)
  if ram > 0 and ramDrainedFully == false then
    local drain = math.min(PER_PULSE_RAM_DRAIN_AMOUNT, ram)
    changeRAM(sps, ownerID, player, -drain)
    if ram - drain <= 0 and ramDrainedFully == false then
      lowHealthFX = playPlayerFx(INTRO_EFFECT)
      ramDrainedFully = true
    end
  else
    local hpCost = PER_PULSE_RAM_DRAIN_AMOUNT * HP_PER_RAM_UNIT
    local newHP = math.max(health - hpCost, MIN_HEALTH_FLOOR)
    if newHP <= MIN_HEALTH_FLOOR then
      if lowHealthFX then
        breakPlayerFx(lowHealthFX)
        lowHealthFX = nil
      end
      ramDrainedFully = false
      stopDrain()
      endBlackwallOverdrive()
      setAbilityBlackwallDownlinkInactive()
      hideRLHint()
      triggerBlackwallSideEffectsHeavy()
      return
    end
    changeHealth(sps, ownerID, player, -hpCost)
  end
  isPerPulseDrainOccuring = false
end

local inCameraPS = nil 
---@param lookAtObject SurveillanceCamera
local function blackwallHackCamera(lookAtObject)
  if not lookAtObject then return end
  log("attempting to get hack action")
  playPlayerFx(FORCE_SCREEN, false)
  local action = lookAtObject:GetDevicePS():ActionQuestForceTakeControlOverCameraWithChain()
  if not action then log("failed to get action") return end
  inCameraPS = lookAtObject:GetDevicePS()
  ---@diagnostic disable-next-line: missing-parameter
  inCameraPS:ExecutePSAction(action)
  spawnEffectAt(lookAtObject)
  Cron.After(2.0, function()
    showCHHint()
  end, true)
end

registerHotkey("blackwallHackCamera", "Blackwall Hack Camera", function() 
  ---@diagnostic disable-next-line: param-type-mismatch
  blackwallHackCamera(getLookAtObject()) 

  end)

registerHotkey("actionLog", "Action log toggle", function()
  actionLog = not actionLog
end)

---@param lookAtObject Door
---@param player PlayerPuppet
local function openOrCloseDoorHack(lookAtObject, player)
  local doorPS = lookAtObject:GetDevicePS()
  if not doorPS then return end
  if doorPS:IsOpen() then 
    local action = doorPS:ActionSetClosed()
    if action then
      ---@diagnostic disable-next-line: missing-parameter
      doorPS:ExecutePSAction(action)
    end
  else
    doorPS:ExecuteForceOpen(player)
  end
  if not overdriveOccuring then
    spawnEffectAt(lookAtObject)
  end
  log("force opened door: " .. tostring(lookAtObject:GetName()))
end

-- Keyed by the actionName set in songsdeck_devicehacks.yaml
local DECK_DEVICE_HACKS = {
  SongsDeckDoorHack = {
    class = "Door",
    altClass = "",
    run = function(target, player) openOrCloseDoorHack(target, player) end,
  },
  SongsDeckCameraHack = {
    class = "SurveillanceCamera",
    altClass = "SecurityTurret",
    run = function(target) blackwallHackCamera(target) end,
  },
}

---@param data QuickhackData
---@param target GameObject
local function runDeckDeviceHack(data, target)
  local action = data.action
  if not action then return false end
  local record = action:GetObjectActionRecord()
  if not record then return false end
  local handler = DECK_DEVICE_HACKS[Game.NameToString(record:ActionName())]
  if not handler then return false end
  if not target:IsA(handler.class) and not (handler.altClass ~= "" and target:IsA(handler.altClass)) then
    log("deck device hack target was " .. tostring(target:GetClassName()) .. ", expected " .. handler.class)
    return false
  end
  log("running deck device hack on " .. tostring(target:GetClassName()))
  handler.run(target, Game.GetPlayer())
  return true
end

---@diagnostic disable-next-line: redundant-parameter
registerForEvent("onUpdate", function(delta)
  Cron.Update(delta)
end)

local nativeSettings = nil
local settingsWidgets = {}
-- Defaults (what "Restore Defaults" should reset to)
local defaults = {
  debug = false,
  radius = 50,
  ramDrainPerTick = 0.2,
  hpPerRamUnit = 10.0,
  gameplayMechanicsEnabled = true,
  vehicleOn = true,
  vehicleRadius = 50,
  perPulseDrain = false,
  perPulseDrainAmount = 2.0,
  knockdownEnabled = true,
  cyberwareexCompatibility = false,
  holdTabToTrigger = false,
  darkFutureEnabled = false,
  timeScale = 0.35,
  blackwallEntityDespawn = true,
  blackwallEntityDespawnTime = 30.0,
  revengeType = 2,
}
local settings = {
  debug = defaults.debug,
  radius = defaults.radius,
  ramDrainPerTick = defaults.ramDrainPerTick,
  hpPerRamUnit = defaults.hpPerRamUnit,
  gameplayMechanicsEnabled = defaults.gameplayMechanicsEnabled,
  vehicleOn = defaults.vehicleOn,
  vehicleRadius = defaults.vehicleRadius,
  perPulseDrain = defaults.perPulseDrain,
  perPulseDrainAmount = defaults.perPulseDrainAmount,
  knockdownEnabled = defaults.knockdownEnabled,
  cyberwareexCompatibility = defaults.cyberwareexCompatibility,
  holdTabToTrigger = defaults.holdTabToTrigger,
  darkFutureEnabled = defaults.darkFutureEnabled,
  timeScale = defaults.timeScale,
  blackwallEntityDespawn = defaults.blackwallEntityDespawn,
  blackwallEntityDespawnTime = defaults.blackwallEntityDespawnTime,
  revengeType = defaults.revengeType,
}

local configPath = "config.json"
local function saveSettings()
  ---@diagnostic disable-next-line: undefined-global
  local ok, encoded = pcall(json.encode, settings)
  if not ok then
    print("[" .. MOD_NAME .. "] json.encode failed: " .. tostring(encoded))
    return
  end
  local f, err = io.open(configPath, "w")
  if not f then
    print("[" .. MOD_NAME .. "] io.open failed: " .. tostring(err))
    return
  end
  f:write(encoded)
  f:close()
  print("[" .. MOD_NAME .. "] saved " .. configPath)
end
local function loadSettings()
  local f = io.open(configPath, "r")
  if not f then return end
  ---@diagnostic disable-next-line: undefined-global
  local data = json.decode(f:read("*a"))
  f:close()
  if data then
    for k, v in pairs(data) do
      if settings[k] ~= nil then settings[k] = v end
    end
  end
end

local function applySettings()
  DEBUG = settings.debug
  RADIUS = settings.radius
  RAM_DRAIN_PER_TICK = settings.ramDrainPerTick
  HP_PER_RAM_UNIT = settings.hpPerRamUnit
  GAMEPLAY_MECHANICS_ENABLED = settings.gameplayMechanicsEnabled
  VEHICLE_ON = settings.vehicleOn
  VEHICLE_RADIUS = settings.vehicleRadius
  PER_PULSE_DRAIN = settings.perPulseDrain
  PER_PULSE_RAM_DRAIN_AMOUNT = settings.perPulseDrainAmount
  KNOCKDOWN_ENABLED = settings.knockdownEnabled
  CYBERWAREEX_COMPATIBILITY = settings.cyberwareexCompatibility
  HOLD_TAB_TO_TRIGGER = settings.holdTabToTrigger
  DARK_FUTURE_ENABLED = settings.darkFutureEnabled
  TIME_SCALE = settings.timeScale
  BLACKWALL_ENTITY_DESPAWN = settings.blackwallEntityDespawn
  BLACKWALL_ENTITY_DESPAWN_TIME = settings.blackwallEntityDespawnTime
  REVENGE_TYPE = settings.revengeType
end
local function setupNativeSettings()
  nativeSettings = GetMod("nativeSettings")
  if not nativeSettings then
    print("[" .. MOD_NAME .. "] Native Settings UI not found — skipping settings page")
    return
  end

local revengeTypeOptions = {[1] = "Never", [2] = "Always", [3] = "During Downlink"}

  -- Tab path must start with /
  nativeSettings.addTab("/songsdeck", MOD_NAME)
  nativeSettings.addSubcategory("/songsdeck/general", "Visuals")
  nativeSettings.addSubcategory("/songsdeck/gameplay", "Gameplay")
  nativeSettings.addSubcategory("/songsdeck/vehicle", "Vehicle")
  nativeSettings.addSubcategory("/songsdeck/perPulseDrain", "Per Pulse Drain")
  nativeSettings.addSubcategory("/songsdeck/cyberwareex", "CyberwareEX")
  nativeSettings.addSubcategory("/songsdeck/darkFuture", "Dark Future")
  nativeSettings.addSubcategory("/songsdeck/debug", "Debug")
  settingsWidgets.revengeType = nativeSettings.addSelectorString(
    "/songsdeck/gameplay",
    "Revenge Type",
    "When the Blackwall will retaliate against (fry) enemy netrunners and their proxies.",
    revengeTypeOptions,
    settings.revengeType,
    defaults.revengeType,
    function(value)
      settings.revengeType = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.blackwallEntityDespawn = nativeSettings.addSwitch(
    "/songsdeck/general",
    "Blackwall Entity Despawn",
    "Despawn blackwall entities after a delay. This will prevent the blackwall entities from staying on the map forever.",
    settings.blackwallEntityDespawn,
    defaults.blackwallEntityDespawn,
    function(value)
      settings.blackwallEntityDespawn = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.blackwallEntityDespawnTime = nativeSettings.addRangeFloat(
    "/songsdeck/general",
    "Blackwall Entity Despawn Time",
    "The time in seconds after which the blackwall entities will be despawned.",
    0.0, 100.0, 1.0, "%.0f",
    settings.blackwallEntityDespawnTime,
    defaults.blackwallEntityDespawnTime,
    function(value)
      settings.blackwallEntityDespawnTime = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.debug = nativeSettings.addSwitch(
    "/songsdeck/debug",
    "Debug logging",
    "Print debug messages to CET console. Fair warning, my logging is terrible.",
    settings.debug,
    defaults.debug,
    function(value)
      settings.debug = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.darkFutureEnabled = nativeSettings.addSwitch(
    "/songsdeck/darkFuture",
    "Dark Future Integration [IN DEVELOPMENT]",
    "Enable Dark Future integration. This will integrate with Dark Future energy and nerve systems. In development. Not functional yet.",
    settings.darkFutureEnabled,
    defaults.darkFutureEnabled,
    function(value)
      settings.darkFutureEnabled = value
      applySettings() 
      saveSettings()
    end
  )
  settingsWidgets.cyberwareexCompatibility = nativeSettings.addSwitch(
    "/songsdeck/cyberwareex",
    "CyberwareEX compatibility",
    "Enable CyberwareEX compatibility. Allows for scanning + E to activate Blackwall Downlink. Don't turn this on if you don't need it.",
    settings.cyberwareexCompatibility,
    defaults.cyberwareexCompatibility,
    function(value)
      settings.cyberwareexCompatibility = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.holdTabToTrigger = nativeSettings.addSwitch(
    "/songsdeck/gameplay",
    "Hold Scan to Trigger",
    "Hold Scan to Trigger Blackwall Downlink.",
    settings.holdTabToTrigger,
    defaults.holdTabToTrigger,
    function(value)
      settings.holdTabToTrigger = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.timeScale = nativeSettings.addRangeFloat(
    "/songsdeck/gameplay",
    "Time scale",
    "Time scale for Blackwall Downlink. Percent slowed is (1 - time scale).",
    0.25, 0.75, 0.01, "%.2f",
    settings.timeScale,
    defaults.timeScale,
    function(value)
      settings.timeScale = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.knockdownEnabled = nativeSettings.addSwitch(
    "/songsdeck/gameplay",
    "Knockdown enabled",
    "Enable knockdown when Blackwall Downlink ends (BOTH MODES).",
    settings.knockdownEnabled,
    defaults.knockdownEnabled,
    function(value)
      settings.knockdownEnabled = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.radius = nativeSettings.addRangeInt(
    "/songsdeck/gameplay",
    "Effect radius",
    "How far nearby targets are affected by blackwall pulse (meters).",
    10, 200, 5,
    settings.radius,
    defaults.radius,
    function(value)
      settings.radius = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.vehicleOn = nativeSettings.addSwitch(
    "/songsdeck/vehicle",
    "Vehicle on",
    "Enable vehicle effects.",
    settings.vehicleOn,
    defaults.vehicleOn,
    function(value)
      if not value then
        nativeSettings.removeOption(settingsWidgets.vehicleRadius)
      else
        settingsWidgets.vehicleRadius = nativeSettings.addRangeInt(
          "/songsdeck/vehicle",
          "Vehicle radius",
          "How far nearby vehicles are affected by blackwall pulse (meters).",
          10, 200, 5,
          settings.vehicleRadius,
          defaults.vehicleRadius,
          function(value)
            settings.vehicleRadius = value
            applySettings()
            saveSettings()
          end
        )
      end
      settings.vehicleOn = value
      applySettings()
      saveSettings()
    end
  )
  if VEHICLE_ON then
    settingsWidgets.vehicleRadius = nativeSettings.addRangeInt(
      "/songsdeck/vehicle",
      "Vehicle radius",
      "How far nearby vehicles are affected by blackwall pulse (meters).",
      10, 200, 5,
      settings.vehicleRadius,
      defaults.vehicleRadius,
      function(value)
        settings.vehicleRadius = value
        applySettings()
        saveSettings()
      end
    )
  end
  if GAMEPLAY_MECHANICS_ENABLED then
    settingsWidgets.ramDrainPerTick = nativeSettings.addRangeFloat(
      "/songsdeck/gameplay",
      "RAM drain per tick",
      "How much RAM is drained per tick.",
      0.1, 1.0, 0.1, "%.1f",
      settings.ramDrainPerTick,
      defaults.ramDrainPerTick,
      function(value)
        settings.ramDrainPerTick = value
        applySettings()
        saveSettings()
      end
    )
    settingsWidgets.hpPerRamUnit = nativeSettings.addRangeFloat(
      "/songsdeck/gameplay",
      "HP per RAM unit",
      "How much HP is drained per RAM unit.",
      1.0, 100.0, 1.0, "%.1f",
      settings.hpPerRamUnit,
      defaults.hpPerRamUnit,
      function(value)
        settings.hpPerRamUnit = value
        applySettings()
        saveSettings()
      end
    )
  end
  settingsWidgets.gameplayMechanicsEnabled = nativeSettings.addSwitch(
    "/songsdeck/gameplay",
    "Gameplay mechanics enabled",
    "Enable gameplay mechanics.",
    settings.gameplayMechanicsEnabled,
    defaults.gameplayMechanicsEnabled,
    function(value)
      if not value then
        nativeSettings.removeOption(settingsWidgets.ramDrainPerTick)
        nativeSettings.removeOption(settingsWidgets.hpPerRamUnit)
      else
        settingsWidgets.ramDrainPerTick = nativeSettings.addRangeFloat(
          "/songsdeck/gameplay",
          "RAM drain per tick",
          "How much RAM is drained per tick.",
          0.1, 1.0, 0.1, "%.1f",
          settings.ramDrainPerTick,
          defaults.ramDrainPerTick,
          function(value)
            settings.ramDrainPerTick = value
            applySettings()
            saveSettings()
          end
        )
        settingsWidgets.hpPerRamUnit = nativeSettings.addRangeFloat(
          "/songsdeck/gameplay",
          "HP per RAM unit",
          "How much HP is drained per RAM unit. Respects gameplay mechanics enabled setting.",
          1.0, 100.0, 1.0, "%.1f",
          settings.hpPerRamUnit,
          defaults.hpPerRamUnit,
          function(value)
            settings.hpPerRamUnit = value
            applySettings()
            saveSettings()
          end
        )
      end
      settings.gameplayMechanicsEnabled = value
      applySettings()
      saveSettings()
    end
  )
  settingsWidgets.perPulseDrain = nativeSettings.addSwitch(
    "/songsdeck/perPulseDrain",
    "Per pulse drain",
    "Enable per pulse drain.",
    settings.perPulseDrain,
    defaults.perPulseDrain,
    function(value)
      if not value then
        nativeSettings.removeOption(settingsWidgets.perPulseDrainAmount)
      else
        settingsWidgets.perPulseDrainAmount = nativeSettings.addRangeFloat(
          "/songsdeck/perPulseDrain",
          "RAM drain per pulse",
          "How much RAM is drained per pulse. Respects gameplay mechanics enabled setting and HP per RAM unit setting.",
          0.1, 10.0, 0.1, "%.1f",
          settings.perPulseDrainAmount,
          defaults.perPulseDrainAmount,
          function(value)
            settings.perPulseDrainAmount = value
            applySettings()
            saveSettings()
          end
        )
      end
      settings.perPulseDrain = value
      applySettings()
      saveSettings()
    end
  )
  if PER_PULSE_DRAIN then
    settingsWidgets.perPulseDrainAmount = nativeSettings.addRangeFloat(
      "/songsdeck/perPulseDrain",
      "RAM drain per pulse",
      "How much RAM is drained per pulse. Respects gameplay mechanics enabled setting and HP per RAM unit setting.",
      0.1, 10.0, 0.1, "%.1f",
      settings.perPulseDrainAmount,
      defaults.perPulseDrainAmount,
      function(value)
        settings.perPulseDrainAmount = value
        applySettings()
        saveSettings()
      end
    )
  end
end

--[[
local function setupDarkFutureIntegration()
  energySystem = Game.GetScriptableSystemsContainer():Get("DFEnergySystem")
  if not energySystem then print("[" .. MOD_NAME .. "] Dark Future system not found — skipping Dark Future integration") return
  else 
    print("[" .. MOD_NAME .. "] Dark Future core system found — setting up Dark Future integration")
  end

  nerveSystem = Game.GetScriptableSystemsContainer():Get("DFNerveSystem")
  if not nerveSystem then print("[" .. MOD_NAME .. "] Dark Future full system not found — skipping full Dark Future integration") return
  else 
    print("[" .. MOD_NAME .. "] Dark Future full system found — setting up full Dark Future integration")
  end
end

local function darkFutureDrain()
  if not DARK_FUTURE_ENABLED then return end
  if not energySystem then setupDarkFutureIntegration() end
  if energySystem then
    energySystem:ChangeNeedValue(-25.0)
  end
  if nerveSystem then
    nerveSystem:ChangeNeedValue(-25.0)
  end
end

local function darkFutureDrainPulse()
  if not DARK_FUTURE_ENABLED then return end
  if not energySystem then setupDarkFutureIntegration() end
  if energySystem then
    energySystem:ChangeNeedValue(-5.0)
  end
  if nerveSystem then
    nerveSystem:ChangeNeedValue(-5.0)
  end
end
]]

local function getActiveNetworkAccessPoint()
  local player = Game.GetPlayer()
  local targetingSystem = Game.GetTargetingSystem()
  if not targetingSystem then return end
  local searchQuery = TSQ_ALL()
  ---@diagnostic disable-next-line: missing-parameter
  searchQuery.searchFilter = TSF_And(
    TSF_Any(gametargetingSystemSearchFilterMaskValue.St_QuickHackable),
    TSF_Any(gametargetingSystemSearchFilterMaskValue.Obj_Sensor),
    TSF_Not(gametargetingSystemSearchFilterMaskValue.St_TurnedOff)
  )
  searchQuery.testedSet = TargetingSet.Complete
  log("Searching for target part")
  local targetPart = targetingSystem:GetObjectClosestToCrosshair(player, searchQuery)
  if not targetPart then return end
  log("Found target part " .. Game.NameToString(targetPart:GetClassName()))
  if not targetPart:IsA("Device") then log("Target part is not a device") return end
  local ps = targetPart:GetDevicePS()
  log(Game.NameToString(ps:GetClassName()))
  if not ps or not ps:IsA("SharedGameplayPS") then return end
  log("Found SharedGameplayPS")
  return ps:GetAccessPoints()[1]
end

local function getDeviceEntityFromPS(devicePS)
  if not devicePS then return nil end

  local ok, entity = pcall(function()
    return devicePS:GetOwnerEntityWeak()
  end)
  if ok and isDefined(entity) then return entity end

  ok, entity = pcall(function()
    local id = PersistentID.ExtractEntityID(devicePS:GetID())
    return Game.FindEntityByID(id)
  end)
  if ok and isDefined(entity) then return entity end

  return nil
end

-- Add stuff to player group make friendly
local function lockSensorsAsAllies(sensors, player)
  player = player or Game.GetPlayer()
  if not isDefined(player) or not sensors or #sensors == 0 then return 0 end

  local playerAgent = player:GetAttitudeAgent()
  if not playerAgent then return 0 end
  local playerGroup = playerAgent:GetAttitudeGroup()

  local count = 0
  for _, sensor in ipairs(sensors) do
    if isDefined(sensor) then
      local agent = sensor:GetAttitudeAgent()
      if agent then
        agent:SetAttitudeGroup(playerGroup)
        agent:SetAttitudeTowards(playerAgent, EAIAttitude.AIA_Friendly)
        count = count + 1
        log("locked sensor ally: " .. Game.NameToString(sensor:GetClassName()))
      end
    end
  end

  return count
end

-- Friendly attitude + turret hijack used by controlNetwork and by camera/turret disconnect.
---@param sensorPS SensorDeviceControllerPS
local function setSensorFriendlyAttitude(sensorPS, entity)
  if not isDefined(sensorPS) then return false end
  entity = entity or getDeviceEntityFromPS(sensorPS)

  local actionOn = sensorPS.ActionSetDeviceON and sensorPS:ActionSetDeviceON()
  local actionAttitude = sensorPS.ActionSetDeviceAttitude and sensorPS:ActionSetDeviceAttitude()
  if actionAttitude then
    actionAttitude.Attitude = EAIAttitude.AIA_Friendly
    actionAttitude.IgnoreHostiles = false
  end
  if actionOn then sensorPS:ExecutePSAction(actionOn) end
  if actionAttitude then sensorPS:ExecutePSAction(actionAttitude) end

  if isDefined(entity) and (entity:IsA("SurveillanceCamera") or entity:IsA("SecurityTurret")) then
    lockSensorsAsAllies({ entity })
  end

  if isDefined(entity) and entity:IsA("SecurityTurret") then
    entity:SetBlackwallDownlinkActive(true)
    if sensorPS.SetIsAttitudeChanged then
      sensorPS:SetIsAttitudeChanged(true)
    end
    if sensorPS.SetBlockSecurityWakeUp then
      sensorPS:SetBlockSecurityWakeUp(true)
    end
    pcall(function() entity:SetHasSupport(false) end)
    local player = Game.GetPlayer()
    if isDefined(player) then
      if entity.LoseTarget then
        pcall(function() entity:LoseTarget(player, true) end)
      end
      pcall(function()
        SenseComponent.RequestPresetChange(entity, TweakDBID.new("Senses.FriendlyTurret"), true)
      end)
      pcall(function()
        local senses = entity:GetSensesComponent()
        if senses then
          senses:SetDetectionOverwrite(player:GetEntityID())
          if senses.ReevaluateDetectionOverwrite then
            senses:ReevaluateDetectionOverwrite(player)
          end
        end
      end)
    end
    armTurretOnEnemyNPCs(entity)
    pcall(function() entity:SongsDeckAcquirePlayerHostiles() end)
    Cron.After(0.5, function()
      if isDefined(entity) then armTurretOnEnemyNPCs(entity) end
    end)
    Cron.After(2.0, function()
      if isDefined(entity) then armTurretOnEnemyNPCs(entity) end
    end)
    log("SecurityTurret hijacked + TSQ EnemyNPC armed")
  end

  return true
end

---@param activeNetworkAccessPoint AccessPointControllerPS
---@param activeNetowrkController AccessPointControllerPS
local function isControlledAlready(activeNetworkAccessPoint, activeNetowrkController)
  if not isDefined(activeNetworkAccessPoint) or not isDefined(activeNetowrkController) then return false end
  return activeNetworkAccessPoint:GetID() == activeNetowrkController:GetID()
end

local function controlNetwork()
  local activeNetworkAccessPoint = getActiveNetworkAccessPoint()
  if isControlledAlready(activeNetworkAccessPoint, activeNetowrkController) then log("Already controlled") return end
  if not activeNetworkAccessPoint then log("No active network access point") return end
  local descendants = activeNetworkAccessPoint:GetAllDescendants()
  log("Got " .. #descendants .. " descendants")

  local friendlySensors = {}
  for _, descendant in ipairs(descendants) do
    if descendant:IsA("SensorDeviceControllerPS") then
      local entity = getDeviceEntityFromPS(descendant)
      if isDefined(entity) then spawnEffectAt(entity) end
      log("Found SensorDeviceControllerPS")
      setSensorFriendlyAttitude(descendant, entity)
      if entity and (entity:IsA("SurveillanceCamera") or entity:IsA("SecurityTurret")) then
        table.insert(friendlySensors, entity)
      end
    end
  end

  -- Backup if ActionSetDeviceAttitude didn't land SetDeviceFriendly.
  lockSensorsAsAllies(friendlySensors)

  -- Refresh EnemyNPC acquisition (new threats / first query empty).
  local function refreshTurretArms()
    for _, sensor in ipairs(friendlySensors) do
      if isDefined(sensor) and sensor:IsA("SecurityTurret") then
        armTurretOnEnemyNPCs(sensor)
      end
    end
  end
  Cron.After(0.5, refreshTurretArms)
  Cron.After(2.0, refreshTurretArms)
  Cron.Every(3.0, function()
    if not activeNetowrkController then return end
    refreshTurretArms()
  end)

  log("Attempting to control robots")
  local puppetDevicePSList = activeNetworkAccessPoint:GetPuppets()
  for _, puppetDevicePS in ipairs(puppetDevicePSList) do
    local puppetEntity = puppetDevicePS:GetOwnerEntityWeak()
    if isDefined(puppetEntity) and puppetEntity:IsA("ScriptedPuppet") then
      local puppetNPCType = puppetEntity:GetNPCType()
      if puppetNPCType == gamedataNPCType.Mech then
        aggroORctrlNPC(puppetEntity, true)
      end
    end
  end
  activeNetowrkController = activeNetworkAccessPoint
end

registerHotkey("NetworkOverrideFullTest", "networkoverridetest", function()
  playPlayerFx(FORCE_SCREEN, true)
  controlNetwork()
end)

registerHotkey("CtrlRobotsTest", "ctrlrobotstest", function()
  local ap = getActiveNetworkAccessPoint()
  if not ap then return end
  local puppetDevicePSList = ap:GetPuppets()
  for _, puppetDevicePS in ipairs(puppetDevicePSList) do
    local puppetEntity = puppetDevicePS:GetOwnerEntityWeak()
    if isDefined(puppetEntity) and puppetEntity:IsA("ScriptedPuppet") then
      local puppetNPCType = puppetEntity:GetNPCType()
      if puppetNPCType == gamedataNPCType.Mech then
        aggroORctrlNPC(puppetEntity, true)
      end
    end
  end
end)

registerHotkey("PlayBlackwallVideoTest", "playblackwallvideotest", function()
  log("Playing Blackwall video test")
  ---@type Device
  local ent = getLookAtObject()
  if not ent or not ent:IsA("TV") then return end
  ---@type TVControllerPS
  local tvController = ent:GetDevicePS()
  if not tvController or not tvController:IsA("TVControllerPS") then return end
  log("Got TV controller" .. Game.NameToString(tvController:GetClassName()))
  log(tvController:GetDefaultGlitchVideoPath():ToString())
  tvController.defaultGlitchVideoPath = redResourceReferenceScriptToken.FromString(BLACKWALL_VIDEO_PATH)
  log(tvController:GetDefaultGlitchVideoPath():ToString())
  ent:StartGlitching(EGlitchState.DEFAULT, 1.0)
  log("Started glitching")
end)

registerHotkey("StopAllRegisteredEffects", "stopallregisteredeffects", function()
  for _, fx in ipairs(activeFx) do
    breakPlayerFx(fx)
  end
  stopAllPlayerFxFollow()
  activeFx = {}
end)

registerHotkey("TSQTEST", "tsqtest", function()
  log("TSQTEST START ==========================================================")
  local targetingSystem = Game.GetTargetingSystem()
  if not targetingSystem then return end
  local player = Game.GetPlayer()

  local searchQuery = TSQ_ALL()
  searchQuery.maxDistance = RADIUS
  searchQuery.testedSet = TargetingSet.Complete
  local success, targetParts = targetingSystem:GetTargetParts(player, searchQuery)
  if not success then return end
  for _, targetPart in ipairs(targetParts) do
    local targetPartENT = targetPart:GetComponent():GetEntity()
    if targetPartENT:IsA("ScriptedPuppet") then
      if targetPartENT:GetNPCType() == gamedataNPCType.Mech then
        log("Mech found ================================================================")
      end
    end
  end
end)

registerHotkey("MechTypeTest", "mechtypetest", function()
  local player = Game.GetPlayer()
  local npc = getLookAtObject()
  if not npc then return end
  if not npc:IsA("ScriptedPuppet") then return end
  log(npc:GetNPCType())
end)

local scanTimer = nil

registerForEvent("onInit", function()
  print("[Songbird's Deck] Loaded!")
  loadSettings()
  applySettings()
  setupNativeSettings()

  GameSession.OnStart(function() 
    isDeckEquipped = checkSongsDeckEquipped()
    log("GameSession Start ==========================================================")
    log("isDeckEquipped: " .. tostring(isDeckEquipped))
  end)

  ObserveBefore("PlayerPuppet", "OnDeath", function()
    if overdriveOccuring then
      stopDrain()
      endBlackwallOverdrive()
      setAbilityBlackwallDownlinkInactive()
      hideRLHint()
    end
  end)
  
  ObserveAfter("ScriptedPuppet", "OnNetworkLinkQuickhackEvent",
  ---@param this ScriptedPuppet
  ---@param evt NetworkLinkQuickhackEvent
  ---@diagnostic disable-next-line: unused-local, redundant-parameter
  function(this, evt)
    log("OnNetworkLinkQuickhackEvent ==========================================================")
    log("isDeckEquipped: " .. tostring(isDeckEquipped))
    if not isDeckEquipped then return end
    if REVENGE_TYPE == 1 then return end
    if REVENGE_TYPE == 3 and not overdriveOccuring then return end
    local enemyRunnerID = evt.netrunnerID
    local proxyID = evt.proxyID

    local enemyRunner = GameInstance.FindEntityByID(enemyRunnerID)
    local proxy = GameInstance.FindEntityByID(proxyID)
    
    if isDefined(enemyRunner) and enemyRunner:IsA("ScriptedPuppet") then
        StatusEffectHelper.ApplyStatusEffect(
          enemyRunner,
          "BaseStatusEffect.SoMi_Q306_BlackwallHackUpload",
          0.0
        )
      end
    if isDefined(proxy) then
      if proxy:IsA("ScriptedPuppet") then
        StatusEffectHelper.ApplyStatusEffect(
          proxy,
          "BaseStatusEffect.SoMi_Q306_BlackwallHackUpload",
          0.0
        )
      elseif proxy:IsA("Device") then
        spawnEffectAt(proxy)
        proxy:BreakDevice()
      end
    end
  end)


  ---@param this RipperDocGameController
  ---@param itemData gameItemData
  ---@diagnostic disable-next-line: unused-local, redundant-parameter
  ObserveAfter("RipperDocGameController", "EquipCyberware", function(this, itemData)
    isDeckEquipped = itemData:HasTag("BlackwallInterface")
    log("Deck equipped: " .. tostring(isDeckEquipped))
    ---@diagnostic disable-next-line: missing-parameter
    Cron.After(0.2, checkSongsDeckEquipped)
  end)

  ---@param this RipperDocGameController
  ---@param itemData gameItemData
  ---@diagnostic disable-next-line: unused-local, redundant-parameter
  ObserveAfter("RipperDocGameController", "UnequipCyberware", function(this, itemData)
    isDeckEquipped = not itemData:HasTag("BlackwallInterface")
    log("Deck unequipped: " .. tostring(isDeckEquipped))
    ---@diagnostic disable-next-line: missing-parameter
    Cron.After(0.2, checkSongsDeckEquipped)
  end)

  ---@param this QuickhacksListGameController
  ---@param shouldUseUI boolean
  ---@diagnostic disable-next-line: unused-local, redundant-parameter
  ObserveAfter("QuickhacksListGameController", "ApplyQuickHack", function(this, shouldUseUI)
    if not isDeckEquipped then return end
    local data = this.selectedData
    if data then
      local targetID = data.actionOwner
      local target = GameInstance.FindEntityByID(targetID)
      local actionName = "?"
      if data.action and data.action.GetObjectActionRecord then
        local rec = data.action:GetObjectActionRecord()
        if rec and rec.ActionName then
          actionName = Game.NameToString(rec:ActionName())
        end
      end
      log("ApplyQuickHack actionName=" .. tostring(actionName)
        .. " title=" .. tostring(data.title)
        .. " locked=" .. tostring(data.isLocked)
        .. " target=" .. tostring(target and Game.NameToString(target:GetClassName()) or "nil"))
      if target then
        playPlayerFx(USE_FORCE, false)
        if not runDeckDeviceHack(data, target) and not target:IsA("ScriptedPuppet") then
          spawnEffectAt(target)
        end
      end
    end
  end)
  
  ---@diagnostic disable-next-line: unused-local, redundant-parameter
  Override("ChargedHotkeyItemCyberwareController", "ResolveState", function(this,wrappedMethod)
    if overdriveOccuring then
      return
    end
    return wrappedMethod()
  end)

  ---@diagnostic disable-next-line: unused-local, redundant-parameter
  Override("AimingStateDecisions", "OnAction", function(this, action, consumer, wrappedMethod)
    local actionName = Game.NameToString(ListenerAction.GetName(action))
    local actionType = ListenerAction.GetType(action)

    if overdriveOccuring and actionType == gameinputActionType.BUTTON_PRESSED and (actionName == "CameraAim") then
      log("Fuck you stop trying to re aim the camera")
      return false
    end

    return wrappedMethod(action, consumer)
  end)
  ---@diagnostic disable-next-line: unused-local, redundant-parameter
  Override("PlayerPuppet", "OnAction", function(this, action, consumer, wrappedMethod)
    local actionName = Game.NameToString(ListenerAction.GetName(action))
    local actionType = ListenerAction.GetType(action)

    if actionLog then
      log("OnAction: " .. actionName .. " " .. tostring(actionType))
    end

    if inCameraPS and actionName == "StopDeviceControl" then 
      local action1 = inCameraPS:ActionQuestForceStopTakeControlOverCamera()
      local action2 = inCameraPS:ActionQuestForceDeactivate()
      if action1 and action2 then 
        local releasedPS = inCameraPS
        inCameraPS:ExecutePSAction(action1)
        inCameraPS:ExecutePSAction(action2)
        inCameraPS = nil
        local entity = getDeviceEntityFromPS(releasedPS)
        if isDefined(entity) then spawnEffectAt(entity) end
        setSensorFriendlyAttitude(releasedPS, entity)
        log("applied friendly attitude after camera/turret disconnect")
        for _, fx in ipairs(activeFx) do
          breakPlayerFx(fx)
        end
        stopAllPlayerFxFollow()
        activeFx = {}
        hideCHHint()
        return false
      end
    end

    local function icTriggerDL()
      if isDeckEquipped and checkSecurityArea() and not overdriveOccuring then
        if cyberwareex_enabled and not scanning then
          log("Scanning is not active, blocking iconic cyberware")
          return wrappedMethod(action, consumer)
        end
        if GAMEPLAY_MECHANICS_ENABLED then
          local player, sps, ownerID = getPlayerPools()
          --log("Player, StatPoolsSystem, OwnerID found")
          if not player or not sps or not ownerID then return false end
          local ram = getRAM(sps, ownerID)
          --log("RAM found: " .. tostring(ram))
          if ram <= 0 then
            log("Not enough RAM to activate blackwall downlink")
            return false
          end
        end
        showRLHint()
        setAbilityBlackwallDownlinkActive()
        triggerBlackwallOverdrive()
        controlNetwork()
        if GAMEPLAY_MECHANICS_ENABLED then
          startDrain()
        end
        return false
      end
      if not GAMEPLAY_MECHANICS_ENABLED then
        if overdriveOccuring then
          endBlackwallOverdrive()
          setAbilityBlackwallDownlinkInactive()
          hideRLHint()
          triggerBlackwallSideEffectsHeavy()
          return false
        end
      end
    end

    if actionName == "VisionHold" then
      log("VisionHold: " .. actionName .. " " .. tostring(actionType))
      if actionType == gameinputActionType.BUTTON_PRESSED and isDeckEquipped then
        log("VisionHold pressed")
        scanning = true
        if HOLD_TAB_TO_TRIGGER then
          scanTimer = Cron.After(HOLD_SECONDS, function()
            icTriggerDL()
          end, true)
        end
      end
      if actionType == gameinputActionType.BUTTON_RELEASED and isDeckEquipped then
        log("VisionHold released")
        if scanTimer then Cron.Halt(scanTimer) end
        scanTimer = nil
        scanning = false
      end
    end

    if actionName == "IconicCyberware" and actionType == gameinputActionType.BUTTON_RELEASED then
      log("Iconic Cyberware pressed")
      icTriggerDL()
    end

    if not overdriveOccuring and actionName == "MeleeBlock" and actionType == gameinputActionType.BUTTON_PRESSED and scanning then
      log("MeleeBlock pressed")
      if isDeckEquipped then
        log("Uploading Blackwall Device")
        local player = Game.GetPlayer()
        if not player then return end
        local lookAtObject = getLookAtObject()
        if not lookAtObject then return end
        if lookAtObject:IsA("Door") then
          ---@diagnostic disable-next-line: param-type-mismatch
          openOrCloseDoorHack(lookAtObject, player)
        end
        if lookAtObject:IsA("SurveillanceCamera") then
          ---@diagnostic disable-next-line: param-type-mismatch
          blackwallHackCamera(lookAtObject)
        end
      end
    end

    if overdriveOccuring then
      if actionType == gameinputActionType.BUTTON_PRESSED and (actionName == "RangedAttack" or actionName == "MeleeAttack") then
        BlackwallUpload.Execute()
        Cron.After(1.0, function()
          perPulseDrain()
          pulseNearbyDevicesAndVehicles()
          local lookAtObject = getLookAtObject()
          if lookAtObject then
            if lookAtObject:IsA("Door") then
              local player = Game.GetPlayer()
              if player then
                ---@diagnostic disable-next-line: param-type-mismatch
                openOrCloseDoorHack(lookAtObject, player)
              end
            end
          end
        end, true)
      end
      if actionType == gameinputActionType.BUTTON_PRESSED and (actionName == "MeleeBlock") then
        BlackwallUpload.Execute(nil, true)
      end
      return wrappedMethod(action, consumer)
    end

    return wrappedMethod(action, consumer)
  end)
  ---@diagnostic disable-next-line: unused-local, redundant-parameter
  Override("EquipmentSystem", "QueueRequest", function(this, request, wrappedMethod)
    if overdriveOccuring and request and request:IsA("EquipmentSystemWeaponManipulationRequest") then
      log("blocked weapon manipulation request: " .. tostring(request.requestType))
      local player = Game.GetPlayer()
      local wasAlreadyUsingCarryWrapper = StatusEffectSystem.ObjectHasStatusEffect(
        player,
      "GameplayRestriction.BodyCarryingWoundedSoldier"
      )

      if not wasAlreadyUsingCarryWrapper then
        Game.SetAnimWrapperWeight(player, "carry_woundedSoldier", 1.0)
        carryingWoundedF = true
      end
      return
    end

    wrappedMethod(request)
  end)
end)
