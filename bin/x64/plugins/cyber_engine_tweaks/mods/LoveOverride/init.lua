--[[
    LoveOverride - Admin Companion
    Cyberpunk 2077 Patch 2.31 / CET v1.37.0+

    Author: drixsm
    Mod Settings UI: LoveOverride -> Romance Unlocks
    CET Admin UI: optional testing panel, hidden by default.
]]

local Mod = {
    name = "LoveOverride",
    version = "0.1",
    targetGame = "Cyberpunk 2077 2.31",
    author = "drixsm"
}

local State = {
    open = false,
    overlayOpen = false,
    launcherOpen = false,
    launcherMinimized = false,
    page = "overview",
    allowDestructive = false,
    logs = {},
    maxLogs = 12
}

local Romances = {
    {
        id = "judy",
        name = "Judy Alvarez",
        vanilla = "Vanilla: feminine body + feminine voice",
        facts = {
            romanceable = "judy_romanceable",
            lover = "sq030_judy_lover",
            relationship = "judy_relationship",
            main = "q305_judy_romance"
        },
        note = "Best used before Pyramid Song / locked romance dialogue."
    },
    {
        id = "panam",
        name = "Panam Palmer",
        vanilla = "Vanilla: masculine body",
        facts = {
            romanceable = "panam_romanceable",
            lover = "sq027_panam_lover",
            relationship = "panam_relationship",
            main = "q113_panam_romance"
        },
        note = "Best used before Riders on the Storm / Queen of the Highway."
    },
    {
        id = "river",
        name = "River Ward",
        vanilla = "Vanilla: feminine body",
        facts = {
            romanceable = "river_romanceable",
            lover = "sq029_river_lover",
            relationship = "river_relationship",
            main = "q303_river_romance"
        },
        note = "Best used before Following the River."
    },
    {
        id = "kerry",
        name = "Kerry Eurodyne",
        vanilla = "Vanilla: masculine body + masculine voice",
        facts = {
            romanceable = "kerry_romanceable",
            lover = "sq028_kerry_lover",
            relationship = "sq028_kerry_relationship",
            main = "q110_kerry_romance"
        },
        note = "Best used before Boat Drinks."
    }
}

local function log(message)
    local line = os.date("%H:%M:%S") .. "  " .. tostring(message)
    table.insert(State.logs, 1, line)
    while #State.logs > State.maxLogs do
        table.remove(State.logs)
    end
    print("[LoveOverride] " .. tostring(message))
end

local function quests()
    if Game == nil or Game.GetQuestsSystem == nil then
        return nil
    end

    local ok, qs = pcall(function()
        return Game.GetQuestsSystem()
    end)

    if ok then
        return qs
    end

    return nil
end

local function isReady()
    return quests() ~= nil
end

local function readFact(fact)
    if fact == nil or fact == "" then
        return "-"
    end

    local qs = quests()
    if qs == nil then
        return "not ready"
    end

    local ok, value = pcall(function()
        return qs:GetFactStr(fact)
    end)

    if ok then
        return tostring(value)
    end

    return "error"
end

local function writeFact(fact, value)
    if fact == nil or fact == "" then
        return false
    end

    local qs = quests()
    if qs == nil then
        log("Quest system not ready. Load into a save first.")
        return false
    end

    local ok, err = pcall(function()
        qs:SetFactStr(fact, value)
    end)

    if ok then
        log(fact .. " = " .. tostring(value))
        return true
    end

    log("Failed to set " .. tostring(fact) .. ": " .. tostring(err))
    return false
end

local function unlockRomance(romance)
    writeFact(romance.facts.romanceable, 1)
end

local function lockRomance(romance)
    writeFact(romance.facts.romanceable, 0)
end

local function setRelationship(romance)
    writeFact(romance.facts.romanceable, 1)
    writeFact(romance.facts.lover, 1)
    writeFact(romance.facts.relationship, 1)
    writeFact(romance.facts.main, 1)
end

local function clearRelationship(romance)
    writeFact(romance.facts.lover, 0)
    writeFact(romance.facts.relationship, 0)
    writeFact(romance.facts.main, 0)
end

local function clearAllKnownFacts()
    for _, romance in ipairs(Romances) do
        writeFact(romance.facts.romanceable, 0)
        writeFact(romance.facts.lover, 0)
        writeFact(romance.facts.relationship, 0)
        writeFact(romance.facts.main, 0)
    end
end

local function unlockAll()
    for _, romance in ipairs(Romances) do
        unlockRomance(romance)
    end
end

local function setAllRelationships()
    for _, romance in ipairs(Romances) do
        setRelationship(romance)
    end
end

