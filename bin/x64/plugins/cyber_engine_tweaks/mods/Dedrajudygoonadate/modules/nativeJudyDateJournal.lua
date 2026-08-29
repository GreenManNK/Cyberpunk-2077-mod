-- Judy date native journal controller
-- Reusable native MinorQuest entries for Swim, Guitar and Climb.
-- Description and Judy codex-link entries are explicitly activated.
-- Successful dates become Succeeded; timeouts/leaving the date area become Failed.

local M = {}

local DEFINITIONS = {
  swim = {
    quest = "quests/minor_quest/judy_date_swim",
    description = "quests/minor_quest/judy_date_swim/description",
    judyCodex = "quests/minor_quest/judy_date_swim/codex_link_judy_alvarez",
    phase = "quests/minor_quest/judy_date_swim/phases",
    objectives = {
      "quests/minor_quest/judy_date_swim/phases/1_meet",
      "quests/minor_quest/judy_date_swim/phases/2_dive",
      "quests/minor_quest/judy_date_swim/phases/3_follow",
      "quests/minor_quest/judy_date_swim/phases/4_surface",
      "quests/minor_quest/judy_date_swim/phases/5_rest",
      "quests/minor_quest/judy_date_swim/phases/6_end",
    },
  },
  guitar = {
    quest = "quests/minor_quest/judy_date_guitar",
    description = "quests/minor_quest/judy_date_guitar/description",
    judyCodex = "quests/minor_quest/judy_date_guitar/codex_link_judy_alvarez",
    phase = "quests/minor_quest/judy_date_guitar/phases",
    objectives = {
      "quests/minor_quest/judy_date_guitar/phases/1_meet",
      "quests/minor_quest/judy_date_guitar/phases/2_group",
      "quests/minor_quest/judy_date_guitar/phases/3_downstairs",
      "quests/minor_quest/judy_date_guitar/phases/4_ride",
      "quests/minor_quest/judy_date_guitar/phases/5_upstairs",
      "quests/minor_quest/judy_date_guitar/phases/6_end",
    },
  },
  climb = {
    quest = "quests/minor_quest/judy_date_climb",
    description = "quests/minor_quest/judy_date_climb/description",
    judyCodex = "quests/minor_quest/judy_date_climb/codex_link_judy_alvarez",
    phase = "quests/minor_quest/judy_date_climb/phases",
    objectives = {
      "quests/minor_quest/judy_date_climb/phases/1_meet",
      "quests/minor_quest/judy_date_climb/phases/2_climb",
      "quests/minor_quest/judy_date_climb/phases/3_find",
      "quests/minor_quest/judy_date_climb/phases/4_follow",
      "quests/minor_quest/judy_date_climb/phases/5_top",
      "quests/minor_quest/judy_date_climb/phases/6_end",
    },
  },
}

local STARTUP_GATE = 3.0
local loadElapsed = 0.0
local gateOpen = false
local currentKind = nil
local currentIndex = nil
local currentIndexByKind = {}
local pendingLoadReset = false
local pending = {}
local missingLogElapsed = 999.0

local function log(s)
  print("[JudyDateJournal] " .. tostring(s))
end

local function manager()
  local ok, jm = pcall(function()
    return Game and Game.GetJournalManager and Game.GetJournalManager() or nil
  end)
  if ok then return jm end
  return nil
end

local function get(path, className)
  local jm = manager()
  if not jm then return nil end
  local ok, entry = pcall(function() return jm:GetEntryByString(path, className) end)
  if ok then return entry end
  return nil
end

local function change(path, className, state, notify)
  local jm = manager()
  if not jm then return false end
  local entry = get(path, className)
  if not entry then
    log("Missing journal entry: " .. tostring(path) .. " [" .. tostring(className) .. "]")
    return false
  end
  local okHash, hash = pcall(function() return jm:GetEntryHash(entry) end)
  if not okHash or hash == nil then return false end
  local ok = pcall(function()
    jm:ChangeEntryStateByHash(hash, state, notify and "Notify" or "DoNotNotify")
  end)
  return ok
