local Vehicle = require("Modules/vehicle.lua")
local Event = require("Modules/event.lua")
local Queue = require("Etc/queue.lua")
local Utils = require("Etc/utils.lua")

local Core = {}
Core.__index = Core

function Core:New()
    -- instance --
    local obj = {}
    obj.log_obj = Log:New()
    obj.log_obj:SetLevel(LogLevel.Info, "Core")
    obj.queue_obj = Queue:New()
    obj.vehicle_obj = nil
    obj.event_obj = nil
    -- static --
    -- move
    obj.max_move_count = 100000
    -- lock
    obj.delay_action_time_in_waiting = 0.05
    obj.delay_action_time_in_vehicle = 0.05
    -- import path
    obj.tank_model_path = "Data/default_model.json"
    obj.tank_input_path = "Data/tank_input.json"
    -- input setting
    obj.axis_dead_zone = 0.5
    obj.relative_dead_zone = 0.01
    obj.hold_progress = 0.9
    -- radio
    obj.default_station_num = 13
    obj.get_track_name_time_resolution = 1
    -- fan speed
    obj.fan_speed_up_value = 0.015
    obj.fan_speed_down_value = 0.005
    -- prevention
    obj.next_stage_count_list = {0, 1, 5, 15, 30}
    obj.re_searching_time_in_level5 = 60
    -- dynamic --
    -- move
    obj.is_move_up_button_hold_counter = false
    obj.move_up_button_hold_count = 0
    obj.is_move_down_button_hold_counter = false
    obj.move_down_button_hold_count = 0
    obj.is_pitch_up_button_hold_counter = false
    obj.pitch_up_button_hold_count = 0
    obj.is_pitch_down_button_hold_counter = false
    obj.pitch_down_button_hold_count = 0
    obj.is_pitch_reset_button_hold_counter = false
    obj.pitch_reset_button_hold_count = 0
    -- lock
    obj.is_locked_action_in_waiting = false
    -- model table
    obj.all_models = nil
    -- input table
    obj.tank_input_table = {}
    obj.relative_table = {}
    obj.hold_time_resolution = 0.1
    obj.radio_hold_complete_time_count = 5
    obj.radio_button_hold_count = 0
    obj.is_radio_button_hold_counter = false
    -- user setting table
    obj.initial_user_setting_table = {}
    -- language table
    obj.language_file_list = {}
    obj.language_name_list = {}
    obj.translation_table_list = {}
    -- summon
    obj.is_vehicle_call = false
    -- radio
    obj.current_station_index = -1
    obj.current_radio_volume = 50
    obj.is_opened_radio_popup = false
    --prevention
    obj.prevention_system = nil
    obj.heat_stage = EStarState.default
    obj.star_state = EPreventionHeatStage.Heat_0
    obj.kill_count_for_prevention = 0
    return setmetatable(obj, self)
end

function Core:Init()

    self.all_models = self:GetAllModel()
    if self.all_models == nil then
        self.log_obj:Record(LogLevel.Error, "Model is nil")
        return
    end

    -- set initial user setting
    self.initial_user_setting_table = FlyingTank.user_setting_table
    self:LoadSetting()
    self:SetTranslationNameList()
    self:StoreTranslationtableList()

    self.tank_input_table = self:GetInputTable(self.tank_input_path)

    self.vehicle_obj = Vehicle:New(self.all_models)
    self.vehicle_obj:Init()

    self.event_obj = Event:New()
    self.event_obj:Init(self.vehicle_obj)

    Cron.Every(FlyingTank.time_resolution, function()
        self.event_obj:CheckAllEvents()
        self:GetActions()
    end)

    -- set observer
    self:SetInputListener()
    self:SetSummonTrigger()
    self:SetRadioPopupController()
    self:SetPreventionObserver()

end

function Core:Reset()
    self.vehicle_obj = Vehicle:New(self.all_models)
    self.vehicle_obj:Init()
    self.event_obj:Init(self.vehicle_obj)
    self.kill_count_for_prevention = 0
end

