-- Clean Effects - Settings
-- Author: Riiswalker/lopstar

local settings = {
    -- Cyberware
    sandevistanFX = "sandevistan",
    sandevistanFX_s = true,
    kerenzikovFX = "kereznikov",
    kerenzikovFX_s = true,
    berserkFX = "perk_edgerunner",
    berserkFX_s = 1,
    adconvFX = "catch_me",
    adconvFX_s = true,
    -- Perks
    furyFX = "perk_edgerunner_player",
    furyFX_s = true,
    overclockFX = "perk_overclock",
    overclockFX_s = true,
    -- Heal Items
    inhalerFX = "splinter_buff",
    inhalerFX_s = true,
    injectorFX = "reflex_buster",
    injectorFX_s = true,
    bloodpumpFX = "reflex_buster",
    bloodpumpFX_s = 1,
    -- Other
    lowhealthFX = 40,
    lowhealthFX_s = 1,

}

-- Lists ---------------------------------------------------------------------------------------------------------

local berserklist = {
    [1] = "Vanilla",
    [2] = "Off",
    [3] = "Leeroy Jenkins",
    [4] = "Reflex Buster",
}

local bloodpumplist = {
    [1] = "Vanilla",
    [2] = "Off",
    [3] = "Splinter Buff",
    [4] = "Time Bank",
}

local lowhealthlist = {
    [1] = "Vanilla",
    [2] = "Off",
    [3] = "Low Threshold",
}

-- Save -----------------------------------------------------------------------------------------------------------

registerForEvent("onInit", function()
    LoadSettings()
    ApplySettings()
    addNativeSettings()
end)


function SaveSettings()
  local validJson, contents = pcall(function() return json.encode(settings) end)

  if validJson and contents ~= nil then
    local file = io.open("settings.json", "w+")
    file:write(contents)
    file:close()
  end
end


function LoadSettings()
  local file = io.open('settings.json', 'r')
  if file ~= nil then
    local contents = file:read("*a")
    local validJson, savedSettings = pcall(function() return json.decode(contents) end)
    file:close()

    if validJson then
      for key, _ in pairs(settings) do
        if savedSettings[key] ~= nil then
          settings[key] = savedSettings[key]
        end
      end
    end
  end
end

-- Variables -----------------------------------------------------------------------------------------------------

function ApplySettings()
    -- Cyberware
    TweakDB:SetFlat("playerStateMachineTimeDilation.timeDilationAcceptedReasons.sandevistanEffectReasons", {settings.sandevistanFX})
    TweakDB:SetFlat("playerStateMachineTimeDilation.timeDilationAcceptedReasons.kerenzikovEffectReasons", {settings.kerenzikovFX})
    TweakDB:SetFlat("BaseStatusEffect.AdvancedBerserkPlayerBuff_inline0.name", settings.berserkFX)
    TweakDB:SetFlat("BaseStatusEffect.DetectorRushPlayerBuffCommon_inline2.name", settings.adconvFX)
    -- Perks
    TweakDB:SetFlat("BaseStatusEffect.Tech_Master_Perk_3_VFX_inline0.name", settings.furyFX)
    TweakDB:SetFlat("BaseStatusEffect.Intelligence_Central_Milestone_3_Overclock_Buff_inline4.vfxName", settings.overclockFX)
    -- Heal Items
    TweakDB:SetFlat("BaseStatusEffect.InhalerBuff_inline0.name", settings.inhalerFX)
    TweakDB:SetFlat("BaseStatusEffect.InjectorBuff_inline0.name", settings.injectorFX)
    TweakDB:SetFlat("CyberwareAction.BloodPumpVFXObjectActionEffect_inline0.vfxName", settings.bloodpumpFX)
    -- Other
    TweakDB:SetFlat("player.hitVFX.lowHealthThreshold", settings.lowhealthFX)
end

-- Settings ------------------------------------------------------------------------------------------------------

