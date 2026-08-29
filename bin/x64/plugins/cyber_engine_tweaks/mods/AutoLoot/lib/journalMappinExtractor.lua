-------------------------------------------------------------------------------------------------------------------------------
-- Mod expansion and additional coding by anygoodname by keanuWheeze consent.
-- This mod shall not be redistributed or modified/renamed/rebranded and published as a separate mod without keanuWheeze and anygoodname permission.
-- To use code snippets from this mod in other mods requires a consent and a proper credit note.

-- v1.5.3 Nov 27, 2025
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
You can use the mod code and files to learn how to code this game mods and improve your skills.
You can use parts the code or file modifications in your creations only by my consent and on a credit note.
You're not allowed to use parts of the code or files marked as coming from other people without their consent.
You can create and publish translations of the parts of the mod that are explicitly marked as allowed to translate either in the mod description either in the mod files.
The translations must follow the Nexusmods translation publishing rules.
]]--

-- THIS MODULE DOES NOT SUPPORT TRANSLATIONS IN IT'S CURRENT SHAPE

----------------------------------------------
local Ref = require('lib/Ref')
if not Ref then return end

local journalMappinExtractor = {}
local capturedQuestMappins = {}
local mappinsChangeCounter, prevMappinsChangeCounter, firstTimeRun = 0, 0, true
local unfinishedQuestsRequestContext = nil
local activeQuestsRequestContext = nil
local journalManager
local n, t
local n_gameJournalFolderEntry = 'gameJournalFolderEntry'
local n_gameJournalQuestGuidanceMarker = "gameJournalQuestGuidanceMarker"
local n_gameJournalQuestMapPin = "gameJournalQuestMapPin"
local n_gameJournalContainerEntry = "gameJournalContainerEntry"
local gameJournalEntryStateActive
local GameGetNodeTransform
local resolveNodeRefWithEntityID
local t_MappinsQuestStaticMappinDefinition, t_MappinsQuestDynamicMappinDefinition
-- Warning: Don't change the functions order as it will break the code execution!

local function resetVariables()
	capturedQuestMappins = {}
	mappinsChangeCounter = 0
	prevMappinsChangeCounter = 0
end

local function setObservers()
	Observe('gamemappinsMappinSystem', 'RegisterMappin', function() --self, data, position)
		mappinsChangeCounter = mappinsChangeCounter + 1
	end)
	
	Observe('gamemappinsMappinSystem', 'SetMappinActive', function() --self, data, position)
		mappinsChangeCounter = mappinsChangeCounter + 1
	end)
	
	Observe('gamemappinsMappinSystem', 'UnregisterMappin', function() --self, id)
		mappinsChangeCounter = mappinsChangeCounter + 1
	end)
	
	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(self)
		if self:IsReplacer() then return end
		journalManager = Ref.Weak(Game.GetJournalManager())
		resetVariables()
	end)	
end

---@param journalEntry gameJournalEntry
---@return string
local function getEntryHash(journalEntry)
	local hash = journalManager:GetEntryHash(journalEntry)
	if hash >= 0 then return hash end
	return hash + 4294967296
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
function journalMappinExtractor.init() -- While it is designed to init itself on demand it's recommended to put it in OnInit() handler in the main mod init.lua script.
	if isInitialized then firstTimeRun = false return end
	n = CName
	t = TweakDBID
	journalManager = Ref.Weak(Game.GetJournalManager())
	resetVariables()
	unfinishedQuestsRequestContext = getUnfinishedQuestsJournalRequestContext()
	activeQuestsRequestContext = getActiveQuestsJournalRequestContext()
	n_gameJournalFolderEntry = n"gameJournalFolderEntry"
	n_gameJournalQuestGuidanceMarker = n"gameJournalQuestGuidanceMarker"
	n_gameJournalQuestMapPin = n"gameJournalQuestMapPin"
	n_gameJournalContainerEntry = n"gameJournalContainerEntry"
	gameJournalEntryStateActive = gameJournalEntryState.Active
	GameGetNodeTransform = Game.GetNodeTransform
	resolveNodeRefWithEntityID = ResolveNodeRefWithEntityID
	t_MappinsQuestStaticMappinDefinition = t"Mappins.QuestStaticMappinDefinition"
	t_MappinsQuestDynamicMappinDefinition = t"Mappins.QuestStaticMappinDefinition"
	setObservers()
	firstTimeRun = false
	isInitialized = true
