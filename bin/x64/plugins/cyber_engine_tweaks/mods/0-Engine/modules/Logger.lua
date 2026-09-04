-- Logger.lua - leveled logging with ring buffer and optional ImGui overlay

local Logger = { version = '0.1.0' }

---@alias LogLevel "debug"|"info"|"warn"|"error"

local levels = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4
}

local levelTags = {
    debug = "DEBUG",
    info = "INFO",
    warn = "WARN",
    error = "ERROR"
}

local maxEntries = 256
local entries = {}
local entryCount = 0
local writeIndex = 0
local minLevel = levels.info
local showOverlay = false
local autoScroll = true

---@class LogEntry
---@field modName string
---@field message string
---@field level string
---@field timestamp number
---@field frame number

local currentFrame = 0

---Sets the current frame number (called by Engine each frame)
---@param frame number
function Logger.SetFrame(frame)
    currentFrame = frame
end

---Sets the minimum log level
---@param level LogLevel
function Logger.SetLevel(level)
    local l = levels[level]
    if l then
        minLevel = l
    end
end

---Returns the current minimum log level name
---@return string
function Logger.GetLevel()
    for name, val in pairs(levels) do
        if val == minLevel then return name end
    end
    return "info"
end

---Toggles the ImGui overlay
---@param enabled boolean
function Logger.SetOverlay(enabled)
    showOverlay = enabled == true
end

---Returns whether the overlay is enabled
---@return boolean
function Logger.IsOverlayEnabled()
    return showOverlay
end

---Logs a message
---@param modName string
---@param message string
---@param level LogLevel|nil defaults to "info"
function Logger.Log(modName, message, level)
    level = level or "info"
    local numLevel = levels[level] or levels.info
    local tag = levelTags[level] or "INFO"

    if numLevel < minLevel then return end

    local entry = {
        modName = modName,
        message = message,
        level = level,
        timestamp = os.clock(),
        frame = currentFrame
    }

    writeIndex = (writeIndex % maxEntries) + 1
    entries[writeIndex] = entry
    if entryCount < maxEntries then
        entryCount = entryCount + 1
    end

    print(string.format("[%s] [%s] %s", modName, tag, message))
end

---Returns recent log entries (newest first)
---@param count number|nil max entries to return (default 50)
---@param filterMod string|nil optional mod name filter
---@param filterLevel LogLevel|nil optional minimum level filter
---@return LogEntry[]
function Logger.GetEntries(count, filterMod, filterLevel)
    count = count or 50
    local filterLevelNum = filterLevel and levels[filterLevel] or nil
    local result = {}

    local idx = writeIndex
    local scanned = 0

    while #result < count and scanned < entryCount do
        local entry = entries[idx]
        if entry then
            local passLevel = not filterLevelNum or (levels[entry.level] or 0) >= filterLevelNum
            local passMod = not filterMod or entry.modName == filterMod

            if passLevel and passMod then
                table.insert(result, entry)
            end
        end

        idx = idx - 1
        if idx < 1 then idx = maxEntries end
        scanned = scanned + 1
    end

    return result
end

---Clears all log entries
function Logger.Clear()
    entries = {}
    entryCount = 0
    writeIndex = 0
end

---Draws the ImGui overlay (call from onDraw)
function Logger.Draw()
    if not showOverlay then return end

    ImGui.SetNextWindowSize(500, 300, ImGuiCond.FirstUseEver)
    if ImGui.Begin("0-Engine Log") then
        if ImGui.Button("Clear") then
            Logger.Clear()
        end
        ImGui.SameLine()
        if ImGui.Button("Close") then
            showOverlay = false
        end

        ImGui.SameLine()
        autoScroll, _ = ImGui.Checkbox("Auto-scroll", autoScroll)

        ImGui.Separator()
        ImGui.BeginChild("LogScroll")

        local recentEntries = Logger.GetEntries(100)
        for i = #recentEntries, 1, -1 do
            local e = recentEntries[i]
            local color = {1, 1, 1, 1}
            if e.level == "error" then
                color = {1, 0.3, 0.3, 1}
            elseif e.level == "warn" then
                color = {1, 0.8, 0.2, 1}
            elseif e.level == "debug" then
                color = {0.6, 0.6, 0.6, 1}
            end

            ImGui.PushStyleColor(ImGuiCol.Text, color[1], color[2], color[3], color[4])
            ImGui.TextWrapped(string.format("[%s] [%s] %s", e.modName, levelTags[e.level] or "INFO", e.message))
            ImGui.PopStyleColor()
        end

        -- Keep scroll pinned to newest entry
        if autoScroll then
            ImGui.SetScrollHereY(1.0)
        end

        ImGui.EndChild()
    end
    ImGui.End()
end

return Logger