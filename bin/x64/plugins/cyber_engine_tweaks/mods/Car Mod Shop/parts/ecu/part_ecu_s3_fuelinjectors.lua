part_ecu_s3_fuelinjectors = { 
    description = "Part - Ecu - Fuel Injectors"
}

function part_ecu_s3_fuelinjectors.getPart()
	
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
	Part.Type = "Ecu"
	Part.ID = 0207
	Part.Name = "Fuel Injectors"
	Part.SuperType = 0206
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 1000
	Part.Desc = "Medium Engine Torque Increase"
	
	return Part
	
end

return part_ecu_s3_fuelinjectors