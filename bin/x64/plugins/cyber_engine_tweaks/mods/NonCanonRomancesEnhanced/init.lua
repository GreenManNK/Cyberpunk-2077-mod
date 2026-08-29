local GameUI = require("GameUI")
local loc = require("loc")

noncanonRomances = {
	settings = {
		judy = false,
		panam = false,
		kerry = false,
		river = false,
		femV = false
	},
	nativeOptions = {}
}

function noncanonRomances:setup()
	registerForEvent("onInit", function()
		GameUI.OnSessionStart(function()
			noncanonRomances:nativeLoad()
		end)
		GameUI.OnSessionEnd(function()
			noncanonRomances:nativeUnload()
		end)		
		noncanonRomances:nativeSetup()
    end)
end

function noncanonRomances:nativeSetup()
	local nativeSettings = GetMod("nativeSettings")	
	nativeSettings.addTab("/noncanonRomances", "Non-Canon Romances Enhanced")
	nativeSettings.addSubcategory("/noncanonRomances/partner", loc.category)
	nativeSettings.addSubcategory("/noncanonRomances/placeholder", loc.placeholder)
end

function noncanonRomances:nativeLoad()
	local nativeSettings = GetMod("nativeSettings")	
	if Game.GetQuestsSystem():GetFactStr("judy_romanceable") > 0 then 
		self.settings.judy = true
	else
		self.settings.judy = false
	end
	if Game.GetQuestsSystem():GetFactStr("panam_romanceable") > 0 then 
		self.settings.panam = true
	else
		self.settings.panam = false
	end
	if Game.GetQuestsSystem():GetFactStr("kerry_romanceable") > 0 then 
		self.settings.kerry = true
	else
		self.settings.kerry = false
	end
	if Game.GetQuestsSystem():GetFactStr("river_romanceable") > 0 then 
		self.settings.river = true
	else
		self.settings.river = false
	end
	if (GetPlayer():GetResolvedGenderName() == ToCName{hash_lo = 0x33676EB9, hash_hi = 0x040F253D}) then 
		self.settings.femV = true
		self.nativeOptions["panam"] = nativeSettings.addSwitch("/noncanonRomances/partner", loc.title.panam, loc.description.panam, self.settings.panam, false, function(state)
			self.settings.panam = state
			if self.settings.panam then 
				Game.GetQuestsSystem():SetFactStr("panam_romanceable", 1)
			else
				Game.GetQuestsSystem():SetFactStr("panam_romanceable", 0)
			end
		end) 
		self.nativeOptions["kerry"] = nativeSettings.addSwitch("/noncanonRomances/partner", loc.title.kerry, loc.description.kerry, self.settings.kerry, false, function(state)
			self.settings.kerry = state
			if self.settings.kerry then 
				Game.GetQuestsSystem():SetFactStr("kerry_romanceable", 1)
			else
				Game.GetQuestsSystem():SetFactStr("kerry_romanceable", 0)
			end
		end)
	else
		self.settings.femV = false
		self.nativeOptions["judy"] = nativeSettings.addSwitch("/noncanonRomances/partner", loc.title.judy, loc.description.judy,  self.settings.judy,  false, function(state)
			self.settings.judy = state
			if self.settings.judy then 
				Game.GetQuestsSystem():SetFactStr("judy_romanceable", 1)
			else
				Game.GetQuestsSystem():SetFactStr("judy_romanceable", 0)
			end
		end)
		self.nativeOptions["river"] = nativeSettings.addSwitch("/noncanonRomances/partner", loc.title.river, loc.description.river, self.settings.river, false, function(state)
			self.settings.river = state
			if self.settings.river then 
				Game.GetQuestsSystem():SetFactStr("river_romanceable", 1)
			else
				Game.GetQuestsSystem():SetFactStr("river_romanceable", 0)
			end		
		end)
	end
	nativeSettings.removeSubcategory("/noncanonRomances/placeholder")
end

function noncanonRomances:nativeUnload()
	local nativeSettings = GetMod("nativeSettings")	
	if self.settings.femV == true then
		nativeSettings.setOption(self.nativeOptions["panam"], false)
		nativeSettings.setOption(self.nativeOptions["kerry"], false)
		nativeSettings.removeOption(self.nativeOptions["panam"])
		nativeSettings.removeOption(self.nativeOptions["kerry"])
	else
		nativeSettings.setOption(self.nativeOptions["judy"], false)
		nativeSettings.setOption(self.nativeOptions["river"], false)
		nativeSettings.removeOption(self.nativeOptions["judy"])
		nativeSettings.removeOption(self.nativeOptions["river"])
	end
	self.settings.judy = false
	self.settings.panam = false
	self.settings.river = false
	self.settings.kerry = false
	self.settings.femV = false
	nativeSettings.addSubcategory("/noncanonRomances/placeholder", loc.placeholder)
end

return noncanonRomances:setup()