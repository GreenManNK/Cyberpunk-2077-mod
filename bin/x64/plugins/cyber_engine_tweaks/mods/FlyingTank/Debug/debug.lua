local Utils = require("Etc/utils.lua")
local Debug = {}
Debug.__index = Debug

function Debug:New(core_obj)
    local obj = {}
    obj.core_obj = core_obj

    -- set parameters
    obj.is_set_observer = false
    obj.is_im_gui_rw_count = false
    obj.is_im_gui_vehicle_info = false
    obj.is_im_gui_situation = false
    obj.is_im_gui_player_position = false
    obj.is_im_gui_tank_position = false
    obj.is_im_gui_engine_info = false
    obj.is_im_gui_sound_check = false
    obj.selected_sound = "100_call_vehicle"
    obj.is_im_gui_radio_info = false

    return setmetatable(obj, self)
end

function Debug:ImGuiMain()

    ImGui.Begin("FlyingTank DEBUG WINDOW")
    ImGui.Text("Debug Mode : On")

    self:SetObserver()
    self:SetLogLevel()
    self:SelectPrintDebug()
    self:ImGuiShowRWCount()
    self:ImGuiVehicleInfo()
    self:ImGuiSituation()
    self:ImGuiPlayerPosition()
    self:ImGuiTankPosition()
    self:ImGuiSoundCheck()
    self:ImGuiRadioInfo()
    self:ImGuiExcuteFunction()

    ImGui.End()

end

function Debug:SetObserver()

    if not self.is_set_observer then
        -- reserved    
    end
    self.is_set_observer = true

    if self.is_set_observer then
        ImGui.SameLine()
        ImGui.Text("Observer : On")
    end

end

function Debug:SetLogLevel()
    local selected = false
    if ImGui.BeginCombo("LogLevel", Utils:GetKeyFromValue(LogLevel, MasterLogLevel)) then
		for _, key in ipairs(Utils:GetKeys(LogLevel)) do
			if Utils:GetKeyFromValue(LogLevel, MasterLogLevel) == key then
				selected = true
			else
				selected = false
			end
			if(ImGui.Selectable(key, selected)) then
				MasterLogLevel = LogLevel[key]
			end
		end
		ImGui.EndCombo()
	end
end

function Debug:SelectPrintDebug()
    PrintDebugMode = ImGui.Checkbox("Print Debug Mode", PrintDebugMode)
end

function Debug:ImGuiShowRWCount()
    self.is_im_gui_rw_count = ImGui.Checkbox("[ImGui] R/W Count", self.is_im_gui_rw_count)
    if self.is_im_gui_rw_count then
        ImGui.Text("Read : " .. READ_COUNT .. ", Write : " .. WRITE_COUNT)
    end
end

function Debug:ImGuiVehicleInfo()
    self.is_im_gui_vehicle_info = ImGui.Checkbox("[ImGui] Vehicle Info", self.is_im_gui_vehicle_info)
    if self.is_im_gui_vehicle_info then
        if self.core_obj.vehicle_obj == nil then
            return
        end
        local left_door_state = self.core_obj.vehicle_obj:GetDoorState(EVehicleDoor.seat_front_left)
        ImGui.Text("Door State : " .. tostring(left_door_state) )
        if self.core_obj.vehicle_obj.engine_obj.fly_tank_system == nil then
            return
        end
        if self.core_obj.vehicle_obj.engine_obj.fly_tank_system:IsOnGround() then
            ImGui.Text("On Ground")
        else
            ImGui.Text("In Air")
        end
        ImGui.Text("Phy State: " .. tostring(self.core_obj.vehicle_obj.engine_obj.fly_tank_system:GetPhysicsState()))
        if self.core_obj.vehicle_obj.engine_obj.fly_tank_system:HasGravity() then
            ImGui.Text("Gravity : On")
        else
            ImGui.Text("Gravity : Off")
        end
        local speed = self.core_obj.vehicle_obj.engine_obj.fly_tank_system:GetVelocity()
        local speed_x = string.format("%.2f", speed.x)
        local speed_y = string.format("%.2f", speed.y)
        local speed_z = string.format("%.2f", speed.z)
        ImGui.Text("Speed : X:" .. speed_x .. ", Y:" .. speed_y .. ", Z:" .. speed_z)
        local force = self.core_obj.vehicle_obj.engine_obj.fly_tank_system:GetForce()
        local force_x = string.format("%.2f", force.x)
        local force_y = string.format("%.2f", force.y)
        local force_z = string.format("%.2f", force.z)
        ImGui.Text("Force : X:" .. force_x .. ", Y:" .. force_y .. ", Z:" .. force_z)

    end
end

function Debug:ImGuiSituation()
    self.is_im_gui_situation = ImGui.Checkbox("[ImGui] Current Situation", self.is_im_gui_situation)
    if self.is_im_gui_situation then
        ImGui.Text("Current Situation : " .. self.core_obj.event_obj.current_situation)
    end
end

