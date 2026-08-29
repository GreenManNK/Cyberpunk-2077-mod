local GameUI = require("GameUI")
local loc = require("loc")

nciSettings = {
	settings = {
		no_alco = false
	},
	isInGame = false,
    saving = require("saving")
}

function nciSettings:setup()
	registerForEvent("onInit", function()
		GameUI.OnSessionStart(function()
            self.isInGame = true
			nciSettings:updateFacts()
		end)
		GameUI.OnSessionEnd(function()
            self.isInGame = false
		end)
        self.saving.tryMakeSave("settings.json", self.settings)
        self.saving.checkData("settings.json", self.settings)
        self.settings = self.saving.loadFile("settings.json")		
		nciSettings:nativeSetup()
    end)
end

function nciSettings:nativeSetup()
	local nativeSettings = GetMod("nativeSettings")	
	
	local nativeOptions = {}	
	
	nativeSettings.addTab("/nciSettings", loc.title)
	
	nativeSettings.addSwitch("/nciSettings", loc.no_alco.title, loc.no_alco.desc,  self.settings.no_alco,  false, function(state)
		self.settings.no_alco = state
        saving.saveFile("settings.json", self.settings)
		nciSettings:updateFacts()
	end)
end

function nciSettings:updateFacts()
	if self.isInGame == true then
		if self.settings.no_alco then 
			Game.GetQuestsSystem():SetFactStr("nci_no_alcohol", 1)
		else
			Game.GetQuestsSystem():SetFactStr("nci_no_alcohol", 0)
		end
	end
end

return nciSettings:setup()