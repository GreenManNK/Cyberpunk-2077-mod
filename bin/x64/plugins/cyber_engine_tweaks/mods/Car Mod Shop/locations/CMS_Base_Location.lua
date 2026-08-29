CMSLocation_Base = { 
    description = "CMS Location - Base"
}

function CMSLocation_Base.getLocation()
	
	--Location Specification
	Location = {}
	
	--Location Type
	--Position/Essentially map pin position
	Location.Position = Vector4.new(-773.45, 2968.5, 27.5, 1.0)

	--Bounding Box
	--Why specific position rather than auto calculated position from map pin center? Because lets say you have a map pin in front of a garage, and you want the player to only upgrade inside of the garage.
	--Also I added height, even though its essentially useless and wastes cpu performance, but its for you goobers if you ever decide to put it in the friggin sky or something...
	--Logic: CurrentPos is More than Axis1, and Less than Axis2
	--Logic Example: CurrentPos > X1, and CurrentPos < X2
	Location.PosX1 = -782
	Location.PosX2 = -772
	Location.PosY1 = 2965
	Location.PosY2 = 2977
	Location.PosZ1 = 0
	Location.PosZ2 = 50

	--Teleportation Position/Rotation
	Location.FinalPos = Vector4.new(-768.80, 2971.57, 26.55, 1.0)
	Location.FinalRot = EulerAngles.new(0,0,290)
	
	return Location
	
end

return CMSLocation_Base