local function navButton(label, page, width)
    local activeLabel = label
    if State.page == page then
        activeLabel = "> " .. label
    end

    if ImGui.Button(activeLabel, width or 190, 30) then
        State.page = page
    end
end

local function statusLine(label, value)
    ImGui.Text(label .. ": " .. tostring(value))
end

local function renderHeader()
    ImGui.Text(Mod.name .. "  v" .. Mod.version .. " - Admin Panel")
    ImGui.Text("Author: " .. Mod.author .. " | Target: " .. Mod.targetGame)
    ImGui.Separator()

    if isReady() then
        ImGui.Text("Status: Quest system ready")
    else
        ImGui.Text("Status: Quest system not ready - load into a save first")
    end

    ImGui.Separator()
end

local function renderOverview()
    ImGui.Text("Overview")
    ImGui.TextWrapped("This panel is intentionally hidden by default. It is for testing, status checks and emergency manual control. The public user interface is the simple Mod Settings page with four switches.")
    ImGui.Separator()

    if ImGui.Button("Unlock all romance gates", 250, 32) then
        unlockAll()
    end

    ImGui.SameLine()

    if ImGui.Button("Set all as relationships", 250, 32) then
        setAllRelationships()
    end

    ImGui.Separator()
    ImGui.Text("Current quick status")

    for _, romance in ipairs(Romances) do
        local r = readFact(romance.facts.romanceable)
        local l = readFact(romance.facts.lover)
        local rel = readFact(romance.facts.relationship)
        local main = readFact(romance.facts.main)
        ImGui.Text(romance.name .. "  |  gate=" .. r .. "  lover=" .. l .. "  relationship=" .. rel .. "  main=" .. main)
    end
end

local function renderCharacters()
    ImGui.Text("Characters")
    ImGui.TextWrapped("Recommended order: backup save -> unlock romance gate -> play the quest naturally -> use relationship flags only if needed for testing.")
    ImGui.Separator()

    for _, romance in ipairs(Romances) do
        ImGui.Text(romance.name)
        ImGui.Text(romance.vanilla)
        ImGui.TextWrapped(romance.note)

        statusLine("romanceable / " .. romance.facts.romanceable, readFact(romance.facts.romanceable))
        statusLine("lover / " .. romance.facts.lover, readFact(romance.facts.lover))
        statusLine("relationship / " .. romance.facts.relationship, readFact(romance.facts.relationship))
        statusLine("main / " .. romance.facts.main, readFact(romance.facts.main))

        if ImGui.Button("Unlock gate##" .. romance.id, 130, 28) then
            unlockRomance(romance)
        end

        ImGui.SameLine()

        if ImGui.Button("Lock gate##" .. romance.id, 110, 28) then
            lockRomance(romance)
        end

        ImGui.SameLine()

        if ImGui.Button("Set relationship##" .. romance.id, 155, 28) then
            setRelationship(romance)
        end

        ImGui.SameLine()

        if ImGui.Button("Clear relationship##" .. romance.id, 155, 28) then
            clearRelationship(romance)
        end

        ImGui.Separator()
    end
end

local function renderAdvanced()
    ImGui.Text("Advanced / Reset")
    ImGui.TextWrapped("Destructive actions can break active quest states. Only use them on a backup save or when testing.")
    ImGui.Separator()

    State.allowDestructive = ImGui.Checkbox("Enable destructive actions", State.allowDestructive)

    if State.allowDestructive then
        if ImGui.Button("Clear all known romance facts", 280, 32) then
            clearAllKnownFacts()
        end
    else
        ImGui.Text("Destructive actions are locked.")
    end

    ImGui.Separator()
    ImGui.Text("Known facts")

    for _, romance in ipairs(Romances) do
        ImGui.Text(romance.name .. ": " .. romance.facts.romanceable .. ", " .. romance.facts.lover .. ", " .. romance.facts.relationship .. ", " .. romance.facts.main)
    end
end

local function renderLogs()
    ImGui.Text("Log")
    ImGui.TextWrapped("These are only this-session action logs. Also check cyber_engine_tweaks.log if something fails.")
    ImGui.Separator()

    if #State.logs == 0 then
        ImGui.Text("No actions yet.")
    else
        for _, line in ipairs(State.logs) do
            ImGui.Text(line)
        end
    end
end

local function renderInfo()
    ImGui.Text("Info")
    ImGui.TextWrapped("Version: 0.1")
    ImGui.TextWrapped("Target version: Cyberpunk 2077 2.31")
    ImGui.Separator()
    ImGui.TextWrapped("Limit: this mod changes quest facts. It does not add missing voice lines, animations, scene logic or custom romance content.")
