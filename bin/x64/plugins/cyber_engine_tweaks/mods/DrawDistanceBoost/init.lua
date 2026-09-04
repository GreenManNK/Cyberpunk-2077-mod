-- Increased Level of Details Distance - Draw Distance by (c) DBK
-- https://www.nexusmods.com/cyberpunk2077/mods/8694
-- April 09, 2026
-- File version: 5.1
-- Requires CET - 1.37.1
-- Requires Native UI - 1.96

local GameUI
do
  local ok, mod = pcall(require, "modules/GameUI")
  if not ok then ok, mod = pcall(require, "GameUI") end
  if ok then GameUI = mod else GameUI = nil end
end

local nativeSettings = nil

-- Store both JSON files INSIDE the mod folder (relative paths in CET are relative to this mod folder)
local STATE_FILE = "ddb_state.json"       -- ONLY master on/off
local SETTINGS_FILE = "ddb_settings.json" -- ALL tuning settings, no master

-- Universal CET event wrapper
local function On(event, fn)
  if registerForEvent then
    registerForEvent(event, fn)
  elseif CET and CET.RegisterCallback then
    CET.RegisterCallback(event, fn)
  else
    print()
  end
end

local runtimeData = { inMenu = false }

-- ----------------------------
-- Defaults (no ModEnabled here)
-- ----------------------------
local defaults = {
  dboost = 0.0,       -- Current Distance Boost
  rboost = 60.0,      -- Rendering Range
  aboost = 0.0,       -- Min Streaming Distance
  bboost = 23170.25,  -- Max Streaming Distance
  nboost = 300.0,     -- Max Nodes Per Frame (int applied)
  zboost = 0.0,       -- Precache Distance
  sboost = 200.0,     -- Streaming Radius
  fboost = 500.0,     -- Spatial Max Range
  mboost = 10.0,      -- Spatial Detail Max Range
  oboost = 2000.0,    -- Occlusion Range
  jboost = 50.0,      -- Animation Preload Distance
  iboost = 12.0,      -- Animation Cutoff Distance
  EnableParticlesWorldPreview = false,     -- Experimental
  ObserverVelocityOffsetEnabled = false    -- Experimental
}

local settings = { Current = {} }

local modState = {
  enabled = true -- default if no state file exists
}

local function deepCopyTable(t)
  local out = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      out[k] = deepCopyTable(v)
    else
      out[k] = v
    end
  end
  return out
end

-- ----------------------------
-- Load / Save (two JSON files)
-- ----------------------------
local function LoadModState()
  local f = io.open(STATE_FILE, "r")
  if not f then
    modState.enabled = true
    return
  end

  local s = f:read("*a")
  f:close()

  local decoded = json.decode(s)
  if type(decoded) == "table" and type(decoded.enabled) == "boolean" then
    modState.enabled = decoded.enabled
  else
    modState.enabled = true
  end
end

local function SaveModState()
  local f = io.open(STATE_FILE, "w")
  if f then
    f:write(json.encode({ enabled = modState.enabled }))
    f:close()
    print()
  end
end

local function LoadSettings()
  -- start from defaults
  settings.Current = deepCopyTable(defaults)

  local f = io.open(SETTINGS_FILE, "r")
  if not f then
    print()
    return
  end

  local s = f:read("*a")
  f:close()

  local decoded = json.decode(s)
  if type(decoded) ~= "table" then
    print()
    return
  end

  -- merge known keys only (ignore anything unexpected)
  for k, v in pairs(defaults) do
    if decoded[k] ~= nil then
      settings.Current[k] = decoded[k]
    end
  end

  print()
end

local function SaveSettings()
  -- Write only tuning values (no enabled state)
  local out = {}
  for k, _ in pairs(defaults) do
    out[k] = settings.Current[k]
  end

  local f = io.open(SETTINGS_FILE, "w")
  if f then
    f:write(json.encode(out))
    f:close()
    print()
  end
end

-- ----------------------------
-- GameOptions capture/restore
-- ----------------------------
local originalOptions = nil

local function CaptureOriginalOptions()
  if originalOptions then return end
  originalOptions = {}

  originalOptions.DistanceBoost = GameOptions.GetFloat("Streaming", "DistanceBoost")
  originalOptions.MinStreamingDistance = GameOptions.GetFloat("Streaming", "MinStreamingDistance")
  originalOptions.MaxStreamingDistance = GameOptions.GetFloat("Streaming", "MaxStreamingDistance")
  originalOptions.SpatialDebugRange = GameOptions.GetFloat("Streaming", "SpatialDebugRange")
  originalOptions.SpatialDebugDetailRange = GameOptions.GetFloat("Streaming", "SpatialDebugDetailRange")
  originalOptions.PrecacheDistance = GameOptions.GetFloat("Streaming", "PrecacheDistance")
  originalOptions.RoughCullingRejectionRange = GameOptions.GetFloat("Rendering", "RoughCullingRejectionRange")
  originalOptions.MaxNodesPerFrame = GameOptions.GetInt("Streaming", "MaxNodesPerFrame")
  originalOptions.RadiusNearSubtrahend = GameOptions.GetFloat("Streaming", "RadiusNearSubtrahend")
  originalOptions.OcclusionMaxDistance = GameOptions.GetFloat("Occlusion", "MaxDistance")
  originalOptions.IKTurnOffDistance = GameOptions.GetFloat("Animation", "IKTurnOffDistance")
  originalOptions.DistanceToCameraForAlwaysSample = GameOptions.GetFloat("Animation", "DistanceToCameraForAlwaysSample")
