-- Judy Date SMS
-- One-date Judy swim event using the same CET phone and mappin pattern as the Panam version.

local Cron = require("modules/Cron")
local okLang, lang = pcall(require, "modules/lang")

if not okLang or type(lang) ~= "table" then
  print("[JudyDateSMS] ERROR: modules/lang.lua could not be loaded: " .. tostring(lang))
  lang = {
    getText = function(key) return tostring(key or "") end,
    getKey = function() return nil end,
    getRandomFromCategory = function() return "" end
  }
end

local ui
do
  local ok, m = pcall(require, "modules/interactionUI")
  if ok and m then ui = m end
end

local ICON_LOOT = nil
local ICON_GET_UP = nil
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

local function getUIText(key)
  return lang.getText(key) or key
end

local JudyDateSMS = {
  active = false,
  runtimeData = { inGame = false, inMenu = false },
  messenger = nil,
  enabled = false,
  currentCategory = nil,
  initDay = -1,
  lastCheck = 0,
  lastGiftDay = -1,
  cooldownDays = 0,
  initialCooldownDays = 0,
  hasMail = false,
  debug = {
    lastMessageFired = false,
    lastMessageFiredDay = -1
  },
  poll = 0,
  autoPoll = 0,
  pin = nil,
  materialPin = nil,
  materialTarget = nil,
  scavengeUiShown = false,
  scavengeAmbientPlayed = false,
  swimLoopIndex = 1,
  swimLoopTimer = 0,
  phase = "idle",
  phaseTimer = 0,
  dateTimer = 0,
  endSent = false,
  swimEndUiShown = false,
  swimNoUiWarned = false,
  swimEndDone = false,
  yawStep = 0,
  stableTimer = 0,
  lastPosKey = nil,
  lastYawKey = nil,
  lastYawValue = nil,
  yawPollTimer = 0,
  sleepTimer = 0,
  settings = {
    requireJudyRomance = true,
    pollInterval = 0.5,
    swimPollInterval = 2.0,
    guitarPollInterval = 1.0,
    climbPollInterval = 1.0,
    updateInterval = 1.0,
    swimYawPollInterval = 2.0,
    yawTolerance = 25.0,
    oppositeYawTolerance = 65.0,
    swimLoopDuration = 30.0
  }
}

-- CET can run without _G, so keep JudyDateSMS local and return it at the end.

local NODE = "$/02/judydate1"
local VARIANTS = { "judys1", "judys2", "judys3", "judys4", "judys5", "judys6", "judysmoke", "judysleep" }
local ALWAYS_ON_VARIANTS = { "water2", "judycamp1" }
local VARIANT_STATE = {}
local SUPPRESS_SWIM_FX = false
local SUPPRESS_SWIM_SPLASH = false
local spawnBlinkFx

local POS = {
  meetSurface = { x = -978.98211669922, y = 1505.9338378906, z = 0.13393402099609, w = 1, yaw = -117.1353225708 },
  underwaterIcon1 = { x = -962.39599609375, y = 1492.4434814453, z = -1.1417007446289, w = 1, yaw = -124.9849395752 },
  underwaterTrigger1 = { x = -972.47863769531, y = 1499.4877929688, z = -1.0124893188477, w = 1, yaw = -120.0290145874 },
  cuteIcon = { x = -960.48706054688, y = 1490.3131103516, z = -4.5981063842773, w = 1, yaw = -147.99446105957 },
  swimIcon2 = { x = -954.60504150391, y = 1495.0065917969, z = -4.9304504394531, w = 1, yaw = -69.221542358398 },
  surfaceSmokeIcon = { x = -977.36492919922, y = 1505.4365234375, z = 0.13393402099609, w = 1, yaw = 72.704498291016 },
  surfaceSmokeTrigger = { x = -971.96362304688, y = 1503.6359863281, z = 0.066581726074219, w = 1, yaw = 72.072845458984 },
  sleepIcon = { x = -982.67071533203, y = 1499.1799316406, z = 0.13182067871094, w = 1, yaw = 115.9052734375 },
  restIcon = { x = -977.86901855469, y = 1504.7243652344, z = 0.13393402099609, w = 1, yaw = -82.319747924805 },
  scavengeExitTrigger = { x = -976.18627929688, y = 1505.0941162109, z = 0.13393402099609, w = 1, yaw = 67.799598693848 }
}

local SCAVENGE_POINTS = {
  { x = -952.24609375, y = 1494.0871582031, z = -5.8173751831055, w = 1, yaw = 40.937084197998 },
  { x = -949.47259521484, y = 1496.4975585938, z = -5.724609375, w = 1, yaw = 32.085186004639 },
  { x = -951.26293945313, y = 1497.2830810547, z = -4.6664962768555, w = 1, yaw = 111.96125030518 }
}


local SWIM_LOOP_STAGES = {
  { variant = "judys4", visibleYaw = -166.69287109375 },
  { variant = "judys5", visibleYaw = 69.429054260254 },
  { variant = "judys6", visibleYaw = 16.421215057373 }
}

local function dbg(msg)
  print("[JudyDateSMS] " .. tostring(msg))
end

local AUDIO_SUBTITLE_GATE_FILE = "dedera2253333335431.json"
local AUDIO_SUBTITLE_GATE_ID = "ra_mod_3256744342"
local audioSubtitleGateWarned = false

local function getScriptDirectory()
  if not (debug and debug.getinfo) then return nil end
  local ok, info = pcall(function() return debug.getinfo(1, "S") end)
  if not ok or not info or type(info.source) ~= "string" then return nil end
  local source = info.source
  if source:sub(1, 1) == "@" then source = source:sub(2) end
  return source:match("^(.*)[/\\][^/\\]+$")
end

local function readFile(path)
  if not path or path == "" then return nil end
  local f = io.open(path, "rb")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

local function canPlayVoiceAndSubtitles()
  local scriptDir = getScriptDirectory()
  local candidates = {}

  if scriptDir then
    table.insert(candidates, scriptDir .. "\\ra\\" .. AUDIO_SUBTITLE_GATE_FILE)
    table.insert(candidates, scriptDir .. "/ra/" .. AUDIO_SUBTITLE_GATE_FILE)
  end

  table.insert(candidates, "cyber_engine_tweaks\\mods\\Dedrajudygoonadate\\ra\\" .. AUDIO_SUBTITLE_GATE_FILE)
  table.insert(candidates, "cyber_engine_tweaks/mods/Dedrajudygoonadate/ra/" .. AUDIO_SUBTITLE_GATE_FILE)
  table.insert(candidates, "ra\\" .. AUDIO_SUBTITLE_GATE_FILE)
  table.insert(candidates, "ra/" .. AUDIO_SUBTITLE_GATE_FILE)

  for _, path in ipairs(candidates) do
    local content = readFile(path)
    if content and content:match('"id"%s*:%s*"' .. AUDIO_SUBTITLE_GATE_ID .. '"') then
      audioSubtitleGateWarned = false
      return true
    end
  end

  if not audioSubtitleGateWarned then
    dbg("Audio and subtitles disabled: missing or invalid ra/" .. AUDIO_SUBTITLE_GATE_FILE)
    audioSubtitleGateWarned = true
  end
  return false
end

local function factGet(key)
  local qs = Game.GetQuestsSystem()
  if not qs then return 0 end
  return tonumber((qs:GetFactStr(key) or "0")) or 0
end

local function factSet(key, val)
  local qs = Game.GetQuestsSystem()
  if not qs then return end
  qs:SetFactStr(key, tonumber(val) or 0)
end

local function ToVector4(tbl)
  return Vector4.new(tbl.x, tbl.y, tbl.z, tbl.w or 1)
end

local function dist3(a, b)
  local dx, dy, dz = (a.x - b.x), (a.y - b.y), (a.z - b.z)
  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function round1(x)
  return math.floor((x or 0) * 10 + 0.5) / 10
end

local function posKey(p)
  return tostring(round1(p.x)) .. "|" .. tostring(round1(p.y)) .. "|" .. tostring(round1(p.z))
end

local function yawKey(y)
  return tostring(round1(y or 0))
end

local function yawDeltaDeg(a, b)
  local d = (a - b) % 360
  if d > 180 then d = 360 - d end
  return math.abs(d)
end

local function getPlayer()
  return Game.GetPlayer()
end

local function getPlayerPos()
  local p = getPlayer()
  if not p then return nil end
  return p:GetWorldPosition()
end

local function getPlayerYaw()
  local p = getPlayer()
  if not p then return 0 end
  local ok, ang = pcall(function() return p:GetWorldOrientation():ToEulerAngles() end)
  if ok and ang then return ang.yaw or 0 end
  return 0
end

local function inRange(posTbl, range)
  local p = getPlayerPos()
  if not p then return false end
  return dist3(p, posTbl) <= (range or 4.0)
end

local function playerFacing(yaw, tolerance)
  return yawDeltaDeg(getPlayerYaw(), yaw) <= (tolerance or JudyDateSMS.settings.yawTolerance)
end

local function oppositeYaw(yaw)
  local y = ((yaw or 0) + 180.0) % 360.0
  if y > 180.0 then y = y - 360.0 end
  return y
end

local function resetSwimYawPoll(self)
  self.yawPollTimer = 0
  self.lastYawValue = getPlayerYaw()
end

local function readySwimYawPoll(self)
  local step = self.currentTickStep or self.settings.swimPollInterval or self.settings.pollInterval or 0.5
  self.yawPollTimer = (self.yawPollTimer or 0) + step
  if self.yawPollTimer < (self.settings.swimYawPollInterval or 2.0) then return false end
  self.yawPollTimer = 0
  return true
end

local function yawMovedSinceStored(self, minDelta)
  local currentYaw = getPlayerYaw()
  local oldYaw = self.lastYawValue
  if oldYaw == nil then
    self.lastYawValue = currentYaw
    return false
  end
  if yawDeltaDeg(currentYaw, oldYaw) >= (minDelta or 20.0) then
    self.lastYawValue = currentYaw
    return true
  end
  return false
end

local function pushHUD(text, duration)
  pcall(function()
    local msg = SimpleScreenMessage.new()
    local bbs = Game.GetBlackboardSystem()
    local defs = GetAllBlackboardDefs()
    local note = bbs:Get(defs.UI_Notifications)
    msg.message = text
    msg.isShown = true
    msg.duration = duration or 2.0
    note:SetVariant(defs.UI_Notifications.OnscreenMessage, ToVariant(msg), true)
  end)
end



local spawnWaterSplashAt

local function countLetter(text)
  if type(text) ~= "string" then return 0 end
  return string.len(text)
end

local function calcTimebyLetter(count, perLetter)
  count = count or 0
  perLetter = perLetter or (1 / 5)
  local t = count * perLetter
  if t < 4 then t = 4 end
  return t
end