function Core:LoadSetting()

    local setting_data = Utils:ReadJson(FlyingTank.user_setting_path)
    if setting_data == nil then
        self.log_obj:Record(LogLevel.Error, "Failed to load setting data. Restore default setting")
        Utils:WriteJson(FlyingTank.user_setting_path, FlyingTank.user_setting_table)
        return
    end
    if setting_data.version == FlyingTank.version then
        FlyingTank.user_setting_table = setting_data
    else
        self.log_obj:Record(LogLevel.Info, "Different version detected. Regenerate user_setting.json")
        for key, _ in pairs(self.initial_user_setting_table) do
            if setting_data[key] ~= nil and key ~= "version" then
                FlyingTank.user_setting_table[key] = setting_data[key]
            else
                FlyingTank.user_setting_table[key] = self.initial_user_setting_table[key]
            end
        end
        Utils:WriteJson(FlyingTank.user_setting_path, FlyingTank.user_setting_table)
    end
    self:SetDestructibility(FlyingTank.user_setting_table.is_enable_destory)

end

function Core:ResetSetting()

    FlyingTank.user_setting_table = self.initial_user_setting_table
    self:Reset()

end

function Core:SetSummonTrigger()

    Override("VehicleSystem", "SpawnActivePlayerVehicle", function(this, vehicle_type, wrapped_method)
        local record_id = this:GetActivePlayerVehicle(vehicle_type).recordID

        if TweakDBID.new(FlyingTank.basilisk_aldecaldos_record).hash == record_id.hash then
            self.log_obj:Record(LogLevel.Trace, "Summon Basilisk Aldecaldos")
            FlyingTank.model_index = 1
            FlyingTank.model_type_index = 1

            self.vehicle_obj:Init()
            self.is_vehicle_call = true
            return false
        elseif TweakDBID.new(FlyingTank.basilisk_militech_record).hash == record_id.hash then
            self.log_obj:Record(LogLevel.Trace, "Summon Basilisk Militech")
            FlyingTank.model_index = 2
            FlyingTank.model_type_index = 1

            self.vehicle_obj:Init()
            self.is_vehicle_call = true
            return false
        end
        local res = wrapped_method(vehicle_type)
        self.is_vehicle_call = false
        return res
    end)

end

function Core:GetCallStatus()
    local call_status = self.is_vehicle_call
    self.is_vehicle_call = false
    return call_status
end

function Core:SetTranslationNameList()

    self.language_file_list = {}
    self.language_name_list = {}

    local files = dir(FlyingTank.language_path)
    local default_file
    local other_files = {}

    for _, file in ipairs(files) do
        if string.match(file.name, 'default.json') then
            default_file = file
        elseif string.match(file.name, '%a%a%-%a%a.json') then
            table.insert(other_files, file)
        end
    end

    if default_file then
        local default_language_table = Utils:ReadJson(FlyingTank.language_path .. "/" .. default_file.name)
        if default_language_table and default_language_table.language then
            table.insert(self.language_file_list, default_file)
            table.insert(self.language_name_list, default_language_table.language)
        end
    else
        self.log_obj:Record(LogLevel.Critical, "Default Language File is not found")
        return
    end

    for _, file in ipairs(other_files) do
        local language_table = Utils:ReadJson(FlyingTank.language_path .. "/" .. file.name)
        if language_table and language_table.language then
            table.insert(self.language_file_list, file)
            table.insert(self.language_name_list, language_table.language)
        end
    end

end

function Core:StoreTranslationtableList()

    self.translation_table_list = {}
    for _, file in ipairs(self.language_file_list) do
        local language_table = Utils:ReadJson(FlyingTank.language_path .. "/" .. file.name)
        if language_table then
            table.insert(self.translation_table_list, language_table)
        end
    end

end

function Core:GetTranslationText(text)

    if self.translation_table_list == {} then
        self.log_obj:Record(LogLevel.Critical, "Language File is invalid")
        return nil
    end
    local translated_text = self.translation_table_list[FlyingTank.user_setting_table.language_index][text]
    if translated_text == nil then
        self.log_obj:Record(LogLevel.Warning, "Translation is not found")
        translated_text = self.translation_table_list[1][text]
        if translated_text == nil then
            self.log_obj:Record(LogLevel.Error, "Translation is not found in default language")
            translated_text = "???"
        end
        return translated_text
    end

    return translated_text

end

