/*
BlackwallSideEffects - Haunted Gun VFX System
Duration-based effect management using Delay system with persistent scoring
Supports mod settings for intensity control
*/

public class BlackwallEffectCallback extends DelayCallback {
    private let m_target: wref<IScriptable>;
    private let m_fn: CName;

    public static func Create(target: wref<IScriptable>, fn: CName) -> ref<BlackwallEffectCallback> {
        let self = new BlackwallEffectCallback();
        self.m_target = target;
        self.m_fn = fn;
        return self;
    }

    public func Call() -> Void {
        if IsDefined(this.m_target) {
            let targetVariant = ToVariant(this.m_target);
            let function = Reflection.GetClassOf(targetVariant).GetFunction(this.m_fn);
            if IsDefined(function) {
                function.Call(this.m_target);
            }
        }
    }
}

public class HauntedGunVFXSystem extends ScriptableSystem {
    private let m_gameInstance: GameInstance;
    private let m_player: wref<PlayerPuppet>;
    
    // Effect tracking
    private let m_isEffectActive: Bool;
    private let m_effectDelayID: DelayID;
    private let m_currentEffectLevel: Int32;
    private let m_currentEffectName: CName;
    
    // Duration ranges based on effect level
    private let m_minDurations: array<Float>;
    private let m_maxDurations: array<Float>;
    
    // Effect tracking counters
    private let m_totalEffectsTriggered: Int32;
    private let m_consecutiveEffects: Int32;
    
    // Persistent scoring system (save-scoped, no decay for performance)
    private persistent let m_hauntedGunScore: Int32;
    private persistent let m_lastUsageTime: Float;
    
    // Escalation thresholds based on score
    private let m_scoreThresholds: array<Int32>;
    private let m_escalationMultipliers: array<Float>;
    
    // Bonus effects cooldown and stacking management
    private let m_bonusEffectCooldownName: CName;
    private let m_bonusEffectCooldownDuration: Float;
    private let m_activeBonusEffectsCount: Int32;
    
    // Main VFX cooldown to prevent rapid-fire overexposure
    private let m_mainVFXCooldownName: CName;
    private let m_mainVFXCooldownDuration: Float;
    
    // Quickhack VFX system (separate from gun system)
    private let m_isQuickhackEffectActive: Bool;
    private let m_quickhackEffectDelayID: DelayID;
    
