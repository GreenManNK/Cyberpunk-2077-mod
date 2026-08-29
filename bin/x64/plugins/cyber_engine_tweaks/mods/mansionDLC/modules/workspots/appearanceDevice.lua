local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")

local app = {}

function app:new(id, position)
	local o = {}

    o.id = id
    o.position = position

    o.hub = nil
    o.callbacks = nil
    o.inGameMenu = nil
    o.awaitMenu = false

	self.__index = self
   	return setmetatable(o, self)
end

function app:init() -- Setup basic info, create world interaction and hub
    self.detectionAngle = 80
    self.iconRange = 3.2
    self.interactionRange = 1.5
    self.iconRecord = "ChoiceIcons.HairdresserIcon"
    self.iconColor = HDRColor.new({ Red = 0.15829999744892, Green = 1.3033000230789, Blue = 1.4141999483109, Alpha = 1.0 })
    self.name = GetLocalizedText("LocKey#45529")

    local choice = interaction.createChoice("[" .. GetLocalizedText("LocKey#79059") .. "]", TweakDBInterface.GetChoiceCaptionIconPartRecord("ChoiceCaptionParts.HairdresserIcon"))
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

    Observe("gameuiInGameMenuGameController", "SpawnMenuInstanceEvent", function(this)
        self.inGameMenu = this
    end)

    Observe("gameuiInGameMenuGameController", "RegisterGlobalBlackboards", function(this)
        self.inGameMenu = this
    end)

    Override("MenuScenario_PauseMenu", "OnEnterScenario", function(this, prev, data, f)
        if self.awaitMenu then
            this:SwitchToScenario("MenuScenario_CharacterCustomizationMirror")
            self.awaitMenu = false
        else
            f(prev, data)
        end
    end)

    Override("MenuScenario_CharacterCustomizationMirror", "OnCCOPuppetReady", function(this)
        local morphMenuUserData = MorphMenuUserData.new()
        morphMenuUserData.optionsListInitialized = false
        morphMenuUserData.updatingFinalizedState = true
        morphMenuUserData.editMode = gameuiCharacterCustomizationEditTag.NewGame
        this.currMenuName = "character_customization"
        local menuState = this:GetMenusState()
        menuState:OpenMenu("player_puppet")
        menuState:OpenMenu("character_customization", morphMenuUserData)
    end)
end

function app:setupCallbacks()
    interaction.callbacks[1] = function()
        if not self.inGameMenu then
            print("MansionDLC Error: Please reload a save")
            return
        end
        self.inGameMenu:SpawnMenuInstanceEvent("OnOpenPauseMenu")
        self.awaitMenu = true
    end
end

return app