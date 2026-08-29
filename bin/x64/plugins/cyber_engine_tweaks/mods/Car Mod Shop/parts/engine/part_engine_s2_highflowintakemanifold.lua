part_engine_s2_highflowintakemanifold = { 
    description = "Part - Engine - High Flow Intake Manifold"
}

function part_engine_s2_highflowintakemanifold.getPart()
	
	--Part Specification
	--Use Addition/Multiplication
	Part = {}
	
	--Part modifiers
	Modifiers = {}
	
	Modifiers[0] = {}
	Modifiers[0].RecordType = "VehicleEngineData"
	Modifiers[0].VariableName = "engineMaxTorque"
	Modifiers[0].ModifierValue = 1.04
	Modifiers[0].ModifierType = "Mult"
	
	--Part Type
	Part.Type = "Engine"
	Part.ID = 0106
	Part.Name = "High Flow Intake Manifold"
	Part.SuperType = 0105
	Part.Stage = 2
	Part.SubModifiers = Modifiers
	Part.Price = 500
	Part.Desc = "Small Engine Torque Increase"
	
	return Part
	
end

return part_engine_s2_highflowintakemanifold