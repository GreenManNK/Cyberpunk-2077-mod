MainFunctions = { 
    description = "Main Functions"
}

local recordTypesSystem = require('functions/tweakdb_record_types')


--function MainFunctions()

	function MainFunctions.cloneVehicleSettings(SimpleVehicleName, fullTweakDBIDToUse, ShouldCloneVehicleEngineData, ShouldCloneVehicleDriveModelData, ShouldCloneVehicleDataPackage, ShouldCloneVehicleWheelDimensionsSetup, ShouldCloneVehicleWheelSetup)
		--VehicleName = SimpleVehicleName
		VehicleName = SimpleVehicleName

		foundVeh = false
		
		VehicleClonedRecords = {}
		if TweakDB:GetRecord(VehicleName.."_cms_original") == nil then
			--print(VehicleName.."_cms_original")
			TweakDB:CloneRecord(VehicleName.."_cms_original", fullTweakDBIDToUse)
			VehicleClonedRecords.OriginalVehicle = VehicleName.."_cms_original"
			--VehicleClonedRecords.OriginalVehicle = fullTweakDBIDToUse
		else
			foundVeh = true

			fullTweakDBIDToUse = TweakDB:GetRecord(VehicleName.."_cms_original")
			VehicleClonedRecords.OriginalVehicle = fullTweakDBIDToUse
		end

		if ShouldCloneVehicleEngineData == true then
			
			if TweakDB:GetRecord(VehicleName.."_cms_enginedata") == nil then
				TweakDB:CloneRecord((VehicleName.."_cms_enginedata"), TweakDB:GetFlat(VehicleName.."_cms_original.vehEngineData"))
			end
			VehicleClonedRecords.OriginalVehicleEngineData = TweakDB:GetFlat(VehicleName.."_cms_original.vehEngineData")
			VehicleClonedRecords.VehicleEngineData = VehicleName.."_cms_enginedata"
			
			UpdateRecordWithOriginalValues((VehicleName.."_cms_enginedata"), TweakDB:GetFlat(VehicleName.."_cms_original.vehEngineData"), "VehicleEngineData")

			VehicleClonedRecords.GearBox = {}
			
			local gearCount = 0
			
			GearSet = {}
			OriginalGearSet = {}
			for indexG, gearFound in pairs(TweakDB:GetFlat(VehicleClonedRecords.OriginalVehicleEngineData .. ".gears")) do
				
				if TweakDB:GetRecord(VehicleName.."_cms_inline_gear" .. gearCount) == nil then
					TweakDB:CloneRecord((VehicleName.."_cms_inline_gear" .. gearCount), gearFound)
				end
				GearSet[gearCount+1] = VehicleName.."_cms_inline_gear" .. gearCount
				
				if TweakDB:GetRecord(VehicleName.."_cms_original_inline_gear" .. gearCount) == nil then
					TweakDB:CloneRecord((VehicleName.."_cms_original_inline_gear" .. gearCount), gearFound)
				end
				OriginalGearSet[gearCount+1] = VehicleName.."_cms_original_inline_gear" .. gearCount

				UpdateRecordWithOriginalValues((VehicleName.."_cms_inline_gear" .. gearCount), (VehicleName.."_cms_original_inline_gear" .. gearCount), "VehicleGearData")

				gearCount = gearCount + 1
			end
			
			TweakDB:SetFlat(VehicleName.."_cms_enginedata.gears", GearSet)
			VehicleClonedRecords.OriginalGearBox = OriginalGearSet
			VehicleClonedRecords.GearBox = GearSet
		end
		if ShouldCloneVehicleDriveModelData == true then
			--Check if bike
			local isBike = false
			if TweakDB:GetFlat(VehicleName.."_cms_original.bikeDriveModelData") ~= TweakDBID.new() then
				isBike = true
			end

			if TweakDB:GetRecord(VehicleName.."_cms_vehDriveModelData") == nil then
				--Check if bike
				if isBike == true then
					TweakDB:CloneRecord(VehicleName.."_cms_vehDriveModelData", TweakDB:GetFlat(VehicleName.."_cms_original.bikeDriveModelData"))
				else
					TweakDB:CloneRecord(VehicleName.."_cms_vehDriveModelData", TweakDB:GetFlat(VehicleName.."_cms_original.vehDriveModelData"))
				end
			end

			--Check if bike again (CDPR dev that did this, literally dude, WHY? Its literally pointless...)
			if isBike == true then
				VehicleClonedRecords.OriginalVehicleDriveModelData = TweakDB:GetFlat(VehicleName.."_cms_original.bikeDriveModelData")
			else
				VehicleClonedRecords.OriginalVehicleDriveModelData = TweakDB:GetFlat(VehicleName.."_cms_original.vehDriveModelData")
			end
			VehicleClonedRecords.VehicleDriveModelData = VehicleName.."_cms_vehDriveModelData"

			if isBike == true then
				UpdateRecordWithOriginalValues((VehicleName.."_cms_vehDriveModelData"), TweakDB:GetFlat(VehicleName.."_cms_original.bikeDriveModelData"), "VehicleBikeModelData")
			else
				UpdateRecordWithOriginalValues((VehicleName.."_cms_vehDriveModelData"), TweakDB:GetFlat(VehicleName.."_cms_original.vehDriveModelData"), "VehicleDriveModelData")
			end
		end
		if ShouldCloneVehicleDataPackage == true then
			if TweakDB:GetRecord(VehicleName.."_cms_vehDataPackage") == nil then
				TweakDB:CloneRecord(VehicleName.."_cms_vehDataPackage", TweakDB:GetFlat(VehicleName.."_cms_original.vehDataPackage"))
			end
			VehicleClonedRecords.OriginalVehicleDataPackage = TweakDB:GetFlat(VehicleName.."_cms_original.vehDataPackage")
			VehicleClonedRecords.VehicleDataPackage = VehicleName.."_cms_vehDataPackage"

			UpdateRecordWithOriginalValues((VehicleName.."_cms_vehDataPackage"), TweakDB:GetFlat(VehicleName.."_cms_original.vehDataPackage"), "VehicleDataPackage")
		end
		if ShouldCloneVehicleWheelDimensionsSetup == true then
			if TweakDB:GetRecord(VehicleName.."_cms_vehWheelDimensionsSetup") == nil then
				TweakDB:CloneRecord(VehicleName.."_cms_vehWheelDimensionsSetup", TweakDB:GetFlat(VehicleName.."_cms_original.vehWheelDimensionsSetup"))
			end
			VehicleClonedRecords.OriginalVehicleWheelDimensionsSetup = TweakDB:GetFlat(VehicleName.."_cms_original.vehWheelDimensionsSetup")
			VehicleClonedRecords.VehicleWheelDimensionsSetup = VehicleName.."_cms_vehWheelDimensionsSetup"

			UpdateRecordWithOriginalValues((VehicleName.."_cms_vehWheelDimensionsSetup"), TweakDB:GetFlat(VehicleName.."_cms_original.vehWheelDimensionsSetup"), "VehicleWheelDimensionsSetup")
		end
		if ShouldCloneVehicleWheelSetup == true then
			local isBike = false
			if TweakDB:GetFlat(VehicleName.."_cms_original.bikeDriveModelData") ~= TweakDBID.new() then
				isBike = true
			end

			DriveModelHelper = TweakDB:GetFlat(VehicleName.."_cms_original.vehDriveModelData")
			if isBike == true then
				DriveModelHelper = TweakDB:GetFlat(VehicleName.."_cms_original.bikeDriveModelData")
			end

			if TweakDB:GetRecord(VehicleName.."_cms_vehWheelSetup") == nil then
				TweakDB:CloneRecord(VehicleName.."_cms_vehWheelSetup", TweakDB:GetFlat(DriveModelHelper..".wheelSetup"))
			end
			VehicleClonedRecords.OriginalVehicleWheelSetup = TweakDB:GetFlat(DriveModelHelper..".wheelSetup")
			VehicleClonedRecords.VehicleWheelSetup = VehicleName.."_cms_vehWheelSetup"

			UpdateRecordWithOriginalValues((VehicleName.."_cms_vehWheelSetup"), TweakDB:GetFlat(DriveModelHelper..".wheelSetup"), "VehicleWheelSetup")

			if TweakDB:GetRecord(VehicleName.."_cms_vehWheelSetupFrontPreset") == nil or TweakDB:GetRecord(VehicleName.."_cms_vehWheelSetupRearPreset") == nil then
				TweakDB:CloneRecord(VehicleName.."_cms_vehWheelSetupFrontPreset", TweakDB:GetFlat(VehicleName.."_cms_vehWheelSetup.frontPreset"))
				TweakDB:CloneRecord(VehicleName.."_cms_vehWheelSetupRearPreset", TweakDB:GetFlat(VehicleName.."_cms_vehWheelSetup.backPreset"))
			end
			VehicleClonedRecords.OriginalFrontWheelSuspension = TweakDB:GetFlat(VehicleName.."_cms_vehWheelSetup.frontPreset")
			VehicleClonedRecords.OriginalRearWheelSuspension = TweakDB:GetFlat(VehicleName.."_cms_vehWheelSetup.backPreset")
			VehicleClonedRecords.FrontWheelSuspension = VehicleName.."_cms_vehWheelSetupFrontPreset"
			VehicleClonedRecords.RearWheelSuspension = VehicleName.."_cms_vehWheelSetupRearPreset"

			UpdateRecordWithOriginalValues((VehicleName.."_cms_vehWheelSetupFrontPreset"), TweakDB:GetFlat(TweakDB:GetFlat(DriveModelHelper..".wheelSetup")..".frontPreset"), "VehicleWheelSetupPreset")
			UpdateRecordWithOriginalValues((VehicleName.."_cms_vehWheelSetupRearPreset"), TweakDB:GetFlat(TweakDB:GetFlat(DriveModelHelper..".wheelSetup")..".backPreset"), "VehicleWheelSetupPreset")

		end
		
		return VehicleClonedRecords
	end

	function UpdateRecordWithOriginalValues(recordName, originalRecordName, recordType)
		local parametersCheck = recordTypesSystem.GetTweakDBRecordTypes(recordType)
		for i,v in ipairs(parametersCheck) do
			--if (TweakDB:GetFlat(recordName.."."..v) ~= nil) then
				TweakDB:SetFlatNoUpdate(recordName.."."..v, TweakDB:GetFlat(originalRecordName..("."..v)))
			--end
		end
		TweakDB:Update(recordName)
	end
	
	function MainFunctions.removePreviousClones(VehicleClonedRecords)
		--local GearBoxStuff = nil
		--if VehicleClonedRecords.VehicleEngineData ~= nil then
			--local GearBoxStuff = TweakDB:GetFlat(VehicleClonedRecords.VehicleEngineData .. ".gears")
		--end
		
		TweakDB:DeleteRecord(VehicleClonedRecords.VehicleEngineData)
		TweakDB:DeleteRecord(VehicleClonedRecords.VehicleDriveModelData)
		TweakDB:DeleteRecord(VehicleClonedRecords.VehicleDataPackage)
		TweakDB:DeleteRecord(VehicleClonedRecords.VehicleWheelDimensionsSetup)
		TweakDB:DeleteRecord(VehicleClonedRecords.VehicleWheelSetup)
		TweakDB:DeleteRecord(VehicleClonedRecords.FrontWheelSuspension)
		TweakDB:DeleteRecord(VehicleClonedRecords.RearWheelSuspension)
		
		--if GearBoxStuff ~= nil then
			for _, gearToDelete in pairs(VehicleClonedRecords.OriginalGearBox) do
				TweakDB:DeleteRecord(gearToDelete)
			end
		--end
		
		--return VehicleClonedRecords
	end

	function MainFunctions.setVehicleSettings(vehicleToSetTo, VehicleEngineDataToSet, VehicleDriveModelDataToSet, VehicleDataPackageToSet, VehicleWheelDimensionsSetupToSet)
	TweakDB:SetFlat(vehicleToSetTo..".vehEngineData", VehicleEngineDataToSet)

	--Yep this is why bikes brakes and tires refused to load, I am silly and so is CDPR :)
	local isBike = false
	if TweakDB:GetFlat(vehicleToSetTo..".bikeDriveModelData") ~= TweakDBID.new() then
		isBike = true
	end

	if isBike == true then
		TweakDB:SetFlat(vehicleToSetTo..".bikeDriveModelData", VehicleDriveModelDataToSet)
	else
		TweakDB:SetFlat(vehicleToSetTo..".vehDriveModelData", VehicleDriveModelDataToSet)
	end
	TweakDB:SetFlat(vehicleToSetTo..".vehDataPackage", VehicleDataPackageToSet)
	TweakDB:SetFlat(vehicleToSetTo..".vehWheelDimensionsSetup", VehicleWheelDimensionsSetupToSet)
	end

	function MainFunctions.setGearData(gearToSetDataTo, torqueMultiplierToSet, minSpeedToSet, maxSpeedToSet, minEngineRPMToSet, maxEngineRPMToSet)
	TweakDB:SetFlat(gearToSetDataTo..".torqueMultiplier", torqueMultiplierToSet)
	TweakDB:SetFlat(gearToSetDataTo..".minSpeed", minSpeedToSet)
	TweakDB:SetFlat(gearToSetDataTo..".maxSpeed", maxSpeedToSet)
	TweakDB:SetFlat(gearToSetDataTo..".minEngineRPM", minEngineRPMToSet)
	TweakDB:SetFlat(gearToSetDataTo..".maxEngineRPM", maxEngineRPMToSet)
	end

	function MainFunctions.setSupensionData(VehicleDriveModelDataToSetTo, VehicleWheelSetupToSet, FrontWheelSuspensionToSet, RearWheelSuspensionToSet)
	TweakDB:SetFlat(VehicleDriveModelDataToSetTo..".wheelSetup", VehicleWheelSetupToSet)
	TweakDB:SetFlat(VehicleWheelSetupToSet..".frontPreset", FrontWheelSuspensionToSet)
	TweakDB:SetFlat(VehicleWheelSetupToSet..".backPreset", RearWheelSuspensionToSet)
	end
	
	function MainFunctions.setAllCarsBaseHPMult(CarHealthMultiplier)
	TweakDB:SetFlat("VehicleStatPreset.BaseCar_inline0.value", 2500*CarHealthMultiplier)
	end
	
	function MainFunctions.split(s, delimiter)
		result = {};
		for match in (s..delimiter):gmatch("(.-)"..delimiter) do
			table.insert(result, match);
		end
		return result;
	end
	
--end

return MainFunctions