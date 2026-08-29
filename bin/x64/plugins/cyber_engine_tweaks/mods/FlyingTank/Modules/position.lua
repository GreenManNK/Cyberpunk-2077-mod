local Utils = require("Tools/utils.lua")
local Position = {}
Position.__index = Position

function Position:New(all_models)
    -- instance --
    local obj = {}
    obj.log_obj = Log:New()
    obj.log_obj:SetLevel(LogLevel.Info, "Position")
    -- static --
    obj.all_models = all_models
    obj.min_direction_norm = 0.5 -- NOT Change this value
    obj.collision_max_count = 80
    obj.dividing_rate = 0.5
    obj.judged_stack_length = 3
    obj.collision_filters = {"Static", "Terrain", "Water"}
    obj.far_distance = 100
    -- dyanmic --
    obj.entity = nil
    obj.next_position = nil
    obj.next_angle = nil
    obj.model_index = 1
    obj.is_collision = false
    obj.local_corners = {}
    obj.corners = {}
    obj.stack_distance = 0
    obj.stack_count = 0
    obj.sensor_pair_vector_num = 15
    obj.collision_trace_result = nil

    obj.fly_tank_system = nil

    return setmetatable(obj, self)
end

--[[
        This is the diagram of the vehicle's local corners
               E-----A
              /|    /|
             / |   / |
            G-----C  |
            |  F--|--B
            | /   | /
            |/    |/       
            H-----D

            ABFE is the front face
            CDHG is the back face
            ABDC is the right face
            EFHG is the left face
            ACGE is the top face
            BDHF is the bottom face           
    ]]

function Position:SetModel(index)
    self.local_corners = {
        { x = self.all_models[index].shape.A.x, y = self.all_models[index].shape.A.y, z = self.all_models[index].shape.A.z },
        { x = self.all_models[index].shape.B.x, y = self.all_models[index].shape.B.y, z = self.all_models[index].shape.B.z },
        { x = self.all_models[index].shape.C.x, y = self.all_models[index].shape.C.y, z = self.all_models[index].shape.C.z },
        { x = self.all_models[index].shape.D.x, y = self.all_models[index].shape.D.y, z = self.all_models[index].shape.D.z },
        { x = self.all_models[index].shape.E.x, y = self.all_models[index].shape.E.y, z = self.all_models[index].shape.E.z },
        { x = self.all_models[index].shape.F.x, y = self.all_models[index].shape.F.y, z = self.all_models[index].shape.F.z },
        { x = self.all_models[index].shape.G.x, y = self.all_models[index].shape.G.y, z = self.all_models[index].shape.G.z },
        { x = self.all_models[index].shape.H.x, y = self.all_models[index].shape.H.y, z = self.all_models[index].shape.H.z },
        { x = self.all_models[index].shape.ABFE.x, y = self.all_models[index].shape.ABFE.y, z = self.all_models[index].shape.ABFE.z },
        { x = self.all_models[index].shape.CDHG.x, y = self.all_models[index].shape.CDHG.y, z = self.all_models[index].shape.CDHG.z },
        { x = self.all_models[index].shape.ABDC.x, y = self.all_models[index].shape.ABDC.y, z = self.all_models[index].shape.ABDC.z },
        { x = self.all_models[index].shape.EFHG.x, y = self.all_models[index].shape.EFHG.y, z = self.all_models[index].shape.EFHG.z },
        { x = self.all_models[index].shape.ACGE.x, y = self.all_models[index].shape.ACGE.y, z = self.all_models[index].shape.ACGE.z },
        { x = self.all_models[index].shape.BDHF.x, y = self.all_models[index].shape.BDHF.y, z = self.all_models[index].shape.BDHF.z }
    }
end

function Position:SetEntity(entity)
    if entity == nil then
        self.log_obj:Record(LogLevel.Warning, "Entity is nil for SetEntity")
    end
    self.entity = entity
    self.fly_tank_system = FlyTankSystem.new()
    local entity_id_hash = entity:GetEntityID().hash
    self.fly_tank_system:SetVehicle(entity_id_hash)
end

function Position:ChangeWorldCordinate(basic_vector ,point_list)
    local quaternion = self:GetQuaternion()
    local result_list = {}
    for i, corner in ipairs(point_list) do
        local rotated = Utils:RotateVectorByQuaternion(corner, quaternion)
        result_list[i] = {x = rotated.x + basic_vector.x, y = rotated.y + basic_vector.y, z = rotated.z + basic_vector.z}
    end
    return result_list
