module NightlyNow.Utils

// -----------------------------------------------------------------------------
// TimeUtils - NightlyNow Core
// -----------------------------------------------------------------------------
// Skip time with a 1s glitch effect
public func SkipTime(seconds: Int32) {
    let player = GetPlayer(GetGameInstance());
    let timeSystem = GameInstance.GetTimeSystem(GetGameInstance());

    // Play time skip glitch effect for 1 second
    GameObjectEffectHelper.StartEffectEvent(player, n"time_skip_glitch", false);
    let stopGlitchCallback = new StopGlitchCallback();
    stopGlitchCallback.player = player;
    GameInstance
        .GetDelaySystem(GetGameInstance())
        .DelayCallback(stopGlitchCallback, 1.0, false);

    if seconds <= 0 {
        // No skip time requested
        return;
    }

    // Advance game time
    let currentTime = timeSystem.GetGameTimeStamp();
    timeSystem.SetGameTimeBySeconds(Cast<Int32>(currentTime) + seconds);

    // Sync NPC schedules and world state after time jump
    GameTimeUtils.FastForwardPlayerState(player);
}

// Returns true if current ingame time is between 22:00 and 05:00
public func IsNight() -> Bool {
    let hour = GameInstance
        .GetTimeSystem(GetGameInstance())
        .GetGameTime()
        .Hours();
    return hour >= 22 || hour < 5;
}

// Stops the glitch effect after a delay
private class StopGlitchCallback extends DelayCallback {
    public let player: wref<GameObject>;

    public func Call() {
        if IsDefined(this.player) {
            GameObjectEffectHelper.StopEffectEvent(this.player, n"time_skip_glitch");
        }
    }
}

