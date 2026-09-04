-- REDLINE RAMPAGE v5.9 - self-contained CET combat HUD
-- No require() calls: CET's process-wide Lua module cache can collide across mods.

local CONFIG_FILE = "config.json"
local HORIZON = 10.0 -- Rolling 10-second combat window: a hit remains in DPS for its full window.
local SPREE_GAP = 30.0 -- A fight can pause for repositioning, looting, or a new wave without restarting the chain.
local DEATH_DEDUP_SECONDS = 5.0 -- Suppress duplicate callbacks, but permit entity-hash reuse in a long police fight.
local enabled = true
-- Native Settings values: palette 1=Blood Red, 2=Neon Cyan, 3=Toxic Gold; position axes 0=left/top, 1=center, 2=right/bottom.
-- Fresh installs default to Neon Cyan on the upper-left; saved in-game preferences override these values.
local palette = 2
local horizontalPosition = 0
local verticalPosition = 0
local hudScale = 1.0
local targetDps = 0.0
local displayDps = 0.0
local damageEvents = {}
local decayReferenceDps = 0.0
local lastUpdate = nil
local spreeCount = 0
local lastKill = nil
local countedDeaths = {}
local recentPlayerHits = {}
local killCount = 0
local previewUntil = 0.0
local peakDps = 0.0 -- Session record: retained across combat breaks until the game/reload session ends.
local killBannerUntil = 0.0
local activeStinger = nil
local lastStatusLabel = "COMBAT READY"
local combatUntil = 0.0
local menuOpen = false

local function now()
    local value = Game.GetEngineTime()
    return value and value:ToFloat() or 0.0
end

local function isMenuOpen()
    return menuOpen
end

local function isGameCombatActive()
    -- Native player combat state; unlike a UI blackboard this does not misclassify normal gameplay as a menu.
    local playerOk, player = pcall(function() return Game.GetPlayer() end)
    if not playerOk or player == nil then return false end
    local combatOk, inCombat = pcall(function() return player:IsInCombat() end)
    return combatOk and inCombat == true
end

local function resetCombatChain()
    -- Kill count is session-wide. Only the current linked-kill chain ends outside combat.
    spreeCount = 0
    lastKill = nil
    countedDeaths = {}
    recentPlayerHits = {}
    activeStinger = nil
    killBannerUntil = 0.0
    combatUntil = 0.0
end

local function loadConfig()
    local file = io.open(CONFIG_FILE, "r")
    if not file then return end
    local ok, data = pcall(json.decode, file:read("*a"))
    file:close()
    if not ok or type(data) ~= "table" then return end
    if type(data.enabled) == "boolean" then enabled = data.enabled end
    if type(data.palette) == "number" then palette = math.max(1, math.min(3, math.floor(data.palette))) end
    if type(data.horizontalPosition) == "number" then horizontalPosition = math.max(0, math.min(2, math.floor(data.horizontalPosition))) end
    if type(data.verticalPosition) == "number" then verticalPosition = math.max(0, math.min(2, math.floor(data.verticalPosition))) end
    if type(data.hudScale) == "number" then hudScale = math.max(0.75, math.min(2.0, data.hudScale)) end
end

local function saveConfig()
    local file = io.open(CONFIG_FILE, "w")
    if not file then return end
    file:write(json.encode({
        enabled = enabled,
        palette = palette,
        horizontalPosition = horizontalPosition,
        verticalPosition = verticalPosition,
        hudScale = hudScale
    }))
    file:close()
end

local function getPalette()
    if palette == 2 then return 0.05, 0.85, 1.0, 0.18, 0.42, 0.55 end -- Neon Cyan
    if palette == 3 then return 1.0, 0.68, 0.08, 0.46, 0.27, 0.03 end -- Toxic Gold
    return 1.0, 0.14, 0.18, 0.42, 0.06, 0.10 -- Blood Red
end

