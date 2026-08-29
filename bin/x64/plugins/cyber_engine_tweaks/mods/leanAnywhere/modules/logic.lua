local interaction = require("modules/interactionUI")
local world = require("modules/worldInteraction")
local utils = require("modules/utils")
local GameUI = require("modules/external/GameUI")
local logger = require("modules/logger")

local logic = {}

function logic:new(mod)
	local o = {}

    o.isScanning = false
    o.interface = nil
    o.mod = mod

    o.pin = nil

    o.leanWorkspot = nil

	self.__index = self
   	return setmetatable(o, self)
end

function logic:init()
    GameUI.Observe("ScannerOpen", function()
        self.isScanning = true
    end)

    GameUI.Observe("ScannerClose", function()
        self.isScanning = false
    end)

    Observe("LocomotionEventsTransition", "OnUpdate", function(_, _, _, interface)
        self.interface = interface
    end)
end

function logic:isValidEnviroment() -- Base requirements for scanning
    local zone = FromVariant(GetPlayer():GetPlayerStateMachineBlackboard():GetVariant(GetAllBlackboardDefs().PlayerStateMachine.SecurityZoneData))
    if zone and (zone.securityAreaType == ESecurityAreaType.RESTRICTED or zone.securityAreaType == ESecurityAreaType.DANGEROUS) then return false end

    if GetPlayer():IsInCombat() then return false end

    if Game.GetWorkspotSystem():IsActorInWorkspot(GetPlayer()) then return false end

    if Game.GetQuestsSystem():GetFact("wanted_level") > 0 then return false end

    local target = Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), true, false)
    if target and target:GetClassName().value == "NPCPuppet" then return false end

    if GetMountedVehicle(GetPlayer()) then return false end

    if GetPlayer():GetPlayerStateMachineBlackboard():GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying) then return false end

    if GetPlayer():GetPlayerStateMachineBlackboard():GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) > 2 then return false end

    if GetPlayer():GetHudManager():IsBraindanceActive() then return false end

    return true
end

function logic:getTargetLocation() -- Get sitable surface pos + rot
    local groupHit = self:getHit("group")
    local presetHit = self:getHit("preset")

    local hit = groupHit or presetHit
    local castType = "group"
    if (groupHit == nil) and presetHit then castType = "preset" end
    if not hit then return end -- No valid hit

    logger.log("Hit castType", castType)

    local normal = Vector4.Vector3To4(hit.normal)

    local pitch = math.abs(normal:ToRotation().pitch)
    if pitch > 5 then
        local origin = utils.subVector(Vector4.Vector3To4(hit.position), utils.multVector(GetPlayer():GetWorldForward():Normalize(), 0.4))
        origin.z = origin.z - 0.1
        normal = self:getForwardNormals(origin, castType, 7.5)

        if not normal then
            local origin = utils.subVector(Vector4.Vector3To4(hit.position), utils.multVector(GetPlayer():GetWorldForward():Normalize(), 0.4))
            origin.z = origin.z - 0.03
            normal = self:getForwardNormals(origin, castType, 30)
        end

        logger.log("Flat surface, normal", normal)
    end

    if not normal then return end

    logger.log("Lean yaw", normal:ToRotation().yaw)
    logger.log("Player yaw", GetPlayer():GetWorldForward():ToRotation().yaw + 180)

    local isThicc
    hit, isThicc = self:validateDepthAndHeight(Vector4.Vector3To4(hit.position), normal, castType)

    if not hit then return end

    return hit, normal, isThicc
end