function DialogLine(line, speaker, forcedDuration)
  if not canPlayVoiceAndSubtitles() then return false end
  local ok, err = pcall(function()
    local inkSystem = Game.GetInkSystem()
    if not inkSystem then return end
    local layers = inkSystem:GetLayers()

    local GameController = {}
    for i, layer in ipairs(layers) do
      for j, controller in ipairs(layer:GetGameControllers()) do
        if NameToString(controller:GetClassName()) == "SubtitlesGameController" then
          GameController["SubtitlesGameController"] = controller
        end
      end
    end

    if GameController["SubtitlesGameController"] ~= nil then
      local dialogLine = scnDialogLineData.new()
      local id = math.random(1, 9999)
      local perLetter = 1 / 9

      dialogLine.id = CRUID(id)
      dialogLine.text = line
      dialogLine.type = 1
      dialogLine.speaker = Game.GetPlayer()
      dialogLine.speakerName = speaker or "Judy"
      dialogLine.isPersistent = false
      dialogLine.duration = forcedDuration or math.ceil(calcTimebyLetter(countLetter(dialogLine.text), perLetter))

      local canShow = true
      local settings = Game.GetSettingsSystem()
      if settings then
        local var = settings:GetVar("/accessibility/subtitles", "Cinematic")
        if var and var.GetValue then canShow = var:GetValue() == true end
      end

      if canShow then
        GameController["SubtitlesGameController"]:SpawnDialogLine(dialogLine)
      end

      Cron.After(dialogLine.duration, function()
        if GameController["SubtitlesGameController"] ~= nil then
          GameController["SubtitlesGameController"]:Cleanup()
          GameController["SubtitlesGameController"]:Cleanup()
        end
      end)
    end
  end)
  if not ok then dbg("DialogLine failed: " .. tostring(err)) end
end

local function PlayAudioKey(key)
  if not canPlayVoiceAndSubtitles() then return false end
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

  return true
end

local function isPlayerFemaleVoice()
  local p = getPlayer()
  if not p then return false end

  local samples = {}
  local function addSample(v)
    if v ~= nil then table.insert(samples, tostring(v)) end
  end

  pcall(function() addSample(p:GetResolvedGenderName()) end)
  pcall(function() addSample(p:GetResolvedGender()) end)
  pcall(function() addSample(p:GetGender()) end)
  pcall(function()
    local rec = p:GetRecord()
    if rec and rec.Gender then addSample(rec:Gender()) end
  end)

  for _, raw in ipairs(samples) do
    local s = string.lower(raw or "")
    if string.find(s, "female", 1, true) or string.find(s, "woman", 1, true) or s == "f" then
      return true
    end
  end

  return false
end

local function getVGenderedAudioKey(baseKey)
  if isPlayerFemaleVoice() then
    return tostring(baseKey) .. "f"
  end
  return tostring(baseKey) .. "m"
end

local function playClimbIntroVoiceSequence(self)
  local c = self and self.climb
  if not c or c.introVoiceStarted then return end
  c.introVoiceStarted = true

  PlayAudioKey(getVGenderedAudioKey("climbv1"))
  DialogLine("Hey Judy", "V", 3)

  Cron.After(2.0, function()
    if not (JudyDateSMS and JudyDateSMS.climb and JudyDateSMS.climb.active) then return end
    if not (JudyDateSMS.runtimeData and JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu) then return end
    PlayAudioKey("climbjudy1")
    DialogLine("V! Lookin' Good", "Judy", 3)
  end)
end

local function playClimbFinalVoiceSequence(self)
  local c = self and self.climb
  if not c or c.finalVoiceStarted then return end
  c.finalVoiceStarted = true

  PlayAudioKey("judyclimb2")
  DialogLine("And here we are... Pickin' up very chill vibes.", "Judy", 4)

  Cron.After(5.5, function()
    if not (JudyDateSMS and JudyDateSMS.climb and JudyDateSMS.climb.active) then return end
    if not (JudyDateSMS.runtimeData and JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu) then return end
    PlayAudioKey(getVGenderedAudioKey("climbv"))
    DialogLine("Well, I be damned", "V", 3)
  end)
end

local function playScavengeAmbientLineOnce(self)
  if self.scavengeAmbientPlayed then return end
  self.scavengeAmbientPlayed = true

  if isPlayerFemaleVoice() then
    PlayAudioKey("Vswimfem")
  else
    PlayAudioKey("Vswimmasc")
  end
  DialogLine("We lookin' for anything in particular here?", "V", 2)

  Cron.After(2.2, function()
    if not (JudyDateSMS and JudyDateSMS.currentDateKind == "swim" and JudyDateSMS.phase == "swim_scavenge_loop") then return end
    if not (JudyDateSMS.runtimeData and JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu) then return end
    PlayAudioKey("judyo2")
    DialogLine("Nah. Can't hurt to look around, though.", "Judy", 5)
  end)
end

local function spawnHeavyFrontSplashBurst(count)
  count = count or 18
  local p = getPlayer()
  if not p then return end
  local ppos = p:GetWorldPosition()
  local fwd = p:GetWorldForward()
  local sideX = -(fwd.y or 0)
  local sideY = (fwd.x or 0)
  for i = 1, count do
    local forwardBias = 0.55 + (math.random() * 2.8)
    local sideBias = (math.random() * 3.2) - 1.6
    local height = 0.02 + (math.random() * 0.55)
    local pos = {
      x = ppos.x + (fwd.x * forwardBias) + (sideX * sideBias),
      y = ppos.y + (fwd.y * forwardBias) + (sideY * sideBias),
      z = ppos.z + height,
      w = 1
    }
    spawnWaterSplashAt(pos)
  end
end

local giveRandomMaterial

local function hideScavengeUI(self)
  if ui and self.scavengeUiShown and ui.hideHub then
    pcall(function() ui.hideHub() end)
  end
  self.scavengeUiShown = false
end

local function showScavengeUI(self)
  if self.scavengeUiShown then return end

  if not (ui and ui.createHub and ui.createChoice and ui.registerChoiceCallback and ui.clearCallbacks and ui.setupHub and ui.showHub) then
    return
  end

  ui.clearCallbacks()
  local choices = {
    ui.createChoice(getUIText("ui_scavenge_material"), ICON_LOOT or ICON_FALLBACK, YELLOW_CHOICE_TYPE)
  }

  ui.registerChoiceCallback(1, function()
    hideScavengeUI(self)
    giveRandomMaterial()
    self:setMaterialPin()
  end)

  local hub = ui.createHub(getUIText("ui_judy_swim"), choices)
  ui.setupHub(hub)
  ui.showHub()
  self.scavengeUiShown = true
end

local SWIM_SPLASH_EFFECT = "base\\fx\\characters\\common\\water_impact\\water_splash_npc.effect"
local SWIM_SPLASH_SMALL_BURST = 3
local SWIM_SPLASH_HEAVY_BURST = 18

local function isSwimVariant(variant)
  return variant == "judys1" or variant == "judys2" or variant == "judys3" or variant == "judys4" or variant == "judys5" or variant == "judys6"
end

local function swimSplashBaseForVariant(variant)
  if variant == "judys1" then return POS.underwaterTrigger1 end
  if variant == "judys2" then return POS.cuteIcon end
  if variant == "judys3" then return POS.swimIcon2 end
  if variant == "judys4" then return SCAVENGE_POINTS[1] or POS.swimIcon2 end
  if variant == "judys5" then return SCAVENGE_POINTS[2] or POS.swimIcon2 end
  if variant == "judys6" then return SCAVENGE_POINTS[3] or POS.swimIcon2 end
  return POS.swimIcon2
end

local function randomAround(base, radiusXY, radiusZ)
  radiusXY = radiusXY or 1.15
  radiusZ = radiusZ or 0.18
  return {
    x = base.x + ((math.random() * 2.0 - 1.0) * radiusXY),
    y = base.y + ((math.random() * 2.0 - 1.0) * radiusXY),
    z = base.z + ((math.random() * 2.0 - 1.0) * radiusZ),
    w = 1
  }
end

spawnWaterSplashAt = function(pos)
  local p = getPlayer()
  local fx = Game.GetFxSystem()
  if not fx or not pos then return false end

  local res = gameFxResource.new({ effect = SWIM_SPLASH_EFFECT })
  local spawned = false

  -- Primary path: same style as the working blink command, but placed at the requested Judy swim XYZ.
  local ok1, err1 = pcall(function()
    local t = WorldTransform.new()
    if p and p.GetWorldOrientation then
      t:SetOrientation(p:GetWorldOrientation())
    end
    t:SetPosition(Vector4.new(pos.x, pos.y, pos.z, 1))
    fx:SpawnEffect(res, t)
    spawned = true
  end)

  -- Fallback for runtimes where WorldTransform behaves differently.
  if not spawned then
    local ok2, err2 = pcall(function()
      local t = Transform.new()
      if t.SetPosition then t:SetPosition(Vector4.new(pos.x, pos.y, pos.z, 1)) end
      fx:SpawnEffect(res, t)
      spawned = true
    end)
    if not ok2 then
      print("[JudyDateSMS] NPC splash Transform fallback failed: " .. tostring(err2))
    end
  end

  -- Last fallback so the player still sees the NPC splash instead of seeing no FX at all.
  if not spawned and p then
    local ok3, err3 = pcall(function()
      fx:SpawnEffect(res, p:GetWorldTransform())
      spawned = true
    end)
    if not ok3 then
      print("[JudyDateSMS] NPC splash player fallback failed: " .. tostring(err3))
    end
  end

  if not ok1 then
    print("[JudyDateSMS] NPC splash WorldTransform failed: " .. tostring(err1))
  end

  return spawned
end

local function playerFrontSplashPos(distance, height, sideOffset)
  local p = getPlayer()
  if not p then return nil end
  local pos = p:GetWorldPosition()
  local fwd = p:GetWorldForward()
  local sideX = -(fwd.y or 0)
  local sideY = (fwd.x or 0)
  distance = distance or 1.65
  height = height or 0.25
  sideOffset = sideOffset or 0.0
  return {
    x = pos.x + (fwd.x * distance) + (sideX * sideOffset),
    y = pos.y + (fwd.y * distance) + (sideY * sideOffset),
    z = pos.z + height,
    w = 1
  }
end

local function playerAroundSplashPos(radius, height)
  local p = getPlayer()
  if not p then return nil end
  local pos = p:GetWorldPosition()
  local ang = math.random() * 6.28318530718
  local r = radius or (0.85 + math.random() * 0.75)
  return {
    x = pos.x + math.cos(ang) * r,
    y = pos.y + math.sin(ang) * r,
    z = pos.z + (height or 0.15),
    w = 1
  }
end

