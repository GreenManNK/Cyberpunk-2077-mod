part_transmission_s2_highperformanceclutch = { 
    description = "Part - Transmission - High Performance Clutch"
}

function part_transmission_s2_highperformanceclutch.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "gearChangeCooldown"
	Modifiers[0].ModifierValue = 0.8
	Modifiers[0].ModifierType = "Mult"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "VehicleEngineData"
	Modifiers[1].VariableName = "gearChangeTime"
	Modifiers[1].ModifierValue = 0.8
	Modifiers[1].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Transmission"
	Part.ID = 0305
	Part.Name = "High Performance Clutch"
	Part.SuperType = 0304
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 1500
	Part.Desc = "Large Gear Change Time Reduction"
	
	return Part
	
end

return part_transmission_s2_highperformanceclutch