function logic:getHit(castType) -- Get basic hit position
    local forwardOffset = 0.5
    if castType == "preset" then forwardOffset = 1.6 end -- Avoid collision with player
    local playerHead = utils.addVector(GetPlayer():GetWorldPosition(), Vector4.new(0, 0, 1.6, 0))
    local from = utils.addVector(playerHead, utils.multVector(Game.GetCameraSystem():GetActiveCameraForward(), forwardOffset))
    local to = utils.addVector(playerHead, utils.multVector(Game.GetCameraSystem():GetActiveCameraForward(), 100))

    local result = self:raycast(from, to, castType)

    logger.log("Cast castType", castType)
    logger.log("Cast succes", result:IsValid())
    logger.log("Cast distance", Vector4.Vector3To4(result.position):Distance(GetPlayer():GetWorldPosition()))
    logger.log("Cast yDist", Vector4.Vector3To4(result.position).z - GetPlayer():GetWorldPosition().z)
    logger.log("Cast normal pitch", math.abs(Vector4.Vector3To4(result.normal):ToRotation().pitch))

    if not result:IsValid() then return end -- No hit

    if Vector4.Vector3To4(result.position):Distance(GetPlayer():GetWorldPosition()) > 2.5 then return end -- Valid Hit distance

    local yDist = Vector4.Vector3To4(result.position).z - GetPlayer():GetWorldPosition().z -- Valid Z Distance
    if yDist < 0.89 or yDist > 1.3 then return end

    local pitch = math.abs(Vector4.Vector3To4(result.normal):ToRotation().pitch)
    if (pitch < 85 and pitch > 7.5) then return end

    local target = Game.GetTargetingSystem():GetObjectClosestToCrosshair(GetPlayer(), TSQ_NPC()) -- NPC too close
    if target and target:GetWorldPosition():Distance(Vector4.Vector3To4(result.position)) < 0.75 then return end

    return result
end

function logic:raycast(from, to, castType) -- Single raycast
    self.casts = self.casts + 1
    if castType == "group" then
        return self.interface:RaycastWithASingleGroup(from, to, "PlayerBlocker") -- Does not detect low metal benches
    else
        return self.interface:Raycast(from, to, "Bullet logic") -- Collides with player hitbox when low pitch
    end
end

function logic:getForwardNormals(origin, castType, maxPitch) -- Get normals using multiple angled raycasts
    local angleDiff = 25
    local angleSteps = 1
    local maxDistance = 0.65
    local results = {}

    for i = -angleSteps, angleSteps do
        local angle = angleDiff * i
        local direction = GetPlayer():GetWorldForward():RotByAngleXY(angle)

        local result = self:raycast(origin, utils.addVector(origin, utils.multVector(direction, 50)), castType)

        if result:IsValid() and Vector4.Vector3To4(result.position):Distance(origin) < maxDistance and Vector4.Vector3To4(result.position):Distance(origin) > 0 then
            if math.abs(Vector4.Vector3To4(result.normal):ToRotation().pitch) < maxPitch then
                results[i] = Vector4.Vector3To4(result.normal)
            end
        end
    end

    if results[0] then -- Prefer center raycast
        return results[0]
    else
        for _, result in pairs(results) do
            if result then
                return result
            end
        end
    end
end

function logic:validateDepthAndHeight(origin, normal, castType) -- Get depth and center point
    local searchDepth = 0.4

    normal.z = 0
    local forwardEdge = self:getEdge(origin, normal, searchDepth, castType)
    local backwardsEdge = self:getEdge(origin, normal:RotByAngleXY(180), searchDepth, castType)

    forwardEdge = forwardEdge * searchDepth
    backwardsEdge = backwardsEdge * searchDepth

    if backwardsEdge == 0 or forwardEdge == 0 then return nil end

    logger.log("forwardOffset", forwardEdge)
    logger.log("backwardsEdge", backwardsEdge)
    logger.log("depth", forwardEdge + backwardsEdge)

    -- Too deep
    if forwardEdge + backwardsEdge > 0.42 then return nil end

    -- Center point relative to depth
    local isThicc = false
    local shiftAmount = forwardEdge - ((forwardEdge + backwardsEdge) / 2)
    if forwardEdge + backwardsEdge / 2 > 0.1 then
        shiftAmount = 0.08 - backwardsEdge
        isThicc = true
    end
    local adjustedOrigin = utils.addVector(origin, utils.multVector(normal:Normalize(), shiftAmount))

    logger.log("shiftAmount", shiftAmount)
    logger.log("isThicc", isThicc)

    -- Figure out height
    local zHit = self:raycast(utils.addVector(adjustedOrigin, Vector4.new(0, 0, 0.5, 0)), utils.addVector(adjustedOrigin, Vector4.new(0, 0, -0.5, 0)), castType)
    if not zHit:IsValid() then return nil end
    local yDist =zHit.position.z - GetPlayer():GetWorldPosition().z -- Valid Z Distance
    if yDist < 0.8 or yDist > 1.3 then return nil end
    adjustedOrigin.z = zHit.position.z

    return adjustedOrigin, isThicc
