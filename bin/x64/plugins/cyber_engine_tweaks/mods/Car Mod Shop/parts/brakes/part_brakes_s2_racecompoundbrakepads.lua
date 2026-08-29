part_brakes_s2_racecompoundbrakepads = { 
    description = "Part - Brakes - Race Compound Brake Pads"
}

function part_brakes_s2_racecompoundbrakepads.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "maxBrakingTorque"
	Modifiers[0].ModifierValue = 750
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "maxBrakingTorque"
	Modifiers[1].ModifierValue = 750
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Brakes"
	Part.ID = 0605
	Part.Name = "Race Compound Brake Pads"
	Part.SuperType = 0601
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 1000
	Part.Desc = "Large Brake Torque Increase"
	
	return Part
	
end

return part_brakes_s2_racecompoundbrakepads