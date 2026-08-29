part_engine_s3_highflowheaders = { 
    description = "Part - Engine - High Flow Headers"
}

function part_engine_s3_highflowheaders.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.06
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0111
	Part.Name = "High Flow Headers"
	Part.SuperType = 0102
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.Desc = "Medium Engine Torque Increase"
	
	return Part
	
end

return part_engine_s3_highflowheaders