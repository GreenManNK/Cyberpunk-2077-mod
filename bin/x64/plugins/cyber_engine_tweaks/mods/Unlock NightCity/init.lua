-- Change Slot Cooldown Time Here (in minutes)
slotCoolDownTime = 1440

-- Change Smuggling Cost
smugglingCost = 50000

-- Enable Debug
enableDebug = false

-- Delta Time For Updated
deltaTime = 0

canDraw = false

-- Mod Code
packages = {
	ItemsManager = "misc/items",
	TeleportManager = "teleports/teleports",
	DoorManager = "doors/doors",
	DeviceManager = "devices/devices",
	SlotMachineManager = "slotmachine/slotmachine",
	SmugglerManager = "smuggler/smuggler",
}


function loadPackages()

	for pkgName, pkgLocation in pairs(packages) do
		packages[pkgName] = require(pkgLocation)

		if enableDebug then
			packages[pkgName].Log()
		end
		
	end

	canDraw = true

end

function runUpdates()
	packages.SmugglerManager.UpdateSmugglerWindow()
end

-- print(Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), false, false):GetWorldPosition())
registerForEvent("onInit", function()
	loadPackages()

	tt = Game.GetTargetingSystem()

	print("[Unlock NightCity] Initialized | Version: 1.5.2")
end)


registerHotkey("prev_tv_channel", "Prev TV Channel", function() -- Left Arrow 
	local object = tt:GetLookAtObject(Game.GetPlayer(), false, false)
	packages.DeviceManager.SwitchPreviousTVChannel(object)
end)

registerHotkey("next_tv_channel", "Next TV Channel", function() -- Right Arrow 
	local object = tt:GetLookAtObject(Game.GetPlayer(), false, false)
	packages.DeviceManager.SwitchPreviousTVChannel(object)
end)

registerHotkey("turn_off_computer", "Toogle Computer State", function() -- Shift + F 
	local object = tt:GetLookAtObject(Game.GetPlayer(), false, false)
	packages.DeviceManager.ToogleComputerState(object)
end)

registerHotkey("main_mod_function_key", "Main Mod Function Key", function() -- F 
	local stopAfter = false

	-- Check for Teleport location
	stopAfter = packages.TeleportManager.CheckTeleport()
	if stopAfter then return end

	-- Stop Runtime If No Object Found
	local object = tt:GetLookAtObject(Game.GetPlayer(), false, false)
	if not object then return end

	-- Check for Devices
	stopAfter = packages.DeviceManager.CheckDevice(object)
	if stopAfter then return end

	-- Check for SlotMachine
	stopAfter = packages.SlotMachineManager.CheckSlotMachine(object, slotCoolDownTime, packages.ItemsManager)
	if stopAfter then return end

	-- Check for Allowed Doors
	stopAfter = packages.DoorManager.CheckAllowedDoor(object)
	if stopAfter then return end


	-- Check for Smuggler
	stopAfter = packages.SmugglerManager.CheckSmuggler(object, smugglingCost)
	if stopAfter then return end
end)


registerForEvent("onUpdate", function(dt)

	deltaTime = deltaTime + dt

	if deltaTime > 1 then
		runUpdates()
        deltaTime = deltaTime - 1
    end

end)

registerForEvent("onDraw", function()
	if canDraw then
		packages.SmugglerManager.DrawSmugglerWindow(drawSmuggleWindow)
	end
end)