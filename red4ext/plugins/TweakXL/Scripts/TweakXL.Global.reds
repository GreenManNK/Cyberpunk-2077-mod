// TweakXL 1.11.3

public abstract native class ScriptableTweak {
    protected cb func OnApply() -> Void
}

@wrapMethod(StealthMappinController)
private final func UpdateStatusEffectIcon() {
    wrappedMethod();
    if this.m_statusEffectShowing {
        let iconRecord = TweakDBInterface.GetUIIconRecord(TDBID.Create("UIIcon." + this.m_mappin.GetStatusEffectIconPath()));
        if IsDefined(iconRecord) {
            inkImageRef.SetTexturePart(this.m_statusEffectIcon, iconRecord.AtlasPartName());
            inkImageRef.SetAtlasResource(this.m_statusEffectIcon, iconRecord.AtlasResourcePath());
        } else {
            inkImageRef.SetAtlasResource(this.m_statusEffectIcon, r"base/gameplay/gui/widgets/healthbar/atlas_buffinfo.inkatlas");
        }
    }
}

public native class TweakDBBatch {
    public native func SetFlat(id: TweakDBID, value: Variant) -> Bool
    public native func CreateRecord(id: TweakDBID, type: CName) -> Bool
    public native func CloneRecord(id: TweakDBID, base: TweakDBID) -> Bool
    public native func UpdateRecord(id: TweakDBID) -> Bool
    public native func RegisterEnum(id: TweakDBID)
    public native func RegisterName(name: CName) -> Bool
    public native func Commit()
    public func SetFlat(name: CName, value: Variant) -> Bool {
        if this.SetFlat(TDBID.Create(NameToString(name)), value) {
            this.RegisterName(name);
            return true;
        }
        return false;
    }
    public func CreateRecord(name: CName, type: CName) -> Bool {
        if this.CreateRecord(TDBID.Create(NameToString(name)), type) {
            this.RegisterName(name);
            return true;
        }
        return false;
    }
    public func CloneRecord(name: CName, base: TweakDBID) -> Bool {
        if this.CloneRecord(TDBID.Create(NameToString(name)), base) {
            this.RegisterName(name);
            return true;
        }
        return false;
    }
}

@addMethod(TweakDBInterface)
public final static native func GetFlat(path: TweakDBID) -> Variant
@addMethod(TweakDBInterface)
public final static native func GetRecord(path: TweakDBID) -> ref<TweakDBRecord>
@addMethod(TweakDBInterface)
public final static native func GetRecords(type: CName) -> array<ref<TweakDBRecord>>
@addMethod(TweakDBInterface)
public final static native func GetRecordCount(type: CName) -> Uint32
@addMethod(TweakDBInterface)
public final static native func GetRecordByIndex(type: CName, index: Uint32) -> ref<TweakDBRecord>
@addMethod(TweakDBInterface)
public final static func GetRecords(keys: array<TweakDBID>) -> array<ref<TweakDBRecord>> {
    let records: array<ref<TweakDBRecord>>;
    for key in keys {
        let record = TweakDBInterface.GetRecord(key);
        if IsDefined(record) {
            ArrayPush(records, record);
        }
    }
    return records;
}
@addMethod(TweakDBInterface)
public final static func GetRecordIDs(type: CName) -> array<TweakDBID> {
    let ids: array<TweakDBID>;
    for record in TweakDBInterface.GetRecords(type) {
        ArrayPush(ids, record.GetID());
    }
    return ids;
}

public abstract native class TweakDBManager {
    public final static native func SetFlat(id: TweakDBID, value: Variant) -> Bool
    public final static native func CreateRecord(id: TweakDBID, type: CName) -> Bool
    public final static native func CloneRecord(id: TweakDBID, base: TweakDBID) -> Bool
    public final static native func UpdateRecord(id: TweakDBID) -> Bool
    public final static native func RegisterEnum(id: TweakDBID)
    public final static native func RegisterName(name: CName) -> Bool
    public final static native func StartBatch() -> ref<TweakDBBatch>
    public final static func SetFlat(name: CName, value: Variant) -> Bool {
        if TweakDBManager.SetFlat(TDBID.Create(NameToString(name)), value) {
            TweakDBManager.RegisterName(name);
            return true;
        }
        return false;
    }
    public final static func CreateRecord(name: CName, type: CName) -> Bool {
        if TweakDBManager.CreateRecord(TDBID.Create(NameToString(name)), type) {
            TweakDBManager.RegisterName(name);
            return true;
        }
        return false;
    }
    public final static func CloneRecord(name: CName, base: TweakDBID) -> Bool {
        if TweakDBManager.CloneRecord(TDBID.Create(NameToString(name)), base) {
            TweakDBManager.RegisterName(name);
            return true;
        }
        return false;
    }
}

public abstract native class TweakXL {
    public static native func Require(version: String) -> Bool
    public static native func Version() -> String
}

@wrapMethod(ScannervehicleGameController)
protected cb func OnVehicleManufacturerChanged(value: Variant) -> Bool {
    wrappedMethod(value);
    if this.m_isValidVehicleManufacturer {
        let vehicleManufacturer = FromVariant<ref<ScannerVehicleManufacturer>>(value);
        let iconRecord = TweakDBInterface.GetUIIconRecord(TDBID.Create("UIIcon." + vehicleManufacturer.GetVehicleManufacturer()));
        inkImageRef.SetAtlasResource(this.m_vehicleManufacturer, iconRecord.AtlasResourcePath());
    }
}
