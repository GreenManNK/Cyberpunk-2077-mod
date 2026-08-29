local CMSLocation_Rocky = {
    description = "Rocky Ridge"
}

function CMSLocation_Rocky.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(2579.06, -13.72, 80.82, 1.0)

    Location.PosX1 = 2576
    Location.PosX2 = 2578
    Location.PosY1 = -14
    Location.PosY2 = -10
    Location.PosZ1 = 70
    Location.PosZ2 = 100

    Location.FinalPos = Vector4.new(2579.06, -13.72, 82.82, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, 222.30)

    return Location
end

return CMSLocation_Rocky