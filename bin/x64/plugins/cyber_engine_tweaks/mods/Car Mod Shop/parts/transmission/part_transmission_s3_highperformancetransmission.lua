part_transmission_s3_highperformancetransmission = { 
    description = "Part - Transmission - High Performance Transmission"
}

function part_transmission_s3_highperformancetransmission.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "gears"
	Modifiers[0].ModifierValue = 1.20
	Modifiers[0].ModifierType = "AddGear"
	
	Modifiers[1] = {}
	Modifiers[1].RecordType = "VehicleGearData"
	Modifiers[1].VariableName = "minSpeed"
	Modifiers[1].ModifierValue = 1.20
	Modifiers[1].ModifierType = "Mult"
	
	Modifiers[2] = {}
	Modifiers[2].RecordType = "VehicleGearData"
	Modifiers[2].VariableName = "maxSpeed"
	Modifiers[2].ModifierValue = 1.20
	Modifiers[2].ModifierType = "Mult"
	
	Modifiers[3] = {}
	Modifiers[3].RecordType = "VehicleGearData"
	Modifiers[3].VariableName = "torqueMultiplier"
	Modifiers[3].ModifierValue = 0.96
	Modifiers[3].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Transmission"
	Part.ID = 0306
	Part.Name = "High Performance Transmission"
	Part.SuperType = 0305
	Part.Stage = 3
	Part.SubModifiers = Modifiers
	Part.Price = 5000
	Part.Desc = "Adds A Gear, Improves Top Speed"
	
	return Part
	
end

return part_transmission_s3_highperformancetransmission