end

local function track(def, index)
  local jm = manager()
  if not jm then return false end
  local entry = get(def.objectives[index], "gameJournalQuestObjective")
  if not entry then return false end
  return pcall(function() jm:TrackEntry(entry) end)
end

local function resourceLoaded()
  for _, def in pairs(DEFINITIONS) do
    if get(def.quest, "gameJournalQuest") == nil then return false end
  end
  return true
end

local function setPresentationEntries(def, state, notifyDescription)
  if def.description then
    -- Quest descriptions need their own journal-state notification.
    -- Without it the quest can appear correctly while the description panel stays blank.
    change(def.description, "gameJournalQuestDescription", state, notifyDescription == true)
  end
  if def.judyCodex then
    change(def.judyCodex, "gameJournalQuestCodexLink", state, false)
  end
end

local function minimalReset(kind)
  local def = DEFINITIONS[kind]
  if not def then return end
  for i = 1, #def.objectives do
    change(def.objectives[i], "gameJournalQuestObjective", "Inactive", false)
  end
  setPresentationEntries(def, "Inactive")
  change(def.phase, "gameJournalQuestPhase", "Inactive", false)
  change(def.quest, "gameJournalQuest", "Inactive", false)
  currentIndexByKind[kind] = nil
  if currentKind == kind then
    currentKind = nil
    currentIndex = nil
  end
end

local function resetAllRoots()
  for kind, _ in pairs(DEFINITIONS) do minimalReset(kind) end
end

