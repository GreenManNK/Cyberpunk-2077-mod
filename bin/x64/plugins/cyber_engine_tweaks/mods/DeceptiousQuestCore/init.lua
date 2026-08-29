local GameUI = require("GameUI")
local loc = require("loc")

questcore = {
	settings = {
		slot_1 = 0,
		slot_2 = 0,
		slot_3 = 0,
		slot_4 = 0,
		slot_5 = 0,
		slot_6 = 0,
		slot_7 = 0,
		slot_8 = 0,
		slot_9 = 0,
		slot_10 = 0,
		slot_11 = 0,
		slot_12 = 0,
		slot_13 = 0,
		slot_14 = 0,
		slot_15 = 0,
		slot_16 = 0,
		slot_17 = 0,
		slot_18 = 0,
		slot_19 = 0,
		slot_20 = 0,
		slot_21 = 0,
		slot_22 = 0,
		slot_23 = 0,
		slot_24 = 0,
		slot_25 = 0,
		slot_26 = 0,
		slot_27 = 0,
		slot_28 = 0,
		slot_29 = 0,
		slot_30 = 0,
		hotFuzz = false,
		californication = false,
		encore = false,
		jesseRomanced = false,
		sleighSFX = true,
		alexPhotomode = false
	},
	isInGame = false,
	isPopulated = false,
	isAuroreOverrideShown = false,
	isAlexOverrideShown = false,
	nativeOptions = {}
}

function questcore:setup()
	registerForEvent("onInit", function()		
		questcore:nativeSetup()
		GameUI.OnSessionStart(function()
            self.isInGame = true
		end)
		GameUI.OnMenuOpen(function()
			if self.isInGame == true then
				questcore:nativeLoad()
			end
		end)
		GameUI.OnMenuClose(function()
			if self.isInGame == true then
				questcore:nativeUnload()
			end
		end)
		GameUI.OnSessionEnd(function()
			questcore:nativeUnload()
            self.isInGame = false
		end)
    end)
end

function questcore:nativeSetup()
	local nativeSettings = GetMod("nativeSettings")	
	nativeSettings.addTab("/questcore", loc.main)
	nativeSettings.addSubcategory("/questcore/main", loc.category)
	nativeSettings.addSubcategory("/questcore/placeholder", loc.placeholder)
end

