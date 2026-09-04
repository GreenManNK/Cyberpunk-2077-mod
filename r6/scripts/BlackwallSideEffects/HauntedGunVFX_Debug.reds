native func LogChannel(channel: CName, text: script_ref<String>);

// Debug function
public exec func MisterChedda_BlackwallVFX_StartTest(opt level: Int32) {
    let player = GetPlayer(GetGameInstance());
    if !IsDefined(player) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] Player not found!");
        return;
    }
    
    let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(GetGameInstance());
    if !IsDefined(system) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] HauntedGunVFXSystem not found!");
        return;
    }
    
    let testLevel = level > 0 ? level : 1;
    system.StartBlackwallEffect(player, testLevel);
    LogChannel(n"DEBUG", s"BlackwallVFX: Started test effect with level \(testLevel)");
}

public exec func MisterChedda_BlackwallVFX_StopVFX() {
    let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(GetGameInstance());
    if !IsDefined(system) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] HauntedGunVFXSystem not found!");
        return;
    }
    
    let gunActive = system.IsEffectActive();
    let quickhackActive = system.IsQuickhackEffectActive();
    
    system.StopBlackwallEffect();
    system.StopQuickhackBlackwallEffect();
    
    LogChannel(n"DEBUG", s"BlackwallVFX: [DEBUG] Manually stopped effects - Gun: \(gunActive), Quickhack: \(quickhackActive)");
}

// public exec func MisterChedda_BlackwallVFX_Status() {
//     let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(GetGameInstance());
//     if !IsDefined(system) {
//         LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] HauntedGunVFXSystem not found!");
//         return;
//     }
    
//     LogChannel(n"DEBUG", "BlackwallVFX: === Blackwall VFX System Status ===");
//     LogChannel(n"DEBUG", s"BlackwallVFX: Active: \(system.IsEffectActive())");
//     LogChannel(n"DEBUG", s"BlackwallVFX: Current Level: \(system.GetCurrentEffectLevel())");
//     LogChannel(n"DEBUG", s"BlackwallVFX: Total Effects: \(system.GetTotalEffectsTriggered())");
//     LogChannel(n"DEBUG", s"BlackwallVFX: Consecutive: \(system.GetConsecutiveEffects())");
//     LogChannel(n"DEBUG", s"BlackwallVFX: Haunted Gun Score: \(system.GetHauntedGunScore())");
//     LogChannel(n"DEBUG", s"BlackwallVFX: Escalation Multiplier: \(system.GetEscalationMultiplier())");
//     LogChannel(n"DEBUG", s"BlackwallVFX: Current VFX Effect: \(NameToString(system.GetCurrentEffectName()))");
// }

// Debug function to manually adjust the score
public exec func MisterChedda_BlackwallVFX_SetScore(score: Int32) {
    let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(GetGameInstance());
    if !IsDefined(system) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] HauntedGunVFXSystem not found!");
        return;
    }
    
    system.SetScore(score);
    LogChannel(n"DEBUG", s"BlackwallVFX: Manually set persistent score to \(score)");
}

// Debug function to reset the persistent score
public exec func MisterChedda_BlackwallVFX_ResetScore() {
    let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(GetGameInstance());
    if !IsDefined(system) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] HauntedGunVFXSystem not found!");
        return;
    }
    
    system.ResetScore();
    LogChannel(n"DEBUG", "BlackwallVFX: Reset persistent score to 0");
}



// Debug function to test direct effects
public exec func MisterChedda_BlackwallVFX_TestDirectEffects(opt effectType: Int32) {
    let player = GetPlayer(GetGameInstance());
    if !IsDefined(player) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] Player not found!");
        return;
    }
    
    if effectType == 0 {
        effectType = 1;
    }
    
    if effectType == 1 {
        // Test custom warp effect (bonus effect)
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] === TESTING CUSTOM WARP LOW EFFECT ===");
        GameObjectEffectHelper.StartEffectEvent(player, n"custom_warp_low", false);
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] Started custom_warp_low effect (non-looping)");
        
    } else if effectType == 2 {
        // Test custom bright spots effect (quickhack analog)
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] === TESTING CUSTOM BRIGHT SPOTS EFFECT ===");
        GameObjectEffectHelper.StartEffectEvent(player, n"custom_bright_spots", true);
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] Started custom_bright_spots effect (looping) - Use MisterChedda_BlackwallVFX_Stop() to stop");
        
    } else if effectType == 3 {
        // Test custom high short effect (bonus effect)
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] === TESTING CUSTOM HIGH SHORT EFFECT ===");
        GameObjectEffectHelper.StartEffectEvent(player, n"custom_high_short", false);
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] Started custom_high_short effect (non-looping)");
        
    } else if effectType == 4 {
        // Test lab delicate effect (quickhack bonus)
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] === TESTING LAB DELICATE EFFECT ===");
        GameObjectEffectHelper.StartEffectEvent(player, n"q304_blackwall_onscreen_lab_delicate_single_02", false);
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] Started lab delicate effect (non-looping)");
        
    } else {
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] Usage: MisterChedda_BlackwallVFX_TestDirectEffects()");
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG]   1 = Custom Warp Low (bonus, non-looping)");
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG]   2 = Custom Bright Spots (quickhack analog, looping)");
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG]   3 = Custom High Short (bonus, non-looping)");
        LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG]   4 = Lab Delicate (quickhack bonus, non-looping)");
    }
}

