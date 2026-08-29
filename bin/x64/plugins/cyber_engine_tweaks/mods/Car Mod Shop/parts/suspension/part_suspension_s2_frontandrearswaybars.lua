part_suspension_s2_frontandrearswaybars = { 
    description = "Part - Suspension - Front and Rear Swaybars"
}

function part_suspension_s2_frontandrearswaybars.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "FrontWheelSuspension"
	Modifiers[0].VariableName = "swaybarStiffness"
	Modifiers[0].ModifierValue = 4
	Modifiers[0].ModifierType = "Add"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "RearWheelSuspension"
	Modifiers[1].VariableName = "swaybarStiffness"
	Modifiers[1].ModifierValue = 4
	Modifiers[1].ModifierType = "Add"
	
	--Part Type
	Part.Type = "Suspension"
	Part.ID = 0404
	Part.Name = "Front and Rear Swaybars"
	Part.SuperType = 0403
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 1000
	Part.EnabledForBikes = false
	Part.Desc = "Small Swaybar Stiffness Improvement"
	
	return Part
	
end

return part_suspension_s2_frontandrearswaybars