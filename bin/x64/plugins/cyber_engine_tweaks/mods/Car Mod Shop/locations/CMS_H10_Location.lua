local CMSLocation_OficinaH10 = {
    description = "H10"
}

function CMSLocation_OficinaH10.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(-1378.09, 1265.08, 23.71, 1.0)

    Location.PosX1 = -1381
    Location.PosX2 = -1375
    Location.PosY1 = 1262
    Location.PosY2 = 1268
    Location.PosZ1 = 20
    Location.PosZ2 = 30

    Location.FinalPos = Vector4.new(-1378.09, 1265.08, 25.21, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, -184.60)

    return Location
end

return CMSLocation_OficinaH10
