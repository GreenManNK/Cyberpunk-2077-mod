-- Based on (c)keanuWheeze Nano Drone mod code thanks to keanuWheeze consent to use and adapt the code for the Hotscenes Spycam.
-- Mar 1, 2026 by anygoodname
local moduleVer = "3.10.6"

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

local Ref = require("Ref")
if not Ref then return end

local cetVerStr = GetVersion()
local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- (c)psiberx
	return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
end)))

local isGameV2 = true
if cetVer < 1.26 then isGameV2 = false end

drone = {}
local gameVer = 0
local isCooldownTimeDilationIgnoreSupported = false
local droneCameraEntPath = 'base\\hotscenes\\spycam\\security_surveillance_camera_old.ent'
local trackerEntPath = "base\\hotscenes\\spycam\\player_tracker.ent"
local playerTracker = {}
local npcTracker = {}
local reuseCamera = false
local newSpycam = {entIdHash = 120936542645690848ULL, nodedbn = '{mod_hotscenes_spycam_new}', cpid = "mod_hotscenes_spycam_new"}
local isNewSpycamAvailable = false
local isUsingNewSpycam = false
local n
local n_ItemAttachmentSlots = "ItemAttachmentSlots"
local n_Head = "Head"
local n_hotscenes_spycam_player_tracker = "hotscenes_spycam_player_tracker"
local n_mod_hotscenes_spycam_take_control_cooldown = "mod_hotscenes_spycam_take_control_cooldown"
local n_mod_hotscenes_spycam_spawn_cooldown = "mod_hotscenes_spycam_spawn_cooldown"
local n_mod_hotscenes_spycam_release_control_cooldown = "mod_hotscenes_spycam_release_control_cooldown"
local n_mod_hotscenes_spycam_despawn_cooldown = "mod_hotscenes_spycam_despawn_cooldown"
local n_Static = "Static"
local n_PlayerBlocker = "PlayerBlocker"
local n_SurveillanceCamera = "SurveillanceCamera"
local n_NPCPuppet = "NPCPuppet"
local n_PlayerPuppet = "PlayerPuppet"
local n_camera_mask = "camera_mask"
local n_entEntity = "entEntity"
local spatialQueriesSystem
local Vector4new
local EulerAnglesnew
local GameFindEntityByID
local gameBlackboardSystem
local sceneSystem

local minDespawnTicks = 10
if reuseCamera then minDespawnTicks = 5 end
local isConstantDataInitialized
function drone:new(nd)
	if not isConstantDataInitialized then
		n = CName
		n_ItemAttachmentSlots = n"ItemAttachmentSlots"
		n_Head = n"Head"
		n_hotscenes_spycam_player_tracker = n"hotscenes_spycam_player_tracker"
		n_mod_hotscenes_spycam_take_control_cooldown = n"mod_hotscenes_spycam_take_control_cooldown"
		n_mod_hotscenes_spycam_spawn_cooldown = n"mod_hotscenes_spycam_spawn_cooldown"
		n_mod_hotscenes_spycam_release_control_cooldown = n"mod_hotscenes_spycam_release_control_cooldown"
		n_mod_hotscenes_spycam_despawn_cooldown = n"mod_hotscenes_spycam_despawn_cooldown"
		n_Static = n"Static"
		n_PlayerBlocker = n"PlayerBlocker"
		n_SurveillanceCamera = n"SurveillanceCamera"
		n_NPCPuppet = n"NPCPuppet"
		n_PlayerPuppet = n"PlayerPuppet"
		n_camera_mask = n"camera_mask"
		n_entEntity = n"entEntity"
		spatialQueriesSystem = Game.GetSpatialQueriesSystem()
		Vector4new = Vector4.new
		EulerAnglesnew = EulerAngles.new
		GameFindEntityByID = Game.FindEntityByID
		gameBlackboardSystem = Game.GetBlackboardSystem()
		sceneSystem = Game.GetSceneSystem()
		isConstantDataInitialized = true
	end

	local o = {}

	o.nd = nd
	o.spawned = false
	o.spawnRequested = false
	o.spawnRequestedTimeout = 0
	o.despawnRequested = false
	o.despawnWaitTicks = 0
	o.despawnRequestedTimeout = 0
	o.lastReleaseControlRequest = 0
	o.entID = nil
	o.forceTakeOver = false
	o.fullySpawned = false

	o.handle = nil

	o.prevPos = nil
	o.pos = nil
	o.prevRot = nil
	o.rot = nil

	o.vel = nil
	o.orbitVel = nil
	o.accel = 0
	o.topSpeed = 0
	o.range = 0

	o.maxPitch = 86
	o.minPitch = -86
	o.orbitPitchWithMouse = true
	o.orbitMode = false
	o.isNewOrbit = false

	o.npcHeadVoffset = 1.5
	o.npcChestVoffset = 1.25

	o.playerFppCamStandingVOffset = 1.6
	o.playerFppOverhead = 0.35

	o.traceTarget = false
	o.traceTargetIsObject = false
	o.trackedEntityID = nil
	o.trackedPosition = nil

	o.moduleVer = moduleVer
	gameVer = tonumber(Game.GetSystemRequestsHandler():GetGameVersion())
	isCooldownTimeDilationIgnoreSupported = gameVer >= 1.61
	self.__index = self
	return setmetatable(o, self)
end

function drone:init()
	self.spawned = false
	self.spawnRequested = false
	self.spawnRequestedTimeout = 0
	self.despawnRequested = false
	self.despawnRequestedTimeout = 0
	self.entID = nil
	self.forceTakeOver = false
	self.fullySpawned = false
	self.handle = nil

	self.traceTarget = false
	self.traceTargetIsObject = false
	self.trackedEntityID = nil
	self.trackedPosition = nil

	self.batteryPercent = 100
	self.pos = Vector4new()
	self.vel = Vector4new()
	self.orbitVel = Vector4new()
	self.orbitMode = false
	self.isNewOrbit = false
end

local playerToCameraYaw = 0
local spawnDist = 3

local mathSqrt = math.sqrt
local function vectorDistance(src, target);
    local dx = target.x - src.x;
    local dy = target.y - src.y;
    local dz = target.z - src.z;
    return mathSqrt(dx * dx + dy * dy + dz * dz);
end;
local function vectorDistance2D(src, target);
    local dx = target.x - src.x;
    local dy = target.y - src.y;
    return mathSqrt(dx * dx + dy * dy);
end;
local function vectorDistanceSquared(src, target)
    local dx = target.x - src.x;
    local dy = target.y - src.y;
    local dz = target.z - src.z;
    return dx * dx + dy * dy + dz * dz;
end;
local function vectorDistanceSquared2D(src, target);
    local dx = target.x - src.x;
    local dy = target.y - src.y;
    return dx * dx + dy * dy;
end;
local function isValidVector4(input)
	if type(input) ~= 'userdata' then return false end
	if type(input.IsZero) ~= 'function' then return false end
	if input.x ~= 0 then return true end
	if input.y ~= 0 then return true end
	if input.z ~= 0 then return true end
end
local function isValidVector34Unsafe(input)
	if input.x ~= 0 then return true end
	if input.y ~= 0 then return true end
	if input.z ~= 0 then return true end
end
local function isVector34ZeroUsafe(input)
	if input.x ~= 0 then return end
	if input.y ~= 0 then return end
	if input.z ~= 0 then return end
	return true
