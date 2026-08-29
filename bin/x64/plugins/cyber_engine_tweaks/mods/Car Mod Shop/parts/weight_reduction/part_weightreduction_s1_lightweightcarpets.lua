part_weightreduction_s1_lightweightcarpets = { 
    description = "Part - Weight Reduction - Lightweight Carpets"
}

function part_weightreduction_s1_lightweightcarpets.getPart()
	
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
	Part.ID = 0801
	Part.Name = "Lightweight Carpets"
	Part.SuperType = 0801
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 100
	Part.EnabledForBikes = false
	Part.Desc = "Small Weight Reduction"
	
	return Part
	
end

return part_weightreduction_s1_lightweightcarpets