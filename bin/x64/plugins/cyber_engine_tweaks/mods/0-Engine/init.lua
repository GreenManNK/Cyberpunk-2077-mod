-- 0-Engine by DigitalVixen
-- Centralized runtime service layer for CET mods (state caching + event bus).
-- API reference: README.md. Changelog: history.md.

local engineVersion = "0.18.6"

-- psiberx Libraries
local Cron = require('external/Cron')
local GameSession = require('external/GameSession')
local GameUI = require('external/GameUI')
local GameHUD = require('external/GameHUD')
local Ref = require('external/Ref')

-- Internal Libraries
local Lifecycle = require('modules/Lifecycle')
local DerivedState = require('modules/DerivedState')
local EventEmitter = require('modules/EventEmitter')
local BlackboardCache = require('modules/BlackboardCache2')
local Storage = require('modules/Storage')
local Reference = require('modules/Reference')
local Logger = require('modules/Logger')
local Proximity = require('modules/Proximity')
local SpatialHash = require('modules/SpatialHash')
local Engine = {}

--##########################################
-- Event Emitters (Internal Bus)
--##########################################

local Events = {
    PlayerAction = EventEmitter.new(),
    VehicleMount = EventEmitter.new(),
    VehicleUnmount = EventEmitter.new(),
    StatusEffectAdded = EventEmitter.new(),
    StatusEffectRemoved = EventEmitter.new(),
    MenuOpen = EventEmitter.new(),
    MenuClose = EventEmitter.new(),
    CombatStateChanged = EventEmitter.new(),
    MovementStateChanged = EventEmitter.new(),
    VisionStateChanged = EventEmitter.new(),

    -- BlackboardCache (locomotion)
    LocomotionStateChanged = EventEmitter.new(),
    DetailedLocomotionChanged = EventEmitter.new(),
    SprintStateChanged = EventEmitter.new(),
    CrouchStateChanged = EventEmitter.new(),
    SlidingChanged = EventEmitter.new(),
    LadderChanged = EventEmitter.new(),
    FallingChanged = EventEmitter.new(),
    KnockdownChanged = EventEmitter.new(),
    HardLandingChanged = EventEmitter.new(),

    -- BlackboardCache (combat)
    UpperBodyStateChanged = EventEmitter.new(),
    AimStateChanged = EventEmitter.new(),
    WeaponStateChanged = EventEmitter.new(),
    TakedownChanged = EventEmitter.new(),

    -- BlackboardCache (body)
    SwimmingChanged = EventEmitter.new(),
    CarryingChanged = EventEmitter.new(),
    BodyCarryingChanged = EventEmitter.new(),

    -- BlackboardCache (vehicle)
    VehicleStateChanged = EventEmitter.new(),
    MountedToVehicleChanged = EventEmitter.new(),

    -- BlackboardCache (scene)
    SceneTierChanged = EventEmitter.new(),
    LandingChanged = EventEmitter.new(),

    -- Lifecycle
    PlayerReady = EventEmitter.new(),
    PlayerInvalidated = EventEmitter.new(),
    PlayerRecreated = EventEmitter.new(),

    -- Location
    DistrictChanged = EventEmitter.new(),

    -- Cover
    CoverDirectionChanged = EventEmitter.new()
}

--##########################################
-- Runtime Cache
--##########################################

local isPlaying = false
local isSessionLoaded = false
local currentFrame = 0
local frameEmitters = {}

-- Cached TweakDB IDs (avoid per-call allocation)
local combatEffectId = nil

--##########################################
-- Central State
--##########################################

local State = {
    player = Reference(nil),
    pos = nil,
    yaw = 0,
    orientation = nil,
    inMenu = false,
    inCombat = false,
    inVehicle = false,
    time = 0,
    frame = 0,

    derived = {},
    blackboard = BlackboardCache.Get()
}

--##########################################
-- Internal Helpers
--##########################################

local function GetPlayer()
    return State.player()
end

-- Deep read-only proxy: recursively freezes nested tables
local proxyCache = {}

local function DeepReadOnly(tbl, path)
    if proxyCache[tbl] then return proxyCache[tbl] end

    local proxy = setmetatable({}, {
        __index = function(_, k)
            local v = tbl[k]
            if type(v) == "table" then
                return DeepReadOnly(v, (path or "state") .. "." .. tostring(k))
            end
            return v
        end,
        __newindex = function()
            error("[0-Engine] Attempt to modify read-only " .. (path or "state"))
        end,
        __len = function()
            return #tbl
        end,
        __pairs = function()
            return next, tbl, nil
        end
    })

    proxyCache[tbl] = proxy
    return proxy
end

local stateProxy = nil

-- Invalidate proxy cache when nested tables are replaced
local function InvalidateProxyCache()
    proxyCache = {}
    stateProxy = nil
end

--##########################################
-- WhenReady Queue (must be declared before UpdateFrame)
--##########################################

