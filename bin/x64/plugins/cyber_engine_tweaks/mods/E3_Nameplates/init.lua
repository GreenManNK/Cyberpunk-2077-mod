local config = require("config")

UI_NamePlateSetter = {
	settings = {},
	defaultSettings = {
		showFriendly = true,
		showNeutral = true,
		showCivilian = true,
		showHostile = true,
		range = 35,
	}
}

-- Hi Spicy!!! Hi Erok!!!

local function updateSettings(settings) -- Update the settings class on the player
	local s = GetPlayer().namePlateSettings
	if not s then return end

	s.showHostile = settings.showHostile
	s.showFriendly = settings.showFriendly
	s.showNeutral = settings.showNeutral
	s.showCivilian = settings.showCivilian
	s.range = settings.range
end

function UI_NamePlateSetter:new()
    registerForEvent("onInit", function()
		
		ObserveAfter('NameplateVisualsLogicController', 'SetVisualData', function(self)
			local CurrentVehicle = Game.GetMountedVehicle(Game.GetPlayer())
			local playerInsideWorkspot = Game.GetWorkspotSystem():IsActorInWorkspot(Game.GetPlayer())
			
			if (CurrentVehicle ~= nil and playerInsideWorkspot) then
				self.customContainer:SetVisible(false)
				self.customContainer2:SetVisible(false)
			else
				self.customContainer:SetVisible(true)
				self.customContainer2:SetVisible(true)
			end
		end)

		ObserveAfter("NpcNameplateGameController", "OnInitialize", function (this)
			this.visualController.playerPuppet = GetPlayer()
			updateSettings(self.settings)
		end)

		-- Do TweakDB stuff
		local arrayOfBools = {}
		arrayOfBools = TweakDB:GetFlat("MappinUISettings.GlobalProfile.nameplateVisibleInTier")

		for index, _ in pairs(arrayOfBools) do
			arrayOfBools[index] = true
		end

		TweakDB:SetFlat("MappinUISettings.GlobalProfile.nameplateVisibleInTier", arrayOfBools)

		-- Do config stuff

		config.tryCreateConfig("data/config.json", self.defaultSettings)
        self.settings = config.loadFile("data/config.json")
		updateSettings(self.settings)

		-- Do native settings setup

		local nativeSettings = GetMod("nativeSettings")

		if not nativeSettings then
			print("[E3 Nameplates] Error: NativeSettings lib not found!")
			return
		end

		local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- <-- This has been made by psiberx, all credits to him
			return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
		end)))

		if cetVer < 1.18 then
			return
		end

		nativeSettings.addTab("/e3Names", "E3 Names")

		nativeSettings.addSubcategory("/e3Names/visibility", "Visibilty")
		nativeSettings.addSubcategory("/e3Names/range", "Range")

		nativeSettings.addSwitch("/e3Names/visibility", "Show Friendly", "Toggles friendly NPC's nameplates", self.settings.showFriendly, self.defaultSettings.showFriendly, function(value)
			self.settings.showFriendly = value
			updateSettings(self.settings)
			config.saveFile("data/config.json", self.settings)
		end)
		
	    nativeSettings.addSwitch("/e3Names/visibility", "Show Hostile", "Toggles hostile NPC's nameplates", self.settings.showHostile, self.defaultSettings.showHostile, function(value)
			self.settings.showHostile = value
			updateSettings(self.settings)
			config.saveFile("data/config.json", self.settings)
		end)

		nativeSettings.addSwitch("/e3Names/visibility", "Show Civilian", "Toggles civilian aka NC Resident NPC's nameplates", self.settings.showCivilian, self.defaultSettings.showCivilian, function(value)
			self.settings.showCivilian = value
			updateSettings(self.settings)
			config.saveFile("data/config.json", self.settings)
		end)
		
		nativeSettings.addSwitch("/e3Names/visibility", "Show Neutral", "This is a weird one - this toggles nameplates for any NPC not covered by the Show Civilian toggle for example hostages and some other random NPCs", self.settings.showNeutral, self.defaultSettings.showNeutral, function(value)
			self.settings.showNeutral = value
			updateSettings(self.settings)
			config.saveFile("data/config.json", self.settings)
		end)

		nativeSettings.addRangeInt("/e3Names/range", "Nameplate Range", "Sets the range in which the nameplates are visible", 1, 125, 1, self.settings.range, self.defaultSettings.range, function(value)
			self.settings.range = value
			updateSettings(self.settings)
			config.saveFile("data/config.json", self.settings)
		end)
	end)
end

return UI_NamePlateSetter:new()