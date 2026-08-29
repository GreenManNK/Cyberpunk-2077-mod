local TeleportManager = {}

local tp = Game.GetTeleportationFacility()

function round(n)
	return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

local TeleportLocations = {
	-- V Mansion
	vMansionIn = { x1 = -1362.7366, y1 = 1262.9171, x2 = -1360.1641, y2 = 1261.3978, z = nil, ang = { min = 131, max = 214 }, tp = { x = -1340.8207, y = 1189.0009, z = 115.00717, w = 1.0, ang = 355.86430751414 } },
	vMansionOut = { x1 = -1340.0024, y1 = 1188.9678, x2 = -1341.3989, y2 = 1189.8715, z = nil, ang = { min = 126, max = 175 }, tp = { x = -1361.6105, y = 1261.4937, z = 41.500008, w = 1.0, ang = 354.29516260943 } },
	
	-- Atlantis Bar
	atlantisBarIn = { x1 = -770.48676, y1 = 1106.0305, x2 = -771.2676, y2 = 1103.9075, z = nil, ang = { min = -121, max = -54 }, tp = { x = -764.93384, y = 1105.6572, z = 29.0, w = 1.0, ang = 277.87610919623 } },
	atlantisBarOut = { x1 = -769.0687, y1 = 1104.3372, x2 = -765.288, y2 = 1106.9291, z = nil, ang = { min = 75, max = 112 }, tp = { x = -770.46277, y = 1105.0232, z = 29.0, w = 1.0, ang = 95.82663528188 } },

	-- Konpeki Tower
	konpekiTowerGateIn = { x1 = -2111.5012, y1 = 1778.6323, x2 = -2115.0469, y2 = 1802.474, z = nil, ang = { min = 70, max = 153 }, tp = { x = -2126.5457, y = 1789.7084, z = 18.21, w = 1.0, ang = 86.517776489258 } },
	konpekiTowerGateOut = { x1 = -2123.955, y1 = 1797.2015, x2 = -2119.6572, y2 = 1774.1086, z = nil, ang = { min = -100, max = -27 }, tp = { x = -2109.7732, y = 1787.4629, z = 18.175941, w = 1.0, ang = -58.917133331299 } },
	konpekiTowerPlazaFakeDoorIn = { x1 = -2186.367, y1 = 1725.5879, x2 = -2189.073, y2 = 1722.2958, z = nil, ang = { min = -87, max = -35 }, tp = { x = -2185.6116, y = 1725.1577, z = 20.0, w = 1.0, ang = -58.598033905029 } },
	konpekiTowerPlazaFakeDoorOut = { x1 = -2184.1187, y1 = 1726.8806, x2 = -2186.6343, y2 = 1723.6713, z = nil, ang = { min = 94, max = 142 }, tp = { x = -2187.1292, y = 1723.9705, z = 20.0, w = 1.0, ang = 120.94380950928 } },
	konpekiTowerSecretRoom1In = { x1 = -2186.8623, y1 = 1775.0294, x2 = -2188.7544, y2 = 1773.3333, z = 163, ang = { min = -178, max = -115 }, tp = { x = -2200.2468, y = 1777.4227, z = 155.0, w = 1.0, ang = 30.079713821411 } },
	konpekiTowerSecretRoom1Out = { x1 = -2199.3496, y1 = 1778.2903, x2 = -2201.023, y2 = 1777.1056, z = 155, ang = { min = -168, max = -116 }, tp = { x = -2187.7134, y = 1773.9803, z = 163.01, w = 1.0, ang = 29.965148925781 } },
	konpekiTowerSecretRoom2In = { x1 = 2178.8638, y1 = 1787.1606, x2 = -2180.7163, y2 = 1785.5, z = 163, ang = { min = 6, max = 70 }, tp = { x = -2200.6565, y = 1777.8875, z = 147.0, w = 1.0, ang = 30.24005317688 } },
	konpekiTowerSecretRoom2Out = { x1 = -2199.5852, y1 = 1779.1616, x2 = -2201.5017, y2 = 1777.5187, z = 147, ang = { min = -172, max = -121 }, tp = { x = -2179.7036, y = 1786.2086, z = 163.01, w = 1.0, ang = -149.6848449707 } },
	konpekiTowerSecretRoom3In = { x1 = -2210.8457, y1 = 1768.6658, x2 = -2212.741, y2 = 1766.9113, z = 163, ang = { min = 6, max = 70 }, tp = { x = -2200.8247, y = 1778.309, z = 139.0, w = 1.0, ang = 28.15535736084 } },
	konpekiTowerSecretRoom3Out = { x1 = -2199.6538, y1 = 1779.2875, x2 = -2201.5762, y2 = 1777.4906, z = 139, ang = { min = -177, max = -121 }, tp = { x = -2211.9104, y = 1767.8201, z = 163.01001, w = 1.0, ang = -151.33483886719 } },
	konpekiTowerSecretRoom4In = { x1 = -2205.9104, y1 = 1753.5205, x2 = -2207.4482, y2 = 1751.6868, z = 163, ang = { min = -86, max = -29 }, tp = { x = -2201.2744, y = 1779.4202, z = 122.8, w = 1.0, ang = 28.609071731567 } },
	konpekiTowerSecretRoom4Out = { x1 = -2200.3833, y1 = 1780.5854, x2 = -2202.0574, y2 = 1778.7885, z = 123, ang = { min = -170, max = -121 }, tp = { x = -2206.7888, y = 1752.9232, z = 163.01001, w = 1.0, ang = 121.31513214111 } },

	-- Jig-Jig Apartment
	JigJigApartmentIn = { x1 = -668.08746, y1 = 878.67535, x2 = -671.13214, y2 = 875.0415, z = nil, ang = { min = -176, max = -126 }, tp = { x = -665.6719, y = 854.45044, z = 28.5, w = 1.0, ang = -170.33335876465 } },
	JigJigApartmentOut = { x1 = -664.56305, y1 = 857.5872, x2 = -667.1586, y2 = 853.34174, z = nil, ang = { min = -10, max = 33 }, tp = { x = -670.1892, y = 878.28455, z = 20.174019, w = 1.0, ang = 17.166879653931 } },
	
}

function TeleportManager.CheckTeleport()
    local player = Game.GetPlayer()
	local pPos = player:GetWorldPosition()
	local ang = player:GetWorldYaw()

	for loc, coords in pairs(TeleportLocations) do
		local x = pPos.x
		local y = pPos.y
		local z = pPos.z
		local minx = math.min(coords.x1, coords.x2)
		local maxx = math.max(coords.x1, coords.x2)
		local miny = math.min(coords.y1, coords.y2)
		local maxy = math.max(coords.y1, coords.y2)


		local intersect = (x >= minx and x <= maxx) and (y >= miny and y <= maxy)
		local matchz = coords.z == nil or coords.z == round(z)

		local orientation = (ang > coords.ang.min) and (ang < coords.ang.max)

		if intersect and orientation and matchz then
			local vTp = Vector4.new(coords.tp.x,coords.tp.y,coords.tp.z,coords.tp.w)
			tp:Teleport(player, vTp , EulerAngles.new(0,0,coords.tp.ang))

			return true
		end
		
	end
end

function TeleportManager.Log()
	print('[Unlock NightCity] TeleportManager Loaded')
end

return TeleportManager