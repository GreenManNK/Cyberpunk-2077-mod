part_tires_s1_tires = { 
    description = "Part - Turbo - Street Performance Tires"
}

function part_tires_s1_tires.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "frictionMulLateral"
	Modifiers[0].ModifierValue = 1.10
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "FrontWheelSuspension"
	Modifiers[1].VariableName = "frictionMulLongitudinal"
	Modifiers[1].ModifierValue = 1.10
	Modifiers[1].ModifierType = "Mult"
	
	Modifiers[2] = {}
	Modifiers[2].RecordType = "RearWheelSuspension"
	Modifiers[2].VariableName = "frictionMulLateral"
	Modifiers[2].ModifierValue = 1.10
	Modifiers[2].ModifierType = "Mult"
	
	Modifiers[3] = {}
	Modifiers[3].RecordType = "RearWheelSuspension"
	Modifiers[3].VariableName = "frictionMulLongitudinal"
	Modifiers[3].ModifierValue = 1.10
	Modifiers[3].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Tires"
	Part.ID = 0501
	Part.Name = "Street Performance Tires"
	Part.SuperType = 0501
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.Desc = "Medium Tire Grip Improvement"
	
	return Part
	
end

return part_tires_s1_tires