end

local function renderLauncher()
    if State.launcherMinimized then
        ImGui.SetNextWindowSize(230, 82, ImGuiCond.FirstUseEver)

        if ImGui.Begin("LoveOverride Dock") then
            ImGui.Text("LoveOverride Admin")

            if ImGui.Button("Open Admin Panel", 190, 30) then
                State.open = true
                State.launcherOpen = false
                State.launcherMinimized = false
                log("Admin panel opened from dock")
            end
        end

        ImGui.End()
        return
    end

    ImGui.SetNextWindowSize(330, 145, ImGuiCond.FirstUseEver)

    if ImGui.Begin("LoveOverride Launcher") then
        ImGui.Text("LoveOverride Admin")
        ImGui.Text("CET-only testing panel")
        ImGui.Separator()

        if ImGui.Button("Open Admin Panel", 290, 32) then
            State.open = true
            State.launcherOpen = false
            State.launcherMinimized = false
            log("Admin panel opened from launcher")
        end

        if ImGui.Button("Minimize to Dock", 290, 28) then
            State.launcherOpen = true
            State.launcherMinimized = true
            log("Admin launcher minimized")
        end
    end

    ImGui.End()
end

local function renderMain()
    renderHeader()

    ImGui.BeginChild("LO_Navigation", 205, 430)
        navButton("Overview", "overview", 190)
        navButton("Characters", "characters", 190)
        navButton("Advanced", "advanced", 190)
        navButton("Log", "logs", 190)
        navButton("Info", "info", 190)

        ImGui.Separator()

        if ImGui.Button("Close window", 190, 30) then
            State.open = false
            State.launcherOpen = true
            State.launcherMinimized = true
        end
    ImGui.EndChild()

    ImGui.SameLine()

    ImGui.BeginChild("LO_Content", 655, 430)
        if State.page == "overview" then
            renderOverview()
        elseif State.page == "characters" then
            renderCharacters()
        elseif State.page == "advanced" then
            renderAdvanced()
        elseif State.page == "logs" then
            renderLogs()
        else
            renderInfo()
        end
    ImGui.EndChild()
end

local function openAdmin()
    State.open = true
    State.overlayOpen = true
    State.launcherOpen = false
    State.launcherMinimized = false
    log("Admin panel opened")
end

local function closeAdmin()
    State.open = false
    State.launcherOpen = true
    State.launcherMinimized = true
    log("Admin panel closed")
end

local function toggleAdmin()
    State.open = not State.open
    State.overlayOpen = true
    if State.open then
        State.launcherOpen = false
        State.launcherMinimized = false
    else
        State.launcherOpen = true
        State.launcherMinimized = true
    end
    log("Admin panel toggled: " .. tostring(State.open))
end

-- CET console fallback. Some CET builds isolate mod globals, so the launcher is the primary fallback.
-- These assignments are harmless if the console cannot see the mod environment.
if _G ~= nil then
    _G.LoveOverride_OpenAdmin = openAdmin
    _G.LoveOverride_CloseAdmin = closeAdmin
    _G.LoveOverride_ToggleAdmin = toggleAdmin
end

registerForEvent("onInit", function()
    log(Mod.name .. " loaded. Mod Settings UI active; admin panel hidden by default.")

    if registerHotkey ~= nil then
        registerHotkey("lo_toggle_admin_panel", "Toggle LoveOverride Admin Panel", toggleAdmin)
        registerHotkey("loveoverride_toggle_admin_panel_v01", "LoveOverride: Toggle Admin Panel", toggleAdmin)
        log("Admin hotkeys registered. Admin launcher/dock appears when CET overlay opens.")
    else
        log("registerHotkey unavailable. Admin launcher/dock appears when CET overlay opens.")
    end
end)

registerForEvent("onOverlayOpen", function()
    State.overlayOpen = true
    -- Small launcher only. The full admin panel still stays closed until opened deliberately.
    if not State.open then
        State.launcherOpen = true
        State.launcherMinimized = false
    end
end)

registerForEvent("onOverlayClose", function()
    State.overlayOpen = false
    State.open = false
    State.launcherOpen = false
    State.launcherMinimized = false
end)

registerForEvent("onDraw", function()
    -- Hard guard: nothing from the CET companion is rendered outside the CET overlay.
    if not State.overlayOpen then
        return
    end

    if State.launcherOpen and not State.open then
        renderLauncher()
    end

    if not State.open then
        return
    end

    ImGui.SetNextWindowSize(900, 560, ImGuiCond.FirstUseEver)

    if ImGui.Begin("LoveOverride Admin Panel") then
        renderMain()
    end

    ImGui.End()
end)
