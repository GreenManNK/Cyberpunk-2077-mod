-- Based on (c)keanuWheeze Nano Drone mod code thanks to keanuWheeze consent to use and adapt the code for the Hotscenes Spycam.
-- May 22, 2026 by anygoodname

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


local modVer = '3.8.4'

nd = {
	runtimeData = {
		cetOpen = false,
		inMenu = false,
		inGame = false,
		inWorkSpot = false,
		isDisabled = false
	},

	input = require("modules/input"),
}

local runtimeData = nd.runtimeData

function nd.disable()
	runtimeData.isDisabled = true
	nd.input.isDisabled = true
end

function nd.update(deltaTime)
	if runtimeData.isDisabled then return end
	if runtimeData.inMenu or (not runtimeData.inGame) then return end
	local drone = nd.drone
	if not drone.batteryPercent then drone:init() end
	drone:update(deltaTime)
end

function nd.init(isInSession)
	if runtimeData.isDisabled then return end

	local drone = GetMod("hotscenes_drone")
	if type(drone) == 'table' and type(drone.init) == 'function' and type(drone.new) == 'function' then
		print('using external drone module')
		nd.drone = drone:new(nd)
	else
		nd.drone = require("modules/drone"):new(nd)
	end

	nd.input.startInputObserver(nd)
	ObserveAfter('QuestTrackerGameController', 'UpdateTrackerData', function(this);
		nd.drone:hideQuestTracker(this)
	end)

	Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu)
		if runtimeData.isDisabled then return end
		runtimeData.inMenu = isInMenu
	end)

	Observe('PlayerPuppet', 'OnGameAttached', function(self)
		if runtimeData.isDisabled then return end
		if not self:IsReplacer() then
			runtimeData.inGame = true
			nd.drone:init()
		end
	end)

	Observe('PlayerPuppet', 'OnDetach', function(self)
		if runtimeData.isDisabled then return end
		if not self:IsReplacer() then
			runtimeData.inGame = false
			nd.drone:despawn(true)
		end
	end)

	if isInSession then runtimeData.inGame = true
	else
		runtimeData.inGame = true
		local streetCred = false
		pcall(function() streetCred = Game.GetStatsSystem():GetStatValue(GetPlayer():GetEntityID(), 'StreetCred') end) --(c)psiberx)
		if type(streetCred) ~= 'number' then runtimeData.inGame = false elseif streetCred < 1 then runtimeData.inGame = false end
	end

	local ver = nd.drone.moduleVer or modVer
	print('Hotscenes Spycam', ver, 'initialized. Powered by Nano Drone by (c)keanuWheeze')
end

function nd.spawnDroneKeyHandler(down, newSpawnPos, newSpawnYaw, limitByRaycast)
	if runtimeData.isDisabled then return end
	if down then
		if (not nd.drone.spawned) and (not nd.drone.spawnRequested) and (not nd.drone.despawnRequested) then
			nd.drone:spawn(newSpawnPos, newSpawnYaw, limitByRaycast)
		else
			if nd.drone.fullySpawned then nd.drone:despawn() end
		end
	end
end

local horizontalRotationSensitivity, verticalRotationSensitivity = 8, 5

function nd.forwardKeyHandler(down)
	if runtimeData.isDisabled then return end
	if not nd.drone.orbitMode or (nd.drone.orbitMode and nd.drone.orbitPitchWithMouse) then
		nd.input.forward = down
		if down then nd.input.analogForward = 1 else nd.input.analogForward = 0 end
	elseif nd.drone.orbitMode and (not nd.drone.orbitPitchWithMouse) then
		nd.input.orbitForward = down
		if down then nd.input.analogOrbitForward = verticalRotationSensitivity else nd.input.analogOrbitForward = 0 end
		return
	end
end

function nd.backwardKeyHandler(down)
	if runtimeData.isDisabled then return end
	if not nd.drone.orbitMode or (nd.drone.orbitMode and nd.drone.orbitPitchWithMouse) then
		nd.input.backwards = down
		if down then nd.input.analogBackwards = 1 else nd.input.analogBackwards = 0 end
	elseif nd.drone.orbitMode and (not nd.drone.orbitPitchWithMouse) then
		nd.input.orbitBackwards = down
		if down then nd.input.analogOrbitBackwards = verticalRotationSensitivity else nd.input.analogOrbitBackwards = 0 end
		return
	end
end

function nd.leftKeyHandler(down)
	if runtimeData.isDisabled then return end
	if nd.drone.orbitMode then
		nd.input.left = down
		if down then nd.input.analogLeft = horizontalRotationSensitivity else nd.input.analogLeft = 0 end
		do return end
	end
	nd.input.left = down
	if down then nd.input.analogLeft = 1 else nd.input.analogLeft = 0 end
end

function nd.rightKeyHandler(down)
	if runtimeData.isDisabled then return end
	if nd.drone.orbitMode then
		nd.input.right = down
		if down then nd.input.analogRight = horizontalRotationSensitivity else nd.input.analogRight = 0 end
		do return end
	end
	nd.input.right = down
	if down then nd.input.analogRight = 1 else nd.input.analogRight = 0 end
end

return nd