native func Log(const text: script_ref<String>) -> Void
native func LogWarning(const text: script_ref<String>) -> Void
native func LogError(const text: script_ref<String>) -> Void

native func LogChannel(channel: CName, const text: script_ref<String>)
native func LogChannelWarning(channel: CName, const text: script_ref<String>) -> Void
native func LogChannelError(channel: CName, const text: script_ref<String>) -> Void

native func FTLog(const value: script_ref<String>) -> Void
native func FTLogWarning(const value: script_ref<String>) -> Void
native func FTLogError(const value: script_ref<String>) -> Void

native func Trace() -> Void
native func TraceToString() -> String

private func IsDelamainVehicle(recordID: TweakDBID) -> Bool {
    return Equals(recordID, t"Vehicle.v_delamain_taxi");
}

@wrapMethod(VehiclesManagerDataView)
public func SortItem(lhs: ref<IScriptable>, rhs: ref<IScriptable>) -> Bool {
    let a: ref<VehicleListItemData> = lhs as VehicleListItemData;
    let b: ref<VehicleListItemData> = rhs as VehicleListItemData;

    let isDelA: Bool = IsDelamainVehicle(a.m_data.recordID);
    let isDelB: Bool = IsDelamainVehicle(b.m_data.recordID);
    if !Equals(isDelA, isDelB) {
        return isDelA;
    }

    let pa: Int32 = a.m_data.uiFavoriteIndex == -1 ? 1 : 0;
    let pb: Int32 = b.m_data.uiFavoriteIndex == -1 ? 1 : 0;
    if pa != pb {
        return pa < pb;
    }

    return UnicodeStringLessThan(
        GetLocalizedTextByKey(a.m_displayName),
        GetLocalizedTextByKey(b.m_displayName)
    );
}