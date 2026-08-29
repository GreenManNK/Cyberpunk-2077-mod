local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")
local switcher = require("modules/variants")

local tentDoor = {}

function tentDoor:new(id, interactionPosition, swapOnVariant, swapOffVariant)
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

    o.swapOnSounds = {
        {name = "sq031_sc_04_v_takes_off_cloth", delay = 0, seekTime = 2.5, intensity = 3}
    }
    o.swapOffSounds = {
        {name = "sq031_sc_04_v_takes_off_cloth", delay = 0, seekTime = 1.5, intensity = 3}
        -- {name = "q305_sc_11_take_off_v_cloth", delay = 0, seekTime = 1.5, intensity = 3}
        -- {name = "av_q305_myers_excalibur_land_cloth", delay = 0, seekTime = 1, intensity = 5}
    }

	self.__index = self
   	return setmetatable(o, self)
end

function tentDoor:init()
    self.workspot = require("modules/devices/template/meshSwapDevice"):new(self.id, self.interactionPosition, self.swapOnVariant, self.swapOffVariant)
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

return tentDoor