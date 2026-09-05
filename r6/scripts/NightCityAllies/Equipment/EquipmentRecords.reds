module NightCityAllies.Equipment

import NightCityAllies.*

public final class NCACloneName {
    private static func Root() -> String = "NCA.";

    private static func Fold(id: TweakDBID) -> String {
        return StrReplaceAll(TDBID.ToStringDEBUG(id), ".", "_");
    }

    public static func Character(companionId: TweakDBID) -> CName {
        return StringToName(NCACloneName.Root() + TDBID.ToStringDEBUG(companionId));
    }

    private static func Derived(companionId: TweakDBID, suffix: String) -> CName {
        return StringToName(NameToString(NCACloneName.Character(companionId)) + "_" + suffix);
    }

    public static func Group(companionId: TweakDBID, group: CName) -> CName {
        return NCACloneName.Derived(companionId, "group_" + NameToString(group));
    }

    public static func Item(companionId: TweakDBID, equipSlot: CName, weapon: TweakDBID) -> CName {
        return NCACloneName.Derived(companionId,
            "item_" + NameToString(equipSlot) + "_" + NCACloneName.Fold(weapon));
    }

    public static func Weapon(companionId: TweakDBID, equipSlot: CName, weapon: TweakDBID) -> CName {
        return NCACloneName.Derived(companionId,
            "weapon_" + NameToString(equipSlot) + "_" + NCACloneName.Fold(weapon));
    }

    public static func Part(companionId: TweakDBID, equipSlot: CName, attachmentSlot: TweakDBID) -> CName {
        return NCACloneName.Derived(companionId,
            "part_" + NameToString(equipSlot) + "_" + NCACloneName.Fold(attachmentSlot));
    }

    public static func ToID(name: CName) -> TweakDBID {
        return TDBID.Create(NameToString(name));
    }
}

public class NCARecordWrite {
    private let m_name: CName;
    private let m_id: TweakDBID;
    private let m_rejected: String;
    private let m_valid: Bool;

    public static func Clone(name: CName, base: TweakDBID) -> ref<NCARecordWrite> {
        let write = new NCARecordWrite();
        write.m_name = name;
        write.m_id = NCACloneName.ToID(name);
        write.m_valid = true;

        if IsDefined(TweakDBInterface.GetRecord(write.m_id)) {
            return write;
        }

        if !TweakDBManager.CloneRecord(name, base) {
            NCA.CETLog("[equip] ERROR clone failed: " + NameToString(name)
                + " from " + TDBID.ToStringDEBUG(base));
            write.m_valid = false;
            return write;
        }

        TweakDBManager.UpdateRecord(write.m_id);

        return write;
    }

    public func Set(flat: String, value: Variant) -> Void {
        if !this.m_valid {
            return;
        }

        if !TweakDBManager.SetFlat(TDBID.Create(NameToString(this.m_name) + "." + flat), value) {
            this.m_rejected += " " + flat;
        }
    }

    public func Commit() -> Bool {
        if !this.m_valid {
            return false;
        }

        TweakDBManager.UpdateRecord(this.m_id);

        if IsStringValid(this.m_rejected) {
            NCA.CETLog("[equip] ERROR flats rejected on " + NameToString(this.m_name)
                + ":" + this.m_rejected);
            return false;
        }

        return true;
    }

    public func GetID() -> TweakDBID {
        return this.m_id;
    }

    public func IsValid() -> Bool {
        return this.m_valid;
    }
}
