local CMSLocation_SDM = {
    description = "Santo Domingo"
}

function CMSLocation_SDM.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(245.97, -1470.49, 9.53, 1.0)

    Location.PosX1 = 237
    Location.PosX2 = 243
    Location.PosY1 = -1467
    Location.PosY2 = -1460
    Location.PosZ1 = 0
    Location.PosZ2 = 20

    Location.FinalPos = Vector4.new(239.68, -1464.39, 11.03, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, 145.30)

    return Location
end

return CMSLocation_SDM
