-- Based on (c)keanuWheeze Nano Drone mod code thanks to keanuWheeze consent to use and adapt the code for the Hotscenes Spycam.
-- Mar 14, 2026 by anygoodname
-- file ver 3.1.2

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

input = {
	q = false,
	noSave = false,
	interact = false,
	forward = false,
	backwards = false,
	right = false,
	left = false,
	up = false,
	down = false,
	analogForward = 0,
	analogBackwards = 0,
	analogRight = 0,
	analogLeft = 0,
	analogUp = 0,
	analogDown = 0,
	
	orbitForward = false,
	orbitBackwards = false,
	orbitRight = false,
	orbitLeft = false,
	orbitUp = false,
	orbitDown = false,
    analogOrbitForward = 0,
    analogOrbitBackwards = 0,
    analogOrbitRight = 0,
    analogOrbitLeft = 0,
    analogOrbitUp = 0,
    analogOrbitDown = 0,
	orbitMouseSensitivity = 0.055,
	forwardMouseSensitivity = 0.025,

	invertMouseVertically = false,
	isDisabled = false
}

function resetInputs(orbitModeOnly, onOrbitModeEntry)
	if not onOrbitModeEntry then
		nd.drone.orbitMode = false
		nd.drone.orbitCenterPos = false
		nd.drone.isNewOrbit = false
	end
	nd.drone.orbitVel.x = 0
	nd.drone.orbitVel.y = 0
	input.orbitForward = false
	input.orbitBackwards = false
	input.orbitRight = false
	input.orbitLeft = false
	input.orbitUp = false
	input.orbitDown = false
    input.analogOrbitForward = 0
    input.analogOrbitBackwards = 0
    input.analogOrbitRight = 0
    input.analogOrbitLeft = 0
    input.analogOrbitUp = 0
    input.analogOrbitDown = 0

	nd.drone.vel.x = 0
	input.interact = false
	input.right = false
	input.left = false
	input.up = false
	input.down = false
	input.analogRight = 0
	input.analogLeft = 0
	input.analogUp = 0
	input.analogDown = 0
	
	if orbitModeOnly then return end

	nd.drone.vel.y = 0
	input.forward = false
	input.backwards = false
	input.analogForward = 0
	input.analogBackwards = 0
end

