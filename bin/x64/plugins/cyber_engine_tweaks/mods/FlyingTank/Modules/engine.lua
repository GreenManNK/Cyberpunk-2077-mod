Engine = {}
Engine.__index = Engine

function Engine:New(vehicle_obj)
    local obj = {}
    obj.log_obj = Log:New()
    obj.log_obj:SetLevel(LogLevel.Info, "Engine")
    obj.vehicle_obj = vehicle_obj
    ---static---
    obj.all_models = vehicle_obj.all_models
    obj.model_index = 1
    obj.pitch_limit = 35
    obj.max_pitch = 70
    obj.reset_pitch_exception_area = 0.1
    obj.reset_pitch_speed = 0.03
    ---dynamic---
    -- set default parameters
    obj.next_indication = {roll = 0, pitch = 0, yaw = 0}
    obj.is_finished_init = false

    obj.entity = nil
    obj.fly_tank_system = nil
    obj.force = Vector3.new(0, 0, 0)
    obj.torque = Vector3.new(0, 0, 0)
    obj.direction_velocity = Vector3.new(0, 0, 0)
    obj.angular_velocity = Vector3.new(0, 0, 0)
    obj.engine_control_type = Def.EngineControlType.None
    

    return setmetatable(obj, self)
end

function Engine:SetModel(index)
    -- set pyhsical parameters
    self.up_down_speed = self.all_models[index].up_down_speed
    self.pitch_speed = self.all_models[index].pitch_speed
    self.reset_pitch_speed = self.all_models[index].reset_pitch_speed
end

function Engine:Init(entity)
    if entity == nil then
        self.log_obj:Record(LogLevel.Warning, "Entity is nil for SetEntity")
    end
    self.entity = entity
    entity:TurnEngineOn(true)
    self.fly_tank_system = FlyTankSystem.new()
    local entity_id_hash = entity:GetEntityID().hash
    self.fly_tank_system:SetVehicle(entity_id_hash)

    self:SetForce(Vector3.new(0, 0, 0))
    self:SetTorque(Vector3.new(0, 0, 0))

    self.is_finished_init = true
end

function Engine:Update(delta)
    if not self.is_finished_init then
        return
    end
    if FlyingTank.core_obj.event_obj:IsInMenuOrPopupOrPhoto() then
        return
    end
    if self:GetPhysicsState() ~= 0 then
        self:UnsetPhysicsState()
        self.log_obj:Record(LogLevel.Trace, "Unset DAV physics")
    end

    if FlyingTank.core_obj.event_obj.current_situation == Def.Situation.Waiting then
        return
    end

    if self.engine_control_type == Def.EngineControlType.ChangeVelocity then
        self.force = Vector3.new(0, 0, 0)
        self.torque = Vector3.new(0, 0, 0)
        self:ChangeVelocity(Def.ChangeVelocityType.Both ,self.direction_velocity, self.angular_velocity)
    elseif self.engine_control_type == Def.EngineControlType.AddForce then
        -- local direction_velocity = self:GetDirectionVelocity()
        -- local angular_velocity = self:GetAngularVelocity()
        -- local _, actual_angular_velocity = self:GetDirectionAndAngularVelocity()
        -- local angular_velocity_diff = Vector3.new(angular_velocity.x - actual_angular_velocity.x, angular_velocity.y - actual_angular_velocity.y, angular_velocity.z - actual_angular_velocity.z)
        -- local mass = self.mass
        -- self.force = Vector3.new(direction_velocity.x * mass, direction_velocity.y * mass, direction_velocity.z * mass)
        -- self.torque = Vector3.new(angular_velocity_diff.x * self.torque_gain, angular_velocity_diff.y * self.torque_gain, angular_velocity_diff.z * self.torque_gain)
        -- self:AddForce(self.force, self.torque)
    elseif self.engine_control_type == Def.EngineControlType.FluctuationVelocity then
        self.force = Vector3.new(0, 0, 0)
        self.torque = Vector3.new(0, 0, 0)
        self:FluctuationVelocity(delta)
    elseif self.engine_control_type == Def.EngineControlType.Blocking then
        -- Do nothing, just block the physics
        self.log_obj:Record(LogLevel.Trace, "Blocking DAV physics")
    else
        self.log_obj:Record(LogLevel.Error, "Unknown control type")
    end
