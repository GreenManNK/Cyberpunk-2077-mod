local CMSLocation_JIG = {
    description = "JigJig oficina"
}

function CMSLocation_JIG.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(-719.87, 860.86, 20.84, 1.0)

    Location.PosX1 = -792
    Location.PosX2 = -783
    Location.PosY1 = 940
    Location.PosY2 = 945
    Location.PosZ1 = 0
    Location.PosZ2 = 20

    Location.FinalPos = Vector4.new(-790.81, 942.75, 14.87, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, -0.66)

    return Location
end

return CMSLocation_JIG