end

---@param journalData table
local function sortJournalData(journalData)
	table.sort(journalData, function(a, b)
		if a.type ~= b.type then
			return EnumValueFromString('gameJournalQuestType', a.type) < EnumValueFromString('gameJournalQuestType', b.type)
		end

		return a.path < b.path
	end)
end

local knownStaticMappinNodeRefs = {}
---@param journalEntries gameJournalEntry[]
function processJournalEntriesForMappinsExtraction(journalEntries, includeMarkers, includeMapIns, playerEntId)
	if (not includeMarkers) and (not includeMapIns) then return end
	playerEntId = playerEntId or GetPlayer():GetEntityID()
	for _, journalEntry in ipairs(journalEntries) do
		local isEntryProcessed
		if includeMarkers and journalEntry:IsA(n_gameJournalQuestGuidanceMarker) then
			local success, transform = GameGetNodeTransform(resolveNodeRefWithEntityID(journalEntry.nodeRef, playerEntId))
			if success then table.insert(capturedQuestMappins, {type = 'Marker', id = journalEntry.id, pos = transform:GetPosition()}) end
			isEntryProcessed = true
		end
		if includeMapIns and (not isEntryProcessed) and journalEntry:IsA(n_gameJournalQuestMapPin) then
			local nodeRef = journalEntry.reference.reference
			local nodeRefStr = GameDump(nodeRef)
			local knownStaticMappinNodeRef = knownStaticMappinNodeRefs[nodeRefStr]
			if knownStaticMappinNodeRef then
				table.insert(capturedQuestMappins, knownStaticMappinNodeRef)
			else
				local success, transform = GameGetNodeTransform(resolveNodeRefWithEntityID(nodeRef, playerEntId))
				if success then
					local mappinData = journalEntry.mappinData
					local entry = {type = 'MapPin', id = journalEntry.id, pos = transform:GetPosition(), mappinData = mappinData, nodeRefStr = nodeRefStr, nodeRef = nodeRef}
					table.insert(capturedQuestMappins, entry)
					if mappinData.mappinType == t_MappinsQuestStaticMappinDefinition and (not entry.pos:IsZero()) then knownStaticMappinNodeRefs[nodeRefStr] = entry end
				end
			end
			isEntryProcessed = true
		end
		if (not isEntryProcessed) and journalEntry:IsA(n_gameJournalContainerEntry) and journalManager:GetEntryState(journalEntry) == gameJournalEntryStateActive then
			local childrenEntries = journalEntry.entries
			if #childrenEntries > 0 then processJournalEntriesForMappinsExtraction(childrenEntries, includeMarkers, includeMapIns, playerEntId) end
		end
	end
end

