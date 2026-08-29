local DoorManager = {}

local AllowedDoors = {
	-- Konpeki Tower
	konpekiTowerFrontDoor = { x = -2262, y = 1705, z = nil, type = 'Door' },
	konpekiTowerSuiteShaft = { x = -2228, y = 1769, z = nil, type = 'FakeDoor' },
	konpekiTowerParkingGarangeDoor = { x = -2208, y = 1710, z = 7, type = 'Door' },
	konpekiTowerBarrier1 = { x = -2259.5989, y = 1707.0662, z = 19.0, type = 'Door' },
	
	-- Gig Penthouse
	gigPenthouseBuildingDoor = { x = -1185, y = 1401, z = nil, type = 'Door' },
	
	-- Voodoo Chapel Undergroud Base
	voodooUndergroundDoor = { x = -1733, y = -1903, z = nil, type = 'Door' },
	
	-- Clouds
	cloudsEntranceDoor = { x = -637, y = 806, z = nil, type = 'Door' },
	cloudsSecretAreaDoor1 = { x = -648, y = 791, z = nil, type = 'Door' },
	cloudsSecretAreaDoor2 = { x = -655, y = 796, z = 132, type = 'Door' },
	cloudsGlassDoor = { x = -663, y = 807, z = 128, type = 'Door' },
	cloudsLift = { x = -686, y = 805, z = 36, type = 'LiftDevice' },

	-- Maelstrom Hideout
	maelstromHideoutGarage = { x = -774, y = 2203, z = 51, type = 'Door' },
	maelstromHideoutDoor1 = { x = -828, y = 2236, z = 55, type = 'Door' },
	maelstromHideoutDoor2 = { x = -878, y = 2221, z = 61, type = 'Door' },
	maelstromHideoutDoor3 = { x = -785, y = 2189, z = 53, type = 'Door' },

	-- Sandra Dorsett
	sandraDorsettRescueSecretRoom = { x = -453, y = 390, z = 132, type = 'Door' },
	sandraDorsettApartmentDoor = { x = -1283, y = 1519, z = 45, type = 'Door' },

	-- Peralez Penthouse
	peralezPenthouseBuildingDoor = { x = -65, y = -99, z = 7, type = 'Door' },
	peralezPenthouseLookedDoor1 = { x = -78, y = -112, z = 111, type = 'Door' },
	peralezPenthouseLookedDoor2 = { x = -99, y = -111, z = 111, type = 'Door' },
	peralezPenthouseLookedDoor3 = { x = -69, y = -128, z = 111, type = 'Door' },
	peralezPenthouseSecretDoor1 = { x = -68, y = -121, z = 115, type = 'Door' },
	peralezPenthouseSecretDoor2 = { x = -69, y = -122, z = 123, type = 'Door' },

	-- MLK and Brendon Hotel
	MLKandBrendonHotelDoor1 = { x = -574, y = -828, z = 8, type = 'Door' },
	MLKandBrendonHotelDoor2 = { x = -570, y = -800, z = 8, type = 'Door' },
	MLKandBrendonHotelDoor3 = { x = -567, y = -821, z = 12, type = 'Door' },
	MLKandBrendonHotelDoor4 = { x = -581, y = -834, z = 12, type = 'Door' },

	-- Delamain HQ
	delamainHQMainDoor = { x = -951, y = -86, z = 8, type = 'Door' },
	delamainHQGarage1 = { x = -988, y = -110, z = 4, type = 'Door' },
	delamainHQGarage2 = { x = -978, y = -129, z = 4, type = 'Door' },
	delamainHQDoor1 = { x = -949, y = -90, z = 8, type = 'Door' },
	delamainHQDoor2 = { x = -945, y = -93, z = 8, type = 'Door' },
	delamainHQDoor3 = { x = -933, y = -106, z = 7, type = 'Door' },
	delamainHQDoor4 = { x = -958, y = -87, z = 8, type = 'Door' },
	delamainHQDoor5 = { x = -969, y = -106, z = 8, type = 'FakeDoor' },
	delamainHQDoor6 = { x = -971, y = -98, z = 8, type = 'Door' },
	delamainHQDoor7 = { x = -973, y = -123, z = 6, type = 'Door' },
	delamainHQDoor8 = { x = -958, y = -156, z = 7, type = 'Door' },
	delamainHQDoor9 = { x = -966, y = -153, z = 2, type = 'Door' },
	delamainHQDoor10 = { x = -979, y = -139, z = 3, type = 'Door' },
	delamainHQDoor11 = { x = -984, y = -149, z = 6, type = 'FakeDoor' },
	delamainHQDoor12 = { x = -972, y = -162, z = 8, type = 'Door' },

	-- Lizzy's Bar
	lizzysBarPodDoor1 = { x = -1171, y = 1583, z = 23, type = 'Door' },
	lizzysBarPodDoor2 = { x = -1174, y = 1583, z = 23, type = 'Door' },
	lizzysBarPodDoor3 = { x = -1177, y = 1583, z = 23, type = 'Door' },
	lizzysBarPodDoor4 = { x = -1180, y = 1584, z = 23, type = 'Door' },
	lizzysBarPodDoor5 = { x = -1183, y = 1584, z = 23, type = 'Door' },

	-- Shooting Range
	ShootingRangeDoor = { x = -1463, y = 1309, z = 119, type = 'Door' },

	-- Barry Lewis's Apartment
	BarryLewisApartmentDoor = { x = -1394, y = 1302, z = 119, type = 'Door' },

	-- Rogue's Apartment
	RogueApartmentDoor = { x = -1424, y = 991, z = 17, type = 'Door' },

	-- Finger's Apartment
	FingersApartmentDoor1 = { x = -566, y = 795, z = 25, type = 'Door' },
	FingersApartmentDoor2 = { x = -574, y = 798, z = 25, type = 'Door' },

	-- Lake Farm House
	LakeFarmHouseDoor = { x = 1116, y = -3477, z = 181, type = 'Door' },

	-- Solar Power Station
	SolarPowerStationDoor1 = { x = -200, y = -2801, z = 20, type = 'Door' },
	SolarPowerStationDoor2 = { x = -198, y = -2820, z = 20, type = 'Door' },

}

function unlockDoor(object)
	local objDPS = object:GetDevicePS();

	-- Unseal door if sealed
	if(objDPS:IsSealed()) then
		objDPS:ToggleSealOnDoor() 
	end

	-- Unlock door if locked
	if(objDPS:IsLocked()) then
		objDPS:ToggleLockOnDoor() 
	end

	objDPS:SetDeviceState(1) -- Restore power to door
	object:OpenDoor() -- Opens door
	objDPS:SetCloseItself(true) -- Closes door automatically

	print('[Unlock NightCity] Door Unlocked')
end

function unlockFakeDoor(object) 
	object:Dispose()

	print('[Unlock NightCity] Fake Door Disposed')
end

function DoorManager.CheckAllowedDoor(object)
	local objCoords = object:GetWorldPosition()

	for name, doorData in pairs(AllowedDoors) do

		match = doorData.x == round(objCoords.x) and doorData.y == round(objCoords.y)
		matchz = doorData.z == nil or doorData.z == round(objCoords.z)

		if match and matchz then

			if doorData.type == "Door" then 
				unlockDoor(object)
			elseif doorData.type == "FakeDoor" then
				unlockFakeDoor(object)
			end

			return true
		end

	end

end

function DoorManager.Log()
	print('[Unlock NightCity] DoorManager Loaded')
end

return DoorManager