end

local function RestoreOriginalOptions()
  if not originalOptions then return end
  if runtimeData.inMenu then return end

  GameOptions.SetFloat("Streaming", "DistanceBoost", originalOptions.DistanceBoost)
  GameOptions.SetFloat("Streaming", "MinStreamingDistance", originalOptions.MinStreamingDistance)
  GameOptions.SetFloat("Streaming", "MaxStreamingDistance", originalOptions.MaxStreamingDistance)
  GameOptions.SetFloat("Streaming", "SpatialDebugRange", originalOptions.SpatialDebugRange)
  GameOptions.SetFloat("Streaming", "SpatialDebugDetailRange", originalOptions.SpatialDebugDetailRange)
  GameOptions.SetFloat("Streaming", "PrecacheDistance", originalOptions.PrecacheDistance)
  GameOptions.SetFloat("Rendering", "RoughCullingRejectionRange", originalOptions.RoughCullingRejectionRange)
  GameOptions.SetInt("Streaming", "MaxNodesPerFrame", originalOptions.MaxNodesPerFrame)
  GameOptions.SetFloat("Streaming", "RadiusNearSubtrahend", originalOptions.RadiusNearSubtrahend)
  GameOptions.SetFloat("Occlusion", "MaxDistance", originalOptions.OcclusionMaxDistance)
  GameOptions.SetFloat("Animation", "IKTurnOffDistance", originalOptions.IKTurnOffDistance)
  GameOptions.SetFloat("Animation", "DistanceToCameraForAlwaysSample", originalOptions.DistanceToCameraForAlwaysSample)
end

-- ----------------------------
-- Apply functions
-- ----------------------------
local function SetBoost()       GameOptions.SetFloat("Streaming", "DistanceBoost", settings.Current.dboost) end
local function SetStreamMin()   GameOptions.SetFloat("Streaming", "MinStreamingDistance", settings.Current.aboost) end
local function SetStreamMax()   GameOptions.SetFloat("Streaming", "MaxStreamingDistance", settings.Current.bboost) end
local function SetSpatial()     GameOptions.SetFloat("Streaming", "SpatialDebugRange", settings.Current.fboost) end
local function SetMaxSpatial()  GameOptions.SetFloat("Streaming", "SpatialDebugDetailRange", settings.Current.mboost) end
local function SetCache()       GameOptions.SetFloat("Streaming", "PrecacheDistance", settings.Current.zboost) end
local function SetRender()      GameOptions.SetFloat("Rendering", "RoughCullingRejectionRange", settings.Current.rboost) end
local function SetNodes()       GameOptions.SetInt("Streaming", "MaxNodesPerFrame", math.floor(tonumber(settings.Current.nboost) or 0)) end
local function SetRadius()      GameOptions.SetFloat("Streaming", "RadiusNearSubtrahend", settings.Current.sboost) end
local function SetOcclusion()   GameOptions.SetFloat("Occlusion", "MaxDistance", settings.Current.oboost) end
local function SetAnimTurnOffDistance() GameOptions.SetFloat("Animation", "IKTurnOffDistance", settings.Current.iboost) end
local function SetAnimDistanceToCam()   GameOptions.SetFloat("Animation", "DistanceToCameraForAlwaysSample", settings.Current.jboost) end

local function UpdateGameOptions()
  if runtimeData.inMenu then return end
  if not modState.enabled then return end

  SetBoost()
  SetStreamMin()
  SetStreamMax()
  SetSpatial()
  SetMaxSpatial()
  SetCache()
  SetRender()
  SetNodes()
  SetRadius()
  SetOcclusion()
  SetAnimTurnOffDistance()
  SetAnimDistanceToCam()
end

-- ----------------------------
-- Native Settings helpers
-- ----------------------------
local function ShouldIgnoreUserChanges()
  -- When disabled, do not apply and do not persist tuning changes.
  return not modState.enabled
end

