part_ecu_s2_performancechip = { 
    description = "Part - Ecu - Performance Chip"
}

function part_ecu_s2_performancechip.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.20
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Ecu"
	Part.ID = 0204
	Part.Name = "Performance Chip"
	Part.SuperType = 0204
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 1000
	Part.Desc = "Large Engine Torque Increase"
	
	return Part
	
end

return part_ecu_s2_performancechip