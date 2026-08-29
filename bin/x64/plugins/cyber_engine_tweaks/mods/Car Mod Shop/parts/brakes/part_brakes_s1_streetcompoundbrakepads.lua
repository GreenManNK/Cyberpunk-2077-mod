part_brakes_s1_streetcompoundbrakepads = { 
    description = "Part - Brakes - Street Compound Brake Pads"
}

function part_brakes_s1_streetcompoundbrakepads.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "maxBrakingTorque"
	Modifiers[0].ModifierValue = 1.015
	Modifiers[0].ModifierType = "Mult"

	--Old system
	--Modifiers[0].ModifierValue = 200
	--Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "maxBrakingTorque"
	Modifiers[1].ModifierValue = 1.015
	Modifiers[1].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Brakes"
	Part.ID = 0601
	Part.Name = "Street Compound Brake Pads"
	Part.SuperType = 0601
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.Desc = "Medium Brake Torque Increase"
	
	return Part
	
end

return part_brakes_s1_streetcompoundbrakepads