-- Staggered WhenReady queue with priority levels.
-- Priority 1 = fire first (critical infrastructure), 5 = fire last (safest, most deps available).
-- Default priority: 3. Within each priority, callbacks fire in registration order.
-- Drains readyBatchSize callbacks per frame across all priorities, lowest first.
local readyPriorityCount = 5
local readyQueues = { {}, {}, {}, {}, {} }
local readyQueueCount = 0   -- tracked counter: avoids iterating all 5 queues every frame
local readyBatchSize = 5    -- callbacks per frame (5 = ~6 frames to init 30 mods)

local function ReadyQueueTotal()
    return readyQueueCount
end

local function DrainReadyQueue()
    if readyQueueCount == 0 then return end

    local drained = 0
    for p = 1, readyPriorityCount do
        local q = readyQueues[p]
        while drained < readyBatchSize and #q > 0 do
            local entry = table.remove(q, 1)
            readyQueueCount = readyQueueCount - 1
            local ok, err = pcall(entry.fn, entry.player)
            if not ok then
                Logger.Log("0-Engine", "WhenReady error (priority " .. p .. "): " .. tostring(err), "error")
            end
            drained = drained + 1
        end
        if drained >= readyBatchSize then break end
    end

    if readyQueueCount > 0 then
        Logger.Log("0-Engine", "WhenReady queue: " .. tostring(readyQueueCount) .. " remaining", "debug")
    end
end

local function QueueReadyCallback(fn, player, priority)
    priority = priority or 3
    if priority < 1 then priority = 1 end
    if priority > readyPriorityCount then priority = readyPriorityCount end
    table.insert(readyQueues[priority], { fn = fn, player = player })
    readyQueueCount = readyQueueCount + 1
end

--##########################################
-- Frame Update
--##########################################

local function UpdateFrame(delta)
    currentFrame = currentFrame + 1
    State.frame = currentFrame
    State.time = State.time + delta

    Logger.SetFrame(currentFrame)

    -- Re-sync from GameSession's live state each frame; the On callback isn't re-fired
    -- after a save flicker, so cached flags could otherwise stick until a menu toggle.
    local okLive, liveLoaded = pcall(GameSession.IsLoaded)
    if okLive then
        isSessionLoaded = liveLoaded
        local okPaused, livePaused = pcall(GameSession.IsPaused)
        isPlaying = liveLoaded and not (okPaused and livePaused)
    end

    -- No session loaded (main menu, loading screen) - skip all game object access.
    -- Lifecycle.ForceInvalidate() already fired from GameSession callback.
    if not isSessionLoaded then return end

    Lifecycle.SetFrame(currentFrame)
    Lifecycle.Update()

    -- Blackboard poll independent of Lifecycle warmup/recovery. Cache holds its own
    -- playerBB ref and no-ops if nil, so transitions are detected across flicker windows.
    local pcOk, pc = pcall(Game.GetPlayer)
    if pcOk and pc then
        pcall(BlackboardCache.Update, pc)
        State.blackboard = BlackboardCache.Get()
        State.inVehicle = State.blackboard.vehicle.isMounted or State.blackboard.psm.mountedToVehicle
    end

    if not Lifecycle.IsPlayerValid() then return end
    local player = State.player()
    if not player then return end

    -- Staggered WhenReady queue - drain early so callbacks fire even if
    -- state reads below fail (position/orientation pcall guards).
    -- The queue only needs a valid player, not full state.
    DrainReadyQueue()

    -- Position + Orientation (consolidated pcall - saves one error handler setup per frame)
    local posOriOk, pos, orientation, yaw = pcall(function()
        local p = player:GetWorldPosition()
        local o = player:GetWorldOrientation()
        return p, o, o:ToEulerAngles().yaw
    end)
    if not posOriOk then return end
    State.pos = pos
    State.orientation = orientation
    State.yaw = yaw

    -- Derived State (player-dependent; BB already updated above)
    local stateOk = pcall(DerivedState.Update, player)
    if not stateOk then return end
    State.derived = DerivedState.Get()

    -- Proximity zones
    Proximity.SetPlayerPos(pos)
    pcall(Proximity.Update, currentFrame)

    -- Spatial Hash
    SpatialHash.SetPlayerPos(pos)
    pcall(SpatialHash.Update, currentFrame)

    -- Throttled Frame Dispatcher
    for interval, emitter in pairs(frameEmitters) do
        if currentFrame % interval == 0 then
            emitter:trigger(currentFrame)
        end
    end
end

--##########################################
-- Public API
--##########################################

function Engine.GetState()
    if not stateProxy then
        stateProxy = DeepReadOnly(State, "state")
    end
    return stateProxy
end

function Engine.GetPlayer()
    return GetPlayer()
end

function Engine.IsPlaying()
    return isPlaying
end

function Engine.GetVersion()
    return engineVersion
end

--##########################################
-- Lifecycle Convenience API
--##########################################

