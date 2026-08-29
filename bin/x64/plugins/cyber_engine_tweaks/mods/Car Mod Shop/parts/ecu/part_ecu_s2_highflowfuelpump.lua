part_ecu_s2_highflowfuelpump = { 
    description = "Part - Ecu - High Flow Fuel Pump"
}

function part_ecu_s2_highflowfuelpump.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.055
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Ecu"
	Part.ID = 0205
	Part.Name = "High Flow Fuel Pump"
	Part.SuperType = 0205
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.Desc = "Small Engine Torque Increase"
	
	return Part
	
end

return part_ecu_s2_highflowfuelpump