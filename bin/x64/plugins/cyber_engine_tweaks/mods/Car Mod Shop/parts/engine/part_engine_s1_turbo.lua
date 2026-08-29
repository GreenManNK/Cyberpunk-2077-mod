part_engine_s1_turbo = { 
    description = "Part - Engine - Stage 1 Turbo"
}

function part_engine_s1_turbo.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.08
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "VehicleDataPackage"
	Modifiers[1].VariableName = "hasTurboCharger"
	Modifiers[1].ModifierValue = true
	Modifiers[1].ModifierType = "Bool"
		
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0121
	Part.Name = "Stage 1 Turbo System"
	Part.SuperType = 0110
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 1000
	Part.Desc = "Medium Engine Torque Increase"
	
	return Part
	
end

return part_engine_s1_turbo