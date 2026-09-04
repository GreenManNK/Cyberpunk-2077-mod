-- SpatialHash.lua - grid-based spatial indexing for batch coordinate queries

local Logger = require('modules/Logger')

local SpatialHash = { version = '0.1.0' }

local defaultGridSize = 100
local defaultPollThrottle = 30

local sets = {}
local playerPos = nil

local function getGridKey(x, y, gridSize)
    local gx = math.floor(x / gridSize)
    local gy = math.floor(y / gridSize)
    return (gx + 10000) * 20000 + (gy + 10000)
end

local function dist3Sq(ax, ay, az, bx, by, bz)
    local dx, dy, dz = ax - bx, ay - by, az - bz
    return dx * dx + dy * dy + dz * dz
end

local function buildGrid(setData)
    local grid = {}
    local cellCount = 0
    local gridSize = setData.config.gridSize or defaultGridSize

    for i, entry in ipairs(setData.entries) do
        if not entry._removed then
            local key = getGridKey(entry.x, entry.y, gridSize)
            if not grid[key] then
                grid[key] = {}
                cellCount = cellCount + 1
            end
            entry._idx = i
            table.insert(grid[key], entry)
        end
    end

    setData.grid = grid
    setData.cellCount = cellCount
end

local function compactAndRebuild(setData)
    local clean = {}
    for _, entry in ipairs(setData.entries) do
        if not entry._removed then
            table.insert(clean, entry)
        end
    end
    setData.entries = clean
    buildGrid(setData)
end

local function getSourceLabel(fn)
    if type(fn) ~= "function" then return "unknown" end
    if not debug or not debug.getinfo then return "unknown" end
    local ok, info = pcall(debug.getinfo, fn, "S")
    if not ok or not info or not info.source then return "unknown" end
    local modName = info.source:match("[/\\]mods[/\\]([^/\\]+)")
    if modName then return modName end
    return info.short_src or "unknown"
end

