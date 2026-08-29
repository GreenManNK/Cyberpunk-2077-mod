part_ecu_s1_fuelrail = { 
    description = "Part - Ecu - Fuel Rail"
}

function part_ecu_s1_fuelrail.getPart()
	
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
	Part.Type = "Ecu"
	Part.ID = 0202
	Part.Name = "Fuel Rail"
	Part.SuperType = 0202
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.Desc = "Small Engine Torque Increase"
	
	return Part
	
end

return part_ecu_s1_fuelrail