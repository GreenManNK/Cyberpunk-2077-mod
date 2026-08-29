local CMSLocation_CC = {
    description = "Oficina Centro"
}

function CMSLocation_CC.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(-2123.20, 532.57, 10.29, 1.0)

    Location.PosX1 = -2126
    Location.PosX2 = -2120
    Location.PosY1 = 529
    Location.PosY2 = 536
    Location.PosZ1 = 5
    Location.PosZ2 = 20

    Location.FinalPos = Vector4.new(-2123.20, 532.57, 11.79, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, 0.00)

    return Location
end

return CMSLocation_CC