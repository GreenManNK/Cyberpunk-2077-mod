-- NCPD_Radio_On_Foot Configurator --
-- by Beckylou: 2025-03-07         --

local NCPD_Radio_On_Foot = {
	 OnFoot_Fact = 'ncpd_radio_on_foot_onfoot'
	,InVehicle_Fact = 'ncpd_radio_on_foot_invehicle'
	,ZeroHeat_Fact = 'ncpd_radio_on_foot_zeroheat'
	,showUIWindow = false
}
NCPD_Radio_On_Foot.Init = (function(self)
	-- can't think of anything
end)

NCPD_Radio_On_Foot.SetGameFact = (function(self,Setting,Value)
	local QS = GameInstance.GetQuestsSystem()
	QS:SetFact(Setting,Value)
end)

NCPD_Radio_On_Foot.GetGameFact = (function(self,Setting)
	local QS = GameInstance.GetQuestsSystem()
	return QS:GetFact(Setting)
end)

NCPD_Radio_On_Foot.Draw = (function(self)
    if self.showUIWindow then
        self:drawUIWindow()
    end
end)

NCPD_Radio_On_Foot.ShowCETMenu = (function(self,show)
    self.showUIWindow = show and true or false
end)


registerForEvent('onInit', function()
	NCPD_Radio_On_Foot:Init()
end)

registerForEvent("onOverlayOpen", function()
	NCPD_Radio_On_Foot:ShowCETMenu(true)
end)

registerForEvent("onOverlayClose", function()
	NCPD_Radio_On_Foot:ShowCETMenu(false)
end)

registerForEvent("onDraw", function()
	NCPD_Radio_On_Foot:Draw()
end)

NCPD_Radio_On_Foot.drawUIWindow = (function(self)
	local WindowWidth, WindowHeight = ImGui.CalcTextSize('NCPD Radio On Foot And Then One More!') -- it just sets the default size of the window!
    ImGui.SetNextWindowPos(WindowWidth/2, WindowWidth*2, ImGuiCond.FirstUseEver)
	ImGui.PushStyleVar(ImGuiStyleVar.WindowMinSize, WindowWidth, WindowHeight*7)
	ImGui.SetNextWindowSize(WindowWidth, WindowHeight*7, ImGuiCond.FirstUseEver)
	local test = false
	local HeatSettings = {
		 "Off"
		,"Always On"
		,"Heat 2+"
		,"Heat 3+"
		,"Heat 4+"
		,"Heat 5"
	}
	local OnFoot_Value = NCPD_Radio_On_Foot:GetGameFact(NCPD_Radio_On_Foot.OnFoot_Fact)+1
	local InVehicle_Value = NCPD_Radio_On_Foot:GetGameFact(NCPD_Radio_On_Foot.InVehicle_Fact)+1
	local ZeroHeat_Value = (NCPD_Radio_On_Foot:GetGameFact(NCPD_Radio_On_Foot.ZeroHeat_Fact)==0)

	local Setting_OnFoot_Value = OnFoot_Value
	local Setting_InVehicle_Value = InVehicle_Value
	local Setting_ZeroHeat_Value = ZeroHeat_Value
	
	if ImGui.Begin("NCPD Radio On Foot", ImGuiWindowFlags.None) then
		Setting_OnFoot_Value = ImGui.Combo("On Foot", OnFoot_Value, HeatSettings, #HeatSettings)
		if (Setting_OnFoot_Value ~= OnFoot_Value) then
			NCPD_Radio_On_Foot:SetGameFact(NCPD_Radio_On_Foot.OnFoot_Fact,Setting_OnFoot_Value-1)
		end
		Setting_InVehicle_Value = ImGui.Combo("In Vehicle", InVehicle_Value, HeatSettings, #HeatSettings)
		if (Setting_InVehicle_Value ~= InVehicle_Value) then
			NCPD_Radio_On_Foot:SetGameFact(NCPD_Radio_On_Foot.InVehicle_Fact,Setting_InVehicle_Value-1)
		end
		Setting_ZeroHeat_Value = ImGui.Checkbox("Resume Normal Patrol Notifications",ZeroHeat_Value)
		if (Setting_ZeroHeat_Value ~= ZeroHeat_Value) then
			NCPD_Radio_On_Foot:SetGameFact(NCPD_Radio_On_Foot.ZeroHeat_Fact,(Setting_ZeroHeat_Value==true) and 0 or -1)
		end
		ImGui.End()
	end
end)

return NCPD_Radio_On_Foot
