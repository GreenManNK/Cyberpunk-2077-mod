--------------------------------------------------------
-- CopyRight (C) 2024, tidusmd. All rights reserved.
-- This mod is under the MIT License.
-- https://opensource.org/licenses/mit-license.php
--------------------------------------------------------

Cron = require('External/Cron.lua')
Def = require("Etc/def.lua")
Log = require("Etc/log.lua")

local Core = require('Modules/core.lua')
local Debug = require('Debug/debug.lua')

FlyingTank = {
	description = "Flying Tank - Enhanced Militech Basilisk",
	version = "1.2.2",
    -- system
    is_ready = false,
    time_resolution = 0.01,
    is_debug_mode = false,
    -- common
    user_setting_path = "Data/user_setting.json",
    language_path = "Language",
    -- grobal index
    model_index = 1,
	model_type_index = 1,
    -- vehicle record
    basilisk_aldecaldos_fly_record = "Vehicle.v_militech_basilisk_fly",
    basilisk_militech_fly_record = "Vehicle.v_militech_basilisk_militech_fly",
    basilisk_aldecaldos_record = "Vehicle.basilisk_aldecaldos",
    basilisk_militech_record = "Vehicle.basilisk_militech",
    -- version check
    cet_required_version = 37.1, -- 1.37.1
    cet_recommended_version = 37.1, -- 1.37.1
    codeware_required_version = 18.0, -- 1.18.0
    codeware_recommended_version = 18.0, -- 1.18.0
    native_settings_required_version = 1.96,
    cet_version_num = 0,
    codeware_version_num = 0,
    native_settings_version_num = 0,
    -- setting
    is_valid_native_settings = false,
    NativeSettings = nil,
    -- input
    input_listener = nil,
    listening_keybind_widget = nil,
    default_keybind_table = {
        {name = "move_up", key = "IK_R", pad = "IK_Pad_Y_TRIANGLE"},
        {name = "move_down", key = "IK_C", pad = "IK_Pad_A_CROSS"},
        {name = "pitch_up", key = "IK_V", pad = "IK_Pad_DigitDown"},
        {name = "pitch_down", key = "IK_T", pad = "IK_Pad_DigitUp"},
        {name = "pitch_reset", key = "IK_G", pad = "IK_Pad_X_SQUARE"},
        {name = "toggle_door", key = "IK_X", pad = "IK_Pad_DigitLeft"},
        {name = "toggle_radio", key = "IK_Z", pad = "IK_Pad_LeftShoulder"},
    },
    -- HUD
    is_active_hud = true,
    -- general
    is_enable_destory = true,
}

-- initial settings
FlyingTank.user_setting_table = {
    -- info
    version = FlyingTank.version,
    --- general
    language_index = 1,
    hud_mode = 1, -- #1: District, #2: KillCounter
    is_active_hud = true,
    is_enable_destory = true,
    is_mute_all = false, -- hidden
    is_mute_flight = false, -- hidden
    --- input
    keybind_table = FlyingTank.default_keybind_table
}

