local Cron = require("modules/external/Cron")
local utils = require("modules/utils/utils")
local wsUtils = require("modules/utils/workspotUtils")
local interaction = require("modules/utils/interactionUI")
local world = require("modules/utils/worldInteraction")
local elevatorPath = "base\\props\\mansion_elevator.ent"

local logic = {
    workspots = {},
    inRange = false,

    topElevatorID = nil,
    bottomElevatorID = nil,

    topCatcher = nil,
    bottomCatcher = nil,
    topUI = nil,
    bottomUI = nil,

    hoverTop = false,
    hoverBottom = false,

    exitInProgress = false,
    enterInProgress = false,

    purchased = false
}

function logic.setupInteractions() -- Setup workspots
    local device = require("modules/workspots/wardrobeDevice"):new(1, Vector4.new(-1342.2339, 1211.3936, 120.41113))
    device.iconRange = 4
    device:init()

    local app = require("modules/workspots/appearanceDevice"):new(2, Vector4.new(-1350.9360351563, 1209.0520019531, 119.76899719238, 0))
    app.iconRange = 4
    app:init()

    local bench_front = require("modules/workspots/benchWorkspot"):new(11, Vector4.new(-1333.8779296875, 1207.5316162109, 115.61174316406), Vector4.new(-1333.1109619141, 1207.5310058594, 115.01000213623, 0), EulerAngles.new(0, 0, 82.310))
    bench_front.minPitch = -15
    bench_front.maxYaw = 40
    bench_front.minYaw = -40
    bench_front.interactionRange = 1.6
    bench_front:init()
    table.insert(logic.workspots, bench_front)

    local bench_left = require("modules/workspots/benchWorkspot"):new(12, Vector4.new(-1328.6671142578, 1188.9222412109, 115.61171264648), Vector4.new(-1328.416015625, 1188.9560546875, 115.01000213623, 0), EulerAngles.new(0, 0, 112.46499633789))
    bench_left:init()
    table.insert(logic.workspots, bench_left)

    local bench_tv = require("modules/workspots/benchWorkspot"):new(13, Vector4.new(-1341.7305664063, 1202.3192138672, 115.35066210938), Vector4.new(-1341.4709472656, 1202.2110595703, 114.81500244141, 0), EulerAngles.new(0, 0, 75.065002441406))
    bench_tv.iconRange = 3
    bench_tv.name = GetLocalizedText("LocKey#39254")
    bench_tv:init()
    table.insert(logic.workspots, bench_tv)

    local bench_outdoor = require("modules/workspots/benchWorkspot"):new(14, Vector4.new(-1316.2674560547, 1237.8327392578, 111.7436157227), Vector4.new(-1316.2010498047, 1237.6910400391, 111.16500091553, 0), EulerAngles.new(0, 0, -9.4200000762939))
    bench_outdoor:init()
    table.insert(logic.workspots, bench_outdoor)

    local bench_bath = require("modules/workspots/benchWorkspot"):new(15, Vector4.new(-1346.2489844, 1212.572373047, 119.55050048828, 0), Vector4.new(-1346.2409667969, 1212.5109863281, 119.01499938965, 0), EulerAngles.new(0, 0, -8.5500001907349))
    bench_bath.iconRange = 1.5
    bench_bath.interactionRange = 1.5
    bench_bath:init()
    table.insert(logic.workspots, bench_bath)

    local bench_sun = require("modules/workspots/benchWorkspot"):new(16, Vector4.new(-1310.3609619141, 1219.3630371094, 111.68800354004, 0), Vector4.new(-1310.1910400391, 1219.3060302734, 111.16500091553, 0), EulerAngles.new(0, 0, 99.165000915527))
    bench_sun.name = GetLocalizedText("LocKey#38969")
    bench_sun.minYaw = -55
    bench_sun.maxYaw = 65
    bench_sun.minPitch = -25
    bench_sun:init()
    table.insert(logic.workspots, bench_sun)

    local seat_guitar = require("modules/workspots/couchWorkspot"):new(21, Vector4.new(-1351.3369140625, 1210.4339599609, 115.73457336426), Vector4.new(-1351.2299804688, 1210.4809570313, 114.98000335693, 0), EulerAngles.new(0, 0, 112.72299957275))
    seat_guitar.name = GetLocalizedText("LocKey#38969")
    seat_guitar:init()
    table.insert(logic.workspots, seat_guitar)

    local bean_outdoor = require("modules/workspots/couchWorkspot"):new(22, Vector4.new(-1352.6479492188, 1221.3250732422, 115.46603088379), Vector4.new(-1352.3950195313, 1221.1159667969, 114.9049987793, 0), EulerAngles.new(0, 0, 49.544998168945))
    bean_outdoor.name = GetLocalizedText("LocKey#38969")
    bean_outdoor:init()
    table.insert(logic.workspots, bean_outdoor)

    local couch_holo = require("modules/workspots/couchWorkspot"):new(23, Vector4.new(-1338.9624023438, 1210.5458105469, 115.55244934082, 0), Vector4.new(-1339.0300292969, 1210.4360351563, 114.98000335693, 0), EulerAngles.new(0, 0, 10.369999885559))
    couch_holo:init()
    table.insert(logic.workspots, couch_holo)

    local bean_top = require("modules/workspots/couchWorkspot"):new(24, Vector4.new(-1336.0407714844, 1206.3853759766, 119.45704162598), Vector4.new(-1336.2399902344, 1206.7259521484, 118.80999755859, 0), EulerAngles.new(0, 0, -150.74499511719))
    bean_top.name = GetLocalizedText("LocKey#38969")
    bean_top.minPitch = -28
    bean_top.minYaw = -60
    bean_top.maxYaw = 60
    bean_top.iconRange = 3
    bean_top:init()
    table.insert(logic.workspots, bean_top)

    local couch_top = require("modules/workspots/couchWorkspot"):new(25, Vector4.new(-1350.9506835938, 1205.6009521484, 119.6225952148, 0), Vector4.new(-1350.6750488281, 1205.4260253906, 118.97499847412, 0), EulerAngles.new(0, 0, 103.94999694824))
    couch_top.iconRange = 3.5
    couch_top:init()
    table.insert(logic.workspots, couch_top)

    local secret = require("modules/workspots/couchWorkspot"):new(26, Vector4.new(-1418.6080322266, 1267.6090087891, 23.590999603271, 0), Vector4.new(-1418.66796875, 1267.3840332031, 23.070999145508, 0), EulerAngles.new(0, 0, -2.8949999809265))
    secret.name = GetLocalizedText("LocKey#38190")
    secret.iconRange = 4
    secret:init()
    table.insert(logic.workspots, secret)

    local bed = require("modules/workspots/sleepWorkspot"):new(31, Vector4.new(-1337.767578125, 1210.623046875, 119.45513916016, 0), Vector4.new(-1336.8260498047, 1210.3370361328, 119.042, 0), EulerAngles.new(0, 0, -95.545928955078))
    bed:init()
    table.insert(logic.workspots, bed)

    local shower = require("modules/workspots/showerWorkspot"):new(41, Vector4.new(-1351.9000244141, 1212.1400146484, 120.29599761963, 0), Vector4.new(-1351.4560546875, 1212.1240234375, 119.01556396484, 0), EulerAngles.new(0, 0, 83.978996276855))
    shower:init()
    table.insert(logic.workspots, shower)

    local rail = require("modules/workspots/railWorkspot"):new(50, Vector4.new(-1330.0760498047, 1214.1810302734, 116.12000274658, 0), Vector4.new(-1330.6579589844, 1214.2030029297, 114.99500274658, 0), EulerAngles.new(0, 0, 94.525))
    rail:init()
    table.insert(logic.workspots, rail)

    local rail_right = require("modules/workspots/railWorkspot"):new(51, Vector4.new(-1330.2430419922, 1199.1600341797, 116.12000274658, 0), Vector4.new(-1330.8079833984, 1198.8929443359, 114.99500274658, 0), EulerAngles.new(0, 0, 118.37999725342))
    rail_right:init()
    table.insert(logic.workspots, rail_right)

    local rail_left = require("modules/workspots/railWorkspot"):new(52, Vector4.new(-1332.3979492188, 1221.9229736328, 116.12000274658, 0), Vector4.new(-1332.3979492188, 1221.3229980469, 114.99500274658, 0), EulerAngles.new(0, 0, 180.42500305176))
    rail_left:init()
    table.insert(logic.workspots, rail_left)

    local rail_left_right = require("modules/workspots/railWorkspot"):new(53, Vector4.new(-1355.8310546875, 1217.0413818359, 116.12000274658, 0), Vector4.new(-1355.1879882813, 1217.248046875, 114.99500274658, 0), EulerAngles.new(0, 0, -90))
    rail_left_right:init()
    table.insert(logic.workspots, rail_left_right)

    local rail_left_left = require("modules/workspots/railWorkspot"):new(54, Vector4.new(-1359.2440185547, 1199.5810546875, 116.12000274658, 0), Vector4.new(-1358.9079589844, 1199.0479736328, 114.99500274658, 0), EulerAngles.new(0, 0, -138.600))
    rail_left_left:init()
    table.insert(logic.workspots, rail_left_left)

    local coffee = require("modules/workspots/coffeeWorkspot"):new(61, Vector4.new(-1334.2349853516, 1188.7239990234, 115.95099639893, 0), Vector4.new(-1334.9429931641, 1188.6939697266, 114.91000366211, 0), EulerAngles.new(0, 0, -95.24 + 180))
    coffee:init()
    table.insert(logic.workspots, coffee)

    local drink = require("modules/workspots/drinkWorkspot"):new(71, Vector4.new(-1337.7020263672, 1192.58203125, 115.83799743652, 0), Vector4.new(-1336.9119873047, 1192.8220214844, 114.69999694824, 0), EulerAngles.new(0, 0, -25.875))
    drink:init()
    table.insert(logic.workspots, drink)
