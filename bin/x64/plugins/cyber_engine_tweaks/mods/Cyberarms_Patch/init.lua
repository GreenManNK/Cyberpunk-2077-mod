-- CYBERARMS PATCH v1.1
-- Makes male cyberarms use male meshes, and female cyberarms use female meshes

registerForEvent("onInit", function()
    Observe("PlayerPuppet", "OnGameAttached", function(this)
        if not this:IsReplacer() then
            local gender = NameToString(this:GetResolvedGenderName())
            if gender == "Male" then

				-- Gorilla Knuckles - By default male characters use female knuckles
				TweakDB:SetFlat("Items.PhysicalDamageKnuckles.appearanceResourceName", "a0_005_ma__strongarms_knuckles")
				TweakDB:SetFlat("Items.ChemicalDamageKnuckles.appearanceResourceName", "a0_005_ma__strongarms_knuckles")
				TweakDB:SetFlat("Items.ElectricDamageKnuckles.appearanceResourceName", "a0_005_ma__strongarms_knuckles")
				TweakDB:SetFlat("Items.ThermalDamageKnuckles.appearanceResourceName", "a0_005_ma__strongarms_knuckles")
				TweakDB:SetFlat("Items.AnimalsStrongArmsKnuckles1.appearanceResourceName", "a0_005_ma__strongarms_knuckles")

				-- Mantis Blades - Originally male characters used female blades and mechanisms
				TweakDB:SetFlat("Items.PhysicalDamageEdge.appearanceResourceName", "a0_003_ma__mantisblades_edges")
				TweakDB:SetFlat("Items.ChemicalDamageEdge.appearanceResourceName", "a0_003_ma__mantisblades_edges")
				TweakDB:SetFlat("Items.ElectricDamageEdge.appearanceResourceName", "a0_003_ma__mantisblades_edges")
				TweakDB:SetFlat("Items.ThermalDamageEdge.appearanceResourceName", "a0_003_ma__mantisblades_edges")
				TweakDB:SetFlat("Items.MaxTacEdge.appearanceResourceName", "a0_003_ma__mantisblades_edges")

				-- Launcher Mechanisms
				TweakDB:SetFlat("Items.ExplosiveDamageRound.appearanceResourceName", "a0_006_ma__launcher_fragment")
				TweakDB:SetFlat("Items.ChemicalDamageRound.appearanceResourceName", "a0_006_ma__launcher_fragment")
				TweakDB:SetFlat("Items.ElectricDamageRound.appearanceResourceName", "a0_006_ma__launcher_fragment")
				TweakDB:SetFlat("Items.ThermalDamageRound.appearanceResourceName", "a0_006_ma__launcher_fragment")
				TweakDB:SetFlat("Items.TranquilizerRound.appearanceResourceName", "a0_006_ma__launcher_fragment")
				TweakDB:SetFlat("Items.MilitechProjectileLauncherRound1.appearanceResourceName", "a0_006_ma__launcher_fragment")

				-- Monowires - Originally male characters used female wires
				TweakDB:SetFlat("Items.PhysicalDamageCable.appearanceResourceName", "a0_002_ma__monowire_whip_cable")
				TweakDB:SetFlat("Items.ChemicalDamageCable.appearanceResourceName", "a0_002_ma__monowire_whip_cable")
				TweakDB:SetFlat("Items.ElectricDamageCable.appearanceResourceName", "a0_002_ma__monowire_whip_cable")
				TweakDB:SetFlat("Items.ThermalDamageCable.appearanceResourceName", "a0_002_ma__monowire_whip_cable")
				
            else

				-- Gorilla Knuckles
				TweakDB:SetFlat("Items.PhysicalDamageKnuckles.appearanceResourceName", "a0_005_wa__strongarms_knuckles")
				TweakDB:SetFlat("Items.ChemicalDamageKnuckles.appearanceResourceName", "a0_005_wa__strongarms_knuckles")
				TweakDB:SetFlat("Items.ElectricDamageKnuckles.appearanceResourceName", "a0_005_wa__strongarms_knuckles")
				TweakDB:SetFlat("Items.ThermalDamageKnuckles.appearanceResourceName", "a0_005_wa__strongarms_knuckles")
				TweakDB:SetFlat("Items.AnimalsStrongArmsKnuckles1.appearanceResourceName", "a0_005_wa__strongarms_knuckles")

				-- Mantis Blades
				TweakDB:SetFlat("Items.ChemicalDamageEdge.appearanceResourceName", "a0_003_wa__mantisblades_edges")
				TweakDB:SetFlat("Items.ElectricDamageEdge.appearanceResourceName", "a0_003_wa__mantisblades_edges")
				TweakDB:SetFlat("Items.PhysicalDamageEdge.appearanceResourceName", "a0_003_wa__mantisblades_edges")
				TweakDB:SetFlat("Items.ThermalDamageEdge.appearanceResourceName", "a0_003_wa__mantisblades_edges")
				TweakDB:SetFlat("Items.MaxTacEdge.appearanceResourceName", "a0_003_wa__mantisblades_edges")

				-- Launcher Mechanisms - Originally female characters used male launcher parts
				TweakDB:SetFlat("Items.ExplosiveDamageRound.appearanceResourceName", "a0_006_wa__launcher_fragment")
				TweakDB:SetFlat("Items.ChemicalDamageRound.appearanceResourceName", "a0_006_wa__launcher_fragment")
				TweakDB:SetFlat("Items.ElectricDamageRound.appearanceResourceName", "a0_006_wa__launcher_fragment")
				TweakDB:SetFlat("Items.ThermalDamageRound.appearanceResourceName", "a0_006_wa__launcher_fragment")
				TweakDB:SetFlat("Items.TranquilizerRound.appearanceResourceName", "a0_006_wa__launcher_fragment")
				TweakDB:SetFlat("Items.MilitechProjectileLauncherRound1.appearanceResourceName", "a0_006_wa__launcher_fragment")

				-- Monowires
				TweakDB:SetFlat("Items.PhysicalDamageCable.appearanceResourceName", "a0_002_wa__monowire_whip_cable")
				TweakDB:SetFlat("Items.ChemicalDamageCable.appearanceResourceName", "a0_002_wa__monowire_whip_cable")
				TweakDB:SetFlat("Items.ElectricDamageCable.appearanceResourceName", "a0_002_wa__monowire_whip_cable")
				TweakDB:SetFlat("Items.ThermalDamageCable.appearanceResourceName", "a0_002_wa__monowire_whip_cable")
            end
        end
    end)
end)