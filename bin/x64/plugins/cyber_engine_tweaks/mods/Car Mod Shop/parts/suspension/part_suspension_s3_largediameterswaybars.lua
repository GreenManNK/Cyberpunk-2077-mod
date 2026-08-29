part_suspension_s3_largediameterswaybars = { 
    description = "Part - Suspension - Large Diameter Swaybars"
}

function part_suspension_s3_largediameterswaybars.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "swaybarStiffness"
	Modifiers[0].ModifierValue = 8
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "swaybarStiffness"
	Modifiers[1].ModifierValue = 8
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Suspension"
	Part.ID = 0406
	Part.Name = "Large Diameter Swaybars"
	Part.SuperType = 0403
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 2000
	Part.EnabledForBikes = false
	Part.Desc = "Large Swaybar Stiffness Improvement"
	
	return Part
	
end

return part_suspension_s3_largediameterswaybars