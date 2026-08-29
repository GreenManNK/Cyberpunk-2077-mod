part_ecu_s1_fuelfilter = { 
    description = "Part - Ecu - Fuel Filter"
}

function part_ecu_s1_fuelfilter.getPart()
	
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
	Part.ID = 0203
	Part.Name = "Fuel Filter"
	Part.SuperType = 0203
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.Desc = "Small Engine Torque Increase"
	
	return Part
	
end

return part_ecu_s1_fuelfilter