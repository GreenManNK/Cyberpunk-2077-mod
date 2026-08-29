module VehicleMileage.FastTravelRestore 

@wrapMethod(FastTravelSystem)
private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    wrappedMethod(saveVersion, gameVersion);
    // Post your uniquely named request for the next frame:
    GameInstance.GetDelaySystem(this.GetGameInstance())
        .DelayScriptableSystemRequestNextFrame(this.GetClassName(), new VM_RestoreFTMappinsRequest());
}

// Handler name must match the request class name: On<ReqName>
@addMethod(FastTravelSystem)
private final func OnVM_RestoreFTMappinsRequest(request: ref<VM_RestoreFTMappinsRequest>) -> Void {
    this.RestoreFastTravelMappins();
}

// Unique request class so it won't collide with other mods
public class VM_RestoreFTMappinsRequest extends ScriptableSystemRequest {}
