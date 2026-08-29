local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")
local wsUtils = require("modules/utils/workspotUtils")
local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")
local elevatorPath = "base\\props\\mansion_elevatoa.ent"

local logic = {
    workspots = {},
    inRange = false,
    purchased = false
}

function logic.setupInteractions() -- Setup workspots
    local device = require("modules/workspots/wardrobeDevice"):new(1, Vector4.new(-608.54, 2620.08, 62.95))
    device.iconRange = 4
    device:init()

    local app = require("modules/workspots/appearanceDevice"):new(2, Vector4.new(-605.79, 2618.15, 62.89, 0))
    app.iconRange = 4
    app:init()

    local bed = require("modules/workspots/sleepWorkspot"):new(31, Vector4.new(-609.57, 2621.97, 62.58, 0), Vector4.new(-609.57, 2621.97, 61.79, 0), EulerAngles.new(0, 0, -15))
    bed:init()
    table.insert(logic.workspots, bed)

    local shower = require("modules/workspots/showerWorkspot"):new(41, Vector4.new(-602.89, 2620.42, 63.04, 0), Vector4.new(-603.14, 2620.60, 61.79, 0), EulerAngles.new(0, 0, -125.69))
    shower:init()
    table.insert(logic.workspots, shower)
	
	local couch_top = require("modules/workspots/couchWorkspot"):new(25, Vector4.new(-605.26, 2629.81, 62.25, 0), Vector4.new(-605.30, 2629.69, 61.79, 0), EulerAngles.new(0, 0, -11.86))
    couch_top.iconRange = 3.5
    couch_top:init()
    table.insert(logic.workspots, couch_top)
	
end

function logic.setUpBuyInteraction()
    if Game.GetQuestsSystem():GetFactStr("Rebecca_Apart_DLC_2") == 1 then return end -- Already bought

    local pos = Vector4.new(-615.17, 2623.11, 63.05, 0)
    local range = 3.5
    local angle = 65
    local icon = "ChoiceIcons.ApartmentIcon"
    local iconRange = 8

    local cost = 150000
    if Game.GetStatsSystem():GetStatValue(GetPlayer():GetEntityID(), gamedataStatType.StreetCred) >= 30 then
        cost = 130000
    end

    world.addInteraction(69, pos, range, angle, icon, iconRange, HDRColor.new({Red = 1, Green = 219 / 255, Blue = 78 / 255}), function(state) -- Register world interaction
        if state then -- Show

            -- Setup choice and hub
            local enoughMoney = Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money()) >= cost
            local choiceFlavor = gameinteractionsChoiceType.QuestImportant
            if not enoughMoney then choiceFlavor = gameinteractionsChoiceType.Inactive end
            local choice = interaction.createChoice(cost .. "E$ [" .. GetLocalizedText("Apartment") .. "]", TweakDBInterface.GetChoiceCaptionIconPartRecord("ChoiceCaptionParts.PayIcon"), choiceFlavor)
            local hub = interaction.createHub(GetLocalizedText("Rent"), {choice})
            interaction.setupHub(hub)

            -- Buy option Callback:
            interaction.callbacks[1] = function()
                if not enoughMoney then return end
                Game.GetQuestsSystem():SetFactStr("Rebecca_Apart_DLC_2", 1)
                logic.purchased = true
                utils.spendMoney(cost)

                world.togglePin(world.interactions[69], false) -- Remove hub and pin
                world.interactions[69] = nil
                interaction.hideHub()
            end
            interaction.showHub()
        else -- Hide
            interaction.hideHub()
        end
    end)
end



function logic.init() -- Runs once onInit
    logic.setupVariables()

    Cron.Every(1, function()
        logic.checkInRange()
    end)
end


function logic.onSessionStart()
    logic.purchased = Game.GetQuestsSystem():GetFactStr("Rebecca_Apart_DLC_2") == 1
    logic.setUpBuyInteraction()
    local data = MappinData.new({ mappinType = 'Mappins.StaticPointOfInterestMappinDefinition', variant = gamedataMappinVariant.ApartmentVariant}) -- WorldMap Pin
    Game.GetMappinSystem():RegisterMappin(data, Vector4.new(-615.49, 2622.66, 63.05, 0))
end


function logic.update(dt)
    for _, spot in pairs(logic.workspots) do
        spot:update(dt)
    end
end

return logic