local function spawnWaterSplashForSwim(variant)
  local base = swimSplashBaseForVariant(variant)
  local any = false

  -- Swim 1 must only splash at the icon/Judy position. Do not spawn front/around-player FX here.
  if variant == "judys1" then
    if base then
      for i = 1, SWIM_SPLASH_SMALL_BURST do
        local pos = randomAround(base, 0.65, 0.14)
        any = spawnWaterSplashAt(pos) or any
      end
      print("[JudyDateSMS] NPC splash x" .. tostring(SWIM_SPLASH_SMALL_BURST) .. " at icon for judys1")
    end
    return any
  end

  -- After swim 1, each ON/OFF swim toggle gets a heavier burst around the player.
  -- Six different nearby XYZ positions are used so the swap feels hidden by water movement.
  local p = getPlayer()
  if p then
    local ppos = p:GetWorldPosition()
    local fwd = p:GetWorldForward()
    local sideX = -(fwd.y or 0)
    local sideY = (fwd.x or 0)

    for i = 1, SWIM_SPLASH_HEAVY_BURST do
      local angle = (math.random() * 6.28318530718)
      local radius = 0.2 + (math.random() * 1.3)
      local forwardBias = 0.35 + (math.random() * 2.9)
      local sideBias = (math.random() * 3.4) - 1.7
      local height = 0.02 + (math.random() * 0.55)

      local pos = {
        x = ppos.x + math.cos(angle) * radius + (fwd.x * forwardBias) + (sideX * sideBias),
        y = ppos.y + math.sin(angle) * radius + (fwd.y * forwardBias) + (sideY * sideBias),
        z = ppos.z + height,
        w = 1
      }
      any = spawnWaterSplashAt(pos) or any
    end

    print("[JudyDateSMS] NPC splash burst x" .. tostring(SWIM_SPLASH_HEAVY_BURST) .. " near/front of player for " .. tostring(variant))
  elseif base then
    -- Fallback if player is unavailable.
    for i = 1, SWIM_SPLASH_HEAVY_BURST do
      any = spawnWaterSplashAt(randomAround(base, 2.1, 0.34)) or any
    end
    print("[JudyDateSMS] NPC splash burst x" .. tostring(SWIM_SPLASH_HEAVY_BURST) .. " at Judy fallback for " .. tostring(variant))
  end

  return any
end

local function spawnSwimTransitionFx(variant)
  -- Same transition moment: splash and blink are fired together before the prefab changes.
  local splashOk = false
  if not SUPPRESS_SWIM_SPLASH then
    splashOk = spawnWaterSplashForSwim(variant)
  end
  if spawnBlinkFx then spawnBlinkFx() end
  if splashOk then
    print("[JudyDateSMS] Played NPC water splash and blink together for " .. tostring(variant))
  elseif SUPPRESS_SWIM_SPLASH then
    print("[JudyDateSMS] Splash suppressed, blink only for " .. tostring(variant))
  end
end

local function toggleVariant(variant, state)
  local ws = Game.GetWorldStateSystem()
  if not ws or not CreateNodeRef then return end

  -- Do not gate this behind active/date state. If swim 1-6 is toggled manually or by a reset/start path,
  -- the requested NPC splash must still play before the visible swap.
  local shouldFx = isSwimVariant(variant) and not SUPPRESS_SWIM_FX

  if shouldFx then
    spawnSwimTransitionFx(variant)
  end

  pcall(function()
    ws:TogglePrefabVariant(CreateNodeRef(NODE), variant, state)
  end)
  VARIANT_STATE[variant] = state
end

local function enableSwimBaseVariants()
  pcall(function()
    Game.GetWorldStateSystem():TogglePrefabVariant(CreateNodeRef("$/02/judydate1"), "judycamp1", true)
    Game.GetWorldStateSystem():TogglePrefabVariant(CreateNodeRef("$/02/judydate1"), "water2", true)
  end)
end

local function ensureAlwaysOnVariants()
  -- Kept for compatibility with older calls. Date prefabs stay false on load.
  -- The swim base variants are enabled only when the swim date starts.
  if JudyDateSMS and JudyDateSMS.active and JudyDateSMS.currentDateKind == "swim" then
    enableSwimBaseVariants()
  end
end

local function ensureAlwaysOnOnLoadBurst()
  -- WorldState may not be ready at raw Lua load, so repeat briefly after init/attach.
  ensureAlwaysOnVariants()
  if Cron and Cron.After then
    Cron.After(0.5, function() ensureAlwaysOnVariants() end)
    Cron.After(1.5, function() ensureAlwaysOnVariants() end)
    Cron.After(3.0, function() ensureAlwaysOnVariants() end)
    Cron.After(6.0, function() ensureAlwaysOnVariants() end)
  end
end

local function falseAllVariants()
  local oldSuppress = SUPPRESS_SWIM_FX
  SUPPRESS_SWIM_FX = true
  for _, v in ipairs(VARIANTS) do toggleVariant(v, false) end
  pcall(function()
    Game.GetWorldStateSystem():TogglePrefabVariant(CreateNodeRef("$/02/judydate1"), "judycamp1", false)
    Game.GetWorldStateSystem():TogglePrefabVariant(CreateNodeRef("$/02/judydate1"), "water2", false)
  end)
  SUPPRESS_SWIM_FX = oldSuppress
end

local function setOnlyVariant(variant)
  for _, v in ipairs({ "judys4", "judys5", "judys6" }) do toggleVariant(v, false) end
  if variant then toggleVariant(variant, true) end
end

function spawnBlinkFx()
  local p = getPlayer()
  if not p then return end
  pcall(function()
    local pos = p:GetWorldPosition()
    local fwd = p:GetWorldForward()
    local t = WorldTransform.new()
    t:SetOrientation(p:GetWorldOrientation())
    t:SetPosition(Vector4.new(pos.x + fwd.x * 2, pos.y + fwd.y * 2, pos.z + 1, 1))
    Game.GetFxSystem():SpawnEffect(gameFxResource.new({ effect = "base\\fx\\player\\p_eyes_blinking\\p_eyes_blinking.effect" }), t)
  end)
end

local function spawnGlitchFx()
  local p = getPlayer()
  if not p then return end
  pcall(function()
    Game.GetFxSystem():SpawnEffect(gameFxResource.new({ effect = "base\\fx\\camera\\fast_travel_glitch\\fast_travel_glitch.effect" }), p:GetWorldTransform())
  end)
end

local function advanceTimeHours(hours)
  local ts = Game.GetTimeSystem()
  if not ts then return end
  local seconds = (hours or 0) * 3600
  local ok = pcall(function() ts:ChangeGameTimeBySeconds(seconds) end)
  if not ok then
    local gt = ts:GetGameTime()
    if gt and gt.Days and gt.Hours and gt.Minutes then
      local total = gt:Days() * 86400 + gt:Hours() * 3600 + gt:Minutes() * 60
      pcall(function() ts:SetGameTimeBySeconds(total + seconds) end)
    end
  end
end


local function applyDateEndEffects()
  local p = getPlayer()
  if p then
    pcall(function()
      StatusEffectHelper.ApplyStatusEffect(p, TweakDBID.new("BaseStatusEffect.SatisfiedBuff"), TweakDBID.new(0x00000000, 0))
    end)
  end

  pcall(function()
    local container = Game.GetScriptableSystemsContainer()
    local DFNerveSystem = container and container:Get("DarkFuture.Needs.DFNerveSystem")
    if DFNerveSystem then
      DFNerveSystem:QueueContextuallyDelayedNeedValueChange(50.0, true)
    end
  end)
end

local function registerPin(posTbl, caption)
  local ms = Game.GetMappinSystem()
  if not ms then return nil end
  local md = MappinData.new()
  md.mappinType = TweakDBID.new("Mappins.DefaultStaticMappin")
  md.variant = Enum.new("gamedataMappinVariant", "DefaultQuestVariant")
  md.visibleThroughWalls = true
  md.debugCaption = caption or lang.getText("ui_meet_judy_caption")
  return ms:RegisterMappin(md, ToVector4(posTbl))
end

local function unregisterPin(id)
  local ms = Game.GetMappinSystem()
  if not ms or not id then return end
  pcall(function() ms:UnregisterMappin(id) end)
end

function JudyDateSMS:clearPin()
  if self.pin then unregisterPin(self.pin) end
  self.pin = nil
end

function JudyDateSMS:setPin(posTbl, caption)
  self:clearPin()
  self.pin = registerPin(posTbl, caption)
end

function JudyDateSMS:clearMaterialPin()
  hideScavengeUI(self)
  if self.materialPin then unregisterPin(self.materialPin) end
  self.materialPin = nil
  self.materialTarget = nil
end

function JudyDateSMS:setMaterialPin()
  -- Scavenging was removed from the swim date.
  -- Keep this as a no-op for compatibility with older call sites.
  self:clearMaterialPin()
end

giveRandomMaterial = function()
  -- Scavenging rewards were removed from the swim date.
  return
end

local function checkJudyRomanced()
  if not JudyDateSMS.settings.requireJudyRomance then return true end
  return factGet("sq030_judy_lover") == 1
end

local GUITAR_SPAWN_TAG = "MySpawnedCar"

local function getMountedVehicle()
  local p = getPlayer()
  if not p then return nil end
  local ok, v = pcall(function()
    return Game["GetMountedVehicle;GameObject"](p)
  end)
  if ok then return v end
  return nil
end

local function getMountedVehicleEntityId()
  local v = getMountedVehicle()
  if not v then return nil end
  local ok, id = pcall(function() return v:GetEntityID() end)
  if ok then return id end
  return nil
end

local function idsEqual(a, b)
  if a == nil or b == nil then return false end
  return tostring(a) == tostring(b)
end

local function applyMountedVehicleSystemsOff()
  local v = getMountedVehicle()
  if not v then return false end
  local ok = pcall(function()
    local vc = v:GetVehicleComponent()
    if vc and vc.ToggleVehicleSystems then
      vc:ToggleVehicleSystems(false, true, true)
    end
  end)
  return ok
end

local function isMountedSpecificVehicle(recordPath)
  local v = getMountedVehicle()
  if not v then return false end

  local ok, rid = pcall(function()
    return v:GetRecordID()
  end)
  if not ok or not rid then return false end

  local target = TweakDBID.new(recordPath)
  if target then
    if tostring(rid) == tostring(target) then return true end
  end

  local s = tostring(rid)
  return s and string.find(s, recordPath, 1, true) ~= nil
end

local function getOrientationFromYaw(yaw)
  if yaw ~= nil and EulerAngles and EulerAngles.new then
    local ok, q = pcall(function()
      local ea = EulerAngles.new(0, 0, yaw)
      if ea and ea.ToQuat then return ea:ToQuat() end
      return nil
    end)
    if ok and q then return q end
  end
  local p = getPlayer()
  if p then
    local ok, ori = pcall(function() return p:GetWorldOrientation() end)
    if ok and ori then return ori end
  end
  return nil
end

local function despawnTaggedVehicle(tag)
  local des = Game.GetDynamicEntitySystem()
  if not des then return end
  if des.DespawnTagged then
    pcall(function() des:DespawnTagged(CName.new(tag)) end)
  elseif des.DeleteTagged then
    pcall(function() des:DeleteTagged(CName.new(tag)) end)
  end
end

local function spawnTaggedVehicle(recordId, posTbl, tag, yaw)
  local des = Game.GetDynamicEntitySystem()
  if not des or not posTbl then return nil end

  local spec = NewObject("DynamicEntitySpec")
  if not spec then return nil end

  spec.recordID = TweakDBID.new(recordId)
  spec.position = Vector4.new(posTbl.x, posTbl.y, posTbl.z, posTbl.w or 1)
  spec.orientation = getOrientationFromYaw(yaw or posTbl.yaw)
  spec.persistState = false
  spec.persistSpawn = false
  spec.spawnInView = true
  spec.active = true

  if tag then
    pcall(function() spec.tag = CName.new(tag) end)
    pcall(function() spec.entityTag = CName.new(tag) end)
    pcall(function() spec.tags = { CName.new(tag) } end)
  end

  local spawnedId = nil
  local ok, err = pcall(function()
    spawnedId = des:CreateEntity(spec)
  end)
  if not ok then
    dbg("Vehicle spawn failed for " .. tostring(recordId) .. ": " .. tostring(err))
  end
  return spawnedId
