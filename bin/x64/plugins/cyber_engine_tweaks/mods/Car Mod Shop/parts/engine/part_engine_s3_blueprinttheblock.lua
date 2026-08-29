part_engine_s3_blueprinttheblock = { 
    description = "Part - Engine - Blueprint the Block"
}

function part_engine_s3_blueprinttheblock.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.075
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0110
	Part.Name = "Blueprint the Block"
	Part.SuperType = 0108
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 1500
	Part.Desc = "Medium Engine Torque Increase"
	
	return Part
	
end

return part_engine_s3_blueprinttheblock