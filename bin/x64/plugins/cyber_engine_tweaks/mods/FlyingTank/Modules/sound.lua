local Utils = require("Etc/utils")

local Sound = {}
Sound.__index = Sound

function Sound:New()
    -- instance --
    local obj = {}
    obj.log_obj = Log:New()
    obj.log_obj:SetLevel(LogLevel.Info, "Sound")
    -- dynamic --
    obj.sound_data = {}
    obj.playing_sound = {}
    obj.sound_restriction = Def.SoundRestrictionLevel.None
    return setmetatable(obj, self)
end

function Sound:Init()
    self.sound_data = Utils:ReadJson("Data/sound.json")
end

function Sound:PlaySound(sound_name)
    if self:CheckRestriction(sound_name) then
        if not FlyingTank.core_obj.vehicle_obj:IsPlayerAround() and self:GetIdentificationNumber(sound_name) >= 200 then
            return
        end
        Game.GetPlayer():PlaySoundEvent(self.sound_data[sound_name])
    end
end

function Sound:StopSound(sound_name)
    Game.GetPlayer():StopSoundEvent(self.sound_data[sound_name])
end

function Sound:SetRestriction(level)
    self.sound_restriction = level
end

---@return boolean -- true: play, false: mute
function Sound:CheckRestriction(sound)
    if self.sound_restriction == Def.SoundRestrictionLevel.None then
        return true
    elseif self.sound_restriction == Def.SoundRestrictionLevel.Mute then
        return false
    elseif self.sound_restriction == Def.SoundRestrictionLevel.PriorityRadio then
        local num = self:GetIdentificationNumber(sound)
        if num >= 200 or num < 300 then
            return false
        else
            return true
        end
    else
        return true
    end

end

function Sound:Mute()
    for  sound_name, _  in pairs(self.sound_data) do
        Game.GetPlayer():StopSoundEvent(self.sound_data[sound_name])
    end
end

function Sound:GetIdentificationNumber(name)
    local three_words = string.sub(name, 1, 3)
    return tonumber(three_words)
end

function Sound:PartialMute(num_min, num_max)

    for sound_name, _ in pairs(self.sound_data) do
        local num = self:GetIdentificationNumber(sound_name)
        if num >= num_min and num < num_max then
            Game.GetPlayer():StopSoundEvent(self.sound_data[sound_name])
        end
    end

end

return Sound