function Core:SetInputListener()

    local player = Game.GetPlayer()

    local exception_in_veh_list = Utils:ReadJson("Data/exception_in_veh_input.json")
    local exception_radio_list = Utils:ReadJson("Data/exception_radio_input.json")

    Observe("PlayerPuppet", "OnAction", function(this, action, consumer)
        local action_name = action:GetName(action).value
		local action_type = action:GetType(action).value
        local action_value = action:GetValue(action)

        if self.event_obj:IsInVehicle() then
            for _, exception in pairs(exception_in_veh_list) do
                if string.find(action_name, exception) then
                    consumer:Consume()
                    return
                end
            end
        end
        if self:IsOpenedRadioPopup() then
            for _, exception in pairs(exception_radio_list) do
                if string.find(action_name, exception) then
                    consumer:Consume()
                    return
                end
            end
        end

        self.log_obj:Record(LogLevel.Debug, "Action Name: " .. action_name .. " Type: " .. action_type .. " Value: " .. action_value)

        self:StorePlayerAction(action_name, action_type, action_value)

    end)

end

function Core:GetAllModel()

    local model = Utils:ReadJson(self.tank_model_path)
    if model == nil then
        self.log_obj:Record(LogLevel.Error, "Default Model is nil")
        return nil
    end
    return model

end

function Core:GetInputTable(input_path)

    local input = Utils:ReadJson(input_path)
    if input == nil then
        self.log_obj:Record(LogLevel.Error, "Input is nil")
        return nil
    end
    return input

end

function Core:StorePlayerAction(action_name, action_type, action_value)

    local action_value_type = "ZERO"
    if action_type == "RELATIVE_CHANGE" then
        if action_value > self.relative_dead_zone then
            action_value_type = "POSITIVE"
        elseif action_value < -self.relative_dead_zone then
            action_value_type = "NEGATIVE"
        else
            action_value_type = "ZERO"
        end
    elseif action_type == "BUTTON_HOLD_PROGRESS" then
        if action_value > self.hold_progress then
            action_value_type = "POSITIVE"
        else
            action_value_type = "ZERO"
        end
    else
        if action_value > self.axis_dead_zone then
            action_value_type = "POSITIVE"
        elseif action_value < -self.axis_dead_zone then
            action_value_type = "NEGATIVE"
        else
            action_value_type = "ZERO"
        end
    end

    local cmd = 0

    cmd = self:ConvertTankActionList(action_name, action_type, action_value_type)

    if cmd ~= Def.ActionList.Nothing then
        self.queue_obj:Enqueue(cmd)
    end

end

function Core:ConvertTankActionList(action_name, action_type, action_value_type)

    local action_command = Def.ActionList.Nothing
    local action_dist = {name = action_name, type = action_type, value = action_value_type}
    local fan_diff = 0

    if Utils:IsTablesNearlyEqual(action_dist, self.tank_input_table.KEY_TANK_LEFT_MOVE) then
        fan_diff = self.fan_speed_up_value
    elseif Utils:IsTablesNearlyEqual(action_dist, self.tank_input_table.KEY_TANK_RIGHT_MOVE) then
        fan_diff = self.fan_speed_up_value
    elseif Utils:IsTablesNearlyEqual(action_dist, self.tank_input_table.KEY_TANK_FORWARD_MOVE) then
        fan_diff = self.fan_speed_up_value
    elseif Utils:IsTablesNearlyEqual(action_dist, self.tank_input_table.KEY_TANK_BACK_MOVE) then
        fan_diff = self.fan_speed_up_value
    elseif Utils:IsTablesNearlyEqual(action_dist, self.tank_input_table.KEY_TANK_LEFT_ROTATE) then
        fan_diff = self.fan_speed_up_value
    elseif Utils:IsTablesNearlyEqual(action_dist, self.tank_input_table.KEY_TANK_RIGHT_ROTATE) then
        fan_diff = self.fan_speed_up_value
    elseif Utils:IsTablesNearlyEqual(action_dist, self.tank_input_table.MOUSE_TANK_LEFT_ROTATE) then
        fan_diff = self.fan_speed_up_value
    elseif Utils:IsTablesNearlyEqual(action_dist, self.tank_input_table.MOUSE_TANK_RIGHT_ROTATE) then
        fan_diff = self.fan_speed_up_value
    end

    if self.event_obj.hud_obj.fan_speed + fan_diff <= 100 and self.event_obj.hud_obj.fan_speed + fan_diff >= 0 then
        self.event_obj.hud_obj.fan_speed = self.event_obj.hud_obj.fan_speed + fan_diff
    end

    return action_command

