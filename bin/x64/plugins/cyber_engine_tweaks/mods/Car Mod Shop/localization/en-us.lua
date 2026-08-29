local localization = {
	--Mod Name
	["CMSName"] = "Car Modification Shop",
	
	--Part Types
	["Engine"] = "Engine",
    ["Ecu"] = "Ecu",
    ["Transmission"] = "Transmission",
    ["Suspension"] = "Suspension",
    ["Tires"] = "Tires",
    ["Brakes"] = "Brakes",
    ["Weight Reduction"] = "Weight Reduction",
    ["Stage"] = "Stage",
	
	--Totals text
    ["basetotalTorqueText"] = "TORQUE: ",
    ["basetotalGearsText"] = "GEARS: ",
    ["basetotalHeightText"] = "HEIGHT: ",
    ["basetotalWeightText"] = "WEIGHT: ",
    ["basetotalTractionText"] = "TIRE TRACTION: ",
    ["basetotalBrakePowerText"] = "BRAKE TORQUE: ",
    ["basetotalPriceText"] = "BASKET: \n€$ ",
	
	--Main UI Text
    ["ClearAllUpgrades"] = "Remove All Upgrades",
    ["StopUpgradeClear"] = "Stop Upgrade Clear",
    ["ButtonStartDowngrading"] = "Start Downgrading",
    ["ButtonStopDowngrading"] = "Stop Downgrading",
    ["ButtonAcceptBroke"] = "Continue",
    ["ButtonReturn"] = "Previous Page",
    ["ButtonConfirmUpgrade"] = "Confirm Upgrade",
    ["CloseUIButton"] = "     Close",
    ["partBasketMainTextToSet"] = "PART BASKET:",
    ["partListMainTextToSet"] = "UPGRADED PARTS:",
    ["descriptionPrice"] = "Price: ",
    ["brokeConfirmBox"] = "NOT ENOUGH EDDIES CHOOM\n    GET SOME EDDIES FIRST\n        THEN WE CAN TALK",
    ["ButtonClearBasket"] = "Clear Basket",
	
	--MAP UI
    ["mapTitleText"] = "Car Garage",
    ["mapDescText"] = "Upgrade Your Vehicles and Outrun Everyone In the City!",
    ["ButtonClearBasket"] = "Clear Basket",

	--Parts names and desc
	
	--Engine
	["PartName-0101"] = "Cold Air Intake",
	["PartDesc-0101"] = "Small Engine Torque Increase",
			
	["PartName-0102"] = "Replace Headers",
	["PartDesc-0102"] = "Small Engine Torque Increase",
			
	["PartName-0103"] = "Mild Camshaft and Cam Gears",
	["PartDesc-0103"] = "Small Engine Torque Increase",
			
	["PartName-0104"] = "Performance Exhaust",
	["PartDesc-0104"] = "Small Engine Torque Increase",
			
	["PartName-0121"] = "Stage 1 Turbo System",
	["PartDesc-0121"] = "Medium Engine Torque Increase",
			
	["PartName-0105"] = "Cat Back Exhaust System",
	["PartDesc-0105"] = "Medium Engine Torque Increase",
			
	["PartName-0106"] = "High Flow Intake Manifold",
	["PartDesc-0106"] = "Small Engine Torque Increase",
			
	["PartName-0107"] = "Larger Diameter Downpipe",
	["PartDesc-0107"] = "Small Engine Torque Increase",
				
	["PartName-0122"] = "Stage 2 Turbo System",
	["PartDesc-0122"] = "Very Large Engine Torque Increase",
				
	["PartName-0108"] = "Racing Camshaft and Cam Gears",
	["PartDesc-0108"] = "Medium Engine Torque Increase",
				
	["PartName-0109"] = "Port and Polish Heads",
	["PartDesc-0109"] = "Medium Engine Torque Increase",
				
	["PartName-0110"] = "Blueprint the Block",
	["PartDesc-0110"] = "Medium Engine Torque Increase",
				
	["PartName-0111"] = "High Flow Headers",
	["PartDesc-0111"] = "Medium Engine Torque Increase",
				
	["PartName-0123"] = "Stage 3 Twin Turbo System",
	["PartDesc-0123"] = "Extreme Engine Torque Increase",

	--ECU
	["PartName-0201"] = "Fuel Pressure Regulator",
	["PartDesc-0201"] = "Medium Engine Torque Increase",
		
	["PartName-0202"] = "Fuel Rail",
	["PartDesc-0202"] = "Small Engine Torque Increase",
		
	["PartName-0203"] = "Fuel Filter",
	["PartDesc-0203"] = "Small Engine Torque Increase",
		
	["PartName-0204"] = "Performance Chip",
	["PartDesc-0204"] = "Large Engine Torque Increase",
		
	["PartName-0205"] = "High Flow Fuel Pump",
	["PartDesc-0205"] = "Small Engine Torque Increase",
			
	["PartName-0206"] = "Engine Management Unit",
	["PartDesc-0206"] = "Extreme Engine Torque Increase",
			
	["PartName-0207"] = "Fuel Injectors",
	["PartDesc-0207"] = "Medium Engine Torque Increase",
	
	--Transmission
	["PartName-0301"] = "Short Shift Kit",
	["PartDesc-0301"] = "Medium Gear Change Time Reduction",
				
	["PartName-0302"] = "Lightweight Flywheel",
	["PartDesc-0302"] = "Large Flywheel Weight Reduction",
				
	["PartName-0305"] = "High Performance Clutch",
	["PartDesc-0305"] = "Large Gear Change Time Reduction",
		
	["PartName-0306"] = "High Performance Transmission",
	["PartDesc-0306"] = "Adds A Gear, Improves Top Speed",
	
	--Suspension
	["PartName-0401"] = "Sport Springs and Shocks",
	["PartDesc-0401"] = "Small Height Reduction",
				
	["PartName-0402"] = "Strut Tower Bar",
	["PartDesc-0402"] = "Small Suspension Improvement",
				
	["PartName-0403"] = "Performance Springs and Shocks",
	["PartDesc-0403"] = "Medium Height Reduction",
				
	["PartName-0404"] = "Front and Rear Swaybars",
	["PartDesc-0404"] = "Small Swaybar Stiffness Improvement",
				
	["PartName-0405"] = "Coilover Suspension System",
	["PartDesc-0405"] = "Large Height Reduction",
				
	["PartName-0406"] = "Large Diameter Swaybars",
	["PartDesc-0406"] = "Large Swaybar Stiffness Improvement",
		
	--Tires
	["PartName-0501"] = "Street Performance Tires",
	["PartDesc-0501"] = "Medium Tire Grip Improvement",
				
	["PartName-0502"] = "Pro Performance Tires",
	["PartDesc-0502"] = "Large Tire Grip Improvement",
				
	["PartName-0503"] = "Extreme Performance Tires",
	["PartDesc-0503"] = "Extreme Tire Grip Improvement",

	--Brakes
	["PartName-0601"] = "Street Compound Brake Pads",
	["PartDesc-0601"] = "Medium Brake Torque Increase",	
	
	["PartName-0602"] = "Steel Braided Brake Lines",
	["PartDesc-0602"] = "Small Brake Torque Increase",
		
	["PartName-0603"] = "Cross Drilled Rotors",
	["PartDesc-0603"] = "Medium Brake Torque Increase",
		
	["PartName-0604"] = "Large Diameter Rotors",
	["PartDesc-0604"] = "Large Brake Torque Increase",
		
	["PartName-0605"] = "Race Compound Brake Pads",
	["PartDesc-0605"] = "Large Brake Torque Increase",
		
	["PartName-0606"] = "Cross Drilled And Slotted Rotors",
	["PartDesc-0606"] = "Extreme Brake Torque Increase",
		
	["PartName-0607"] = "6 Piston Racing Calipers",
	["PartDesc-0607"] = "Extreme Brake Torque Increase",	
	
	--Weight Reduction
	["PartName-0801"] = "Lightweight Carpets",
	["PartDesc-0801"] = "Small Weight Reduction",
				
	["PartName-0802"] = "Lightweight Interior Panels",
	["PartDesc-0802"] = "Small Weight Reduction",
				
	["PartName-0803"] = "Lightweight Windows",
	["PartDesc-0803"] = "Medium Weight Reduction",
				
	["PartName-0804"] = "Lightweight Seats",
	["PartDesc-0804"] = "Medium Weight Reduction",
				
	["PartName-0805"] = "Lightweight Doors",
	["PartDesc-0805"] = "Large Weight Reduction",
					
	["PartName-0806"] = "Foam Filled Interior",
	["PartDesc-0806"] = "Medium Weight Reduction",
	
	--Part Descriptions
	["Borpa"] = "Borpa"
}

return localization