// Consolidated debug command - shows complete system status and configuration
public exec func MisterChedda_BlackwallVFX_Status() {
    let player = GetPlayer(GetGameInstance());
    if !IsDefined(player) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] Player not found!");
        return;
    }
    
    let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(GetGameInstance());
    if !IsDefined(system) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] System not found!");
        return;
    }
    
    let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(GetGameInstance());
    
    LogChannel(n"DEBUG", "BlackwallVFX: =============== BLACKWALL SIDE EFFECTS STATUS ===============");
    
    // === MOD SETTINGS ===
    if IsDefined(settings) {
        let intensityMode = Equals(settings.intensityLevel, BlackwallSideEffects_IntensityLevel.Low) ? "Low" : "Default";
        let enabled = settings.enabled ? "Enabled" : "Disabled";
        
        LogChannel(n"DEBUG", s"BlackwallVFX: Mod Status: \(enabled) | Intensity Mode: \(intensityMode)");
        
        if Equals(settings.intensityLevel, BlackwallSideEffects_IntensityLevel.Low) {
            LogChannel(n"DEBUG", "BlackwallVFX: Low Mode: Heavy@10+ (was 6+), Bonus: 2%/5%/3% (was 10%/25%/15%)");
        } else {
            LogChannel(n"DEBUG", "BlackwallVFX: Default Mode: Heavy@6+, Bonus: 10%/25%/15%");
        }
    } else {
        LogChannel(n"DEBUG", "BlackwallVFX: Mod Settings: NOT AVAILABLE - using defaults");
    }
    
    // === SYSTEM STATUS ===
    LogChannel(n"DEBUG", s"BlackwallVFX: Gun VFX Active: \(system.IsEffectActive()) | Quickhack VFX Active: \(system.IsQuickhackEffectActive())");
    LogChannel(n"DEBUG", s"BlackwallVFX: Current Level: \(system.GetCurrentEffectLevel()) | Total Effects: \(system.GetTotalEffectsTriggered())");
    LogChannel(n"DEBUG", s"BlackwallVFX: Haunted Gun Score: \(system.m_hauntedGunScore) | Escalation Multiplier: \(system.GetCurrentEscalationMultiplier())");
    
    if system.IsEffectActive() && NotEquals(system.m_currentEffectName, n"") {
        LogChannel(n"DEBUG", s"BlackwallVFX: Current Gun VFX: \(NameToString(system.m_currentEffectName))");
    }
    
    if system.IsQuickhackEffectActive() {
        let cyberdeckEffectName = system.GetCyberdeckVFXName(player);
        LogChannel(n"DEBUG", s"BlackwallVFX: Current Quickhack VFX: \(NameToString(cyberdeckEffectName)) (custom_bright_spots handled in upload/apply phases)");
    }
    
    // === CYBERDECK QUALITY ===
    let cyberdeckVFX = system.GetCyberdeckVFXName(player);
    let cyberdeckLevel = Equals(cyberdeckVFX, n"q305_cerberus_blackwall_glitch_medium") ? "_medium (LegendaryPlus/LegendaryPlusPlus)" : "_low (Other qualities)";
    LogChannel(n"DEBUG", s"BlackwallVFX: Cyberdeck VFX Level: \(cyberdeckLevel)");
    
    // === COOLDOWN STATUS ===
    let mainVFXCD = GameObject.IsCooldownActive(player, n"BlackwallMainVFXCooldown");
    let bonusVFXCD = GameObject.IsCooldownActive(player, n"BlackwallBonusEffectCooldown");
    LogChannel(n"DEBUG", s"BlackwallVFX: Cooldowns - Main VFX: \(mainVFXCD) (1.5s) | Bonus VFX: \(bonusVFXCD) (3.5s)");
    LogChannel(n"DEBUG", s"BlackwallVFX: Active Bonus Effects: \(system.m_activeBonusEffectsCount)/3");
    
    // === QUICK ACTIONS ===
    LogChannel(n"DEBUG", "BlackwallVFX: Quick Actions: MisterChedda_BlackwallVFX_StartTest() | MisterChedda_BlackwallVFX_Stop() | MisterChedda_BlackwallVFX_QuickhackTest()");
    LogChannel(n"DEBUG", "BlackwallVFX: Direct Effects: MisterChedda_BlackwallVFX_TestDirectEffects(1-4) | MisterChedda_BlackwallVFX_ResetScore()");
    LogChannel(n"DEBUG", "BlackwallVFX: ================================================================");
}

// Debug function to test quickhack blackwall effects
public exec func MisterChedda_BlackwallVFX_QuickhackTest() {
    let player = GetPlayer(GetGameInstance());
    if !IsDefined(player) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] Player not found!");
        return;
    }
    
    let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(GetGameInstance());
    if !IsDefined(system) {
        LogChannel(n"DEBUG", "BlackwallVFX: [ERROR] System not found!");
        return;
    }
    
    system.StartQuickhackBlackwallEffect(player);
    LogChannel(n"DEBUG", "BlackwallVFX: [DEBUG] Manually triggered quickhack blackwall effects");
}
