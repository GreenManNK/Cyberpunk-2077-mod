---@class Def
Def = {}
Def.__index = Def

Def.ActionList = {
    Nothing = 0,
    Up = 1,
    Down = 2,
    PitchUp = 3,
    PitchDown = 4,
    PitchReset = 5,
    ----------
	ChangeDoor = 100,
    ToggleRadio = 101,
    OpenRadio = 102,
}

Def.Situation = {
    Idel = -1,
    Normal = 0,
    Landing = 1,
    Waiting = 2,
    InVehicle = 3,
    TalkingOff = 4,
}

---@enum Def.DoorOperation
Def.DoorOperation = {
	Change = 0,
	Open = 1,
	Close = 2,
}

Def.TeleportResult = {
    Error = -1,
    Collision = 0,
    Success = 1,
    AvoidStack = 2,
}

Def.SoundRestrictionLevel = {
    None = -1,
    Mute = 0,
    PriorityRadio = 1,
}

return Def