end

function logic:getEdge(origin, direction, length, castType) -- Sweep for edge
    local maxSteps = 7
    local minZDelta = 0.4

    local offset = 1
    local lastHit = 0

    for i = 1, maxSteps do
        local from = utils.addVector(utils.addVector(origin, utils.multVector(direction:Normalize(), offset * length)), Vector4.new(0, 0, 1, 0))
        local to = utils.addVector(from, Vector4.new(0, 0, -100, 0))
        local result = self:raycast(from, to, castType)

        if not result:IsValid() then return 0 end

        local zDelta = math.abs(origin.z - result.position.z)

        if zDelta > minZDelta then
            lastHit = offset
            offset = offset - 1 / (2^i)
        else
            if offset > lastHit then
                offset = offset - 1 / (2^i)
            else
                offset = offset + 1 / (2^i)
            end
        end
    end

    return lastHit
end

function logic:hideAllWorkspots()
    world.interactions[1].pos = Vector4.new(0, 0, 0, 0)
    self.leanWorkspot.workspot.interactionPosition = Vector4.new(0, 0, 0, 0)

    if world.interactions[1].pinID then
        Game.GetMappinSystem():SetMappinPosition(world.interactions[1].pinID, Vector4.new(0, 0, 0, 0))
    end
end

function logic:protectSpot() -- Dispose close NPCs
    if not self.leanWorkspot.workspot.inWorkspot then return end

    local target = Game.GetTargetingSystem():GetObjectClosestToCrosshair(GetPlayer(), TSQ_NPC())
    if target and (not target:IsPlayer()) and Game.GetWorkspotSystem():IsActorInWorkspot(target) and target:GetWorldPosition():Distance(GetPlayer():GetWorldPosition()) < 0.55 then
        target:Dispose()
    end
end

function logic:onUpdate()
    logger.log("Status", self.isScanning, self:isValidEnviroment(), self.interface)

    self:protectSpot()

    if (not self.isScanning and not self.mod.runtimeData.forceScan) or (not self:isValidEnviroment()) or (not self.interface) or self.leanWorkspot.workspot.inWorkspot then
        if self.pin then
            Game.GetMappinSystem():UnregisterMappin(self.pin)
        end
        self.pin = nil
        self:hideAllWorkspots()

        if (self.isScanning or self.mod.runtimeData.forceScan) and self.leanWorkspot.workspot.inWorkspot and self.mod.settings.hideExitPopup then
            self.leanWorkspot.workspot:setupExit(true)
        elseif (not self.isScanning and not self.mod.runtimeData.forceScan) and self.leanWorkspot.workspot.inWorkspot and self.mod.settings.hideExitPopup then
            interaction.hideHub()
        end

        return
    end

    self.casts = 0

    local position, forward, isThicc = self:getTargetLocation()
    if position then
        local workspotZAdjustment = -1.1
        local workspotForwardAdjustment = 0.65 --0.54
        if isThicc then
            workspotForwardAdjustment = 0.625
        end

        local workspotPosition = utils.addVector(Vector4.new(position.x, position.y, position.z + workspotZAdjustment, 0), utils.multVector(forward:Normalize(), workspotForwardAdjustment))

        world.interactions[1].pos = position
        self.leanWorkspot.workspot.interactionPosition = position
        self.leanWorkspot.workspot.workspotPosition = workspotPosition
        self.leanWorkspot.workspot.workspotRotation.yaw = forward:ToRotation().yaw

        if world.interactions[1].pinID then
            Game.GetMappinSystem():SetMappinPosition(world.interactions[1].pinID, position)
        end
    else
        self:hideAllWorkspots()
    end

    logger.log("Casts", self.casts)
end

return logic