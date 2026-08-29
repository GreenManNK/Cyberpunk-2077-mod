part_tires_s2_tires = { 
    description = "Part - Turbo - Pro Performance Tires"
}

function part_tires_s2_tires.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "frictionMulLateral"
	Modifiers[0].ModifierValue = 1.20
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "FrontWheelSuspension"
	Modifiers[1].VariableName = "frictionMulLongitudinal"
	Modifiers[1].ModifierValue = 1.20
	Modifiers[1].ModifierType = "Mult"
	
	Modifiers[2] = {}
	Modifiers[2].RecordType = "RearWheelSuspension"
	Modifiers[2].VariableName = "frictionMulLateral"
	Modifiers[2].ModifierValue = 1.20
	Modifiers[2].ModifierType = "Mult"
	
	Modifiers[3] = {}
	Modifiers[3].RecordType = "RearWheelSuspension"
	Modifiers[3].VariableName = "frictionMulLongitudinal"
	Modifiers[3].ModifierValue = 1.20
	Modifiers[3].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Tires"
	Part.ID = 0502
	Part.Name = "Pro Performance Tires"
	Part.SuperType = 0501
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 1500
	Part.Desc = "Large Tire Grip Improvement"
	
	return Part
	
end

return part_tires_s2_tires