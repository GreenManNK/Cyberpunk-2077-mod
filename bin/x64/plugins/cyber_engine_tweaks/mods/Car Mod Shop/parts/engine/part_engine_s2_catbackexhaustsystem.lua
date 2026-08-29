part_engine_s2_catbackexhaustsystem = { 
    description = "Part - Engine - Cat Back Exhaust System"
}

function part_engine_s2_catbackexhaustsystem.getPart()
	
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
	Part.ID = 0105
	Part.Name = "Cat Back Exhaust System"
	Part.SuperType = 0104
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 1000
	Part.Desc = "Medium Engine Torque Increase"
	
	return Part
	
end

return part_engine_s2_catbackexhaustsystem