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

    o.sittables = {}

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

    local target = Game.GetTargetingSystem():GetLookAtObject(GetPlayer(), true, false)
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
    local benchType = 0
    if (groupHit == nil) and presetHit then castType = "preset" end
    if not hit then return end -- No valid hit

    logger.log("Hit castType", castType)

    local normal = self:getForwardNormals(utils.addVector(Vector4.Vector3To4(hit.position), Vector4.new(0, 0, 0.1, 0)), castType) -- Backrest normals

    if not normal then -- No backrest
        local origin = utils.subVector(Vector4.Vector3To4(hit.position), utils.multVector(GetPlayer():GetWorldForward():Normalize(), 0.5))
        origin.z = origin.z - 0.05

        normal = self:getForwardNormals(origin, castType) -- Front of bench normals
        if not normal then
            origin.z = origin.z - 0.25 -- Lower for some bench types with angled fronts
            normal = self:getForwardNormals(origin, castType)
        end
        benchType = 1
    end

    if not normal then return end

    logger.log("Lean yaw", normal:ToRotation().yaw)
    logger.log("Player yaw", GetPlayer():GetWorldForward():ToRotation().yaw + 180)

    hit = self:adjustForDepth(Vector4.Vector3To4(hit.position), normal, castType)

    if not hit then return end

    hit = self:adjustForWidth(hit, normal, castType)

    return hit, normal, benchType
end

function logic:getHit(castType) -- Get basic hit position
    local forwardOffset = 1
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
    if yDist < 0.3 or yDist > 0.8 then return end

    if math.abs(Vector4.Vector3To4(result.normal):ToRotation().pitch) < 80 or math.abs(Vector4.Vector3To4(result.normal):ToRotation().pitch) > 95 then -- Try custom normals, given ones are sometimes faulty
        local spread = 0.1
        local pos = result.position
        local p1 = self:raycast(Vector4.new(pos.x + spread, pos.y, pos.z + 0.75, 0), Vector4.new(pos.x + spread, pos.y, pos.z - 0.75, 0), castType)
        local p2 = self:raycast(Vector4.new(pos.x - spread, pos.y - spread, pos.z + 0.75, 0), Vector4.new(pos.x - spread, pos.y - spread, pos.z - 0.75, 0), castType)
        local p3 = self:raycast(Vector4.new(pos.x, pos.y + spread, pos.z + 0.75, 0), Vector4.new(pos.x, pos.y + spread, pos.z - 0.75, 0), castType)

        if not p1:IsValid() or not p2:IsValid() or not p3:IsValid() then return end

        local normal = utils.subVector(Vector4.Vector3To4(p2.position), Vector4.Vector3To4(p1.position)):Cross(utils.subVector(Vector4.Vector3To4(p3.position), Vector4.Vector3To4(p1.position)))
        logger.log("Custom normal pitch", math.abs(normal:ToRotation().pitch))
        logger.log("Custom normal z1", p1.position.z)
        logger.log("Custom normal z2", p2.position.z)
        logger.log("Custom normal z3", p3.position.z)

        result.normal = normal:Vector4To3()
        if math.abs(Vector4.Vector3To4(result.normal):ToRotation().pitch) < 80 or math.abs(Vector4.Vector3To4(result.normal):ToRotation().pitch) > 95 then return end
    end

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

function logic:getForwardNormals(origin, castType) -- Get normals using multiple angled raycasts
    local angleDiff = 25
    local angleSteps = 1
    local maxDistance = 0.65
    local results = {}

    for i = -angleSteps, angleSteps do
        local angle = angleDiff * i
        local direction = GetPlayer():GetWorldForward():RotByAngleXY(angle)

        local result = self:raycast(origin, utils.addVector(origin, utils.multVector(direction, 50)), castType)

        if result:IsValid() and Vector4.Vector3To4(result.position):Distance(origin) < maxDistance and Vector4.Vector3To4(result.position):Distance(origin) > 0 then
            if Vector4.Vector3To4(result.normal):ToRotation().pitch > -30 and Vector4.Vector3To4(result.normal):ToRotation().pitch < 2 then
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

function logic:adjustForWidth(origin, normal, castType) -- Get width and limit point
    local searchWidth = 0.3
    local snapAmount = 0.2

    normal.z = 0
    local rightEdge = self:getEdge(origin, normal:RotByAngleXY(-90), searchWidth, castType) * searchWidth
    local leftEdge = self:getEdge(origin, normal:RotByAngleXY(90), searchWidth, castType) * searchWidth

    local adjustedOrigin = origin
    if rightEdge == 0 and leftEdge == 0 then return origin end
    if rightEdge == 0 and leftEdge < snapAmount then
        local shiftAmount = snapAmount - leftEdge
        adjustedOrigin = utils.addVector(origin, utils.multVector(normal:Normalize():RotByAngleXY(90), - shiftAmount))
    end
    if leftEdge == 0 and rightEdge < snapAmount then
        local shiftAmount = snapAmount - rightEdge
        adjustedOrigin = utils.addVector(origin, utils.multVector(normal:Normalize():RotByAngleXY(-90), - shiftAmount))
    end

    logger.log("Left edge", leftEdge)
    logger.log("Right edge", rightEdge)

    return adjustedOrigin
