local terminal = {}

function terminal.setupVariables()
    terminal.pinPos = Vector4.new(-1400.218, 1161.164, 24.448)
    terminal.tpPos = Vector4.new(-1399.4311523438, 1161.0443115234, 23.10424041748, 0)
    terminal.tpRot = EulerAngles.new(0, 0, -96.686)
end

function terminal.init() -- Runs once onInit
    terminal.setupVariables()

    ---@param this WorldMapTooltipController
    ---@param data WorldMapTooltipData
    ---@param menu WorldMapMenuGameController
    ObserveAfter("WorldMapTooltipController", "SetData", function(this, data, menu)
        if not data then return end
        if data.mappin and data.mappin:GetWorldPosition():Distance(terminal.pinPos) > 0.1 then return end

        inkWidgetRef.SetVisible(this.inputInteractContainer, menu and menu:IsFastTravelEnabled())
        inkTextRef.SetText(this.titleText, GetLocalizedText("LocKey#49251"))
        inkTextRef.SetText(this.descText, GetLocalizedText("LocKey#35147"))
    end)

    ---@param this WorldMapMenuGameController
    Observe("WorldMapMenuGameController", "TryFastTravel", function(this)
        if not this.selectedMappin then return end
        if this.selectedMappin and this.selectedMappin.mappin:GetWorldPosition():Distance(terminal.pinPos) > 0.1 or not this:IsFastTravelEnabled() then return end
        local nextLoadingTypeEvt = inkSetNextLoadingScreenEvent.new()
        nextLoadingTypeEvt:SetNextLoadingScreenType(inkLoadingScreenType.FastTravel)
        this:QueueBroadcastEvent(nextLoadingTypeEvt)

        if this.menuEventDispatcher then
            this.menuEventDispatcher:SpawnEvent("OnBack")
        end

        Game.GetTeleportationFacility():Teleport(GetPlayer(), terminal.tpPos, terminal.tpRot)
    end)

    ObserveAfter("DataTermInkGameController", "UpdatePointText", function(this)
        if this:GetOwner():GetWorldPosition():Distance(terminal.pinPos) > 2 then return end
        this.pointText:SetText(GetLocalizedText("LocKey#49251"))
        this.districtText:SetText(GetLocalizedText("LocKey#10963"))
    end)
end

function terminal.onSessionStart()
    local data = MappinData.new({ mappinType = "Mappins.FastTravelStaticMappin", variant = gamedataMappinVariant.FastTravelVariant})
    Game.GetMappinSystem():RegisterMappin(data, terminal.pinPos)
end

return terminal