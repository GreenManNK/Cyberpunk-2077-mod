
KillsCounterDisplay = {
	description = "Kills Counter Display",
	author = "Scream81", 
	version = "1.1",
    -- System
    is_ready = false,
    is_hud_initialized = false,
    is_active = false,
    cet_required_version = 34.1, -- 1.34.1
    codeware_required_version = 13.0, -- 1.13.0
}

KillsWidget = {
    weapon_roster_controller = nil,
    HorizPanel = nil,
    KillsTitle = nil,
    KillsText = nil,
}

registerForEvent('onInit', function()

    if not KillsCounterDisplay:Checks() then
        print('[KillsCounterDisplay][Error] Mod failed to load due to missing dependencies.')
        return
    end

    Observe("WeaponRosterGameController", "OnInitialize", function(this)
        KillsWidget.weapon_roster_controller = this
        KillsCounterDisplay:CreateKCDisplay()
		KillsCounterDisplay:SetKCDisplay()
        KillsCounterDisplay.is_hud_initialized = true
    end)

    Observe("WeaponRosterGameController", "OnWeaponDataChanged", function(this, evt)
        KillsWidget.weapon_roster_controller = this
        KillsCounterDisplay:SetKCDisplay()
        KillsCounterDisplay:Show(true)
    end)
	
    Observe("WeaponRosterGameController", "OnWeaponDataChanged_MP", function(this, evt) -- is it doing something??
        KillsWidget.weapon_roster_controller = this
        KillsCounterDisplay:SetKCDisplay()
        KillsCounterDisplay:Show(true)
    end)
	
    Observe("WeaponRosterGameController", "OnMountingEvent", function(this, evt) -- is it doing something??
        KillsWidget.weapon_roster_controller = this
        KillsCounterDisplay:SetKCDisplay()
        KillsCounterDisplay:Show(true)
    end)

    Observe("WeaponRosterGameController", "OnUnmountingEvent", function(this, evt) -- is it doing something??
        KillsWidget.weapon_roster_controller = this
        KillsCounterDisplay:Show(false)
    end)

    KillsCounterDisplay.is_ready = true
     print("[KillsCounterDisplay][Info] Ready to Display Kills Counter.")

end)