end


------------------------------------------------------------
-- Shared date timeout helpers and Northside guitar date
------------------------------------------------------------
local FIVE_IN_GAME_HOURS = 5 * 3600
local GUITAR_NODE = "$/02/judyguitar"
local GUITAR_VARIANTS = {
  "jstuff", "jphone", "ritacar", "lizdrink", "jcheer", "lizcheer",
  "ritaguitar", "ritacheer", "jcar", "lizsmoke"
}

local CLIMB_NODE = "$/02/judyclimb2"
local CLIMB_VARIANTS = {
  "judystuff34", "judysmoke22", "judysitt2", "judystand22", "judymm"
}

JudyDateSMS.currentDateKind = nil
JudyDateSMS.dateStartGameSeconds = nil
JudyDateSMS.pendingMissed = { active = false, dueGameSeconds = 0 }
JudyDateSMS.guitar = {
  active = false,
  phase = "idle",
  phaseTimer = 0,
  poll = 0,
  rideGatePoll = 0,
  mountedTypePoll = 0,
  startGameSeconds = nil,
  arrived = false,
  phoneAudioPlayed = false,
  ritaAudioPlayed = false,
  ritaCallSent = false,
  rideMessageSent = false,
  rideStarted = false,
  comeUpSent = false,
  cigarPlayed = false,
  finalWatchStarted = false,
  finalSampleTimer = 0,
  finalLastKey = nil,
  finalStable = false,
  endUiShown = false,
  noUiWarned = false,
  endDone = false,
  spawnedVehicleId = nil,
  postCarMonitorActive = false,
  postCarMonitorPoll = 0
}

JudyDateSMS.climb = {
  active = false,
  phase = "idle",
  phaseTimer = 0,
  poll = 0,
  startGameSeconds = nil,
  arrived = false,
  comeUpSent = false,
  firstTopReached = false,
  judyHerePlayed = false,
  climbUpSent = false,
  finalLinePlayed = false,
  hummingPlayed = false,
  introVoiceStarted = false,
  finalVoiceStarted = false,
  endUiShown = false,
  noUiWarned = false,
  endDone = false
}

local POS_GUITAR = {
  firstMapIcon = { x = -670.30023193359, y = 3043.3425292969, z = 26.917434692383, w = 1, yaw = -30.354776382446 },
  phoneAudio = { x = -663.09033203125, y = 3029.0270996094, z = 26.355491638184, w = 1, yaw = -152.60049438477 },
  ritaCarAudio = { x = -664.80053710938, y = 3035.0864257813, z = 26.312057495117, w = 1, yaw = -84.304397583008 },
  rideVehicleControl = { x = -663.017578125, y = 3034.8149414063, z = 27.576950073242, w = 1, yaw = -57.115009307861 },
  forcedSpawnCar = { x = -675.44738769531, y = 3091.697265625, z = 7.6358795166016, w = 1, yaw = -124.52033996582 },
  downstairsIcon = { x = -674.12243652344, y = 3086.0178222656, z = 7.2480392456055, w = 1, yaw = -41.32067489624 },
  earlyComeUp = { x = -672.4833984375, y = 3040.3171386719, z = 26.075271606445, w = 1, yaw = -58.736972808838 },
  comeUpIcon = { x = -670.53723144531, y = 3044.7734375, z = 26.223503112793, w = 1, yaw = 87.873992919922 },
  finalExact = { x = -671.19604492188, y = 3044.6911621094, z = 26.207298278809, w = 1, yaw = -83.19441986084 }
}

local POS_CLIMB = {
  firstIcon = { x = 232.54695129395, y = 836.16888427734, z = 158.03700256348, w = 1, yaw = -38.347473144531 },
  upperIcon = { x = 232.1851348877, y = 836.37915039063, z = 171.48057556152, w = 1, yaw = 28.693504333496 },
  judyHere = { x = 224.98138427734, y = 847.12030029297, z = 171.47877502441, w = 1, yaw = 35.110374450684 },
  chillIcon = { x = 212.0675201416, y = 866.54699707031, z = 171.48057556152, w = 1, yaw = 33.591938018799 },
  finalTop = { x = 211.29983520508, y = 859.81793212891, z = 187.83929443359, w = 1, yaw = 128.02005004883 }
}

local function getGameSeconds()
  local ts = Game.GetTimeSystem()
  if not ts then return 0 end
  local gt = ts:GetGameTime()
  if not gt then return 0 end
  local ok, seconds = pcall(function()
    if gt.GetSeconds then return gt:GetSeconds() end
    if gt.Seconds then return gt:Seconds() end
    return (gt:Days() * 86400) + (gt:Hours() * 3600) + (gt:Minutes() * 60)
  end)
  if ok and seconds then return seconds end
  return 0
end

local function gameSecondsElapsed(startSeconds)
  if not startSeconds then return 0 end
  local now = getGameSeconds()
  local diff = now - startSeconds
  if diff < 0 then diff = diff + 2147483647 end
  return diff
end

local function setNextCooldownFromNow(self, reason)
  local ts = Game.GetTimeSystem()
  local today = ts and ts:GetGameTime():Days() or -1
  self.lastGiftDay = today
  self.cooldownDays = math.random(2, 4)
  local nextDay = today + (self.cooldownDays or 0)
  dbg("[Cooldown] " .. tostring(reason or "date ended") .. " | todayDay=" .. tostring(today) .. " cooldownDays=" .. tostring(self.cooldownDays) .. " nextDateEarliestDay=" .. tostring(nextDay))
end

local function printExistingCooldown(self, reason)
  local ts = Game.GetTimeSystem()
  local today = ts and ts:GetGameTime():Days() or -1
  local last = self.lastGiftDay or today
  local cd = self.cooldownDays or 0
  local nextDay = last + cd
  local remaining = nextDay - today
  if remaining < 0 then remaining = 0 end
  dbg("[Cooldown] " .. tostring(reason or "date ended") .. " | todayDay=" .. tostring(today) .. " lastDateDay=" .. tostring(last) .. " cooldownDays=" .. tostring(cd) .. " nextDateEarliestDay=" .. tostring(nextDay) .. " remainingDays=" .. tostring(remaining))
end

local function posKeyExactish(p)
  if not p then return "nil" end
  local function r(x) return tostring(math.floor((x or 0) * 1000 + 0.5) / 1000) end
  return r(p.x) .. "|" .. r(p.y) .. "|" .. r(p.z)
end

local function queueMissedDateMessage(self, delayHours, category)
  delayHours = delayHours or 0
  category = category or "MissedDate"
  self.pendingMissed = self.pendingMissed or {}
  self.pendingMissed.active = true
  self.pendingMissed.category = category
  self.pendingMissed.dueGameSeconds = getGameSeconds() + (delayHours * 3600)
  setNextCooldownFromNow(self, "date ended/message queued; category=" .. tostring(category) .. " delayHours=" .. tostring(delayHours))
end

local function queueLeftDateMessage(self, delayHours)
  queueMissedDateMessage(self, delayHours or 0, "LeftDate")
end

function JudyDateSMS:tickMissedDateMessage(dt)
  local p = self.pendingMissed
  if not p or not p.active then return end
  if not self.runtimeData.inGame or self.runtimeData.inMenu then return end
  if getGameSeconds() < (p.dueGameSeconds or 0) then return end
  p.active = false
  local cat = p.category or "MissedDate"
  p.category = nil
  if self.messenger then self.messenger:sendIncomingFromCategory(cat) end
  printExistingCooldown(self, tostring(cat) .. " message sent")
end

local function toggleGuitarVariant(variant, state)
  local ws = Game.GetWorldStateSystem()
  if not ws or not CreateNodeRef then return end
  pcall(function()
    ws:TogglePrefabVariant(CreateNodeRef(GUITAR_NODE), variant, state)
  end)
end

local function falseAllGuitarVariants(exceptVariant)
  for _, v in ipairs(GUITAR_VARIANTS) do
    toggleGuitarVariant(v, exceptVariant ~= nil and v == exceptVariant)
  end
end

local function toggleClimbVariant(variant, state)
  local ws = Game.GetWorldStateSystem()
  if not ws or not CreateNodeRef then return end
  pcall(function()
    ws:TogglePrefabVariant(CreateNodeRef(CLIMB_NODE), variant, state)
  end)
end

local function falseAllClimbVariants()
  for _, v in ipairs(CLIMB_VARIANTS) do
    toggleClimbVariant(v, false)
  end
end

local function falseAllDateVariantsOnLoad()
  if not (JudyDateSMS and JudyDateSMS.runtimeData and JudyDateSMS.runtimeData.inGame) then return end
  pcall(function() falseAllVariants() end)
  pcall(function() falseAllGuitarVariants() end)
  pcall(function() falseAllClimbVariants() end)
end

local function falseAllDateVariantsOnLoadBurst()
  falseAllDateVariantsOnLoad()
  if not (Cron and Cron.After) then return end
  for _, delay in ipairs({ 0.5, 1.5, 3.0, 6.0 }) do
    Cron.After(delay, function()
      falseAllDateVariantsOnLoad()
    end)
  end
end

local function setClimbInitialVariants()
  falseAllClimbVariants()
  toggleClimbVariant("judystuff34", true)
  toggleClimbVariant("judysmoke22", true)
end

local function setGuitarInitialVariants()
  falseAllGuitarVariants()
  toggleGuitarVariant("jstuff", true)
  toggleGuitarVariant("jphone", true)
  toggleGuitarVariant("ritacar", true)
  toggleGuitarVariant("lizdrink", true)
end

local function setGuitarRideVariants()
  toggleGuitarVariant("jphone", false)
  toggleGuitarVariant("lizdrink", false)
  toggleGuitarVariant("ritacar", false)
  toggleGuitarVariant("jcheer", true)
  toggleGuitarVariant("lizcheer", true)
  toggleGuitarVariant("ritaguitar", true)
end

local function setGuitarComeUpVariants()
  -- Do NOT disable ritaguitar here. Rita's guitar should remain visible through the come-up/final hangout phase.
  -- It is only hidden when the guitar date truly ends or resets.
  toggleGuitarVariant("jcheer", false)
  toggleGuitarVariant("ritacheer", false)
  toggleGuitarVariant("lizcheer", false)
  toggleGuitarVariant("jcar", true)
  toggleGuitarVariant("lizsmoke", true)
end

local function hideGuitarEndUI(self)
  local g = self.guitar
  if ui and g and g.endUiShown and ui.hideHub then
    pcall(function() ui.hideHub() end)
  end
  if g then g.endUiShown = false end
end