end

function Core:ConvertReleaseButtonAction(key)
    local keybind_name = ""
    for _, keybind in ipairs(FlyingTank.user_setting_table.keybind_table) do
        if key == keybind.key or key == keybind.pad then
            keybind_name = keybind.name
            break
        end
    end
    if keybind_name == "toggle_radio" then
        self.is_radio_button_hold_counter = false
        self.radio_button_hold_count = 0
    elseif keybind_name == "move_up" then
        self.is_move_up_button_hold_counter = false
        self.move_up_button_hold_count = 0
    elseif keybind_name == "move_down" then
        self.is_move_down_button_hold_counter = false
        self.move_down_button_hold_count = 0
    elseif keybind_name == "pitch_up" then
        self.is_pitch_up_button_hold_counter = false
        self.pitch_up_button_hold_count = 0
    elseif keybind_name == "pitch_down" then
        self.is_pitch_down_button_hold_counter = false
        self.pitch_down_button_hold_count = 0
    elseif keybind_name == "pitch_reset" then
        self.is_pitch_reset_button_hold_counter = false
        self.pitch_reset_button_hold_count = 0
    end
end

function Core:ConvertPressButtonAction(key)
    local keybind_name = ""
    for _, keybind in ipairs(FlyingTank.user_setting_table.keybind_table) do
        if key == keybind.key or key == keybind.pad then
            keybind_name = keybind.name
            break
        end
    end
    local action_list = Def.ActionList.Nothing
    if keybind_name == "move_up" then
        if not self.is_move_up_button_hold_counter then
            self.is_move_up_button_hold_counter = true
            Cron.Every(FlyingTank.time_resolution, {tick=0}, function(timer)
                timer.tick = timer.tick + 1
                self.move_up_button_hold_count = timer.tick
                if timer.tick >= self.max_move_count then
                    self.is_move_up_button_hold_counter = false
                    Cron.Halt(timer)
                elseif not self.is_move_up_button_hold_counter then
                    Cron.Halt(timer)
                else
                    self.queue_obj:Enqueue(Def.ActionList.Up)
                end
            end)
        end
    elseif keybind_name == "move_down" then
        if not self.is_move_down_button_hold_counter then
            self.is_move_down_button_hold_counter = true
            Cron.Every(FlyingTank.time_resolution, {tick=0}, function(timer)
                timer.tick = timer.tick + 1
                self.move_down_button_hold_count = timer.tick
                if timer.tick >= self.max_move_count then
                    self.is_move_down_button_hold_counter = false
                    Cron.Halt(timer)
                elseif not self.is_move_down_button_hold_counter then
                    Cron.Halt(timer)
                else
                    self.queue_obj:Enqueue(Def.ActionList.Down)
                end
            end)
        end
    elseif keybind_name == "pitch_up" then
        if not self.is_pitch_up_button_hold_counter then
            self.is_pitch_up_button_hold_counter = true
            Cron.Every(FlyingTank.time_resolution, {tick=0}, function(timer)
                timer.tick = timer.tick + 1
                self.pitch_up_button_hold_count = timer.tick
                if timer.tick >= self.max_move_count then
                    self.is_pitch_up_button_hold_counter = false
                    Cron.Halt(timer)
                elseif not self.is_pitch_up_button_hold_counter then
                    Cron.Halt(timer)
                else
                    self.queue_obj:Enqueue(Def.ActionList.PitchUp)
                end
            end)
        end
    elseif keybind_name == "pitch_down" then
        if not self.is_pitch_down_button_hold_counter then
            self.is_pitch_down_button_hold_counter = true
            Cron.Every(FlyingTank.time_resolution, {tick=0}, function(timer)
                timer.tick = timer.tick + 1
                self.pitch_down_button_hold_count = timer.tick
                if timer.tick >= self.max_move_count then
                    self.is_pitch_down_button_hold_counter = false
                    Cron.Halt(timer)
                elseif not self.is_pitch_down_button_hold_counter then
                    Cron.Halt(timer)
                else
                    self.queue_obj:Enqueue(Def.ActionList.PitchDown)
                end
            end)
        end
    elseif keybind_name == "pitch_reset" then
        if not self.is_pitch_reset_button_hold_counter then
            self.is_pitch_reset_button_hold_counter = true
            Cron.Every(FlyingTank.time_resolution, {tick=0}, function(timer)
                timer.tick = timer.tick + 1
                self.pitch_reset_button_hold_count = timer.tick
                if timer.tick >= self.max_move_count then
                    self.is_pitch_reset_button_hold_counter = false
                    Cron.Halt(timer)
                elseif not self.is_pitch_reset_button_hold_counter then
                    Cron.Halt(timer)
                else
                    self.queue_obj:Enqueue(Def.ActionList.PitchReset)
                end
            end)
        end
    elseif keybind_name == "toggle_door" then
        action_list = Def.ActionList.ChangeDoor
    elseif keybind_name == "toggle_radio" then
        if not self.is_radio_button_hold_counter then
            self.is_radio_button_hold_counter = true
            Cron.Every(self.hold_time_resolution, {tick=0}, function(timer)
                timer.tick = timer.tick + 1
                self.radio_button_hold_count = timer.tick
                if timer.tick >= self.radio_hold_complete_time_count then
                    self.is_radio_button_hold_counter = false
                    self.queue_obj:Enqueue(Def.ActionList.OpenRadio)
                    Cron.Halt(timer)
                elseif not self.is_radio_button_hold_counter then
                    self.queue_obj:Enqueue(Def.ActionList.ToggleRadio)
                    Cron.Halt(timer)
                end
            end)
        end
    end

    if action_list ~= Def.ActionList.Nothing then
        self.queue_obj:Enqueue(action_list)
    end
