local Engine = require("Modules/engine.lua")
local Radio = require("Modules/radio.lua")
local Vehicle = {}
Vehicle.__index = Vehicle

function Vehicle:New(all_models)
	---instance---
	local obj = {}
	obj.all_models = all_models
	obj.engine_obj = Engine:New(obj)
	obj.radio_obj = Radio:New()
	obj.log_obj = Log:New()
	obj.log_obj:SetLevel(LogLevel.Info, "Vehicle")
	---static---
	-- summon
	obj.spawn_distance = 5.5
	obj.spawn_height = 25
	obj.spawn_wait_count = 150
	obj.down_time_count = 300
	obj.land_offset = -1.0
	obj.search_ground_offset = 2
	obj.search_ground_distance = 100
	obj.collision_filters =  {"Static", "Terrain", "Water"}
	obj.far_distance = 100
	obj.minimum_distance_to_ground = 0.6
	obj.down_timeout = 5 -- s
	obj.up_timeout = 350
	obj.down_speed = -5.0
	---dynamic---
	-- summon
	obj.entity_id = nil
	obj.vehicle_model_tweakdb_id = nil
	obj.vehicle_model_type = nil
	obj.active_seat = nil
	obj.active_door = nil
	-- status
	obj.is_landed = false
	obj.is_spawning = false

	return setmetatable(obj, self)
end

function Vehicle:Init()

	local index = FlyingTank.model_index
	local type_number = FlyingTank.model_type_index
	self.vehicle_model_tweakdb_id = self.all_models[index].tweakdb_id
	self.vehicle_model_type = self.all_models[index].type[type_number]
	self.active_seat = self.all_models[index].actual_allocated_seat
	self.active_door = self.all_models[index].actual_allocated_door
	self.engine_obj:SetModel(index)

end

function Vehicle:IsPlayerIn()

	local veh_obj = GetMountedVehicle(Game.GetPlayer())
	if veh_obj ~= nil then
		local veh_record_id_hash = veh_obj:GetRecordID().hash
		if veh_record_id_hash == TweakDBID.new(FlyingTank.basilisk_aldecaldos_fly_record).hash or veh_record_id_hash == TweakDBID.new(FlyingTank.basilisk_militech_fly_record).hash then
			return true
		else
			return false
		end
	else
		return false
	end

end

function Vehicle:IsSpawning()
	return self.is_spawning
end

function Vehicle:IsDespawned()
	if self.entity_id == nil then
		return true
	end
	if Game.FindEntityByID(self.entity_id) == nil then
		return true
	else
		return false
	end
end

function Vehicle:GetPosition()
	if self.entity_id == nil then
		return nil
	end
	local entity = Game.FindEntityByID(self.entity_id)
	if entity == nil then
		self.log_obj:Record(LogLevel.Warning, "No entity to get position")
		return nil
	end
	return entity:GetWorldPosition()
end

function Vehicle:GetHeightFromGround()
	local current_position = self:GetPosition()
	if current_position == nil then
		self.log_obj:Record(LogLevel.Warning, "No position to get height from ground")
		return 0
	end
	return current_position.z - self:GetGroundPosition()
end

function Vehicle:GetEulerAngles()
	if self.entity_id == nil then
		return nil
	end
	local entity = Game.FindEntityByID(self.entity_id)
	if entity == nil then
		self.log_obj:Record(LogLevel.Warning, "No entity to get angle")
		return nil
	end
	return entity:GetWorldOrientation():ToEulerAngles()
end

function Vehicle:IsPlayerAround()
    local player_pos = Game.GetPlayer():GetWorldPosition()
	local vehicle_pos = self:GetPosition()
	if player_pos == nil or vehicle_pos == nil then
		self.log_obj:Record(LogLevel.Warning, "No position to check player around")
		return false
	end
    if vehicle_pos:IsZero() then
        return true
    end
    local distance = Vector4.Distance(player_pos, vehicle_pos)
    if distance < self.far_distance then
        return true
    else
        return false
    end
end

--- Get Ground Position
---@return number z
function Vehicle:GetGroundPosition()
    local current_position = self:GetPosition()
	if current_position == nil then
		self.log_obj:Record(LogLevel.Warning, "No position to get ground position")
		return 0
	end
    current_position.z = current_position.z + self.search_ground_offset
    for _, filter in ipairs(self.collision_filters) do
        local is_success, trace_result = Game.GetSpatialQueriesSystem():SyncRaycastByCollisionGroup(current_position, Vector4.new(current_position.x, current_position.y, current_position.z - self.search_ground_distance, 1.0), filter, false, false)
        if is_success then
            return trace_result.position.z
        end
    end
    return current_position.z - self.search_ground_distance - 1
end