function addNativeSettings()
    local nativeSettings = GetMod("nativeSettings")

    if not nativeSettings then -- Make sure the mod is installed
        print("Error: NativeSettings not found!")
        return
    end

    nativeSettings.addTab("/CleanEffects", "Clean Effects")
    nativeSettings.addSubcategory("/CleanEffects/Sub1", "Effects marked with * need you to load a save to be applied")

    -- Cyberware
    nativeSettings.addSubcategory("/CleanEffects/Cyberware", "Cyberware")

    nativeSettings.addSwitch("/CleanEffects/Cyberware", "Sandevistan Effect*", "Need to load a save after changing this", settings.sandevistanFX_s, false, function(state)
        settings.sandevistanFX_s = state
        if state == true then
            settings.sandevistanFX = "sandevistan"
        else
            settings.sandevistanFX = "none"
        end
        TweakDB:SetFlat("playerStateMachineTimeDilation.timeDilationAcceptedReasons.sandevistanEffectReasons", {settings.sandevistanFX})
        SaveSettings()
    end)

    nativeSettings.addSwitch("/CleanEffects/Cyberware", "Kerenzikov Effect*", "Need to load a save after changing this", settings.kerenzikovFX_s, false, function(state)
        settings.kerenzikovFX_s = state
        if state == true then
            settings.kerenzikovFX = "kereznikov"
        else
            settings.kerenzikovFX = "none"
        end
        TweakDB:SetFlat("playerStateMachineTimeDilation.timeDilationAcceptedReasons.kereznikovEffectReasons", {settings.kerenzikovFX})
        SaveSettings()
    end)

    nativeSettings.addSelectorString("/CleanEffects/Cyberware", "Berserk Effect", "Hier könnte Ihre Werbung stehen", berserklist, settings.berserkFX_s, 4, function(value)
        settings.berserkFX_s = value
        if value == 1 then
            settings.berserkFX = "perk_edgerunner"
        elseif value == 2 then
            settings.berserkFX = "none"
        elseif value == 3 then
            settings.berserkFX = "catch_me"
        else
            settings.berserkFX = "reflex_buster"
        end
        TweakDB:SetFlat("BaseStatusEffect.AdvancedBerserkPlayerBuff_inline0.name", settings.berserkFX)
        SaveSettings()
    end)

    nativeSettings.addSwitch("/CleanEffects/Cyberware", "Adrenaline Converter Effect", "Deactivates the grey glitching effect when you enter combat. Also works on Adreno Trigger", settings.adconvFX_s, false, function(state)
        settings.adconvFX_s = state
        if state == true then
            settings.adconvFX = "catch_me"
        else
            settings.adconvFX = "none"
        end
        TweakDB:SetFlat("BaseStatusEffect.DetectorRushPlayerBuffCommon_inline2.name", settings.adconvFX)
        SaveSettings()
    end)

    -- Perks
    nativeSettings.addSubcategory("/CleanEffects/Perks", "Perks")

    nativeSettings.addSwitch("/CleanEffects/Perks", "Fury Effect", "The effect that triggers when you go cyberpsycho because of the Edgerunner Perk", settings.furyFX_s, false, function(state)
        settings.furyFX_s = state
        if state == true then
            settings.furyFX = "perk_edgerunner_player"
        else
            settings.furyFX = "none"
        end
        TweakDB:SetFlat("BaseStatusEffect.Tech_Master_Perk_3_VFX_inline0.name", settings.furyFX)
        SaveSettings()
    end)

    nativeSettings.addSwitch("/CleanEffects/Perks", "Overclock Effect", "The effect that triggers when you activate your Cyberdeck with the Overclock Perk", settings.overclockFX_s, false, function(state)
        settings.overclockFX_s = state
        if state == true then
            settings.overclockFX = "perk_overclock"
        else
            settings.overclockFX = "none"
        end
        TweakDB:SetFlat("BaseStatusEffect.Intelligence_Central_Milestone_3_Overclock_Buff_inline4.vfxName", settings.overclockFX)
        SaveSettings()
    end)

    -- Heal Items
    nativeSettings.addSubcategory("/CleanEffects/HealItems", "Heal Items")

    nativeSettings.addSwitch("/CleanEffects/HealItems", "Inhaler Effect", "Max Doc", settings.inhalerFX_s, false, function(state)
        settings.inhalerFX_s = state
        if state == true then
            settings.inhalerFX = "splinter_buff"
        else
            settings.inhalerFX = "none"
        end
        TweakDB:SetFlat("BaseStatusEffect.InhalerBuff_inline0.name", settings.inhalerFX)
        SaveSettings()
    end)

    nativeSettings.addSwitch("/CleanEffects/HealItems", "Injector Effect", "Bounce Back", settings.injectorFX_s, false, function(state)
        settings.injectorFX_s = state
        if state == true then
            settings.injectorFX = "reflex_buster"
        else
            settings.injectorFX = "none"
        end
        TweakDB:SetFlat("BaseStatusEffect.InjectorBuff_inline0.name", settings.injectorFX)
        SaveSettings()
    end)

    nativeSettings.addSelectorString("/CleanEffects/HealItems", "Blood Pump Effect", ":)", bloodpumplist, settings.bloodpumpFX_s, 4, function(value)
        settings.bloodpumpFX_s = value
        if value == 1 then
            settings.bloodpumpFX = "reflex_buster"
        elseif value == 2 then
            settings.bloodpumpFX = "none"
        elseif value == 3 then
            settings.bloodpumpFX = "splinter_buff"
        else
            settings.bloodpumpFX = "time_bank"
        end
        TweakDB:SetFlat("CyberwareAction.BloodPumpVFXObjectActionEffect_inline0.vfxName", settings.bloodpumpFX)
        SaveSettings()
    end)

    -- Other
    nativeSettings.addSubcategory("/CleanEffects/Other", "Other")

    nativeSettings.addSelectorString("/CleanEffects/Other", "Low Health Effect", "Vanilla Triggers at 40% Health, Low Treshold at 25%", lowhealthlist, settings.lowhealthFX_s, 3, function(value)
        settings.lowhealthFX_s = value
        if value == 1 then
            settings.lowhealthFX = 40
        elseif value == 2 then
            settings.lowhealthFX = 0
        else
            settings.lowhealthFX = 25
        end
        TweakDB:SetFlat("player.hitVFX.lowHealthThreshold", settings.lowhealthFX)
        SaveSettings()
    end)
end