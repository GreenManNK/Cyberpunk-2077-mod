local GameSettings = require("external/GameSettings")
local Cron = require("external/Cron")
local Util = require("external/Util")
local Lang = require("external/Lang")
local PosData = require("data/PosData")
local NpcData = require("data/NpcData")

NPC_SPAWN_DISTANCE = 100
NPC_DESPAWN_DISTANCE = 200
NPC_DISTANCE_DEFAULT =
	(NPC_SPAWN_DISTANCE + NPC_DESPAWN_DISTANCE) / 2

SPAWN = {}

require("module/SpawnUtil")
require("module/SpawnHub")
require("module/SpawnListener")

function SPAWN:new()
	local o = {}
	o.hub = nil
	o.hubId = nil
	o.hubHide = false
	o.verval_text = nil
	o.verval_size = 65
	o.verval_vert = "Center"
	o.verval_time = nil
	o.atmFontSize = 65
	o.npcBanker = 0
	o.friendList = {}
	o.currentTime = 0
	o.nextCheckTime = 0
	o.lastMapPinSlice = -1
	o.nextNpcHoursEnforceTime = 0
	o.mapPinsDirty = true
	o.branchPinID = nil
	o.branchPinCaption = nil
	o.branchMapPinPos = nil
	self.__index = self
	return setmetatable(o, self)
end

function SPAWN:initialize()
	self.hubHide = false
	self.verval_text = nil
	self.verval_size = 55
	self.verval_vert = "Top"
	self.verval_time = nil
	self.friendList = {}
	self.currentTime = 0
	self.nextCheckTime = 0
	self.lastMapPinSlice = -1
	self.nextNpcHoursEnforceTime = 0
	self.mapPinsDirty = true
	self.branchPinID = nil
	self.branchPinCaption = nil
	self.branchMapPinPos = nil

	self.BANK = require("module/Bank")

	self.interactionUI = require("external/interactionUI")
	self.interactionUI.init()


	self.subTitle = require("external/subtitle")
	self.subTitle.startSubtitleObserver()

	if self.interactionUI and self.subTitle then
		self.isInitialized = true
	end
end

function SPAWN:setSettingValues(atmFontSize, npcBanker)
	self.atmFontSize = atmFontSize
	self.npcBanker = npcBanker
end

function SPAWN:getFriendList()
	return self.friendList
end

function SPAWN:markMapPinsDirty()
	self.mapPinsDirty = true
end

function SPAWN:setupBanker()
	if self.friendList and #self.friendList > 0 then
		self.mapPinsDirty = true
		return
	end

	if self.npcBanker == 0 then
		return
	end

	for index, val in ipairs(POSData_BankerLocation) do
		local posdata = Util.getPosDataFromText(val)
		local rec = NPCData_MiscNPC[self.npcBanker].rec
		local apr = NPCData_MiscNPC[self.npcBanker].apr
		local entry = {
			recordID = rec, entityID = nil, entity = nil, aprname = apr,
			anims_handle = nil, anims_name = ANIM_NAME_CORPO_STAND,
			posdata = posdata, distance = NPC_DISTANCE_DEFAULT, mappinID = nil,
			mappinCaption = nil, type = "banker", variety = "banker_" .. tostring(index), active = false
		}

		table.insert(self.friendList, entry)
	end

	local greeterPos = Util.getPosDataFromText(POSData_GreeterLocation)
	local greeterRec = NPCData_MiscNPC[self.npcBanker].rec
	local greeterApr = NPCData_MiscNPC[self.npcBanker].apr
	local greeterEntry = {
		recordID = greeterRec, entityID = nil, entity = nil, aprname = greeterApr,
		anims_handle = nil, anims_name = ANIM_NAME_CORPO_STAND,
		posdata = greeterPos, distance = NPC_DISTANCE_DEFAULT, mappinID = nil,
		mappinCaption = nil, type = "greeter", variety = "branch_greeter", active = false
	}

	table.insert(self.friendList, greeterEntry)

	self.mapPinsDirty = true
end

function SPAWN:spawnFriendAI(i)
	local npcID = self.friendList[i].recordID
	local comma = string.find(npcID, ',')
	local idNPC = tonumber(string.sub(npcID, comma + 1, string.len(npcID)))
	local hasheNPC = tonumber(string.sub(npcID, 1, comma - 1))

	self.friendList[i].entityID = npcSpawn(
		TweakDBID.new(hasheNPC, idNPC),
		self.friendList[i].posdata.pos,
		self.friendList[i].posdata.ang
	)

	Cron.Every(1, {tick = 1}, function(timer)
		if not self.friendList or not self.friendList[i] then
			Cron.Halt(timer)
			return
		end

		local entity = nil

		if self.friendList[i].entityID then
			entity = Game.FindEntityByID(self.friendList[i].entityID)
		end

		timer.tick = timer.tick + 1

		if timer.tick > 10 then
			self:despawnFriendAI(i)
			Cron.Halt(timer)
			return
		end

		if entity then
			self.friendList[i].entity = entity

			Cron.After(2, function()
				if not self.friendList[i] or not self.friendList[i].entityID then
					return
				end

				if self.friendList[i].aprname then
					entity:PrefetchAppearanceChange(self.friendList[i].aprname)
					entity:ScheduleAppearanceChange(self.friendList[i].aprname)
				end

				if self.friendList[i].anims_name then
					self.friendList[i].anims_handle = setAnimation(
						entity,
						ANIM_ENT,
						self.friendList[i].anims_name,
						ANIM_COMP
					)
				end

				setFriendly(entity)
			end)

			Cron.Halt(timer)
		end
	end)
end

function SPAWN:despawnFriendAI(i)
	local entry = self.friendList[i]
	if not entry then
		return
	end

	if entry.anims_handle then
		stopAnimation(entry.entity, entry.anims_handle)
		entry.anims_handle = nil
	end

	if entry.entityID then
		Game.GetDynamicEntitySystem():DeleteEntity(entry.entityID)
	end

	entry.entity = nil
	entry.entityID = nil
	entry.active = false
end

function SPAWN:clearSessionData()
	for _, val in pairs(self.friendList) do
		if val.mappinID then
			Game.GetMappinSystem():UnregisterMappin(val.mappinID)
		end
	end

	if self.branchPinID then
		Game.GetMappinSystem():UnregisterMappin(self.branchPinID)
	end

	self.friendList = {}
	self.currentTime = 0
	self.nextCheckTime = 0
	self.lastMapPinSlice = -1
	self.nextNpcHoursEnforceTime = 0
	self.mapPinsDirty = true
	self.branchPinID = nil
	self.branchPinCaption = nil
	self.branchMapPinPos = nil
end

return SPAWN