local mathAbs = math.abs
function input.startInputObserver(nd)
	local timeSystem = Game.GetTimeSystem()
	local audioSystem = Game.GetAudioSystem()
	local n = CName
	local n_mod_hotscenes_spycam_freeze_frame = n"mod_hotscenes_spycam_freeze_frame"
	local n_CameraMouseX = n"CameraMouseX"
	local n_CameraMouseY = n"CameraMouseY"
	local n_MoveX = n"MoveX"
	local n_MoveY = n"MoveY"

	local function handleSpycamAxisControlAction(action, actionName)
		if not nd.drone.fullySpawned then return end
		actionName = actionName or action:GetName(action)

		if actionName == n_CameraMouseX then
			local x = action:GetValue(action)
			if mathAbs(x) == 0 then
				input.orbitRight = false
				input.orbitLeft = false
				input.analogOrbitRight = 0
				input.analogOrbitLeft = 0
			elseif x < 0 then
				input.orbitLeft = true
				input.orbitRight = false
				input.analogOrbitRight = 0
				input.analogOrbitLeft = -x * input.orbitMouseSensitivity
			else
				input.orbitRight = true
				input.orbitLeft = false
				input.analogOrbitRight = x * input.orbitMouseSensitivity
				input.analogOrbitLeft = 0
			end
			return true
		end
		if actionName == n_CameraMouseY then
			local x = action:GetValue(action)
			if input.invertMouseVertically then
				if nd.drone.orbitMode then
					if nd.drone.orbitPitchWithMouse then x = -x end
				else
					x = -x
				end
			end
			if (not nd.drone.orbitMode) or (nd.drone.orbitMode and nd.drone.orbitPitchWithMouse) then
				if mathAbs(x) == 0 then
					input.orbitBackwards = false
					input.orbitForward = false
					input.analogOrbitForward = 0
					input.analogOrbitBackwards = 0
				elseif x < 0 then
					input.orbitBackwards = true
					input.orbitForward = false
					input.analogOrbitForward = 0
					input.analogOrbitBackwards = -x * input.orbitMouseSensitivity
				else
					input.orbitBackwards = false
					input.orbitForward = true
					input.analogOrbitForward = x * input.orbitMouseSensitivity
					input.analogOrbitBackwards = 0
				end
			elseif nd.drone.orbitMode and (not nd.drone.orbitPitchWithMouse) then
				if mathAbs(x) == 0 then
					input.backwards = false
					input.forward = false
					input.analogForward = 0
					input.analogBackwards = 0
				elseif x < 0 then
					input.backwards = true
					input.forward = false
					input.analogForward = 0
					input.analogBackwards = -x * input.forwardMouseSensitivity
				else
					input.backwards = false
					input.forward = true
					input.analogForward = x * input.forwardMouseSensitivity
					input.analogBackwards = 0
				end
			end
			return true
		end
		if nd.drone.orbitMode then return end

		if actionName == n_MoveX then
			local x = action:GetValue(action)
			if mathAbs(x) == 0 then
				input.right = false
				input.left = false
				input.analogRight = 0
				input.analogLeft = 0
			elseif x < 0 then
				input.left = true
				input.right = false
				input.analogRight = 0
				input.analogLeft = -x
			else
				input.right = true
				input.left = false
				input.analogRight = x
				input.analogLeft = 0
			end
			return true
		end
		if actionName == n_MoveY then
			local x = action:GetValue(action)
			if mathAbs(x) == 0 then
				input.backwards = false
				input.forward = false
				input.analogForward = 0
				input.analogBackwards = 0
			elseif x < 0 then
				input.backwards = true
				input.forward = false
				input.analogForward = 0
				input.analogBackwards = -x
			else
				input.backwards = false
				input.forward = true
				input.analogForward = x
				input.analogBackwards = 0
			end
			return true
		end
	end

	local n_RangedADS = n"RangedADS"
	local n_CameraAim = n"CameraAim"
	local n_DeviceAttack = n"DeviceAttack"
	local n_TagButton = n"TagButton"
	local n_StopDeviceControl = n"StopDeviceControl"
	local n_OpenPauseMenu = n"OpenPauseMenu"

	local gameinputActionTypeBUTTON_PRESSED = gameinputActionType.BUTTON_PRESSED
	local gameinputActionTypeBUTTON_RELEASED = gameinputActionType.BUTTON_RELEASED
	Observe('PlayerPuppet', 'OnAction', function(_, action)
		if input.isDisabled then return end
		if not nd.drone.spawned then return end

		local actionName = action:GetName(action)
		if not action:IsButton(action) then handleSpycamAxisControlAction(action, actionName) return end

		local actionType = action:GetType(action)
		if actionName == n_RangedADS or actionName == n_CameraAim then
			if actionType == gameinputActionTypeBUTTON_PRESSED then
				nd.drone.orbitMode = true
				nd.drone.isNewOrbit = true
				if not nd.drone.orbitPitchWithMouse then resetInputs(false, true) end
			elseif actionType == gameinputActionTypeBUTTON_RELEASED then
				if nd.drone.orbitPitchWithMouse then
					resetInputs(true)
				else
					resetInputs()
				end
			end
			return
		end
		if actionName == n_DeviceAttack then
			if not nd.drone.fullySpawned then return end
			if nd.drone.enableSpycamFreezeFrameToggleMode then
				if actionType ~= gameinputActionTypeBUTTON_PRESSED then return end
				if not timeSystem:IsTimeDilationActive(n_mod_hotscenes_spycam_freeze_frame) then
					timeSystem:SetTimeDilation(n_mod_hotscenes_spycam_freeze_frame, 0.00001, 60)
				else
					timeSystem:UnsetTimeDilation(n_mod_hotscenes_spycam_freeze_frame)
				end
				return
			else
				if actionType == gameinputActionTypeBUTTON_PRESSED then
					if not timeSystem:IsTimeDilationActive(n_mod_hotscenes_spycam_freeze_frame) then
						timeSystem:SetTimeDilation(n_mod_hotscenes_spycam_freeze_frame, 0.00001)
					end
				elseif actionType == gameinputActionTypeBUTTON_RELEASED then
					if timeSystem:IsTimeDilationActive(n_mod_hotscenes_spycam_freeze_frame) then
						timeSystem:UnsetTimeDilation(n_mod_hotscenes_spycam_freeze_frame)
					end
				end
				return
			end
			return
		end

		if actionType ~= gameinputActionTypeBUTTON_RELEASED then return end

		if actionName == n_TagButton then
			if not nd.drone.fullySpawned then return end
			if input.slowMoParams then
				local isSlowMo = timeSystem:IsTimeDilationActive(input.slowMoParams.cNameSlowMoUserReason) or timeSystem:IsTimeDilationActive(input.slowMoParams.cNameSlowMoSpycamReason)
				if isSlowMo then
					timeSystem:UnsetTimeDilation(input.slowMoParams.cNameSlowMoUserReason, input.slowMoParams.cNameSlowMoEaseOutCurve)
					timeSystem:UnsetTimeDilation(input.slowMoParams.cNameSlowMoSpycamReason, input.slowMoParams.cNameSlowMoEaseOutCurve)
				else
					timeSystem:SetTimeDilation(input.slowMoParams.cNameSlowMoUserReason, input.slowMoParams.slowMoSpeedFactor, input.slowMoParams.slowMoDuration, input.slowMoParams.cNameSlowMoEaseInCurve, input.slowMoParams.cNameSlowMoEaseOutCurve)
				end
				audioSystem:PlayLootAllSound()
			end
			return
		end

		if not(actionName == n_StopDeviceControl or actionName == n_OpenPauseMenu) then return end
		nd.drone:despawn()
		resetInputs()
    end)
end

function input.startListeners(player)
end

return input