    @if(ModuleExists("ModSettingsModule"))
    private func OnAttach() -> Void {
        ModSettings.RegisterListenerToClass(this);
        ModSettings.RegisterListenerToModifications(this);
        
        this.m_gameInstance = this.GetGameInstance();
        this.m_isEffectActive = false;
        this.m_effectDelayID = GetInvalidDelayID();
        
        // Initialize quickhack VFX system
        this.m_isQuickhackEffectActive = false;
        this.m_quickhackEffectDelayID = GetInvalidDelayID();

        this.m_currentEffectLevel = 0;
        this.m_totalEffectsTriggered = 0;
        this.m_consecutiveEffects = 0;
        this.m_currentEffectName = n"";
        
        // Initialize score thresholds and escalation multipliers (more aggressive)
        // Score 0-5: Normal behavior
        ArrayPush(this.m_scoreThresholds, 5);
        ArrayPush(this.m_escalationMultipliers, 1.0);
        
        // Score 6-15: Slightly more aggressive
        ArrayPush(this.m_scoreThresholds, 15);
        ArrayPush(this.m_escalationMultipliers, 1.2);
        
        // Score 16-30: Moderately aggressive
        ArrayPush(this.m_scoreThresholds, 30);
        ArrayPush(this.m_escalationMultipliers, 1.5);
        
        // Score 31-60: Very aggressive
        ArrayPush(this.m_scoreThresholds, 60);
        ArrayPush(this.m_escalationMultipliers, 2.0);
        
        // Score 60+: Maximum aggression
        ArrayPush(this.m_scoreThresholds, 999);
        ArrayPush(this.m_escalationMultipliers, 3.0);
        
        // Initialize duration ranges based on effect intensity levels
        // Level 0-4: 10-30 seconds (base)
        ArrayPush(this.m_minDurations, 10.0);
        ArrayPush(this.m_maxDurations, 30.0);
        
        // Level 5-9: 15-45 seconds  
        ArrayPush(this.m_minDurations, 15.0);
        ArrayPush(this.m_maxDurations, 45.0);
        
        // Level 10-19: 20-60 seconds
        ArrayPush(this.m_minDurations, 20.0);
        ArrayPush(this.m_maxDurations, 60.0);
        
        // Level 20+: 30-90 seconds
        ArrayPush(this.m_minDurations, 30.0);
        ArrayPush(this.m_maxDurations, 90.0);
        
        // Initialize bonus effects cooldown system
        this.m_bonusEffectCooldownName = n"BlackwallBonusEffectCooldown";
        this.m_bonusEffectCooldownDuration = 3.5; // 3.5 seconds cooldown
        this.m_activeBonusEffectsCount = 0;
        
        // Initialize main VFX cooldown system (shorter to prevent rapid-fire overexposure)
        this.m_mainVFXCooldownName = n"BlackwallMainVFXCooldown";
        this.m_mainVFXCooldownDuration = 0.9; // 0.8 seconds cooldown
        
        // Log mod settings status
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) {
            let intensityMode = Equals(settings.intensityLevel, BlackwallSideEffects_IntensityLevel.Low) ? "Low" : "Default";
            // FTLog(s"BlackwallVFX: System initialized with persistent score: \(this.m_hauntedGunScore), Intensity Mode: \(intensityMode) ");
        } else {
            // FTLog(s"BlackwallVFX: System initialized with persistent score: \(this.m_hauntedGunScore), Mod Settings: Not Available ");
        }
    }

    @if(ModuleExists("ModSettingsModule"))
    private func OnDetach() -> Void {
        ModSettings.UnregisterListenerToClass(this);
        ModSettings.UnregisterListenerToModifications(this);
    }

    @if(ModuleExists("ModSettingsModule"))
    private func OnModSettingsChange() -> Void {
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) {
            let intensityMode = Equals(settings.intensityLevel, BlackwallSideEffects_IntensityLevel.Low) ? "Low" : "Default";
            // FTLog(s"BlackwallVFX: Settings changed - Enabled: \(settings.enabled), Intensity: \(intensityMode)");
        }
    }

    @if(!ModuleExists("ModSettingsModule"))
    private func OnAttach() -> Void {
        this.m_gameInstance = this.GetGameInstance();
        this.m_isEffectActive = false;
        this.m_effectDelayID = GetInvalidDelayID();
        
        // Initialize quickhack VFX system
        this.m_isQuickhackEffectActive = false;
        this.m_quickhackEffectDelayID = GetInvalidDelayID();

        this.m_currentEffectLevel = 0;
        this.m_totalEffectsTriggered = 0;
        this.m_consecutiveEffects = 0;
        this.m_currentEffectName = n"";
        
        // Initialize score thresholds and escalation multipliers (more aggressive)
        // Score 0-5: Normal behavior
        ArrayPush(this.m_scoreThresholds, 5);
        ArrayPush(this.m_escalationMultipliers, 1.0);
        
        // Score 6-15: Slightly more aggressive
        ArrayPush(this.m_scoreThresholds, 15);
        ArrayPush(this.m_escalationMultipliers, 1.2);
        
        // Score 16-30: Moderately aggressive
        ArrayPush(this.m_scoreThresholds, 30);
        ArrayPush(this.m_escalationMultipliers, 1.5);
        
        // Score 31-60: Very aggressive
        ArrayPush(this.m_scoreThresholds, 60);
        ArrayPush(this.m_escalationMultipliers, 2.0);
        
        // Score 60+: Maximum aggression
        ArrayPush(this.m_scoreThresholds, 999);
        ArrayPush(this.m_escalationMultipliers, 3.0);
        
        // Initialize duration ranges based on effect intensity levels
        // Level 0-4: 10-30 seconds (base)
        ArrayPush(this.m_minDurations, 10.0);
        ArrayPush(this.m_maxDurations, 30.0);
        
        // Level 5-9: 15-45 seconds  
        ArrayPush(this.m_minDurations, 15.0);
        ArrayPush(this.m_maxDurations, 45.0);
        
        // Level 10-19: 20-60 seconds
        ArrayPush(this.m_minDurations, 20.0);
        ArrayPush(this.m_maxDurations, 60.0);
        
        // Level 20+: 30-90 seconds
        ArrayPush(this.m_minDurations, 30.0);
        ArrayPush(this.m_maxDurations, 90.0);
        
        // Initialize bonus effects cooldown system
        this.m_bonusEffectCooldownName = n"BlackwallBonusEffectCooldown";
        this.m_bonusEffectCooldownDuration = 3.5; // 3.5 seconds cooldown
        this.m_activeBonusEffectsCount = 0;
        
        // Initialize main VFX cooldown system (shorter to prevent rapid-fire overexposure)
        this.m_mainVFXCooldownName = n"BlackwallMainVFXCooldown";
        this.m_mainVFXCooldownDuration = 0.8; // 0.8 seconds cooldown
        
        // FTLog(s"BlackwallVFX: System initialized with persistent score: \(this.m_hauntedGunScore), Mod Settings: Not Available (No ModSettings) ");
    }

    @if(!ModuleExists("ModSettingsModule"))
    private func OnDetach() -> Void {}
    
    private func GetCurrentEscalationMultiplier() -> Float {
        let i = 0;
        while i < ArraySize(this.m_scoreThresholds) {
            if this.m_hauntedGunScore <= this.m_scoreThresholds[i] {
                return this.m_escalationMultipliers[i];
            }
            i += 1;
        }
        return this.m_escalationMultipliers[ArraySize(this.m_escalationMultipliers) - 1];
    }
    
    private func GetVFXEffectForLevel(level: Int32) -> CName {
        // Get adjusted thresholds based on mod settings
        let lowToMediumThreshold: Int32;
        let mediumToHeavyThreshold: Int32;
        
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) && Equals(settings.intensityLevel, BlackwallSideEffects_IntensityLevel.Low) {
            // Low mode: Make heavy VFX much harder to trigger
            lowToMediumThreshold = 5;   // Low: 0-2, Medium: 5-9, Heavy: 10+
            mediumToHeavyThreshold = 10;
        } else {
            // Default mode: Original thresholds
            lowToMediumThreshold = 2;   // Low: 0-1, Medium: 2-5, Heavy: 6+
            mediumToHeavyThreshold = 6;
        }
        
        if level < lowToMediumThreshold {
            return n"q305_cerberus_blackwall_glitch_low";
        } else if level < mediumToHeavyThreshold {
            return n"q305_cerberus_blackwall_glitch_medium";
        } else {
            return n"q305_cerberus_blackwall_glitch_heavy";
        }
    }
    
    private func GetDurationForLevel(level: Int32) -> Float {
        let rangeIndex: Int32;
        
        if level < 5 {
            rangeIndex = 0;
        } else if level < 10 {
            rangeIndex = 1;
        } else if level < 20 {
            rangeIndex = 2;
        } else {
            rangeIndex = 3;
        }
        
        let baseDuration = RandRangeF(this.m_minDurations[rangeIndex], this.m_maxDurations[rangeIndex]);
        let escalationMultiplier = this.GetCurrentEscalationMultiplier();
        
        // Higher score = longer durations and higher minimum thresholds
        let calculatedDuration = baseDuration * escalationMultiplier;
        
        // Apply max duration setting
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) {
            calculatedDuration = MinF(calculatedDuration, settings.maxVFXDuration);
        }
        
        return calculatedDuration;
    }
    
    private func IncrementHauntedGunScore(amount: Int32) -> Void {
        let oldScore = this.m_hauntedGunScore;
        this.m_hauntedGunScore += amount;
        
        // Update recent usage timestamp (persistent variable)
        this.m_lastUsageTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.m_gameInstance));
        
        // FTLog(s"BlackwallVFX: [DEBUG] Score: \(oldScore) + \(amount) = \(this.m_hauntedGunScore) (multiplier: \(this.GetCurrentEscalationMultiplier())) [Persistent, no decay]");
    }
    
    // Debug methods for score manipulation
    public func SetScore(score: Int32) -> Void {
        let oldScore = this.m_hauntedGunScore;
        this.m_hauntedGunScore = Max(0, score);
        this.m_lastUsageTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.m_gameInstance));
        // FTLog(s"BlackwallVFX: [DEBUG] Score manually set: \(oldScore) -> \(this.m_hauntedGunScore)");
    }
    
    public func ResetScore() -> Void {
        this.m_hauntedGunScore = 0;
        this.m_lastUsageTime = 0.0;
        // FTLog("BlackwallVFX: [DEBUG] Score and usage time reset to 0");
    }
    

    
    private func ShouldEscalateExistingEffect(newIntensity: Int32) -> Bool {
        // Calculate what the new escalated intensity would be
        let escalationMultiplier = this.GetCurrentEscalationMultiplier();
        let escalatedIntensity = newIntensity;
        let escalationBonus = 0;
        
        if escalationMultiplier > 1.5 {
            escalationBonus = RandRange(1, 3);
        } else if escalationMultiplier > 1.2 {
            escalationBonus = RandRange(1, 2); // Always at least +1 for moderate scores
        } else if escalationMultiplier > 1.0 {
            escalationBonus = RandRange(0, 1); // Small chance for low scores
        }
        
        escalatedIntensity = newIntensity + escalationBonus;
        
        // More lenient escalation logic
        let currentVFXTier = this.GetVFXTierForLevel(this.m_currentEffectLevel);
        let newVFXTier = this.GetVFXTierForLevel(escalatedIntensity);
        
        // Escalate if: intensity increase OR VFX tier increase OR random chance based on multiplier
        let randomChance = RandRange(0, 100);
        let escalateChance = Cast<Int32>((escalationMultiplier - 1.0) * 100.0); // 0% at 1.0x, 20% at 1.2x, etc.
        
        return escalatedIntensity > this.m_currentEffectLevel || newVFXTier > currentVFXTier || randomChance < escalateChance;
    }
    
    private func GetVFXTierForLevel(level: Int32) -> Int32 {
        // Get adjusted thresholds based on mod settings (same as GetVFXEffectForLevel)
        let lowToMediumThreshold: Int32;
        let mediumToHeavyThreshold: Int32;
        
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) && Equals(settings.intensityLevel, BlackwallSideEffects_IntensityLevel.Low) {
            // Low mode: Make heavy VFX much harder to trigger
            lowToMediumThreshold = 5;   // Low: 0-2, Medium: 5-9, Heavy: 10+
            mediumToHeavyThreshold = 10;
        } else {
            // Default mode: Original thresholds
            lowToMediumThreshold = 2;   // Low: 0-1, Medium: 2-5, Heavy: 6+
            mediumToHeavyThreshold = 6;
        }
        
        if level < lowToMediumThreshold {
            return 0; // Low
        } else if level < mediumToHeavyThreshold {
            return 1; // Medium
        } else {
            return 2; // Heavy
        }
    }
    
    private func TriggerRandomBonusEffects(player: wref<PlayerPuppet>, intensity: Int32) -> Void {
        // Check cooldown before triggering any bonus effects
        if GameObject.IsCooldownActive(player, this.m_bonusEffectCooldownName) {
            // FTLog("BlackwallVFX: Bonus effects on cooldown, skipping");
            return;
        }
        
        let vfxTier = this.GetVFXTierForLevel(intensity);
        let roll = RandRange(0, 100);
        let bonusEffectTriggered = false;
        
        // Get adjusted chances based on mod settings
        let lowVFXChance: Int32;
        let mediumVFXChance: Int32;
        let heavyVFXChance: Int32;
        
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) && Equals(settings.intensityLevel, BlackwallSideEffects_IntensityLevel.Low) {
            // Low mode: Drastically reduced bonus effect chances
            lowVFXChance = 2;     // 2% chance (was 10%)
            mediumVFXChance = 5;  // 5% chance (was 25%)
            heavyVFXChance = 3;   // 3% chance (was 15%)
        } else {
            // Default mode: Original chances
            lowVFXChance = 10;    // 10% chance
            mediumVFXChance = 20; // 20% chance
            heavyVFXChance = 15;  // 15% chance
        }
        
        // Effect 1: Blackwall onscreen warp flash (low/medium levels) - NO STACKING
        if vfxTier == 0 { // Low VFX
            if roll < lowVFXChance {
                GameObjectEffectHelper.StartEffectEvent(player, n"custom_warp_low", false);
                this.m_activeBonusEffectsCount = 1; // Reset count for low/medium (no stacking)
                bonusEffectTriggered = true;
                // FTLog(s"BlackwallVFX: Triggered bonus warp flash effect (low, \(lowVFXChance)% chance, no stacking)");
            }
        } else if vfxTier == 1 { // Medium VFX
            if roll < mediumVFXChance {
                GameObjectEffectHelper.StartEffectEvent(player, n"custom_warp_low", false);
                this.m_activeBonusEffectsCount = 1; // Reset count for low/medium (no stacking)
                bonusEffectTriggered = true;
                // FTLog(s"BlackwallVFX: Triggered bonus warp flash effect (medium, \(mediumVFXChance)% chance, no stacking)");
            }
        }
        
        // Effect 2: Blackwall onscreen high short (heavy level only) - STACKING ALLOWED UP TO 3
        if vfxTier == 2 { // Heavy VFX
            let roll2 = RandRange(0, 100);
            if roll2 < heavyVFXChance {
                // Check stacking limit for Heavy VFX
                if this.m_activeBonusEffectsCount < 3 {
                    GameObjectEffectHelper.StartEffectEvent(player, n"custom_high_short", false);
                    this.m_activeBonusEffectsCount += 1; // Increment for stacking
                    bonusEffectTriggered = true;
                    // FTLog(s"BlackwallVFX: Triggered bonus high intensity effect (heavy, \(heavyVFXChance)% chance, stack \(this.m_activeBonusEffectsCount)/3)");
                } else {
                    // FTLog("BlackwallVFX: Heavy bonus effect at max stacking limit (3), skipping");
                }
            }
        }
        
        // Start cooldown if any bonus effect was triggered
        if bonusEffectTriggered {
            GameObject.StartCooldown(player, this.m_bonusEffectCooldownName, this.m_bonusEffectCooldownDuration);
            // FTLog(s"BlackwallVFX: Started bonus effect cooldown (\(this.m_bonusEffectCooldownDuration)s)");
        }
    }
    

    
    private func CleanupBonusEffects(player: wref<PlayerPuppet>) -> Void {
        // Reset bonus effects counter when cleaning up
        this.m_activeBonusEffectsCount = 0;
        // FTLog("BlackwallVFX: Reset bonus effects counter to 0");
    }
    
    public func StartBlackwallEffect(player: wref<PlayerPuppet>, intensity: Int32) -> Void {
        // Check if mod is enabled
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) && !settings.enabled {
            // FTLog("BlackwallVFX: Mod disabled in settings, skipping effect");
            return;
        }
        
        // Check main VFX cooldown to prevent rapid-fire overexposure
        if GameObject.IsCooldownActive(player, this.m_mainVFXCooldownName) {
            // FTLog("BlackwallVFX: Main VFX on cooldown, preventing rapid-fire overexposure");
            return;
        }
        
        if this.m_isEffectActive {
            // If effect is already active, decide whether to extend or escalate
            let shouldEscalate = this.ShouldEscalateExistingEffect(intensity);
            if shouldEscalate {
                // Stop current effect and restart with new intensity (prevents stacking)
                this.StopBlackwallEffect();
                // FTLog("BlackwallVFX: Escalating - stopped current effect, restarting...");
                this.StartBlackwallEffect(player, intensity); // Recursive call after stop
                return; // Exit current call to prevent double execution
            } else {
                // Just extend current effect duration but still increment score
                this.ExtendCurrentEffect(10.0); // Add 10 seconds
                
                // Still increment score even on extensions (reduced amount)
                let scoreIncrease = 1; // Flat 1 point for extensions
                this.IncrementHauntedGunScore(scoreIncrease);
                
                // FTLog(s"BlackwallVFX: Extended existing effect instead of stacking (current level: \(this.m_currentEffectLevel))");
                return;
            }
        }
        
        this.m_player = player;
        
        // Increment haunted gun usage score
        let scoreIncrease = 1 + (intensity / 5); // Higher intensity = more score
        this.IncrementHauntedGunScore(scoreIncrease);
        
        // Apply score-based intensity escalation
        let escalatedIntensity = intensity;
        let escalationMultiplier = this.GetCurrentEscalationMultiplier();
        let escalationBonus = 0;
        
        if escalationMultiplier > 1.5 {
            escalationBonus = RandRange(1, 3); // Random escalation for high scores
        } else if escalationMultiplier > 1.2 {
            escalationBonus = RandRange(1, 2); // Always at least +1 for moderate scores
        } else if escalationMultiplier > 1.0 {
            escalationBonus = RandRange(0, 1); // Small chance for low scores
        }
        
        escalatedIntensity = intensity + escalationBonus;
        
        // FTLog(s"BlackwallVFX: [DEBUG] Escalation: base \(intensity) + bonus \(escalationBonus) = \(escalatedIntensity) (multiplier \(escalationMultiplier))");
        
        this.m_currentEffectLevel = escalatedIntensity;
        this.m_isEffectActive = true;
        this.m_totalEffectsTriggered += 1;
        this.m_consecutiveEffects += 1;
        
        // Start the appropriate VFX effect based on intensity
        this.m_currentEffectName = this.GetVFXEffectForLevel(escalatedIntensity);
        GameObjectEffectHelper.StartEffectEvent(player, this.m_currentEffectName, true);
        
        // Start main VFX cooldown to prevent rapid-fire overexposure
        GameObject.StartCooldown(player, this.m_mainVFXCooldownName, this.m_mainVFXCooldownDuration);
        
        // Trigger random bonus VFX effects based on intensity level
        this.TriggerRandomBonusEffects(player, escalatedIntensity);
        
        // Calculate duration based on escalated intensity level
        let duration = this.GetDurationForLevel(escalatedIntensity);
        
        // Schedule the stop callback
        let delaySystem = GameInstance.GetDelaySystem(this.m_gameInstance);
        let callback = BlackwallEffectCallback.Create(this, n"OnEffectDurationExpired");
        this.m_effectDelayID = delaySystem.DelayCallback(callback, duration);
        
        // FTLog(s"BlackwallVFX: Started effect - Level: \(intensity)->\(escalatedIntensity), VFX: \(NameToString(this.m_currentEffectName)), Duration: \(duration)s, Score: \(this.m_hauntedGunScore), Multiplier: \(escalationMultiplier), MainCooldown: \(this.m_mainVFXCooldownDuration)s");
    }
    
    private cb func OnEffectDurationExpired() -> Void {
        // FTLog(s"BlackwallVFX: Effect duration expired for level \(this.m_currentEffectLevel)");
        this.StopBlackwallEffect();
    }
    
    public func StopBlackwallEffect() -> Void {
        if !this.m_isEffectActive {
            return;
        }
        
        // Cancel the duration timer
        if GetInvalidDelayID() != this.m_effectDelayID {
            let delaySystem = GameInstance.GetDelaySystem(this.m_gameInstance);
            delaySystem.CancelCallback(this.m_effectDelayID);
            this.m_effectDelayID = GetInvalidDelayID();
        }
        
        // Stop the current VFX effect
        if IsDefined(this.m_player) && NotEquals(this.m_currentEffectName, n"") {
            let breakEvent: ref<entBreakEffectLoopEvent> = new entBreakEffectLoopEvent();
            breakEvent.effectName = this.m_currentEffectName;
            this.m_player.QueueEvent(breakEvent);
            
            // Clean up any bonus effect components
            this.CleanupBonusEffects(this.m_player);
        }
        
        // Reset state
        this.m_isEffectActive = false;
        this.m_currentEffectLevel = 0;
        this.m_consecutiveEffects = 0;
        this.m_currentEffectName = n"";
        
        // FTLog("BlackwallVFX: Stopped Blackwall effect");
    }
    
    public func IsEffectActive() -> Bool {
        return this.m_isEffectActive;
    }
    
    public func GetCurrentEffectLevel() -> Int32 {
        return this.m_currentEffectLevel;
    }
    
    public func GetTotalEffectsTriggered() -> Int32 {
        return this.m_totalEffectsTriggered;
    }
    
    public func IsQuickhackEffectActive() -> Bool {
        return this.m_isQuickhackEffectActive;
    }
    
    public func StartQuickhackBlackwallEffect(player: wref<PlayerPuppet>) -> Void {
        // Check if mod is enabled
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) && !settings.enabled {
            // FTLog("BlackwallVFX: Mod disabled in settings, skipping quickhack effect");
            return;
        }
        
        // Don't apply if gun blackwall VFX is already active
        if this.m_isEffectActive {
            // FTLog("BlackwallVFX: Gun blackwall VFX already active, skipping quickhack effect");
            return;
        }
        
        // Don't stack quickhack effects
        if this.m_isQuickhackEffectActive {
            // FTLog("BlackwallVFX: Quickhack blackwall VFX already active, skipping");
            return;
        }
        
        this.m_player = player;
        this.m_isQuickhackEffectActive = true;
        
        // Get cyberdeck quality to determine VFX intensity
        let cyberdeckEffectName = this.GetCyberdeckVFXName(player);
        
        // Start main VFX (scaled by cyberdeck quality, custom_bright_spots handled separately in upload/apply phases)
        GameObjectEffectHelper.StartEffectEvent(player, cyberdeckEffectName, true);
        // FTLog(s"BlackwallVFX: Started quickhack main effect: \(NameToString(cyberdeckEffectName))");
        
        // 50% chance to trigger bonus effect (non-looping)
        let roll = RandRange(0, 100);
        if roll < 50 {
            GameObjectEffectHelper.StartEffectEvent(player, n"q304_blackwall_onscreen_lab_delicate_single_02", false);
            // FTLog("BlackwallVFX: Triggered quickhack bonus effect (50% chance)");
        }
        
        // Set duration (longer than gun effects - cyberdeck is direct neural interface)
        let duration = RandRangeF(90.0, 270.0);
        
        // Apply max duration setting
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) {
            duration = MinF(duration, settings.maxVFXDuration);
        }
        
        // Schedule the stop callback
        let delaySystem = GameInstance.GetDelaySystem(this.m_gameInstance);
        let callback = BlackwallEffectCallback.Create(this, n"OnQuickhackEffectDurationExpired");
        this.m_quickhackEffectDelayID = delaySystem.DelayCallback(callback, duration);
        
        // FTLog(s"BlackwallVFX: Started quickhack blackwall effects - Duration: \(duration)s");
    }
    
    private cb func OnQuickhackEffectDurationExpired() -> Void {
        // FTLog("BlackwallVFX: Quickhack effect duration expired");
        this.StopQuickhackBlackwallEffect();
    }
    

    


    public func StopQuickhackBlackwallEffect() -> Void {
        if !this.m_isQuickhackEffectActive {
            return;
        }
        
        // Cancel the duration timer
        if GetInvalidDelayID() != this.m_quickhackEffectDelayID {
            let delaySystem = GameInstance.GetDelaySystem(this.m_gameInstance);
            delaySystem.CancelCallback(this.m_quickhackEffectDelayID);
            this.m_quickhackEffectDelayID = GetInvalidDelayID();
        }
        
        // Stop the VFX effect (determine which one based on cyberdeck quality, custom_bright_spots is handled separately in upload/apply phases)
        if IsDefined(this.m_player) {
            let cyberdeckEffectName = this.GetCyberdeckVFXName(this.m_player);
            let breakEvent: ref<entBreakEffectLoopEvent> = new entBreakEffectLoopEvent();
            breakEvent.effectName = cyberdeckEffectName;
            this.m_player.QueueEvent(breakEvent);
            // FTLog(s"BlackwallVFX: Stopped quickhack effect: \(NameToString(cyberdeckEffectName))");
        }
        
        // Reset state
        this.m_isQuickhackEffectActive = false;
        
        // FTLog("BlackwallVFX: Stopped quickhack blackwall effects");
    }
    
    // Get cyberdeck VFX name based on cyberdeck quality
    public func GetCyberdeckVFXName(player: wref<PlayerPuppet>) -> CName {
        // Get cyberdeck ItemID
        let systemReplacementID: ItemID = EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
        
        if ItemID.IsValid(systemReplacementID) {
            let itemRecord: wref<Item_Record> = RPGManager.GetItemRecord(systemReplacementID);
            if IsDefined(itemRecord) {
                let qualityRecord: wref<Quality_Record> = itemRecord.Quality();
                if IsDefined(qualityRecord) {
                    let quality = qualityRecord.Type();
                    
                    // LegendaryPlus (6) and LegendaryPlusPlus (7) use _medium, rest use _low
                    if Equals(quality, gamedataQuality.LegendaryPlus) || Equals(quality, gamedataQuality.LegendaryPlusPlus) {
                        // FTLog("BlackwallVFX: [CYBERDECK] Quality: LegendaryPlus/LegendaryPlusPlus -> Using _medium VFX");
                        return n"q305_cerberus_blackwall_glitch_medium";
                    } else {
                        // FTLog(s"BlackwallVFX: [CYBERDECK] Quality: Other -> Using _low VFX ===> \(quality)");
                        return n"q305_cerberus_blackwall_glitch_low";
                    }
                } else {
                        // FTLog("BlackwallVFX: [CYBERDECK] item quality not defined");

                }
            } else {
                            // FTLog("BlackwallVFX: [CYBERDECK] item not defined");

            }
        } else {
            // FTLog("BlackwallVFX: [CYBERDECK] No cyberdeck equipped, using _low VFX fallback");
        }
        
        // Fallback to _low if we can't determine quality
        // FTLog("BlackwallVFX: [CYBERDECK] Could not determine quality, using _low VFX fallback");
        return n"q305_cerberus_blackwall_glitch_low";
    }
    
    public func GetConsecutiveEffects() -> Int32 {
        return this.m_consecutiveEffects;
    }
    
    public func GetHauntedGunScore() -> Int32 {
        return this.m_hauntedGunScore;
    }
    
    public func GetEscalationMultiplier() -> Float {
        return this.GetCurrentEscalationMultiplier();
    }
    
    public func GetCurrentEffectName() -> CName {
        return this.m_currentEffectName;
    }
    
    // Method to extend current effect duration (if needed)
    public func ExtendCurrentEffect(additionalTime: Float) -> Void {
        if !this.m_isEffectActive {
            return;
        }
        
        // Apply max duration setting to extension time
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(this.m_gameInstance);
        if IsDefined(settings) {
            additionalTime = MinF(additionalTime, settings.maxVFXDuration);
        }
        
        // Cancel current timer
        let delaySystem = GameInstance.GetDelaySystem(this.m_gameInstance);
        if GetInvalidDelayID() != this.m_effectDelayID {
            delaySystem.CancelCallback(this.m_effectDelayID);
        }
        
        // Schedule new timer with extended duration
        let callback = BlackwallEffectCallback.Create(this, n"OnEffectDurationExpired");
        this.m_effectDelayID = delaySystem.DelayCallback(callback, additionalTime);
        
        // FTLog(s"BlackwallVFX: Extended effect duration by \(additionalTime)s");
    }
    
    // Method to manually trigger effect escalation
    public func EscalateEffect() -> Void {
        if !this.m_isEffectActive {
            return;
        }
        
        let newLevel = this.m_currentEffectLevel + 1;
        let newDuration = this.GetDurationForLevel(newLevel);
        
        // Update level and restart with new duration
        this.StartBlackwallEffect(this.m_player, newLevel);
        
        // FTLog(s"BlackwallVFX: Escalated effect from level \(this.m_currentEffectLevel) to \(newLevel)");
    }

    public static func GetHauntedGunVFXSystem(gameInstance: GameInstance) -> ref<HauntedGunVFXSystem> {
        return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"HauntedGunVFXSystem") as HauntedGunVFXSystem;
    }

    // Calculate base intensity from weapon tier  
    public static func CalculateIntensityFromTier(itemData: wref<gameItemData>, gameInstance: GameInstance) -> Int32 {
        if !IsDefined(itemData) {
            // FTLog("BlackwallVFX: [DEBUG] ItemData not defined, using fallback intensity 1");
            return 1; // Default fallback
        }

        let statsSystem = GameInstance.GetStatsSystem(gameInstance);
        let statsId = itemData.GetStatsObjectID();

        // Get the base tier (1-5)
        let tier = Cast<Int32>(statsSystem.GetStatValue(statsId, gamedataStatType.EffectiveTier));
        
        // Get the '+' modifier (0 for none, 1 for '+', 2 for '++')
        let plusValue = Cast<Int32>(statsSystem.GetStatValue(statsId, gamedataStatType.IsItemPlus));

        // FTLog(s"BlackwallVFX: [DEBUG] Raw tier: \(tier), plus: \(plusValue)");

        // Base intensity mapping using raw tier values:
        // Tier 0 (display Tier 1) = intensity 1
        // Tier 1-2 (display Tier 1+/2) = intensity 2
        // Tier 3-4 (display Tier 2+/3) = intensity 3  
        // Tier 5-6 (display Tier 3+/4) = intensity 4
        // Tier 7-8 (display Tier 4+/5) = intensity 5
        // Tier 9-10 (display Tier 5+/5++) = intensity 6
        let baseIntensity: Int32;
        if tier <= 0 {
            baseIntensity = 1; // Tier 1
        } else if tier <= 2 {
            baseIntensity = 2; // Tier 1+ to 2
        } else if tier <= 4 {
            baseIntensity = 3; // Tier 2+ to 3
        } else if tier <= 6 {
            baseIntensity = 4; // Tier 3+ to 4
        } else if tier <= 8 {
            baseIntensity = 5; // Tier 4+ to 5
        } else {
            baseIntensity = 6; // Tier 5+ to 5++
        }
        
        // Add bonus for plus modifiers: + adds 1, ++ adds 2
        baseIntensity += plusValue;
        
        // Ensure intensity stays within reasonable bounds
        baseIntensity = Max(1, Min(baseIntensity, 15));
        
        // FTLog(s"BlackwallVFX: [DEBUG] Final calculated intensity: \(baseIntensity) (raw tier \(tier) + plus \(plusValue))");
        
        return baseIntensity;
    }

}