function questcore:nativeLoad()
	local nativeSettings = GetMod("nativeSettings")	
	if self.isPopulated == false then 
		self.settings.slot_1 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_01")
		self.settings.slot_2 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_02")
		self.settings.slot_3 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_03")
		self.settings.slot_4 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_04")
		self.settings.slot_5 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_05")
		self.settings.slot_6 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_06")
		self.settings.slot_7 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_07")
		self.settings.slot_8 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_08")
		self.settings.slot_9 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_09")
		self.settings.slot_10 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_10")
		self.settings.slot_11 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_11")
		self.settings.slot_12 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_12")
		self.settings.slot_13 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_13")
		self.settings.slot_14 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_14")
		self.settings.slot_15 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_15")
		self.settings.slot_16 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_16")
		self.settings.slot_17 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_17")
		self.settings.slot_18 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_18")
		self.settings.slot_19 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_19")
		self.settings.slot_20 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_20")
		self.settings.slot_21 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_21")
		self.settings.slot_22 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_22")
		self.settings.slot_23 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_23")
		self.settings.slot_24 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_24")
		self.settings.slot_25 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_25")
		self.settings.slot_26 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_26")
		self.settings.slot_27 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_27")
		self.settings.slot_28 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_28")
		self.settings.slot_29 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_29")
		self.settings.slot_30 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_30")
		if Game.GetQuestsSystem():GetFactStr("slot_1_loop_disabled") == 0 then
			self.settings.hotFuzz = false
		else
			self.settings.hotFuzz = true
		end
		if Game.GetQuestsSystem():GetFactStr("slot_3_loop_disabled") == 0 then
			self.settings.californication = false
		else
			self.settings.californication = true
		end
		if Game.GetQuestsSystem():GetFactStr("slot_7_loop_disabled") == 0 then
			self.settings.encore = false
		else
			self.settings.encore = true
		end
		if Game.GetQuestsSystem():GetFactStr("slot_17_loop_disabled") == 0 then
			self.settings.jesseRomanced = false
		else
			self.settings.jesseRomanced = true
		end
		if Game.GetQuestsSystem():GetFactStr("alex_rom_allow_pm") == 0 then
			self.settings.alexPhotomode = false
		else
			self.settings.alexPhotomode = true
		end
		isAuroreOverrideShown = false
		isAlexOverrideShown = false
		
		if self.settings.slot_1 == -1 then
			self.nativeOptions["slot_1"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_1, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_01", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_1"])
				if self.nativeOptions["hotFuzz"] ~= nil then
					nativeSettings.removeOption(self.nativeOptions["hotFuzz"])
					nativeSettings.removeSubcategory("/questcore/hotFuzz")
				end
			end)
			nativeSettings.addSubcategory("/questcore/hotFuzz", loc.hotFuzz)
			self.nativeOptions["hotFuzz"] = nativeSettings.addSwitch("/questcore/hotFuzz", loc.loopDisabled, loc.loopDisabledDesc, self.settings.hotFuzz, false, function(state)
				self.settings.hotFuzz = state
				if state == true then
					Game.GetQuestsSystem():SetFactStr("slot_1_loop_disabled", 1)
				else
					Game.GetQuestsSystem():SetFactStr("slot_1_loop_disabled", 0)				
				end
			end)
		end	
		if self.settings.slot_2 == -1 then
			self.nativeOptions["slot_2"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_2, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_02", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_2"])
			end)
		end
		if self.settings.slot_3 == -1 then
			self.nativeOptions["slot_3"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_3, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_03", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_3"])
				if self.nativeOptions["californication"] ~= nil then
					nativeSettings.removeOption(self.nativeOptions["californication"])
					nativeSettings.removeSubcategory("/questcore/californication")
				end
			end)
			nativeSettings.addSubcategory("/questcore/californication", loc.californication)
			self.nativeOptions["californication"] = nativeSettings.addSwitch("/questcore/californication", loc.loopDisabled, loc.loopDisabledDesc, self.settings.californication, false, function(state)
				self.settings.californication = state
				if state == true then
					Game.GetQuestsSystem():SetFactStr("slot_3_loop_disabled", 1)
				else
					Game.GetQuestsSystem():SetFactStr("slot_3_loop_disabled", 0)				
				end
			end)
		end	
		if self.settings.slot_4 == -1 then
			self.nativeOptions["slot_4"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_4, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_04", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_4"])
			end)
		end
		if self.settings.slot_5 == -1 then
			self.nativeOptions["slot_5"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_5, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_05", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_5"])
			end)
		end	
		if self.settings.slot_6 == -1 then
			self.nativeOptions["slot_6"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_6, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_06", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_6"])
			end)
		end
		if self.settings.slot_7 == -1 then
			self.nativeOptions["slot_7"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_7, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_07", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_7"])
				if self.nativeOptions["encore"] ~= nil then
					nativeSettings.removeOption(self.nativeOptions["encore"])
					nativeSettings.removeSubcategory("/questcore/encore")
				end
			end)
			nativeSettings.addSubcategory("/questcore/encore", loc.encore)
			self.nativeOptions["encore"] = nativeSettings.addSwitch("/questcore/encore", loc.loopDisabled, loc.loopDisabledDesc, self.settings.encore, false, function(state)
				self.settings.encore = state
				if state == true then
					Game.GetQuestsSystem():SetFactStr("slot_7_loop_disabled", 1)
				else
					Game.GetQuestsSystem():SetFactStr("slot_7_loop_disabled", 0)				
				end
			end)
		end	
		if self.settings.slot_8 == -1 then
			self.nativeOptions["slot_8"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_8, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_08", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_8"])
			end)
		end
		if self.settings.slot_9 == -1 then
			self.nativeOptions["slot_9"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_9, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_09", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_9"])
			end)
		end	
		if self.settings.slot_10 == -1 then
			self.nativeOptions["slot_10"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_10, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_10", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_10"])
			end)
		end	
		if self.settings.slot_11 == -1 then
			self.nativeOptions["slot_11"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_11, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_11", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_11"])
			end)
		end	
		if self.settings.slot_12 == -1 then
			self.nativeOptions["slot_12"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_12, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_12", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_12"])
			end)
		end
		if self.settings.slot_13 == -1 then
			self.nativeOptions["slot_13"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_13, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_13", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_13"])
			end)
		end	
		if self.settings.slot_14 == -1 then
			self.nativeOptions["slot_14"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_14, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_14", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_14"])
			end)
		end
		if self.settings.slot_15 == -1 then
			self.nativeOptions["slot_15"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_15, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_15", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_15"])
			end)
		end	
		if self.settings.slot_16 == -1 then
			self.nativeOptions["slot_16"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_16, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_16", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_16"])
			end)
		end
		if self.settings.slot_17 == -1 then
			self.nativeOptions["slot_17"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_17, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_17", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_17"])
				if self.nativeOptions["jesseRomanced"] ~= nil then
					nativeSettings.removeOption(self.nativeOptions["jesseRomanced"])
					nativeSettings.removeSubcategory("/questcore/jesseRomanced")
				end
			end)
			nativeSettings.addSubcategory("/questcore/jesseRomanced", loc.jesseRomanced)
			self.nativeOptions["jesseRomanced"] = nativeSettings.addSwitch("/questcore/jesseRomanced", loc.loopDisabled, loc.loopDisabledDesc, self.settings.jesseRomanced, false, function(state)
				self.settings.jesseRomanced = state
				if state == true then
					Game.GetQuestsSystem():SetFactStr("slot_17_loop_disabled", 1)
				else
					Game.GetQuestsSystem():SetFactStr("slot_17_loop_disabled", 0)				
				end
			end)
		end	
		if self.settings.slot_18 == -1 then
			self.nativeOptions["slot_18"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_18, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_18", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_18"])
			end)
		end
		if self.settings.slot_19 == -1 then
			self.nativeOptions["slot_19"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_19, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_19", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_19"])
			end)			
			if  Game.GetQuestsSystem():GetFactStr("i_simp_for_aurore") <= 0 then
				if Game.GetQuestsSystem():GetFactStr("q304_border_car_queue") > 0 then
					nativeSettings.addSubcategory("/questcore/aurore", loc.aurore)
					self.isAuroreOverrideShown = true
					self.nativeOptions["aurore"] = nativeSettings.addButton("/questcore/aurore", loc.auroreOverride, loc.overrideDesc, loc.override, 45, function()
						Game.GetQuestsSystem():SetFactStr("i_simp_for_aurore", 1)
						self.isAuroreOverrideShown = false
						if self.nativeOptions["aurore"] ~= nil then
							nativeSettings.removeOption(self.nativeOptions["aurore"])
							nativeSettings.removeSubcategory("/questcore/aurore")
						end
					end)
				end
			end
		end	
		if self.settings.slot_20 == -1 then
			self.nativeOptions["slot_20"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_20, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_20", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_20"])
			end)
		end	
		if self.settings.slot_21 == -1 then
			self.nativeOptions["slot_21"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_21, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_21", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_21"])
			end)
		end	
		if self.settings.slot_22 == -1 then
			self.nativeOptions["slot_22"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_22, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_22", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_22"])
			end)
		end
		if self.settings.slot_23 == -1 then
			self.nativeOptions["slot_23"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_23, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_23", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_23"])
			end)
		end	
		if self.settings.slot_24 == -1 then
			self.nativeOptions["slot_24"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_24, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_24", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_24"])
			end)
		end
		if self.settings.slot_25 == -1 then
			self.nativeOptions["slot_25"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_25, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_25", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_25"])
			end)
		end	
		if self.settings.slot_26 == -1 then
			self.nativeOptions["slot_26"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_26, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_26", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_26"])
			end)
		end
		if self.settings.slot_27 == -1 then
			self.nativeOptions["slot_27"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_27, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_27", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_27"])
				if self.nativeOptions["alexRomanced"] ~= nil then
					nativeSettings.removeOption(self.nativeOptions["alexRomanced"])
					if self.nativeOptions["alexRomancedOver"] ~= nil then
						nativeSettings.removeOption(self.nativeOptions["alexRomancedOver"])
					end
					nativeSettings.removeSubcategory("/questcore/alexRomanced")
				end
			end)
			nativeSettings.addSubcategory("/questcore/alexRomanced", loc.alexRomanced)
			self.nativeOptions["alexRomanced"] = nativeSettings.addSwitch("/questcore/alexRomanced", loc.photomode, loc.photomodeDesc, self.settings.alexPhotomode, false, function(state)
				self.settings.alexPhotomode = state
				if state == true then
					Game.GetQuestsSystem():SetFactStr("alex_rom_allow_pm", 1)
				else
					Game.GetQuestsSystem():SetFactStr("alex_rom_allow_pm", 0)				
				end
			end)			
			if  Game.GetQuestsSystem():GetFactStr("alex_rom_trigger") <= 0 then
				if Game.GetQuestsSystem():GetFactStr("q304_04e_accepted_heart_to_heart_offer") <= 0 or Game.GetQuestsSystem():GetFactStr("q304_farida_started_secured") >= 1 then
					self.isAlexOverrideShown = true
					self.nativeOptions["alexRomancedOver"] = nativeSettings.addButton("/questcore/alexRomanced", loc.alexOverrideDesc, loc.alexOverrideDesc, loc.override, 45, function()
						Game.GetQuestsSystem():SetFactStr("alex_rom_trigger", 99)
						self.isAlexOverrideShown = false
						if self.nativeOptions["alexRomancedOver"] ~= nil then
							nativeSettings.removeOption(self.nativeOptions["alexRomancedOver"])
						end
					end)
				end
			end
			
		end	
		if self.settings.slot_28 == -1 then
			self.nativeOptions["slot_28"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_28, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_28", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_28"])
			end)
		end
		if self.settings.slot_29 == -1 then
			self.nativeOptions["slot_29"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_29, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_29", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_29"])
			end)
		end	
		if self.settings.slot_30 == -1 then
			self.nativeOptions["slot_30"] = nativeSettings.addButton("/questcore/main", loc.titles.slot_30, loc.resetDesc, loc.reset, 45, function()
				Game.GetQuestsSystem():SetFactStr("deceptious_quest_30", 1)
				nativeSettings.removeOption(self.nativeOptions["slot_30"])
			end)
		end
		nativeSettings.removeSubcategory("/questcore/placeholder")
		self.isPopulated = true
	end
