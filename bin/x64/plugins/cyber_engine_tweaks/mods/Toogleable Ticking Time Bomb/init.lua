local bombON = true -- true: default ON

function turnBombON()
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline13.maxRangeAddition", 5.0)
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline5.value", 0.5)
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline0.floatValues", { 50.0, 3.0 })
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2.loc_name_key", "Lockey#893331")
    TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2.loc_desc_key", "Lockey#89332")
	bombON = true
	PreventionSystem.ShowMessage("Ticking Time Bomb - Bomb ON", 2.0)
end

function turnBombOFF()
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline13.maxRangeAddition", -1.0)
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline5.value", 0.2) -- increase the damage reduction to 90%, vanilla is 0.5
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline0.floatValues", { 80.0, 3.0 }) -- UI for damage reduction
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2.loc_name_key", "Lockey#893332")
    TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2.loc_desc_key", "Lockey#893321")
	bombON = false
	PreventionSystem.ShowMessage("Ticking Time Bomb - Bomb OFF", 2.0)
end

registerInput('Bomb_TOOGLE', 'TOOGLE Ticking Time Bomb', function(keypress1)
	if keypress1 then 
	if bombON == true then
		turnBombOFF()
	else
		turnBombON()
	end
	end
end)

registerForEvent("onInit", function()
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline13.maxRangeAddition", -1.0)
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline5.value", 0.2) -- increase the damage reduction to 90%, vanilla is 0.5
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2_inline0.floatValues", { 80.0, 3.0 }) -- UI for damage reduction
	TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2.loc_name_key", "Lockey#893332")
    TweakDB:SetFlat("NewPerks.Tech_Master_Perk_2.loc_desc_key", "Lockey#893321")
	bombON = false
end)