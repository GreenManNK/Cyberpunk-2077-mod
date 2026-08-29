part_engine_s1_coldairintake = { 
    description = "Part - Engine - Cold Air Intake"
}

function part_engine_s1_coldairintake.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.03
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0101
	Part.Name = "Cold Air Intake"
	Part.SuperType = 0101
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.Desc = "Small Engine Torque Increase"
	
	return Part
	
end

return part_engine_s1_coldairintake