end

local mathMax = math.max
local mathMin = math.min
local mathSin = math.sin
local mathCos = math.cos
local mathRad = math.rad
local stringFind = string.find

function drone:spawn(newSpawnPos, newSpawnYaw, limitByRaycast)
	local player = GetPlayer()
	if not player then return end
	if isPlayerControllingDevice(player) then return end
	
	local shouldWaitOnColdown = player:IsCooldownActive(n_mod_hotscenes_spycam_spawn_cooldown) or player:IsCooldownActive(n_mod_hotscenes_spycam_take_control_cooldown) or  player:IsCooldownActive(n_mod_hotscenes_spycam_release_control_cooldown) or player:IsCooldownActive(n_mod_hotscenes_spycam_despawn_cooldown)
	if shouldWaitOnColdown or (self.lastDespawnTime and os.clock() - self.lastDespawnTime < 0.35) then self.queueSpawn = {newSpawnPos = newSpawnPos, newSpawnYaw = newSpawnYaw, limitByRaycast = limitByRaycast, nextUpdateTime = os.clock() + 0.001} return end

	self.queueSpawn = nil
	if self.spawned or self.spawnRequested or self.despawnRequested then return end

	self.accel = 0.26
	self.topSpeed = 0.22

	if IsDefinedNS(playerTracker.handle) then
		playerTracker.entID = playerTracker.handle:GetEntityID()
		if not playerTracker.isAttached then
			local entity = playerTracker.handle:GetEntity()
			EntityGameInterface.UnbindTransform(entity);
			EntityGameInterface.BindToComponent(entity, player:GetEntity(), n_ItemAttachmentSlots, n_Head, false);
			playerTracker.isAttached = true
		end
	else
		playerTracker = {}
		local spawnTransform = WorldTransform.new();
		WorldTransform.SetPosition(spawnTransform, Vector4new(0.05,-0.12,0,0));
		WorldTransform.SetOrientationEuler(spawnTransform, EulerAnglesnew(-90, 0, 180));
		playerTracker.entID = spawnEntity(trackerEntPath, spawnTransform)
	end

	if newSpawnPos then
		if type(newSpawnPos) ~= 'userdata' then
			newSpawnPos = nil
		elseif not stringFind(tostring(newSpawnPos), 'Vector4') then
			newSpawnPos = nil
		end
	end
	if type(newSpawnYaw) ~= 'number' then newSpawnYaw = nil end

	local playerPos, playerYaw, playerToObjectAngle = nil, nil, nil	
	local cameraObjectRotation = EulerAnglesnew()
	local playerEyesPos, playerEyesYaw, isTracker = getPlayerEyesPosAndRot(1)
	if playerEyesYaw then playerEyesYaw = playerEyesYaw.yaw end

	if newSpawnYaw then
		playerYaw = newSpawnYaw
		cameraObjectRotation.yaw = newSpawnYaw
	else
		if playerEyesYaw then playerYaw = playerEyesYaw else playerYaw = player:GetWorldYaw() end
	end

	if not newSpawnPos then
		if playerEyesPos then playerPos = playerEyesPos else playerPos = Game.GetTargetingSystem():GetCrosshairData(player) end

		playerPos.z = mathMax(playerPos.z, player:GetWorldPosition().z + self.playerFppCamStandingVOffset)
		playerPos.z = playerPos.z + self.playerFppOverhead

		local playerToObjectAngle = normalizeYaw(playerYaw + 90)
		newSpawnPos = Vector4new(playerPos.x + spawnDist * mathCos(mathRad(playerToObjectAngle)), playerPos.y + spawnDist * mathSin(mathRad(playerToObjectAngle)), playerPos.z, 1)
		cameraObjectRotation.yaw = normalizeYaw(playerYaw + 180)
	end

	self.pos, playerToCameraYaw = self:rangeLimiter(newSpawnPos, limitByRaycast)
	if playerToCameraYaw then cameraObjectRotation.yaw = playerToCameraYaw + 90 end
	startCooldown(n_mod_hotscenes_spycam_spawn_cooldown, 0.5, true)

	isUsingNewSpycam = false
	reuseCamera = false
	if isNewSpycamAvailable or (isKnownName(newSpycam.nodedbn) and isKnownName(newSpycam.cpid)) then
		isNewSpycamAvailable = true
		if not newSpycam.entID then  newSpycam.entID = entEntityID.new({hash = newSpycam.entIdHash}) end
		local handle = GameFindEntityByID(newSpycam.entID)
		if handle then newSpycam.handle = Ref.Weak(handle) else newSpycam.handle = nil end
		if newSpycam.handle and newSpycam.handle:FindComponentByName(newSpycam.cpid) then
			isUsingNewSpycam = true
			self.handle = newSpycam.handle
			reuseCamera = true
		else
			newSpycam.handle = nil
		end
	end

	if reuseCamera and IsDefinedNS(self.handle) and self.handle:IsA(n_SurveillanceCamera) and (isUsingNewSpycam or self.handle:FindComponentByName("int_electronics_002__corpo_security_camera_d__wall_mount_vertical")) then
		self.entID = self.handle:GetEntityID()
		Game.GetTeleportationFacility():Teleport(self.handle, self.pos, cameraObjectRotation)
	else
		if self.entID then
			local leftoverHandle = GameFindEntityByID(self.entID)
			if leftoverHandle then
				if Codeware then
					Game.GetDynamicEntitySystem():DeleteEntity(self.entID)
				else
					exEntitySpawner.Despawn(leftoverHandle)
				end
			end
		end
		self.entID = nil
		local spawnTransform = WorldTransform.new();
		spawnTransform:SetPosition(self.pos)
		spawnTransform:SetOrientation(cameraObjectRotation:ToQuat())
		self.entID = spawnEntity(droneCameraEntPath, spawnTransform)
	end

	self.forceTakeOver = true
	self.spawnRequested = true
	self.spawnRequestedTimeout = os.clock() + 5
	self.despawnRequested = false
	self.despawnRequestedTimeout = 0
	self.orbitMode = false
end

function getPlayerEyesPosAndRot(mode)

	local modeType = type(mode)
	if modeType == 'boolean' then
		if mode then
			mode = 0
		else
			mode = -1
		end
	elseif
		modeType ~= 'number'
		then mode = 0
	end

	local sceneCamPos, sceneCamRot = nil, nil
	local isTracker = false
	if mode < 0 then
		return
	elseif mode < 1 then
		-- placeholder
	else
		if playerTracker.isAttached and IsDefinedNS(playerTracker.handle) and vectorDistanceSquared(playerTracker.handle:GetWorldPosition(), Vector4new()) > 1 then
			isTracker = true
			sceneCamPos = playerTracker.handle:GetWorldPosition()
			sceneCamRot = playerTracker.handle:GetWorldOrientation()
			return sceneCamPos, sceneCamRot, isTracker
		else
			local scn = sceneSystem:GetScriptInterface()
			sceneCamPos = scn:GetSceneSystemCameraLastCameraPosition():ToVector4()
			sceneCamRot = nil

			if sceneCamPos then
				if isVector34ZeroUsafe(sceneCamPos) then
					sceneCamPos = nil
				else
					sceneCamPos = sceneCamPos
					sceneCamRot = scn:GetSceneSystemCameraLastCameraOrientation():ToEulerAngles()
				end
			end
		end
	end

	if sceneCamPos then
		return sceneCamPos, sceneCamRot, isTracker
	else
		local playerCamLocalToWorld = GetPlayer():GetFPPCameraComponent():GetLocalToWorld()
		if playerCamLocalToWorld then
			return playerCamLocalToWorld:GetTranslation(), playerCamLocalToWorld:GetRotation(), isTracker
		end
	end