-- set custom vehicle record
registerForEvent("onTweak",function ()

    -- Icon
    if TweakDB:GetRecord("UIIcon.basilisk_dummy") == nil then
        TweakDB:CloneRecord("UIIcon.basilisk_dummy", "UIIcon.quadra_sport_r7_chiaroscuro")
    end
    TweakDB:SetFlat(TweakDBID.new("UIIcon.basilisk_dummy.atlasResourcePathacturer"), "base/gameplay/gui/common/icons/weapon_manufacturers.inkatlas")
    TweakDB:SetFlat(TweakDBID.new("UIIcon.basilisk_dummy.icon.atlasPartName"), "militech_l")

    -- Vehicle Parameters
    if TweakDB:GetRecord("Vehicle.v_militech_basilisk_inline5_fly") == nil then
        TweakDB:CloneRecord("Vehicle.v_militech_basilisk_inline5_fly", "Vehicle.v_militech_basilisk_inline5")
    end
    TweakDB:SetFlat(TweakDBID.new("Vehicle.v_militech_basilisk_inline5_fly.tankGravityMul"), 0)
    TweakDB:SetFlat(TweakDBID.new("Vehicle.v_militech_basilisk_inline5_fly.tankMaxSpeed"), 58) -- do not increase over 100
    TweakDB:SetFlat(TweakDBID.new("Vehicle.v_militech_basilisk_inline5_fly.tankAcceleration"), 30)
    TweakDB:SetFlat(TweakDBID.new("Vehicle.v_militech_basilisk_inline5_fly.tankDeceleration"), 15)

    -- Custom Aldecaldos Basilisk Record
    if TweakDB:GetRecord(FlyingTank.basilisk_aldecaldos_fly_record) == nil then
        TweakDB:CloneRecord(FlyingTank.basilisk_aldecaldos_fly_record, "Vehicle.v_militech_basilisk")
    end
    TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_aldecaldos_fly_record .. ".entityTemplatePath"), "base/vehicles/special/v_militech_basilisk_01__basic_01_fly.ent")
    TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_aldecaldos_fly_record .. ".tankDriveModelData"), "Vehicle.v_militech_basilisk_inline5_fly")

    -- Custom Militech Basilisk Record
    if TweakDB:GetRecord(FlyingTank.basilisk_militech_fly_record) == nil then
        TweakDB:CloneRecord(FlyingTank.basilisk_militech_fly_record, "Vehicle.v_militech_basilisk_militech")
    end
    TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_militech_fly_record .. ".entityTemplatePath"), "base/vehicles/special/v_militech_basilisk_01__basic_01_fly.ent")
    TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_militech_fly_record ..".tankDriveModelData"), "Vehicle.v_militech_basilisk_inline5_fly")

    -- Destruction Dummy Parameters
    if TweakDB:GetRecord("Vehicle.TankDestructionParamsNone") == nil then
        TweakDB:CreateRecord("Vehicle.TankDestructionParamsNone", "gamedataVehicleDestruction_Record")
    end

    -- Tpp Camera Parameters
    if TweakDB:GetRecord("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Close_fly") == nil then
        TweakDB:CloneRecord("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Close_fly", "Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Close")
    end
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Close_fly.baseBoomLength"), 6)
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Close_fly.boomLengthOffset"), 2)
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Close_fly.lookAtOffset"), Vector3.new(0, 2, 5.75))

    if TweakDB:GetRecord("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Medium_fly") == nil then
        TweakDB:CloneRecord("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Medium_fly", "Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Medium")
    end
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Medium_fly.baseBoomLength"), 6)
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Medium_fly.boomLengthOffset"), 5)
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Medium_fly.lookAtOffset"), Vector3.new(0, 2, 5.75))

    if TweakDB:GetRecord("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Far_fly") == nil then
        TweakDB:CloneRecord("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Far_fly", "Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Far")
    end
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Far_fly.baseBoomLength"), 6)
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Far_fly.boomLengthOffset"), 10)
    TweakDB:SetFlat(TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Far_fly.lookAtOffset"), Vector3.new(0, 2, 5.75))

     local tpp_camera_list = {TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Close_fly"),
                              TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Medium_fly"),
                              TweakDBID.new("Vehicle.VehicleTPP_v_militech_basilisk_CameraPreset_High_Far_fly")}
    TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_aldecaldos_fly_record .. ".tppCameraPresets"), tpp_camera_list)
    TweakDB:SetFlat(TweakDBID.new(FlyingTank.basilisk_militech_fly_record .. ".tppCameraPresets"), tpp_camera_list)

end)

