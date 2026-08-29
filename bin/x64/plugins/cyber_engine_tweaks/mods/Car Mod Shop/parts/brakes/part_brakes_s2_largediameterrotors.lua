part_brakes_s2_largediameterrotors = { 
    description = "Part - Brakes - Large Diameter Rototrs"
}

function part_brakes_s2_largediameterrotors.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "maxBrakingTorque"
	Modifiers[0].ModifierValue = 500
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "maxBrakingTorque"
	Modifiers[1].ModifierValue = 500
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Brakes"
	Part.ID = 0604
	Part.Name = "Large Diameter Rototrs"
	Part.SuperType = 0603
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 1500
	Part.Desc = "Large Brake Torque Increase"
	
	return Part
	
end

return part_brakes_s2_largediameterrotors