local function showGuitarEndUI(self)
  local g = self.guitar
  if not g or g.endUiShown or g.endDone then return end

  if not (ui and ui.createHub and ui.createChoice and ui.registerChoiceCallback and ui.clearCallbacks and ui.setupHub and ui.showHub) then
    if not g.noUiWarned then
      g.noUiWarned = true
      pushHUD("End the date interaction is not available because modules/interactionUI was not found.", 5.0)
    end
    return
  end

  ui.clearCallbacks()
  local choices = {
    ui.createChoice(getUIText("ui_end_the_date"), ICON_GET_UP or ICON_FALLBACK, YELLOW_CHOICE_TYPE),
    ui.createChoice(getUIText("ui_not_yet"), ICON_FALLBACK, YELLOW_CHOICE_TYPE)
  }

  ui.registerChoiceCallback(1, function()
    hideGuitarEndUI(self)
    self:finishGuitarDateSuccess()
  end)

  ui.registerChoiceCallback(2, function()
    hideGuitarEndUI(self)
  end)

  local hub = ui.createHub(getUIText("ui_judy_guitar_date"), choices)
  ui.setupHub(hub)
  ui.showHub()
  g.endUiShown = true
end


local function hideClimbEndUI(self)
  local c = self.climb
  if ui and c and c.endUiShown and ui.hideHub then
    pcall(function() ui.hideHub() end)
  end
  if c then c.endUiShown = false end
end

local function showClimbEndUI(self)
  local c = self.climb
  if not c or c.endUiShown or c.endDone then return end

  if not (ui and ui.createHub and ui.createChoice and ui.registerChoiceCallback and ui.clearCallbacks and ui.setupHub and ui.showHub) then
    if not c.noUiWarned then
      c.noUiWarned = true
      pushHUD("End the date interaction is not available because modules/interactionUI was not found.", 5.0)
    end
    return
  end

  ui.clearCallbacks()
  local choices = {
    ui.createChoice(getUIText("ui_end_the_date"), ICON_GET_UP or ICON_FALLBACK, YELLOW_CHOICE_TYPE)
  }

  ui.registerChoiceCallback(1, function()
    hideClimbEndUI(self)
    self:finishClimbDateSuccess()
  end)

  local hub = ui.createHub(getUIText("ui_judy_climb_date"), choices)
  ui.setupHub(hub)
  ui.showHub()
  c.endUiShown = true
end

local function hideSwimEndUI(self)
  if ui and self.swimEndUiShown and ui.hideHub then
    pcall(function() ui.hideHub() end)
  end
  self.swimEndUiShown = false
end

local function showSwimEndUI(self)
  if self.swimEndUiShown or self.swimEndDone then return end

  if not (ui and ui.createHub and ui.createChoice and ui.registerChoiceCallback and ui.clearCallbacks and ui.setupHub and ui.showHub) then
    if not self.swimNoUiWarned then
      self.swimNoUiWarned = true
      pushHUD("End the date interaction is not available because modules/interactionUI was not found.", 5.0)
    end
    return
  end

  ui.clearCallbacks()
  local choices = {
    ui.createChoice(getUIText("ui_end_the_date"), ICON_GET_UP or ICON_FALLBACK, YELLOW_CHOICE_TYPE)
  }

  ui.registerChoiceCallback(1, function()
    hideSwimEndUI(self)
    self:finishSwimDateSuccess()
  end)

  local hub = ui.createHub(getUIText("ui_judy_swim"), choices)
  ui.setupHub(hub)
  ui.showHub()
  self.swimEndUiShown = true
end

local function playAudioWithSubtitle(key, speaker, subtitle, duration)
  PlayAudioKey(key)
  DialogLine(subtitle, speaker or "Judy", duration or 6)
end

local function playGuitarFinalVoiceSequence(self)
  playAudioWithSubtitle("judycigar3", "Judy", "Enjoying the view", 3)

  Cron.After(3.5, function()
    if not (JudyDateSMS and JudyDateSMS.guitar and JudyDateSMS.guitar.active) then return end
    if not (JudyDateSMS.runtimeData and JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu) then return end
    PlayAudioKey(getVGenderedAudioKey("climbv"))
    DialogLine("Well, I be damned", "V", 3)
  end)
end

local function sendGuitarRideMessageAndMarker(self)
  local g = self.guitar
  if not g.active or g.rideMessageSent then return end
  g.rideMessageSent = true
  if self.messenger then self.messenger:sendIncomingFromCategory("GuitarRideBeast") end
  self:setPin(POS_GUITAR.downstairsIcon, lang.getText("ui_meet_judy_caption"))
  g.phase = "go_downstairs"
  g.phaseTimer = 0
end

local function startGuitarRidePhase(self)
  local g = self.guitar
  if not g.active or g.rideStarted then return end
  g.rideStarted = true
  setGuitarRideVariants()
  self:clearPin()
  g.phase = "ride_timer"
  g.phaseTimer = 0
end

local function finishGuitarRide(self, withGlitch)
  local g = self.guitar
  if not g.active or g.comeUpSent then return end
  g.comeUpSent = true
  if self.messenger then self.messenger:sendIncomingFromCategory("GuitarComeUp") end
  if withGlitch then spawnGlitchFx() end
  setGuitarComeUpVariants()
  self:setPin(POS_GUITAR.comeUpIcon, lang.getText("ui_meet_judy_caption"))
  g.phase = "come_up"
  g.phaseTimer = 0
end

local function cleanupGuitarDate(self, sendMissed, missedDelayHours, missedCategory)
  local g = self.guitar
  hideGuitarEndUI(self)
  self:clearPin()
  falseAllGuitarVariants()
  despawnTaggedVehicle(GUITAR_SPAWN_TAG)
  g.active = false
  g.phase = "idle"
  g.phaseTimer = 0
  g.poll = 0
  g.rideGatePoll = 0
  g.mountedTypePoll = 0
  g.startGameSeconds = nil
  g.arrived = false
  g.phoneAudioPlayed = false
  g.ritaAudioPlayed = false
  g.ritaCallSent = false
  g.rideMessageSent = false
  g.rideStarted = false
  g.comeUpSent = false
  g.cigarPlayed = false
  g.finalWatchStarted = false
  g.finalSampleTimer = 0
  g.finalLastKey = nil
  g.finalStable = false
  g.endUiShown = false
  g.noUiWarned = false
  g.endDone = false
  g.spawnedVehicleId = nil
  g.postCarMonitorActive = false
  g.postCarMonitorPoll = 0
  self.active = false
  self.currentDateKind = nil
  self.dateStartGameSeconds = nil
  if self.messenger then self.messenger:clearActiveMessage("guitar date cleanup") end
  if sendMissed then
    queueMissedDateMessage(self, missedDelayHours or 0, missedCategory or "MissedDate")
  else
    printExistingCooldown(self, "guitar date cleanup")
  end
end

function JudyDateSMS:finishGuitarDateSuccess()
  local g = self.guitar
  if g.endDone then return end
  g.endDone = true
  hideGuitarEndUI(self)
  self:clearPin()

  -- End-date cleanup is immediate when the player confirms End Date.
  spawnGlitchFx()
  falseAllGuitarVariants()
  advanceTimeHours(1)
  applyDateEndEffects()

  if self.messenger then
    self.messenger:sendIncomingFromCategory("GuitarThanks")
  end

  if not getMountedVehicle() then
    local p = getPlayer()
    if p then
      local pos = p:GetWorldPosition()
      despawnTaggedVehicle(GUITAR_SPAWN_TAG)
      g.spawnedVehicleId = spawnTaggedVehicle(
        "Vehicle.ma_pac_cvi_08_archer",
        { x = pos.x, y = pos.y + 5, z = pos.z, w = 1 },
        GUITAR_SPAWN_TAG
      )
      g.postCarMonitorActive = true
      g.postCarMonitorPoll = 0
    end
  else
    g.postCarMonitorActive = false
    g.postCarMonitorPoll = 0
  end

  g.active = false
  g.phase = "idle"
  g.phaseTimer = 0
  g.poll = 0
  g.rideGatePoll = 0
  g.mountedTypePoll = 0
  g.startGameSeconds = nil
  g.arrived = false
  g.phoneAudioPlayed = false
  g.ritaAudioPlayed = false
  g.ritaCallSent = false
  g.rideMessageSent = false
  g.rideStarted = false
  g.comeUpSent = false
  g.cigarPlayed = false
  g.finalWatchStarted = false
  g.finalSampleTimer = 0
  g.finalLastKey = nil
  g.finalStable = false
  g.endUiShown = false
  g.noUiWarned = false

  self.active = false
  self.currentDateKind = nil
  self.dateStartGameSeconds = nil
  setNextCooldownFromNow(self, "guitar date success")
end

function JudyDateSMS:startGuitarDate(force, suppressStartMessage)
  if self.active then return end
  if not force and not checkJudyRomanced() then return end

  self:clearPin()
  self:clearMaterialPin()
  falseAllVariants()
  falseAllClimbVariants()
  setGuitarInitialVariants()

  self.active = true
  self.currentDateKind = "guitar"
  self.dateStartGameSeconds = getGameSeconds()

  local g = self.guitar
  g.active = true
  g.phase = "wait_arrival"
  g.phaseTimer = 0
  g.poll = 0
  g.rideGatePoll = 0
  g.mountedTypePoll = 0
  g.startGameSeconds = self.dateStartGameSeconds
  g.arrived = false
  g.phoneAudioPlayed = false
  g.ritaAudioPlayed = false
  g.ritaCallSent = false
  g.rideMessageSent = false
  g.rideStarted = false
  g.comeUpSent = false
  g.cigarPlayed = false
  g.finalWatchStarted = false
  g.finalSampleTimer = 0
  g.finalLastKey = nil
  g.finalStable = false
  g.endUiShown = false
  g.noUiWarned = false
  g.endDone = false
  g.postCarMonitorActive = false
  g.postCarMonitorPoll = 0

  despawnTaggedVehicle(GUITAR_SPAWN_TAG)
  g.spawnedVehicleId = spawnTaggedVehicle("Vehicle.v_standard2_thorton_galena", POS_GUITAR.forcedSpawnCar, GUITAR_SPAWN_TAG)

  if self.messenger and not suppressStartMessage then
    self.messenger:sendIncomingFromCategory("GuitarInvite")
  end

  self:setPin(POS_GUITAR.firstMapIcon, lang.getText("ui_meet_judy_caption"))
  dbg("Judy guitar date started")
end