--- Fires fn immediately if player is already valid, otherwise subscribes to PlayerReady.
--- Also subscribes to PlayerRecreated so fn fires on reload/respawn.
--- Callbacks are staggered across frames to prevent initialization pile-ups.
---@param fn function callback receiving (player)
---@param source string|nil explicit source label
---@param priority number|nil 1-5 (1=first, 5=last, default 3)
---@return table handle with unsubscribe method
function Engine.WhenReady(fn, source, priority)
    if type(fn) ~= "function" then
        Logger.Log("0-Engine", "WhenReady: expected function, got " .. type(fn), "warn")
        return { unsubscribe = function() end }
    end

    priority = priority or 3

    if Lifecycle.IsPlayerValid() then
        -- still stagger even for late arrivals - they might register during the
        -- first few frames while the queue is still draining
        QueueReadyCallback(fn, GetPlayer(), priority)
    end

    local readySub = Events.PlayerReady:subscribe(function(player)
        QueueReadyCallback(fn, player, priority)
    end, source)
    local recreatedSub = Events.PlayerRecreated:subscribe(function(player)
        QueueReadyCallback(fn, player, priority)
    end, source)

    return {
        unsubscribe = function()
            readySub.unsubscribe()
            recreatedSub.unsubscribe()
            -- also remove from queue if still pending
            for p = 1, readyPriorityCount do
                for i = #readyQueues[p], 1, -1 do
                    if readyQueues[p][i].fn == fn then
                        table.remove(readyQueues[p], i)
                        readyQueueCount = readyQueueCount - 1
                    end
                end
            end
        end
    }
end

--##########################################
-- Frame Dispatcher API
--##########################################

--- Subscribes to every frame update
---@param fn function callback receiving (frameCount)
---@param source string|nil explicit source label
---@return table handle with unsubscribe method
function Engine.OnUpdate(fn, source)
    return Engine.OnFrame(1, fn, source)
end

--- Subscribes to a specific frame interval
---@param interval number the frame interval (e.g. 5 for every 5th frame)
---@param fn function the callback function
---@param source string|nil explicit source label
---@return table handle with unsubscribe method
function Engine.OnFrame(interval, fn, source)
    if type(interval) ~= "number" or interval < 1 then
        Logger.Log("0-Engine", "OnFrame: Invalid interval: " .. tostring(interval), "warn")
        return { unsubscribe = function() end }
    end

    interval = math.floor(interval)

    if not frameEmitters[interval] then
        frameEmitters[interval] = EventEmitter.new()
    end

    local innerHandle = frameEmitters[interval]:subscribe(fn, source)
    return {
        unsubscribe = function()
            innerHandle.unsubscribe()
            -- Clean up empty emitters so the overlay doesn't show "0 listeners" entries
            if frameEmitters[interval] and frameEmitters[interval]:getListenerCount() == 0 then
                frameEmitters[interval] = nil
            end
        end
    }
end

--##########################################
-- Cron Wrappers
--##########################################

function Engine.SetTimeout(delay, fn)
    return Cron.After(delay, fn)
end

function Engine.SetInterval(interval, fn)
    return Cron.Every(interval, fn)
end

function Engine.SetNextTick(fn)
    return Cron.NextTick(fn)
end

function Engine.ClearTimer(handle)
    if handle and type(handle) == "table" and handle.Cancel then
        handle:Cancel()
    end
end

--##########################################
-- Storage API
--##########################################

function Engine.SetData(modName, key, value)
    Storage.Set(modName, key, value)
end

function Engine.GetData(modName, key, defaultValue)
    return Storage.Get(modName, key, defaultValue)
end

function Engine.SaveData()
    Storage.Save()
end

function Engine.ClearData(modName)
    Storage.Clear(modName)
end

--##########################################
-- Logging API
--##########################################

--- Logs a message through the centralized logger
---@param modName string the name of the calling mod
---@param message string the log message
---@param level string|nil "debug", "info", "warn", "error" (default: "info")
function Engine.Log(modName, message, level)
    Logger.Log(modName, message, level)
end

--- Sets the minimum log level
---@param level string "debug", "info", "warn", "error"
function Engine.SetLogLevel(level)
    Logger.SetLevel(level)
end

--- Toggles the ImGui log overlay
---@param enabled boolean
function Engine.SetLogOverlay(enabled)
    Logger.SetOverlay(enabled)
end

--##########################################
-- Proximity API
--##########################################

--- Returns whether the player is within radius meters of a world point
---@param x number
---@param y number
---@param z number
---@param radius number
---@return boolean
function Engine.IsNear(x, y, z, radius)
    return Proximity.IsNear(x, y, z, radius)
end

--- Returns the distance in meters from the player to a world point
---@param x number
---@param y number
---@param z number
---@return number distance in meters, or -1 if unavailable
function Engine.DistanceTo(x, y, z)
    return Proximity.DistanceTo(x, y, z)
end

--- Registers a proximity zone with enter/exit/tick callbacks
--- Config: { id, x, y, z, radius, onEnter, onExit, onTick, throttle }
--- onEnter(distance) - called when player enters the zone
--- onExit(distance) - called when player leaves the zone
--- onTick(distance) - called each check while player is inside
--- throttle - check every N frames (default 5)
---@param config table
---@return table handle with unregister method
function Engine.RegisterZone(config)
    return Proximity.RegisterZone(config)
end

--- Returns the current district name
---@return string
function Engine.GetDistrict()
    return State.derived.district or "Unknown"
end

--##########################################
-- Spatial Hash API
--##########################################