end

function drone:setControlledCameraTargetToObject(obj, zOffset, setData, returnTargetPositionOnly)
	if not IsDefinedNS(obj) then return end
	if not obj:IsA(n_entEntity) then return end

	local objPos
	if obj:IsA(n_PlayerPuppet) then
		local playerCamPos, playerCamRot, isTracker = getPlayerEyesPosAndRot(1)
		if playerCamPos then
			objPos = playerCamPos
			if isTracker then zOffset = 0 else
				if zOffset > 0 then zOffset = zOffset - (playerCamPos.z - GetPlayer():GetWorldPosition().z) end
			end
		end
	end

	objPos = objPos or obj:GetWorldPosition()
	if returnTargetPositionOnly then return objPos, zOffset end

	self:setControlledCameraTargetToPos(objPos, zOffset, setData, isTracker)
end

function drone:setControlledCameraTargetToPos(gameObjPos, zOffset, setData, isTracker)
	if type(gameObjPos) ~= 'userdata' then return end
	if not gameObjPos.IsZero then return end
	if isTracker then zOffset = 0 else if type(zOffset) ~= 'number' then zOffset = 0 end end

	local cameraObjPos = self.handle:GetWorldPosition()
	local cameraObjYaw = self.handle:GetWorldYaw()
	local cameraObjToObjRotation = Vector4new(gameObjPos.x - cameraObjPos.x, gameObjPos.y - cameraObjPos.y, gameObjPos.z + zOffset - cameraObjPos.z, 0):ToRotation()
	local cameraViewPitch, cameraViewYaw = 0, 0

	cameraViewYaw = cameraObjToObjRotation.yaw - cameraObjYaw
	if cameraViewYaw > 180 then cameraViewYaw = cameraViewYaw - 360
	elseif cameraViewYaw < -180 then cameraViewYaw = cameraViewYaw + 360 end

	cameraViewPitch = -cameraObjToObjRotation.pitch
	if cameraViewPitch > 180 then cameraViewPitch = cameraViewPitch - 360
	elseif cameraViewPitch < -180 then cameraViewPitch = cameraViewPitch + 360 end

	if setData then self:setControlledCameraPitchYaw(cameraViewPitch, cameraViewYaw) end
end

function drone:setControlledCameraPitchYaw(pitch, yaw)
	if type(pitch) ~= 'number' then pitch = nil end
	if type(yaw) ~= 'number' then yaw = nil end

	self.prevRot = self.handle:GetWorldOrientation():ToEulerAngles()
	local newRotation = EulerAnglesnew(self.prevRot)
	newRotation.roll = 0

	if yaw then newRotation.yaw = newRotation.yaw - yaw end
	if newRotation.yaw > 180 then newRotation.yaw = newRotation.yaw - 360
	elseif newRotation.yaw < -180 then newRotation.yaw = newRotation.yaw + 360 end

	if pitch then newRotation.pitch = pitch end
	if newRotation.pitch > self.maxPitch then newRotation.pitch = self.maxPitch
	elseif newRotation.pitch < self.minPitch then newRotation.pitch = self.minPitch end

	local hasAnythingChanged = false
	if newRotation.roll ~= self.prevRot.roll then hasAnythingChanged = true
	elseif newRotation.pitch ~= self.prevRot.pitch then hasAnythingChanged = true
	elseif newRotation.yaw ~= self.prevRot.yaw then hasAnythingChanged = true
	end

	if hasAnythingChanged then
		self.rot = newRotation
		Game.GetTeleportationFacility():Teleport(self.handle, self.pos, self.rot)
	end
end

function drone:toggleCameraPitchYawControl(enable)
	if not enable then self.handle:QueueEvent(gameeventsDeviceEndPlayerCameraControlEvent.new()) return end

	local currentCameraViewRotation = self.handle:GetRotationFromSlotRotation()
	local cameraRotationData = self.handle:GetRotationData()
	if not cameraRotationData then
		cameraRotationData = CameraRotationData.new()
		cameraRotationData.minYaw = 0.0
		cameraRotationData.maxYaw = 0.0
		cameraRotationData.minPitch = -70.0
		cameraRotationData.maxPitch = 70.0
		cameraRotationData.yaw = currentCameraViewRotation.yaw
		cameraRotationData.pitch = -currentCameraViewRotation.pitch
	end

	cameraControlEvt = gameeventsDeviceStartPlayerCameraControlEvent.new()
	cameraControlEvt.playerController = GetPlayer()

	cameraControlEvt.minYaw = cameraRotationData.minYaw
	cameraControlEvt.maxYaw = cameraRotationData.maxYaw
	cameraControlEvt.minPitch = -89
	cameraControlEvt.maxPitch = 89
	cameraControlEvt.initialRotation = Vector4new(currentCameraViewRotation.yaw, -currentCameraViewRotation.pitch, 0, 0)

	self.handle:QueueEvent(gameeventsDeviceEndPlayerCameraControlEvent.new())
	self.handle:QueueEvent(cameraControlEvt)
end

function drone:despawn(dirty)
	if (not self.spawned) and (not self.spawnRequested) and (not self.despawnRequested) then return end

	if Game.GetTimeSystem():IsTimeDilationActive("mod_hotscenes_spycam_freeze_frame") then Game.GetTimeSystem():UnsetTimeDilation("mod_hotscenes_spycam_freeze_frame") end
	if not dirty then
		local player = GetPlayer()
		if not player then return end
		if player:IsCooldownActive(n_mod_hotscenes_spycam_spawn_cooldown) then return end
		if player:IsCooldownActive(n_mod_hotscenes_spycam_take_control_cooldown) then return end
		if player:IsCooldownActive(n_mod_hotscenes_spycam_release_control_cooldown) then return end
		if player:IsCooldownActive(n_mod_hotscenes_spycam_despawn_cooldown) then return end
		if isPlayerControllingDevice() then
			startCooldown(n_mod_hotscenes_spycam_release_control_cooldown, 0.5, true)
			self.lastReleaseControlRequest = os.clock()
			self.handle:GetTakeOverControlSystem():ToggleToMainPlayerObject()
		end
	end

	if not IsDefinedNS(playerTracker.handle) then playerTracker.handle = nil end
	if not playerTracker.handle and playerTracker.entID then playerTracker.handle = Ref.Weak(GameFindEntityByID(playerTracker.entID)) end
	if playerTracker.handle and playerTracker.handle:FindComponentByName(n_hotscenes_spycam_player_tracker) then
		EntityGameInterface.UnbindTransform(playerTracker.handle:GetEntity());
		playerTracker.isAttached = false
	end

	self.spawnRequestedTimeout = 0
	self.despawnRequested = true
	self.despawnRequestedTimeout = os.clock() + 5
	self.traceTarget = false
	self.traceTargetIsObject = false
	self.trackedPosition = nil
end

