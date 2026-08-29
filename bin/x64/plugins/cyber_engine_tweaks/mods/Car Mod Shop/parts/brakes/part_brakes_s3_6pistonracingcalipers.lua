part_brakes_s3_6pistonbrakecalipers = { 
    description = "Part - Brakes - 6 Piston Racing Calipers"
}

function part_brakes_s3_6pistonbrakecalipers.getPart()
	
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
	Part.ID = 0607
	Part.Name = "6 Piston Racing Calipers"
	Part.SuperType = 0604
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 2000
	Part.Desc = "Extreme Brake Torque Increase"
	
	return Part
	
end

return part_brakes_s3_6pistonbrakecalipers