---Registers a named set of spatial entries
---@param name string unique set name
---@param entries table[] array of {x, y, z, ...metadata}
---@param config table|nil { gridSize, pollRadius, pollThrottle, onEnter, onExit, onNearest }
---@param source string|nil explicit source label (overrides debug.getinfo)
---@return table handle with :remove(), :rebuild(), :clear(), :unregister(), :count()
function SpatialHash.RegisterSpatialSet(name, entries, config, source)
    if type(name) ~= "string" or name == "" then
        Logger.Log("SpatialHash", "RegisterSpatialSet: name must be a non-empty string", "warn")
        return nil
    end
    if sets[name] then
        Logger.Log("SpatialHash", "Set '" .. name .. "' already registered - unregister first", "warn")
        return nil
    end

    config = config or {}
    entries = entries or {}

    local setData = {
        entries = entries,
        grid = {},
        cellCount = 0,
        config = {
            gridSize = config.gridSize or defaultGridSize,
            pollRadius = config.pollRadius,
            pollRadiusSq = config.pollRadius and (config.pollRadius * config.pollRadius) or nil,
            pollThrottle = config.pollThrottle or defaultPollThrottle,
            onEnter = config.onEnter,
            onExit = config.onExit,
            onNearest = config.onNearest,
        },
        activeEntries = {},
        nearestEntry = nil,
        removedCount = 0,
        source = source or getSourceLabel(config.onEnter or config.onExit or config.onNearest)
    }

    buildGrid(setData)
    sets[name] = setData

    Logger.Log("SpatialHash", string.format("Set '%s' registered: %d entries in %d cells (grid=%d)",
        name, #entries, setData.cellCount, setData.config.gridSize), "info")

    local handle = {}

    function handle:remove(entry)
        SpatialHash.RemoveSpatialEntry(name, entry)
    end

    function handle:rebuild(newEntries)
        SpatialHash.RebuildSpatialSet(name, newEntries)
    end

    function handle:clear()
        SpatialHash.RebuildSpatialSet(name, {})
    end

    function handle:unregister()
        sets[name] = nil
    end

    function handle:count()
        if not sets[name] then return 0 end
        return #sets[name].entries - sets[name].removedCount
    end

    return handle
end

---Returns nearest entry + distSq within radius of player, or nil
---@param setName string
---@param radiusSq number squared radius to search
---@return table|nil entry, number|nil distSq
function SpatialHash.QueryNearest(setName, radiusSq)
    local setData = sets[setName]
    if not setData or not playerPos then return nil, nil end

    local px, py, pz = playerPos.x, playerPos.y, playerPos.z
    local gridSize = setData.config.gridSize
    local grid = setData.grid

    local cellRadius = math.ceil(math.sqrt(radiusSq) / gridSize)
    if cellRadius < 1 then cellRadius = 1 end

    local nearest = nil
    local nearestDist = radiusSq

    for dx = -cellRadius, cellRadius do
        for dy = -cellRadius, cellRadius do
            local key = getGridKey(px + dx * gridSize, py + dy * gridSize, gridSize)
            local cell = grid[key]
            if cell then
                for _, entry in ipairs(cell) do
                    if not entry._removed then
                        local dSq = dist3Sq(px, py, pz, entry.x, entry.y, entry.z)
                        if dSq <= nearestDist then
                            nearestDist = dSq
                            nearest = entry
                        end
                    end
                end
            end
        end
    end

    if nearest then
        return nearest, nearestDist
    end
    return nil, nil
end

---Returns all entries within radius of player
---@param setName string
---@param radiusSq number squared radius to search
---@return table[] entries with _distSq field set
function SpatialHash.QueryWithin(setName, radiusSq)
    local setData = sets[setName]
    if not setData or not playerPos then return {} end

    local px, py, pz = playerPos.x, playerPos.y, playerPos.z
    local gridSize = setData.config.gridSize
    local grid = setData.grid

    local cellRadius = math.ceil(math.sqrt(radiusSq) / gridSize)
    if cellRadius < 1 then cellRadius = 1 end

    local results = {}

    for dx = -cellRadius, cellRadius do
        for dy = -cellRadius, cellRadius do
            local key = getGridKey(px + dx * gridSize, py + dy * gridSize, gridSize)
            local cell = grid[key]
            if cell then
                for _, entry in ipairs(cell) do
                    if not entry._removed then
                        local dSq = dist3Sq(px, py, pz, entry.x, entry.y, entry.z)
                        if dSq <= radiusSq then
                            entry._distSq = dSq
                            table.insert(results, entry)
                        end
                    end
                end
            end
        end
    end

    return results
end

---Lazily removes a single entry from a set (compacted on rebuild or at 25% threshold)
---@param setName string
---@param entry table the entry to remove
function SpatialHash.RemoveSpatialEntry(setName, entry)
    local setData = sets[setName]
    if not setData or not entry then return end

    entry._removed = true
    setData.removedCount = setData.removedCount + 1
    setData.activeEntries[entry] = nil

    if setData.removedCount > #setData.entries * 0.25 and setData.removedCount > 10 then
        compactAndRebuild(setData)
        setData.removedCount = 0
    end
end

---Rebuilds grid after bulk changes, optionally replacing entries
---@param setName string
---@param newEntries table[]|nil optional replacement entries
function SpatialHash.RebuildSpatialSet(setName, newEntries)
    local setData = sets[setName]
    if not setData then return end

    if newEntries then
        setData.entries = newEntries
    end

    setData.removedCount = 0
    setData.activeEntries = {}
    setData.nearestEntry = nil
    buildGrid(setData)

    Logger.Log("SpatialHash", string.format("Set '%s' rebuilt: %d entries in %d cells",
        setName, #setData.entries, setData.cellCount), "debug")
end

---Sets the current player position (called by Engine each frame)
---@param pos Vector4
function SpatialHash.SetPlayerPos(pos)
    playerPos = pos
end

---Runs auto-poll for sets with pollRadius configured (called by Engine each frame)
---@param frame number current frame count
function SpatialHash.Update(frame)
    if not playerPos then return end

    for name, setData in pairs(sets) do
        local cfg = setData.config
        if cfg.pollRadiusSq and frame % cfg.pollThrottle == 0 then
            local px, py, pz = playerPos.x, playerPos.y, playerPos.z
            local gridSize = cfg.gridSize
            local grid = setData.grid
            local pollRadiusSq = cfg.pollRadiusSq

            local cellRadius = math.ceil(cfg.pollRadius / gridSize)
            if cellRadius < 1 then cellRadius = 1 end

            local nowActive = {}
            local nearest = nil
            local nearestDist = math.huge

            for dx = -cellRadius, cellRadius do
                for dy = -cellRadius, cellRadius do
                    local key = getGridKey(px + dx * gridSize, py + dy * gridSize, gridSize)
                    local cell = grid[key]
                    if cell then
                        for _, entry in ipairs(cell) do
                            if not entry._removed then
                                local dSq = dist3Sq(px, py, pz, entry.x, entry.y, entry.z)
                                if dSq <= pollRadiusSq then
                                    nowActive[entry] = dSq
                                    if dSq < nearestDist then
                                        nearestDist = dSq
                                        nearest = entry
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local prevActive = setData.activeEntries

            if cfg.onEnter then
                for entry, dSq in pairs(nowActive) do
                    if not prevActive[entry] then
                        local ok, err = pcall(cfg.onEnter, entry, dSq)
                        if not ok then
                            Logger.Log("SpatialHash", "onEnter error in set '" .. name .. "': " .. tostring(err), "error")
                        end
                    end
                end
            end

            if cfg.onExit then
                for entry, _ in pairs(prevActive) do
                    if not nowActive[entry] then
                        local ok, err = pcall(cfg.onExit, entry)
                        if not ok then
                            Logger.Log("SpatialHash", "onExit error in set '" .. name .. "': " .. tostring(err), "error")
                        end
                    end
                end
            end

            if cfg.onNearest and nearest then
                if nearest ~= setData.nearestEntry then
                    local ok, err = pcall(cfg.onNearest, nearest, nearestDist)
                    if not ok then
                        Logger.Log("SpatialHash", "onNearest error in set '" .. name .. "': " .. tostring(err), "error")
                    end
                end
            end

            setData.activeEntries = nowActive
            setData.nearestEntry = nearest
        end
    end
end

---Resets active tracking (called on PlayerInvalidated)
function SpatialHash.Reset()
    playerPos = nil
    for _, setData in pairs(sets) do
        setData.activeEntries = {}
        setData.nearestEntry = nil
    end
end

---Returns info about all registered sets for the debug overlay
---@return table[] { name, entryCount, cellCount, activeCount, gridSize, source }
function SpatialHash.GetSetInfo()
    local info = {}
    for name, setData in pairs(sets) do
        local activeCount = 0
        for _ in pairs(setData.activeEntries) do activeCount = activeCount + 1 end

        table.insert(info, {
            name = name,
            entryCount = #setData.entries - setData.removedCount,
            cellCount = setData.cellCount,
            activeCount = activeCount,
            gridSize = setData.config.gridSize,
            pollRadius = setData.config.pollRadius,
            source = setData.source
        })
    end
    table.sort(info, function(a, b) return a.name < b.name end)
    return info
end

return SpatialHash
