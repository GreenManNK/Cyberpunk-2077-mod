part_suspension_s1_sportspringsandshocks = { 
    description = "Part - Suspension - Sport Springs and Shocks"
}

function part_suspension_s1_sportspringsandshocks.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "wheelsVerticalOffset"
	Modifiers[0].ModifierValue = -0.01
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "wheelsVerticalOffset"
	Modifiers[1].ModifierValue = -0.01
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Suspension"
	Part.ID = 0401
	Part.Name = "Sport Springs and Shocks"
	Part.SuperType = 0401
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.EnabledForBikes = false
	Part.Desc = "Small Height Reduction"
	
	return Part
	
end

return part_suspension_s1_sportspringsandshocks