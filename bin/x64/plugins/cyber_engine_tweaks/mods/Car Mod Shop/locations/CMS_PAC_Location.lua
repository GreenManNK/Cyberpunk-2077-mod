local CMSLocation_Pac = {
    description = "Oficina Pacifica (Pac)"
}

function CMSLocation_Pac.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(-1560.18, -1883.36, 74.00, 1.0)

    Location.PosX1 = -1560
    Location.PosX2 = -1554
    Location.PosY1 = -1886
    Location.PosY2 = -1880
    Location.PosZ1 = 60
    Location.PosZ2 = 94

    Location.FinalPos = Vector4.new(-1560.18, -1883.36, 75.50, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, 68.55)

    return Location
end

return CMSLocation_Pac