function JudyDateSMS:tickGuitarDate(dt)
  local g = self.guitar
  if not g.active then return end
  if not self.runtimeData.inGame or self.runtimeData.inMenu then return end

  g.phaseTimer = (g.phaseTimer or 0) + dt
  g.poll = (g.poll or 0) + dt
  local guitarPollInterval = self.settings.guitarPollInterval or self.settings.pollInterval or 1.0
  if g.poll < guitarPollInterval then return end
  g.poll = 0

  -- Every 2 seconds during guitar date, if V is mounted on the target vehicle,
  -- force vehicle systems off to match the requested behavior.
  g.mountedTypePoll = (g.mountedTypePoll or 0) + (dt or 0)
  if g.mountedTypePoll >= 2.0 then
    g.mountedTypePoll = 0
    if isMountedSpecificVehicle("Vehicle.cs_savable_quadra_type66") then
      applyMountedVehicleSystemsOff()
    end
  end

  local ppos = getPlayerPos()
  if not ppos then return end

  if not g.arrived and (inRange(POS_GUITAR.firstMapIcon, 40.0) or inRange(POS_GUITAR.phoneAudio, 10.0) or inRange(POS_GUITAR.ritaCarAudio, 10.0)) then
    g.arrived = true
  end

  if g.phase == "wait_arrival" and gameSecondsElapsed(g.startGameSeconds) >= FIVE_IN_GAME_HOURS then
    cleanupGuitarDate(self, true, 0)
    return
  end

  -- If the player already arrived and then leaves the whole Northside date area by a large range,
  -- end the date and send the same missed/no-show style message after 5 in-game hours.
  -- Check all important XYZ points so the date does not accidentally fail during valid transitions.
  local nearDateArea = false
  for _, ref in pairs(POS_GUITAR) do
    if dist3(ppos, ref) <= 240.0 then
      nearDateArea = true
      break
    end
  end
  if g.arrived and g.phase ~= "idle" and not nearDateArea then
    cleanupGuitarDate(self, true, 5, "LeftDate")
    return
  end

  if not g.phoneAudioPlayed and inRange(POS_GUITAR.phoneAudio, 4.0) then
    g.phoneAudioPlayed = true
    PlayAudioKey("judyphone1")
    Cron.After(2.0, function()
      if not (JudyDateSMS and JudyDateSMS.guitar and JudyDateSMS.guitar.active) then return end
      if not (JudyDateSMS.runtimeData and JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu) then return end
      DialogLine("Depends what you'd call \"preem.\" Does smut count?", "Judy", 2)
    end)
    Cron.After(4.5, function()
      if not (JudyDateSMS and JudyDateSMS.guitar and JudyDateSMS.guitar.active) then return end
      if not (JudyDateSMS.runtimeData and JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu) then return end
      DialogLine("Objectification? Not in my virtus. My actors love what they do, and that's why everyone wants to feel 'em. Can't fake old school emotions.", "Judy", 12)
    end)
  end

  if not g.ritaAudioPlayed and inRange(POS_GUITAR.ritaCarAudio, 4.0) then
    g.ritaAudioPlayed = true
    playAudioWithSubtitle("ritacar", "Rita", "Got good memory for faces!", 4)
    if self.messenger and not g.ritaCallSent then
      g.ritaCallSent = true
      self.messenger:sendIncomingFromCategory("GuitarRitaCall")
      g.phase = "wait_show_moves_gate"
      g.phaseTimer = 0
      g.rideGatePoll = 0
    end
  end

  if g.phase == "wait_show_moves_gate" then
    g.rideGatePoll = (g.rideGatePoll or 0) + (dt or 0)
    if g.rideGatePoll >= 2.0 then
      g.rideGatePoll = 0
      if inRange(POS_GUITAR.rideVehicleControl, 5.0) then
        applyMountedVehicleSystemsOff()
        sendGuitarRideMessageAndMarker(self)
        return
      end
    end

    -- Fallback so the date flow doesn't get stuck if the player misses the exact gate location.
    if g.phaseTimer >= 30.0 then
      applyMountedVehicleSystemsOff()
      sendGuitarRideMessageAndMarker(self)
      return
    end
    return
  end

  if g.phase == "go_downstairs" then
    if inRange(POS_GUITAR.downstairsIcon, 8.0) then
      startGuitarRidePhase(self)
      return
    end
    return
  end

  if g.phase == "ride_timer" then
    if inRange(POS_GUITAR.earlyComeUp, 7.0) then
      finishGuitarRide(self, true)
      return
    end
    if g.phaseTimer >= 60.0 then
      finishGuitarRide(self, false)
      return
    end
    return
  end

  if g.phase == "come_up" then
    if not g.cigarPlayed and inRange(POS_GUITAR.finalExact, 4.0) then
      g.cigarPlayed = true
      playGuitarFinalVoiceSequence(self)
    end

    if inRange(POS_GUITAR.finalExact, 2.0) then
      self:clearPin()
      showGuitarEndUI(self)
    else
      if g.endUiShown then hideGuitarEndUI(self) end
    end
    return
  end

  if g.phase == "wait_final_move" then
    -- Legacy fallback from the previous build. The new version ends through the interaction UI.
    return
  end
end

function JudyDateSMS:tickPostGuitarVehicleMonitor(dt)
  local g = self.guitar
  if not g or not g.postCarMonitorActive then return end
  if not self.runtimeData.inGame or self.runtimeData.inMenu then return end

  g.postCarMonitorPoll = (g.postCarMonitorPoll or 0) + (dt or 0)
  if g.postCarMonitorPoll < 3.0 then return end
  g.postCarMonitorPoll = 0

  local mountedId = getMountedVehicleEntityId()
  local mountedSpawned = idsEqual(mountedId, g.spawnedVehicleId)
  if not mountedSpawned then
    despawnTaggedVehicle(GUITAR_SPAWN_TAG)
    g.postCarMonitorActive = false
    g.postCarMonitorPoll = 0
    g.spawnedVehicleId = nil
  end
end


local function resetClimbStateOnly(self)
  local c = self.climb
  c.active = false
  c.phase = "idle"
  c.phaseTimer = 0
  c.poll = 0
  c.startGameSeconds = nil
  c.arrived = false
  c.comeUpSent = false
  c.firstTopReached = false
  c.judyHerePlayed = false
  c.climbUpSent = false
  c.finalLinePlayed = false
  c.hummingPlayed = false
  c.introVoiceStarted = false
  c.finalVoiceStarted = false
  c.endUiShown = false
  c.noUiWarned = false
  c.endDone = false
end

local function cleanupClimbDate(self, sendMissed, missedDelayHours, missedCategory)
  hideClimbEndUI(self)
  self:clearPin()
  falseAllClimbVariants()
  resetClimbStateOnly(self)
  self.active = false
  self.currentDateKind = nil
  self.dateStartGameSeconds = nil
  if self.messenger then self.messenger:clearActiveMessage("climb date cleanup") end
  if sendMissed then
    queueMissedDateMessage(self, missedDelayHours or 0, missedCategory or "MissedDate")
  else
    printExistingCooldown(self, "climb date cleanup")
  end
end

function JudyDateSMS:finishClimbDateSuccess()
  local c = self.climb
  if c.endDone then return end
  c.endDone = true
  hideClimbEndUI(self)
  self:clearPin()

  spawnGlitchFx()
  falseAllClimbVariants()
  advanceTimeHours(1)
  applyDateEndEffects()

  resetClimbStateOnly(self)
  self.active = false
  self.currentDateKind = nil
  self.dateStartGameSeconds = nil
  setNextCooldownFromNow(self, "climb date success")

  Cron.After(20.0, function()
    if JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu and JudyDateSMS.messenger then
      JudyDateSMS.messenger:sendIncomingFromCategory("Ending")
    end
  end)
end

function JudyDateSMS:startClimbDate(force, suppressStartMessage)
  if self.active then return end
  if not force and not checkJudyRomanced() then return end

  self:clearPin()
  self:clearMaterialPin()
  falseAllVariants()
  falseAllGuitarVariants()
  setClimbInitialVariants()

  self.active = true
  self.currentDateKind = "climb"
  self.dateStartGameSeconds = getGameSeconds()

  local c = self.climb
  c.active = true
  c.phase = "wait_first_icon"
  c.phaseTimer = 0
  c.poll = 0
  c.startGameSeconds = self.dateStartGameSeconds
  c.arrived = false
  c.comeUpSent = false
  c.firstTopReached = false
  c.judyHerePlayed = false
  c.climbUpSent = false
  c.finalLinePlayed = false
  c.hummingPlayed = false
  c.introVoiceStarted = false
  c.finalVoiceStarted = false
  c.endUiShown = false
  c.noUiWarned = false
  c.endDone = false

  if self.messenger and not suppressStartMessage then
    self.messenger:sendIncomingFromCategory("ClimbInvite")
  end

  self:setPin(POS_CLIMB.firstIcon, lang.getText("ui_meet_judy_caption"))
  dbg("Judy climb date started")
end

function JudyDateSMS:tickClimbDate(dt)
  local c = self.climb
  if not c.active then return end
  if not self.runtimeData.inGame or self.runtimeData.inMenu then return end

  c.phaseTimer = (c.phaseTimer or 0) + dt
  c.poll = (c.poll or 0) + dt
  local climbPollInterval = self.settings.climbPollInterval or self.settings.pollInterval or 1.0
  if c.poll < climbPollInterval then return end
  c.poll = 0

  local ppos = getPlayerPos()
  if not ppos then return end

  if not c.arrived and (inRange(POS_CLIMB.firstIcon, 35.0) or inRange(POS_CLIMB.upperIcon, 12.0)) then
    c.arrived = true
  end

  if c.phase == "wait_first_icon" and gameSecondsElapsed(c.startGameSeconds) >= FIVE_IN_GAME_HOURS then
    cleanupClimbDate(self, true, 0)
    return
  end

  local nearClimbArea = false
  for _, ref in pairs(POS_CLIMB) do
    if dist3(ppos, ref) <= 240.0 then
      nearClimbArea = true
      break
    end
  end
  if c.arrived and c.phase ~= "idle" and not nearClimbArea then
    cleanupClimbDate(self, true, 5, "LeftDate")
    return
  end

  if c.phase == "wait_first_icon" then
    if inRange(POS_CLIMB.firstIcon, 7.0) then
      c.comeUpSent = true
      if self.messenger then self.messenger:sendIncomingFromCategory("ClimbComeUp") end
      toggleClimbVariant("judysitt2", true)
      toggleClimbVariant("judysmoke22", false)
      self:setPin(POS_CLIMB.upperIcon, lang.getText("ui_meet_judy_caption"))
      c.phase = "go_upper_icon"
      c.phaseTimer = 0
    end
    return
  end

  if c.phase == "go_upper_icon" then
    if inRange(POS_CLIMB.upperIcon, 5.0) then
      self:clearPin()
      c.firstTopReached = true
      c.phase = "wait_near_judy"
      c.phaseTimer = 0
    end
    return
  end

  if c.phase == "wait_near_judy" then
    if inRange(POS_CLIMB.judyHere, 7.0) then
      c.judyHerePlayed = true
      spawnBlinkFx()
      playClimbIntroVoiceSequence(self)
      toggleClimbVariant("judystand22", true)
      toggleClimbVariant("judysitt2", false)
      self:setPin(POS_CLIMB.chillIcon, lang.getText("ui_meet_judy_caption"))
      c.phase = "go_chill_icon"
      c.phaseTimer = 0
    end
    return
  end

  if c.phase == "go_chill_icon" then
    if inRange(POS_CLIMB.chillIcon, 5.0) then
      self:clearPin()
      toggleClimbVariant("judystand22", false)
      toggleClimbVariant("judymm", true)
      if self.messenger then self.messenger:sendIncomingFromCategory("ClimbGoUp") end
      self:setPin(POS_CLIMB.finalTop, lang.getText("ui_meet_judy_caption"))
      c.phase = "go_final_top"
      c.phaseTimer = 0
    end
    return
  end

  if c.phase == "go_final_top" then
    if inRange(POS_CLIMB.finalTop, 5.0) then
      self:clearPin()
      playClimbFinalVoiceSequence(self)
      c.finalLinePlayed = true
      c.hummingPlayed = true
      c.phase = "final_voice_sequence"
      c.phaseTimer = 0
    end
    return
  end

  if c.phase == "final_voice_sequence" then
    if c.phaseTimer >= 20.0 then
      c.phase = "end_ui"
      c.phaseTimer = 0
    end
    return
  end

  if c.phase == "end_ui" then
    -- Less strict end-date radius so the End Date interaction appears without requiring exact placement.
    if inRange(POS_CLIMB.finalTop, 12.0) then
      showClimbEndUI(self)
    else
      if c.endUiShown then hideClimbEndUI(self) end
    end
    return
  end