function Vehicle:Spawn(position, angle)
	if self.entity_id ~= nil then
		self.log_obj:Record(LogLevel.Info, "Entity already spawned")
		return false
	end

	self.is_spawning = true

	local entity_system = Game.GetDynamicEntitySystem()
	local entity_spec = DynamicEntitySpec.new()

	entity_spec.recordID = self.vehicle_model_tweakdb_id
	entity_spec.appearanceName = self.vehicle_model_type
	entity_spec.position = position
	entity_spec.orientation = angle
	entity_spec.persistState = false
	entity_spec.persistSpawn = false
	self.entity_id = entity_system:CreateEntity(entity_spec)
	if self.entity_id == nil then
		return false
	end
	-- set entity id to position object
	Cron.Every(0.1, {tick = 1}, function(timer)
		local entity = Game.FindEntityByID(self.entity_id)
		if entity ~= nil then
			self.is_spawning = false
			self.engine_obj:Init(entity)
			self.engine_obj:SetControlType(Def.EngineControlType.ChangeVelocity)
			Cron.Halt(timer)
		end
	end)

	return true
end

function Vehicle:SpawnToSky()
	local position = self:GetSpawnPosition(self.spawn_distance, 0.0)
	position.z = position.z + self.spawn_height
	local angle = self:GetSpawnOrientation(90.0)
	self:Spawn(position, angle)
	Cron.Every(FlyingTank.time_resolution, { tick = 1 }, function(timer)
		if not FlyingTank.core_obj.event_obj:IsInMenuOrPopupOrPhoto() and not self.is_spawning then
			local height = self:GetHeightFromGround()
			self.log_obj:Record(LogLevel.Trace, "Current Height In Spawning: " .. height)
			if timer.tick == 1 then
				self.engine_obj:SetDirectionVelocity(Vector3.new(0, 0, self.down_speed))
				self.log_obj:Record(LogLevel.Info, "Initial Spawn Velocity: " .. self.engine_obj:GetDirectionVelocity().z)
			elseif height < 10 and self.engine_obj:GetControlType() ~= Def.EngineControlType.FluctuationVelocity then
				self.engine_obj:SetFluctuationVelocityParams(-2, 1)
				self.log_obj:Record(LogLevel.Info, "Fluctuation Velocity")
			elseif height < self.minimum_distance_to_ground or timer.tick > (self.down_timeout / FlyingTank.time_resolution) or FlyingTank.core_obj.event_obj.current_situation ~= Def.Situation.Landing then
				self.engine_obj:SetControlType(Def.EngineControlType.ChangeVelocity)
				self.engine_obj:SetDirectionVelocity(Vector3.new(0, 0, 0))
				self.is_landed = true
				self.log_obj:Record(LogLevel.Info, "Spawn to sky success")
				Cron.Halt(timer)
			end
			timer.tick = timer.tick + 1
		end
	end)
end

function Vehicle:GetSpawnPosition(distance, angle)
    local pos = Game.GetPlayer():GetWorldPosition()
    local heading = self:GetPlayerAroundDirection(angle)
    return Vector4.new(pos.x + (heading.x * distance), pos.y + (heading.y * distance), pos.z + heading.z, pos.w + heading.w)
end

function Vehicle:GetSpawnOrientation(angle)
    return EulerAngles.ToQuat(Vector4.ToRotation(self:GetPlayerAroundDirection(angle)))
end

function Vehicle:GetPlayerAroundDirection(angle)
    return Vector4.RotateAxis(Game.GetPlayer():GetWorldForward(), Vector4.new(0, 0, 1, 0), angle / 180.0 * Pi())
end

function Vehicle:Despawn()

	if self.entity_id == nil then
		self.log_obj:Record(LogLevel.Warning, "No entity to despawn")
		return false
	end
	local entity_system = Game.GetDynamicEntitySystem()
	entity_system:DeleteEntity(self.entity_id)
	self.entity_id = nil
	return true

end

function Vehicle:DespawnFromGround()
	Cron.Every(0.01, { tick = 1 }, function(timer)
		if not FlyingTank.core_obj.event_obj:IsInMenuOrPopupOrPhoto() then
			if timer.tick == 1 then
				self.engine_obj:SetControlType(Def.EngineControlType.ChangeVelocity)
				self.engine_obj:SetDirectionVelocity(Vector3.new(0, 0, 1))
				self.log_obj:Record(LogLevel.Info, "Initial Despawn Velocity: " .. self.engine_obj:GetDirectionVelocity().z)
			elseif timer.tick == 2 then
				self.engine_obj:SetFluctuationVelocityParams(1, math.abs(self.down_speed))
				self.log_obj:Record(LogLevel.Info, "Fluctuation Velocity")
			elseif timer.tick >= self.up_timeout then
				self.log_obj:Record(LogLevel.Info, "Despawn Timeout")
				Cron.After(1.5, function()
					self:Despawn()
				end)
				Cron.Halt(timer)
			end
			timer.tick = timer.tick + 1
		end
	end)