end

function Core:GetActions()

    local move_actions = {}

    if self.event_obj:IsInMenuOrPopupOrPhoto() then
        self.queue_obj:Clear()
        return
    end

    while not self.queue_obj:IsEmpty() do
        local action = self.queue_obj:Dequeue()
        if action >= Def.ActionList.ChangeDoor then
            self:SetEvent(action)
        else
            table.insert(move_actions, action)
        end
    end

    if #move_actions == 0 then
        table.insert(move_actions, Def.ActionList.Nothing)
    end

    self:OperateVehicle(move_actions)

    -- fan speed down
    if self.event_obj.hud_obj.fan_speed - self.fan_speed_down_value >= 0 then
        self.event_obj.hud_obj.fan_speed = self.event_obj.hud_obj.fan_speed - self.fan_speed_down_value
    end

end

function Core:OperateVehicle(actions)

    if not self.is_locked_operation then
        if self.event_obj:IsInVehicle() then
            self.vehicle_obj:Operate(actions)
        elseif self.event_obj:IsWaiting() then
            self.vehicle_obj:Operate({Def.ActionList.Idle})
        end
    end

end

function Core:SetEvent(action)

    if self.event_obj.current_situation == Def.Situation.InVehicle then
        if action == Def.ActionList.ChangeDoor then
            self:ToggleDoors()
        elseif action == Def.ActionList.ToggleRadio then
            self:ToggleRadio()
        elseif action == Def.ActionList.OpenRadio then
            self:OpenRadioPort()
        end
    end

end

function Core:ToggleDoors()
    if self.event_obj:IsInVehicle() and not self.event_obj:IsInMenuOrPopupOrPhoto() then
        self.event_obj:ChangeDoor()
    end
end

