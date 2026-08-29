local CMSLocation_Tire = {
    description = "Santo Domingo - Tire Empire"
}

function CMSLocation_Tire.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(-1023.13, -1705.49, 12.52, 1.0)

    Location.PosX1 = -1032
    Location.PosX2 = -1024
    Location.PosY1 = -1715
    Location.PosY2 = -1710
    Location.PosZ1 = 0
    Location.PosZ2 = 20

    Location.FinalPos = Vector4.new(-1023.13, -1705.49, 12.52, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, -36.80)

    return Location
end

return CMSLocation_Tire