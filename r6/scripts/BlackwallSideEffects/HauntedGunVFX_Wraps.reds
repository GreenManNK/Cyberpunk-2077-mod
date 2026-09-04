

// ===== WRAPS  =====
// Wrapper method that triggers when player shoots with a haunted gun
@wrapMethod(ShootEvents)
protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let player = scriptInterface.executionOwner as PlayerPuppet;
    let weapon = scriptInterface.owner as WeaponObject;

    if IsDefined(player) && IsDefined(weapon) {
        if weapon.WeaponHasTag(n"Haunted_Gun") {
            let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(player.GetGame());
            if IsDefined(system) {
                // Get weapon tier and plus modifier for base intensity calculation
                let weaponItemData = weapon.GetItemData();
                let baseIntensity = HauntedGunVFXSystem.CalculateIntensityFromTier(weaponItemData, player.GetGame());
                
                // Get tier info for logging
                let statsSystem = GameInstance.GetStatsSystem(player.GetGame());
                let statsId = weaponItemData.GetStatsObjectID();
                let tier = Cast<Int32>(statsSystem.GetStatValue(statsId, gamedataStatType.EffectiveTier));
                let plusValue = Cast<Int32>(statsSystem.GetStatValue(statsId, gamedataStatType.IsItemPlus));
                let tierString = "Tier " + IntToString(tier) + (plusValue == 1 ? "+" : (plusValue == 2 ? "++" : ""));
                
                // Start the haunted gun effect (system will handle score-based escalation)
                system.StartBlackwallEffect(player, baseIntensity);
                
                // FTLog(s"BlackwallVFX: Haunted gun fired! \(tierString) → Base intensity: \(baseIntensity)");
            } else {
                // FTLog("BlackwallVFX: [ERROR] System not found when haunted gun fired!");
            }
        }
    }

    wrappedMethod(stateContext, scriptInterface);
}

// Quickhack upload finished / status starts
@wrapMethod(ScriptedPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let gplTags = evt.staticData.GameplayTags();
    if ArrayContains(gplTags, n"Quickhack") && ArrayContains(gplTags, n"BlackWallHack") {
        // Check if mod is enabled
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(GetGameInstance());
        if IsDefined(settings) && !settings.enabled {
            // FTLog("BlackwallVFX: Mod disabled in settings, skipping apply phase effects");
        } else {
            let player = GetPlayer(GetGameInstance());
            if IsDefined(player) {
                // Stop the upload phase bright spots effect
                let breakAnalogEvent: ref<entBreakEffectLoopEvent> = new entBreakEffectLoopEvent();
                breakAnalogEvent.effectName = n"custom_bright_spots";
                player.QueueEvent(breakAnalogEvent);
                // FTLog("BlackwallVFX: [APPLY] Stopped custom_bright_spots (upload phase ended)");
                
                let system = HauntedGunVFXSystem.GetHauntedGunVFXSystem(player.GetGame());
                if IsDefined(system) {
                    system.StartQuickhackBlackwallEffect(player);
                    // FTLog(s"BlackwallVFX: Blackwall quickhack applied! Tags: \(gplTags)");
                }
            }
        }
    }
    wrappedMethod(evt);
}

// Quickhack upload started
@wrapMethod(SpreadInitEffector)
protected func ActionOn(owner: ref<GameObject>) -> Void {
    let actionName: String;
    actionName = NameToString(this.m_objectActionRecord.ActionName());

    if StrContains(actionName, "BlackWall") {
        // Check if mod is enabled
        let settings: ref<BlackwallSideEffectsModSettings> = BlackwallSideEffectsModSettings.Get(GetGameInstance());
        if IsDefined(settings) && !settings.enabled {
            // FTLog("BlackwallVFX: Mod disabled in settings, skipping upload phase effect");
        } else {
            let player = GetPlayer(GetGameInstance());
            if IsDefined(player) {
                // Start the bright spots effect during upload phase
                GameObjectEffectHelper.StartEffectEvent(player, n"custom_bright_spots", true);
                // FTLog("BlackwallVFX: [UPLOAD] Started custom_bright_spots during BlackWall quickhack upload");
            }
        }
    }

    wrappedMethod(owner);
}