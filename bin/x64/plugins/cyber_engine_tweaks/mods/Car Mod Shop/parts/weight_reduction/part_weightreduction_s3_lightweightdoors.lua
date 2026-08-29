part_weightreduction_s3_lightweightdoors = { 
    description = "Part - Weight Reduction - Lightweight Doors"
}

function part_weightreduction_s3_lightweightdoors.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleDriveModelData"
	Modifiers[0].VariableName = "chassis_mass"
	Modifiers[0].ModifierValue = 0.975
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "VehicleDriveModelData"
	Modifiers[1].VariableName = "total_mass"
	Modifiers[1].ModifierValue = 0.975
	Modifiers[1].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Weight Reduction"
	Part.ID = 0805
	Part.Name = "Lightweight Doors"
	Part.SuperType = 0805
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 2500
	Part.EnabledForBikes = false
	Part.Desc = "Large Weight Reduction"
	
	return Part
	
end

return part_weightreduction_s3_lightweightdoors