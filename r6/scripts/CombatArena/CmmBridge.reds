// =====================================================================
//  COMBAT ARENA - Custom Map Markers integration
//
//  When DJ_Kovrik's Custom Map Markers is installed, the entrance pins
//  are registered through IT: named "Combat Arena Entrance", visible on
//  both the world map and minimap, colored per the user's CMM settings
//  (red available there). Without CMM, the mod falls back to its own
//  plain service pins - so CMM is an OPTIONAL requirement.
//
//  The @if blocks compile against CMM only when it is present, so this
//  file is safe to ship either way.
// =====================================================================

@if(ModuleExists("CustomMarkers.System"))
import CustomMarkers.System.*

@if(ModuleExists("CustomMarkers.System"))
public func CombatArenaCmmAvailable() -> Bool {
  return true;
}

@if(!ModuleExists("CustomMarkers.System"))
public func CombatArenaCmmAvailable() -> Bool {
  return false;
}

@if(ModuleExists("CustomMarkers.System"))
public func CombatArenaRegisterCmmMarkers(entries: array<Vector4>) -> Void {
  let sys = GameInstance.GetScriptableSystemsContainer(GetGameInstance())
    .Get(n"CustomMarkers.System.CustomMarkerSystem") as CustomMarkerSystem;
  if !IsDefined(sys) {
    ModLog(n"CombatArena", "CMM module present but system not found");
    return;
  };
  let i = 0;
  while i < ArraySize(entries) {
    // persist=false: re-registered on every session boot, never written
    // into CMM's own storage. isExternal=true: marked as mod-shipped.
    sys.AddCustomMappin("Combat Arena Entrance",
      "Enter the combat arena.",
      n"Solo", entries[i], false, true);
    i += 1;
  };
  ModLog(n"CombatArena", "entrances registered via Custom Map Markers");
}

@if(!ModuleExists("CustomMarkers.System"))
public func CombatArenaRegisterCmmMarkers(entries: array<Vector4>) -> Void {
  // CMM not installed - the caller uses the built-in pins instead.
}