registerForEvent("onHook", function ()

    -- refer to https://www.nexusmods.com/cyberpunk2077/mods/8326
    FlyingTank.input_listener = NewProxy({
        OnKeyInput = {
            args = {'handle:KeyInputEvent'},
            callback = function(event)
                local key = event:GetKey().value
                local action = event:GetAction().value
                if FlyingTank.listening_keybind_widget and key:find("IK_Pad") and action == "IACT_Release" then -- OnKeyBindingEvent has to be called manually for gamepad inputs, while there is a keybind widget listening for input
                    FlyingTank.listening_keybind_widget:OnKeyBindingEvent(KeyBindingEvent.new({keyName = key}))
                    FlyingTank.listening_keybind_widget = nil
                elseif FlyingTank.listening_keybind_widget and action == "IACT_Release" then -- Key was bound, by keyboard
                    FlyingTank.listening_keybind_widget = nil
                end
                if FlyingTank.core_obj ~= nil and FlyingTank.core_obj.event_obj.current_situation == Def.Situation.InVehicle then
                    if action == "IACT_Press" then
                        FlyingTank.core_obj:ConvertPressButtonAction(key)
                    elseif action == "IACT_Release" then
                        FlyingTank.core_obj:ConvertReleaseButtonAction(key)
                    end
                end
            end
        }
    })
    Game.GetCallbackSystem():RegisterCallback('Input/Key', FlyingTank.input_listener:Target(), FlyingTank.input_listener:Function("OnKeyInput"), true)
    Observe("SettingsSelectorControllerKeyBinding", "ListenForInput", function(this)
        FlyingTank.listening_keybind_widget = this
    end)

end)

registerForEvent('onInit', function()

    if not FlyingTank:CheckDependencies() then
        print('[FlyTank][Error] Drive an Aerial Vehicle Mod failed to load due to missing dependencies.')
        return
    end

    FlyingTank:CheckNativeSettings()

    FlyingTank.core_obj = Core:New()
    FlyingTank.debug_obj = Debug:New(FlyingTank.core_obj)

    FlyingTank.core_obj:Init()

    FlyingTank.is_ready = true

    print('[FlyTank][Info] Finished initializing Flying Tank Mod.')

end)

registerForEvent("onDraw", function()
    if FlyingTank.is_debug_mode then
        FlyingTank.debug_obj:ImGuiMain()
    end
end)

registerForEvent('onUpdate', function(delta)
    Cron.Update(delta)
    if FlyingTank.core_obj.vehicle_obj.engine_obj == nil then
        return
    end
    FlyingTank.core_obj.vehicle_obj.engine_obj:Update(delta)
end)

registerForEvent('onShutdown', function()
    Game.GetCallbackSystem():UnregisterCallback('Input/Key', FlyingTank.input_listener:Target(), FlyingTank.input_listener:Function("OnKeyInput"))
end)

function FlyingTank:CheckDependencies()

    -- Check Cyber Engine Tweaks Version
    local cet_version_str = GetVersion()
    local cet_version_major, cet_version_minor = cet_version_str:match("1.(%d+)%.*(%d*)")
    FlyingTank.cet_version_num = tonumber(cet_version_major .. "." .. cet_version_minor)

    -- Check CodeWare Version
    local code_version_str = Codeware.Version()
    local code_version_major, code_version_minor = code_version_str:match("1.(%d+)%.*(%d*)")
    FlyingTank.codeware_version_num = tonumber(code_version_major .. "." .. code_version_minor)

    if FlyingTank.cet_version_num < FlyingTank.cet_required_version then
        print("[FlyTank][Error] Flying Tank Mod requires Cyber Engine Tweaks version 1." .. FlyingTank.cet_required_version .. " or higher.")
        return false
    elseif FlyingTank.codeware_version_num < FlyingTank.codeware_required_version then
        print("[FlyTank][Error] Flying Tank Mod requires CodeWare version 1." .. FlyingTank.codeware_required_version .. " or higher.")
        return false
    end

    return true

end

function FlyingTank:CheckNativeSettings()

    FlyingTank.NativeSettings = GetMod("nativeSettings")
    if FlyingTank.NativeSettings == nil then
		FlyingTank.is_valid_native_settings = false
        return
	end
    FlyingTank.native_settings_version_num = FlyingTank.NativeSettings.version
    if FlyingTank.NativeSettings.version < FlyingTank.native_settings_required_version then
        FlyingTank.is_valid_native_settings = false
        return
    end
    FlyingTank.is_valid_native_settings = true

end

function FlyingTank:Version()
    return FlyingTank.version
end

function FlyingTank:ToggleDebugMode()
    FlyingTank.is_debug_mode = not FlyingTank.is_debug_mode
end

return FlyingTank