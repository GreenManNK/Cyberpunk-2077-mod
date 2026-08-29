local CMSLocation_SUM = {
    description = "Sunset Oficina"
}

function CMSLocation_SUM.getLocation()

    local Location = {}

    --Location.Position = Vector4.new(1701.22, -757.06, 51.39, 1.0)

    Location.PosX1 = 1707
    Location.PosX2 = 1715
    Location.PosY1 = -758
    Location.PosY2 = -750
    Location.PosZ1 = 30
    Location.PosZ2 = 80

    Location.FinalPos = Vector4.new(1701.22, -757.06, 51.39, 1.0)

    Location.FinalRot = EulerAngles.new(0, 0, 104.43)

    return Location
end

return CMSLocation_SUM