end

function Engine:UnsetPhysicsState()
    self.fly_tank_system:UnsetPhysicsState()
end

--- Get Physics state
---@return number
function Engine:GetPhysicsState()
    if not self.is_finished_init then
        return 0
    end
    return self.fly_tank_system:GetPhysicsState()
end

function Engine:GetControlType()
    return self.engine_control_type
end

function Engine:SetControlType(control_type)
    self.engine_control_type = control_type
    if control_type == Def.EngineControlType.ChangeVelocity and self:HasGravity() then
        self:EnableGravity(false)
    elseif control_type == Def.EngineControlType.AddForce and not self:HasGravity() then
        self:EnableGravity(true)
    end
end

function Engine:IsOnGround()
    if not self.is_finished_init then
        return false
    end
    return self.fly_tank_system:IsOnGround()
end

function Engine:HasGravity()
    return self.fly_tank_system:HasGravity()
end

function Engine:EnableGravity(on)
    self.fly_tank_system:EnableGravity(on)
end

--- Change velocity
---@param type integer
---@param direction_velocity Vector3
---@param angular_velocity Vector3
function Engine:ChangeVelocity(type, direction_velocity, angular_velocity)
    self.fly_tank_system:ChangeVelocity(direction_velocity, angular_velocity, type)
end

function Engine:SetForce(force)
    self.force = force
end

function Engine:SetTorque(torque)
    self.torque = torque
end

function Engine:GetDirectionVelocity()
    return self.direction_velocity
end

function Engine:GetAngularVelocity()
    return self.angular_velocity
end

function Engine:SetDirectionVelocity(direction_velocity)
    self.direction_velocity = direction_velocity
end

function Engine:SetAngularVelocity(angular_velocity)
    self.angular_velocity = angular_velocity
end

--- Get Direction and Angular Velocity
---@return Vector3
---@return Vector3
function Engine:GetDirectionAndAngularVelocity()
    if not self.is_finished_init then
        return Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
    end
    return self.fly_tank_system:GetVelocity(), self.fly_tank_system:GetAngularVelocity()
end

function Engine:AddVelocity(x,y,z,roll,pitch,yaw)
    local pos = Vector3.new(x, y, z)
    local delta_roll, delta_pitch, delta_yaw = self:EulerAngleChange(roll, pitch, yaw)
    local angle = Vector3.new(delta_pitch, delta_roll, delta_yaw)
    self.fly_tank_system:AddVelocity(pos, angle)
end

function Engine:EulerAngleChange(local_roll, local_pitch, local_yaw)

    local angle = self.entity:GetWorldOrientation():ToEulerAngles()

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

