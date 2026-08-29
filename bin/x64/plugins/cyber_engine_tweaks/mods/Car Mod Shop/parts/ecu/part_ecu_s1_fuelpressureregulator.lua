part_ecu_s1_fuelpressureregulator = { 
    description = "Part - Ecu - Fuel Pressure Regulator"
}

function part_ecu_s1_fuelpressureregulator.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.14
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Ecu"
	Part.ID = 0201
	Part.Name = "Fuel Pressure Regulator"
	Part.SuperType = 0201
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.Desc = "Medium Engine Torque Increase"
	
	return Part
	
end

return part_ecu_s1_fuelpressureregulator