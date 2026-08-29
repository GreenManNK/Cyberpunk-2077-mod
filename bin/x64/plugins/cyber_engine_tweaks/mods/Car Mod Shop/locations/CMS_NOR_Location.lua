local CMSLocation_North = {
    description = "Oficina Norte (North)"
}

function CMSLocation_North.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(-1307.37, 2691.93, 7.07, 1.0)

    Location.PosX1 = -1308
    Location.PosX2 = -1306
    Location.PosY1 = 2691
    Location.PosY2 = 2694
    Location.PosZ1 = 0
    Location.PosZ2 = 20

    Location.FinalPos = Vector4.new(-1307.37, 2691.93, 8.57, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, 145.30)

    return Location
end

return CMSLocation_North