end

function questcore:nativeUnload()
	if self.isPopulated == true then 
		local nativeSettings = GetMod("nativeSettings") 
		
		self.settings.slot_1 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_01")
		self.settings.slot_2 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_02")
		self.settings.slot_3 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_03")
		self.settings.slot_4 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_04")
		self.settings.slot_5 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_05")
		self.settings.slot_6 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_06")
		self.settings.slot_7 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_07")
		self.settings.slot_8 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_08")
		self.settings.slot_9 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_09")
		self.settings.slot_10 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_10")
		self.settings.slot_11 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_11")
		self.settings.slot_12 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_12")
		self.settings.slot_13 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_13")
		self.settings.slot_14 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_14")
		self.settings.slot_15 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_15")
		self.settings.slot_16 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_16")
		self.settings.slot_17 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_17")
		self.settings.slot_18 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_18")
		self.settings.slot_19 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_19")
		self.settings.slot_20 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_20")
		self.settings.slot_21 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_21")
		self.settings.slot_22 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_22")
		self.settings.slot_23 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_23")
		self.settings.slot_24 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_24")
		self.settings.slot_25 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_25")
		self.settings.slot_26 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_26")
		self.settings.slot_27 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_27")
		self.settings.slot_28 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_28")
		self.settings.slot_29 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_29")
		self.settings.slot_30 = Game.GetQuestsSystem():GetFactStr("deceptious_quest_30")
		
		if self.settings.slot_1 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_1"])
			if self.nativeOptions["hotFuzz"] ~= nil then
				nativeSettings.removeOption(self.nativeOptions["hotFuzz"])
				nativeSettings.removeSubcategory("/questcore/hotFuzz")
			end
		end
		if self.settings.slot_2 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_2"])
		end
		if self.settings.slot_3 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_3"])
			if self.nativeOptions["californication"] ~= nil then
				nativeSettings.removeOption(self.nativeOptions["californication"])
				nativeSettings.removeSubcategory("/questcore/californication")
			end
		end
		if self.settings.slot_4 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_4"])
		end
		if self.settings.slot_5 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_5"])
		end
		if self.settings.slot_6 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_6"])
		end
		if self.settings.slot_7 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_7"])
			if self.nativeOptions["encore"] ~= nil then
				nativeSettings.removeOption(self.nativeOptions["encore"])
				nativeSettings.removeSubcategory("/questcore/encore")
			end
		end
		if self.settings.slot_8 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_8"])
		end
		if self.settings.slot_9 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_9"])
		end
		if self.settings.slot_10 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_10"])
		end
		if self.settings.slot_11 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_11"])
		end
		if self.settings.slot_12 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_12"])
		end
		if self.settings.slot_13 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_13"])
		end
		if self.settings.slot_14 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_14"])
		end
		if self.settings.slot_15 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_15"])
		end
		if self.settings.slot_16 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_16"])
		end
		if self.settings.slot_17 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_17"])
			if self.nativeOptions["jesseRomanced"] ~= nil then
				nativeSettings.removeOption(self.nativeOptions["jesseRomanced"])
				nativeSettings.removeSubcategory("/questcore/jesseRomanced")
			end
		end
		if self.settings.slot_18 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_18"])
		end
		if self.settings.slot_19 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_19"])
		end
		if self.isAuroreOverrideShown == true then
			if self.nativeOptions["aurore"] ~= nil then
				nativeSettings.removeOption(self.nativeOptions["aurore"])
				nativeSettings.removeSubcategory("/questcore/aurore")
			end
		end
		if self.settings.slot_20 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_20"])
		end
		if self.settings.slot_21 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_21"])
		end
		if self.settings.slot_22 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_22"])
		end
		if self.settings.slot_23 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_23"])
		end
		if self.settings.slot_24 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_24"])
		end
		if self.settings.slot_25 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_25"])
		end
		if self.settings.slot_26 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_26"])
		end
		if self.settings.slot_27 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_27"])
			if self.nativeOptions["alexRomanced"] ~= nil then
				nativeSettings.removeOption(self.nativeOptions["alexRomanced"])
				if self.nativeOptions["alexRomancedOver"] ~= nil then
					nativeSettings.removeOption(self.nativeOptions["alexRomancedOver"])
				end
				nativeSettings.removeSubcategory("/questcore/alexRomanced")
			end
		end
		if self.settings.slot_28 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_28"])
		end
		if self.settings.slot_29 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_29"])	
		end
		if self.settings.slot_30 == -1 then
			nativeSettings.removeOption(self.nativeOptions["slot_30"])
		end
		nativeSettings.addSubcategory("/questcore/placeholder", loc.placeholder)
		self.isPopulated = false
	end
end

return questcore:setup()