function Core:SetRadioPopupController()

    ObserveAfter('VehicleRadioPopupGameController', 'Activate', function(this)
        if self.event_obj:IsInVehicle() then
            self.current_station_index = this.selectedItem:GetStationData().record:Index()
            if self.current_station_index >= 0 and self.current_station_index <= self.default_station_num then
                self.current_radio_volume = this.radioVolumeSettingsController.value:GetText()
                self.vehicle_obj.radio_obj:Update(self.current_station_index, self.current_radio_volume)
            else
                self.vehicle_obj.radio_obj:Stop()
            end
        end
    end)

    ObserveAfter('RadioVolumeSettingsController', 'ChangeValue', function(this)
        if self.event_obj:IsInVehicle() then
            if self.current_station_index <= self.default_station_num then
                local prev_radio_volume = self.current_radio_volume
                self.current_radio_volume = this.value:GetText()
                if prev_radio_volume ~= "0%" then
                    self.vehicle_obj.radio_obj:SetVolumeFromString(self.current_radio_volume)
                elseif self.current_station_index >= 0 and self.current_station_index <= self.default_station_num then
                    self.vehicle_obj.radio_obj:Update(self.current_station_index, self.current_radio_volume)
                end
            end
        end
    end)

    ObserveAfter('VehicleRadioPopupGameController', 'OnInitialize', function(this)
        if self.event_obj:IsInVehicle() then
            self.is_opened_radio_popup = true
            Cron.Every(self.get_track_name_time_resolution, {tick = 1}, function(timer)
                local lockey = self.vehicle_obj.radio_obj:GetTrackName()
                if lockey ~= nil and this.trackName ~= nil then
                    this.trackName:SetLocalizationKey(lockey)
                end
                if not self.is_opened_radio_popup or not self.event_obj:IsInVehicle() then
                    self.log_obj:Record(LogLevel.Info, "Radio Popup is closed")
                    Cron.Halt(timer)
                end
            end)
        end
    end)

    ObserveAfter('VehicleRadioPopupGameController', 'OnClose', function(this)
        self.is_opened_radio_popup = false
    end)

end

function Core:ToggleRadio()

    if self.event_obj:IsInVehicle() and not self.event_obj:IsInMenuOrPopupOrPhoto() then
        if self.current_station_index >= 0 and self.current_station_index <= self.default_station_num then
            if self.vehicle_obj.radio_obj:IsPlaying() then
                self.vehicle_obj.radio_obj:Stop()
            else
                -- self.current_station_index = math.random(0, self.default_station_num)
                self.vehicle_obj.radio_obj:Update(self.current_station_index, self.current_radio_volume)
            end
        else
            self.log_obj:Record(LogLevel.Info, "Selected station is RadioEXT Station")
            self.event_obj:ShowRadioPopup()
        end
    end

end

function Core:OpenRadioPort()
    if self.event_obj:IsInVehicle() and not self.event_obj:IsInMenuOrPopupOrPhoto() then
        self.event_obj:ShowRadioPopup()
    end
end

---@return boolean
function Core:IsOpenedRadioPopup()
    return self.is_opened_radio_popup
end

function Core:ShowRadioPopup()
    self.event_obj:ShowRadioPopup()
end

function Core:GetCurrentDistrict()

    local current_district_list = {}
    local district_manager = Game.GetScriptableSystemsContainer():Get('PreventionSystem').districtManager
    local district = district_manager:GetCurrentDistrict()
    if district == nil then
        return current_district_list
    end
    local district_record = district:GetDistrictRecord()
    if district_record ~= nil then
        repeat
            table.insert(current_district_list, 1, GetLocalizedText(district_record:LocalizedName()))
            district_record = district_record:ParentDistrict()
        until district_record == nil
    end
    return current_district_list

end

