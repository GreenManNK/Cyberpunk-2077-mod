part_engine_s1_mildcamshaftandcamgears = { 
    description = "Part - Engine - Mild Camshaft and Cam Gears"
}

function part_engine_s1_mildcamshaftandcamgears.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.035
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0103
	Part.Name = "Mild Camshaft and Cam Gears"
	Part.SuperType = 0103
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.Desc = "Small Engine Torque Increase"
	
	return Part
	
end

return part_engine_s1_mildcamshaftandcamgears