function drone:handleInput(deltaTime)

	local acc = deltaTime * self.accel
	local f = 1.8

	if self.nd.input.forward then
		self.vel.y = mathMin(self.vel.y + acc * self.nd.input.analogForward, mathMax(self.vel.y, self.topSpeed * self.nd.input.analogForward))
	elseif self.vel.y > 0 then
		self.vel.y = self.vel.y - acc * f
		self.vel.y = mathMax(0, self.vel.y)
	end

	if self.nd.input.backwards then
		self.vel.y = mathMax(self.vel.y - acc * self.nd.input.analogBackwards, mathMin(self.vel.y, -self.topSpeed * self.nd.input.analogBackwards))
	elseif self.vel.y < 0 then
		self.vel.y = self.vel.y + acc * f
		self.vel.y = mathMin(0, self.vel.y)
	end

	if self.nd.input.right then
		self.vel.x = mathMin(self.vel.x + acc * self.nd.input.analogRight, mathMax(self.vel.x, self.topSpeed * self.nd.input.analogRight))
	elseif self.vel.x > 0 then
		self.vel.x = self.vel.x - acc * f
		self.vel.x = mathMax(0, self.vel.x)
	end
	if self.nd.input.left then
		self.vel.x = mathMax(self.vel.x - acc * self.nd.input.analogLeft, mathMin(self.vel.x, -self.topSpeed * self.nd.input.analogLeft))
	elseif self.vel.x < 0 then
		self.vel.x = self.vel.x + acc * f
		self.vel.x = mathMin(0, self.vel.x)
	end

	local rotSpeed = 0.25

	if self.nd.input.orbitForward then
		self.orbitVel.y = rotSpeed * self.nd.input.analogOrbitForward
	elseif self.orbitVel.y > 0 then
		self.orbitVel.y = self.orbitVel.y - 1
		self.orbitVel.y = mathMax(0, self.orbitVel.y)
	end
	if self.nd.input.orbitBackwards then
		self.orbitVel.y = -rotSpeed * self.nd.input.analogOrbitBackwards
	elseif self.orbitVel.y < 0 then
		self.orbitVel.y = self.orbitVel.y + 1
		self.orbitVel.y = mathMin(0, self.orbitVel.y)
	end

	if self.nd.input.orbitRight then
		self.orbitVel.x = rotSpeed * self.nd.input.analogOrbitRight
	elseif self.orbitVel.x > 0 then
		self.orbitVel.x = self.orbitVel.x - 1
		self.orbitVel.x = mathMax(0, self.orbitVel.x)
	end
	if self.nd.input.orbitLeft then
		self.orbitVel.x = -rotSpeed * self.nd.input.analogOrbitLeft
	elseif self.orbitVel.x < 0 then
		self.orbitVel.x = self.orbitVel.x + 1
		self.orbitVel.x = mathMin(0, self.orbitVel.x)
	end

end

function drone:move(deltaTime)

	local globalVel = Vector4new(0, 0, 0, 0)

	local dir = Game.GetCameraSystem():GetActiveCameraForward()
	local deltaTimeVelY = self.vel.y * deltaTime * 25
	globalVel.x = globalVel.x + dir.x * deltaTimeVelY
	globalVel.y = globalVel.y + dir.y * deltaTimeVelY

	globalVel.z = globalVel.z + dir.z * deltaTimeVelY

	local dir = Game.GetCameraSystem():GetActiveCameraRight()
	local deltaTimeVelX = self.vel.x * deltaTime * 25
	globalVel.x = globalVel.x + dir.x * deltaTimeVelX
	globalVel.y = globalVel.y + dir.y * deltaTimeVelX

	self.prevPos = Vector4new(self.pos)
	self.prevRot = self.handle:GetWorldOrientation():ToEulerAngles()

	local newPos = Vector4new(self.pos.x + globalVel.x, self.pos.y + globalVel.y, self.pos.z + globalVel.z)
	local playerToCameraYaw = 0
	newPos, playerToCameraYaw = self:rangeLimiter(newPos)

	local newRotation = EulerAnglesnew(self.prevRot)
	newRotation.roll = 0
	newRotation.yaw = newRotation.yaw - self.orbitVel.x * deltaTime * 50
	if newRotation.yaw > 180 then newRotation.yaw = newRotation.yaw - 360
	elseif newRotation.yaw < -180 then newRotation.yaw = newRotation.yaw + 360 end

	newRotation.pitch = newRotation.pitch + self.orbitVel.y * deltaTime * 50
	if newRotation.pitch > self.maxPitch then newRotation.pitch = self.maxPitch
	elseif newRotation.pitch < self.minPitch then newRotation.pitch = self.minPitch end

	local hasAnythingChanged = false

	if not self.prevPos then hasAnythingChanged = true
	elseif vectorDistanceSquared(newPos, self.prevPos) > 0.0001 then hasAnythingChanged = true
	elseif newRotation.roll ~= self.prevRot.roll then hasAnythingChanged = true
	elseif newRotation.pitch ~= self.prevRot.pitch then hasAnythingChanged = true
	elseif newRotation.yaw ~= self.prevRot.yaw then hasAnythingChanged = true
	end

	if hasAnythingChanged then
		self.pos = newPos
		self.rot = newRotation
		Game.GetTeleportationFacility():Teleport(self.handle, self.pos, self.rot)
	end
end

