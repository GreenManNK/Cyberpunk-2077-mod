module NightCityAllies.Npc.Hooks

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Persistence.*

@wrapMethod(PlayerDevelopmentData)
public final const func AddExperience(amount: Int32, type: gamedataProficiencyType, telemetryGainReason: telemetryLevelGainReason, opt isDebug: Bool) -> Void {
    if amount > 0 && Equals(type, gamedataProficiencyType.Level) && NCA.Context().isInCombat {
        NCA.Damage().RecordPlayerExp(amount);
    }

    wrappedMethod(amount, type, telemetryGainReason, isDebug);
}
