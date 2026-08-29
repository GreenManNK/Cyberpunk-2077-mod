-------------------------------------------------------------------------------------------------------------------------------
-- Custom door device, extending Mesh swap device template, by Akiway from CP2077 Modding Tools Discord.
-------------------------------------------------------------------------------------------------------------------------------

local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")
local switcher = require("modules/variants")

local customDoor = {}

function customDoor:new(id, interactionPosition, swapOnVariant, swapOffVariant)
    local localized = require("modules/utils/localizedText")

	local o = {}

    o.id = id
    o.interactionPosition = interactionPosition

    o.name = localized.object.overture
    o.iconRecord = "ChoiceIcons.InteractionDoorsIcon"
    o.swapOnText = localized.action.close
    o.swapOnIcon = "ChoiceCaptionParts.InteractionDoorsIcon"
    o.swapOnVariant = swapOnVariant
    o.swapOffText = localized.action.open
    o.swapOffIcon = "ChoiceCaptionParts.InteractionDoorsIcon"
    o.swapOffVariant = swapOffVariant

    o.detectionAngle = 360
    o.iconRange = 3
    o.interactionRange = 1.5

    -- (Optional) Sounds to be played when toggled on / off
    --   you can search for sounds here : https://sounddb.redmodding.org/
    -- Seek time is the duration from the beginning of the sound that will be skipped.
    --   be aware that not all sounds work with seekTime
    o.swapOnSounds = {
        {name = "sq031_sc_04_v_takes_off_cloth", delay = 0, seekTime = 2.5, intensity = 3}
    }
    o.swapOffSounds = {
        {name = "sq031_sc_04_v_takes_off_cloth", delay = 0, seekTime = 1.5, intensity = 3}
    }

	self.__index = self
   	return setmetatable(o, self)
end

function customDoor:init()
    self.workspot = require("modules/devices/template/meshSwapDevice"):new(self.id, self.interactionPosition, self.swapOnVariant, self.swapOffVariant)
    
    -- Overide the template properties with this device properties mentionned in 
    self.workspot.devicePath = self.devicePath
    self.workspot.name = self.name
    self.workspot.iconRecord = self.iconRecord
    self.workspot.swapOnText = self.swapOnText
    self.workspot.swapOnIcon = self.swapOnIcon
    self.workspot.swapOnVariant = self.swapOnVariant
    self.workspot.swapOffText = self.swapOffText
    self.workspot.swapOffIcon = self.swapOffIcon
    self.workspot.swapOffVariant = self.swapOffVariant

    self.workspot.detectionAngle = self.detectionAngle
    self.workspot.iconRange = self.iconRange
    self.workspot.interactionRange = self.interactionRange
    self.workspot.swapOnSounds = self.swapOnSounds
    self.workspot.swapOffSounds = self.swapOffSounds
    self.workspot:init()
end

return customDoor