--- Register a named set of spatial entries with optional auto-poll.
--- Config: { gridSize, pollRadius, pollThrottle, onEnter(entry, distSq), onExit(entry), onNearest(entry, distSq) }
---@param name string unique set name
---@param entries table[] array of {x, y, z, ...metadata}
---@param config table|nil
---@return table|nil handle with :remove(entry), :rebuild(entries?), :clear(), :unregister(), :count()
function Engine.RegisterSpatialSet(name, entries, config)
    return SpatialHash.RegisterSpatialSet(name, entries, config)
end

--- Returns nearest entry + distSq within squared radius of player, or nil.
---@param setName string
---@param radiusSq number
---@return table|nil entry, number|nil distSq
function Engine.QueryNearest(setName, radiusSq)
    return SpatialHash.QueryNearest(setName, radiusSq)
end

--- Returns all entries within squared radius of player.
---@param setName string
---@param radiusSq number
---@return table[] entries (each with _distSq field set)
function Engine.QueryWithin(setName, radiusSq)
    return SpatialHash.QueryWithin(setName, radiusSq)
end

--- Remove a single entry from a spatial set (lazy removal).
---@param setName string
---@param entry table
function Engine.RemoveSpatialEntry(setName, entry)
    SpatialHash.RemoveSpatialEntry(setName, entry)
end

--- Rebuild a spatial set's grid. Optional new entries array.
---@param setName string
---@param newEntries table[]|nil
function Engine.RebuildSpatialSet(setName, newEntries)
    SpatialHash.RebuildSpatialSet(setName, newEntries)
end

--##########################################
-- Mod Registration
--##########################################

local registeredMods = {}  -- name -> mod record

-- Wraps a callback so it's skipped when the owning mod is disabled.
local function wrapForMod(mod, fn)
    return function(...)
        if not mod.enabled then return end
        return fn(...)
    end
end

local function wrapZoneConfig(mod, config)
    local wrapped = {}
    for k, v in pairs(config) do wrapped[k] = v end
    if wrapped.onEnter then wrapped.onEnter = wrapForMod(mod, wrapped.onEnter) end
    if wrapped.onExit then wrapped.onExit = wrapForMod(mod, wrapped.onExit) end
    if wrapped.onTick then wrapped.onTick = wrapForMod(mod, wrapped.onTick) end
    return wrapped
end

local function wrapSpatialConfig(mod, config)
    if not config then return nil end
    local wrapped = {}
    for k, v in pairs(config) do wrapped[k] = v end
    if wrapped.onEnter then wrapped.onEnter = wrapForMod(mod, wrapped.onEnter) end
    if wrapped.onExit then wrapped.onExit = wrapForMod(mod, wrapped.onExit) end
    if wrapped.onNearest then wrapped.onNearest = wrapForMod(mod, wrapped.onNearest) end
    return wrapped
end

