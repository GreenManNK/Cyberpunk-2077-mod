part_transmission_s1_lightweightflywheel = { 
    description = "Part - Transmission - Lightweight Flywheel"
}

function part_transmission_s1_lightweightflywheel.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "flyWheelMomentOfInertia"
	Modifiers[0].ModifierValue = 0.75
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Transmission"
	Part.ID = 0302
	Part.Name = "Lightweight Flywheel"
	Part.SuperType = 0302
	Part.Stage = 1
	Part.SubModifiers = Modifiers
	Part.Price = 400
	Part.Desc = "Large Flywheel Weight Reduction"
	
	return Part
	
end

return part_transmission_s1_lightweightflywheel