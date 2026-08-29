part_suspension_s1_struttowerbar = { 
    description = "Part - Suspension - Strut Tower Bar"
}

function part_suspension_s1_struttowerbar.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "mass"
	Modifiers[0].ModifierValue = 5
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "mass"
	Modifiers[1].ModifierValue = 5
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Suspension"
	Part.ID = 0402
	Part.Name = "Strut Tower Bar"
	Part.SuperType = 0402
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.EnabledForBikes = false
	Part.Desc = "Small Suspension Improvement"
	
	return Part
	
end

return part_suspension_s1_struttowerbar