end

function JudyDateSMS:cleanupDate(sendEnding)
  hideSwimEndUI(self)
  self:clearPin()
  self:clearMaterialPin()
  falseAllVariants()
  falseAllGuitarVariants()
  falseAllClimbVariants()
  self.active = false
  self.currentDateKind = nil
  self.dateStartGameSeconds = nil
  self.phase = "idle"
  self.phaseTimer = 0
  self.poll = 0
  self.stableTimer = 0
  self.swimEndUiShown = false
  self.swimNoUiWarned = false
  self.swimEndDone = false
  self.sleepTimer = 0
  if sendEnding and self.messenger and not self.endSent then
    self.endSent = true
    self.messenger:sendIncomingFromCategory("Ending")
  elseif self.messenger and not self.endSent then
    self.messenger:clearActiveMessage("swim date cleanup")
  end
end

function JudyDateSMS:startDate(force, suppressStartMessage)
  if self.active then return end
  if not force and factGet("judySwimDate_done") == 1 then return end
  if not force and not checkJudyRomanced() then return end

  self.currentDateKind = "swim"
  self.dateStartGameSeconds = getGameSeconds()
  ensureAlwaysOnVariants()

  factSet("judySwimDate_started", 1)
  self.active = true
  self.phase = "meet_judy"
  self.phaseTimer = 0
  self.dateTimer = 0
  self.endSent = false
  self.swimEndUiShown = false
  self.swimNoUiWarned = false
  self.swimEndDone = false
  self.yawStep = 0
  self.stableTimer = 0
  self.sleepTimer = 0
  self.lastPosKey = nil
  self.lastYawKey = nil
  self.lastYawValue = nil
  self.yawPollTimer = 0
  self.swimLoopIndex = 1
  self.swimLoopTimer = 0
  self.scavengeUiShown = false
  self.scavengeAmbientPlayed = false

  falseAllGuitarVariants()
  falseAllClimbVariants()
  falseAllVariants()
  enableSwimBaseVariants()
  -- Do not blink/splash on the initial Lizzie's swim invite placement.
  -- Blink FX stays for the later swim transitions only.
  local oldSuppressSwimFx = SUPPRESS_SWIM_FX
  SUPPRESS_SWIM_FX = true
  toggleVariant("judys1", true)
  SUPPRESS_SWIM_FX = oldSuppressSwimFx

  if self.messenger and not suppressStartMessage then
    self.messenger:sendIncomingFromCategory("JudySwim")
  end
  self:setPin(POS.meetSurface, lang.getText("ui_meet_judy_caption"))
  dbg("Judy swim date started")
end


function JudyDateSMS:resetRuntimeForNewSave(performWorldCleanup)
  performWorldCleanup = performWorldCleanup == true and self.runtimeData.inGame == true

  if performWorldCleanup then
    self:clearPin()
    self:clearMaterialPin()
    falseAllVariants()
    falseAllGuitarVariants()
    falseAllClimbVariants()
    despawnTaggedVehicle(GUITAR_SPAWN_TAG)
    factSet("judySwimDate_started", 0)
    factSet("judySwimDate_done", 0)
  else
    -- On save attachment, engine-owned IDs from the previous world are invalid.
    -- Drop Lua references without calling mappin, prefab, or entity systems.
    self.pin = nil
    self.materialPin = nil
    self.materialTarget = nil
  end

  resetClimbStateOnly(self)
  self.active = false
  self.currentDateKind = nil
  self.dateStartGameSeconds = nil
  self.pendingMissed.active = false
  self.pendingMissed.category = nil
  self.pendingMissed.dueGameSeconds = 0
  self.phase = "idle"
  self.phaseTimer = 0
  self.dateTimer = 0
  self.endSent = false
  self.swimEndUiShown = false
  self.swimNoUiWarned = false
  self.swimEndDone = false
  self.yawStep = 0
  self.stableTimer = 0
  self.sleepTimer = 0
  self.lastPosKey = nil
  self.lastYawKey = nil
  self.lastYawValue = nil
  self.yawPollTimer = 0
  self.swimLoopIndex = 1
  self.swimLoopTimer = 0
  self.scavengeUiShown = false
  self.scavengeAmbientPlayed = false
  self.poll = 0
  self.autoPoll = 0
  self.hasMail = false
  self.debug.lastMessageFired = false
  self.debug.lastMessageFiredDay = -1

  local g = self.guitar
  g.active = false
  g.phase = "idle"
  g.phaseTimer = 0
  g.poll = 0
  g.rideGatePoll = 0
  g.mountedTypePoll = 0
  g.startGameSeconds = nil
  g.arrived = false
  g.phoneAudioPlayed = false
  g.ritaAudioPlayed = false
  g.ritaCallSent = false
  g.rideMessageSent = false
  g.rideStarted = false
  g.comeUpSent = false
  g.cigarPlayed = false
  g.finalWatchStarted = false
  g.finalSampleTimer = 0
  g.finalLastKey = nil
  g.finalStable = false
  g.endUiShown = false
  g.noUiWarned = false
  g.endDone = false
  g.spawnedVehicleId = nil
  g.postCarMonitorActive = false
  g.postCarMonitorPoll = 0

  if self.messenger then self.messenger:resetForNewSave() end
end

function JudyDateSMS:checkJudyRomanceAndResetCycle()
  self:resetRuntimeForNewSave(false)

  local q001Done = factGet("q001_wakeup_scene_done")
  local romanceOk = checkJudyRomanced()
  dbg("Judy romance fact sq030_judy_lover = " .. tostring(factGet("sq030_judy_lover")))
  dbg("Quest fact q001_wakeup_scene_done = " .. tostring(q001Done))

  if q001Done == 1 and romanceOk then
    self.enabled = true
    local ts = Game.GetTimeSystem()
    self.initDay = ts and ts:GetGameTime():Days() or -1
    self.initialCooldownDays = math.random(2, 4)
    self.lastGiftDay = -1
    self.cooldownDays = 0
    self.lastCheck = 0
    dbg("Romance confirmed - session initialized initDay=" .. tostring(self.initDay) .. " initialCooldownDays=" .. tostring(self.initialCooldownDays))
    if self.messenger then self.messenger:ensureContactWhenReady() end
  else
    self.enabled = false
    self.currentCategory = nil
    self.initDay = -1
    self.initialCooldownDays = 0
    self.lastGiftDay = -1
    self.cooldownDays = 0
    dbg("Judy not romanced or wakeup not done - mod inactive")
  end
end

function JudyDateSMS:sendMessageAndReact()
  if not self.enabled then return end
  if self.active then return end
  if not self.messenger then
    dbg("ERROR: messenger not initialized")
    return
  end

  self.debug.lastMessageFired = true
  local ts = Game.GetTimeSystem()
  self.debug.lastMessageFiredDay = ts and ts:GetGameTime():Days() or -1

  -- Weighted almost equally, but swim is very slightly less likely than the other two dates.
  -- Swim 32%, guitar 34%, climb 34%.
  local roll = math.random(1, 100)
  if roll <= 32 then
    self.currentCategory = "JudySwim"
    self:startDate(true, false)
  elseif roll <= 66 then
    self.currentCategory = "GuitarInvite"
    self:startGuitarDate(true, false)
  else
    self.currentCategory = "ClimbInvite"
    self:startClimbDate(true, false)
  end
end

function JudyDateSMS:startSwimScavengeLoop()
  self.phase = "swim_scavenge_loop"
  self.phaseTimer = 0
  self.swimLoopTimer = 0
  self.swimLoopIndex = 1
  self.yawPollTimer = 0
  setOnlyVariant(SWIM_LOOP_STAGES[self.swimLoopIndex].variant)
  spawnHeavyFrontSplashBurst(10)
  resetSwimYawPoll(self)

  Cron.After(1.0, function()
    if not (JudyDateSMS and JudyDateSMS.currentDateKind == "swim" and JudyDateSMS.phase == "swim_scavenge_loop") then return end
    if not (JudyDateSMS.runtimeData and JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu) then return end
    playScavengeAmbientLineOnce(JudyDateSMS)
  end)
end

function JudyDateSMS:finishUnderwaterSequence()
  setOnlyVariant(nil)
  spawnHeavyFrontSplashBurst(10)
  spawnGlitchFx()
  if self.messenger then self.messenger:sendIncomingFromCategory("JudyWaterDone") end
  spawnBlinkFx()
  toggleVariant("judysmoke", true)
  self:setPin(POS.surfaceSmokeIcon, lang.getText("ui_meet_judy_caption"))
  self:clearMaterialPin()
  self.phase = "return_top"
  self.phaseTimer = 0
end

function JudyDateSMS:finishSleepStep()
  self:clearPin()
  self:setPin(POS.restIcon, lang.getText("ui_meet_judy_caption"))
  self.phase = "rest_end_ui"
  self.phaseTimer = 0
end

function JudyDateSMS:finishSwimDateSuccess()
  if self.swimEndDone then return end
  self.swimEndDone = true
  hideSwimEndUI(self)
  self:clearPin()
  self:clearMaterialPin()
  spawnGlitchFx()
  advanceTimeHours(1)
  applyDateEndEffects()
  falseAllVariants()
  factSet("judySwimDate_done", 1)
  self.active = false
  self.currentDateKind = nil
  self.dateStartGameSeconds = nil
  self.phase = "idle"
  self.phaseTimer = 0
  setNextCooldownFromNow(self, "swim date success")
  Cron.After(20.0, function()
    if JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu and JudyDateSMS.messenger then
      JudyDateSMS.messenger:sendIncomingFromCategory("Ending")
    end
  end)
end