local function doStart(kind, index)
  local def = DEFINITIONS[kind]
  if not def then return end
  index = math.max(1, math.min(#def.objectives, tonumber(index) or 1))

  -- Make a previous completed/failed date reusable on Judy's next invitation.
  minimalReset(kind)

  -- Prime the description before the quest root becomes visible, then notify it again
  -- after activation so the journal details panel refreshes with the description text.
  setPresentationEntries(def, "Active", false)
  change(def.quest, "gameJournalQuest", "Active", true)
  setPresentationEntries(def, "Active", true)
  change(def.phase, "gameJournalQuestPhase", "Active", false)
  for i = 1, index - 1 do
    change(def.objectives[i], "gameJournalQuestObjective", "Succeeded", false)
  end
  change(def.objectives[index], "gameJournalQuestObjective", "Active", true)
  track(def, index)
  currentKind = kind
  currentIndex = index
  currentIndexByKind[kind] = index
  log("Started " .. tostring(kind) .. " at objective " .. tostring(index))
end

local function doObjective(kind, index)
  local def = DEFINITIONS[kind]
  if not def then return end
  index = math.max(1, math.min(#def.objectives, tonumber(index) or 1))

  if currentKind == kind and currentIndex and currentIndex ~= index then
    change(def.objectives[currentIndex], "gameJournalQuestObjective", "Succeeded", false)
  end
  -- Keep description/codex alive even if a game state transition touched child states.
  setPresentationEntries(def, "Active", true)
  change(def.objectives[index], "gameJournalQuestObjective", "Active", true)
  track(def, index)
  currentKind = kind
  currentIndex = index
  currentIndexByKind[kind] = index
end

local function doComplete(kind)
  local def = DEFINITIONS[kind]
  if not def then return end
  for i = 1, #def.objectives do
    change(def.objectives[i], "gameJournalQuestObjective", "Succeeded", false)
  end
  setPresentationEntries(def, "Active", true)
  change(def.phase, "gameJournalQuestPhase", "Succeeded", false)
  change(def.quest, "gameJournalQuest", "Succeeded", true)
  currentIndexByKind[kind] = nil
  if currentKind == kind then
    currentKind = nil
    currentIndex = nil
  end
  log("Completed " .. tostring(kind))
end

local function doFail(kind)
  local def = DEFINITIONS[kind]
  if not def then return end

  -- Preserve already completed objectives, fail the current objective, and leave future ones inactive.
  local idx = currentIndexByKind[kind]
  if not idx and currentKind == kind then idx = currentIndex end
  if idx then
    for i = idx + 1, #def.objectives do
      change(def.objectives[i], "gameJournalQuestObjective", "Inactive", false)
    end
    change(def.objectives[idx], "gameJournalQuestObjective", "Failed", false)
  end
  setPresentationEntries(def, "Active", true)
  change(def.phase, "gameJournalQuestPhase", "Failed", false)
  change(def.quest, "gameJournalQuest", "Failed", true)
  currentIndexByKind[kind] = nil
  if currentKind == kind then
    currentKind = nil
    currentIndex = nil
  end
  log("Failed " .. tostring(kind))
end

local function discardPendingForKind(kind)
  local kept = {}
  for _, op in ipairs(pending) do
    if op.kind ~= kind then kept[#kept + 1] = op end
  end
  pending = kept
end

local function queue(op)
  pending[#pending + 1] = op
end

function M.requestLoadReset()
  loadElapsed = 0.0
  gateOpen = false
  currentKind = nil
  currentIndex = nil
  currentIndexByKind = {}
  pending = {}
  pendingLoadReset = true
  missingLogElapsed = 999.0
end

function M.onSessionEnd()
  loadElapsed = 0.0
  gateOpen = false
  currentKind = nil
  currentIndex = nil
  currentIndexByKind = {}
  pending = {}
  pendingLoadReset = false
end

function M.start(kind, index)
  if not DEFINITIONS[kind] then return false end
  queue({ action = "start", kind = kind, index = tonumber(index) or 1 })
  return true
end

function M.setObjective(kind, index)
  if not DEFINITIONS[kind] then return false end
  queue({ action = "objective", kind = kind, index = tonumber(index) or 1 })
  return true
end

function M.complete(kind)
  if not DEFINITIONS[kind] then return false end
  queue({ action = "complete", kind = kind })
  return true
end

function M.fail(kind)
  if not DEFINITIONS[kind] then return false end
  queue({ action = "fail", kind = kind })
  return true
end

function M.completeNow(kind)
  if not DEFINITIONS[kind] then return false end
  if resourceLoaded() then
    discardPendingForKind(kind)
    doComplete(kind)
  else
    queue({ action = "complete", kind = kind })
  end
  return true
end

function M.failNow(kind)
  if not DEFINITIONS[kind] then return false end
  if resourceLoaded() then
    discardPendingForKind(kind)
    doFail(kind)
  else
    queue({ action = "fail", kind = kind })
  end
  return true
end

function M.cancel(kind)
  if not DEFINITIONS[kind] then return false end
  queue({ action = "cancel", kind = kind })
  return true
end

function M.update(elapsed)
  elapsed = tonumber(elapsed) or 0.0
  if not gateOpen then
    loadElapsed = loadElapsed + elapsed
    if loadElapsed < STARTUP_GATE then return end
    gateOpen = true
  end

  if not pendingLoadReset and #pending == 0 then return end

  if not resourceLoaded() then
    missingLogElapsed = missingLogElapsed + elapsed
    if missingLogElapsed >= 15.0 then
      missingLogElapsed = 0.0
      log("Journal resource is not loaded yet. Waiting for the compiled Judy journal archive.")
    end
    return
  end
  missingLogElapsed = 0.0

  if pendingLoadReset then
    pendingLoadReset = false
    resetAllRoots()
    log("Judy date quests reset after load.")
  end

  -- Process every state change queued since the last 1.5 second journal tick.
  local ops = pending
  pending = {}
  for _, op in ipairs(ops) do
    if op.action == "start" then
      doStart(op.kind, op.index)
    elseif op.action == "objective" then
      doObjective(op.kind, op.index)
    elseif op.action == "complete" then
      doComplete(op.kind)
    elseif op.action == "fail" then
      doFail(op.kind)
    elseif op.action == "cancel" then
      minimalReset(op.kind)
    end
  end
end

return M
