module VehicleMileage.FastTravelRestore 

@wrapMethod(FastTravelSystem)
private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
    wrappedMethod(saveVersion, gameVersion);
    // Post the request only when the runtime delay service is available.
    let delaySystem = GameInstance.GetDelaySystem(this.GetGameInstance());
    if IsDefined(delaySystem) {
        delaySystem.DelayScriptableSystemRequestNextFrame(
            this.GetClassName(),
            new VM_RestoreFTMappinsRequest()
        );
    };
}

// Handler name must match the request class name: On<ReqName>
@addMethod(FastTravelSystem)
private final func OnVM_RestoreFTMappinsRequest(request: ref<VM_RestoreFTMappinsRequest>) -> Void {
    this.RestoreFastTravelMappins();
}

// Unique request class so it won't collide with other mods
public class VM_RestoreFTMappinsRequest extends ScriptableSystemRequest {}
