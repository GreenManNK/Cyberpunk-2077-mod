local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")

local wardrobe = {}

function wardrobe:new(id, position)
	local o = {}

    o.id = id
    o.position = position

    o.hub = nil
    o.callbacks = nil

	self.__index = self
   	return setmetatable(o, self)
end

function wardrobe:init() -- Setup basic info, create world interaction and hub
    self.detectionAngle = 80
    self.iconRange = 5
    self.interactionRange = 1.5
    self.iconRecord = "ChoiceIcons.OpenWardrobeIcon"
    self.iconColor = HDRColor.new({ Red = 0.15829999744892, Green = 1.3033000230789, Blue = 1.4141999483109, Alpha = 1.0 })
    self.name = GetLocalizedText("LocKey#35138")

    local choice = interaction.createChoice(GetLocalizedText("LocKey#79193"), TweakDBInterface.GetChoiceCaptionIconPartRecord("ChoiceCaptionParts.OpenWardrobeIcon"))
    self.hub = interaction.createHub(self.name, {choice})

    world.addInteraction(self.id, self.position, self.interactionRange, self.detectionAngle, self.iconRecord, self.iconRange, self.iconColor, function(state)
        if state then
            self:setupCallbacks()
            interaction.setupHub(self.hub)
            interaction.showHub()
        else
            interaction.hideHub()
        end
    end)
end

function wardrobe:setupCallbacks()
    interaction.callbacks[1] = function()
        local userData = WardrobeUserData.new()
        local menuEvent = inkMenuInstance_SpawnEvent.new()
        menuEvent:Init("OnOpenWardrobeMenu", userData)
        Game.GetUISystem():QueueEvent(menuEvent)
    end
end

return wardrobe