-- prevention system
function Core:SetPreventionObserver()

    Observe("PreventionSystem", "ChangeHeatStage", function(this, heat_stage, reason)
        if heat_stage == EPreventionHeatStage.Heat_0 then
            self.kill_count_for_prevention = 0
        end
    end)

    Cron.Every(0.1, {tick=1}, function(timer)
        local prevention_system = Game.GetScriptableSystemsContainer():Get('PreventionSystem')
        timer.tick = timer.tick + 1
        local player = Game.GetPlayer()
        if player == nil then
            return
        end
        local mounted_vehicle_obj = Game.GetMountedVehicle(player)
        if mounted_vehicle_obj == nil or self.vehicle_obj.entity_id == nil then
            return
        elseif mounted_vehicle_obj:GetEntityID().hash ~= self.vehicle_obj.entity_id.hash then
            return
        end
        self.star_state = prevention_system:GetStarState()
        self.heat_stage = prevention_system:GetHeatStage()
        self.log_obj:Record(LogLevel.Debug, "Kill Count For Prevention: " .. self.kill_count_for_prevention)

        if self.heat_stage == EPreventionHeatStage.Heat_0 then
            if self.kill_count_for_prevention > self.next_stage_count_list[1] then
                -- self:SetPreventionSpawning(prevention_system)
                prevention_system:ChangeHeatStage(EPreventionHeatStage.Heat_1, "KillCivilian")
            end
        elseif self.heat_stage == EPreventionHeatStage.Heat_1 then
            self.log_obj:Record(LogLevel.Info, "Prevention Heat_1")
            if self.kill_count_for_prevention > self.next_stage_count_list[2] then
                -- self:SetPreventionSpawning(prevention_system)
                prevention_system:ChangeHeatStage(EPreventionHeatStage.Heat_2, "KillCivilian")
            end
        elseif self.heat_stage == EPreventionHeatStage.Heat_2 then
            self.log_obj:Record(LogLevel.Info, "Prevention Heat_2")
            if self.kill_count_for_prevention > self.next_stage_count_list[3] then
                -- self:SetPreventionSpawning(prevention_system)
                prevention_system:ChangeHeatStage(EPreventionHeatStage.Heat_3, "KillCivilian")
            end
        elseif self.heat_stage == EPreventionHeatStage.Heat_3 then
            self.log_obj:Record(LogLevel.Info, "Prevention Heat_3")
            if self.kill_count_for_prevention > self.next_stage_count_list[4] then
                -- self:SetPreventionSpawning(prevention_system)
                prevention_system:ChangeHeatStage(EPreventionHeatStage.Heat_4, "KillCivilian")
            end
        elseif self.heat_stage == EPreventionHeatStage.Heat_4 then
            self.log_obj:Record(LogLevel.Info, "Prevention Heat_4")
            if self.kill_count_for_prevention > self.next_stage_count_list[5] then
                -- self:SetPreventionSpawning(prevention_system)
                prevention_system:ChangeHeatStage(EPreventionHeatStage.Heat_5, "KillCivilian")
            end
        elseif self.heat_stage == EPreventionHeatStage.Heat_5 then
            self.log_obj:Record(LogLevel.Info, "Prevention Heat_5")

        end
    end)

end

function Core:SetPreventionSpawning(prevention_system)

    local police_agent_registry = prevention_system:GetAgentRegistry()
    local prevention_spawn_system = Game.GetPreventionSpawnSystem()
    prevention_spawn_system:CancelAllSpawnRequests()
    prevention_spawn_system:TogglePreventionActive(true)
    local player = Game.GetPlayer()
    local player_pos = player:GetWorldPosition()
    local police_transform = WorldTransform.new()
    local npcs = player:GetNPCsAroundObject()
    local min_distance = 100
    local min_index = 0
    for index, npc in ipairs(npcs) do
        local npc_pos = npc:GetWorldPosition()
        local distnce = Vector4.Distance(player_pos, npc_pos)
        if distnce < min_distance then
            min_distance = distnce
            min_index = index
        end
    end
    local spawn_point = npcs[min_index]:GetWorldPosition()
    police_transform:SetPosition(spawn_point)
    local police_unit_num = prevention_spawn_system:RequestUnitSpawn(TweakDBID.new("Character.prevention_police_handgun_ma"), police_transform)
    police_agent_registry:CreateTicket(police_unit_num, vehiclePoliceStrategy.SearchFromAnywhere, true)

    prevention_system:SetLastKnownPlayerPosition(player_pos)

end

function Core:SetDestructibility(enable)

    local tweek_db_tag_list = {CName.new("InteractiveTrunk")}
	if not enable then
		table.insert(tweek_db_tag_list, CName.new("Immortal"))
        TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_aldecaldos_fly_record .. ".destruction"), "Vehicle.TankDestructionParamsNone")
        TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_militech_fly_record .. ".destruction"), "Vehicle.TankDestructionParamsNone")
    else
        TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_aldecaldos_fly_record .. ".destruction"), "Vehicle.v_militech_basilisk_inline0")
        TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_militech_fly_record .. ".destruction"), "Vehicle.v_militech_basilisk_inline0")
    end
    TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_aldecaldos_fly_record .. ".tags"), tweek_db_tag_list)
    TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_militech_fly_record .. ".tags"), tweek_db_tag_list)

end

return Core