On("onInit", function()
  nativeSettings = GetMod("nativeSettings")
  if not nativeSettings then
    print()
    return
  end

  LoadModState()
  LoadSettings()
  CaptureOriginalOptions()

  if modState.enabled then
    UpdateGameOptions()
  else
    RestoreOriginalOptions()
  end

  -- Menu detection via GameUI (reactive)
  if GameUI and GameUI.Listen then
    GameUI.Listen(function(state)
      runtimeData.inMenu = state.isMenu or false
    end)
  else
    On("onUpdate", function()
      if GameUI and GameUI.IsMenu then
        runtimeData.inMenu = GameUI.IsMenu()
      end
    end)
  end

  -- TAB
  nativeSettings.addTab("/DDB", "Draw Distance Boost")

  -- Master category (top)
  nativeSettings.addSubcategory("/DDB/Master", "Master")
  nativeSettings.addSwitch(
    "/DDB/Master",
    "Enabled",
    "When OFF, none of the settings will apply to the game.",
    modState.enabled,
    true,
    function(state)
      modState.enabled = state and true or false
      SaveModState() -- ONLY enabled/disabled state

      if modState.enabled then
        -- Re-apply using last saved (and still-in-memory) settings
        UpdateGameOptions()
      else
        RestoreOriginalOptions()
      end
    end
  )

  local function addFloat(path, name, desc, min, max, step, fmt, key, applyFn)
    nativeSettings.addRangeFloat(
      path, name, desc,
      min, max, step, fmt,
      settings.Current[key],
      defaults[key],
      function(value)
        if ShouldIgnoreUserChanges() then
          -- do not change in-memory settings; do not save; do not apply
          return
        end
        settings.Current[key] = value
        applyFn()
        SaveSettings() -- autosave so Defaults button also updates json
      end
    )
  end

  local function addSwitch(path, name, desc, key)
    nativeSettings.addSwitch(
      path,
      name,
      desc,
      settings.Current[key],
      defaults[key],
      function(state)
        if ShouldIgnoreUserChanges() then
          return
        end
        settings.Current[key] = state and true or false
        SaveSettings()
      end
    )
  end

  -- Categories + ordering (exactly as requested)
  -- Boost
  nativeSettings.addSubcategory("/DDB/Boost", "Boost")
  addFloat("/DDB/Boost", "Current Distance Boost",
    "Pushes the game engine to load higher detail objects further away (if and when available).",
    0, 100, 1, "%0.0f", "dboost", SetBoost)

  -- Rendering
  nativeSettings.addSubcategory("/DDB/Rendering", "Rendering")
  addFloat("/DDB/Rendering", "Rendering Range",
    "Adjusts culling rejection range for distant rendering.",
    0, 300, 1, "%0.0f", "rboost", SetRender)

  -- Streaming
  nativeSettings.addSubcategory("/DDB/Streaming", "Streaming")
  addFloat("/DDB/Streaming", "Min Streaming Distance",
    "Minimum distance from player where objects start rendering.",
    0, 1000, 1, "%0.0f", "aboost", SetStreamMin)

  addFloat("/DDB/Streaming", "Max Streaming Distance",
    "How far the world is streamed.",
    0, 32000, 1, "%0.0f", "bboost", SetStreamMax)

  addFloat("/DDB/Streaming", "Max Nodes Per Frame",
    "Maximum number of streaming nodes processed per frame. Higher values increase streaming load.",
    1, 1500, 1, "%0.0f", "nboost", SetNodes)

  addFloat("/DDB/Streaming", "Precache Distance",
    "Distance used for pre-caching streaming data.",
    0, 100, 0.1, "%.2f", "zboost", SetCache)

  addFloat("/DDB/Streaming", "Streaming Radius",
    "Streaming radius adjustment forces objects to load further away.",
    0, 1000, 1, "%0.0f", "sboost", SetRadius)

  addFloat("/DDB/Streaming", "Spatial Max Range",
    "Spatial streaming max range. Shadow and GI distance.",
    0, 2500, 1, "%0.0f", "fboost", SetSpatial)

  addFloat("/DDB/Streaming", "Spatial Detail Max Range",
    "Spatial streaming detailed max range for small objects.",
    0, 100, 1, "%0.0f", "mboost", SetMaxSpatial)

  -- Occlusion
  nativeSettings.addSubcategory("/DDB/Occlusion", "Occlusion")
  addFloat("/DDB/Occlusion", "Occlusion Range",
    "Maximum Ray distance for occlusion shading.",
    0, 10000, 1, "%0.0f", "oboost", SetOcclusion)

  -- Animation
  nativeSettings.addSubcategory("/DDB/Animation", "Animation")
  addFloat("/DDB/Animation", "Animation Preload Distance",
    "Distance where animations are always sampled.",
    0, 250, 0.1, "%0.0f", "jboost", SetAnimDistanceToCam)

  addFloat("/DDB/Animation", "Animation Cutoff Distance",
    "When animations stop updating.",
    0, 60, 0.1, "%.2f", "iboost", SetAnimTurnOffDistance)

  -- Experimental
  nativeSettings.addSubcategory("/DDB/Experimental", "Experimental")
  addSwitch("/DDB/Experimental",
    "Particles World Preview",
    "Experimental particle rendering behavior.",
    "EnableParticlesWorldPreview")

  addSwitch("/DDB/Experimental",
    "Observer Velocity Offset",
    "Experimental streaming behavior adjustment.",
    "ObserverVelocityOffsetEnabled")

  -- Optional manual save button (kept, but autosave already covers most cases)
  nativeSettings.addSubcategory("/DDB/Save", "Save")
  nativeSettings.addButton(
    "/DDB/Save",
    "Save Current Settings",
    "Manually save your Current Settings. If in Game, Reload Last Sove for the New Settings to take effect.",
    "Save",
    45,
    function()
      SaveSettings()
    end
  )
end)