function Engine:GetNextPosition(movement)

    -- wait for init
    if not self.is_finished_init then
        return 0, 0, 0, 0, 0, 0
    end

    if movement == Def.ActionList.Idle and FlyingTank.core_obj.event_obj.current_situation == Def.Situation.Waiting then
        local x, y, z, roll, pitch, yaw = 0, 0, 0, 0, 0, 0

        local vel_vec, _ = self:GetDirectionAndAngularVelocity()

        if not self.vehicle_obj:IsCollision() then
            -- Height control
            local height = self.vehicle_obj:GetHeightFromGround()
            local dest_height = self.vehicle_obj.minimum_distance_to_ground

            local damping = 0.9
            local height_gain = 0.4

            z = z - vel_vec.z * damping
            if math.abs(height - dest_height) > 0.05 then
                z = z + (dest_height - height) * height_gain
            end
        end

        -- roll and pitch control
        local current_angle = self.vehicle_obj:GetEulerAngles()
        local damping_angle = 0.2

        if math.abs(current_angle.roll) > 0.1 then
            roll = roll + current_angle.roll * damping_angle
        elseif math.abs(current_angle.roll) < -0.1 then
            roll = roll + current_angle.roll * damping_angle
        end

        if math.abs(current_angle.pitch) > 0.1 then
            pitch = pitch - current_angle.pitch * damping_angle
        elseif math.abs(current_angle.pitch) < -0.1 then
            pitch = pitch + current_angle.pitch * damping_angle
        end

        self:ChangeVelocity(Def.ChangeVelocityType.Angular ,Vector3.new(0, 0, 0), Vector3.new(roll, pitch, 0))
        roll = 0
        pitch = 0


        return x, y, z, roll, pitch, yaw
    end

    local angle_pitch = self.entity:GetWorldOrientation():ToEulerAngles().pitch
    if angle_pitch > self.max_pitch or angle_pitch < -self.max_pitch then
        self:ChangeVelocity(Def.ChangeVelocityType.Angular ,Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
    end

    if movement == Def.ActionList.Up then
        local vec3 = self.fly_tank_system:GetVelocity()
        if vec3.z > 40 then
            return 0, 0, 0, 0, 0, 0
        end
        return 0, 0, self.up_down_speed, 0, 0, 0
    elseif movement == Def.ActionList.Down then
        local vec3 = self.fly_tank_system:GetVelocity()
        if vec3.z < -40 then
            return 0, 0, 0, 0, 0, 0
        end
        return 0, 0, -self.up_down_speed, 0, 0, 0
    elseif movement == Def.ActionList.PitchUp then
        if angle_pitch > self.pitch_limit then
            return 0, 0, 0, 0, 0, 0
        elseif angle_pitch > 0 then
            return 0, 0, 0, 0, self.pitch_speed * (1 - angle_pitch / self.pitch_limit), 0
        end
        return 0, 0, 0, 0, self.pitch_speed, 0
    elseif movement == Def.ActionList.PitchDown then
        if angle_pitch < -self.pitch_limit then
            return 0, 0, 0, 0, 0, 0
        elseif angle_pitch < 0 then
            return 0, 0, 0, 0, -self.pitch_speed * (1 + angle_pitch / self.pitch_limit), 0
        end
        return 0, 0, 0, 0, -self.pitch_speed, 0
    elseif movement == Def.ActionList.PitchReset then
        if angle_pitch > self.reset_pitch_exception_area then
            return 0, 0, 0, 0, -self.reset_pitch_speed, 0
        elseif angle_pitch < -self.reset_pitch_exception_area then
            return 0, 0, 0, 0, self.reset_pitch_speed, 0
        end
        return 0, 0, 0, 0, 0, 0
    else
        return 0, 0, 0, 0, 0, 0
    end

end

--- Set fluctuation velocity params
---@param step_width_per_second number
---@param target_velocity number
function Engine:SetFluctuationVelocityParams(step_width_per_second, target_velocity)
    self.step_width_per_second = step_width_per_second
    self.target_velocity = target_velocity
    self.engine_control_type = Def.EngineControlType.FluctuationVelocity
end

--- Fluctuation velocity
---@param delta number
function Engine:FluctuationVelocity(delta)
    local velocity = Vector4.Vector3To4(self.direction_velocity):Length()
    if self.step_width_per_second == 0 then
        self.log_obj:Record(LogLevel.Trace, "step_width_per_second is 0")
        self.engine_control_type = Def.EngineControlType.ChangeVelocity
        return
    elseif self.step_width_per_second > 0 and velocity > self.target_velocity then
        self.log_obj:Record(LogLevel.Trace, "velocity > target_velocity")
        self.direction_velocity.x = self.direction_velocity.x / velocity * self.target_velocity
        self.direction_velocity.y = self.direction_velocity.y / velocity * self.target_velocity
        self.direction_velocity.z = self.direction_velocity.z / velocity * self.target_velocity
        self.engine_control_type = Def.EngineControlType.ChangeVelocity
        return
    elseif self.step_width_per_second < 0 and velocity < self.target_velocity then
        self.log_obj:Record(LogLevel.Trace, "velocity < target_velocity")
        self.direction_velocity.x = self.direction_velocity.x / velocity * self.target_velocity
        self.direction_velocity.y = self.direction_velocity.y / velocity * self.target_velocity
        self.direction_velocity.z = self.direction_velocity.z / velocity * self.target_velocity
        self.engine_control_type = Def.EngineControlType.ChangeVelocity
        return
    end
    self.direction_velocity.x = self.direction_velocity.x / velocity * (velocity + self.step_width_per_second * delta)
    self.direction_velocity.y = self.direction_velocity.y / velocity * (velocity + self.step_width_per_second * delta)
    self.direction_velocity.z = self.direction_velocity.z / velocity * (velocity + self.step_width_per_second * delta)
    self:ChangeVelocity(Def.ChangeVelocityType.Both ,self.direction_velocity, self.angular_velocity)
end

return Engine
