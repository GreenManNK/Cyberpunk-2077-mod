-- Panam Date SMS (Beach + Shootingrange + Autofix)
-- init.lua

------------------------------------------------------------
-- Required modules
------------------------------------------------------------
local GameUI = require("modules/GameUI")
local Cron   = require("modules/Cron")
local lang   = require("modules/lang")

------------------------------------------------------------
-- GameSession
------------------------------------------------------------
local GameSession
do
  local ok, m = pcall(require, "modules/GameSession")
  if ok and m then
    GameSession = m
  else
    print("[PanamDateSMS] WARN: modules/GameSession not found; HUD/SFX preferences will not persist.")
    GameSession = nil
  end
end

------------------------------------------------------------
-- Interaction UI 
------------------------------------------------------------
local ui
do
  local ok, m = pcall(require, "modules/interactionUI")
  if ok and m then ui = m end
end

-- UI icon variables (interaction choices)
local ICON_LOOT = nil
local ICON_FOOD_VENDOR = nil
local ICON_GUN = nil
local ICON_DRAW_WEAPON = nil
local ICON_SIT = nil
local ICON_SITDOWN = nil
local ICON_PAY = nil
local ICON_GET_UP = nil
local ICON_DRINK = nil
local ICON_PLAY_GUITAR = nil
local ICON_GIVE_TAKE = nil
local ICON_FALLBACK = nil
local YELLOW_CHOICE_TYPE = nil

local function getChoiceIconRecord(recordId)
  if not (TweakDBInterface and TweakDBInterface.GetChoiceCaptionIconPartRecord) then
    return nil
  end
  local ok, icon = pcall(function()
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(recordId)
  end)
  if ok then return icon end
  return nil
end

