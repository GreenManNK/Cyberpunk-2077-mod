local GameSettings = require("external/GameSettings")
local Cron = require("external/Cron")
local Util = require("external/Util")
local Lang = require("external/Lang")
local PosData = require("data/PosData")
local NpcData = require("data/NpcData")

function SPAWN:updateTimers(dt)
	self.currentTime = os.clock()

	if self.currentTime > (self.nextNpcHoursEnforceTime or 0) then
		self.nextNpcHoursEnforceTime = self.currentTime + 1.0
		self:enforceNpcBusinessHours()
	end

	if self.currentTime > self.nextCheckTime then
		self.nextCheckTime = self.currentTime + 5

		if self.BANK and self.BANK.getCurrentHalfHourBucket then
			local currentSlice = self.BANK:getCurrentHalfHourBucket()
			if currentSlice ~= self.lastMapPinSlice then
				self.lastMapPinSlice = currentSlice
				self.mapPinsDirty = true
			end
		end

		if self.mapPinsDirty then
			self:switchMapPin()
			self.mapPinsDirty = false
		end
	end
end

function SPAWN:enforceNpcBusinessHours()
	if not self.friendList or #self.friendList <= 0 then
		return
	end

	if not self.BANK or not self.BANK.isLocationOpen then
		return
	end

	local bankerOpen = true
	local branchOpen = true
	pcall(function() bankerOpen = self.BANK:isLocationOpen("banker") end)
	pcall(function() branchOpen = self.BANK:isLocationOpen("branch") end)

	if bankerOpen and branchOpen then
		return
	end

	for i, val in ipairs(self.friendList) do
		local locationType = "banker"
		if val.type == "greeter" or val.type == "branchstaff" then
			locationType = "branch"
		end

		local isOpen = locationType == "branch" and branchOpen or bankerOpen
		if not isOpen and (val.entity ~= nil or val.entityID ~= nil) then
			self:despawnFriendAI(i)
		end
	end
end

function SPAWN:spawnFriend()
	if not self.HUDInput and not self.interactionUI then
		return 0
	end

	if not self.friendList then
		return 0
	end

	local playerPos = nil
	pcall(function()
		local player = Game.GetPlayer()
		if player then playerPos = player:GetWorldPosition() end
	end)
	if playerPos == nil then
		return 0
	end

	local bankerOpen = true
	local branchOpen = true
	if self.BANK and self.BANK.isLocationOpen then
		pcall(function() bankerOpen = self.BANK:isLocationOpen("banker") end)
		pcall(function() branchOpen = self.BANK:isLocationOpen("branch") end)
	end

	for i, val in ipairs(self.friendList) do
		local targetPos = val.posdata and val.posdata.pos or nil
		if playerPos and targetPos then
			local dx = (tonumber(playerPos.x) or 0) - (tonumber(targetPos.x) or 0)
			local dy = (tonumber(playerPos.y) or 0) - (tonumber(targetPos.y) or 0)
			local dz = (tonumber(playerPos.z) or 0) - (tonumber(targetPos.z) or 0)
			val.distance = math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
		else
			val.distance = NPC_DISTANCE_DEFAULT
		end

		if val.entity then
			val.active = val.entity:IsActive()
		end

		local locationType = "banker"
		local interactionDistance = 3
		if val.type == "greeter" or val.type == "branchstaff" then
			locationType = "branch"
			interactionDistance = 4
		end

		local isOpen = locationType == "branch" and branchOpen or bankerOpen

		if not isOpen then
			if val.entity or val.entityID then
				self:despawnFriendAI(i)
			end

			if val.type == "greeter" then
				if val.distance < interactionDistance then
					self:showSubTitle(self.BANK:getGreeterText(false), self.atmFontSize, "Center", false)
				end
			elseif val.distance < interactionDistance then
				return i
			end
		else
			if not val.entityID and val.distance < NPC_SPAWN_DISTANCE then
				self:spawnFriendAI(i)
			end

			if val.type == "greeter" then
				if val.distance < interactionDistance then
					self:showSubTitle(self.BANK:getGreeterText(true), self.atmFontSize, "Center", false)
				end
			elseif val.entity and val.active and val.distance < interactionDistance then
				return i
			end
		end

		if val.entity and val.entityID and val.distance > NPC_DESPAWN_DISTANCE then
			self:despawnFriendAI(i)
		end
	end

	return 0
end

function SPAWN:switchMapPin()
	local mappinSystem = Game.GetMappinSystem()
	local buildingVariant = gamedataMappinVariant.ServicePointJunkVariant
		or gamedataMappinVariant.OpenVendorVariant
		or gamedataMappinVariant.WanderingMerchantVariant

	for _, val in pairs(self.friendList) do
		if val.type ~= "greeter" then
			local caption = self.BANK:getMapPinCaption("banker")

			if val.mappinID and val.mappinCaption ~= caption then
				mappinSystem:UnregisterMappin(val.mappinID)
				val.mappinID = nil
			end

			if not val.mappinID then
				val.mappinID = Util.showMapPin(
					val.posdata.pos,
					buildingVariant,
					Lang.getText("pin_bank_estate_text"),
					caption
				)
			end

			val.mappinCaption = caption
		else
			if val.mappinID then
				mappinSystem:UnregisterMappin(val.mappinID)
				val.mappinID = nil
			end
			val.mappinCaption = nil
		end
	end

	if self.branchMapPinPos == nil then
		local ok, posdata = pcall(function() return Util.getPosDataFromText(POSData_BranchDoorLocation or POSData_GreeterLocation) end)
		if ok and posdata ~= nil then
			self.branchMapPinPos = posdata.pos
		end
	end
	local branchPos = self.branchMapPinPos or Util.getPosDataFromText(POSData_BranchDoorLocation or POSData_GreeterLocation).pos
	local branchCaption = self.BANK:getMapPinCaption("branch")

	if self.branchPinID and self.branchPinCaption ~= branchCaption then
		mappinSystem:UnregisterMappin(self.branchPinID)
		self.branchPinID = nil
	end

	if not self.branchPinID then
		self.branchPinID = Util.showMapPin(
			branchPos,
			buildingVariant,
			Lang.getText("pin_bank_estate_text"),
			branchCaption
		)
	end

	self.branchPinCaption = branchCaption
end
