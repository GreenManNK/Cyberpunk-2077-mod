part_brakes_s3_crossdrilledandslottedrotors = { 
    description = "Part - Brakes - Cross Drilled And Slotted Rotors"
}

function part_brakes_s3_crossdrilledandslottedrotors.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "maxBrakingTorque"
	Modifiers[0].ModifierValue = 1.10
	Modifiers[0].ModifierType = "Mult"

	--Old system
	--Modifiers[0].ModifierValue = 1000
	--Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "maxBrakingTorque"
	Modifiers[1].ModifierValue = 1.10
	Modifiers[1].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Brakes"
	Part.ID = 0606
	Part.Name = "Cross Drilled And Slotted Rotors"
	Part.SuperType = 0603
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 2000
	Part.Desc = "Extreme Brake Torque Increase"
	
	return Part
	
end

return part_brakes_s3_crossdrilledandslottedrotors