function drone:orbitHandleInput(deltaTime)

	if self.nd.input.analogLeft then
		self.nd.input.analogRightIsBlocked = false
		self.nd.input.analogOrbitLeftIsBlocked = false
		self.nd.input.analogOrbitRightIsBlocked = false
		self.nd.input.analogForwardIsBlocked = false
		self.nd.input.analogBackwardsIsBlocked = false
		self.nd.input.analogOrbitForwardIsBlocked = false
		self.nd.input.analogOrbitBackwardsIsBlocked = false
	end
	if self.nd.input.analogRight then
		self.nd.input.analogLeftIsBlocked = false
		self.nd.input.analogOrbitLeftIsBlocked = false
		self.nd.input.analogOrbitRightIsBlocked = false
		self.nd.input.analogForwardIsBlocked = false
		self.nd.input.analogBackwardsIsBlocked = false
		self.nd.input.analogOrbitForwardIsBlocked = false
		self.nd.input.analogOrbitBackwardsIsBlocked = false
	end
	if self.nd.input.analogOrbitLeft then
		self.nd.input.analogLeftIsBlocked = false
		self.nd.input.analogRightIsBlocked = false
		self.nd.input.analogOrbitRightIsBlocked = false
		self.nd.input.analogForwardIsBlocked = false
		self.nd.input.analogBackwardsIsBlocked = false
		self.nd.input.analogOrbitForwardIsBlocked = false
		self.nd.input.analogOrbitBackwardsIsBlocked = false
	end
	if self.nd.input.analogOrbitRight then
		self.nd.input.analogLeftIsBlocked = false
		self.nd.input.analogRightIsBlocked = false
		self.nd.input.analogOrbitLeftIsBlocked = false
		self.nd.input.analogForwardIsBlocked = false
		self.nd.input.analogBackwardsIsBlocked = false
		self.nd.input.analogOrbitForwardIsBlocked = false
		self.nd.input.analogOrbitBackwardsIsBlocked = false
	end
	if self.nd.input.analogForward then
		self.nd.input.analogLeftIsBlocked = false
		self.nd.input.analogRightIsBlocked = false
		self.nd.input.analogOrbitLeftIsBlocked = false
		self.nd.input.analogOrbitRightIsBlocked = false
		self.nd.input.analogBackwardsIsBlocked = false
		self.nd.input.analogOrbitForwardIsBlocked = false
		self.nd.input.analogOrbitBackwardsIsBlocked = false
	end
	if self.nd.input.analogBackwards then
		self.nd.input.analogLeftIsBlocked = false
		self.nd.input.analogRightIsBlocked = false
		self.nd.input.analogOrbitLeftIsBlocked = false
		self.nd.input.analogOrbitRightIsBlocked = false
		self.nd.input.analogForwardIsBlocked = false
		self.nd.input.analogOrbitForwardIsBlocked = false
		self.nd.input.analogOrbitBackwardsIsBlocked = false
	end
	if self.nd.input.analogOrbitForward then
		self.nd.input.analogLeftIsBlocked = false
		self.nd.input.analogRightIsBlocked = false
		self.nd.input.analogOrbitLeftIsBlocked = false
		self.nd.input.analogOrbitRightIsBlocked = false
		self.nd.input.analogForwardIsBlocked = false
		self.nd.input.analogBackwardsIsBlocked = false
		self.nd.input.analogOrbitBackwardsIsBlocked = false
	end
	if self.nd.input.analogOrbitBackwards then
		self.nd.input.analogLeftIsBlocked = false
		self.nd.input.analogRightIsBlocked = false
		self.nd.input.analogOrbitLeftIsBlocked = false
		self.nd.input.analogOrbitRightIsBlocked = false
		self.nd.input.analogForwardIsBlocked = false
		self.nd.input.analogBackwardsIsBlocked = false
		self.nd.input.analogOrbitForwardIsBlocked = false
	end

	local maxOrbitSpeed = 0.1
	local acc, f = 1, 1

	local isKeyboardYaw = false

	if not self.nd.input.analogRightIsBlocked then
		if self.nd.input.right then
			self.vel.x = mathMin(self.vel.x + acc * self.nd.input.analogRight, mathMax(self.vel.x, maxOrbitSpeed * self.nd.input.analogRight))
			isKeyboardYaw = true
		elseif self.vel.x > 0 then
			self.vel.x = self.vel.x - acc * f
			self.vel.x = mathMax(0, self.vel.x)
			isKeyboardYaw = true
		end
	end

	if not self.nd.input.analogLeftIsBlocked then
		if self.nd.input.left then
			self.vel.x = mathMax(self.vel.x - acc * self.nd.input.analogLeft, mathMin(self.vel.x, -maxOrbitSpeed * self.nd.input.analogLeft))
			isKeyboardYaw = true
		elseif self.vel.x < 0 then
			self.vel.x = self.vel.x + acc * f
			self.vel.x = mathMin(0, self.vel.x)
			isKeyboardYaw = true
		end
	end

	if isKeyboardYaw then self.orbitVel.x = - self.vel.x
	else
		if not self.nd.input.analogOrbitForwardIsBlocked then
			if self.nd.input.orbitForward then
				self.orbitVel.y = mathMin(self.orbitVel.y + acc * self.nd.input.analogOrbitForward, mathMax(self.orbitVel.y, maxOrbitSpeed * self.nd.input.analogOrbitForward))
			elseif self.orbitVel.y > 0 then
				self.orbitVel.y = self.orbitVel.y - 1
				self.orbitVel.y = mathMax(0, self.orbitVel.y)
			end
		end

		if not self.nd.input.analogOrbitBackwardsIsBlocked then
			if self.nd.input.orbitBackwards then
				self.orbitVel.y = mathMax(self.orbitVel.y - acc * self.nd.input.analogOrbitBackwards, mathMin(self.orbitVel.y, -maxOrbitSpeed * self.nd.input.analogOrbitBackwards))
			elseif self.orbitVel.y < 0 then
				self.orbitVel.y = self.orbitVel.y + 1
				self.orbitVel.y = mathMin(0, self.orbitVel.y)
			end
		end

		if not self.nd.input.analogOrbitRightIsBlocked then
			if self.nd.input.orbitRight then
				self.orbitVel.x = mathMin(self.orbitVel.x + acc * self.nd.input.analogOrbitRight, mathMax(self.orbitVel.x, maxOrbitSpeed * self.nd.input.analogOrbitRight))
			elseif self.orbitVel.x > 0 then
				self.orbitVel.x = self.orbitVel.x - 1
				self.orbitVel.x = mathMax(0, self.orbitVel.x)
			end
		end

		if not self.nd.input.analogOrbitLeftIsBlocked then
			if self.nd.input.orbitLeft then
				self.orbitVel.x = mathMax(self.orbitVel.x - acc * self.nd.input.analogOrbitLeft, mathMin(self.orbitVel.x, -maxOrbitSpeed * self.nd.input.analogOrbitLeft))
			elseif self.orbitVel.x < 0 then
				self.orbitVel.x = self.orbitVel.x + 1
				self.orbitVel.x = mathMin(0, self.orbitVel.x)
			end
		end
	end

	local acc = deltaTime * self.accel
	local f = 1.8

	if not self.nd.input.analogForwardIsBlocked then
		if self.nd.input.forward then
			self.vel.y = mathMin(self.vel.y + acc * self.nd.input.analogForward, mathMax(self.vel.y, self.topSpeed * self.nd.input.analogForward))
		elseif self.vel.y > 0 then
			self.vel.y = self.vel.y - acc * f
			self.vel.y = mathMax(0, self.vel.y)
		end
	end

	if not self.nd.input.analogBackwardsIsBlocked then
		if self.nd.input.backwards then
			self.vel.y = mathMax(self.vel.y - acc * self.nd.input.analogBackwards, mathMin(self.vel.y, -self.topSpeed * self.nd.input.analogBackwards))
		elseif self.vel.y < 0 then
			self.vel.y = self.vel.y + acc * f
			self.vel.y = mathMin(0, self.vel.y)
		end
	end
end

