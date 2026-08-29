part_brakes_s1_crossdrilledrotors = { 
    description = "Part - Brakes - Cross Drilled Rotors"
}

function part_brakes_s1_crossdrilledrotors.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "maxBrakingTorque"
	Modifiers[0].ModifierValue = 1.025
	Modifiers[0].ModifierType = "Mult"

	--Old system
	--Modifiers[0].ModifierValue = 200
	--Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "maxBrakingTorque"
	Modifiers[1].ModifierValue = 1.025
	Modifiers[1].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Brakes"
	Part.ID = 0603
	Part.Name = "Cross Drilled Rotors"
	Part.SuperType = 0603
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.Desc = "Medium Brake Torque Increase"
	
	return Part
	
end

return part_brakes_s1_crossdrilledrotors