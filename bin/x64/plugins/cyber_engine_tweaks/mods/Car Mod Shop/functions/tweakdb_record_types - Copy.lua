TweakDBRecordTypes = { 
    description = "Record Types for TweakDB use"
}

function TweakDBRecordTypes.GetTweakDBRecordTypes(RecordType)

	Types = {}

	if (RecordType) == "VehicleEngineData" then
		Types = {"engineMaxTorque", "fastR1GearChange", "finalGearTorqueDecimationScalor", 
		"flyWheelMomentOfInertia", "forceReverseRPMToMin", "gearChangeCooldown", 
		"gearChangeTime", "gearCurvesPath", "gears", "maxRPM", "minRPM", "resistanceTorque",
		"reverseDirDelay", "wheelsResistanceRatio"}
	end

	if (RecordType) == "VehicleGearData" then
		Types = {"maxEngineRPM", "minEngineRPM", "minSpeed", 
		"maxSpeed", "torqueMultiplier"}
	end

	if (RecordType) == "VehicleDriveModelData" then
		Types = {"airResistanceFactor", "antiSwaybarDampingScalor", "bankBodyFBTanMultiplier", 
		"bankBodyLRTanMultiplier", "bodyFriction", "brakingEstimationMagicFactor", 
		"brakingFrictionFactor", "burnOut", "center_of_mass_offset", "chassis_mass", 
		"differentialOvershootFactor", "driveHelpers", "flatTireSim", 
		"forwardWeightTransferFactor", "handbrakeBrakingTorque", 
		"lowVelStoppingDeceleration", "maxWheelTurnDeg", "momentOfInertia", "momentOfInertiaScale", 
		"perfectSteeringFactor", "sideWeightTransferFactor", "slipAngleCurveScale", 
		"slipAngleMinSpeedThreshold", "slipRatioCurveScale", "slipRatioMinSpeedThreshold", 
		"slopeTractionReductionBegin", "slopeTractionReductionFactor", "slopeTractionReductionMax",
		"smoothWheelContactDecreaseTime","smoothWheelContactIncreseTime", "total_mass",
		"turningRollFactor","turningRollFactorWeakContactMul","turningRollFactorWeakContactThresholdMax",
		"turningRollFactorWeakContactThresholdMin","turnUpdateBaseSpeedThreshold",
		"turnUpdateInputDiffForFastChange","turnUpdateInputDiffForSlowChange",
		"turnUpdateInputDiffProgressionPow","turnUpdateInputFastChangeSpeed",
		"turnUpdateInputSlowChangeSpeed","turnUpdateMaxSpeedThreshold",
		"turnUpdateMaxSpeedTurnChangeMul","turnUpdateMaxSpeedTurnMul","turnUpdateMidSpeedThreshold",
		"turnUpdateMidSpeedTurnChangeMul","turnUpdateMidSpeedTurnMul","useAlternativeTurnUpdate",
		"waterParams","wheelSetup","wheelsFrictionMap","wheelTurnMaxAddPerSecond","wheelTurnMaxSubPerSecond"
		}
	end

	if (RecordType) == "TankDriveModelData" then
    Types = {
        "tankAcceleration", "tankCTOD","tankCTOI","tankCTOP","tankDeceleration","tankGravityMul","tankMaxSpeed",
        "tankSpringDamping","tankSpringDistance","tankSpringRadius","tankSpringsLocalPositions",
        "tankSpringStiffness","tankSpringVerticalOffset","tankTurningSpeed"    }
	end

	if (RecordType) == "BikeDriveModelData" then
		Types = {"airResistanceFactor", "antiSwaybarDampingScalor", "bankBodyFBTanMultiplier", 
			"bankBodyLRTanMultiplier", "bikeCOMOffsetDampFactor", "bikeCurvesPath", "bikeMaxCOMLongOffset",
			"bikeMaxTilt", "bikeMinCOMLongOffset", "bikeTiltCustomSpeed", "bikeTiltPID", 
			"bikeTiltReturnSpeed", "bikeTiltSpeed", "bodyFriction", "brakingEstimationMagicFactor", 
			"brakingFrictionFactor", "burnOut", "center_of_mass_offset", "chassis_mass", 
			"differentialOvershootFactor", "driveHelpers", "flatTireSim", "forwardWeightTransferFactor",
			"handbrakeBrakingTorque", "lowVelStoppingDeceleration", "maxWheelTurnDeg", "momentOfInertia", 
			"momentOfInertiaScale", "perfectSteeringFactor", "sideWeightTransferFactor",
			"slipAngleCurveScale", "slipAngleMinSpeedThreshold", "slipRatioCurveScale", "slipRatioMinSpeedThreshold", 
			"slopeTractionReductionBegin", "slopeTractionReductionFactor", "slopeTractionReductionMax",
			"smoothWheelContactDecreaseTime","smoothWheelContactIncreseTime", "total_mass",
			"turnUpdateBaseSpeedThreshold", "turnUpdateInputDiffForFastChange","turnUpdateInputDiffForSlowChange",
			"turnUpdateInputDiffProgressionPow","turnUpdateInputFastChangeSpeed",
			"turnUpdateInputSlowChangeSpeed","turnUpdateMaxSpeedThreshold",
			"turnUpdateMaxSpeedTurnChangeMul","turnUpdateMaxSpeedTurnMul","turnUpdateMidSpeedThreshold",
			"turnUpdateMidSpeedTurnChangeMul","turnUpdateMidSpeedTurnMul",
			"turningRollFactor","turningRollFactorWeakContactMul","turningRollFactorWeakContactThresholdMax",
			"turningRollFactorWeakContactThresholdMin", "useAlternativeTurnUpdate", "waterParams",
			"wheelSetup", "wheelTurnMaxAddPerSecond", "wheelTurnMaxSubPerSecond", "wheelsFrictionMap" }
	end

	if (RecordType) == "VehicleDataPackage" then
		Types = {"additionalAnimFeatures", "animVars", "barnDoorsTailgate", 
		"body_dump_close_trunk_delay", "boneNames", "canStoreBody", 
		"combatEntering", "disableSwitchSeats", "driverCombat", 
		"entering", "exitDelay", "fppCameraOverride", "fromCombat", 
		"hasSpoiler", "hasTurboCharger", "immediate_open_close_duration", 
		"interactiveHood", "interactiveTrunk", "knockOffForce", "normal_open", 
		"open_close_duration", "parkingAngle", "seatingTemplateOverride", "slideDuration", 
		"slidingRearDoors", "speedToClose", "spoilerSpeedToDeploy", "spoilerSpeedToRetract", 
		"stealing", "stealing_open", "switchSeats","tireOnVehicleDamageImpulseScalor","toCombat",
		"useAuxiliary","vehSeatSet","wheelBumperLengthScalor","wheelBumperVertOffsetScalor",
		"wheelBumperWidthScalor"}
	end

	if (RecordType) == "VehicleWheelDimensionsSetup" then
		Types = {"backPreset", "frontPreset"}
	end

	if (RecordType) == "VehicleWheelSetup" then
		Types = {"backPreset", "frontPreset", "F", "B", "LB", "LF", "RB", "RF"}
	end

	if (RecordType) == "VehicleWheelSetupPreset" then
		Types = {"extremeCompressionEventScalor", "frictionMulLateral", "frictionMulLongitudinal", 
		"logicalSuspensionCompressionLength", "mass", "maxBrakingTorque", "springBoundDampingLowRate", 
		"springDamping", "springDampingHighRateCompression", "springDampingLowRateCompression", 
		"springReboundDamping", "springReboundDampingLowRate", "springStiffness", 
		"swaybarDisplacementLimit", "swaybarLengthScalar", "swaybarStiffness", "tenderSpringLength", 
		"tireFrictionCoef", "tireLateralSlipEffectsMul", "tireLongitudinalSlipEffectsMul", 
		"tireRollingResistanceCoef", "visualSuspensionCompressionLength", "visualSuspensionDroop", 
		"wheelsVerticalOffset"}
	end
	
	return Types
	
end

return TweakDBRecordTypes