function drone:orbitMove(deltaTime, centerPos, bounceBack)

	local playerEyesDetectionMode = 1
	local playerEyesPos, playerEyesYaw, isTracker, isTrackerVerified

	if not centerPos then
		playerEyesPos, playerEyesYaw, isTracker = getPlayerEyesPosAndRot(playerEyesDetectionMode)
		centerPos = playerEyesPos
		isTrackerVerified = true
	end

	local tooCloseRange2D = 0.75

	local camDist3d = vectorDistance(centerPos, self.pos) - self.vel.y * deltaTime * 25
	if camDist3d < tooCloseRange2D then camDist3d = tooCloseRange2D end

	self.prevPos = Vector4new(self.pos)
	self.prevRot = self.handle:GetWorldOrientation():ToEulerAngles()

	local camPos = self.pos
	local newRotation = Vector4new(camPos.x - centerPos.x, camPos.y - centerPos.y, camPos.z - centerPos.z, 0):ToRotation()

	if self.isNewOrbit then
		if self.trackedEntityID then
			local performerObj = GameFindEntityByID(self.trackedEntityID)
			if performerObj and performerObj:IsA(n_NPCPuppet) then
				local performerPos = performerObj:GetWorldPosition()
				local playerPos = GetPlayer():GetWorldPosition()
				if math.abs(performerPos.z - playerPos.z) < 2 then
					local distanceSquared2D = vectorDistanceSquared2D(performerPos, playerPos)
					if distanceSquared2D > 0 and distanceSquared2D < 9 then
						if not isTrackerVerified then
							playerEyesPos, playerEyesYaw, isTracker = getPlayerEyesPosAndRot(playerEyesDetectionMode)
							isTrackerVerified = true
						end
						if isTracker then playerPos = playerEyesPos end
						local playerToPerformerRotation = Vector4new(playerPos.x - performerPos.x, playerPos.y - performerPos.y, 0, 0):ToRotation()
						newRotation.yaw = playerToPerformerRotation.yaw + 180
					end
				end
			end
		end
	end

	local rotationSpeed = 100
	newRotation.yaw = newRotation.yaw - self.orbitVel.x * deltaTime * rotationSpeed
	newRotation.pitch = newRotation.pitch - self.orbitVel.y * deltaTime * rotationSpeed

	if newRotation.yaw > 180 then newRotation.yaw = newRotation.yaw - 360
	elseif newRotation.yaw < -180 then newRotation.yaw = newRotation.yaw + 360 end

	if newRotation.pitch > 180 then newRotation.pitch = newRotation.pitch - 360
	elseif newRotation.pitch < -180 then newRotation.pitch = newRotation.pitch + 360 end

	if newRotation.pitch > self.maxPitch then newRotation.pitch = self.maxPitch
	elseif newRotation.pitch < self.minPitch then newRotation.pitch = self.minPitch end

	local newForward = newRotation:GetForward()
	local newPos = Vector4new(centerPos.x + newForward.x * camDist3d, centerPos.y + newForward.y * camDist3d, centerPos.z - newForward.z * camDist3d, 1)

	local limitByRaycast = true
	local playerToCameraYaw, isMaxRangeLimitHit, isRaycastObstacleHit, isVerticalLimitHit
	newPos, playerToCameraYaw, isMaxRangeLimitHit, isRaycastObstacleHit, isVerticalLimitHit = self:rangeLimiter(newPos, limitByRaycast, playerEyesDetectionMode)

	if not self.isNewOrbit then 
		if isRaycastObstacleHit or isVerticalLimitHit then
			local lastChance = self:orbitMove2dFallback(deltaTime, centerPos, rotationSpeed, tooCloseRange2D, camDist3d, newRotation, limitByRaycast, playerEyesDetectionMode)

			if bounceBack then return end
			local isMouseLeftRight = false
			if not lastChance then
				if math.abs(self.orbitVel.x) > 0.00001 then
					if self.nd.drone.orbitMode then
						if self.nd.input.analogLeft > 0 then
							self.nd.input.analogLeftIsBlocked = true
							self.nd.input.left = false
							self.nd.input.analogLeft = 0
						end
						if self.nd.input.analogRight > 0 then
							self.nd.input.analogRightIsBlocked = true
							self.nd.input.right = false
							self.nd.input.analogRight = 0
						end
					end
					if self.nd.input.analogOrbitLeft > 0 then
						self.nd.input.analogOrbitLeftIsBlocked = true
						self.nd.input.orbitLeft = false
						self.nd.input.analogOrbitLeft = 0
						isMouseLeftRight = true
					end
					if self.nd.input.analogOrbitRight > 0 then
						self.nd.input.analogOrbitRightIsBlocked = true
						self.nd.input.orbitRight = false
						self.nd.input.analogOrbitRight = 0
						isMouseLeftRight = true
					end
				end
				if math.abs(self.vel.y) > 0.00001 then
					if self.nd.input.analogForward > 0 then
						self.nd.input.analogForwardIsBlocked = true
						self.nd.input.forward = false
						self.nd.input.analogForward = 0
					end
					if self.nd.input.analogBackwards > 0 then
						self.nd.input.analogBackwardsIsBlocked = true
						self.nd.input.backwards = false
						self.nd.input.analogBackwards = 0
					end
				end
				if math.abs(self.orbitVel.y) > 0.00001 then
					if self.nd.input.analogOrbitForward > 0 then
						self.nd.input.analogOrbitForwardIsBlocked = true
						self.nd.input.orbitForward = false
						self.nd.input.analogOrbitForward = 0
					end
					if self.nd.input.analogOrbitBackwards > 0 then
						self.nd.input.analogOrbitBackwardsIsBlocked = true
						self.nd.input.orbitBackwards = false
						self.nd.input.analogOrbitBackwards = 0
					end
				end

				if isMouseLeftRight then
					self.orbitVel.x = -self.orbitVel.x * 0.05
				else
					self.orbitVel.x = -self.orbitVel.x * 0.75
				end

				if self.orbitPitchWithMouse then
					self.vel.y = -self.vel.y * 0.25
					self.orbitVel.y = -self.orbitVel.y * 0.1
				else
					self.vel.y = -self.vel.y * 0.1
					self.orbitVel.y = -self.orbitVel.y * 0.3
				end

				self:orbitMove(deltaTime, centerPos, true)
			end
			return
		end
	end

	newRotation = Vector4new(newPos.x - centerPos.x, newPos.y - centerPos.y, newPos.z - centerPos.z, 0):ToRotation()
	newRotation.yaw = newRotation.yaw -180

	local hasAnythingChanged = false
	if not self.prevPos then hasAnythingChanged = true
	elseif self.isNewOrbit then hasAnythingChanged = true
	elseif vectorDistanceSquared(newPos, self.prevPos) > 0.0001 then hasAnythingChanged = true
	elseif not self.prevRot then hasAnythingChanged = true
	elseif newRotation.roll ~= self.prevRot.roll then hasAnythingChanged = true
	elseif newRotation.pitch ~= self.prevRot.pitch then hasAnythingChanged = true
	elseif newRotation.yaw ~= self.prevRot.yaw then hasAnythingChanged = true
	end

	if hasAnythingChanged then
		self.isNewOrbit = false
		self.pos = newPos
		self.rot = newRotation
		Game.GetTeleportationFacility():Teleport(self.handle, self.pos, self.rot)
	end
end

