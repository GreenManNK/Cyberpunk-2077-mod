local CMSLocation_GLE = {
    description = "Oficina The Glen (GLE)"
}

function CMSLocation_GLE.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(-1431.75, -1289.84, 46.84, 1.0)

    Location.PosX1 = -1441
    Location.PosX2 = -1421
    Location.PosY1 = -1294
    Location.PosY2 = -1284
    Location.PosZ1 = 42
    Location.PosZ2 = 50

    Location.FinalPos = Vector4.new(-1431.75, -1289.84, 48.34, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, 177.80)

    return Location
end

return CMSLocation_GLE