function getJournalEntriesMappins(journalEntries, includeMarkers, includeMapIns, playerEntId);
	for _, journalEntry in ipairs(journalEntries) do;
		local isEntryProcessed;
		if includeMarkers and journalEntry.nodeRef and journalEntry.pathfindingType then;
			local success, transform = GameGetNodeTransform(resolveNodeRefWithEntityID(journalEntry.nodeRef, playerEntId));
			if success then table.insert(capturedQuestMappins, {pos = transform:GetPosition()}) end;
			isEntryProcessed = true;
		end;
		if includeMapIns and (not isEntryProcessed) and journalEntry.offset then;
			local reference = journalEntry.reference;
			if reference then;
				local nodeRef = reference.reference
				local nodeRefStr = GameDump(nodeRef)
				local knownStaticMappinNodeRef = knownStaticMappinNodeRefs[nodeRefStr]
				if knownStaticMappinNodeRef then
					table.insert(capturedQuestMappins, knownStaticMappinNodeRef)
				else
					local success, transform = GameGetNodeTransform(resolveNodeRefWithEntityID(nodeRef, playerEntId));
					if success then
						local mappinData = journalEntry.mappinData
						local entry = {pos = transform:GetPosition(), mappinData = mappinData, nodeRefStr = nodeRefStr, nodeRef = nodeRef}
						table.insert(capturedQuestMappins, entry)
						if mappinData.mappinType == t_MappinsQuestStaticMappinDefinition and (not entry.pos:IsZero()) then knownStaticMappinNodeRefs[nodeRefStr] = entry end
					end;
				end
				isEntryProcessed = true;
			end;
		end;
		if not isEntryProcessed then;
			local childrenEntries = journalEntry.entries;
			if childrenEntries and #childrenEntries > 0 then getJournalEntriesMappins(childrenEntries, includeMarkers, includeMapIns, playerEntId) end;
		end;
	end;
end;

---@param journalFolder gameJournalFolderEntry
local function collectJournalEntries(journalFolder, journalEntryClass, outputList)
	if not outputList then
		outputList = {}
	end

	for _, journalEntry in ipairs(journalFolder.entries) do
		if journalEntry:IsA(journalEntryClass) then
			table.insert(outputList, journalEntry)
		elseif journalEntry:IsA(n_gameJournalFolderEntry) then
			collectJournalEntries(journalEntry, journalEntryClass, outputList)
		end
	end

	return outputList
end

local function getJournalQuestsMappins(requestContext, newQuests)
	if not requestContext then requestContext = getUnfinishedQuestsJournalRequestContext() end
	local questEntries = journalManager:GetQuests(requestContext)
	if questEntries then
		capturedQuestMappins = {}
		local playerEntId = GetPlayer():GetEntityID();
		if newQuests then
			getJournalEntriesMappins(questEntries, false, true, playerEntId)
		else
			processJournalEntriesForMappinsExtraction(questEntries, false, true, playerEntId)
		end
	end
	return capturedQuestMappins
end

 -- this the main one to call here or from outside. A "public" equivalent
function journalMappinExtractor.getCurrentQuestsMappins()
	if (prevMappinsChangeCounter ~= mappinsChangeCounter or firstTimeRun) then
		if firstTimeRun then journalMappinExtractor.init() end
		getJournalQuestsMappins(unfinishedQuestsRequestContext)
	end
	prevMappinsChangeCounter = mappinsChangeCounter
	return capturedQuestMappins
end

 -- this the main one to call here or from outside. A "public" equivalent
function journalMappinExtractor.getActiveQuestsMappins()
	if (prevMappinsChangeCounter ~= mappinsChangeCounter or firstTimeRun) then
		if firstTimeRun then journalMappinExtractor.init() end
		getJournalQuestsMappins(activeQuestsRequestContext, true)
	end
	prevMappinsChangeCounter = mappinsChangeCounter
	return capturedQuestMappins
end

function journalMappinExtractor.getAllJournalQuestEntries()
	if not IsDefined(journalManager) then journalManager = Ref.Weak(Game.GetJournalManager()) end
	local questsFolder = journalManager:GetEntryByString('quests', 'gameJournalPrimaryFolderEntry')
	local questsFolderPhL = journalManager:GetEntryByString('ep1/quests', 'gameJournalPrimaryFolderEntry')
	local questList = collectJournalEntries(questsFolder, n"gameJournalQuest")
	if questsFolderPhL then questList = collectJournalEntries(questsFolderPhL, n"gameJournalQuest", questList) end
	return questList
end

return journalMappinExtractor