function drone:orbitMove2dFallback(deltaTime, centerPos, rotationSpeed, tooCloseRange2D, camDist3d, newRotation, limitByRaycast, playerEyesDetectionMode)
	if not centerPos then return end

	if not camDist3d then
		if not tooCloseRange2D then tooCloseRange2D = 0.75 end

		camDist3d = vectorDistance(centerPos, self.pos) - self.vel.y * deltaTime * 25
		if camDist3d < tooCloseRange2D then camDist3d = tooCloseRange2D end
	end

	if not newRotation then
		local camPos = self.pos
		newRotation = Vector4new(camPos.x - centerPos.x, camPos.y - centerPos.y, camPos.z - centerPos.z, 0):ToRotation()

		if not rotationSpeed then rotationSpeed = 100 end
		newRotation.yaw = newRotation.yaw - self.orbitVel.x * deltaTime * rotationSpeed

		if newRotation.yaw > 180 then newRotation.yaw = newRotation.yaw - 360
		elseif newRotation.yaw < -180 then newRotation.yaw = newRotation.yaw + 360 end
	end

	local currentCameraViewRotation = self.handle:GetRotationFromSlotRotation()
	newRotation.pitch = -currentCameraViewRotation.pitch

	local newForward = newRotation:GetForward()
	local newPos = Vector4new(centerPos.x + newForward.x * camDist3d, centerPos.y + newForward.y * camDist3d, centerPos.z - newForward.z * camDist3d, 1)

	local playerToCameraYaw, isMaxRangeLimitHit, isRaycastObstacleHit, isVerticalLimitHit
	newPos, playerToCameraYaw, isMaxRangeLimitHit, isRaycastObstacleHit, isVerticalLimitHit = self:rangeLimiter(newPos, limitByRaycast, playerEyesDetectionMode)
	if isRaycastObstacleHit then return false end

	newRotation = Vector4new(newPos.x - centerPos.x, newPos.y - centerPos.y, newPos.z - centerPos.z, 0):ToRotation()
	newRotation.yaw = newRotation.yaw -180

	local hasAnythingChanged = false
	if not self.prevPos then hasAnythingChanged = true
	elseif self.isNewOrbit then hasAnythingChanged = true
	elseif vectorDistanceSquared(newPos, self.prevPos) > 0.0001 then hasAnythingChanged = true
	elseif not self.prevRot then hasAnythingChanged = true
	elseif newRotation.roll ~= self.prevRot.roll then hasAnythingChanged = true
	elseif newRotation.pitch ~= self.prevRot.pitch then hasAnythingChanged = true
	elseif newRotation.yaw ~= self.prevRot.yaw then hasAnythingChanged = true
	end
	if hasAnythingChanged then
		self.isNewOrbit = false
		self.pos = newPos
		self.rot = newRotation
		Game.GetTeleportationFacility():Teleport(self.handle, self.pos, self.rot)
	end
	return true
end

local maxHorizontalRange = 12
local maxUpRange, maxDownRange = 3.2, 0.5
local angles = {
				15, -15,
				105, -105,
				135, -135,
				150, -150,
				180,
				90, -90,
				45, -45,
				}
local tooClose = 0.9
			
function drone:rangeLimiter(objectPos, limitByRaycast, playerEyesDetectionMode)
	local isMaxRangeLimitHit, isRaycastObstacleHit, isVerticalLimitHit = false, false, false
	local orgPlayerPos = GetPlayer():GetWorldPosition()

	local playerPos = Vector4new(orgPlayerPos)
	local playerCamPos, playerCamRot, isTracker = getPlayerEyesPosAndRot(playerEyesDetectionMode)

	if playerCamPos then
		playerPos = playerCamPos
		playerPos.z = playerPos.z + self.playerFppOverhead
	else
		playerPos.z = orgPlayerPos.z + self.playerFppCamStandingVOffset + self.playerFppOverhead
	end

	local playerToObjectAngle = Vector4new(objectPos.x - playerPos.x, objectPos.y - playerPos.y, 0, 0):ToRotation().yaw + 90
	local cosA, sinA = mathCos(mathRad(playerToObjectAngle)), mathSin(mathRad(playerToObjectAngle))
	local maxObjectPos = Vector4new(playerPos.x + maxHorizontalRange * cosA, playerPos.y + maxHorizontalRange * sinA, playerPos.z, 1)

	if limitByRaycast then
		local raycastTrace = physicsTraceResult.new()
		local raycastGroupName = n_Static
		local hit, traceResult = spatialQueriesSystem:SyncRaycastByCollisionGroup(playerPos, objectPos, raycastGroupName, raycastTrace)

		if hit then
			isRaycastObstacleHit = true
			local lookedRange = vectorDistance2D(objectPos, playerPos)
			local newLookedPos = traceResult.position
			local found = stringFind(tostring(newLookedPos), 'ToVector3') and (not stringFind(tostring(newLookedPos), 'inf'))
			if found then newLookedPos = Vector4new(newLookedPos.x, newLookedPos.y, newLookedPos.z, 1) end
			if found and vectorDistance2D(playerPos, newLookedPos) > tooClose then
				objectPos = newLookedPos
			else
				local lookedPlayerToObjectAngle = playerToObjectAngle
				local newAngleFound

				for i = 1, #angles do
					lookedPlayerToObjectAngle = normalizeYaw(playerToObjectAngle - angles[i])
					cosA, sinA = mathCos(mathRad(lookedPlayerToObjectAngle)), mathSin(mathRad(lookedPlayerToObjectAngle))
					newLookedPos = Vector4new(playerPos.x + lookedRange * cosA, playerPos.y + lookedRange * sinA, playerPos.z, 1)
					hit, traceResult = spatialQueriesSystem:SyncRaycastByCollisionGroup(playerPos, newLookedPos, raycastGroupName, raycastTrace)
					if not hit then
						newAngleFound = true
					else
						newLookedPos = traceResult.position
						local newLookedPosStr = tostring(newLookedPos)
						local hitPointFound = stringFind(newLookedPosStr, 'ToVector3') and (not stringFind(newLookedPosStr, 'inf'))
						if hitPointFound then
							newLookedPos = Vector4new(newLookedPos.x, newLookedPos.y, newLookedPos.z, 1)
							if vectorDistance2D(playerPos, newLookedPos) > tooClose then newAngleFound = true end
						end
					end
					if newAngleFound then break end
				end

				if newAngleFound then
					objectPos = newLookedPos
					playerToObjectAngle = lookedPlayerToObjectAngle
				else
					objectPos = Vector4new(playerPos.x + 0.75 * cosA, playerPos.y + 0.75 * sinA, objectPos.z, 1)
				end
			end
		end
	end

	local newPlayerToObjectDistance = vectorDistance2D(objectPos, playerPos)
	if newPlayerToObjectDistance > maxHorizontalRange then
		isMaxRangeLimitHit = true
		objectPos.x = maxObjectPos.x
		objectPos.y = maxObjectPos.y
	end
	playerPos.z = orgPlayerPos.z
	local isLimitHit = false
	if objectPos.z > playerPos.z then
		if math.abs(objectPos.z - playerPos.z) > maxUpRange then objectPos.z = playerPos.z + maxUpRange isLimitHit = true end
	else
		if math.abs(objectPos.z - playerPos.z) > maxDownRange then objectPos.z = playerPos.z - maxDownRange isLimitHit = true end
	end

	if isLimitHit then isVerticalLimitHit = true end

	return objectPos, playerToObjectAngle, isMaxRangeLimitHit, isRaycastObstacleHit, isVerticalLimitHit
end

local newViewAdjustmentTime = 0