end

function Position:GetPosition()
    if self.entity == nil then
        self.log_obj:Record(LogLevel.Warning, "No vehicle entity for GetPosition")
        return Vector4.new(0, 0, 0, 1.0)
    end
    return self.entity:GetWorldPosition()
end

function Position:GetForward()
    if self.entity == nil then
        self.log_obj:Record(LogLevel.Warning, "No vehicle entity for GetForward")
        return Vector4.new(0, 0, 0, 1.0)
    end
    return self.entity:GetWorldForward()
end

function Position:GetQuaternion()
    if self.entity == nil then
        self.log_obj:Record(LogLevel.Warning, "No vehicle entity for GetQuaternion")
        return Quaternion.new(0, 0, 0, 1.0)
    end
    return self.entity:GetWorldOrientation()
end

function Position:GetEulerAngles()
    if self.entity == nil then
        self.log_obj:Record(LogLevel.Warning, "No vehicle entity for GetEulerAngles")
        return EulerAngles.new(0, 0, 0)
    end
    return self.entity:GetWorldOrientation():ToEulerAngles()
end

function Position:GetPlayerAroundDirection(angle)
    return Vector4.RotateAxis(Game.GetPlayer():GetWorldForward(), Vector4.new(0, 0, 1, 0), angle / 180.0 * Pi())
end

function Position:GetSpawnPosition(distance, angle)
    local pos = Game.GetPlayer():GetWorldPosition()
    local heading = self:GetPlayerAroundDirection(angle)
    return Vector4.new(pos.x + (heading.x * distance), pos.y + (heading.y * distance), pos.z + heading.z, pos.w + heading.w)
end

function Position:GetSpawnOrientation(angle)
    return EulerAngles.ToQuat(Vector4.ToRotation(self:GetPlayerAroundDirection(angle)))
end

function Position:IsPlayerAround()
    local player_pos = Game.GetPlayer():GetWorldPosition()
    if self:GetPosition():IsZero() then
        return true
    end
    local distance = Vector4.Distance(player_pos, self:GetPosition())
    if distance < self.far_distance then
        return true
    else
        return false
    end
end

function Position:SetNextPosition(x, y, z, roll, pitch, yaw)

    if self.entity == nil then
        self.log_obj:Record(LogLevel.Error, "No vehicle entity for SetNextPosition")
        return Def.TeleportResult.Error
    end

    local pos = self:GetPosition()
    self.next_position = Vector4.new(pos.x + x, pos.y + y, pos.z + z, 1.0)

    local rot = self:GetEulerAngles()
    self.next_angle = EulerAngles.new(rot.roll + roll, rot.pitch + pitch, rot.yaw + yaw)

    self:ChangePosition()

    if self:CheckCollision(pos, self.next_position) then
        self.log_obj:Record(LogLevel.Debug, "Collision Detected")

        self.next_position = Vector4.new(pos.x, pos.y, pos.z, 1.0)
        self.next_angle = EulerAngles.new(rot.roll, rot.pitch, rot.yaw)

        self:ChangePosition()

        return Def.TeleportResult.Collision
    else
        return Def.TeleportResult.Success
    end
end

function Position:ChangePosition()

    if self.entity == nil then
        self.log_obj:Record(LogLevel.Error, "No vehicle entity for ChangePosition")
        return false
    end

    Game.GetTeleportationFacility():Teleport(self.entity, self.next_position, self.next_angle)
    return true

end

function Position:AddLinelyVelocity(x,y,z,roll,pitch,yaw)
    local pos = Vector3.new(x, y, z)
    local delta_roll, delta_pitch, delta_yaw = self:EulerAngleChange(roll, pitch, yaw)
    local angle = Vector3.new(delta_pitch, delta_roll, delta_yaw)
    self.fly_tank_system:AddLinelyVelocity(pos, angle)
end

function Position:ChangeLinelyVelocity(x,y,z,roll,pitch,yaw,type)
    local pos = Vector3.new(x, y, z)
    local angle = Vector3.new(roll, pitch, yaw)
    self.fly_tank_system:ChangeLinelyVelocity(pos, angle, type)
end