end

function Vehicle:UnlockDoor()
	if self.entity_id == nil then
		self.log_obj:Record(LogLevel.Warning, "No entity to change door lock")
		return false
	end
	local entity = Game.FindEntityByID(self.entity_id)
	local vehicle_ps = entity:GetVehiclePS()
	vehicle_ps:UnlockAllVehDoors()
	return true
end

function Vehicle:LockDoor()
	if self.entity_id == nil then
		self.log_obj:Record(LogLevel.Warning, "No entity to change door lock")
		return false
	end
	local entity = Game.FindEntityByID(self.entity_id)
	local vehicle_ps = entity:GetVehiclePS()
	vehicle_ps:QuestLockAllVehDoors()
	return true
end

---@param e_veh_door EVehicleDoor
---@return string | nil
function Vehicle:GetDoorState(e_veh_door)
	if self.entity_id == nil then
		self.log_obj:Record(LogLevel.Warning, "No entity to get door state")
		return nil
	end
	local entity = Game.FindEntityByID(self.entity_id)
	local vehicle_ps = entity:GetVehiclePS()
	return vehicle_ps:GetDoorState(e_veh_door).value
end

---@param door_state Def.DoorOperation
---@return number | nil
function Vehicle:ChangeDoorState(door_state)

	local change_counter = 0

	for _, door_name in ipairs(self.active_door) do
		local e_veh_door = EVehicleDoor.seat_front_left
		if door_name == "seat_front_left" then
			e_veh_door = EVehicleDoor.seat_front_left
		elseif door_name == "seat_front_right" then
			e_veh_door = EVehicleDoor.seat_front_right
		elseif door_name == "seat_back_left" then
			e_veh_door = EVehicleDoor.seat_back_left
		elseif door_name == "seat_back_right" then
			e_veh_door = EVehicleDoor.seat_back_right
		elseif door_name == "trunk" then
			e_veh_door = EVehicleDoor.trunk
		elseif door_name == "hood" then
			e_veh_door = EVehicleDoor.hood
		end

		local state = self:GetDoorState(e_veh_door)

		local door_event = nil
		local can_change = true
		if state == "Closed" then
			if door_state == Def.DoorOperation.Close then
				can_change = false
			end
			door_event = VehicleDoorOpen.new()
		elseif state == "Open" then
			if door_state == Def.DoorOperation.Open then
				can_change = false
			end
			door_event = VehicleDoorClose.new()
		else
			self.log_obj:Record(LogLevel.Error, "Door state is not valid : " .. state)
			return nil
		end

		if self.entity_id == nil then
			self.log_obj:Record(LogLevel.Warning, "No entity to get door state")
			return nil
		end
		local entity = Game.FindEntityByID(self.entity_id)
		local vehicle_ps = entity:GetVehiclePS()
		if can_change then
			change_counter = change_counter + 1
			door_event.slotID = CName.new(door_name)
			door_event.forceScene = false
			vehicle_ps:QueuePSEvent(vehicle_ps, door_event)
		end
	end
	return change_counter

end

function Vehicle:Operate(action_commands)
	if #action_commands == 1 and action_commands[1] == Def.ActionList.Nothing then
		return false
	end
	local x_total, y_total, z_total, roll_total, pitch_total, yaw_total = 0, 0, 0, 0, 0, 0
	self.log_obj:Record(LogLevel.Debug, "Operation Count:" .. #action_commands)
	for _, action_command in ipairs(action_commands) do
		if action_command >= Def.ActionList.ChangeDoor then
			self.log_obj:Record(LogLevel.Critical, "Invalid Event Command:" .. action_command)
			return false
		end
		local x, y, z, roll, pitch, yaw = self.engine_obj:GetNextPosition(action_command)
		x_total = x_total + x
		y_total = y_total + y
		z_total = z_total + z
		roll_total = roll_total + roll
		pitch_total = pitch_total + pitch
		yaw_total = yaw_total + yaw
	end
	if #action_commands == 0 then
		self.log_obj:Record(LogLevel.Critical, "Division by Zero")
		return false
	end

	self.is_collision = false

	x_total = x_total / #action_commands
	y_total = y_total / #action_commands
	z_total = z_total / #action_commands
	roll_total = roll_total / #action_commands
	pitch_total = pitch_total / #action_commands
	yaw_total = yaw_total / #action_commands

	if x_total == 0 and y_total == 0 and z_total == 0 and roll_total == 0 and pitch_total == 0 and yaw_total == 0 then
		self.log_obj:Record(LogLevel.Debug, "No operation")
		return false
	end

	self.engine_obj:AddVelocity(x_total, y_total, z_total, roll_total, pitch_total, yaw_total)

	return true
end

--- This function returns collision status.
---@return boolean
function Vehicle:IsCollision()
    return self.engine_obj:IsOnGround()
end

return Vehicle