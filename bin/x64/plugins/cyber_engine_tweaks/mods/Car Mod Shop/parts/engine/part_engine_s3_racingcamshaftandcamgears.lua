part_engine_s3_racingcamshaftandcamgears = { 
    description = "Part - Engine - Racing Camshaft and Cam Gears"
}

function part_engine_s3_racingcamshaftandcamgears.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.05
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0108
	Part.Name = "Racing Camshaft and Cam Gears"
	Part.SuperType = 0103
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.Desc = "Medium Engine Torque Increase"
	
	return Part
	
end

return part_engine_s3_racingcamshaftandcamgears