function JudyDateSMS:tickDate(dt)
  if not self.active then return end
  if self.currentDateKind ~= "swim" then return end
  self.dateTimer = (self.dateTimer or 0) + dt
  self.phaseTimer = (self.phaseTimer or 0) + dt
  self.currentTickStep = dt

  if self.phase == "meet_judy" and gameSecondsElapsed(self.dateStartGameSeconds) >= FIVE_IN_GAME_HOURS then
    self:cleanupDate(false)
    queueMissedDateMessage(self, 0)
    return
  end

  local currentPos = getPlayerPos()
  if currentPos and self.phase ~= "meet_judy" and dist3(currentPos, POS.meetSurface) > 220.0 then
    self:cleanupDate(false)
    queueLeftDateMessage(self, 5)
    return
  end

  if self.phase == "rest_end_ui" then
    if inRange(POS.restIcon, 5.0) then
      showSwimEndUI(self)
    else
      if self.swimEndUiShown then hideSwimEndUI(self) end
    end
    return
  end

  self.poll = self.poll + dt
  local swimPollInterval = self.settings.swimPollInterval or self.settings.pollInterval or 2.0
  if self.poll < swimPollInterval then return end
  self.poll = 0

  if self.phase == "meet_judy" then
    if inRange(POS.meetSurface, 7.0) then
      self:setPin(POS.underwaterIcon1, lang.getText("ui_meet_judy_caption"))
      self.phase = "swim_to_truck"
      self.phaseTimer = 0
    end
    return
  end

  if self.phase == "swim_to_truck" then
    -- Big range is ONLY for judys1 -> judys2. Do not skip judys2 -> judys3 here.
    if inRange(POS.underwaterTrigger1, 16.0) then
      local oldSuppressSplash = SUPPRESS_SWIM_SPLASH
      SUPPRESS_SWIM_SPLASH = true
      toggleVariant("judys1", false)
      toggleVariant("judys2", true)
      SUPPRESS_SWIM_SPLASH = oldSuppressSplash
      self:setPin(POS.cuteIcon, lang.getText("ui_meet_judy_caption"))
      self.phase = "go_cute_icon"
      self.phaseTimer = 0
    end
    return
  end

  if self.phase == "go_cute_icon" then
    -- Player must actually reach the second underwater icon before Judy sends the cute message.
    if inRange(POS.cuteIcon, 4.5) then
      if self.messenger then self.messenger:sendIncomingFromCategory("JudyCute") end
      -- Do not use a fixed seconds wait for judys2 -> judys3.
      -- Wait until the camera turns away/opposite, then switch while Judy is off-screen.
      resetSwimYawPoll(self)
      self.phase = "cute_wait_for_lookaway"
      self.phaseTimer = 0
    end
    return
  end

  if self.phase == "cute_wait_for_lookaway" then
    local shouldSwitch = false

    -- First try the intended hidden swap: player looks to the opposite side.
    if readySwimYawPoll(self) and playerFacing(oppositeYaw(POS.cuteIcon.yaw), self.settings.oppositeYawTolerance) then
      shouldSwitch = true
    end

    -- Fallback so the date never gets stuck on the "Hard not to like them" message.
    -- After 5 seconds, force the next underwater stage even if the angle check did not catch.
    if self.phaseTimer >= 5.0 then
      shouldSwitch = true
    end

    if shouldSwitch then
      toggleVariant("judys2", false)
      toggleVariant("judys3", true)
      self:setPin(POS.swimIcon2, lang.getText("ui_meet_judy_caption"))
      resetSwimYawPoll(self)
      self.phase = "reach_swim_icon2"
      self.phaseTimer = 0
    end
    return
  end

  if self.phase == "reach_swim_icon2" then
    if inRange(POS.swimIcon2, 4.5) then
      toggleVariant("judys3", false)
      self:startSwimScavengeLoop()
    end
    return
  end

  if self.phase == "swim_scavenge_loop" then
    if inRange(POS.scavengeExitTrigger, 10.0) then
      hideScavengeUI(self)
      self:clearMaterialPin()
      spawnGlitchFx()
      self:finishUnderwaterSequence()
      return
    end

    if self.phaseTimer >= (self.settings.swimLoopDuration or 30.0) then
      self:finishUnderwaterSequence()
      return
    end

    -- Scavenging UI/reward/marker removed from the swim date.

    if readySwimYawPoll(self) then
      local stage = SWIM_LOOP_STAGES[self.swimLoopIndex] or SWIM_LOOP_STAGES[1]
      -- Use the OPPOSITE yaw of the visible swim placement, not the exact placement yaw.
      if playerFacing(oppositeYaw(stage.visibleYaw), self.settings.oppositeYawTolerance) then
        self.swimLoopIndex = (self.swimLoopIndex % #SWIM_LOOP_STAGES) + 1
        setOnlyVariant(SWIM_LOOP_STAGES[self.swimLoopIndex].variant)
        resetSwimYawPoll(self)
      end
    end
    return
  end

  if self.phase == "return_top" then
    if inRange(POS.surfaceSmokeTrigger, 9.0) then
      if self.messenger then self.messenger:sendIncomingFromCategory("JudyEasy") end
      self:setPin(POS.sleepIcon, lang.getText("ui_meet_judy_caption"))
      self.phase = "go_sleep"
      self.phaseTimer = 0
    end
    return
  end

  if self.phase == "go_sleep" then
    if inRange(POS.sleepIcon, 5.0) then
      spawnBlinkFx()
      toggleVariant("judysmoke", false)
      toggleVariant("judysleep", true)
      self:setPin(POS.restIcon, lang.getText("ui_meet_judy_caption"))
      self.phase = "sleep_wait"
      self.phaseTimer = 0
      self.sleepTimer = 0
      self.stableTimer = 0
      self.lastPosKey = nil
      self.lastYawKey = nil
    end
    return
  end

  if self.phase == "sleep_wait" then
    local step = self.currentTickStep or dt or self.settings.swimPollInterval or self.settings.pollInterval or 2.0
    self.sleepTimer = self.sleepTimer + step
    if inRange(POS.restIcon, 3.0) then
      local p = getPlayerPos()
      local y = getPlayerYaw()
      local pk = p and posKey(p) or "nil"
      local yk = yawKey(y)
      if self.lastPosKey == pk and self.lastYawKey == yk then
        self.stableTimer = self.stableTimer + step
      else
        self.stableTimer = 0
        self.lastPosKey = pk
        self.lastYawKey = yk
      end
      if self.stableTimer >= 5.0 then
        self:finishSleepStep()
        return
      end
    end
    if self.sleepTimer >= 10.0 then
      self:finishSleepStep()
      return
    end
    return
  end
end

function JudyDateSMS:tickAutoMessages(dt)
  if not self.enabled then return end
  if self.active then return end
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
    dbg("Cooldown passed - starting random Judy date day=" .. tostring(day) .. " nextCooldownDays=" .. tostring(self.cooldownDays))
    self:sendMessageAndReact()
  end
end

local function registerJudyDebugHotkeys(self)
  if self._hotkeysRegistered then return end
  ----------------------------------------------------------
  -- Hotkeys (debug), same direct registerHotkey style as the Panam mod.
  ----------------------------------------------------------
  local function onStartRandom()
    self:resetRuntimeForNewSave(true)
    self.enabled = true
    self:sendMessageAndReact()
  end

  if type(registerHotkey) == "function" then
    registerHotkey("judy_start_random", "JudyDate: Start Random Date", onStartRandom)
    self._hotkeysRegistered = true
    return
  end

  if type(registerInput) == "function" then
    registerInput("judy_start_random", "JudyDate: Start Random Date", function(pressed) if pressed then onStartRandom() end end)
    self._hotkeysRegistered = true
    return
  end

  dbg("No CET bindkey API found. Debug bindkeys skipped.")
end

function JudyDateSMS:onInit()
  if ui and ui.init then pcall(function() ui.init() end) end

  self.messenger = require("modules/messenger"):new(self)
  self.messenger:setup()

  Observe("RadialWheelController", "OnIsInMenuChanged", function(_, isInMenu)
    self.runtimeData.inMenu = isInMenu
  end)

  ObserveAfter("PlayerPuppet", "OnGameAttached", function()
    ICON_LOOT = getChoiceIconRecord("ChoiceCaptionParts.LootIcon") or ICON_FALLBACK
    ICON_GET_UP = getChoiceIconRecord("ChoiceCaptionParts.GetUpIcon") or ICON_FALLBACK
    YELLOW_CHOICE_TYPE = (gameinteractionsChoiceType and gameinteractionsChoiceType.QuestImportant) or nil
    self.runtimeData.inGame = true
    self:checkJudyRomanceAndResetCycle()
    falseAllDateVariantsOnLoadBurst()
  end)

  ObserveBefore("PlayerPuppet", "OnDetach", function()
    -- Do not call world, mappin, or entity systems while the game world is detaching.
    self.runtimeData.inGame = false
    self.runtimeData.inMenu = false
    self.pin = nil
    self.materialPin = nil
    self.materialTarget = nil
    self.active = false
    self.currentDateKind = nil
    self.guitar.active = false
    self.guitar.spawnedVehicleId = nil
    self.guitar.postCarMonitorActive = false
    self.climb.active = false
    Cron.StopAll()
  end)
end

-- Register bindkeys at script load time so they appear in CET Bindings.
registerJudyDebugHotkeys(JudyDateSMS)

registerForEvent("onInit", function()
  pcall(function() math.randomseed(os.time()) end)
  JudyDateSMS:onInit()
end)

registerForEvent("onDraw", function()
  if ui and ui.update then ui.update() end
end)

local ONUPDATE_ACCUMULATOR = 0.0
local SWIM_TICK_ACCUMULATOR = 0.0
local GUITAR_TICK_ACCUMULATOR = 0.0
local CLIMB_TICK_ACCUMULATOR = 0.0

registerForEvent("onUpdate", function(dt)
  ONUPDATE_ACCUMULATOR = ONUPDATE_ACCUMULATOR + (dt or 0)
  local updateInterval = JudyDateSMS.settings.updateInterval or 1.0
  if ONUPDATE_ACCUMULATOR < updateInterval then return end

  local tickDt = ONUPDATE_ACCUMULATOR
  ONUPDATE_ACCUMULATOR = 0.0

  Cron.Update(tickDt)

  if JudyDateSMS.runtimeData.inGame and not JudyDateSMS.runtimeData.inMenu then
    JudyDateSMS:tickAutoMessages(tickDt)
    JudyDateSMS:tickMissedDateMessage(tickDt)
    JudyDateSMS:tickPostGuitarVehicleMonitor(tickDt)

    SWIM_TICK_ACCUMULATOR = SWIM_TICK_ACCUMULATOR + tickDt
    if SWIM_TICK_ACCUMULATOR >= (JudyDateSMS.settings.swimPollInterval or 2.0) then
      local swimDt = SWIM_TICK_ACCUMULATOR
      SWIM_TICK_ACCUMULATOR = 0.0
      JudyDateSMS:tickDate(swimDt)
    end

    GUITAR_TICK_ACCUMULATOR = GUITAR_TICK_ACCUMULATOR + tickDt
    if GUITAR_TICK_ACCUMULATOR >= (JudyDateSMS.settings.guitarPollInterval or 1.0) then
      local guitarDt = GUITAR_TICK_ACCUMULATOR
      GUITAR_TICK_ACCUMULATOR = 0.0
      JudyDateSMS:tickGuitarDate(guitarDt)
    end

    CLIMB_TICK_ACCUMULATOR = CLIMB_TICK_ACCUMULATOR + tickDt
    if CLIMB_TICK_ACCUMULATOR >= (JudyDateSMS.settings.climbPollInterval or 1.0) then
      local climbDt = CLIMB_TICK_ACCUMULATOR
      CLIMB_TICK_ACCUMULATOR = 0.0
      JudyDateSMS:tickClimbDate(climbDt)
    end
  end
end)

return JudyDateSMS