local function telemetryPosition(screenWidth, screenHeight, width)
    local margin = 52
    local x = horizontalPosition == 0 and margin or (horizontalPosition == 2 and screenWidth - width - margin or (screenWidth - width) * 0.5)
    local y = verticalPosition == 0 and math.max(132, screenHeight * 0.14) or (verticalPosition == 2 and screenHeight * 0.68 or screenHeight * 0.38)
    return x, y
end

local function updateDps(timestamp)
    if lastUpdate == nil then lastUpdate = timestamp end
    local total = 0.0
    local keepFrom = 1
    for i = 1, #damageEvents do
        local event = damageEvents[i]
        if timestamp - event.timestamp <= HORIZON then
            total = total + event.damage
        else
            keepFrom = i + 1
        end
    end
    if keepFrom > 1 then
        local kept = {}
        for i = keepFrom, #damageEvents do kept[#kept + 1] = damageEvents[i] end
        damageEvents = kept
    end
    targetDps = total / HORIZON
    -- Keep the display responsive on hits while preserving the measured 10-second value between events.
    local dt = math.max(0.0, timestamp - lastUpdate)
    local speed = targetDps > displayDps and 16.0 or 6.0
    displayDps = displayDps + (targetDps - displayDps) * (1.0 - math.exp(-speed * dt))
    lastUpdate = timestamp
end

local milestoneWords = {
    "CYBERPSYCHOSIS", "BLOOD MOON", "MEAT GRINDER", "BONE HARVEST", "GORESTORM",
    "RED SLAUGHTER", "CORPSE PILE", "BUTCHER'S RUN", "NIGHTMARE", "LEGENDARY"
}

local function spreeLabel(count)
    if count == 2 then return "DOUBLE KILL" end
    if count == 3 then return "TRIPLE KILL" end
    if count == 4 then return "QUADRA KILL" end
    if count == 5 then return "PENTA KILL" end
    if count == 6 then return "UNSTOPPABLE" end
    return nil
end