------------------------------------------------------------
-- Minimal JSON (flat key/value only)
------------------------------------------------------------
local json = (_G and _G.json) or nil
if not json then
  local function _esc(s)
    return (s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"))
  end
  local function _trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
  local function _parse_val(v)
    v = _trim(v)
    if v == "true" then return true end
    if v == "false" then return false end
    if v == "null" then return nil end
    if v:match("^%-?%d+%.%d+$") or v:match("^%-?%d+$") then return tonumber(v) end
    local s = v:match('^"(.*)"$')
    if s then
      return (s:gsub('\\"', '"'):gsub("\\\\", "\\"):gsub("\\n", "\n"):gsub("\\r", "\r"))
    end
    return v
  end
  local function _decode(s)
    if type(s) ~= "string" then return nil end
    local t = {}
    for k, v in s:gmatch('"%s*([^"]-)%s*"%s*:%s*([^,%}%]]+)') do
      t[k] = _parse_val(v)
    end
    return next(t) and t or nil
  end
  local function _encode(tbl)
    local parts = {}
    for k, v in pairs(tbl) do
      local key = '"' .. _esc(tostring(k)) .. '":'
      local tv = type(v)
      local val
      if tv == "number" then val = tostring(v)
      elseif tv == "boolean" then val = v and "true" or "false"
      elseif v == nil then val = "null"
      else val = '"' .. _esc(tostring(v)) .. '"' end
      table.insert(parts, key .. val)
    end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  json = { encode = _encode, decode = _decode }
end

------------------------------------------------------------
-- Helper function to get translated UI text
------------------------------------------------------------
local function getUIText(key)
  return lang.getText(key) or key
end

------------------------------------------------------------
-- Main table (MUST be defined first)
------------------------------------------------------------
PanamDateSMS = {
  active = false,

  runtimeData = {
    inGame = false,
    inMenu = false
  },

  messenger = nil,
  currentCategory = nil,
  initDay = -1,

  debug = {
    lastMessageFired = false,
    lastMessageFiredDay = -1,
    beachSequenceDone = false
  },

  lastCheck = 0,
  lastGiftDay = -1,
  cooldownDays = 0,
  initialCooldownDays = 0,
  hasMail = false,

  pins = {
    quest = nil,
    waypoint = nil
  },

  beach = {
    active = false,
    phase = "idle",
    timer = 0,
    checkTimer = 0,

    stepPin = nil,

    uiShown = false,

    truckSpawned = false,
    manualStartFired = false,

    picnicDone = false,
    preparedMeat = false,
    cookedMeat = false,

    voIntroPlayed = false,

    voD2BeforePlayed = false,
    voD2AfterPlayed = false,

    voPreFinalPlayed = false,
    voPreFinalScheduled = false,

    hudReduced = false,
    hudRestoredByLeaving = false,
    audioBusy = false,

    preFinal = {
      inRange = false,
      pollTimer = 0,
      pollInterval = 0.5,
      lastKey = nil,
      stableCount = 0,
      readyForMove = false
    }
  },

  shooting = {
    active = false,
    phase = "idle",
    timer = 0,

    stepPin = nil,
    uiShown = false,

    hudReduced = false,
    hudRestoredByLeaving = false,
    audioBusy = false,

    voNearPlayed = false,

    rangeChosen = false,
    practiceRunning = false,

    practiceRemaining = 0,
    practiceLastShown = -1,
    practiceSwitchTimer = 0,
    practiceSwitchInterval = 0.9,
    practiceCountdownShown = false,

    fireFxHandle = nil,
    fireFxStopHandle = nil,

    sampler = {
      pollTimer = 0,
      pollInterval = 0.5,
      lastKey = nil,
      stableCount = 0,
      ready = false
    },

    panamd2Played = false,
    sentArrivalMsg = false,

    questTrackerHidden = false,
    questTrackerPrev = nil
  },

  autofix = {
    active = false,
    phase = "idle",
    timer = 0,

    stepPin = nil,
    uiShown = false,

    hudReduced = false,
    hudRestoredByLeaving = false,

    truckSpawned = false,

    voIntroPlayed = false,

    buyDone = false,
    placedDrink = false,
    watchStarted = false,

    savedSfx = nil,
    sfxMuted = false,

    pdg2Set = false,

    perf = {
      uiPos = { x = -733.6467, y = -1000.5615, z = 8.004082, w = 1 },
      facingYaw = 95.44833,
      lastOpposite = nil,
      audioTimer = 0,
      audioInterval = 20.0,
      enjoyCooldown = 0,
      lastToggleTime = 0,
      lastToggleChoice = nil
    }
  },

  _functions = {}
}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function dbg(msg)
  print("[PanamDateSMS] " .. msg)
end

local function registerFunction(name, fn)
  PanamDateSMS._functions[name] = fn
  return fn
end

local function ToVector4(tbl)
  return Vector4.new(tbl.x, tbl.y, tbl.z, tbl.w or 1)
end

local function ToEulerAngles(tbl)
  return EulerAngles.new(tbl.roll or 0, tbl.pitch or 0, tbl.yaw or 0)
end

local function dist3(a, b)
  local dx, dy, dz = (a.x - b.x), (a.y - b.y), (a.z - b.z)
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function round2(x)
  return math.floor((x or 0) * 100 + 0.5) / 100
end

local function posKey2(p)
  return tostring(round2(p.x)) .. "|" .. tostring(round2(p.y)) .. "|" .. tostring(round2(p.z))
end

local function yawDeltaDeg(a, b)
  local d = (a - b) % 360
  if d > 180 then d = 360 - d end
  return math.abs(d)
end

local function PushHUDMessage(text, duration)
  local MSG = SimpleScreenMessage.new()
  local BBS = Game.GetBlackboardSystem()
  local defs = GetAllBlackboardDefs()
  local UINote = BBS:Get(defs.UI_Notifications)

  MSG.message = text
  MSG.isShown = true
  MSG.duration = duration or 1.0

  UINote:SetVariant(defs.UI_Notifications.OnscreenMessage, ToVariant(MSG), true)
end

------------------------------------------------------------
-- HUD control with persistence + repair on next load
------------------------------------------------------------
local HUD = { saved = nil }
local HUD_FILE = "PanamDateSMS_hud_restore.json"

-- Player preferences (persisted via GameSession)
local LOCAL_PREFERENCES = {
  baseline = {},     -- [hudKey] = true/false (player's original HUD state at game load)
  hud = {},          -- [hudKey] = true if originally enabled
  sfx = 1.0,         -- original SFX volume
  baselineSfx = 1.0  -- player's original SFX volume at game load
}

local HUD_KEYS = {
  "minimap","healthbar","stamina_oxygen","npc_healthbar","ammo_counter",
  "input_hints","action_buttons","activity_log","crosshairs","quest_tracker",
  "object_markers","npc_names","wanted_level","npc_nameplates","crouch_indicator",
  "vehicle_hud","hud_markers"
}

local function hudGetVar(settings, key)
  return settings:GetVar("/interface/hud", key)
end

local function hudRead(var)
  if not var then return nil end
  if var.GetValue then
    local ok, v = pcall(function() return var:GetValue() end)
    if ok then return v end
  end
  return nil
end

local function hudWrite(var, value)
  if not var then return end
  if var.SetValue then pcall(function() var:SetValue(value) end) end
end

local function hudWriteFile(savedTbl)
  local flat = { needsRestore = true }
  for k, v in pairs(savedTbl or {}) do
    flat[k] = v
  end
  local file = io.open(HUD_FILE, "w")
  if file then
    file:write(json.encode(flat) or "{}")
    file:close()
  end
end

local function hudClearFile()
  local file = io.open(HUD_FILE, "w")
  if file then
    file:write("{}")
    file:close()
  end
end

local function hudReadFile()
  local file = io.open(HUD_FILE, "r")
  if not file then return nil end
  local blob = file:read("*a")
  file:close()
  local ok, t = pcall(function() return json.decode(blob or "") end)
  if not ok then return nil end
  if type(t) ~= "table" then return nil end
  return t
end

local function captureBaselineHUD()
  local settings = Game.GetSettingsSystem()
  if not settings then return nil end
  local baseline = {}
  for _, k in ipairs(HUD_KEYS) do
    local v = hudGetVar(settings, k)
    local state = hudRead(v)
    baseline[k] = state or false
  end
  
  -- Also capture baseline SFX volume
  local sfxVar = settings:GetVar("/audio/volume", "SfxVolume")
  if sfxVar and sfxVar.GetValue then
    local ok, sfxVal = pcall(function() return sfxVar:GetValue() end)
    if ok and sfxVal then
      baseline._sfx = sfxVal
    end
  end
  
  return baseline
end

local function hudSnapshot()
  local settings = Game.GetSettingsSystem()
  if not settings then return nil end
  local saved = {}
  for _, k in ipairs(HUD_KEYS) do
    local v = hudGetVar(settings, k)
    local state = hudRead(v)
    -- Only save HUDs that are currently ENABLED (true)
    if state == true then
      saved[k] = true
    end
  end
  
  -- Also capture current SFX volume
  local sfxVar = settings:GetVar("/audio/volume", "SfxVolume")
  if sfxVar and sfxVar.GetValue then
    local ok, sfxVal = pcall(function() return sfxVar:GetValue() end)
    if ok and sfxVal then
      saved._sfx = sfxVal
    end
  end
  
  return saved
end

local function hudRestore(saved)
  local settings = Game.GetSettingsSystem()
  if not settings or type(saved) ~= "table" then return end
  for _, k in ipairs(HUD_KEYS) do
    local v = hudGetVar(settings, k)
    if saved[k] == true then
      -- This HUD was originally enabled, so restore it to enabled
      hudWrite(v, true)
    else
      -- This HUD was not in the saved list (was disabled), so disable it
      hudWrite(v, false)
    end
  end
  
  -- Also restore SFX volume if it was saved
  if saved._sfx then
    local sfxVar = settings:GetVar("/audio/volume", "SfxVolume")
    if sfxVar and sfxVar.SetValue then
      pcall(function() sfxVar:SetValue(saved._sfx) end)
    end
  end
end

local function restoreBaselineHUD(baseline)
  local settings = Game.GetSettingsSystem()
  if not settings or type(baseline) ~= "table" then return end
  
  -- Restore all HUDs to their baseline states (exact original)
  for _, k in ipairs(HUD_KEYS) do
    local v = hudGetVar(settings, k)
    local state = baseline[k]
    if state ~= nil then
      hudWrite(v, state)
    end
  end
  
  -- Restore baseline SFX volume
  if baseline._sfx then
    local sfxVar = settings:GetVar("/audio/volume", "SfxVolume")
    if sfxVar and sfxVar.SetValue then
      pcall(function() sfxVar:SetValue(baseline._sfx) end)
    end
  end
  
  dbg("Restored HUDs to baseline state")
end

local function hudRepairIfNeeded()
  local t = hudReadFile()
  if not t or t.needsRestore ~= true then return end

  local saved = {}
  for _, k in ipairs(HUD_KEYS) do
    -- Only restore HUDs that were explicitly marked as enabled
    if t[k] == true then
      saved[k] = true
    end
  end

  hudRestore(saved)
  hudClearFile()
  dbg("HUD repair applied from restore file")
end

local function setHUDMarkersOnlyNoMinimap(enable)
  local settings = Game.GetSettingsSystem()
  if not settings then return end

  if enable then
    if not HUD.saved then
      HUD.saved = hudSnapshot() or {}
      hudWriteFile(HUD.saved)
      -- Save to LOCAL_PREFERENCES for GameSession persistence
      for k, v in pairs(HUD.saved) do
        if k ~= "_sfx" then
          LOCAL_PREFERENCES.hud[k] = v
        else
          LOCAL_PREFERENCES.sfx = v
        end
      end
    end

    for _, k in ipairs(HUD_KEYS) do
      local v = hudGetVar(settings, k)
      if v then
        if k == "hud_markers" then
          hudWrite(v, true)
        elseif k == "minimap" then
          hudWrite(v, false)
        else
          hudWrite(v, false)
        end
      end
    end
  else
    if HUD.saved then
      hudRestore(HUD.saved)
    end
    HUD.saved = nil
    hudClearFile()
  end
end

local function setHUDAllHidden(enable)
  local settings = Game.GetSettingsSystem()
  if not settings then return end

  if enable then
    if not HUD.saved then
      HUD.saved = hudSnapshot() or {}
      hudWriteFile(HUD.saved)
      -- Save to LOCAL_PREFERENCES for GameSession persistence
      for k, v in pairs(HUD.saved) do
        if k ~= "_sfx" then
          LOCAL_PREFERENCES.hud[k] = v
        else
          LOCAL_PREFERENCES.sfx = v
        end
      end
    end

    for _, k in ipairs(HUD_KEYS) do
      local v = hudGetVar(settings, k)
      if v then hudWrite(v, false) end
    end
  else
    if HUD.saved then
      hudRestore(HUD.saved)
    end
    HUD.saved = nil
    hudClearFile()
  end
end

local function setQuestTrackerVisible(visible)
  local settings = Game.GetSettingsSystem()
  if not settings then return end
  local var = settings:GetVar("/interface/hud", "quest_tracker")
  if var and var.SetValue then
    pcall(function() var:SetValue(visible) end)
  end
end

local function readQuestTrackerVisible()
  local settings = Game.GetSettingsSystem()
  if not settings then return nil end
  local var = settings:GetVar("/interface/hud", "quest_tracker")
  if var and var.GetValue then
    local ok, val = pcall(function() return var:GetValue() end)
    if ok then return val end
  end
  return nil
end

-- Quest tracker is no longer modified by shooting event; keep helpers as no-ops
local function hideQuestTrackerForShooting(self)
  return
end

local function restoreQuestTrackerForShooting(self)
  return
end

------------------------------------------------------------
-- Audio helper (Audioware keys)
------------------------------------------------------------
local VOICE_STEP_SECONDS = 2.0

local function PlayAudioKey(key)
  local p = Game.GetPlayer()
  if not p then return false end

  local ok, audio = pcall(function()
    return (Game.GetAudioSystemExt and Game.GetAudioSystemExt()) or Game.GetAudioSystem()
  end)
  if not ok or not audio then return false end

  if audio.PlayExternal then
    pcall(function()
      audio:PlayExternal(key, p:GetEntityID(), "V")
    end)
  end

  if audio.Play then
    pcall(function()
      audio:Play(key, p:GetEntityID(), "V")
    end)
  end

  return false
end

local function playSequence(self, steps)
  local b = self.beach
  local s = self.shooting

  if b then b.audioBusy = true end
  if s then s.audioBusy = true end

  local t = 0.0
  for _, step in ipairs(steps) do
    local key = step.key
    local waitAfter = step.waitAfter or VOICE_STEP_SECONDS

    Cron.After(t, function()
      if self.runtimeData.inGame and not self.runtimeData.inMenu then
        pcall(function() PlayAudioKey(key) end)
      end
    end)

    t = t + waitAfter
  end

  Cron.After(t, function()
    if self.beach then self.beach.audioBusy = false end
    if self.shooting then self.shooting.audioBusy = false end
  end)

  return true
end

local function playVoiceFixed2(self, keys)
  local steps = {}
  for _, k in ipairs(keys) do
    table.insert(steps, { key = k, waitAfter = VOICE_STEP_SECONDS })
  end
  return playSequence(self, steps)
end

local function playD2Sequence(self)
  return playSequence(self, {
    { key = "panamd2", waitAfter = 4.0 },
    { key = "panamv2", waitAfter = VOICE_STEP_SECONDS }
  })
end

local function playWhaleOrShip()
  if math.random(1, 100) <= 75 then
    pcall(function() PlayAudioKey("pship") end)
  else
    pcall(function() PlayAudioKey("pwhale") end)
  end
end

------------------------------------------------------------
-- FX
------------------------------------------------------------
local function spawnBlinkFx()
  local p = Game.GetPlayer()
  if not p then return end
  pcall(function()
    Game.GetFxSystem():SpawnEffect(
      gameFxResource.new({ effect = "base\\fx\\player\\p_eyes_blinking\\p_blink_slow.effect" }),
      p:GetWorldTransform()
    )
  end)
end

local function spawnFastTravelGlitchFx()
  local p = Game.GetPlayer()
  if not p then return end
  pcall(function()
    Game.GetFxSystem():SpawnEffect(
      gameFxResource.new({ effect = "base\\fx\\camera\\fast_travel_glitch\\fast_travel_glitch.effect" }),
      p:GetWorldTransform()
    )
  end)
end

local function spawnFxAtOrFallback(posTbl, effectPath)
  local p = Game.GetPlayer()
  local fx = Game.GetFxSystem()
  if not p or not fx then return end

  local res = gameFxResource.new({ effect = effectPath })
  local ok = false

  if WorldTransform and WorldTransform.new then
    pcall(function()
      local wt = WorldTransform.new()
      if wt.SetPosition then wt:SetPosition(ToVector4(posTbl)) end
      fx:SpawnEffect(res, wt)
      ok = true
    end)
  end

  if (not ok) and Transform and Transform.new then
    pcall(function()
      local t = Transform.new()
      if t.SetPosition then t:SetPosition(ToVector4(posTbl)) end
      fx:SpawnEffect(res, t)
      ok = true
    end)
  end

  if not ok then
    pcall(function()
      fx:SpawnEffect(res, p:GetWorldTransform())
    end)
  end
end

------------------------------------------------------------
-- Teleport helpers
------------------------------------------------------------
local function TeleportPlayerTo(posTbl, eulerTbl)
  local p = Game.GetPlayer()
  if not p then return false end
  local fac = Game.GetTeleportationFacility()
  if not fac then return false end

  local ok = pcall(function()
    fac:Teleport(p, ToVector4(posTbl), ToEulerAngles(eulerTbl))
  end)
  return ok
end

local function BlinkTeleportNoMove(self)
  local p = Game.GetPlayer()
  if not p then return end
  local fac = Game.GetTeleportationFacility()
  if not fac then return end

  spawnBlinkFx()
  playVoiceFixed2(self, { "panamd3" })

  Cron.After(3.0, function()
    if self.runtimeData.inGame and not self.runtimeData.inMenu then
      playWhaleOrShip()
    end
  end)

  local pos = p:GetWorldPosition()
  local ang = p:GetWorldOrientation():ToEulerAngles()
  pcall(function()
    fac:Teleport(p, pos, EulerAngles.new(ang.roll or 0, ang.pitch or 0, ang.yaw or 0))
  end)
end

------------------------------------------------------------
-- Time skip
------------------------------------------------------------
local function advanceTimeHours(S)
  local ts = Game.GetTimeSystem()
  if not ts then return end
  local add = (S or 0) * 3600
  local ok = pcall(function() ts:ChangeGameTimeBySeconds(add) end)
  if not ok then
    local gt = ts:GetGameTime()
    if gt and gt.Days and gt.Hours and gt.Minutes then
      local total = gt:Days() * 86400 + gt:Hours() * 3600 + gt:Minutes() * 60
      pcall(function() ts:SetGameTimeBySeconds(total + add) end)
    end
  end
end

------------------------------------------------------------
-- WorldState toggles
------------------------------------------------------------
local function togglePrefab(node, pb, state)
  local ws = Game.GetWorldStateSystem()
  if not ws then return end
  if not CreateNodeRef then return end
  pcall(function()
    ws:TogglePrefabVariant(CreateNodeRef(node), pb, state)
  end)
end

local function applyPanamPrefabHides()
  local ws = Game.GetWorldStateSystem()
  if not ws then return end
  if not CreateNodeRef then return end

  local function t(node, pb)
    pcall(function() ws:TogglePrefabVariant(CreateNodeRef(node), pb, false) end)
  end

  t("$/0panamb4", "pb10")
  t("$/0panamb4", "pb11")
  t("$/0panamb5", "pb12")
  t("$/0panamb5", "pb13")
  t("$/0panamb3", "pb9")
  t("$/0panamb1", "pb3")
  t("$/0panamb1", "pb4")
  t("$/0panamb1", "pb5")
  t("$/0panamb2", "pb7")
end

local function enableBeachPrefabs()
  togglePrefab("$/0panamb4", "pb11", true)
  togglePrefab("$/0panamb3", "pb9", true)
end

local function applyShootingPrefabHides()
  togglePrefab("$/08phr",  "phr2", false)
  togglePrefab("$/08phr",  "phr1", false)
  togglePrefab("$/01phhe", "pt2", false)
  togglePrefab("$/01phhe", "pt6", false)
  togglePrefab("$/01phhe", "pt3", false)
  togglePrefab("$/01phhe", "ps1", false)
  togglePrefab("$/01phhe", "pt4", false)
  togglePrefab("$/01phhe", "pt1", false)
  togglePrefab("$/01phhe", "pt5", false)
end

local function applyAutofixPrefabHides()
  togglePrefab("$/02panamgg", "pdg1", false)
  togglePrefab("$/02panamgg", "pdg2", false)

  togglePrefab("$/006pggg", "pggg1", false)
  togglePrefab("$/006pggg", "pggg2", false)
  togglePrefab("$/006pggg", "pggg3", false)
  togglePrefab("$/006pggg", "pggg4", false)

  togglePrefab("$/007pggg", "pggg8", false)
  togglePrefab("$/007pggg", "pggg7", false)
  togglePrefab("$/007pggg", "pggg6", false)
  togglePrefab("$/007pggg", "pggg5", false)
end

local function set006Exclusive(which)
  togglePrefab("$/006pggg", "pggg1", which == "pggg1")
  togglePrefab("$/006pggg", "pggg2", which == "pggg2")
  togglePrefab("$/006pggg", "pggg3", which == "pggg3")
  togglePrefab("$/006pggg", "pggg4", which == "pggg4")
end

------------------------------------------------------------
-- UI hub helpers
------------------------------------------------------------
local function hideHubIfAny(self)
  if not ui then return end

  if self.beach and self.beach.uiShown and ui.hideHub then
    pcall(function() ui.hideHub() end)
    self.beach.uiShown = false
  end

  if self.shooting and self.shooting.uiShown and ui.hideHub then
    pcall(function() ui.hideHub() end)
    self.shooting.uiShown = false
  end

  if self.autofix and self.autofix.uiShown and ui.hideHub then
    pcall(function() ui.hideHub() end)
    self.autofix.uiShown = false
  end
end

local function showOneChoiceUI(self, title, label, onPick, flagField)
  if not ui or not ui.createHub then
    onPick()
    return
  end

  ui.clearCallbacks()
  local icon = nil
  local choiceType = nil
  if type(flagField) == "table" then
    icon = flagField.icon
    choiceType = flagField.choiceType
    flagField = flagField.flagField
  end
  local choices = { ui.createChoice(label, icon, choiceType) }

  ui.registerChoiceCallback(1, function()
    hideHubIfAny(self)
    onPick()
  end)

  local hub = ui.createHub(title, choices)
  ui.setupHub(hub)
  ui.showHub()
  if flagField and self[flagField] then
    self[flagField].uiShown = true
  end
end

local function showTwoChoiceUI(self, title, label1, on1, label2, on2, flagField)
  if not ui or not ui.createHub then
    on1()
    return
  end

  ui.clearCallbacks()
  local icon1, type1, icon2, type2 = nil, nil, nil, nil
  if type(flagField) == "table" then
    icon1 = flagField.icon1
    type1 = flagField.choiceType1
    icon2 = flagField.icon2
    type2 = flagField.choiceType2
    flagField = flagField.flagField
  end
  local choices = {
    ui.createChoice(label1, icon1, type1),
    ui.createChoice(label2, icon2, type2)
  }

  ui.registerChoiceCallback(1, function()
    hideHubIfAny(self)
    on1()
  end)

  ui.registerChoiceCallback(2, function()
    hideHubIfAny(self)
    on2()
  end)

  local hub = ui.createHub(title, choices)
  ui.setupHub(hub)
  ui.showHub()
  if flagField and self[flagField] then
    self[flagField].uiShown = true
  end
end

------------------------------------------------------------
-- Pin helpers
------------------------------------------------------------
-- IMPORTANT:
-- You cannot reliably set the World Map tooltip title ("Meet Panam") from Lua alone.
-- Use debugCaption as an identifier (REDscript can read it and set the tooltip text).
local MEET_PANAM_CAPTION_TOKEN = "PDS_MEET_PANAM"

local function registerQuestPinAt(posTbl)
  local ms = Game.GetMappinSystem()
  if not ms then return nil end

  local md = MappinData.new()
  md.mappinType = TweakDBID.new("Mappins.DefaultStaticMappin")
  md.variant = Enum.new("gamedataMappinVariant", "DefaultQuestVariant")
  md.visibleThroughWalls = true
  md.debugCaption = lang.getText("ui_meet_panam_caption") or "PanamDate|Meet Panam|Panam is waiting for you"

  return ms:RegisterMappin(md, ToVector4(posTbl))
end

local function unregisterPin(id)
  local ms = Game.GetMappinSystem()
  if not ms or not id then return end
  pcall(function() ms:UnregisterMappin(id) end)
end

local function setBeachMarker(self, posTbl)
  local b = self.beach
  if b.stepPin then unregisterPin(b.stepPin) end
  b.stepPin = registerQuestPinAt(posTbl)
end

local function clearBeachMarker(self)
  local b = self.beach
  if b.stepPin then unregisterPin(b.stepPin) end
  b.stepPin = nil
end

local function setShootingMarker(self, posTbl)
  local s = self.shooting
  if s.stepPin then unregisterPin(s.stepPin) end
  s.stepPin = registerQuestPinAt(posTbl)
end

local function clearShootingMarker(self)
  local s = self.shooting
  if s.stepPin then unregisterPin(s.stepPin) end
  s.stepPin = nil
end

local function setAutofixMarker(self, posTbl)
  local a = self.autofix
  if a.stepPin then unregisterPin(a.stepPin) end
  a.stepPin = registerQuestPinAt(posTbl)
end

local function clearAutofixMarker(self)
  local a = self.autofix
  if a.stepPin then unregisterPin(a.stepPin) end
  a.stepPin = nil
end

------------------------------------------------------------
-- Pin management (main quest pin)
------------------------------------------------------------
local CATEGORY_LOCS = {
  Beach = { x = -2187.1929, y = -1844.6361, z = 0.88832855, w = 1 },
  Autofix = { x = -722.3613, y = -988.3361, z = 8.004082, w = 1 },
  Shootingrange = { x = 2224.4685, y = 2000.9822, z = 178.48315, w = 1 },
}

PanamDateSMS.clearMeetPanamPins = registerFunction("clearMeetPanamPins", function(self)
  local ms = Game.GetMappinSystem()
  if not ms then return end
  if self.pins and self.pins.quest then
    pcall(function() ms:UnregisterMappin(self.pins.quest) end)
    self.pins.quest = nil
  end
  if self.pins and self.pins.waypoint then
    pcall(function() ms:UnregisterMappin(self.pins.waypoint) end)
    self.pins.waypoint = nil
  end
end)

PanamDateSMS.placeMeetPanamPins = registerFunction("placeMeetPanamPins", function(self, category)
  local ms = Game.GetMappinSystem()
  if not ms then return end
  local pos = CATEGORY_LOCS[category]
  if not pos then return end

  self:clearMeetPanamPins()

  local md1 = MappinData.new()
  md1.mappinType = TweakDBID.new("Mappins.DefaultStaticMappin")
  md1.variant = Enum.new("gamedataMappinVariant", "DefaultQuestVariant")
  md1.visibleThroughWalls = true
  md1.debugCaption = lang.getText("ui_meet_panam_caption") or "PanamDate|Meet Panam|Panam is waiting for you"
  self.pins.quest = ms:RegisterMappin(md1, ToVector4(pos))

  if category == "Beach" then
    enableBeachPrefabs()
    local b = self.beach
    b.active = false
    b.phase = "idle"
    b.timer = 0
    b.checkTimer = 0
    b.uiShown = false
    b.truckSpawned = false
    b.manualStartFired = false
    b.picnicDone = false
    b.preparedMeat = false
    b.cookedMeat = false
    b.voIntroPlayed = false
    b.voD2BeforePlayed = false
    b.voD2AfterPlayed = false
    b.voPreFinalPlayed = false
    b.voPreFinalScheduled = false
    b.hudReduced = false
    b.hudRestoredByLeaving = false
    b.audioBusy = false
    b.preFinal.inRange = false
    b.preFinal.pollTimer = 0
    b.preFinal.lastKey = nil
    b.preFinal.stableCount = 0
    b.preFinal.readyForMove = false
    clearBeachMarker(self)
    hideHubIfAny(self)
  end

  if category == "Shootingrange" then
    applyShootingPrefabHides()
    local s = self.shooting
    s.active = false
    s.phase = "idle"
    s.timer = 0
    s.uiShown = false
    s.hudReduced = false
    s.hudRestoredByLeaving = false
    s.audioBusy = false
    s.voNearPlayed = false
    s.rangeChosen = false
    s.practiceRunning = false
    s.practiceRemaining = 0
    s.practiceLastShown = -1
    s.practiceSwitchTimer = 0
    s.practiceSwitchInterval = 0.9
    s.sampler.pollTimer = 0
    s.sampler.lastKey = nil
    s.sampler.stableCount = 0
    s.sampler.ready = false
    s.panamd2Played = false
    s.sentArrivalMsg = false
    s.questTrackerHidden = false
    s.questTrackerPrev = nil
    if s.fireFxHandle then pcall(function() Cron.Halt(s.fireFxHandle) end) end
    s.fireFxHandle = nil
    if s.fireFxStopHandle then pcall(function() Cron.Halt(s.fireFxStopHandle) end) end
    s.fireFxStopHandle = nil
    clearShootingMarker(self)
    hideHubIfAny(self)
  end

  if category == "Autofix" then
    applyAutofixPrefabHides()
    local a = self.autofix
    a.active = false
    a.phase = "idle"
    a.timer = 0
    a.uiShown = false
    a.hudReduced = false
    a.hudRestoredByLeaving = false
    a.truckSpawned = false
    a.voIntroPlayed = false
    a.buyDone = false
    a.placedDrink = false
    a.watchStarted = false
    a.savedSfx = nil
    a.sfxMuted = false
    a.pdg2Set = false
    a.perf.audioTimer = 0
    a.perf.enjoyCooldown = 0
    a.perf.lastOpposite = nil
    clearAutofixMarker(self)
    hideHubIfAny(self)
  end
end)

------------------------------------------------------------
-- Manual phone message helper
------------------------------------------------------------
local function sendPhoneFromCategory(self, catName)
  if self.messenger and self.messenger.sendIncomingFromCategory then
    pcall(function() self.messenger:sendIncomingFromCategory(catName) end)
  else
    dbg("Missing messenger.sendIncomingFromCategory for " .. tostring(catName))
  end
end

------------------------------------------------------------
-- Check for Dedra Friends mod
------------------------------------------------------------
local function checkForDedraFriendsMod()
  local filePath = "ra/dedrapfriends.json"
  local file = io.open(filePath, "r")
  if file then
    io.close(file)
    dbg("Dedra Friends mod detected - using sq027_done fact")
    return true
  end
  return false
end

------------------------------------------------------------
-- Romance check
------------------------------------------------------------
local function checkPanamRomance()
  ObserveAfter("PlayerPuppet", "OnGameAttached", function()
    -- Force a clean baseline on every load before romance gating (same pattern as Panam Gift)
    PanamDateSMS.active = false
    PanamDateSMS.currentCategory = nil
    PanamDateSMS.lastCheck = 0
    PanamDateSMS.hasMail = false
    PanamDateSMS.lastGiftDay = -1
    PanamDateSMS.cooldownDays = 0
    PanamDateSMS.initialCooldownDays = 0
    PanamDateSMS.debug.lastMessageFired = false
    PanamDateSMS.debug.beachSequenceDone = false

    applyPanamPrefabHides()
    applyShootingPrefabHides()
    applyAutofixPrefabHides()

    if PanamDateSMS.beach then
      PanamDateSMS.beach.active = false
      PanamDateSMS.beach.phase = "idle"
      PanamDateSMS.beach.uiShown = false
      PanamDateSMS.beach.hudReduced = false
      PanamDateSMS.beach.hudRestoredByLeaving = false
    end

    if PanamDateSMS.shooting then
      PanamDateSMS.shooting.active = false
      PanamDateSMS.shooting.phase = "idle"
      PanamDateSMS.shooting.uiShown = false
      PanamDateSMS.shooting.hudReduced = false
      PanamDateSMS.shooting.hudRestoredByLeaving = false
      PanamDateSMS.shooting.practiceRunning = false
      PanamDateSMS.shooting.practiceRemaining = 0
      PanamDateSMS.shooting.rangeChosen = false
      PanamDateSMS.shooting.sentArrivalMsg = false
      PanamDateSMS.shooting.questTrackerHidden = false
      PanamDateSMS.shooting.questTrackerPrev = nil
    end

    if PanamDateSMS.autofix then
      PanamDateSMS.autofix.active = false
      PanamDateSMS.autofix.phase = "idle"
      PanamDateSMS.autofix.uiShown = false
      PanamDateSMS.autofix.hudReduced = false
      PanamDateSMS.autofix.hudRestoredByLeaving = false
      PanamDateSMS.autofix.watchStarted = false
      PanamDateSMS.autofix.sfxMuted = false
      PanamDateSMS.autofix.savedSfx = nil
    end

    if PanamDateSMS.messenger then
      PanamDateSMS.messenger:resetForNewSave()
    end

    local hasDedraFriends = checkForDedraFriendsMod()
    local factName = hasDedraFriends and "sq027_done" or "sq027_panam_lover"
    local fact = Game.GetQuestsSystem():GetFactStr(factName)
    local q108Done = Game.GetQuestsSystem():GetFactStr("q108_done")
    dbg("Romance fact " .. factName .. " = " .. tostring(fact))
    dbg("Quest fact q108_done = " .. tostring(q108Done))

    if fact == 1 and q108Done == 1 then
      PanamDateSMS.active = true
      
      if hasDedraFriends then
        dbg("I will be there for you")
      end

      -- Always reset on load to start fresh 2-4 day cycle
      PanamDateSMS.initDay = Game.GetTimeSystem():GetGameTime():Days()
      PanamDateSMS.initialCooldownDays = math.random(2, 4)
      PanamDateSMS.lastGiftDay = -1
      PanamDateSMS.cooldownDays = 0
      dbg("Romance confirmed - RESET for new save  initDay=" .. PanamDateSMS.initDay .. " initialCooldownDays=" .. PanamDateSMS.initialCooldownDays)

      if PanamDateSMS.messenger then
        PanamDateSMS.messenger:ensureContactWhenReady()
      end
    else
      PanamDateSMS.active = false
      PanamDateSMS.currentCategory = nil
      PanamDateSMS.initDay = -1
      dbg("Panam not romanced  mod inactive")
    end
  end)
end

------------------------------------------------------------
-- Messaging + events
------------------------------------------------------------
PanamDateSMS.sendMessageAndReact = registerFunction("sendMessageAndReact", function(self)
  if not self.active then return end
  if not self.messenger then
    dbg("ERROR: messenger not initialized")
    return
  end

  self.messenger:forceIncoming()

  local category = self.messenger.selectedCategory
  if not category then
    dbg("ERROR: no category selected")
    return
  end

  self.currentCategory = category
  self.debug.lastMessageFired = true
  self.debug.lastMessageFiredDay = Game.GetTimeSystem():GetGameTime():Days()

  self:startEventForCategory(category)
end)

PanamDateSMS.startEventForCategory = registerFunction("startEventForCategory", function(self, category)
  dbg("START EVENT  " .. tostring(category))
  self:placeMeetPanamPins(category)

  if category == "Beach" then
    self:startBeachEvent()
  elseif category == "Shootingrange" then
    self:startShootingrangeEvent()
  elseif category == "Autofix" then
    self:startAutofixEvent()
  end
end)

------------------------------------------------------------
-- Tagged dynamic entity helpers
------------------------------------------------------------
local function quatFromYawDeg(yawDeg)
  local r = math.rad(yawDeg or 0) * 0.5
  return Quaternion.new(0, 0, math.sin(r), math.cos(r))
end

local function spawnTaggedVehicle(recordId, posTbl, yawDeg, tagName)
  local des = Game.GetDynamicEntitySystem()
  if not des or not NewObject then return end

  pcall(function()
    des:CreateEntity((function(sp)
      sp.recordID     = TweakDBID.new(recordId)
      sp.position     = ToVector4(posTbl)
      sp.orientation  = quatFromYawDeg(yawDeg or 0)
      sp.persistState = false
      sp.persistSpawn = false
      sp.spawnInView  = true
      sp.active       = true
      sp.tags         = { CName.new(tagName or "TMP_TAG") }
      return sp
    end)(NewObject("DynamicEntitySpec")))
  end)
end

local function deleteTagged(tagName)
  local des = Game.GetDynamicEntitySystem()
  if not des then return end
  pcall(function()
    local t = CName.new(tagName or "TMP_TAG")
    if des.DeleteTagged then
      des:DeleteTagged(t)
    elseif des.DespawnTagged then
      des:DespawnTagged(t)
    end
  end)
end

------------------------------------------------------------
-- BEACH EVENT
------------------------------------------------------------
local BEACH_UI_RANGE = 2.0
local VO1_POS = { x = -2186.3447, y = -1844.9423, z = 0.95440674, w = 1 }
local VO1_YAW = 17.995798
local VO1_RANGE = 2.5
local VO1_YAW_TOL = 70.0

local VO2_POS = { x = -2215.2805, y = -1808.8391, z = -1.298439, w = 1 }
local VO2_YAWS = { 36.43947, 41.46403 }
local VO2_RANGE = 7.0
local VO2_YAW_TOL = 70.0

local HUD_HIDE_POS = { x = -2187.3843, y = -1844.6752, z = 0.8825302, w = 1 }
local HUD_HIDE_RANGE = 12.0

local BEACH_TRUCK_POS = { x = -2191.1482, y = -1890.2583, z = 4.0459747, w = 1 }
local BEACH_TRUCK_YAW = -165.76985
local BEACH_TRUCK_UI_POS = { x = -2191.8044, y = -1886.8535, z = 3.4701538, w = 1 }

local BEACH_ANCHOR_POS = { x = -2191.8286, y = -1847.0256, z = 0.8520813, w = 1 }
local BEACH_PREP_POS   = { x = -2188.7285, y = -1846.0681, z = 0.9215698, w = 1 }
local BEACH_BACK_POS   = { x = -2191.7937, y = -1847.0536, z = 0.8558426, w = 1 }
local BEACH_CANDLE_POS = { x = -2191.1108, y = -1846.6152, z = -0.093566895, w = 1 }
local BEACH_POS4       = { x = -2216.264,  y = -1807.4677, z = -0.9388733, w = 1 }

local BEACH_PRE_FINAL_POS = { x = -2189.8208, y = -1845.0247, z = 0.80683136, w = 1 }
local BEACH_PRE_FINAL_RANGE = 8.0

local BEACH_GLITCH_TP_POS = { x = -2198.578, y = -1834.0568, z = 0.069122314, w = 1 }
local BEACH_GLITCH_TP_ROT = { roll = 0, pitch = 0, yaw = 40.49324 }

local BEACH_FINAL_POS  = { x = -2185.5815, y = -1919.7542, z = 5.58461, w = 1 }

local BEACH_ALT_END_FROM_POS = { x = -2186.8328, y = -1846.1417, z = 1.0260315, w = 1 }
local BEACH_ALT_END_FAR_DIST = 80.0

local BEACH_OVERRIDE_END_POS = { x = 1820.9524, y = 2274.3606, z = 182.17699, w = 1 }
local BEACH_OVERRIDE_END_RANGE = 8.0

local function yawMatchesAny(pyaw, list, tol)
  for _, y in ipairs(list) do
    if yawDeltaDeg(pyaw or 0, y) <= (tol or 70.0) then
      return true
    end
  end
  return false
end

local function endBeachEventNow(self, reason)
  local b = self.beach
  dbg("[Beach] Ending event: " .. tostring(reason or "unknown"))

  self:clearMeetPanamPins()
  clearBeachMarker(self)
  hideHubIfAny(self)

  applyPanamPrefabHides()
  deleteTagged("TMP_BEACH")

  if b.hudReduced then
    setHUDMarkersOnlyNoMinimap(false)
    b.hudReduced = false
  end

  b.active = false
  b.phase = "idle"
  b.timer = 0
  b.checkTimer = 0
  b.uiShown = false
  b.truckSpawned = false
  b.audioBusy = false

  b.preFinal.inRange = false
  b.preFinal.pollTimer = 0
  b.preFinal.lastKey = nil
  b.preFinal.stableCount = 0
  b.preFinal.readyForMove = false

  self.currentCategory = nil
  self.debug.beachSequenceDone = true

  local DFNerveSystem = Game.GetScriptableSystemsContainer():Get("DarkFuture.Needs.DFNerveSystem")
  if DFNerveSystem then
    DFNerveSystem:QueueContextuallyDelayedNeedValueChange(50.0, true)
  end
  Game.GetStatusEffectSystem():ApplyStatusEffect(Game.GetPlayer():GetEntityID(), "HousingStatusEffect.Rested")

  if reason == "final marker reached" then
    Cron.After(10.0, function()
      sendPhoneFromCategory(self, "Ending")
    end)
  end
end

local function maybeApplyHudReductionBeach(self, ppos)
  local b = self.beach
  if b.hudReduced then return end
  if dist3(ppos, HUD_HIDE_POS) > HUD_HIDE_RANGE then return end

  setHUDMarkersOnlyNoMinimap(true)
  b.hudReduced = true
  dbg("[Beach] HUD reduced at checkpoint")
end

local BEACH_LEAVE_RANGE = 110.0
local BEACH_HUD_RETURN_RANGE = 40.0

local function getBeachLeaveRefs(phase)
  if phase == "truck_supplies_ui" then return { BEACH_TRUCK_UI_POS } end
  if phase == "anchor_prepare_ui" then return { BEACH_ANCHOR_POS } end
  if phase == "wait6_then_back_marker" or phase == "back_cook_ui" then return { BEACH_BACK_POS } end
  if phase == "wait5_then_blinkteleport" or phase == "wait1_then_reward" or phase == "go_pos4" then
    return { BEACH_POS4 }
  end
  if phase == "pre_final_hold_and_wait_move" then return { BEACH_PRE_FINAL_POS } end
  if phase == "final_marker" then return { BEACH_FINAL_POS, BEACH_ALT_END_FROM_POS } end
  return nil
end

local function nearestDistToRefs(ppos, refs)
  if not refs or #refs == 0 then return false end
  local nearest = nil
  for _, ref in ipairs(refs) do
    local d = dist3(ppos, ref)
    if (not nearest) or d < nearest then
      nearest = d
    end
  end
  return nearest
end

local function isTooFarFromRefs(ppos, refs, maxRange)
  local nearest = nearestDistToRefs(ppos, refs)
  if not nearest then return false end
  return nearest > maxRange
end

local function scheduleLeavingMessage(self)
  self.cooldownDays = math.random(2, 4)
  Cron.After(5.0, function()
    if self.runtimeData.inGame and not self.runtimeData.inMenu then
      sendPhoneFromCategory(self, "Leaving")
    end
  end)
end

local function maybeHandleBeachLeaving(self, ppos)
  local b = self.beach
  if not b or not b.active then return false end
  local refs = getBeachLeaveRefs(b.phase)
  if not refs then return false end
  local nearest = nearestDistToRefs(ppos, refs)
  if not nearest then return false end

  -- Early HUD restore band while still in date
  if b.hudReduced then
    if nearest > BEACH_HUD_RETURN_RANGE and nearest <= BEACH_LEAVE_RANGE then
      setHUDMarkersOnlyNoMinimap(false)
      b.hudReduced = false
      b.hudRestoredByLeaving = true
      dbg("[Beach] HUD restored while moving away from date area")
    end
  elseif b.hudRestoredByLeaving then
    if nearest <= BEACH_HUD_RETURN_RANGE then
      setHUDMarkersOnlyNoMinimap(true)
      b.hudReduced = true
      b.hudRestoredByLeaving = false
      dbg("[Beach] HUD reduced again after returning to date area")
    end
  end

  if nearest <= BEACH_LEAVE_RANGE then
    return false
  end

  endBeachEventNow(self, "player left date area")
  scheduleLeavingMessage(self)
  return true
end

local function maybePlayVO1(self, ppos, pyaw)
  local b = self.beach
  if b.voIntroPlayed then return end
  if b.picnicDone then return end

  if dist3(ppos, VO1_POS) > VO1_RANGE then return end
  if yawDeltaDeg(pyaw or 0, VO1_YAW) > VO1_YAW_TOL then return end

  b.voIntroPlayed = true
  playVoiceFixed2(self, { "panamv1", "panamd1" })
end

local function maybePlayVO2Twice(self, ppos, pyaw)
  local b = self.beach
  if dist3(ppos, VO2_POS) > VO2_RANGE then return end
  if not yawMatchesAny(pyaw, VO2_YAWS, VO2_YAW_TOL) then return end

  if (not b.preparedMeat) and (not b.voD2BeforePlayed) then
    b.voD2BeforePlayed = true
    playD2Sequence(self)
    return
  end

  if b.preparedMeat and (not b.cookedMeat) and (not b.voD2AfterPlayed) then
    b.voD2AfterPlayed = true
    playD2Sequence(self)
    return
  end
end

local function maybeSchedulePreFinalVoice(self)
  local b = self.beach
  if b.voPreFinalScheduled or b.voPreFinalPlayed then return end
  b.voPreFinalScheduled = true
  Cron.After(4.0, function()
    if self.beach and self.beach.active and (not self.beach.voPreFinalPlayed) then
      self.beach.voPreFinalPlayed = true
      playVoiceFixed2(self, { "panamd4" })
    end
  end)
end

local function updatePreFinalSamplerBeach(self, dt, ppos)
  local b = self.beach
  local pf = b.preFinal

  pf.pollTimer = pf.pollTimer + dt
  if pf.pollTimer < pf.pollInterval then return false end
  pf.pollTimer = 0

  local key = posKey2(ppos)

  if not pf.lastKey then
    pf.lastKey = key
    pf.stableCount = 1
    pf.readyForMove = false
    return false
  end

  if key == pf.lastKey then
    pf.stableCount = pf.stableCount + 1
    if pf.stableCount >= 5 then
      pf.readyForMove = true
    end
    return false
  end

  if pf.readyForMove then
    return true
  end

  pf.lastKey = key
  pf.stableCount = 1
  pf.readyForMove = false
  return false
end

PanamDateSMS.startBeachEvent = registerFunction("startBeachEvent", function(self)
  dbg("[EVENT] Beach")
  local b = self.beach

  b.active = true
  b.phase = "wait_near_beach_icon"
  b.timer = 0
  b.checkTimer = 0
  b.uiShown = false
  b.saveLocked = false
  b.truckSpawned = false
  b.manualStartFired = false
  b.picnicDone = false
  b.preparedMeat = false
  b.cookedMeat = false
  b.voIntroPlayed = false
  b.voD2BeforePlayed = false
  b.voD2AfterPlayed = false
  b.voPreFinalPlayed = false
  b.voPreFinalScheduled = false
  b.hudReduced = false
  b.hudRestoredByLeaving = false
  b.audioBusy = false

  b.preFinal.inRange = false
  b.preFinal.pollTimer = 0
  b.preFinal.lastKey = nil
  b.preFinal.stableCount = 0
  b.preFinal.readyForMove = false

  b.startGameTime = Game.GetTimeSystem():GetGameTime():GetSeconds()

  hideHubIfAny(self)

  deleteTagged("TMP_BEACH")
  spawnTaggedVehicle("Vehicle.v_standard3_thorton_mackinaw_nomad_panam", BEACH_TRUCK_POS, BEACH_TRUCK_YAW, "TMP_BEACH")
  b.truckSpawned = true
end)

PanamDateSMS.tickBeachEvent = registerFunction("tickBeachEvent", function(self, dt)
  local b = self.beach
  if not b.active then return end
  if not self.runtimeData.inGame or self.runtimeData.inMenu then return end

  local p = Game.GetPlayer()
  if not p then return end

  local veh = Game['GetMountedVehicle;GameObject'](p)
  if veh and veh:GetRecordID() == "Vehicle.v_standard3_thorton_mackinaw_nomad_panam" then
    local comp = veh:GetVehicleComponent()
    if comp then comp:ToggleVehicleSystems(false, true, true) end
  end

  local ppos = p:GetWorldPosition()
  local pyaw = p:GetWorldOrientation():ToEulerAngles().yaw

  local nowSec = Game.GetTimeSystem():GetGameTime():GetSeconds()
  if b.startGameTime and (nowSec - b.startGameTime) >= (9 * 3600) then
    endBeachEventNow(self, "timeout")
    self.cooldownDays = math.random(2, 4)
    Cron.After(5.0, function()
      if self.runtimeData.inGame and not self.runtimeData.inMenu then
        sendPhoneFromCategory(self, "waittime")
      end
    end)
    return
  end

  if dist3(ppos, BEACH_OVERRIDE_END_POS) <= BEACH_OVERRIDE_END_RANGE then
    endBeachEventNow(self, "override location reached")
    return
  end

  if maybeHandleBeachLeaving(self, ppos) then
    return
  end

  maybeApplyHudReductionBeach(self, ppos)
  maybePlayVO1(self, ppos, pyaw)
  maybePlayVO2Twice(self, ppos, pyaw)

  if b.phase == "wait_near_beach_icon" then
    local dMain = dist3(ppos, CATEGORY_LOCS.Beach)
    if dMain <= 30.0 then
      if not b.manualStartFired then
        sendPhoneFromCategory(self, "BeachPreJoin")
        b.manualStartFired = true
      end

      self:clearMeetPanamPins()
      setBeachMarker(self, BEACH_TRUCK_UI_POS)
      b.phase = "truck_supplies_ui"
      b.timer = 0
      hideHubIfAny(self)
    end
    return
  end

  if b.phase == "truck_supplies_ui" then
    local d = dist3(ppos, BEACH_TRUCK_UI_POS)
    if d <= BEACH_UI_RANGE then
      if not b.uiShown then
        showOneChoiceUI(self, getUIText("ui_coastview"), getUIText("ui_grab_picnic"), function()
          b.picnicDone = true

          togglePrefab("$/0panamb2", "pb7", true)
          togglePrefab("$/0panamb3", "pb9", false)

          clearBeachMarker(self)
          setBeachMarker(self, BEACH_ANCHOR_POS)

          b.phase = "anchor_prepare_ui"
          b.timer = 0
        end, {
          flagField = "beach",
          icon = ICON_GIVE_TAKE,
          choiceType = YELLOW_CHOICE_TYPE
        })
      end
    else
      if b.uiShown then hideHubIfAny(self) end
    end
    return
  end

  if b.phase == "anchor_prepare_ui" then
    local d = dist3(ppos, BEACH_ANCHOR_POS)
    if d <= BEACH_UI_RANGE then
      if not b.uiShown then
        showTwoChoiceUI(
          self,
          getUIText("ui_coastview"),
          getUIText("ui_prepare_meat"),
          function()
            b.preparedMeat = true
            togglePrefab("$/0panamb5", "pb12", true)

            clearBeachMarker(self)
            setBeachMarker(self, BEACH_PREP_POS)

            b.phase = "wait6_then_back_marker"
            b.timer = 0
          end,
          getUIText("ui_join_panam"),
          function()
            b.phase = "anchor_prepare_ui"
            b.timer = 0
          end,
          {
            flagField = "beach",
            icon1 = ICON_FOOD_VENDOR,
            choiceType1 = YELLOW_CHOICE_TYPE
          }
        )
      end
    else
      if b.uiShown then hideHubIfAny(self) end
    end
    return
  end

  if b.phase == "wait6_then_back_marker" then
    b.timer = b.timer + dt
    if b.timer >= 6.0 then
      clearBeachMarker(self)
      setBeachMarker(self, BEACH_BACK_POS)
      b.phase = "back_cook_ui"
      b.timer = 0
      hideHubIfAny(self)
    end
    return
  end

  if b.phase == "back_cook_ui" then
    local d = dist3(ppos, BEACH_BACK_POS)
    if d <= BEACH_UI_RANGE then
      if not b.uiShown then
        if ui and ui.createHub then
          showTwoChoiceUI(
            self,
            getUIText("ui_coastview"),
            getUIText("ui_cook_meat"),
            function()
              b.cookedMeat = true

              spawnFxAtOrFallback(BEACH_CANDLE_POS, "base\\fx\\environment\\pyro\\e_candle_fire_idle_small.effect")

              togglePrefab("$/0panamb5", "pb12", false)
              togglePrefab("$/0panamb5", "pb13", true)

              clearBeachMarker(self)
              b.phase = "wait5_then_blinkteleport"
              b.timer = 0
              
              -- Play audio after phase transition to avoid blocking
              Cron.After(0.1, function()
                PlayAudioKey("panamgrill")
              end)
            end,
            "Join Panam",
            function()
              b.phase = "back_cook_ui"
              b.timer = 0
            end,
            {
              flagField = "beach",
              icon1 = ICON_FOOD_VENDOR,
              choiceType1 = YELLOW_CHOICE_TYPE
            }
          )
        else
          -- Fallback if UI is not available - auto-progress
          b.cookedMeat = true
          spawnFxAtOrFallback(BEACH_CANDLE_POS, "base\\fx\\environment\\pyro\\e_candle_fire_idle_small.effect")
          togglePrefab("$/0panamb5", "pb12", false)
          togglePrefab("$/0panamb5", "pb13", true)
          clearBeachMarker(self)
          b.phase = "wait5_then_blinkteleport"
          b.timer = 0
          
          -- Play audio after phase transition to avoid blocking
          Cron.After(0.1, function()
            PlayAudioKey("panamgrill")
          end)
        end
      end
    else
      if b.uiShown then hideHubIfAny(self) end
    end
    return
  end

  if b.phase == "wait5_then_blinkteleport" then
    b.timer = b.timer + dt
    if b.timer >= 5.0 then
      BlinkTeleportNoMove(self)

      togglePrefab("$/0panamb2", "pb7", false)
      togglePrefab("$/0panamb1", "pb3", true)
      togglePrefab("$/0panamb5", "pb13", false)

      b.phase = "wait1_then_reward"
      b.timer = 0
    end
    return
  end

  if b.phase == "wait1_then_reward" then
    b.timer = b.timer + dt
    if b.timer >= 1.0 then
      pcall(function()
        Game.AddToInventory("Items.MediumQualityFood7", 1)
      end)

      clearBeachMarker(self)
      setBeachMarker(self, BEACH_POS4)
      b.phase = "go_pos4"
      b.timer = 0
    end
    return
  end

  if b.phase == "go_pos4" then
    if dist3(ppos, BEACH_POS4) <= 8.0 then
      clearBeachMarker(self)

      togglePrefab("$/0panamb1", "pb3", false)
      togglePrefab("$/0panamb1", "pb5", true)

      setBeachMarker(self, BEACH_PRE_FINAL_POS)

      b.preFinal.inRange = false
      b.preFinal.pollTimer = 0
      b.preFinal.lastKey = nil
      b.preFinal.stableCount = 0
      b.preFinal.readyForMove = false

      b.phase = "pre_final_hold_and_wait_move"
      b.timer = 0
    end
    return
  end

  if b.phase == "pre_final_hold_and_wait_move" then
    local d = dist3(ppos, BEACH_PRE_FINAL_POS)
    if d <= BEACH_PRE_FINAL_RANGE then
      if not b.preFinal.inRange then
        b.preFinal.inRange = true
        b.preFinal.pollTimer = 0
        b.preFinal.lastKey = nil
        b.preFinal.stableCount = 0
        b.preFinal.readyForMove = false
        maybeSchedulePreFinalVoice(self)
      end

      local shouldTrigger = updatePreFinalSamplerBeach(self, dt, ppos)
      if shouldTrigger then
        clearBeachMarker(self)

        spawnFastTravelGlitchFx()
        TeleportPlayerTo(BEACH_GLITCH_TP_POS, BEACH_GLITCH_TP_ROT)
        advanceTimeHours(2)

        togglePrefab("$/0panamb1", "pb5", false)
        togglePrefab("$/0panamb1", "pb4", true)

        setBeachMarker(self, BEACH_FINAL_POS)

        b.phase = "final_marker"
        b.timer = 0
      end
    else
      if b.preFinal.inRange then
        b.preFinal.inRange = false
        b.preFinal.pollTimer = 0
        b.preFinal.lastKey = nil
        b.preFinal.stableCount = 0
        b.preFinal.readyForMove = false
      end
    end
    return
  end

  if b.phase == "final_marker" then
    local atFinal = dist3(ppos, BEACH_FINAL_POS) <= 8.0
    local farFromAlt = dist3(ppos, BEACH_ALT_END_FROM_POS) >= BEACH_ALT_END_FAR_DIST

    if atFinal or farFromAlt then
      endBeachEventNow(self, atFinal and "final marker reached" or "far-from-alt end condition")
    end
    return
  end
end)

------------------------------------------------------------
-- SHOOTING EVENT
------------------------------------------------------------
local SHOOT_UI_RANGE = 2.0

local SHOOT_START_POS = { x = 2224.4685, y = 2000.9822, z = 178.48315, w = 1 }
local SHOOT_STEP_POS  = { x = 2246.7996, y = 1985.878,  z = 179.44682, w = 1 }

local SHOOT_VO_NEAR_POS = { x = 2248.1433, y = 2001.3513, z = 179.47992, w = 1 }
local SHOOT_VO_NEAR_RANGE = 7.0

local SHOOT_LONG_POS = { x = 2260.8489, y = 1981.7377, z = 182.67247, w = 1 }
local SHOOT_LONG_ROT = { roll = 0, pitch = 0, yaw = -80.93321 }

local SHOOT_SHORT_POS = { x = 2295.664, y = 1992.348, z = 175.95523, w = 1 }
local SHOOT_SHORT_ROT = { roll = 0, pitch = 0, yaw = -90.21487 }

local CAMP_BRANCHES_POS = { x = 2318.029, y = 1968.2004, z = 177.96172, w = 1 }
local CAMP_STAND_POS    = { x = 2304.6743, y = 1999.9557, z = 176.41016, w = 1 }
local CAMP_MEDIATE_POS  = { x = 2303.2087, y = 1997.1246, z = 176.15784, w = 1 }
local CAMP_FACE_YAW     = 78.534
local CAMP_FACE_TOL     = 70.0
local CAMP_FACE_RANGE   = 7.0

local SHOOT_RETURN_POS  = { x = 2250.0476, y = 1992.6686, z = 179.50981, w = 1 }
local SHOOT_LEAVE_RANGE = 130.0
local SHOOT_HUD_RETURN_RANGE = 45.0
local endShootingEventNow

local function getShootingLeaveRefs(phase)
  if phase == "go_step_marker" then return { SHOOT_STEP_POS } end
  if phase == "practice_running" then return { SHOOT_SHORT_POS, SHOOT_LONG_POS } end
  if phase == "camp_branches_ui" then return { CAMP_BRANCHES_POS } end
  if phase == "camp_build_ui" or phase == "camp_wait_still" or phase == "camp_face_panamd2" then
    return { CAMP_STAND_POS, CAMP_MEDIATE_POS }
  end
  if phase == "return_marker" then return { SHOOT_RETURN_POS } end
  return nil
end

local function maybeHandleShootingLeaving(self, ppos)
  local s = self.shooting
  if not s or not s.active then return false end
  local refs = getShootingLeaveRefs(s.phase)
  if not refs then return false end
  local nearest = nearestDistToRefs(ppos, refs)
  if not nearest then return false end

  -- Early HUD restore band while still in date
  if s.hudReduced then
    if nearest > SHOOT_HUD_RETURN_RANGE and nearest <= SHOOT_LEAVE_RANGE then
      setHUDMarkersOnlyNoMinimap(false)
      s.hudReduced = false
      s.hudRestoredByLeaving = true
      dbg("[Shooting] HUD restored while moving away from date area")
    end
  elseif s.hudRestoredByLeaving then
    if nearest <= SHOOT_HUD_RETURN_RANGE then
      setHUDMarkersOnlyNoMinimap(true)
      s.hudReduced = true
      s.hudRestoredByLeaving = false
      dbg("[Shooting] HUD reduced again after returning to date area")
    end
  end

  if nearest <= SHOOT_LEAVE_RANGE then
    return false
  end

  endShootingEventNow(self, "player left date area")
  scheduleLeavingMessage(self)
  return true
end

local function setTargetPairDownUp(downVar, upVar, isDown)
  togglePrefab("$/01phhe", downVar, isDown)
  togglePrefab("$/01phhe", upVar, not isDown)
end

local function randomizeTargetsOnce()
  local d1 = (math.random(0, 1) == 1)
  local d2 = (math.random(0, 1) == 1)
  local d3 = (math.random(0, 1) == 1)

  setTargetPairDownUp("pt3", "pt4", d1)
  setTargetPairDownUp("pt5", "pt6", d2)
  setTargetPairDownUp("pt1", "pt2", d3)
end

local function stopShootingFireLoop(self)
  local s = self.shooting
  if s.fireFxHandle then
    pcall(function() Cron.Halt(s.fireFxHandle) end)
    s.fireFxHandle = nil
  end
  if s.fireFxStopHandle then
    pcall(function() Cron.Halt(s.fireFxStopHandle) end)
    s.fireFxStopHandle = nil
  end
end

endShootingEventNow = function(self, reason)
  local s = self.shooting
  dbg("[Shooting] Ending event: " .. tostring(reason or "unknown"))

  self:clearMeetPanamPins()
  clearShootingMarker(self)
  hideHubIfAny(self)

  applyShootingPrefabHides()
  stopShootingFireLoop(self)
  restoreQuestTrackerForShooting(self)

  if s.hudReduced then
    setHUDMarkersOnlyNoMinimap(false)
    s.hudReduced = false
  end

  s.active = false
  s.phase = "idle"
  s.timer = 0
  s.uiShown = false
  s.voNearPlayed = false
  s.rangeChosen = false
  s.practiceRunning = false
  s.practiceRemaining = 0
  s.practiceLastShown = -1
  s.practiceSwitchTimer = 0
  s.practiceCountdownShown = false
  s.panamd2Played = false
  s.sampler.pollTimer = 0
  s.sampler.lastKey = nil
  s.sampler.stableCount = 0
  s.sampler.ready = false
  s.sentArrivalMsg = false

  self.currentCategory = nil

  local DFNerveSystem = Game.GetScriptableSystemsContainer():Get("DarkFuture.Needs.DFNerveSystem")
  if DFNerveSystem then
    DFNerveSystem:QueueContextuallyDelayedNeedValueChange(50.0, true)
  end
  Game.GetStatusEffectSystem():ApplyStatusEffect(Game.GetPlayer():GetEntityID(), "HousingStatusEffect.Rested")
  
end

PanamDateSMS.startShootingrangeEvent = registerFunction("startShootingrangeEvent", function(self)
  dbg("[EVENT] Shootingrange")

  applyShootingPrefabHides()
  hideHubIfAny(self)

  local s = self.shooting
  s.active = true
  s.phase = "go_start_marker"
  s.timer = 0
  s.uiShown = false
  s.hudReduced = false
  s.hudRestoredByLeaving = false
  s.audioBusy = false
  s.voNearPlayed = false
  s.saveLocked = false
  s.rangeChosen = false
  s.practiceRunning = false
  s.practiceRemaining = 30.0
  s.practiceLastShown = -1
  s.practiceSwitchTimer = 0
  s.practiceSwitchInterval = 0.9
  s.practiceCountdownShown = false
  s.panamd2Played = false
  s.sentArrivalMsg = false
  s.questTrackerHidden = false
  s.questTrackerPrev = nil

  s.sampler.pollTimer = 0
  s.sampler.lastKey = nil
  s.sampler.stableCount = 0
  s.sampler.ready = false

  s.startGameTime = Game.GetTimeSystem():GetGameTime():GetSeconds()

  stopShootingFireLoop(self)

  self:clearMeetPanamPins()
  self.pins.quest = registerQuestPinAt(SHOOT_START_POS)

  setShootingMarker(self, SHOOT_START_POS)
end)

PanamDateSMS.tickShootingrangeEvent = registerFunction("tickShootingrangeEvent", function(self, dt)
  local s = self.shooting
  if not s.active then return end
  if not self.runtimeData.inGame or self.runtimeData.inMenu then return end

  local p = Game.GetPlayer()
  if not p then return end
  local ppos = p:GetWorldPosition()
  local pyaw = p:GetWorldOrientation():ToEulerAngles().yaw

  local nowSec = Game.GetTimeSystem():GetGameTime():GetSeconds()
  if s.startGameTime and (nowSec - s.startGameTime) >= (9 * 3600) then
    endShootingEventNow(self, "timeout")
    self.cooldownDays = math.random(2, 4)
    Cron.After(5.0, function()
      if self.runtimeData.inGame and not self.runtimeData.inMenu then
        sendPhoneFromCategory(self, "waittime")
      end
    end)
    return
  end

  if maybeHandleShootingLeaving(self, ppos) then
    return
  end

  if s.phase == "go_start_marker" then
    if dist3(ppos, SHOOT_START_POS) <= 8.0 then
      if not s.sentArrivalMsg then
        sendPhoneFromCategory(self, "panamshooting")
        s.sentArrivalMsg = true
      end
      
      clearShootingMarker(self)
      setShootingMarker(self, SHOOT_STEP_POS)

      togglePrefab("$/01phhe", "pt3", true)
      togglePrefab("$/01phhe", "pt1", true)
      togglePrefab("$/08phr",  "phr1", true)

      s.phase = "go_step_marker"
      s.timer = 0
    end
    return
  end

  if (not s.voNearPlayed) and dist3(ppos, SHOOT_VO_NEAR_POS) <= SHOOT_VO_NEAR_RANGE then
    s.voNearPlayed = true
    playVoiceFixed2(self, { "panamd1", "panamv1" })
  end

  if s.phase == "go_step_marker" then
    if dist3(ppos, SHOOT_STEP_POS) <= SHOOT_UI_RANGE then
      if (not s.uiShown) and (not s.rangeChosen) then
        showTwoChoiceUI(
          self,
          getUIText("ui_shooting_title"),
          getUIText("ui_short_range"),
          function()
            s.rangeChosen = true
            spawnFastTravelGlitchFx()
            TeleportPlayerTo(SHOOT_SHORT_POS, SHOOT_SHORT_ROT)
            hideQuestTrackerForShooting(self)

            randomizeTargetsOnce()

            s.practiceRunning = true
            s.practiceRemaining = 30.0
            s.practiceLastShown = -1
            s.practiceSwitchTimer = 0
            s.practiceSwitchInterval = 0.9
            s.practiceCountdownShown = false

            s.phase = "practice_running"
            s.timer = 0
          end,
          getUIText("ui_long_range"),
          function()
            s.rangeChosen = true
            spawnFastTravelGlitchFx()
            TeleportPlayerTo(SHOOT_LONG_POS, SHOOT_LONG_ROT)
            hideQuestTrackerForShooting(self)

            randomizeTargetsOnce()

            s.practiceRunning = true
            s.practiceRemaining = 30.0
            s.practiceLastShown = -1
            s.practiceSwitchTimer = 0
            s.practiceSwitchInterval = 0.9
            s.practiceCountdownShown = false

            s.phase = "practice_running"
            s.timer = 0
          end,
          {
            flagField = "shooting",
            icon1 = ICON_GUN,
            choiceType1 = YELLOW_CHOICE_TYPE,
            icon2 = ICON_DRAW_WEAPON,
            choiceType2 = YELLOW_CHOICE_TYPE
          }
        )
      end
    else
      if s.uiShown then hideHubIfAny(self) end
    end
    return
  end

  if s.phase == "practice_running" then
    if not s.practiceRunning then
      s.phase = "after_practice"
      return
    end

    s.practiceRemaining = s.practiceRemaining - dt
    if s.practiceRemaining < 0 then s.practiceRemaining = 0 end

    local shown = math.ceil(s.practiceRemaining)
    if shown <= 10 then
      if shown ~= s.practiceLastShown then
        s.practiceLastShown = shown
        PushHUDMessage("Time: " .. tostring(shown), 1.1)
      end
      s.practiceCountdownShown = true
    else
      s.practiceCountdownShown = false
    end

    s.practiceSwitchTimer = s.practiceSwitchTimer + dt
    if s.practiceSwitchTimer >= s.practiceSwitchInterval then
      s.practiceSwitchTimer = 0
      s.practiceSwitchInterval = math.random(7, 14) / 10.0
      randomizeTargetsOnce()
    end

    if s.practiceRemaining <= 0.0 then
      s.practiceRunning = false

      sendPhoneFromCategory(self, "panamcampfire")

      clearShootingMarker(self)
      setShootingMarker(self, CAMP_BRANCHES_POS)

      s.phase = "camp_branches_ui"
      s.timer = 0
      hideHubIfAny(self)
    end

    return
  end

  if s.phase == "camp_branches_ui" then
    if dist3(ppos, CAMP_BRANCHES_POS) <= SHOOT_UI_RANGE then
      if not s.uiShown then
        showOneChoiceUI(self, getUIText("ui_practice"), getUIText("ui_gather_branches"), function()
          clearShootingMarker(self)
          setShootingMarker(self, CAMP_STAND_POS)
          s.phase = "camp_build_ui"
          s.timer = 0
        end, {
          flagField = "shooting",
          icon = ICON_GIVE_TAKE,
          choiceType = YELLOW_CHOICE_TYPE
        })
      end
    else
      if s.uiShown then hideHubIfAny(self) end
    end
    return
  end

  if s.phase == "camp_build_ui" then
    if dist3(ppos, CAMP_STAND_POS) <= SHOOT_UI_RANGE then
      if not s.uiShown then
        showOneChoiceUI(self, getUIText("ui_campfire"), getUIText("ui_build_campfire"), function()
          setHUDMarkersOnlyNoMinimap(true)
          s.hudReduced = true

          togglePrefab("$/01phhe", "ps1", true)

          clearShootingMarker(self)
          setShootingMarker(self, CAMP_MEDIATE_POS)

          self:clearMeetPanamPins()
          self.pins.quest = registerQuestPinAt(CAMP_MEDIATE_POS)

          s.sampler.pollTimer = 0
          s.sampler.lastKey = nil
          s.sampler.stableCount = 0
          s.sampler.ready = false

          s.phase = "camp_wait_still"
          s.timer = 0
        end, {
          flagField = "shooting",
          icon = ICON_SITDOWN,
          choiceType = YELLOW_CHOICE_TYPE
        })
      end
    else
      if s.uiShown then hideHubIfAny(self) end
    end
    return
  end

  if s.phase == "camp_wait_still" then
    if dist3(ppos, CAMP_STAND_POS) > 8.0 then
      s.sampler.pollTimer = 0
      s.sampler.lastKey = nil
      s.sampler.stableCount = 0
      s.sampler.ready = false
      return
    end

    s.sampler.pollTimer = s.sampler.pollTimer + dt
    if s.sampler.pollTimer < s.sampler.pollInterval then return end
    s.sampler.pollTimer = 0

    local key = posKey2(ppos)
    if not s.sampler.lastKey then
      s.sampler.lastKey = key
      s.sampler.stableCount = 1
      return
    end

    if key == s.sampler.lastKey then
      s.sampler.stableCount = s.sampler.stableCount + 1
      if s.sampler.stableCount >= 8 then
        spawnFastTravelGlitchFx()
        spawnFxAtOrFallback(CAMP_STAND_POS, "base\\fx\\environment\\pyro\\e_fire_medium.effect")

        stopShootingFireLoop(self)
        s.fireFxHandle = Cron.Every(3.0, function()
          if self.shooting and self.shooting.active then
            spawnFxAtOrFallback(CAMP_STAND_POS, "base\\fx\\environment\\pyro\\e_fire_medium.effect")
          end
        end)
        s.fireFxStopHandle = Cron.After(180.0, function()
          stopShootingFireLoop(self)
        end)

        advanceTimeHours(1)
        togglePrefab("$/08phr", "phr2", true)

        s.phase = "camp_face_panamd2"
        s.timer = 0
      end
      return
    end

    s.sampler.lastKey = key
    s.sampler.stableCount = 1
    return
  end

  if s.phase == "camp_face_panamd2" then
    if (not s.panamd2Played) then
      if dist3(ppos, CAMP_STAND_POS) <= CAMP_FACE_RANGE and yawDeltaDeg(pyaw or 0, CAMP_FACE_YAW) <= CAMP_FACE_TOL then
        s.panamd2Played = true
        playVoiceFixed2(self, { "panamd2" })

        clearShootingMarker(self)
        setShootingMarker(self, SHOOT_RETURN_POS)

        s.phase = "return_marker"
        s.timer = 0
      end
    end
    return
  end

  if s.phase == "return_marker" then
    if dist3(ppos, SHOOT_RETURN_POS) <= 8.0 then
      clearShootingMarker(self)

      applyShootingPrefabHides()
      stopShootingFireLoop(self)

      Cron.After(13.0, function()
        sendPhoneFromCategory(self, "Ending")
      end)

      endShootingEventNow(self, "shooting finished")
    end
    return
  end
end)

------------------------------------------------------------
-- AUTOFIX EVENT
------------------------------------------------------------
local AUTO_MAIN_POS   = { x = -722.3613,  y = -988.3361,  z = 8.004082, w = 1 }
local AUTO_STEP2_POS  = { x = -733.80347, y = -1000.25183, z = 8.004082, w = 1 }
local AUTO_VO_POS     = { x = -726.5925,  y = -993.5122,  z = 8.067436, w = 1 }

local AUTO_BUY_POS    = { x = -726.43756, y = -1002.2287, z = 8.004082, w = 1 }
local AUTO_PLACE_POS  = { x = -733.6467,  y = -1000.5615, z = 8.004082, w = 1 }

local AUTO_TRUCK_POS  = { x = -699.3999,  y = -1003.7873, z = 7.3694,  w = 1 }
local AUTO_TRUCK_YAW  = 141.19121

local AUTO_BOUND1_POS = { x = -723.36743, y = -989.6608, z = 8.004082, w = 1 }
local AUTO_BOUND1_TP  = { x = -725.56415, y = -992.5285, z = 8.060707, w = 1 }
local AUTO_BOUND1_ROT = { roll = 0, pitch = 0, yaw = 144.11635 }

local AUTO_BOUND2_POS = { x = -731.5761, y = -1011.8257, z = 8.004082, w = 1 }
local AUTO_BOUND2_TP  = { x = -735.50134, y = -1008.5388, z = 8.004082, w = 1 }
local AUTO_BOUND2_ROT = { roll = 0, pitch = 0, yaw = 49.27644 }

local AUTO_END_TP_POS = { x = -727.1964, y = -995.107, z = 8.004082, w = 1 }
local AUTO_END_TP_ROT = { roll = 0, pitch = 0, yaw = -37.388668 }
local AUTO_LEAVE_RANGE = 100.0
local AUTO_HUD_RETURN_RANGE = 35.0
local endAutofixEventNow

local function getAutofixLeaveRefs(phase)
  if phase == "go_step2_marker" then return { AUTO_STEP2_POS } end
  if phase == "buy_ui" then return { AUTO_BUY_POS } end
  if phase == "place_drink_ui" or phase == "watch_ui" or phase == "performance_ui" then
    return { AUTO_PLACE_POS }
  end
  return nil
end

local function maybeHandleAutofixLeaving(self, ppos)
  local a = self.autofix
  if not a or not a.active then return false end
  local refs = getAutofixLeaveRefs(a.phase)
  if not refs then return false end
  local nearest = nearestDistToRefs(ppos, refs)
  if not nearest then return false end

  -- Early HUD restore band while still in date
  if a.hudReduced then
    if nearest > AUTO_HUD_RETURN_RANGE and nearest <= AUTO_LEAVE_RANGE then
      setHUDAllHidden(false)
      a.hudReduced = false
      a.hudRestoredByLeaving = true
      dbg("[Autofix] HUD restored while moving away from date area")
    end
  elseif a.hudRestoredByLeaving then
    if nearest <= AUTO_HUD_RETURN_RANGE then
      setHUDAllHidden(true)
      a.hudReduced = true
      a.hudRestoredByLeaving = false
      dbg("[Autofix] HUD reduced again after returning to date area")
    end
  end

  if nearest <= AUTO_LEAVE_RANGE then
    return false
  end

  endAutofixEventNow(self, "player left date area")
  scheduleLeavingMessage(self)
  return true
end

local function getSfxVar()
  local ss = Game.GetSettingsSystem()
  if not ss then return nil end
  return ss:GetVar("/audio/volume", "SfxVolume")
end

local function readSfxValue()
  local v = getSfxVar()
  if not v or not v.GetValue then return nil end
  local ok, val = pcall(function() return v:GetValue() end)
  return ok and val or nil
end

local function writeSfxValue(val)
  local v = getSfxVar()
  if not v or not v.SetValue then return end
  pcall(function() v:SetValue(val) end)
end

endAutofixEventNow = function(self, reason)
  local a = self.autofix
  dbg("[Autofix] Ending event: " .. tostring(reason or "unknown"))

  hideHubIfAny(self)
  clearAutofixMarker(self)
  self:clearMeetPanamPins()

  if a.hudReduced then
    setHUDAllHidden(false)
    a.hudReduced = false
  end

  if a.sfxMuted then
    writeSfxValue(a.savedSfx ~= nil and a.savedSfx or 1.0)
    a.sfxMuted = false
  end
  a.savedSfx = nil

  applyAutofixPrefabHides()
  deleteTagged("TMP_AUTOFIX")

  a.active = false
  a.phase = "idle"
  a.timer = 0
  a.uiShown = false
  a.truckSpawned = false
  a.buyDone = false
  a.placedDrink = false
  a.watchStarted = false

  self.currentCategory = nil

  local DFNerveSystem = Game.GetScriptableSystemsContainer():Get("DarkFuture.Needs.DFNerveSystem")
  if DFNerveSystem then
    DFNerveSystem:QueueContextuallyDelayedNeedValueChange(50.0, true)
  end
  Game.GetStatusEffectSystem():ApplyStatusEffect(Game.GetPlayer():GetEntityID(), "HousingStatusEffect.Rested")

  Cron.After(20.0, function()
    if self.runtimeData.inGame and not self.runtimeData.inMenu then
      sendPhoneFromCategory(self, "Ending")
    end
  end)
end

local function maybePlayAutofixVO(self, ppos)
  local a = self.autofix
  if a.voIntroPlayed then return end
  if dist3(ppos, AUTO_VO_POS) > 7.0 then return end

  a.voIntroPlayed = true

  if not a.hudReduced then
    setHUDAllHidden(true)
    a.hudReduced = true
  end

  pcall(function() PlayAudioKey("panamv1") end)
  Cron.After(1.0, function()
    if self.runtimeData.inGame and not self.runtimeData.inMenu and self.autofix and self.autofix.active then
      pcall(function() PlayAudioKey("panamd1") end)
    end
  end)
end

local function enforceAutofixNoExit(self, ppos)
  local a = self.autofix
  if not a.watchStarted then return end

  local d1 = dist3(ppos, AUTO_BOUND1_POS)
  local d2 = dist3(ppos, AUTO_BOUND2_POS)

  if d1 <= 3.0 then
    if not a.perf.lastBound1Teleport or (os.time() - a.perf.lastBound1Teleport) > 2.0 then
      dbg("[Autofix] Boundary 1 triggered! Distance: " .. tostring(d1))
      TeleportPlayerTo(AUTO_BOUND1_TP, AUTO_BOUND1_ROT)
      PushHUDMessage("End the Date first!", 5.0)
      spawnFastTravelGlitchFx()
      a.perf.lastBound1Teleport = os.time()
    end
    return
  end

  if d2 <= 3.0 then
    if not a.perf.lastBound2Teleport or (os.time() - a.perf.lastBound2Teleport) > 2.0 then
      dbg("[Autofix] Boundary 2 triggered! Distance: " .. tostring(d2))
      TeleportPlayerTo(AUTO_BOUND2_TP, AUTO_BOUND2_ROT)
      PushHUDMessage("End the Date first!", 5.0)
      spawnFastTravelGlitchFx()
      a.perf.lastBound2Teleport = os.time()
    end
    return
  end
end

local PERF_WATCH_POSITIONS = {
  { pos = { x = -725.9385, y = -997.5118, z = 8.004082 }, yaw = -123.293625 },
  { pos = { x = -726.4481, y = -1002.23694, z = 8.004082 }, yaw = -37.464134 },
  { pos = { x = -727.3385, y = -995.17175, z = 8.004082 }, yaw = -32.92806 },
  { pos = { x = -735.18445, y = -1008.91144, z = 8.004082 }, yaw = -132.22493 }
}

local function isPlayerAtWatchPosition(ppos, pyaw)
  for _, wpData in ipairs(PERF_WATCH_POSITIONS) do
    local distToPos = dist3(ppos, wpData.pos)
    local yawDelta = yawDeltaDeg(pyaw or 0, wpData.yaw)
    if distToPos <= 1.5 and yawDelta <= 15.0 then
      return true
    end
  end
  return false
end

local function updateAutofixFacingAndPrefabs(self, ppos, pyaw, dt)
  local a = self.autofix
  if not a.watchStarted then return end

  a.perf.audioTimer = (a.perf.audioTimer or 0) + dt
  a.perf.enjoyCooldown = math.max(0, (a.perf.enjoyCooldown or 0) - dt)
  a.perf.lastToggleTime = (a.perf.lastToggleTime or 0) + dt

  local atWatchPos = isPlayerAtWatchPosition(ppos, pyaw)

  if atWatchPos and a.perf.lastToggleTime >= 15.0 then
    local randChoice = math.random(1, 3)
    a.perf.lastToggleChoice = randChoice
    a.perf.lastToggleTime = 0
    
    togglePrefab("$/006pggg", "pggg2", randChoice == 3)
    togglePrefab("$/006pggg", "pggg3", randChoice == 1)
    togglePrefab("$/006pggg", "pggg4", randChoice == 2)
  end

  if a.perf.audioTimer >= a.perf.audioInterval then
    a.perf.audioTimer = 0
    local choice = a.perf.lastToggleChoice or 1
    if choice == 1 then
      pcall(function() PlayAudioKey("panambar2") end)
    elseif choice == 2 then
      pcall(function() PlayAudioKey("panamd4") end)
    else
      pcall(function() PlayAudioKey("panambar1") end)
    end
  end
end

PanamDateSMS.startAutofixEvent = registerFunction("startAutofixEvent", function(self)
  dbg("[EVENT] Autofix")

  togglePrefab("$/02panamgg", "pdg1", false)
  togglePrefab("$/02panamgg", "pdg2", false)
  togglePrefab("$/006pggg", "pggg1", false)
  togglePrefab("$/006pggg", "pggg2", false)
  togglePrefab("$/006pggg", "pggg3", false)
  togglePrefab("$/006pggg", "pggg4", false)
  togglePrefab("$/007pggg", "pggg8", false)
  togglePrefab("$/007pggg", "pggg7", false)
  togglePrefab("$/007pggg", "pggg6", false)
  togglePrefab("$/007pggg", "pggg5", false)

  hideHubIfAny(self)

  local a = self.autofix
  a.active = true
  a.phase = "go_main_marker"
  a.timer = 0
  a.saveLocked = false
  a.uiShown = false
  a.hudReduced = false
  a.hudRestoredByLeaving = false
  a.truckSpawned = false
  a.voIntroPlayed = false
  a.buyDone = false
  a.placedDrink = false
  a.watchStarted = false
  a.savedSfx = nil
  a.sfxMuted = false
  a.pdg2Set = false
  a.perf.audioTimer = 0
  a.perf.enjoyCooldown = 0
  a.perf.lastOpposite = nil
  a.perf.lastToggleTime = 0
  a.perf.lastToggleChoice = nil
  a.perf.lastBound1Teleport = nil
  a.perf.lastBound2Teleport = nil

  a.startGameTime = Game.GetTimeSystem():GetGameTime():GetSeconds()

  togglePrefab("$/006pggg", "pggg1", true)
  togglePrefab("$/007pggg", "pggg7", true)

  deleteTagged("TMP_AUTOFIX")
  spawnTaggedVehicle("Vehicle.v_standard3_thorton_mackinaw_nomad_panam", AUTO_TRUCK_POS, AUTO_TRUCK_YAW, "TMP_AUTOFIX")
  a.truckSpawned = true

  self:clearMeetPanamPins()
  self.pins.quest = registerQuestPinAt(AUTO_MAIN_POS)
  setAutofixMarker(self, AUTO_MAIN_POS)
end)

PanamDateSMS.tickAutofixEvent = registerFunction("tickAutofixEvent", function(self, dt)
  local a = self.autofix
  if not a.active then return end
  if not self.runtimeData.inGame or self.runtimeData.inMenu then return end

  local p = Game.GetPlayer()
  if not p then return end

  local veh = Game['GetMountedVehicle;GameObject'](p)
  if veh and veh:GetRecordID() == "Vehicle.v_standard3_thorton_mackinaw_nomad_panam" then
    local comp = veh:GetVehicleComponent()
    if comp then comp:ToggleVehicleSystems(false, true, true) end
  end

  local ppos = p:GetWorldPosition()
  local pyaw = p:GetWorldOrientation():ToEulerAngles().yaw

  local nowSec = Game.GetTimeSystem():GetGameTime():GetSeconds()
  if a.startGameTime and (nowSec - a.startGameTime) >= (9 * 3600) then
    endAutofixEventNow(self, "timeout")
    self.cooldownDays = math.random(2, 4)
    Cron.After(5.0, function()
      if self.runtimeData.inGame and not self.runtimeData.inMenu then
        sendPhoneFromCategory(self, "waittime")
      end
    end)
    return
  end

  if maybeHandleAutofixLeaving(self, ppos) then
    return
  end

  maybePlayAutofixVO(self, ppos)
  enforceAutofixNoExit(self, ppos)
  updateAutofixFacingAndPrefabs(self, ppos, pyaw, dt)

  if a.phase == "go_main_marker" then
    if dist3(ppos, AUTO_MAIN_POS) <= 8.0 then
      self:clearMeetPanamPins()
      self.pins.quest = registerQuestPinAt(AUTO_STEP2_POS)
      setAutofixMarker(self, AUTO_STEP2_POS)

      sendPhoneFromCategory(self, "Panamdirttext")

      a.phase = "go_step2_marker"
      hideHubIfAny(self)
    end
    return
  end

  if a.phase == "go_step2_marker" then
    if dist3(ppos, AUTO_STEP2_POS) <= 8.0 then
      self:clearMeetPanamPins()
      self.pins.quest = registerQuestPinAt(AUTO_BUY_POS)
      setAutofixMarker(self, AUTO_BUY_POS)

      togglePrefab("$/007pggg", "pggg8", true)

      a.phase = "buy_ui"
      hideHubIfAny(self)
    end
    return
  end

  if a.phase == "buy_ui" then
    local d = dist3(ppos, AUTO_BUY_POS)
    if d <= 2.0 then
      if (not a.uiShown) then
        showOneChoiceUI(self, getUIText("ui_autofix"), getUIText("ui_buy_drinks"), function()
          a.buyDone = true

          pcall(function()
            Game.AddToInventory("Items.money", -50)
            Game.AddToInventory("Items.LowQualityAlcohol1", 1)
          end)

          togglePrefab("$/007pggg", "pggg8", false)
          togglePrefab("$/006pggg", "pggg1", false)
          togglePrefab("$/006pggg", "pggg2", true)

          self:clearMeetPanamPins()
          self.pins.quest = registerQuestPinAt(AUTO_PLACE_POS)
          setAutofixMarker(self, AUTO_PLACE_POS)

          a.phase = "place_drink_ui"
          hideHubIfAny(self)
        end, {
          flagField = "autofix",
          icon = ICON_PAY,
          choiceType = YELLOW_CHOICE_TYPE
        })
      end
    else
      if a.uiShown then hideHubIfAny(self) end
    end
    return
  end

  if a.phase == "place_drink_ui" then
    local d = dist3(ppos, AUTO_PLACE_POS)
    if d <= 2.0 and not a.placedDrink and not a.uiShown then
      a.uiShown = true
      setHUDAllHidden(true)
      showOneChoiceUI(self, getUIText("ui_autofix"), getUIText("ui_place_drink"), function()
        a.placedDrink = true
        togglePrefab("$/007pggg", "pggg6", true)
        pcall(function() PlayAudioKey("panambar1") end)
        Cron.After(2.0, function()
          if self.autofix and self.autofix.active then
            self.autofix.uiShown = false
            self.autofix.phase = "watch_ui"
          end
        end)
      end, {
        flagField = "autofix",
        icon = ICON_DRINK,
        choiceType = YELLOW_CHOICE_TYPE
      })
    elseif d > 2.0 and a.uiShown then
      hideHubIfAny(self)
      a.uiShown = false
    end
    return
  end

  if a.phase == "watch_ui" then
    local d = dist3(ppos, AUTO_PLACE_POS)
    if d <= 2.0 and not a.watchStarted and not a.uiShown then
      a.uiShown = true
      showOneChoiceUI(self, getUIText("ui_autofix"), getUIText("ui_watch_performance"), function()
        if a.savedSfx == nil then
          a.savedSfx = readSfxValue()
        end
        a.sfxMuted = true
        writeSfxValue(0.0)

        a.watchStarted = true

        spawnFastTravelGlitchFx()
        Cron.After(0.5, function()
          spawnFastTravelGlitchFx()
          togglePrefab("$/006pggg", "pggg2", false)
          local randChoice = math.random(1, 3)
          togglePrefab("$/006pggg", "pggg3", randChoice == 1)
          togglePrefab("$/006pggg", "pggg4", randChoice == 2)
          if randChoice == 3 then
            togglePrefab("$/006pggg", "pggg2", true)
          end
          if self.autofix and self.autofix.active then
            self.autofix.perf.lastToggleChoice = randChoice
          end
        end)

        Cron.After(2.0, function()
          togglePrefab("$/02panamgg", "pdg2", true)

          if self.autofix and self.autofix.active then
            self.autofix.uiShown = false
            self.autofix.phase = "performance_ui"
            self.autofix.perf.audioTimer = 0
            self.autofix.perf.lastToggleTime = 0
          end
        end)
      end, {
        flagField = "autofix",
        icon = ICON_PLAY_GUITAR,
        choiceType = YELLOW_CHOICE_TYPE
      })
    elseif d > 2.0 and a.uiShown then
      hideHubIfAny(self)
      a.uiShown = false
    end
    return
  end

  if a.phase == "performance_ui" then
    local d = dist3(ppos, AUTO_PLACE_POS)
    if d <= 2.0 then
      if not a.uiShown then
        a.uiShown = true
        showTwoChoiceUI(
          self,
          getUIText("ui_red_dirt"),
          getUIText("ui_enjoy_performance"),
          function()
            -- no-op, keep enjoying
          end,
          getUIText("ui_end_date"),
          function()
            spawnFastTravelGlitchFx()
            TeleportPlayerTo(AUTO_END_TP_POS, AUTO_END_TP_ROT)
            endAutofixEventNow(self, "manual end")
          end,
          {
            flagField = "autofix",
            icon1 = ICON_PLAY_GUITAR,
            icon2 = ICON_GET_UP,
            choiceType2 = YELLOW_CHOICE_TYPE
          }
        )
      end
    else
      if a.uiShown then
        hideHubIfAny(self)
        a.uiShown = false
      end
    end
    return
  end
end)

------------------------------------------------------------
-- Auto-message cooldown (2-4 days)
------------------------------------------------------------
PanamDateSMS.tickAutoMessages = registerFunction("tickAutoMessages", function(self, dt)
  if not self.active then return end
  if not self.runtimeData.inGame or self.runtimeData.inMenu then return end
  if not self.messenger then return end

  self.lastCheck = (self.lastCheck or 0) + dt
  if self.lastCheck < 5.0 then return end
  self.lastCheck = 0

  local ts = Game.GetTimeSystem()
  if not ts then return end
  local day = ts:GetGameTime():Days()

  if self.initDay == -1 then return end
  local initGate = self.initialCooldownDays or 1
  if (day - self.initDay) < initGate then return end

  local last = self.lastGiftDay or -1
  local cd = self.cooldownDays or 0

  if (last == -1) or (cd > 0 and (day - last) >= cd) then
    self.lastGiftDay = day
    self.cooldownDays = math.random(2, 4)
    self.hasMail = true
    self:sendMessageAndReact()
  end
end)

------------------------------------------------------------
-- Init
------------------------------------------------------------
function PanamDateSMS:new()
  local self = self

  registerForEvent("onInit", function()
    -- Initialize GameSession for HUD/SFX persistence
    if GameSession then
      GameSession.IdentifyAs("PanamDateSMS_preferences")
      GameSession.StoreInDir("sessions")
      GameSession.Persist(LOCAL_PREFERENCES)

      GameSession.OnLoad(function(_)
        -- Restore HUD and SFX preferences on game load
        if next(LOCAL_PREFERENCES.hud) or LOCAL_PREFERENCES.sfx ~= 1.0 then
          hudRestore(LOCAL_PREFERENCES)
          dbg("Restored HUD/SFX preferences from GameSession")
        end
      end)
    end

    hudRepairIfNeeded()

    checkPanamRomance()
    applyPanamPrefabHides()
    applyShootingPrefabHides()
    applyAutofixPrefabHides()

    if ui and ui.init then pcall(function() ui.init() end) end

    ObserveAfter("PlayerPuppet", "OnGameAttached", function()
      ICON_LOOT = getChoiceIconRecord("ChoiceCaptionParts.LootIcon") or ICON_FALLBACK
      ICON_FOOD_VENDOR = getChoiceIconRecord("ChoiceCaptionParts.FoodVendorIcon") or ICON_FALLBACK
      ICON_GUN = getChoiceIconRecord("ChoiceCaptionParts.GunIcon") or ICON_FALLBACK
      ICON_DRAW_WEAPON = getChoiceIconRecord("ChoiceCaptionParts.DrawWeaponIcon") or ICON_FALLBACK
      ICON_SIT = getChoiceIconRecord("ChoiceCaptionParts.Sit") or ICON_FALLBACK
      ICON_SITDOWN = getChoiceIconRecord("ChoiceCaptionParts.SitDown") or ICON_SIT or ICON_FALLBACK
      ICON_PAY = getChoiceIconRecord("ChoiceCaptionParts.PayIcon") or ICON_FALLBACK
      ICON_GET_UP = getChoiceIconRecord("ChoiceCaptionParts.GetUpIcon") or ICON_FALLBACK
      ICON_DRINK = getChoiceIconRecord("ChoiceCaptionParts.DrinkIcon") or ICON_FALLBACK
      ICON_PLAY_GUITAR = getChoiceIconRecord("ChoiceCaptionParts.PlayGuitarIcon") or ICON_FALLBACK
      ICON_GIVE_TAKE = getChoiceIconRecord("ChoiceCaptionParts.GiveTakeIcon") or ICON_FALLBACK
      YELLOW_CHOICE_TYPE = (gameinteractionsChoiceType and gameinteractionsChoiceType.QuestImportant) or nil
      dbg("UI choice icons initialized after PlayerPuppet attached")
    end)

    self.messenger = require("modules/messenger"):new(self)
    self.messenger:setup()

    Observe("RadialWheelController", "OnIsInMenuChanged", function(_, isInMenu)
      self.runtimeData.inMenu = isInMenu
    end)

    GameUI.OnSessionStart(function()
      hudRepairIfNeeded()
      
      -- Capture baseline HUD/SFX if not already captured
      if not next(LOCAL_PREFERENCES.baseline) then
        LOCAL_PREFERENCES.baseline = captureBaselineHUD() or {}
        if LOCAL_PREFERENCES.baseline._sfx then
          LOCAL_PREFERENCES.baselineSfx = LOCAL_PREFERENCES.baseline._sfx
        end
        dbg("Captured baseline HUD/SFX state on game load")
        if GameSession then GameSession.TrySave() end
      else
        -- Restore to baseline on every load
        restoreBaselineHUD(LOCAL_PREFERENCES.baseline)
      end
      
      self.runtimeData.inGame = true
      applyPanamPrefabHides()
      applyShootingPrefabHides()
      applyAutofixPrefabHides()
      self.messenger:ensureContactWhenReady()
    end)

    GameUI.OnSessionEnd(function()
      self.runtimeData.inGame = false
      self:clearMeetPanamPins()
      hideHubIfAny(self)
      clearBeachMarker(self)
      clearShootingMarker(self)
      clearAutofixMarker(self)

      if self.beach and self.beach.hudReduced then
        setHUDMarkersOnlyNoMinimap(false)
        self.beach.hudReduced = false
      end

      if self.shooting and self.shooting.hudReduced then
        setHUDMarkersOnlyNoMinimap(false)
        self.shooting.hudReduced = false
      end

      if self.autofix and self.autofix.hudReduced then
        setHUDAllHidden(false)
        self.autofix.hudReduced = false
      end

      if self.autofix and self.autofix.sfxMuted then
        writeSfxValue(self.autofix.savedSfx ~= nil and self.autofix.savedSfx or 1.0)
        self.autofix.sfxMuted = false
        self.autofix.savedSfx = nil
      end

      if self.shooting then
        stopShootingFireLoop(self)
        restoreQuestTrackerForShooting(self)
      end

      deleteTagged("TMP_BEACH")
      deleteTagged("TMP_AUTOFIX")
      applyAutofixPrefabHides()

      pcall(function() Cron.StopAll() end)
    end)
  end)

  registerForEvent("onUpdate", function(dt)
    if self.runtimeData.inGame and not self.runtimeData.inMenu then
      Cron.Update(dt)
      self:tickAutoMessages(dt)

      if self.currentCategory == "Beach" and self.beach and self.beach.active then
        self:tickBeachEvent(dt)
      end

      if self.currentCategory == "Shootingrange" and self.shooting and self.shooting.active then
        self:tickShootingrangeEvent(dt)
      end

      if self.currentCategory == "Autofix" and self.autofix and self.autofix.active then
        self:tickAutofixEvent(dt)
      end
    end
  end)

  registerForEvent("onDraw", function()
    if ui and ui.update then ui.update() end
  end)

  ----------------------------------------------------------
  -- Hotkeys (debug)
  ----------------------------------------------------------
  registerHotkey("panam_send", "PanamDate: Send Message", function()
    self:sendMessageAndReact()
  end)

  registerHotkey("panam_hud_repair_now", "PanamDate: HUD Repair Now", function()
    hudRepairIfNeeded()
    if self.beach and self.beach.hudReduced then
      setHUDMarkersOnlyNoMinimap(false)
      self.beach.hudReduced = false
    end
    if self.shooting and self.shooting.hudReduced then
      setHUDMarkersOnlyNoMinimap(false)
      self.shooting.hudReduced = false
    end
    if self.autofix and self.autofix.hudReduced then
      setHUDMarkersOnlyNoMinimap(false)
      self.autofix.hudReduced = false
    end
  end)

  return self
end

return PanamDateSMS:new()
