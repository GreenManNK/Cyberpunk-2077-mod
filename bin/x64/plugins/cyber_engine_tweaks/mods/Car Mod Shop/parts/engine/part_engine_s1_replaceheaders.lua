part_engine_s1_replaceheaders = { 
    description = "Part - Engine - Replace Headers"
}

function part_engine_s1_replaceheaders.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.04
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0102
	Part.Name = "Replace Headers"
	Part.SuperType = 0102
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.Desc = "Small Engine Torque Increase"
	
	return Part
	
end

return part_engine_s1_replaceheaders