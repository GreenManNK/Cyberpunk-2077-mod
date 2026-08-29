local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")
local Cron  = require("modules/external/Cron")
local switcher = require("modules/variants")
local workspotUtils = require("modules/utils/workspotUtils")
local utils = require("modules/utils/utils")

local meshSwap = {}

function meshSwap:new(id, interactionPosition, swapOnVariant, swapOffVariant)
    local localized = require("modules/utils/localizedText")

	local o = {}

    o.id = id
    o.interactionPosition = interactionPosition

    o.name = localized.object.overture
    o.iconRecord = "ChoiceIcons.InteractionDoorsIcon"
    o.swapOnText = localized.action.open
    o.swapOnIcon = "ChoiceCaptionParts.InteractionDoorsIcon"
    o.swapOnVariant = swapOnVariant
    o.swapOnTime = 0.225
    o.swapOffText = localized.action.close
    o.swapOffIcon = "ChoiceCaptionParts.InteractionDoorsIcon"
    o.swapOffVariant = swapOffVariant
    o.swapOffTime = 0.225

    o.detectionAngle = 80
    o.iconRange = 3
    o.interactionRange = 1.5

    o.swapOnSounds = {}
    o.swapOffSounds = {}

    o.iconColor = HDRColor.new({ Red = 0.15829999744892, Green = 1.3033000230789, Blue = 1.4141999483109, Alpha = 1.0 })

	self.__index = self
   	return setmetatable(o, self)
end

function meshSwap:init() -- Setup basic info, create world interaction and hub

    world.addInteraction(self.id, self.interactionPosition, self.interactionRange, self.detectionAngle, self.iconRecord, self.iconRange, self.iconColor, function(state)
        if state then
            self:setupCallbacks()
        else
            interaction.hideHub()
        end
    end)
end

function meshSwap:setupCallbacks()
    -- Entry dialog UI:
    local choice = self:getChoice(switcher.getSettingByVariant(self.swapOnVariant).state)
    self.hub = interaction.createHub(self.name, { choice })
    interaction.setupHub(self.hub)
    interaction.showHub()

    interaction.callbacks[1] = function()
        if self.inGameMenu then return end
        if switcher.getSettingByVariant(self.swapOnVariant).state ~= true then
            switcher.toggleSwapSetting(self.swapOnVariant)
            if #self.swapOnSounds > 0 then
                local sound = self.swapOnSounds[math.random(#self.swapOnSounds)]
                workspotUtils.playAudio(sound.name, sound.delay, sound.seekTime, sound.intensity)
            end
        else
            switcher.toggleSwapSetting(self.swapOffVariant)
            if #self.swapOffSounds > 0 then
                local sound = self.swapOffSounds[math.random(#self.swapOffSounds)]
                workspotUtils.playAudio(sound.name, sound.delay, sound.seekTime, sound.intensity)
            end
        end

        local switchTime = 0
        if state then
            switchTime = self.swapOnTime
        else
            switchTime = self.swapOffTime
        end

        Cron.After(switchTime, function()
            self:setupCallbacks()
        end)
    end
end

---@param state boolean Current swap state
function meshSwap:getChoice(state)
    if state then
        return interaction.createChoice(self.swapOffText, TweakDBInterface.GetChoiceCaptionIconPartRecord(self.swapOffIcon))
    else
        return interaction.createChoice(self.swapOnText, TweakDBInterface.GetChoiceCaptionIconPartRecord(self.swapOnIcon))
    end
end

return meshSwap
