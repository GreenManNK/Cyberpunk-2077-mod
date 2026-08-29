part_brakes_s1_steelbraidedbrakelines = { 
    description = "Part - Brakes - Steel Braided Brake Lines"
}

function part_brakes_s1_steelbraidedbrakelines.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "maxBrakingTorque"
	Modifiers[0].ModifierValue = 100
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "maxBrakingTorque"
	Modifiers[1].ModifierValue = 100
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Brakes"
	Part.ID = 0602
	Part.Name = "Steel Braided Brake Lines"
	Part.SuperType = 0602
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.Desc = "Small Brake Torque Increase"
	
	return Part
	
end

return part_brakes_s1_steelbraidedbrakelines