function Debug:ImGuiPlayerPosition()
    self.is_im_gui_player_position = ImGui.Checkbox("[ImGui] Player Position Angle", self.is_im_gui_player_position)
    if self.is_im_gui_player_position then
        local x = string.format("%.2f", Game.GetPlayer():GetWorldPosition().x)
        local y = string.format("%.2f", Game.GetPlayer():GetWorldPosition().y)
        local z = string.format("%.2f", Game.GetPlayer():GetWorldPosition().z)
        ImGui.Text("[world]X:" .. x .. ", Y:" .. y .. ", Z:" .. z)
        local roll = string.format("%.2f", Game.GetPlayer():GetWorldOrientation():ToEulerAngles().roll)
        local pitch = string.format("%.2f", Game.GetPlayer():GetWorldOrientation():ToEulerAngles().pitch)
        local yaw = string.format("%.2f", Game.GetPlayer():GetWorldOrientation():ToEulerAngles().yaw)
        ImGui.Text("[world]Roll:" .. roll .. ", Pitch:" .. pitch .. ", Yaw:" .. yaw)
    end
end

function Debug:ImGuiTankPosition()
    self.is_im_gui_tank_position = ImGui.Checkbox("[ImGui] Tank Position Angle", self.is_im_gui_tank_position)
    if self.is_im_gui_tank_position then
        if self.core_obj.vehicle_obj.entity_id == nil then
            return
        end
        local x = string.format("%.2f", self.core_obj.vehicle_obj:GetPosition().x)
        local y = string.format("%.2f", self.core_obj.vehicle_obj:GetPosition().y)
        local z = string.format("%.2f", self.core_obj.vehicle_obj:GetPosition().z)
        ImGui.Text("X: " .. x .. ", Y: " .. y .. ", Z: " .. z)
    end
end

function Debug:ImGuiSoundCheck()
    self.is_im_gui_sound_check = ImGui.Checkbox("[ImGui] Sound Check", self.is_im_gui_sound_check)
    if self.is_im_gui_sound_check then
        if ImGui.BeginCombo("##Sound List", self.selected_sound) then
            for key, _ in pairs(self.core_obj.event_obj.sound_obj.sound_data) do
                if (ImGui.Selectable(key, (self.selected_sound==key))) then
                    self.selected_sound = key
                end
            end
            ImGui.EndCombo()
        end

        if ImGui.Button("Play", 150, 60) then
            self.core_obj.event_obj.sound_obj:PlaySound(self.selected_sound)
        end

        if ImGui.Button("Stop", 150, 60) then
            self.core_obj.event_obj.sound_obj:StopSound(self.selected_sound)
        end
    end
end

function Debug:ImGuiRadioInfo()
    self.is_im_gui_radio_info = ImGui.Checkbox("[ImGui] Radio Info", self.is_im_gui_radio_info)
    if self.is_im_gui_radio_info then
        local volume = self.core_obj.vehicle_obj.radio_obj:GetVolume()
        local entity_num = #self.core_obj.vehicle_obj.radio_obj.radio_entity_list
        local station_index = self.core_obj.vehicle_obj.radio_obj:GetPlayingStationIndex()
        local station_name = CName("No Play")
        if station_index >= 0 then
            station_name = RadioStationDataProvider.GetStationNameByIndex(station_index)
        end
        local track_name = GetLocalizedText(LocKeyToString(self.core_obj.vehicle_obj.radio_obj:GetTrackName()))
        local is_playing = self.core_obj.vehicle_obj.radio_obj.is_playing
        local is_opened_radio_popup = self.core_obj.is_opened_radio_popup
        local radio_port_index = self.core_obj.current_station_index
        local radio_port_volume = self.core_obj.current_radio_volume
        ImGui.Text("Radio Port Index : " .. radio_port_index .. ", Radio Port Volume : " .. radio_port_volume)
        ImGui.Text("Actual Volume : " .. volume .. ", Entity Num : " .. entity_num)
        ImGui.Text("Actual Station Index : " .. station_index .. ", Station Name : " .. station_name.value)
        ImGui.Text("Track Name : " .. track_name)
        ImGui.Text("Is Playing : " .. tostring(is_playing) .. ", Is Radio Popup : " .. tostring(is_opened_radio_popup))
    end
end

function Debug:ImGuiExcuteFunction()
    if ImGui.Button("TF1") then
        local sys = self.core_obj.vehicle_obj.engine_obj.fly_tank_system
        print("Excute Test Function 1")
    end
    ImGui.SameLine()
    if ImGui.Button("TF2") then
        local sys = self.core_obj.vehicle_obj.engine_obj.fly_tank_system
        sys:UnsetPhysicsState()
        print("Excute Test Function 2")
    end
    ImGui.SameLine()
    if ImGui.Button("TF3") then
        local entity = self.core_obj.vehicle_obj.engine_obj.entity
        entity:TurnEngineOn(true)
        print("Excute Test Function 3")
    end
    ImGui.SameLine()
    if ImGui.Button("TF4") then
        local entity = self.core_obj.vehicle_obj.engine_obj.entity
        GameObjectEffectHelper.StopEffectEvent(entity, CName.new("exhaust_start"))
        print("Excute Test Function 4")
    end
end


return Debug