function drone:update(deltaTime)
	if not(self.queueSpawn or self.spawnRequested or self.despawnRequested or self.fullySpawned) then return end

	if self.fullySpawned and (not self.despawnRequested) then
		if not IsDefinedNS(self.handle) then self:despawn() return end
		if self.orbitMode then
			self:orbitHandleInput(deltaTime)
			self:orbitMove(deltaTime)
			return
		else
			self:handleInput(deltaTime)
			self:move(deltaTime)
		end
		return
	end

	if self.queueSpawn then
		if os.clock() < self.queueSpawn.nextUpdateTime then return end
		self:spawn(self.queueSpawn.newSpawnPos, self.queueSpawn.newSpawnYaw, self.queueSpawn.limitByRaycast)
		return
	end
	if self.spawnRequested then
		if type(self.spawnRequestedTimeout) == 'number' then
			if os.clock() > self.spawnRequestedTimeout then
				self.spawnRequested = false
				self.spawnRequestedTimeout = 0
				self:despawn()
			end
		end

		local newHandle = Ref.Weak(GameFindEntityByID(self.entID))
		if IsDefinedNS(newHandle) and newHandle:IsA(n_SurveillanceCamera) and (isUsingNewSpycam or newHandle:FindComponentByName("int_electronics_002__corpo_security_camera_d__wall_mount_vertical")) then
			self.spawned = true
			self.handle = newHandle

			if not IsDefinedNS(playerTracker.handle) then playerTracker.handle = nil end
			if not playerTracker.handle and playerTracker.entID then playerTracker.handle = Ref.Weak(GameFindEntityByID(playerTracker.entID)) end
			if playerTracker.handle and playerTracker.handle:FindComponentByName(n_hotscenes_spycam_player_tracker) then
				local player = GetPlayer()
				local entity = playerTracker.handle:GetEntity()
				EntityGameInterface.UnbindTransform(entity);
				EntityGameInterface.BindToComponent(entity, player:GetEntity(), n_ItemAttachmentSlots, n_Head, false);
				playerTracker.isAttached = true
			end

			if self.forceTakeOver then
				self.forceTakeOver = false
				startCooldown(n_mod_hotscenes_spycam_take_control_cooldown, 0.5, true)
				self.handle:OnToggleTakeOverControl(ToggleTakeOverControl.new())
			elseif isPlayerControllingDevice() then
				self:toggleCameraPitchYawControl(false)
				self.fullySpawned = true
				self.spawnRequested = false
				local player = GetPlayer()
				GameObjectEffectHelper.StopEffectEvent(player, n_camera_mask)

				if self.traceTarget then
					if self.traceTargetIsObject then
						local trackedObject = nil
						local isTrackedObjectValid = false
						if self.trackedEntityID then
							trackedObject = GameFindEntityByID(self.trackedEntityID)
							if IsDefinedNS(trackedObject) and trackedObject:IsA(n_NPCPuppet) then
								local performerPos = trackedObject:GetWorldPosition()
								local playerPos = player:GetWorldPosition()
								if math.abs(performerPos.z - playerPos.z) < 2 then
									local distanceSquared2D = vectorDistanceSquared2D(performerPos, playerPos)
									if distanceSquared2D > 0 and distanceSquared2D < 9 then isTrackedObjectValid = true end
								end
							end
						end

						if not isTrackedObjectValid then trackedObject = player end
						self:setControlledCameraTargetToObject(trackedObject, self.npcChestVoffset - self.playerFppOverhead, true)
					else
						if self.trackedPosition then
							self:setControlledCameraTargetToPos(self.trackedPosition, 0, true)
						end
					end
				end
			end
		end
		return
	end
	if self.despawnRequested then
		if (not IsDefinedNS(self.handle)) or not (GameFindEntityByID(self.entID)) then
			self.entID = nil
			self.handle = nil
			self.spawned = false
			self.spawnRequested = false
			self.fullySpawned = false
			self.despawnRequested = false
			self.despawnRequestedTimeout = 0
			self.despawnWaitTicks = 0
		else
			if IsDefinedNS(self.handle) then
				if not self.despawnWaitTicks then self.despawnWaitTicks = 0 end
				if self.despawnWaitTicks > 10 then self.despawnWaitTicks = 0 end
				self.despawnWaitTicks = self.despawnWaitTicks + 1
				if self.despawnWaitTicks >= minDespawnTicks then
					self.entID = nil
					self.spawned = false
					self.spawnRequested = false
					self.fullySpawned = false
					self.despawnRequested = false
					self.despawnRequestedTimeout = 0
					self.despawnWaitTicks = 0
					startCooldown(n_mod_hotscenes_spycam_despawn_cooldown, 0.75, true)
					if reuseCamera then
						Game.GetTeleportationFacility():Teleport(self.handle, Vector4new(), EulerAnglesnew())
					else
						if Codeware then
							Game.GetDynamicEntitySystem():DeleteEntity(self.handle:GetEntityID())
						else
							exEntitySpawner.Despawn(self.handle)
						end
					end
					self.lastDespawnTime = os.clock()
				end
			end
		end
		return
	end
end

function drone:hideQuestTracker(this)
	if not self.fullySpawned then return end
	if self.despawnRequested then return end
	if not IsDefinedNS(this) then return end
	if not IsDefinedNS(self.handle) then return end
	if not this.questTrackerContainer then return end
	inkWidgetRef.SetVisible(this.questTrackerContainer, false)
end

function normalizeYaw(yaw)
	if yaw > 180 then return yaw - 360 end
	if yaw < -180 then return yaw + 360 end
	return yaw
end

function startCooldown(cooldownName, cooldownDuration, ignoreTimeDilation)
	if isCooldownTimeDilationIgnoreSupported then GetPlayer():StartCooldown(cooldownName, cooldownDuration, ignoreTimeDilation) return end
	GetPlayer():StartCooldown(cooldownName, cooldownDuration)
end

function isPlayerControllingDevice(player)
	player = player or GetPlayer()
	if not player then return false end
	local allBlackboardDefsPlayerStateMachine = Game.GetAllBlackboardDefs().PlayerStateMachine
	return gameBlackboardSystem:GetLocalInstanced(player:GetEntityID(), allBlackboardDefsPlayerStateMachine):GetBool(allBlackboardDefsPlayerStateMachine.IsControllingDevice)
end

function spawnEntity(pathOrID, spawnTransform, appName, tags)
	local id = spawnWithCodeware(pathOrID, spawnTransform, appName, tags)
	if id then return id end
	return exEntitySpawner.Spawn(pathOrID, spawnTransform, appName)
end

local function isStringValid(input)
	if type(input) ~= 'string' then return end
	return string.len(input) > 0
end

function spawnWithCodeware(pathOrID, spawnTransform, appName, tags);
	if not Codeware then return end;
	local entitySystem = Game.GetDynamicEntitySystem();
	if not entitySystem then return end;
	if type(pathOrID) ~= 'string' then return end;
	if not IsStringValid(pathOrID) then return end;
	local isRecord, isValid = false, false;
	if TweakDB:GetRecord(pathOrID) then isRecord = true isValid = true end;
	if (not isRecord) and string.match(pathOrID, '%.ent$') then isValid = true end;
	if not isValid then return end;
	local entSpec = DynamicEntitySpec.new();
	if isRecord then entSpec.recordID = pathOrID else entSpec.templatePath = pathOrID end;
	if type(appName) == 'string' then entSpec.appearanceName = appName end;
	if spawnTransform then;
		entSpec.position = spawnTransform:GetWorldPosition():ToVector4();
		entSpec.orientation = spawnTransform:GetOrientation();
	end;
	entSpec.alwaysSpawned = true;
	entSpec.spawnInView = true;
	entSpec.active = true;
	if type(tags) == 'table' then entSpec.tags = tags end;
	return entitySystem:CreateEntity(entSpec);
end;

function IsDefinedNS(gameObj)
	if not gameObj then return false end
	local result, val = pcall(function() return IsDefined(gameObj) end)
	if result then return val else return false end
end

function isKnownName(inputString)
	return CName.new(inputString).value == inputString
end

return drone