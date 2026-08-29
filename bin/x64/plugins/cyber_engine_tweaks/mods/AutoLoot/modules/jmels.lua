-------------------------------------------------------------------------------------------------------------------------------
-- Mod expansion and additional coding by anygoodname by keanuWheeze consent.
-- This mod shall not be redistributed or modified/renamed/rebranded and published as a separate mod without keanuWheeze and anygoodname permission.
-- To use code snippets from this mod in other mods requires a consent and a proper credit note.

-- Jurnal Mappin Extractor Lite
-- v1.0.1 Apr 28, 2026
-- Based on (c)psiberx JournalScan script.
-- adapted to extract quest markers and mappins only for the Autoloot mod by anygoodname

--[[ DISCLAIMER:

This mod is a non-commercial fan creation intended for personal use only.

By using the word "republish" I mean both republish and redistribute in this disclaimer:
You're not allowed to republish the mod without my consent or against the Nexusmods rules.
You're not allowed to republish parts of this mod code or files without consent. Either mine either other authors.
You can modify the mod code or files for your personal use only.
By modifying the mod code or files, you acknowledge I cannot support the modified mod code or files.
You're not allowed to publish your modifications to the mod code or files without my consent.
You're not allowed to publicly propose unauthorized changes to the mod code or files.
You're not allowed to use any part of the mod code or files for commercial purposes, advertising or promotion of any kind.
You can use parts the code or file modifications in your creations only by my consent and on a credit note.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--

-- THIS MODULE DOES NOT SUPPORT TRANSLATIONS IN IT'S CURRENT SHAPE

----------------------------------------------

local capturedQuestMappins
local mappinsChangeCounter, prevMappinsChangeCounter = 0, 0
local activeQuestsRequestContext
local journalManager
local n, t
local n_gameJournalFolderEntry = 'gameJournalFolderEntry'
local n_gameJournalQuest = "gameJournalQuest"
local GameGetNodeTransform
local resolveNodeRefWithEntityID
local t_MappinsQuestStaticMappinDefinition

-- Warning: Don't change the functions order as it will break the code execution!

local function resetVariables()
	capturedQuestMappins = {}
	mappinsChangeCounter = 0
	prevMappinsChangeCounter = 0
end

local function setObservers()
	Observe('gamemappinsMappinSystem', 'RegisterMappin', function(this, data, position)
		mappinsChangeCounter = mappinsChangeCounter + 1
	end)
	
	Observe('gamemappinsMappinSystem', 'SetMappinActive', function(this, data, active)
		if not active then return end
		mappinsChangeCounter = mappinsChangeCounter + 1
	end)

	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(self)
		if self:IsReplacer() then return end
		journalManager = journalManager or Game.GetJournalManager()
		resetVariables()
	end)
end

local function getDefaulQuestsJournalRequestContext()
	return gameJournalRequestContext.new({
		stateFilter = gameJournalRequestStateFilter.new({
			inactive = true,
			active = true,
			succeeded = true,
			failed = true,
		})
	})
end

local function getUnfinishedQuestsJournalRequestContext()
	return gameJournalRequestContext.new({
		stateFilter = gameJournalRequestStateFilter.new({
			inactive = true,
			active = true,
			succeeded = false,
			failed = false,
		})
	})
end

local function getActiveQuestsJournalRequestContext()
	return gameJournalRequestContext.new({
		stateFilter = gameJournalRequestStateFilter.new({
			inactive = false,
			active = true,
			succeeded = false,
			failed = false,
		})
	})
end

local isInitialized = false
local function init() -- While it is designed to init itself on demand it's recommended to put it in OnInit() handler in the main mod init.lua script.
	if isInitialized then return end
	n = CName
	t = TweakDBID
	journalManager = Game.GetJournalManager()
	resetVariables()
	activeQuestsRequestContext = getActiveQuestsJournalRequestContext()
	n_gameJournalFolderEntry = n"gameJournalFolderEntry"
	n_gameJournalQuest = n"gameJournalQuest"
	GameGetNodeTransform = Game.GetNodeTransform
	resolveNodeRefWithEntityID = ResolveNodeRefWithEntityID
	t_MappinsQuestStaticMappinDefinition = t"Mappins.QuestStaticMappinDefinition"
	setObservers()
	isInitialized = true
end

local knownStaticMappinNodeRefs = {}
local knownResolvedEntries = {}
local isKnownCapturedStaticMappinNodeRef = {}
local gameDump
local function getJournalEntriesMappinsOnly(journalEntries, includeMarkers, includeMapIns, playerEntId, path, level);
	gameDump = gameDump or GameDump
	if not level then level = 0 else level = level + 1 end
	for i = 1, #journalEntries do
		local journalEntry = journalEntries[i]
		if level == 0 then path = journalEntry.id else path = path..tostring(level) end
		local resolvedEntry = knownResolvedEntries[path]
		if resolvedEntry then
			if resolvedEntry.isMappin then
				capturedQuestMappins[#capturedQuestMappins+1] = resolvedEntry
			elseif resolvedEntry.hasChildren then
				local childrenEntries = resolvedEntry.childrenEntries
				if #childrenEntries > 0 then
					getJournalEntriesMappinsOnly(childrenEntries, includeMarkers, includeMapIns, playerEntId, path, level)
				end
			end
		else
			local isEntryProcessed;
			if journalEntry.offset then;
				local reference = journalEntry.reference;
				if reference then;
					local nodeRef = reference.reference
					local nodeRefStr = gameDump(nodeRef)
					local knownStaticMappinNodeRef = knownStaticMappinNodeRefs[nodeRefStr]
					if knownStaticMappinNodeRef then
						if not isKnownCapturedStaticMappinNodeRef[nodeRefStr] then
							capturedQuestMappins[#capturedQuestMappins+1] = knownStaticMappinNodeRef
							isKnownCapturedStaticMappinNodeRef[nodeRefStr] = true
						end
					else
						local success, transform = GameGetNodeTransform(resolveNodeRefWithEntityID(nodeRef, playerEntId));
						if success then
							local pos = transform:GetPosition()
							local entry = {isMappin = true, pos = pos}
							capturedQuestMappins[#capturedQuestMappins+1] = entry
							knownResolvedEntries[path] = entry
							local mappinData = journalEntry.mappinData
							if mappinData.mappinType == t_MappinsQuestStaticMappinDefinition then
								knownStaticMappinNodeRefs[nodeRefStr] = entry
								isKnownCapturedStaticMappinNodeRef[nodeRefStr] = true
							end
						end;
					end
					isEntryProcessed = true;
				end;
			end;
			if not isEntryProcessed then;
				local childrenEntries = journalEntry.entries;
				if childrenEntries then
					knownResolvedEntries[path] = {hasChildren = true, childrenEntries = childrenEntries}
					if #childrenEntries > 0 then getJournalEntriesMappinsOnly(childrenEntries, includeMarkers, includeMapIns, playerEntId, path, level) end
				else
					knownResolvedEntries[path] = {isOtherType = true}
				end;
			end;
		end
	end;
end;

 -- this the main one to call here or from outside. A "public" equivalent
local function getActiveQuestsMappins()
	if not isInitialized then init() end
	if (prevMappinsChangeCounter ~= mappinsChangeCounter) then
		activeQuestsRequestContext = activeQuestsRequestContext or getActiveQuestsJournalRequestContext()
		local questEntries = journalManager:GetQuests(activeQuestsRequestContext)
		if questEntries then
			capturedQuestMappins = {}
			isKnownCapturedStaticMappinNodeRef = {}
			local playerEntId = GetPlayer():GetEntityID();
			getJournalEntriesMappinsOnly(questEntries, false, true, playerEntId)
		end
	end
	prevMappinsChangeCounter = mappinsChangeCounter
	return capturedQuestMappins
end

---@param journalEntry gameJournalEntry
---@return string
local function getEntryHash(journalEntry)
	local hash = journalManager:GetEntryHash(journalEntry)
	if hash >= 0 then return hash end
	return hash + 4294967296
end

local tableInsert = table.insert
---@param journalFolder gameJournalFolderEntry
local function collectJournalEntries(journalFolder, journalEntryClass, outputList)
	if not outputList then
		outputList = {}
	end

	for _, journalEntry in ipairs(journalFolder.entries) do
		if journalEntry:IsA(journalEntryClass) then
			tableInsert(outputList, journalEntry)
		elseif journalEntry:IsA(n_gameJournalFolderEntry) then
			collectJournalEntries(journalEntry, journalEntryClass, outputList)
		end
	end

	return outputList
end

local stringLen = string.len
local function isStringValid(input)
	if type(input) ~= 'string' then return end
	return stringLen(input) > 0
end
local function getAllJournalQuestEntries(createLookups)
	if not isInitialized then init() end
	journalManager = journalManager or Game.GetJournalManager()
	local questsFolder = journalManager:GetEntryByString('quests', 'gameJournalPrimaryFolderEntry')
	local questsFolderPhL = journalManager:GetEntryByString('ep1/quests', 'gameJournalPrimaryFolderEntry')
	local questList = collectJournalEntries(questsFolder, n_gameJournalQuest)
	if questsFolderPhL then questList = collectJournalEntries(questsFolderPhL, n_gameJournalQuest, questList) end
	if not createLookups then return questList end
	local hashLookup, idLookup = {}, {}
	for i, entry in ipairs(questList) do
		hashLookup[getEntryHash(entry)] = entry
		local id = entry.id
		if isStringValid(id) then
			if not idLookup[id] then idLookup[id] = {} end
			tableInsert(idLookup[id], entry)
		end
	end
	return questList, hashLookup, idLookup
end

local jmels = {}
jmels.init = init
jmels.getAllJournalQuestEntries = getAllJournalQuestEntries
jmels.getActiveQuestsMappins = getActiveQuestsMappins
jmels.isLs = true

return jmels