function Position:EulerAngleChange(local_roll, local_pitch, local_yaw)

    local angle = self:GetEulerAngles()

    -- Convert Euler angles to radians
    local rad_roll = math.rad(angle.roll)
    local rad_pitch = math.rad(angle.pitch)
    local rad_yaw = math.rad(angle.yaw)
    local rad_local_roll = math.rad(local_roll)
    local rad_local_pitch = math.rad(local_pitch)
    local rad_local_yaw = math.rad(local_yaw)

    -- Calculate sin and cos
    local cos_roll, sin_roll = math.cos(rad_roll), math.sin(rad_roll)
    local cos_pitch, sin_pitch = math.cos(rad_pitch), math.sin(rad_pitch)
    local cos_yaw, sin_yaw = math.cos(rad_yaw), math.sin(rad_yaw)
    local cos_local_roll, sin_local_roll = math.cos(rad_local_roll), math.sin(rad_local_roll)
    local cos_local_pitch, sin_local_pitch = math.cos(rad_local_pitch), math.sin(rad_local_pitch)
    local cos_local_yaw, sin_local_yaw = math.cos(rad_local_yaw), math.sin(rad_local_yaw)

    -- Calculate rotation matrices
    local R1 = {
        {cos_roll * cos_pitch, cos_roll * sin_pitch * sin_yaw - sin_roll * cos_yaw, cos_roll * sin_pitch * cos_yaw + sin_roll * sin_yaw},
        {sin_roll * cos_pitch, sin_roll * sin_pitch * sin_yaw + cos_roll * cos_yaw, sin_roll * sin_pitch * cos_yaw - cos_roll * sin_yaw},
        {-sin_pitch, cos_pitch * sin_yaw, cos_pitch * cos_yaw}
    }

    local R2 = {
        {cos_local_roll * cos_local_pitch, cos_local_roll * sin_local_pitch * sin_local_yaw - sin_local_roll * cos_local_yaw, cos_local_roll * sin_local_pitch * cos_local_yaw + sin_local_roll * sin_local_yaw},
        {sin_local_roll * cos_local_pitch, sin_local_roll * sin_local_pitch * sin_local_yaw + cos_local_roll * cos_local_yaw, sin_local_roll * sin_local_pitch * cos_local_yaw - cos_local_roll * sin_local_yaw},
        {-sin_local_pitch, cos_local_pitch * sin_local_yaw, cos_local_pitch * cos_local_yaw}
    }

    -- Calculate composite rotation matrix
    local R = {}
    for i = 1, 3 do
        R[i] = {}
        for j = 1, 3 do
            R[i][j] = 0
            for k = 1, 3 do
                R[i][j] = R[i][j] + R1[i][k] * R2[k][j]
            end
        end
    end

    -- Calculate Euler angles from composite rotation matrix
    local new_roll = math.deg(math.atan2(R[2][1], R[1][1]))
    local new_pitch = math.deg(math.atan2(-R[3][1], math.sqrt(R[3][2] * R[3][2] + R[3][3] * R[3][3])))
    local new_yaw = math.deg(math.atan2(R[3][2], R[3][3]))

    return new_roll - angle.roll, new_pitch - angle.pitch, new_yaw - angle.yaw
end

function Position:CheckCollision(current_pos, next_pos)

    self.corners = self:ChangeWorldCordinate(current_pos, self.local_corners)

    -- Conjecture Direction Norm for Detect Collision
    local direction = {x = next_pos.x - current_pos.x, y = next_pos.y - current_pos.y, z = next_pos.z - current_pos.z}
    local direction_norm = math.sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z)
    if direction_norm < self.min_direction_norm then
        direction = {x = direction.x * self.min_direction_norm / direction_norm, y = direction.y * self.min_direction_norm / direction_norm, z = direction.z * self.min_direction_norm / direction_norm}
    end

    for i, corner in ipairs(self.corners) do
        local current_corner = Vector4.new(corner.x, corner.y, corner.z, 1.0)
        local next_corner = Vector4.new(corner.x + direction.x, corner.y + direction.y, corner.z + direction.z, 1.0)
        for _, filter in ipairs(self.collision_filters) do
            local success, trace_result = Game.GetSpatialQueriesSystem():SyncRaycastByCollisionGroup(current_corner, next_corner, filter, false, false)
            if success then
                self.collision_trace_result = trace_result
                self.stack_corner_num = i
                self.is_collision = true
                return true
            end
        end
    end

    return false
end

function Position:IsCollision()
    local collision_status = self.is_collision
    self.is_collision = false
    return collision_status
end

return Position