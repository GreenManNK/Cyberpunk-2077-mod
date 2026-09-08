// -----------------------------------------------------------------------------
// NCFLogging
// -----------------------------------------------------------------------------
//
// - Logging for Night City Finance.
// - Redscript has no release-mode logging API; the convention is to stub
//   logs in shipped builds. Uncomment FTLog calls below for debug builds.
//

module NightCityFinance.Logging

public enum NCFLogLevel {
    Info = 0,
    Warning = 1,
    Error = 2
}

// All logging is no-op in release. Uncomment the FTLog line for debug.
public func NCFLog(system: ref<IScriptable>, message: String, opt level: NCFLogLevel) -> Void {
    // Uncomment for debug:
    // FTLog("[NCFinance] " + NameToString(system.GetClassName()) + ": " + message);
}

public func NCFLogNoSystem(message: String, opt level: NCFLogLevel) -> Void {
    // v1.0.7: temporarily activated to diagnose the Premium amenities reminder
    // popup bug. FTLog lands in red4ext.log and CET scripting.log. Re-stub
    // to // before release once the bug is identified.
    FTLog("[NCFinance] " + message);
}