end

function logic:adjustForDepth(origin, normal, castType) -- Get depth and center point
    local searchDepth = 0.6

    normal.z = 0
    local forwardEdge = self:getEdge(origin, normal, searchDepth, castType) * searchDepth
    local backwardsEdge = self:getEdge(origin, normal:RotByAngleXY(180), searchDepth, castType) * searchDepth

    logger.log("forwardOffset", forwardEdge)
    logger.log("backwardsEdge", backwardsEdge)
    logger.log("depth", forwardEdge + backwardsEdge)

    if forwardEdge == 0 then return nil end
    if forwardEdge + backwardsEdge > 0.75 then return end
    if backwardsEdge == 0 then -- Short side of bench e.g.
        local shiftAmount = 0.2 - forwardEdge
        logger.log("short", shiftAmount)
        local adjustedOrigin = utils.addVector(origin, utils.multVector(normal:Normalize(), -shiftAmount))
        return adjustedOrigin
    end

    local shiftAmount = forwardEdge - ((forwardEdge + backwardsEdge) / 2)
    local adjustedOrigin = utils.addVector(origin, utils.multVector(normal:Normalize(), shiftAmount))

    return adjustedOrigin
end

function logic:getEdge(origin, direction, length, castType) -- Sweep for edge
    local maxSteps = 6
    local minZDelta = 0.125

    local offset = 1
    local lastHit = 0
    for i = 1, maxSteps do
        local from = utils.addVector(utils.addVector(origin, utils.multVector(direction:Normalize(), offset * length)), Vector4.new(0, 0, 1.2, 0))
        local to = utils.addVector(from, Vector4.new(0, 0, -2, 0))
        local result = self:raycast(from, to, castType)

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

function logic:inWorkspot()
    return self.sittables[0].workspot.inWorkspot or self.sittables[1].workspot.inWorkspot
end

function logic:inTransition()
    return self.sittables[0].workspot.inTransition or self.sittables[1].workspot.inTransition
end

function logic:hideAllWorkspots()
    for key, _ in pairs(self.sittables) do
        world.interactions[key].pos = Vector4.new(0, 0, 0, 0)
        self.sittables[key].workspot.interactionPosition = Vector4.new(0, 0, 0, 0)
        if world.interactions[key].pinID then
            Game.GetMappinSystem():SetMappinPosition(world.interactions[key].pinID, Vector4.new(0, 0, 0, 0))
        end
    end
end

function logic:protectSpot() -- Dispose close NPCs
    if not self:inWorkspot() then return end

    local target = Game.GetTargetingSystem():GetObjectClosestToCrosshair(GetPlayer(), TSQ_NPC())
    if target and (not target:IsPlayer()) and Game.GetWorkspotSystem():IsActorInWorkspot(target) and target:GetWorldPosition():Distance(GetPlayer():GetWorldPosition()) < 0.55 then
        target:Dispose()
    end
end

function logic:onUpdate()
    logger.log("Status", self.isScanning, self:isValidEnviroment(), self.interface)

    self:protectSpot()

    if (not self.isScanning and not self.mod.runtimeData.forceScan) or (not self:isValidEnviroment()) or (not self.interface) or self:inWorkspot() then
        self:hideAllWorkspots()

        if (self.isScanning or self.mod.runtimeData.forceScan) and self:inWorkspot() and self.mod.settings.hideExitPopup then
            if self.sittables[0].workspot.inWorkspot then self.sittables[0].workspot:setupExit(true) end
            if self.sittables[1].workspot.inWorkspot then self.sittables[1].workspot:setupExit(true) end
        elseif (not self.isScanning and not self.mod.runtimeData.forceScan) and self:inWorkspot() and self.mod.settings.hideExitPopup then
            interaction.hideHub()
        end

        return
    end

    self.casts = 0

    local position, forward, benchType = self:getTargetLocation()
    if position then
        local workspotZAdjustment = -0.45
        local workspotForwardAdjustment = 0.25
        local workspotPosition = utils.addVector(Vector4.new(position.x, position.y, position.z + workspotZAdjustment, 0), utils.multVector(forward:Normalize(), workspotForwardAdjustment))

        if self.mod.settings.sitAnimation ~= 1 then
            benchType = 1 - (self.mod.settings.sitAnimation - 2)
        end

        world.interactions[benchType].pos = position
        self.sittables[benchType].workspot.interactionPosition = position
        self.sittables[benchType].workspot.workspotPosition = workspotPosition
        self.sittables[benchType].workspot.workspotRotation.yaw = forward:ToRotation().yaw + 180

        if world.interactions[benchType].pinID then
            Game.GetMappinSystem():SetMappinPosition(world.interactions[benchType].pinID, position)
        end

        world.interactions[1 - benchType].pos = Vector4.new(0, 0, 0, 0)
        self.sittables[1 - benchType].workspot.interactionPosition = Vector4.new(0, 0, 0, 0)
        if world.interactions[1 - benchType].pinID then
            Game.GetMappinSystem():SetMappinPosition(world.interactions[1 - benchType].pinID, Vector4.new(0, 0, 0, 0))
        end

        logger.log("Benchtype", benchType)
    else
        self:hideAllWorkspots()
    end

    logger.log("Casts", self.casts)
end

return logic