local function killHighlightLabel()
    -- Major combat milestones take priority at every tenth credited kill.
    if killCount >= 10 and killCount % 10 == 0 then
        local tier = math.floor(killCount / 10)
        return milestoneWords[((tier - 1) % #milestoneWords) + 1]
    end
    if spreeCount == 1 then return "FIRST BLOOD" end
    local label = spreeLabel(spreeCount)
    return label
end

local function stingerDuration(label, milestone, count)
    if count == 10 then return 5.5 end
    if milestone then return 4.5 end
    if label == "DOUBLE KILL" then return 2.7 end
    if label == "TRIPLE KILL" then return 3.0 end
    if label == "QUADRA KILL" then return 3.3 end
    if label == "PENTA KILL" then return 3.6 end
    if label == "UNSTOPPABLE" then return 4.0 end
    return 1.85 -- FIRST BLOOD
end

local creditPlayerKill

-- ScriptedPuppet is a component. Its own ID can differ from the owning NPC entity ID
-- across damage and defeat callbacks, so use the owner ID whenever CET exposes it.
local function entityIdKey(id)
    if id == nil then return nil end
    -- entEntityID is CET userdata. tostring(id) is the Lua wrapper address, not the stable game ID.
    local hashOk, hash = pcall(function() return id.hash end)
    if hashOk and hash ~= nil then return tostring(hash) end
    local getHashOk, value = pcall(function() return id:GetHash() end)
    if getHashOk and value ~= nil then return tostring(value) end
    return tostring(id)
end

local function puppetKey(target)
    if target == nil then return nil end
    local ownerOk, owner = pcall(function() return target:GetOwner() end)
    if ownerOk and owner ~= nil then
        local idOk, id = pcall(function() return owner:GetEntityID() end)
        if idOk and id ~= nil then return entityIdKey(id) end
    end
    local idOk, id = pcall(function() return target:GetEntityID() end)
    return idOk and id ~= nil and entityIdKey(id) or nil
end

local function damageFromHit(hitEvent)
    if hitEvent == nil or hitEvent.attackComputed == nil then return 0.0 end
    local computed = hitEvent.attackComputed
    local totalOk, total = pcall(function()
        return computed:GetTotalAttackValue(gamedataStatPoolType.Health)
    end)
    if totalOk and type(total) == "number" and total > 0 then return total end

    -- Quickhacks such as Short Circuit can report their value only in the elemental
    -- attack channels rather than the generic Health total exposed to CET.
    local typedTotal = 0.0
    for damageType = 0, 3 do
        local valueOk, value = pcall(function() return computed:GetAttackValue(damageType) end)
        if valueOk and type(value) == "number" and value > 0 then
            typedTotal = typedTotal + value
        end
    end
    return typedTotal
end

local function recordPlayerDamage(target, damageReceivedEvent)
    if damageReceivedEvent == nil or damageReceivedEvent.hitEvent == nil then return end
    local hitEvent = damageReceivedEvent.hitEvent
    if hitEvent.attackData == nil or hitEvent.attackComputed == nil then return end
    local instigator = hitEvent.attackData:GetInstigator()
    if instigator == nil or not instigator:IsPlayer() then return end

    local timestamp = now()
    local damage = damageFromHit(hitEvent)
    if type(damage) == "number" and damage > 0 then
        damageEvents[#damageEvents + 1] = { timestamp = timestamp, damage = damage }
        updateDps(timestamp)
        if targetDps > peakDps then
            peakDps = targetDps
        end
    else
        updateDps(timestamp)
    end

    -- Kill attribution only needs a stable hash and timestamp; do not retain CET objects.
    if target == nil then return end
    local id = puppetKey(target)
    if id == nil then return end
    recentPlayerHits[id] = timestamp
    local deadOk, dead = pcall(function() return target:IsDead() end)
    if deadOk and dead then creditPlayerKill(target, timestamp) end
end

creditPlayerKill = function(target, timestamp, playerOwnedDeath)
    if target == nil then return end
    local id = puppetKey(target)
    if id == nil then return end
    local lastPlayerHit = recentPlayerHits[id]
    local age = lastPlayerHit ~= nil and timestamp - lastPlayerHit or -1.0
    local previousDeath = countedDeaths[id]
    local alreadyCounted = type(previousDeath) == "number" and timestamp - previousDeath <= DEATH_DEDUP_SECONDS
    if not playerOwnedDeath and lastPlayerHit == nil then return end
    if not playerOwnedDeath and age > 8.0 then
        recentPlayerHits[id] = nil
        return
    end
    if alreadyCounted then return end
    recentPlayerHits[id] = nil
    countedDeaths[id] = timestamp
    killCount = killCount + 1
    local sameFight = lastKill ~= nil and (timestamp - lastKill <= SPREE_GAP or isGameCombatActive())
    spreeCount = sameFight and spreeCount + 1 or 1
    lastKill = timestamp
    local label = killHighlightLabel()
    if label ~= nil then
        lastStatusLabel = label
        local milestone = killCount >= 10 and killCount % 10 == 0
        activeStinger = { label = label, kill = killCount, milestone = milestone }
        -- Milestones persist through a simultaneous follow-up kill instead of being overwritten before a frame draws.
        killBannerUntil = timestamp + stingerDuration(label, milestone, killCount)
    end
    combatUntil = timestamp + SPREE_GAP
    print("[REDLINE RAMPAGE] Player kill credited: total=" .. tostring(killCount))
end

local function deathEventHasPlayerInstigator(evt)
    if evt == nil then return false end
    local instigatorOk, instigator = pcall(function() return evt.instigator end)
    if not instigatorOk or instigator == nil then return false end
    local playerOk, isPlayer = pcall(function() return instigator:IsPlayer() end)
    return playerOk and isPlayer == true
end

local function recordPlayerDeath(target, evt)
    creditPlayerKill(target, now(), deathEventHasPlayerInstigator(evt))
end

local function recordAIHumanDeath(component, evt)
    local ok, target = pcall(function() return component:GetEntity() end)
    if not ok or target == nil then return end
    creditPlayerKill(target, now(), deathEventHasPlayerInstigator(evt))
end

local function drawTextAt(x, y, id, text, r, g, b, a, scale)
    local autoResizeFlag = ImGuiWindowFlags.AlwaysAutoResize or 0
    local flags = ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoResize + ImGuiWindowFlags.NoMove
        + ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoSavedSettings + ImGuiWindowFlags.NoBackground
        + ImGuiWindowFlags.NoInputs + autoResizeFlag
    -- One low-cost dark halo layer keeps the neon readable over bright signs and daylight.
    ImGui.SetNextWindowBgAlpha(0.0)
    ImGui.SetNextWindowPos(x + 2, y + 2, ImGuiCond.Always)
    if ImGui.Begin("##wdm_halo_" .. id, flags) then
        ImGui.SetWindowFontScale(scale)
        ImGui.TextColored(0.0, 0.0, 0.0, math.min(0.90, a), text)
        ImGui.SetWindowFontScale(1.0)
    end
    ImGui.End()
    ImGui.SetNextWindowBgAlpha(0.0)
    ImGui.SetNextWindowPos(x, y, ImGuiCond.Always)
    if ImGui.Begin("##wdm_" .. id, flags) then
        ImGui.SetWindowFontScale(scale)
        ImGui.TextColored(r, g, b, a, text)
        ImGui.SetWindowFontScale(1.0)
    end
    ImGui.End()
end

local function drawText(screenWidth, y, text, r, g, b, a, scale)
    local width = ImGui.CalcTextSize(text) * scale
    drawTextAt((screenWidth - width) * 0.5, y, text, text, r, g, b, a, scale)
end

local function milestoneColor(kill)
    -- Each ten-kill stage has its own exaggerated identity; it loops after the tenth stage.
    local phase = (math.floor(kill / 10) - 1) % 5
    if phase == 0 then return 1.0, 0.04, 0.08, 1.0, 0.60, 0.06 end -- cyberpsycho crimson/fire
    if phase == 1 then return 0.92, 0.00, 0.12, 0.48, 0.00, 0.18 end -- blood moon: bruised crimson, not candy magenta
    if phase == 2 then return 1.0, 0.22, 0.01, 0.38, 0.88, 0.02 end -- meat grinder: burning orange with corrosive flash
    if phase == 3 then return 1.0, 0.72, 0.18, 0.52, 0.12, 0.01 end -- bone harvest: scorched amber
    return 0.04, 0.64, 1.0, 0.00, 0.16, 0.45 -- gorestorm: harsh electric cyan
end

local function drawRageText(timestamp, screenWidth, y, text, a, scale, stinger)
    local autoResizeFlag = ImGuiWindowFlags.AlwaysAutoResize or 0
    local flags = ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoResize + ImGuiWindowFlags.NoMove
        + ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoSavedSettings + ImGuiWindowFlags.NoBackground
        + ImGuiWindowFlags.NoInputs + autoResizeFlag
    local x = (screenWidth - ImGui.CalcTextSize(text) * scale) * 0.5
    -- Early streaks stay solid/readable; milestone stingers deliberately tear loose.
    local cyberpsychosis = stinger.label == "CYBERPSYCHOSIS"
    local feral = stinger.milestone == true
    local rage = feral and 1.0 or math.min(1.0, math.max(0.0, (stinger.kill - 5) / 25.0))
    local shakeX = math.sin(timestamp * 43.0) * (cyberpsychosis and 8.5 or (feral and 5.5 or (0.45 + rage * 4.0)))
    local shakeY = math.cos(timestamp * 57.0) * (cyberpsychosis and 3.5 or (feral and 2.4 or (0.25 + rage * 1.65)))
    local trailAlpha = a * (feral and 0.70 or (0.12 + rage * 0.42))
    local flashAlpha = a * (feral and 0.92 or (0.34 + rage * 0.46))
    local mainR, mainG, mainB, flashR, flashG, flashB = 1.0, 0.04, 0.08, 1.0, 0.60, 0.06
    if feral then
        mainR, mainG, mainB, flashR, flashG, flashB = milestoneColor(stinger.kill)
    end
    local function raw(id, px, py, r, g, b, alpha, textScale)
        ImGui.SetNextWindowBgAlpha(0.0)
        ImGui.SetNextWindowPos(px, py, ImGuiCond.Always)
        if ImGui.Begin("##wdm_rage_" .. id, flags) then
            ImGui.SetWindowFontScale(textScale)
            ImGui.TextColored(r, g, b, alpha, text)
            ImGui.SetWindowFontScale(1.0)
        end
        ImGui.End()
    end
    raw("trail_a", x - 11 - shakeX * 0.25, y + 5, mainR * 0.42, mainG * 0.20, mainB * 0.20, trailAlpha, scale)
    raw("trail_b", x + 8 + shakeX * 0.20, y - 3, flashR, flashG * 0.45, flashB * 0.45, trailAlpha * 0.82, scale)
    raw("flash", x - shakeX * 0.40, y - shakeY * 0.40, flashR, flashG, flashB, flashAlpha, scale * 1.025)
    raw("main", x + shakeX, y + shakeY, mainR, mainG, mainB, a, scale)
end

local function drawKillHighlight(timestamp, screenWidth, screenHeight)
    if timestamp >= killBannerUntil then
        activeStinger = nil
        return
    end
    if activeStinger == nil then return end
    local remaining = killBannerUntil - timestamp
    local alpha = math.min(1.0, remaining * 3.5)
    local label = activeStinger.label
    local cyberpsychosis = label == "CYBERPSYCHOSIS"
    local scale = (1.90 + math.min(0.40, remaining * 0.35)) * hudScale
    local titleScale = cyberpsychosis and scale * 1.38 or (activeStinger.milestone and scale * 1.18 or scale)
    drawRageText(timestamp, screenWidth, screenHeight * (cyberpsychosis and 0.24 or 0.28), label, alpha, titleScale, activeStinger)
end

local function drawTelemetryPlate(timestamp, screenWidth, screenHeight)
    local s = hudScale
    local w, h = 285 * s, 90 * s
    local x, y = telemetryPosition(screenWidth, screenHeight, w)
    local pr, pg, pb, dr, dg, db = getPalette()
    local list = ImGui.GetBackgroundDrawList()
    local accent = ImGui.ColorConvertFloat4ToU32({pr, pg, pb, 0.95})
    local dim = ImGui.ColorConvertFloat4ToU32({dr, dg, db, 0.9})
    -- No backing panel or frame: only combat telemetry floating over the world.
    -- ImGui applies window padding before glyphs; offset telemetry text so its visible glyphs align with the raw meter rectangles.
    local textOrigin = x - 8 * s
    drawTextAt(textOrigin, y + 7 * s, "telemetry", lastStatusLabel, pr, pg, pb, 0.90, 0.76 * s)
    -- CET exposes no Lua font loader; native 1x rendering keeps this number as sharp as the other HUD labels.
    drawTextAt(textOrigin, y + 24 * s, "dps", string.format("%04d", math.floor(displayDps + 0.5)), pr, pg, pb, 1.0, 1.0)
    drawTextAt(textOrigin + 52 * s, y + 24 * s, "dpslabel", "DPS", pr, pg, pb, 0.9, 0.82 * s)
    drawTextAt(textOrigin + 145 * s, y + 7 * s, "peak", string.format("PEAK %04d", math.floor(peakDps + 0.5)), pr, pg, pb, 0.82, 0.70 * s)
    drawTextAt(textOrigin + 145 * s, y + 28 * s, "kills", string.format("KILLS %03d", killCount), pr, pg, pb, 1.0, 0.80 * s)
    for i = 0, 11 do
        local fill = math.min(1.0, displayDps / 500.0)
        local color = i / 12 < fill and accent or dim
        ImGui.ImDrawListAddRectFilled(list, x + i * 12 * s, y + 76 * s, x + (9 + i * 12) * s, y + 82 * s, color)
    end
end

loadConfig()

registerForEvent("onInit", function()
    ObserveAfter("ScriptedPuppet", "OnDamageReceived", recordPlayerDamage)
    -- OnDeath is defined on NPCPuppet; observing ScriptedPuppet here missed real NPC death callbacks.
    ObserveAfter("NPCPuppet", "OnDeath", recordPlayerDeath)
    ObserveAfter("ScriptedPuppet", "OnDefeated", recordPlayerDeath)
    ObserveAfter("AIHumanComponent", "OnDeath", recordAIHumanDeath)
    -- Event-driven pause state keeps rendering enabled during gameplay and hides it only for menus.
    ObserveAfter("gameuiPopupsManager", "OnMenuUpdate", function(_, isInMenu)
        menuOpen = isInMenu == true
    end)
    local nativeSettings = GetMod("nativeSettings")
    if nativeSettings then
        -- Native Settings requires the parent tab to exist before its subcategory/options.
        nativeSettings.addTab("/redline_rampage", "REDLINE RAMPAGE")
        nativeSettings.addSubcategory("/redline_rampage/hud", "HUD CONFIGURATION")
        nativeSettings.addSwitch(
            "/redline_rampage/hud",
            "Rampage HUD enabled",
            "Master switch for the REDLINE RAMPAGE combat telemetry and kill counter.",
            enabled,
            true,
            function(value)
                enabled = value
                previewUntil = now() + 4.0
                saveConfig()
                print("[REDLINE RAMPAGE] Enabled: " .. tostring(enabled))
            end
        )
        nativeSettings.addRangeInt(
            "/redline_rampage/hud",
            "Color palette",
            "1 Blood Red | 2 Neon Cyan | 3 Toxic Gold",
            1, 3, 1, palette, 1,
            function(value) palette = value; previewUntil = now() + 4.0; saveConfig() end
        )
        nativeSettings.addRangeFloat(
            "/redline_rampage/hud",
            "HUD scale",
            "Scales the complete REDLINE RAMPAGE display, including telemetry, meter, and kill stingers.",
            0.75, 2.0, 0.05, "%.2fx", hudScale, 1.0,
            function(value) hudScale = value; previewUntil = now() + 4.0; saveConfig() end
        )
        nativeSettings.addRangeInt(
            "/redline_rampage/hud",
            "HUD horizontal position",
            "0 Left | 1 Center | 2 Right",
            0, 2, 1, horizontalPosition, 1,
            function(value) horizontalPosition = value; previewUntil = now() + 4.0; saveConfig() end
        )
        nativeSettings.addRangeInt(
            "/redline_rampage/hud",
            "HUD vertical position",
            "0 Top | 1 Middle | 2 Bottom",
            0, 2, 1, verticalPosition, 0,
            function(value) verticalPosition = value; previewUntil = now() + 4.0; saveConfig() end
        )
    else
        print("[REDLINE RAMPAGE] Native Settings UI not found; HUD remains enabled by config/default.")
    end
    -- Do not render an init preview: CET initializes during the loading screen.
    -- A preview is shown only after the player changes a HUD setting in-game.
    print("[REDLINE RAMPAGE] v5.9 loaded; enabled=" .. tostring(enabled))
end)

registerForEvent("onDraw", function()
    local timestamp = now()
    updateDps(timestamp)
    if not enabled or isMenuOpen() then return end
    local screenWidth, screenHeight = GetDisplayResolution()
    if not screenWidth or not screenHeight then return end
    local inGameCombat = isGameCombatActive()
    -- IsInCombat can briefly flicker false during an active encounter; never reset on one false frame.
    if displayDps >= 0.5 or timestamp < previewUntil or timestamp < combatUntil or inGameCombat then
        drawTelemetryPlate(timestamp, screenWidth, screenHeight)
    end
    drawKillHighlight(timestamp, screenWidth, screenHeight)
    if timestamp < previewUntil then
        drawText(screenWidth, screenHeight * 0.42, "REDLINE RAMPAGE // ONLINE", 1.0, 0.16, 0.20, 1.0, 1.20 * hudScale)
    end
    -- Fallback if no combat transition was observed (for example, after a HUD reload outside combat).
    if displayDps < 0.5 and timestamp >= previewUntil and timestamp >= combatUntil and not inGameCombat then
        resetCombatChain()
    end
end)
