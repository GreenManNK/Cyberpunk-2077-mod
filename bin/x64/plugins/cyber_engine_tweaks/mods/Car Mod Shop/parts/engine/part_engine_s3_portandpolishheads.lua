part_engine_s3_portandpolishheads = { 
    description = "Part - Engine - Port and Polish Heads"
}

function part_engine_s3_portandpolishheads.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.0625
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0109
	Part.Name = "Port and Polish Heads"
	Part.SuperType = 0107
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 1000
	Part.Desc = "Medium Engine Torque Increase"
	
	return Part
	
end

return part_engine_s3_portandpolishheads