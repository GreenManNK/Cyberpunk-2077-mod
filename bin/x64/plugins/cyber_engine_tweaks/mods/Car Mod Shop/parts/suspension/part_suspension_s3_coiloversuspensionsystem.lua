part_suspension_s3_coiloversuspensionsystem = { 
    description = "Part - Suspension - Coilover Suspension System"
}

function part_suspension_s3_coiloversuspensionsystem.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "wheelsVerticalOffset"
	Modifiers[0].ModifierValue = -0.03
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "wheelsVerticalOffset"
	Modifiers[1].ModifierValue = -0.03
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Suspension"
	Part.ID = 0405
	Part.Name = "Coilover Suspension System"
	Part.SuperType = 0401
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 4000
	Part.EnabledForBikes = false
	Part.Desc = "Large Height Reduction"
	
	return Part
	
end

return part_suspension_s3_coiloversuspensionsystem