end

function logic.setUpBuyInteraction()
    if Game.GetQuestsSystem():GetFactStr("mansion_owned") == 1 then return end -- Already bought

    local pos = Vector4.new(-1392.5830078125, 1150.3089599609, 24.225999832153, 0)
    local range = 2.5
    local angle = 65
    local icon = "ChoiceIcons.ApartmentIcon"
    local iconRange = 8

    local cost = 150000
    if Game.GetStatsSystem():GetStatValue(GetPlayer():GetEntityID(), gamedataStatType.StreetCred) >= 30 then
        cost = 75000
    end

    world.addInteraction(69, pos, range, angle, icon, iconRange, HDRColor.new({Red = 1, Green = 219 / 255, Blue = 78 / 255}), function(state) -- Register world interaction
        if state then -- Show

            -- Setup choice and hub
            local enoughMoney = Game.GetTransactionSystem():GetItemQuantity(GetPlayer(), MarketSystem.Money()) >= cost
            local choiceFlavor = gameinteractionsChoiceType.QuestImportant
            if not enoughMoney then choiceFlavor = gameinteractionsChoiceType.Inactive end
            local choice = interaction.createChoice(cost .. "E$ [" .. GetLocalizedText("LocKey#15323") .. "]", TweakDBInterface.GetChoiceCaptionIconPartRecord("ChoiceCaptionParts.PayIcon"), choiceFlavor)
            local hub = interaction.createHub(GetLocalizedText("LocKey#49251"), {choice})
            interaction.setupHub(hub)

            -- Buy option Callback:
            interaction.callbacks[1] = function()
                if not enoughMoney then return end
                Game.GetQuestsSystem():SetFactStr("mansion_owned", 1)
                logic.purchased = true
                utils.spendMoney(cost)

                logic.bottomElevatorInRange = false -- Open door

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

function logic.setupVariables()
    logic.aptCenter = Vector4.new(-1335.82421875, 1218.3798828125, 119.14869689941, 0)
    logic.aptRange = 54
    logic.inRange = GetPlayer():GetWorldPosition():Distance(logic.aptCenter) < logic.aptRange

    logic.elevatorCenter = Vector4.new(-1378.0100097656, 1177.3630371094, 58.134414672852, 0)
    logic.elevatorRange = 80
    logic.elevatorInRange = false

    logic.topElevatorPos = {pos = Vector4.new(-1340.975, 1186.570, 115.003), rot = EulerAngles.new(0, 0, 174.979)}
    logic.topElevatorInRange = false

    logic.bottomElevatorPos = {pos = Vector4.new(-1392.792, 1148.360, 23.086), rot = EulerAngles.new(0, 0, 173.829)}
    logic.bottomElevatorInRange = false

    logic.middleElevatorPos = Vector4.new(-1386.4475097656, 1167.2287597656, 76.676345825195, 0)

    logic.topElevatorID = entEntityID.new({hash = 25176159ULL})
    logic.bottomElevatorID = entEntityID.new({hash = 32623512ULL})
end

function logic.init() -- Runs once onInit
    logic.setupVariables()

    Cron.Every(1, function()
        logic.checkInRange()
        logic.checkObjects()
    end)

    Override("GameTimeUtils", "CanPlayerTimeSkip;PlayerPuppet", function(player, wrapped) -- Enable time skip in mansion
        if logic.inRange then return true end
        return wrapped(player)
    end)

    Override("ElevatorInkGameController", "SetCurrentFloorOnUI", function(this, name, wrapped) -- Custom elevator floor names
        if utils.isSameInstance(Game.FindEntityByID(logic.topElevatorID), this:GetOwner()) then
            if logic.enterInProgress then
                this.currentFloorTextWidget:SetText(GetLocalizedText("LocKey#37572")) -- "Street"
            else
                this.currentFloorTextWidget:SetText(GetLocalizedText("LocKey#49251")) -- "Penthouse"
            end
            return
        end
        if utils.isSameInstance(Game.FindEntityByID(logic.bottomElevatorID), this:GetOwner()) then
            if logic.exitInProgress then
                this.currentFloorTextWidget:SetText(GetLocalizedText("LocKey#49251"))
            else
                this.currentFloorTextWidget:SetText(GetLocalizedText("LocKey#37572"))
            end
            return
        end
        wrapped(name)
    end)

    Override("ElevatorInkGameController", "UpdateActionWidgets", function(this, widgets, wrapped) -- Custom elevator button setup
        if utils.isSameInstance(Game.FindEntityByID(logic.topElevatorID), this:GetOwner()) then
            logic.topUI = this

            if logic.exitInProgress then return end
            if not logic.hoverTop then
                logic.greyOutArrows(this.elevatorDownArrowsWidget, true)
            end

            logic.topCatcher = sampleStyleManagerGameController.new() -- For the button callbacks
            this.elevatorDownArrowsWidget:SetInteractive(true)
            this.elevatorDownArrowsWidget:RegisterToCallback('OnEnter', logic.topCatcher, 'OnStyle2')
            this.elevatorDownArrowsWidget:RegisterToCallback('OnLeave', logic.topCatcher, 'OnStyle1')
            this.elevatorDownArrowsWidget:RegisterToCallback('OnPress', logic.topCatcher, 'OnState1')

            if logic.enterInProgress then
                logic.setElevatorArrows(logic.topUI, "up", true)
            else
                logic.setElevatorArrows(logic.topUI, "down", false)
            end
            return
        end
        if utils.isSameInstance(Game.FindEntityByID(logic.bottomElevatorID), this:GetOwner()) then
            logic.bottomUI = this

            if logic.enterInProgress then return end
            if not logic.hoverBottom then
                logic.greyOutArrows(this.elevatorUpArrowsWidget, true)
            end

            logic.bottomCatcher = sampleStyleManagerGameController.new()
            this.elevatorUpArrowsWidget:SetInteractive(true)
            this.elevatorUpArrowsWidget:RegisterToCallback('OnEnter', logic.bottomCatcher, 'OnStyle2')
            this.elevatorUpArrowsWidget:RegisterToCallback('OnLeave', logic.bottomCatcher, 'OnStyle1')
            this.elevatorUpArrowsWidget:RegisterToCallback('OnPress', logic.bottomCatcher, 'OnState1')

            if logic.exitInProgress then
                logic.setElevatorArrows(logic.bottomUI, "down", true)
            else
                logic.setElevatorArrows(logic.bottomUI, "up", false)
            end
            return
        end
        wrapped(widgets)
    end)

    Observe('sampleStyleManagerGameController', 'OnStyle2', function(self) -- Hover in event
        if utils.isSameInstance(logic.topCatcher, self) then
            logic.greyOutArrows(logic.topUI.elevatorDownArrowsWidget, false)
            logic.hoverTop = true
        end
        if utils.isSameInstance(logic.bottomCatcher, self) then
            logic.greyOutArrows(logic.bottomUI.elevatorUpArrowsWidget, false)
            logic.hoverBottom = true
        end
    end)

    Observe('sampleStyleManagerGameController', 'OnStyle1', function(self) -- Hover out event
        if utils.isSameInstance(logic.topCatcher, self) then
            logic.greyOutArrows(logic.topUI.elevatorDownArrowsWidget, true)
            logic.hoverTop = false
        end
        if utils.isSameInstance(logic.bottomCatcher, self) then
            logic.greyOutArrows(logic.bottomUI.elevatorUpArrowsWidget, true)
            logic.hoverBottom = false
        end
    end)

    Observe('sampleStyleManagerGameController', 'OnState1', function(self, evt) -- Press Event
        if not evt:IsAction("click") then return end

        if utils.isSameInstance(logic.topCatcher, self) then
            logic.leaveSequence()
        end
        if utils.isSameInstance(logic.bottomCatcher, self) then
            logic.enterSequence()
        end
    end)

    Observe("gameItemDropObject", "OnInteractionActivated", function(this)
        if this:GetWorldPosition():Distance(Vector4.new(-1347.3116, 1193.2089, 114.9877, 1)) < 0.1 and Vector4.new(-1347.3116, 1193.2089, 114.9877, 1):Distance(GetPlayer():GetWorldPosition()) < 3 then

            local isQuest = false
            pcall(function()
                local questName = Game.GetJournalManager():GetParentEntry(Game.GetJournalManager():GetParentEntry(Game.GetJournalManager():GetTrackedEntry())):GetTitle(Game.GetJournalManager())
                if not questName then return end
                if questName == "LocKey#9308" then isQuest = true end
            end)

            local posHide = Vector4.new(-1347.3116, 1193.2089, 110.9877, 1)
            if isQuest then
                return
            else
                Game.GetTeleportationFacility():Teleport(this, posHide, this:GetWorldOrientation():ToEulerAngles())
            end
        end
    end)

    Override("gameLootContainerBasePS", "IsLocked", function(this, wrapped)
        if logic.inRange then
            local ent = Game.FindEntityByID(this:GetID():ExtractEntityID())
            if ent and ent:GetWorldPosition():Distance(Vector4.new(-1338.7823, 1209.1736, 119.005005)) < 0.1 then
                local isQuest = false
                pcall(function()
                    local questName = Game.GetJournalManager():GetParentEntry(Game.GetJournalManager():GetParentEntry(Game.GetJournalManager():GetTrackedEntry())):GetTitle(Game.GetJournalManager())
                    if not questName then return end
                    if questName == "LocKey#9308" then isQuest = true end
                end)
                if isQuest then return false end
                return true
            else
                return wrapped()
            end
        end

        return wrapped()
    end)
end

function logic.checkInRange()
    -- In apartment
    if GetPlayer():GetWorldPosition():Distance(logic.aptCenter) < logic.aptRange then
        if not logic.inRange then
            logic.inRange = true
        end
        utils.applyStatus("GameplayRestriction.NoCombat")
        utils.applyStatus("GameplayRestriction.VehicleNoSummoning")
    else
        if logic.inRange then
            logic.inRange = false
            utils.removeStatus("GameplayRestriction.NoCombat")
            utils.removeStatus("GameplayRestriction.VehicleNoSummoning")
        end
    end

    -- In range for elevator things
    if GetPlayer():GetWorldPosition():Distance(logic.elevatorCenter) < logic.elevatorRange then
        logic.elevatorInRange = true
        logic.handleElevatorDoors()
    else
        logic.elevatorInRange = false
    end
end

function logic.handleElevatorDoors() -- Automatically open / close elevator doors
    local top = Game.FindEntityByID(logic.topElevatorID)
    local bottom = Game.FindEntityByID(logic.bottomElevatorID)
    local rangeTop = 7
    local rangeBottom = 10

    if logic.exitInProgress or logic.enterInProgress then return end
    if not logic.purchased then return end

    if logic.topElevatorPos.pos:Distance(GetPlayer():GetWorldPosition()) < rangeTop and top and not logic.topElevatorInRange then
        utils.toggleElevatorDoors(top, true)
        logic.topElevatorInRange = true
    elseif logic.topElevatorPos.pos:Distance(GetPlayer():GetWorldPosition()) > rangeTop and logic.topElevatorInRange then
        utils.toggleElevatorDoors(top, false)
        logic.topElevatorInRange = false
    end

    if logic.bottomElevatorPos.pos:Distance(GetPlayer():GetWorldPosition()) < rangeBottom and bottom and not logic.bottomElevatorInRange then
        utils.toggleElevatorDoors(bottom, true)
        logic.bottomElevatorInRange = true
    elseif logic.bottomElevatorPos.pos:Distance(GetPlayer():GetWorldPosition()) > rangeBottom and logic.bottomElevatorInRange then
        utils.toggleElevatorDoors(bottom, false)
        logic.bottomElevatorInRange = false
    end
end

function logic.onSessionStart()
    logic.purchased = Game.GetQuestsSystem():GetFactStr("mansion_owned") == 1
    logic.setUpBuyInteraction()

    local data = MappinData.new({ mappinType = 'Mappins.StaticPointOfInterestMappinDefinition', variant = gamedataMappinVariant.ApartmentVariant}) -- WorldMap Pin
    Game.GetMappinSystem():RegisterMappin(data, Vector4.new(-1392.5830078125, 1152.3089599609, 24.225999832153, 0))
end

function logic.onSessionEnd()
    logic.bottomElevatorInRange = false
    logic.topElevatorInRange = false
    logic.elevatorInRange = false
end

function logic.checkObjects() -- Remove objects and unlock doors
    local terminal = Game.FindEntityByID(entEntityID.new{hash = 13312760010544421172ULL})
    if terminal then terminal:Dispose() end
    local door = Game.FindEntityByID(entEntityID.new{hash = 3868860460885039388ULL})
    if door then door:Dispose() end
    local v1 = Game.FindEntityByID(entEntityID.new{hash = 16320050434162506961ULL})
    if v1 then v1:Dispose() end
    local v2 = Game.FindEntityByID(entEntityID.new{hash = 18041008585649371276ULL})
    if v2 then v2:Dispose() end

    local door1 = Game.FindEntityByID(entEntityID.new{hash = 17842403809714745159ULL})
    local door2 = Game.FindEntityByID(entEntityID.new{hash = 15153792353086968887ULL})

    if door1 then
        if door1:GetDevicePS():IsLocked() then
            door1:GetDevicePS():ToggleLockOnDoor()
        end
        if door1:GetDevicePS():IsSealed() then
            door1:GetDevicePS():ToggleSealOnDoor()
        end
    end
    if door2 then
        if door2:GetDevicePS():IsLocked() then
            door2:GetDevicePS():ToggleLockOnDoor()
        end
        if door2:GetDevicePS():IsSealed() then
            door2:GetDevicePS():ToggleSealOnDoor()
        end
    end
end

function logic.enterSequence()
    if logic.enterInProgress then return end
    logic.enterInProgress = true

    wsUtils.toggleHUD(false)
    SaveLocksManager.RequestSaveLockAdd("PersonalLink")

    logic.bottomUI.elevatorUpArrowsWidget:SetOpacity(1)
    Cron.After(0.2, function()
        logic.bottomUI.elevatorUpArrowsWidget:SetOpacity(0.75)
        logic.setElevatorArrows(logic.bottomUI, "up", true)
    end)

    utils.playSound("ui_elevator_select")
    utils.toggleElevatorDoors(Game.FindEntityByID(logic.bottomElevatorID), false)

    Cron.After(0.75, function()
        utils.playSound("dev_elevator_02_movement_start", Game.FindEntityByID(logic.topElevatorID))
        utils.playSound("dev_elevator_02_movement_start", Game.FindEntityByID(logic.bottomElevatorID))
    end)

    -- TP to middle

    Cron.After(6, function()
        GameObjectEffectHelper.StartEffectEvent(GetPlayer(), "blink_slow", true, worldEffectBlackboard.new())
        Cron.After(0.6, function()
            local offset = utils.subVector(GetPlayer():GetWorldPosition(), logic.bottomElevatorPos.pos)
            local target = utils.addVector(logic.middleElevatorPos, offset)
            Game.GetTeleportationFacility():Teleport(GetPlayer(), target, GetPlayer():GetWorldOrientation():ToEulerAngles())
        end)
    end)

    -- TP to bottom

    Cron.After(6.1, function()
        Cron.After(0.6, function()
            local offset = utils.subVector(GetPlayer():GetWorldPosition(), logic.middleElevatorPos)
            local target = utils.addVector(logic.topElevatorPos.pos, offset)
            Game.GetTeleportationFacility():Teleport(GetPlayer(), target, GetPlayer():GetWorldOrientation():ToEulerAngles())

            Cron.After(0.2, function ()
                logic.setElevatorArrows(logic.topUI, "up", true)
            end)
        end)
    end)

    Cron.After(12, function()
        utils.stopSound("dev_elevator_02_movement_start", Game.FindEntityByID(logic.topElevatorID))
        utils.stopSound("dev_elevator_02_movement_start", Game.FindEntityByID(logic.bottomElevatorID))
        utils.playSound("dev_elevator_02_movement_stop", Game.FindEntityByID(logic.topElevatorID))
        logic.enterInProgress = false
        SaveLocksManager.RequestSaveLockRemove("PersonalLink")
        wsUtils.toggleHUD(true)
        if logic.topUI then
            logic.setElevatorArrows(logic.topUI, "down", false)
            logic.greyOutArrows(logic.topUI.elevatorDownArrowsWidget, true)
            logic.topUI.currentFloorTextWidget:SetText(GetLocalizedText("LocKey#49251"))
        end
    end)
end

function logic.leaveSequence()
    if logic.exitInProgress then return end
    logic.exitInProgress = true

    wsUtils.toggleHUD(false)
    SaveLocksManager.RequestSaveLockAdd("PersonalLink")

    logic.topUI.elevatorDownArrowsWidget:SetOpacity(1)
    Cron.After(0.2, function()
        logic.topUI.elevatorDownArrowsWidget:SetOpacity(0.75)
        logic.setElevatorArrows(logic.topUI, "down", true)
    end)

    utils.playSound("ui_elevator_select")
    utils.toggleElevatorDoors(Game.FindEntityByID(logic.topElevatorID), false)

    Cron.After(0.75, function()
        utils.playSound("dev_elevator_02_movement_start", Game.FindEntityByID(logic.topElevatorID))
        utils.playSound("dev_elevator_02_movement_start", Game.FindEntityByID(logic.bottomElevatorID))
    end)

    -- TP to middle

    Cron.After(6, function()
        GameObjectEffectHelper.StartEffectEvent(GetPlayer(), "blink_slow", true, worldEffectBlackboard.new())
        Cron.After(0.6, function()
            local offset = utils.subVector(GetPlayer():GetWorldPosition(), logic.topElevatorPos.pos)
            local target = utils.addVector(logic.middleElevatorPos, offset)
            Game.GetTeleportationFacility():Teleport(GetPlayer(), target, GetPlayer():GetWorldOrientation():ToEulerAngles())
        end)
    end)

    -- TP to top

    Cron.After(6.1, function()
        Cron.After(0.6, function()
            local offset = utils.subVector(GetPlayer():GetWorldPosition(), logic.middleElevatorPos)
            local target = utils.addVector(logic.bottomElevatorPos.pos, offset)
            Game.GetTeleportationFacility():Teleport(GetPlayer(), target, GetPlayer():GetWorldOrientation():ToEulerAngles())

            Cron.After(0.2, function ()
                logic.setElevatorArrows(logic.bottomUI, "down", true)
            end)
        end)
    end)

    Cron.After(12, function()
        utils.stopSound("dev_elevator_02_movement_start", Game.FindEntityByID(logic.bottomElevatorID))
        utils.stopSound("dev_elevator_02_movement_start", Game.FindEntityByID(logic.topElevatorID))
        utils.playSound("dev_elevator_02_movement_stop", Game.FindEntityByID(logic.bottomElevatorID))
        logic.exitInProgress = false
        SaveLocksManager.RequestSaveLockRemove("PersonalLink")
        wsUtils.toggleHUD(true)
        if logic.bottomUI then
            logic.setElevatorArrows(logic.bottomUI, "up", false)
            logic.greyOutArrows(logic.bottomUI.elevatorUpArrowsWidget, true)
            logic.bottomUI.currentFloorTextWidget:SetText(GetLocalizedText("LocKey#37572"))
        end
    end)
end

function logic.setElevatorArrows(ui, direction, animated)
    if not ui then return end

    ui.elevatorUpArrowsWidget:SetVisible(direction == "up")
    ui.elevatorDownArrowsWidget:SetVisible(direction == "down")
    if direction == "up" and animated then
        ui.elevatorUpArrowsWidget:GetController():PlayAnimationsArrowsUp()
    elseif direction == "down" and animated then
        ui.elevatorDownArrowsWidget:GetController():PlayAnimationsArrowsDown()
    end
end

function logic.greyOutArrows(arrow, state)
    if logic.exitInProgress or logic.enterInProgress or not arrow then return end

    if state then
        local color = HDRColor.new({Red = 1, Green = 1, Blue = 1, Alpha = 1})
        arrow:SetOpacity(0.25)
        arrow:GetWidgetByPathName("1"):GetWidgetByIndex(0):SetTintColor(color)
        arrow:GetWidgetByPathName("1"):GetWidgetByIndex(1):SetTintColor(color)
        arrow:GetWidgetByPathName("2"):GetWidgetByIndex(0):SetTintColor(color)
        arrow:GetWidgetByPathName("2"):GetWidgetByIndex(1):SetTintColor(color)
        arrow:GetWidgetByPathName("3"):GetWidgetByIndex(0):SetTintColor(color)
        arrow:GetWidgetByPathName("3"):GetWidgetByIndex(1):SetTintColor(color)
    else
        local color = HDRColor.new({Red = 0.93725496530533, Green = 0.8156863451004, Blue = 0.14509804546833, Alpha = 1})
        arrow:SetOpacity(0.75)
        arrow:GetWidgetByPathName("1"):GetWidgetByIndex(0):SetTintColor(color)
        arrow:GetWidgetByPathName("1"):GetWidgetByIndex(1):SetTintColor(color)
        arrow:GetWidgetByPathName("2"):GetWidgetByIndex(0):SetTintColor(color)
        arrow:GetWidgetByPathName("2"):GetWidgetByIndex(1):SetTintColor(color)
        arrow:GetWidgetByPathName("3"):GetWidgetByIndex(0):SetTintColor(color)
        arrow:GetWidgetByPathName("3"):GetWidgetByIndex(1):SetTintColor(color)
    end
end

function logic.update(dt)
    for _, spot in pairs(logic.workspots) do
        spot:update(dt)
    end
end

return logic