--- Register a mod with 0-Engine. Returns a scoped handle with all Engine methods.
--- All callbacks are tagged to the mod for tracking and bulk enable/disable.
--- Unregistered mods can still use Engine.* directly (backward compat).
---@param name string unique mod name
---@return table|nil scoped handle, or nil if name already taken
function Engine.Register(name)
    if type(name) ~= "string" or name == "" then
        Logger.Log("0-Engine", "Register: invalid mod name", "warn")
        return nil
    end

    if registeredMods[name] then
        Logger.Log("0-Engine", "Register: '" .. name .. "' already registered", "warn")
        return registeredMods[name].handle
    end

    local mod = {
        name = name,
        enabled = true,
        subs = {},       -- { handle, event }
        timers = {},     -- { handle }
        zones = {},      -- { handle }
        spatials = {},   -- { handle }
        frames = {},     -- { handle }
        readySubs = {},  -- { handle }
        handle = nil     -- set below
    }

    local Mod = {}

    -- Core state (pass-through, not mod-gated - these are reads)
    Mod.GetState = Engine.GetState
    Mod.GetPlayer = Engine.GetPlayer
    Mod.IsPlaying = Engine.IsPlaying
    Mod.GetVersion = Engine.GetVersion
    Mod.GetDistrict = Engine.GetDistrict
    Mod.IsNear = Engine.IsNear
    Mod.DistanceTo = Engine.DistanceTo
    Mod.QueryNearest = Engine.QueryNearest
    Mod.QueryWithin = Engine.QueryWithin
    Mod.RemoveSpatialEntry = Engine.RemoveSpatialEntry
    Mod.RebuildSpatialSet = Engine.RebuildSpatialSet

    -- Auto-removes from mod.subs on unsubscribe so overlay counts stay accurate.
    function Mod.Subscribe(eventName, fn)
        local wrapped = wrapForMod(mod, fn)
        local handle = Engine.Subscribe(eventName, wrapped, name)
        local entry = { handle = handle, event = eventName }
        table.insert(mod.subs, entry)
        local originalUnsub = handle.unsubscribe
        handle.unsubscribe = function()
            originalUnsub()
            for i = #mod.subs, 1, -1 do
                if mod.subs[i] == entry then
                    table.remove(mod.subs, i)
                    break
                end
            end
        end
        return handle
    end

    function Mod.WhenReady(fn, priority)
        local wrapped = wrapForMod(mod, fn)
        local handle = Engine.WhenReady(wrapped, name, priority)
        table.insert(mod.readySubs, handle)
        local originalUnsub = handle.unsubscribe
        handle.unsubscribe = function()
            originalUnsub()
            for i = #mod.readySubs, 1, -1 do
                if mod.readySubs[i] == handle then
                    table.remove(mod.readySubs, i)
                    break
                end
            end
        end
        return handle
    end

    function Mod.OnUpdate(fn)
        return Mod.OnFrame(1, fn)
    end

    function Mod.OnFrame(interval, fn)
        local wrapped = wrapForMod(mod, fn)
        local handle = Engine.OnFrame(interval, wrapped, name)
        table.insert(mod.frames, handle)
        local originalUnsub = handle.unsubscribe
        handle.unsubscribe = function()
            originalUnsub()
            for i = #mod.frames, 1, -1 do
                if mod.frames[i] == handle then
                    table.remove(mod.frames, i)
                    break
                end
            end
        end
        return handle
    end

    -- One-shot timers self-remove from mod.timers after firing; otherwise dead
    -- handles accumulate and inflate overlay counts.
    local function trackOneShot(fn)
        local handle
        local wrapped = wrapForMod(mod, function(...)
            fn(...)
            for i = #mod.timers, 1, -1 do
                if mod.timers[i] == handle then
                    table.remove(mod.timers, i)
                    break
                end
            end
        end)
        return wrapped, function(h) handle = h end
    end

    function Mod.SetTimeout(delay, fn)
        local wrapped, setHandle = trackOneShot(fn)
        local handle = Cron.After(delay, wrapped)
        setHandle(handle)
        table.insert(mod.timers, handle)
        return handle
    end

    function Mod.SetInterval(interval, fn)
        local wrapped = wrapForMod(mod, fn)
        local handle = Cron.Every(interval, wrapped)
        table.insert(mod.timers, handle)
        return handle
    end

    function Mod.SetNextTick(fn)
        local wrapped, setHandle = trackOneShot(fn)
        local handle = Cron.NextTick(wrapped)
        setHandle(handle)
        table.insert(mod.timers, handle)
        return handle
    end

    function Mod.ClearTimer(handle)
        Engine.ClearTimer(handle)
        for i = #mod.timers, 1, -1 do
            if mod.timers[i] == handle then
                table.remove(mod.timers, i)
                break
            end
        end
    end

    function Mod.RegisterZone(config)
        local wrappedConfig = wrapZoneConfig(mod, config)
        wrappedConfig.source = name
        local handle = Proximity.RegisterZone(wrappedConfig)
        table.insert(mod.zones, handle)
        local originalUnreg = handle.unregister
        handle.unregister = function()
            originalUnreg()
            for i = #mod.zones, 1, -1 do
                if mod.zones[i] == handle then
                    table.remove(mod.zones, i)
                    break
                end
            end
        end
        return handle
    end

    function Mod.RegisterSpatialSet(setName, entries, config)
        local wrappedConfig = wrapSpatialConfig(mod, config)
        local handle = SpatialHash.RegisterSpatialSet(setName, entries, wrappedConfig, name)
        table.insert(mod.spatials, handle)
        local originalUnreg = handle.unregister
        handle.unregister = function()
            originalUnreg()
            for i = #mod.spatials, 1, -1 do
                if mod.spatials[i] == handle then
                    table.remove(mod.spatials, i)
                    break
                end
            end
        end
        return handle
    end

    function Mod.SetData(key, value)
        Storage.Set(name, key, value)
    end

    function Mod.GetData(key, defaultValue)
        return Storage.Get(name, key, defaultValue)
    end

    function Mod.SaveData()
        Storage.Save()
    end

    function Mod.ClearData()
        Storage.Clear(name)
    end

    function Mod.Log(message, level)
        Logger.Log(name, message, level)
    end

    mod.handle = Mod
    registeredMods[name] = mod
    Logger.Log("0-Engine", "Mod registered: " .. name, "info")
    return Mod
end

--- Disable a registered mod - all its callbacks are silently skipped.
---@param name string
function Engine.DisableMod(name)
    local mod = registeredMods[name]
    if not mod then
        Logger.Log("0-Engine", "DisableMod: '" .. tostring(name) .. "' not registered", "warn")
        return
    end
    mod.enabled = false
    Logger.Log("0-Engine", "Mod disabled: " .. name, "info")
end

--- Re-enable a previously disabled mod.
---@param name string
function Engine.EnableMod(name)
    local mod = registeredMods[name]
    if not mod then
        Logger.Log("0-Engine", "EnableMod: '" .. tostring(name) .. "' not registered", "warn")
        return
    end
    mod.enabled = true
    Logger.Log("0-Engine", "Mod enabled: " .. name, "info")
end

--- Check if a mod is registered.
---@param name string
---@return boolean
function Engine.IsModRegistered(name)
    return registeredMods[name] ~= nil
end

--- Check if a registered mod is currently enabled.
---@param name string
---@return boolean
function Engine.IsModEnabled(name)
    local mod = registeredMods[name]
    return mod ~= nil and mod.enabled
end

