local SmugglerManager = {}


local tt = Game.GetTargetingSystem()
local ts = Game.GetTransactionSystem()
local tp = Game.GetTeleportationFacility()
local as = Game.GetActivityLogSystem()

local moneyID = ItemID.new(TweakDBID.new("Items.money"))


function SmugglerManager.UpdateSmugglerWindow()
	local player = Game.GetPlayer()

	if player then
		local object = tt:GetLookAtObject(player, false, false)

		if object and object:ToString() == "NPCPuppet" and object:GetRecordID().hash == 966543935 then
			drawSmuggleWindow = true
		else
			drawSmuggleWindow = false
		end
	end
end

function SmugglerManager.CheckSmuggler(object, smugglingCost)
    if object:ToString() == "NPCPuppet" and object:GetRecordID().hash == 966543935 then
        if drawSmuggleWindow then
            ts:RemoveItem(Game.GetPlayer(), moneyID, 50000)
            tp:Teleport(Game.GetPlayer(), ToVector4{ x = -899.2886, y = 1319.1085, z = 5.8175964, w = 1.0 } , EulerAngles.new(0,0,-45.378467559814))
            drawSmuggleWindow = false
        else
            moneyQuantity = ts:GetItemQuantity(Game.GetPlayer(), moneyID)

            if moneyQuantity >= smugglingCost then 
                drawSmuggleWindow = true
            else
                as:AddLog("Smuggling: Not enough eddies for smuggling. You need 50.000")
            end
        end

    end

end

function SmugglerManager.DrawSmugglerWindow(drawSmuggleWindow)
	ImGui.PushStyleColor(ImGuiCol.PopupBg, 0.21, 0.08, 0.08, 0.85)
	ImGui.PushStyleColor(ImGuiCol.Border, 0.4, 0.17, 0.12, 1)
	ImGui.PushStyleColor(ImGuiCol.Separator, 0.4, 0.17, 0.12, 1)
	
	if (drawSmuggleWindow) then
		ImGui.BeginTooltip()
		ImGui.SetWindowFontScale(1.6)
		ImGui.Spacing()
			ImGui.TextColored(0.45, 1, 0.5, 1, "[Warning] Getting out of the Watson District during Lockdown may break some quests.")
			ImGui.Spacing()
			ImGui.Separator()
			ImGui.Spacing()
			ImGui.TextColored(0.2, 1, 1, 1, "Sure, I can smuggle you out of the Watson District, but it will cost you.")
			ImGui.Spacing()
			ImGui.TextColored(0.2, 1, 1, 1, "Say, 50.000 eddies? I need it to be worth the risk for me!")
			ImGui.Spacing()
			ImGui.Separator()
			ImGui.Spacing()
			ImGui.TextColored(0.98, 0.85, 0.25, 1, "[F] Sure, just get me out of here already")
			ImGui.Spacing()
			ImGui.Spacing()
			ImGui.TextColored(0.98, 0.85, 0.25, 1, "[Look Away] Nah, maybe another time.")
			ImGui.Spacing()
		ImGui.EndTooltip()
	end

	ImGui.PopStyleColor(3)
end

function SmugglerManager.Log()
	print('[Unlock NightCity] SmugglerManager Loaded')
end

return SmugglerManager