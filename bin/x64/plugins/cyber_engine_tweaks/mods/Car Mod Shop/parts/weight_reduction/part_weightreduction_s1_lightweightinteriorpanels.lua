part_weightreduction_s1_lightweightinteriorpanels = { 
    description = "Part - Weight Reduction - Lightweight Interior Panels"
}

function part_weightreduction_s1_lightweightinteriorpanels.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleDriveModelData"
	Modifiers[0].VariableName = "chassis_mass"
	Modifiers[0].ModifierValue = 0.990
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "VehicleDriveModelData"
	Modifiers[1].VariableName = "total_mass"
	Modifiers[1].ModifierValue = 0.990
	Modifiers[1].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Weight Reduction"
	Part.ID = 0802
	Part.Name = "Lightweight Interior Panels"
	Part.SuperType = 0802
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 250
	Part.EnabledForBikes = false
	Part.Desc = "Small Weight Reduction"
	
	return Part
	
end

return part_weightreduction_s1_lightweightinteriorpanels