--- Returns info about all registered mods (for overlay).
---@return table[]
function Engine.GetRegisteredMods()
    local result = {}
    for modName, mod in pairs(registeredMods) do
        -- Collect unique event names this mod subscribes to
        local eventNames = {}
        local eventSeen = {}
        for _, entry in ipairs(mod.subs) do
            if not eventSeen[entry.event] then
                eventSeen[entry.event] = true
                table.insert(eventNames, entry.event)
            end
        end
        table.sort(eventNames)

        table.insert(result, {
            name = modName,
            enabled = mod.enabled,
            subs = #mod.subs,
            timers = #mod.timers,
            zones = #mod.zones,
            spatials = #mod.spatials,
            frames = #mod.frames,
            readySubs = #mod.readySubs,
            eventNames = eventNames
        })
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

--##########################################
-- Event Subscription
--##########################################

function Engine.Subscribe(eventName, fn, source)
    local proxy = Events[eventName]

    if proxy then
        return proxy:subscribe(fn, source)
    else
        Logger.Log("0-Engine", "Unknown event: " .. tostring(eventName), "warn")
        return { unsubscribe = function() end }
    end
end

--- Returns a list of all available event names
---@return string[]
function Engine.GetEventNames()
    local names = {}
    for name, _ in pairs(Events) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

--##########################################
-- Deprecated Guards
--##########################################

function Engine.GetCron()
    Logger.Log("0-Engine", "Direct Cron access is deprecated. Use Engine.SetTimeout/SetInterval.", "warn")
    return Cron
end

--##########################################
-- Initialization
--##########################################

registerForEvent("onInit", function()

    State.pos = Vector4.new(0, 0, 0, 0)
    State.player:set(nil)

    -- Cache TweakDB IDs
    combatEffectId = TweakDBID.new("BaseStatusEffect.Combat")

    ------------------------------------------------
    -- Game Session
    ------------------------------------------------

    GameSession.On(function(state)
        -- Quick/auto saves emit a transient isLoaded=false with the player still
        -- attached; treat that as a flicker (stay loaded, skip the reset). A real
        -- session unload detaches the player, so it still cleans up below.
        local loaded = state.isLoaded
        if not loaded then
            local ok, p = pcall(Game.GetPlayer)
            if ok and p then
                local okAttached, attached = pcall(function() return p:IsAttached() end)
                if okAttached and attached then loaded = true end
            end
        end

        isPlaying = loaded and not state.isPaused
        isSessionLoaded = loaded
        DerivedState.SetLoading(not loaded)

        -- Real session unload only: wipe caches before invalidating so prior-session
        -- state can't bleed in.
        if not loaded then
            BlackboardCache.Reset()
            Proximity.Reset()
            SpatialHash.Reset()
            Lifecycle.ForceInvalidate()
        end
    end)

    local sessionState = GameSession.GetState()
    isPlaying = sessionState.isLoaded and not sessionState.isPaused
    isSessionLoaded = sessionState.isLoaded

    ------------------------------------------------
    -- Lifecycle init
    ------------------------------------------------

    Lifecycle.Init(Events, State, Logger)

    -- Derived state init (needs Events for DistrictChanged)
    DerivedState.Init(Events)

    -- Lightweight cleanup only - Proximity / SpatialHash resets live in the
    -- GameSession callback above so transient flickers preserve their entries.
    Events.PlayerInvalidated:subscribe(function()
        DerivedState.Reset()
        InvalidateProxyCache()
        for p = 1, readyPriorityCount do readyQueues[p] = {} end
        readyQueueCount = 0
    end)

    ------------------------------------------------
    -- Blackboard init (CET-native - direct blackboard access)
    ------------------------------------------------

    BlackboardCache.Init(Events)

    Events.PlayerReady:subscribe(function(player)
        BlackboardCache.Attach(player)
    end)

    Events.PlayerRecreated:subscribe(function(player)
        -- don't Reset() here - the player's gameplay state hasn't changed, only the entity ID.
        -- resetting clears psm.mountedToVehicle to false, which causes a phantom VehicleMount
        -- event on the next Update() when the blackboard reads the (still true) mount flag.
        BlackboardCache.Attach(player)
    end)

    Events.PlayerInvalidated:subscribe(function()
        -- Detach only; Reset lives in the GameSession callback above.
        BlackboardCache.Detach()
    end)

    -- Fallback: If player already exists (e.g. CET reload mid-game), attach immediately
    if Game.GetPlayer() then
        BlackboardCache.Attach(Game.GetPlayer())
    end

    ------------------------------------------------
    -- Storage init
    ------------------------------------------------

    Storage.Init()

    ------------------------------------------------
    -- Player Action Observer
    ------------------------------------------------

    Observe('PlayerPuppet', 'OnAction', function(_, action)
        if not isPlaying or State.inMenu then return end
        Events.PlayerAction:trigger(action)
    end)

    ------------------------------------------------
    -- Status Effects Observers
    ------------------------------------------------

    Observe('StatusEffectSystem', 'ApplyStatusEffect', function(_, target, effect)
        pcall(function()
            local player = GetPlayer()
            if not player or not target or not IsDefined(target) or not Ref.Equals(target, player) then return end
            if not effect or not IsDefined(effect) then return end
            Events.StatusEffectAdded:trigger(effect)

            -- Combat State Tracking
            if effect:GetRecord():GetID() == combatEffectId then
                State.inCombat = true
                Events.CombatStateChanged:trigger(true)
            end
        end)
    end)

    Observe('StatusEffectSystem', 'RemoveStatusEffect', function(_, target, effect)
        pcall(function()
            local player = GetPlayer()
            if not player or not target or not IsDefined(target) or not Ref.Equals(target, player) then return end
            if not effect or not IsDefined(effect) then return end
            Events.StatusEffectRemoved:trigger(effect)

            -- Combat State Tracking
            if effect:GetRecord():GetID() == combatEffectId then
                State.inCombat = false
                Events.CombatStateChanged:trigger(false)
            end
        end)
    end)

    ------------------------------------------------
    -- Menu Tracking
    ------------------------------------------------

    GameUI.OnMenuOpen(function()
        State.inMenu = true
        Events.MenuOpen:trigger()
    end)

    GameUI.OnMenuClose(function()
        State.inMenu = false
        Events.MenuClose:trigger()
    end)

    -- Auto-save on menu close as a safety measure
    Events.MenuClose:subscribe(function()
        Storage.Save()
    end)

    Logger.Log("0-Engine", "Runtime v" .. engineVersion .. " initialized", "info")
end)

