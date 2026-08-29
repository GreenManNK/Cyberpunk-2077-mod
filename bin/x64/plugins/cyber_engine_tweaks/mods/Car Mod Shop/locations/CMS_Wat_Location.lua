local CMSLocation_Wat = {
    description = "Oficina Wat (Carro)"
}

function CMSLocation_Wat.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(-1120.96, 1208.00, 17.06, 1.0)

    Location.PosX1 = -1119
    Location.PosX2 = -1114
    Location.PosY1 = 1198
    Location.PosY2 = 1204
    Location.PosZ1 = 10
    Location.PosZ2 = 25

    Location.FinalPos = Vector4.new(-1120.96, 1208.00, 18.56, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, 265.62)

    return Location
end

return CMSLocation_Wat