function KillsCounterDisplay:CreateKCDisplay()

    if KillsWidget.weapon_roster_controller == nil then
        print("[KillsCounterDisplay][Error] Weapon Roster Game Controller not found.")
        KillsCounterDisplay.is_active = false
        return
    end
    local parent = KillsWidget.weapon_roster_controller:GetRootCompoundWidget():GetWidget("weapon_on_foot"):GetWidget("ammo_counter"):GetWidget("weapon_wrapper"):GetWidget("weapon_holder")
    if parent == nil then
        print("[KillsCounterDisplay][Error] Weapon Holder not found.")
        KillsCounterDisplay.is_active = false
        return
    -- elseif parent:GetWidget("KC") ~= nil then
        -- KillsCounterDisplay.is_active = true
         -- print("[KillsCounterDisplay][Info] Kills Widget found.")
       -- return
    end

    KillsWidget.HorizPanel = inkHorizontalPanel.new()
	KillsWidget.HorizPanel:SetName('KC'); CName.add('KC')
    KillsWidget.HorizPanel:SetAnchor(inkEAnchor.TopRight)
    KillsWidget.HorizPanel:SetHAlign(inkEHorizontalAlign.Right)
    --KillsWidget.HorizPanel:SetVAlign(inkEVerticalAlign.Top)
	KillsWidget.HorizPanel:SetFitToContent(true)
    KillsWidget.HorizPanel:SetMargin(0, 0, 25, 0)
    KillsWidget.HorizPanel:Reparent(parent)

    KillsWidget.KillsTitle = inkText.new()
    KillsWidget.KillsTitle:SetName('KCtitle'); CName.add('KCtitle')
    KillsWidget.KillsTitle:SetText("Kills")
    KillsWidget.KillsTitle:SetFontFamily("base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily") -- ("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily")
    KillsWidget.KillsTitle:SetFontStyle("Medium")
    KillsWidget.KillsTitle:SetFontSize(20)
	KillsWidget.KillsTitle:SetLetterCase("UpperCase") --OriginalCase
    KillsWidget.KillsTitle:SetOpacity(1)
    KillsWidget.KillsTitle:SetMargin(0, 0, 10, 0)
    KillsWidget.KillsTitle:SetFitToContent(true)
	KillsWidget.KillsTitle:SetTracking(2)
    KillsWidget.KillsTitle:SetStyle(ResRef.FromName("base\\gameplay\\gui\\common\\main_colors.inkstyle"))
    KillsWidget.KillsTitle:BindProperty("tintColor", "MainColors.Blue") --MainColors.Red
    KillsWidget.KillsTitle:Reparent(KillsWidget.HorizPanel)

    KillsWidget.KillsText = inkText.new()
    KillsWidget.KillsText:SetName('KCtext'); CName.add('KCtext')
    KillsWidget.KillsText:SetText("000")
    KillsWidget.KillsText:SetFontFamily("base\\gameplay\\gui\\fonts\\orbitron\\orbitron.inkfontfamily")
    KillsWidget.KillsText:SetFontStyle("Medium")
    KillsWidget.KillsText:SetMargin(0, 0, 25, 0)
    KillsWidget.KillsText:SetFitToContent(true)
    KillsWidget.KillsText:SetStyle(ResRef.FromName("base\\gameplay\\gui\\common\\main_colors.inkstyle"))
    KillsWidget.KillsText:BindProperty("tintColor", "MainColors.White")
    KillsWidget.KillsText:SetFontSize(20)
	KillsWidget.KillsText:SetTracking(2)
    KillsWidget.KillsText:Reparent(KillsWidget.HorizPanel)

    KillsCounterDisplay.is_active = true

end

function KillsCounterDisplay:SetKCDisplay()

    if not KillsCounterDisplay.is_active then
        return
    end

	local dataTrackingSystem = Game.GetScriptableSystemsContainer():Get('DataTrackingSystem')
	if (dataTrackingSystem == nil) then return end

	local killed = dataTrackingSystem.killedEnemies
	local finished = dataTrackingSystem.finishedEnemies
	
	local totalKills = tonumber(killed) + tonumber(finished)

	KillsWidget.KillsText:SetText(totalKills)

end

function KillsCounterDisplay:Show(on)

    if not KillsCounterDisplay.is_active then
        return
    end
    KillsWidget.HorizPanel:SetVisible(on)

end


function KillsCounterDisplay:Checks()

    -- Check Cyber Engine Tweaks Version
    local cet_version_str = GetVersion()
    local cet_version_major, cet_version_minor = cet_version_str:match("1.(%d+)%.*(%d*)")
    KillsCounterDisplay.cet_version_num = tonumber(cet_version_major .. "." .. cet_version_minor)

    -- Check CodeWare Version
    local code_version_str = Codeware.Version()
    local code_version_major, code_version_minor = code_version_str:match("1.(%d+)%.*(%d*)")
    KillsCounterDisplay.codeware_version_num = tonumber(code_version_major .. "." .. code_version_minor)

    if KillsCounterDisplay.cet_version_num < KillsCounterDisplay.cet_required_version then
        print("[KillsCounterDisplay][Error] requires Cyber Engine Tweaks version 1." .. KillsCounterDisplay.cet_required_version .. " or higher.")
        return false
    elseif KillsCounterDisplay.codeware_version_num < KillsCounterDisplay.codeware_required_version then
        print("[KillsCounterDisplay][Error] requires CodeWare version 1." .. KillsCounterDisplay.codeware_required_version .. " or higher.")
        return false
    end

    return true

end

function KillsCounterDisplay:Version()
    return KillsCounterDisplay.version
end

return KillsCounterDisplay