--##########################################
-- Main Update Loop
--##########################################

registerForEvent("onUpdate", function(delta)
    pcall(Cron.Update, delta)
    pcall(UpdateFrame, delta)
end)

registerForEvent("onShutdown", function()
    Storage.Save()
end)

--##########################################
-- CET Overlay Tab
--##########################################

local isOverlayOpen = false

registerForEvent("onOverlayOpen", function()
    isOverlayOpen = true
end)

registerForEvent("onOverlayClose", function()
    isOverlayOpen = false
end)

registerForEvent("onDraw", function()
    if isOverlayOpen then
        if ImGui.Begin("0-Engine") then
            ImGui.Text("v" .. engineVersion)
            ImGui.SameLine()
            ImGui.TextColored(0.5, 0.5, 0.5, 1, isPlaying and "Playing" or "Not playing")
            ImGui.Separator()

            ------------------------------------------------
            -- Logger
            ------------------------------------------------
            if ImGui.CollapsingHeader("Logger") then
                local overlayOn, overlayChanged = ImGui.Checkbox("Show Log Overlay", Logger.IsOverlayEnabled())
                if overlayChanged then
                    Logger.SetOverlay(overlayOn)
                end

                local levelNames = { "debug", "info", "warn", "error" }
                local currentLevel = Logger.GetLevel()
                local currentIdx = 0
                for i, name in ipairs(levelNames) do
                    if name == currentLevel then currentIdx = i - 1 end
                end
                local newIdx, levelChanged = ImGui.Combo("Log Level", currentIdx, levelNames, #levelNames)
                if levelChanged then
                    Logger.SetLevel(levelNames[newIdx + 1])
                end

                if ImGui.Button("Clear Log") then
                    Logger.Clear()
                end
            end

            ------------------------------------------------
            -- Event Subscribers
            ------------------------------------------------
            if ImGui.CollapsingHeader("Event Subscribers") then
                local names = {}
                local totalSubs = 0
                for name, emitter in pairs(Events) do
                    local count = emitter:getListenerCount()
                    totalSubs = totalSubs + count
                    table.insert(names, { name = name, count = count, emitter = emitter })
                end
                table.sort(names, function(a, b) return a.name < b.name end)

                ImGui.Text("Total: " .. tostring(totalSubs) .. " subscribers across " .. tostring(#names) .. " events")
                local queueTotal = ReadyQueueTotal()
                if queueTotal > 0 then
                    local parts = {}
                    for p = 1, readyPriorityCount do
                        if #readyQueues[p] > 0 then
                            table.insert(parts, "P" .. p .. "=" .. #readyQueues[p])
                        end
                    end
                    ImGui.TextColored(1.0, 1.0, 0.2, 1, "WhenReady queue: " .. tostring(queueTotal) .. " pending (" .. table.concat(parts, ", ") .. ")")
                end
                ImGui.Separator()

                for _, entry in ipairs(names) do
                    if entry.count > 0 then
                        ImGui.TextColored(0.4, 1.0, 0.4, 1, entry.name)
                        ImGui.SameLine()
                        ImGui.Text("(" .. tostring(entry.count) .. ")")
                        if ImGui.IsItemHovered() then
                            local sources = entry.emitter:getListenerSources()
                            if #sources > 0 then
                                ImGui.BeginTooltip()
                                for _, src in ipairs(sources) do
                                    ImGui.Text(src)
                                end
                                ImGui.EndTooltip()
                            end
                        end
                    else
                        ImGui.TextColored(0.5, 0.5, 0.5, 1, entry.name)
                    end
                end
            end

            ------------------------------------------------
            -- Frame Emitters
            ------------------------------------------------
            if ImGui.CollapsingHeader("Frame Emitters") then
                local count = 0
                local intervals = {}
                for interval, emitter in pairs(frameEmitters) do
                    count = count + 1
                    table.insert(intervals, { interval = interval, listeners = emitter:getListenerCount(), emitter = emitter })
                end
                table.sort(intervals, function(a, b) return a.interval < b.interval end)

                if count == 0 then
                    ImGui.TextColored(0.5, 0.5, 0.5, 1, "None")
                else
                    for _, entry in ipairs(intervals) do
                        ImGui.Text("Every " .. tostring(entry.interval) .. " frame(s)")
                        ImGui.SameLine()
                        ImGui.TextColored(0.4, 1.0, 0.4, 1, "(" .. tostring(entry.listeners) .. " listeners)")
                        if ImGui.IsItemHovered() then
                            local sources = entry.emitter:getListenerSources()
                            if #sources > 0 then
                                ImGui.BeginTooltip()
                                for _, src in ipairs(sources) do
                                    ImGui.Text(src)
                                end
                                ImGui.EndTooltip()
                            end
                        end
                    end
                end
            end

            ------------------------------------------------
            -- Proximity Zones
            ------------------------------------------------
            if ImGui.CollapsingHeader("Proximity Zones") then
                local zoneInfo = Proximity.GetZones()
                if #zoneInfo == 0 then
                    ImGui.TextColored(0.5, 0.5, 0.5, 1, "None")
                else
                    for _, z in ipairs(zoneInfo) do
                        if z.isInside then
                            ImGui.TextColored(0.4, 1.0, 0.4, 1, z.id)
                            ImGui.SameLine()
                            ImGui.Text("r=" .. string.format("%.1f", z.radius) .. "m")
                            ImGui.SameLine()
                            ImGui.TextColored(1.0, 1.0, 0.2, 1, "[INSIDE]")
                        else
                            ImGui.Text(z.id)
                            ImGui.SameLine()
                            ImGui.TextColored(0.5, 0.5, 0.5, 1, "r=" .. string.format("%.1f", z.radius) .. "m")
                        end
                        if ImGui.IsItemHovered() and z.source and z.source ~= "" then
                            ImGui.BeginTooltip()
                            ImGui.Text(z.source)
                            ImGui.EndTooltip()
                        end
                    end
                end
            end

            ------------------------------------------------
            -- Spatial Hash Sets
            ------------------------------------------------
            if ImGui.CollapsingHeader("Spatial Hash Sets") then
                local setInfo = SpatialHash.GetSetInfo()
                if #setInfo == 0 then
                    ImGui.TextColored(0.5, 0.5, 0.5, 1, "None")
                else
                    for _, s in ipairs(setInfo) do
                        ImGui.TextColored(0.4, 1.0, 0.4, 1, s.name)
                        ImGui.SameLine()
                        ImGui.Text(string.format("%d entries, %d cells, grid=%d",
                            s.entryCount, s.cellCount, s.gridSize))
                        if s.pollRadius then
                            ImGui.SameLine()
                            ImGui.TextColored(1.0, 1.0, 0.2, 1,
                                string.format("[poll r=%dm, active=%d]", s.pollRadius, s.activeCount))
                        end
                        if ImGui.IsItemHovered() and s.source and s.source ~= "unknown" then
                            ImGui.BeginTooltip()
                            ImGui.Text(s.source)
                            ImGui.EndTooltip()
                        end
                    end
                end
            end

            ------------------------------------------------
            -- Registered Mods
            ------------------------------------------------
            if ImGui.CollapsingHeader("Registered Mods") then
                local mods = Engine.GetRegisteredMods()
                if #mods == 0 then
                    ImGui.TextColored(0.5, 0.5, 0.5, 1, "None")
                else
                    for _, m in ipairs(mods) do
                        local toggled, changed = ImGui.Checkbox(m.name, m.enabled)
                        if changed then
                            if toggled then
                                Engine.EnableMod(m.name)
                            else
                                Engine.DisableMod(m.name)
                            end
                        end
                        local total = m.subs + m.timers + m.zones + m.spatials + m.frames
                        ImGui.SameLine()
                        ImGui.TextColored(0.5, 0.5, 0.5, 1, string.format("(%d callbacks)", total))
                        if ImGui.IsItemHovered() then
                            ImGui.BeginTooltip()
                            if m.subs > 0 then
                                ImGui.Text("Events (" .. tostring(m.subs) .. "):")
                                for _, evName in ipairs(m.eventNames) do
                                    ImGui.Text("  " .. evName)
                                end
                            end
                            if m.frames > 0 then ImGui.Text("Frames: " .. tostring(m.frames)) end
                            if m.timers > 0 then ImGui.Text("Timers: " .. tostring(m.timers)) end
                            if m.zones > 0 then ImGui.Text("Zones: " .. tostring(m.zones)) end
                            if m.spatials > 0 then ImGui.Text("Spatial Sets: " .. tostring(m.spatials)) end
                            if m.readySubs > 0 then ImGui.Text("WhenReady: " .. tostring(m.readySubs)) end
                            ImGui.EndTooltip()
                        end
                    end
                end
            end
        end
        ImGui.End()
    end

    Logger.Draw()
end)

return Engine