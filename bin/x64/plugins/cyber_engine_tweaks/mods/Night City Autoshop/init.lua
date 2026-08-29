local STATIC_PIN = 'Mappins.PointOfInterest_ServicePointTechVariant'

local MAPPIN_GROUP_PATHS = {
    "WorldMap.DropPointFilterGroup.mappins",
    "Mappins.DropPointDynamicMappin.possibleVariants",
    "Mappins.DropPointStaticMappin.possibleVariants",
    "WorldMap.JobsFilterGroup.mappins",
    "WorldMap.AllServicePointsFilterGroup.mappins"
}

function AddMappinToGroup(groupPath, pinRecord)
    local pinList = TweakDB:GetFlat(groupPath)
    if not pinList then pinList = {} end

    local pinID = TweakDBID.new(pinRecord)
    local isNewPin = true

    for _, existingPin in pairs(pinList) do
        if existingPin == pinID then
            isNewPin = false
            break
        end
    end

    if isNewPin then
        table.insert(pinList, pinID)
    end

    TweakDB:SetFlat(groupPath, pinList)
end

function RegisterMappinToFilters()
    for _, groupPath in ipairs(MAPPIN_GROUP_PATHS) do
        AddMappinToGroup(groupPath, STATIC_PIN)
    end
end

registerForEvent("onInit", RegisterMappinToFilters)