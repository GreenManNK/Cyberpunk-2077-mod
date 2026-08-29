part_engine_s2_largerdiameterdownpipe = { 
    description = "Part - Engine - Larger Diameter Downpipe"
}

function part_engine_s2_largerdiameterdownpipe.getPart()
	
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
	Part.ID = 0107
	Part.Name = "Larger Diameter Downpipe"
	Part.SuperType = 0106
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.Desc = "Small Engine Torque Increase"
	
	return Part
	
end

return part_engine_s2_largerdiameterdownpipe