part_suspension_s2_performancespringsandshocks = { 
    description = "Part - Suspension - Performance Springs and Shocks"
}

function part_suspension_s2_performancespringsandshocks.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "wheelsVerticalOffset"
	Modifiers[0].ModifierValue = -0.02
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "wheelsVerticalOffset"
	Modifiers[1].ModifierValue = -0.02
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Suspension"
	Part.ID = 0403
	Part.Name = "Performance Springs and Shocks"
	Part.SuperType = 0401
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 2000
	Part.EnabledForBikes = false
	Part.Desc = "Medium Height Reduction"
	
	return Part
	
end

return part_suspension_s2_performancespringsandshocks