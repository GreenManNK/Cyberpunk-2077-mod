part_ecu_s3_enginemanagementunit = { 
    description = "Part - Ecu - Engine Management Unit"
}

function part_ecu_s3_enginemanagementunit.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.28
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "VehicleEngineData"
	Modifiers[1].VariableName = "maxRPM"
	Modifiers[1].ModifierValue = 500
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Ecu"
	Part.ID = 0206
	Part.Name = "Engine Management Unit"
	Part.SuperType = 0204
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 3500
	Part.Desc = "Extreme Engine Torque Increase"
	
	return Part
	
end

return part_ecu_s3_enginemanagementunit