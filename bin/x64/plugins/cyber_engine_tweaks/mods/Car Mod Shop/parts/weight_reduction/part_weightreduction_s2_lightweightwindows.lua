part_weightreduction_s2_lightweightwindows = { 
    description = "Part - Weight Reduction - Lightweight Windows"
}

function part_weightreduction_s2_lightweightwindows.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleDriveModelData"
	Modifiers[0].VariableName = "chassis_mass"
	Modifiers[0].ModifierValue = 0.985
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "VehicleDriveModelData"
	Modifiers[1].VariableName = "total_mass"
	Modifiers[1].ModifierValue = 0.985
	Modifiers[1].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Weight Reduction"
	Part.ID = 0803
	Part.Name = "Lightweight Windows"
	Part.SuperType = 0803
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 1000
	Part.EnabledForBikes = false
	Part.Desc = "Medium Weight Reduction"
	
	return Part
	
end

return part_weightreduction_s2_lightweightwindows