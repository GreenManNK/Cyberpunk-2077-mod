part_transmission_s1_shortshiftkit = { 
    description = "Part - Transmission - Short Shift Kit"
}

function part_transmission_s1_shortshiftkit.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "gearChangeCooldown"
	Modifiers[0].ModifierValue = 0.9
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "VehicleEngineData"
	Modifiers[1].VariableName = "gearChangeTime"
	Modifiers[1].ModifierValue = 0.9
	Modifiers[1].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Transmission"
	Part.ID = 0301
	Part.Name = "Short Shift Kit"
	Part.SuperType = 0301
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 100
	Part.Desc = "Medium Gear Change Time Reduction"
	
	return Part
	
end

return part_transmission_s1_shortshiftkit