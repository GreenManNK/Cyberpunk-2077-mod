// CyberwareEx 1.5.6
module CyberwareEx
import Codeware.Localization.*
@if(ModuleExists("CyberwareEx.Customization"))
import CyberwareEx.Customization.*

public abstract class CompatibilityManager {
    public static func RequiredTweakXL() -> String = "1.11.3";
    public static func RequiredCodeware() -> String = "1.20.1";

    public static func CheckRequirements() -> Bool {
        return Codeware.Require(CompatibilityManager.RequiredCodeware())
            && TweakXL.Require(CompatibilityManager.RequiredTweakXL());
    }

    public static func CheckConflicts(game: GameInstance, out conflicts: array<String>) -> Bool {
        let itemController = new InventoryItemDisplayController();
        itemController.SetLocked(true, true);
        if !itemController.m_isLocked {
            if itemController.m_visibleWhenLocked {
                ArrayPush(conflicts, "No Special Outfit Lock");
            } else {
                ArrayPush(conflicts, "Never Lock Outfits");
            }
        }

        return ArraySize(conflicts) == 0;
    }

    public static func CheckConflicts(game: GameInstance) -> Bool {
        let conflicts: array<String>;
        return CompatibilityManager.CheckConflicts(game, conflicts);
    }

    public static func IsUserNotified() -> Bool {
        return TweakDBInterface.GetBool(t"CyberwareEx.isUserNotified", false);
    }

    public static func MarkAsNotified() {
        TweakDBManager.SetFlat(t"CyberwareEx.isUserNotified", true);
    }
}

@if(ModuleExists("CyberwareEx.Customization"))
public func IsCustomMode() -> Bool = true

@if(ModuleExists("CyberwareEx.Customization"))
public func GetCustomSlotExpansions() -> array<ExpansionArea> = UserConfig.SlotExpansions()

@if(ModuleExists("CyberwareEx.Customization"))
public func GetCustomSlotOverrides() -> array<OverrideArea> = UserConfig.SlotOverrides()

@if(ModuleExists("CyberwareEx.Customization"))
public func GetCustomUpgradePrice() -> Int32 = UserConfig.UpgradePrice()

@if(ModuleExists("CyberwareEx.Customization"))
public func GetCustomResetPrice() -> Int32 = UserConfig.ResetPrice()

@if(ModuleExists("CyberwareEx.Customization"))
public func IsCombinedAbilityMode() -> Bool = UserConfig.CombinedAbilityMode()

@if(!ModuleExists("CyberwareEx.Customization"))
public func IsCustomMode() -> Bool = false

@if(!ModuleExists("CyberwareEx.Customization"))
public func GetCustomSlotExpansions() -> array<ExpansionArea> = DefaultConfig.SlotExpansions()

@if(!ModuleExists("CyberwareEx.Customization"))
public func GetCustomSlotOverrides() -> array<OverrideArea> = DefaultConfig.SlotOverrides()

@if(!ModuleExists("CyberwareEx.Customization"))
public func GetCustomUpgradePrice() -> Int32 = DefaultConfig.UpgradePrice()

@if(!ModuleExists("CyberwareEx.Customization"))
public func GetCustomResetPrice() -> Int32 = DefaultConfig.ResetPrice()

@if(!ModuleExists("CyberwareEx.Customization"))
public func IsCombinedAbilityMode() -> Bool = DefaultConfig.CombinedAbilityMode()

public abstract class DefaultConfig {
    public static func SlotExpansions() -> array<ExpansionArea> = CyberwareConfig.DefaultSlotExpansions()
    public static func SlotOverrides() -> array<OverrideArea> = OverrideConfig.DefaultSlotOverrides()
    public static func UpgradePrice() -> Int32 = OverrideConfig.DefaultUpgradePrice()
    public static func ResetPrice() -> Int32 = OverrideConfig.DefaultResetPrice()
    public static func CombinedAbilityMode() -> Bool = false
}

public struct ExpansionArea {
    public let equipmentArea: gamedataEquipmentArea;
    public let extraSlots: array<ExpansionSlot>;

    public static func Create(equipmentArea: gamedataEquipmentArea, extraSlots: array<ExpansionSlot>) -> ExpansionArea =
        ExpansionArea(equipmentArea, extraSlots)
}

public struct ExpansionSlot {
    public let requiredPerk: gamedataNewPerkType;
    public let requiredLevel: Int32;

    public static func Create(requiredPerk: gamedataNewPerkType, requiredLevel: Int32) -> ExpansionSlot =
        ExpansionSlot(requiredPerk, requiredLevel)
}

public struct AttachmentSlot {
    public let slotID: TweakDBID;
    public let slotName: CName;
    public let cyberwareType: CName;

    public static func Create(slotName: CName, cyberwareType: CName) -> AttachmentSlot =
        AttachmentSlot(TDBID.Create(NameToString(slotName)), slotName, cyberwareType)
}

public struct CyberwareRemapping {
    public let displayName: CName;
    public let cyberwareType: CName;

    public static func Create(recordID: TweakDBID, cyberwareType: CName) -> CyberwareRemapping =
        CyberwareRemapping(TweakDBInterface.GetLocKeyDefault(recordID + t".displayName"), cyberwareType)
}

public abstract class CyberwareConfig {
    public static func SlotExpansions() -> array<ExpansionArea> =
        IsCustomMode()
            ? GetCustomSlotExpansions()
            : CyberwareConfig.DefaultSlotExpansions()

    public static func DefaultSlotExpansions() -> array<ExpansionArea> =
        IsExtendedMode()
                ? CyberwareConfig.ExtendedSlotExpansions()
                : CyberwareConfig.BasicSlotExpansions()

    public static func BasicSlotExpansions() -> array<ExpansionArea> = [
        ExpansionArea.Create(gamedataEquipmentArea.SystemReplacementCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3)
        ])
    ];

    public static func ExtendedSlotExpansions() -> array<ExpansionArea> = [
        ExpansionArea.Create(gamedataEquipmentArea.SystemReplacementCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.FrontalCortexCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Central_Milestone_3, 1),
            ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Central_Milestone_3, 2)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.CardiovascularSystemCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Body_Central_Perk_1_4, 1)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.NervousSystemCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 2)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.IntegumentarySystemCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 1),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Perk_3_3, 1)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.ArmsCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Perk_3_2, 1)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.HandsCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Perk_3_2, 1)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.LegsCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Central_Perk_1_3, 1)
        ])
    ];

    public static func Attachments() -> array<AttachmentSlot> = [
        AttachmentSlot.Create(n"CyberwareSlots.Berserk", n"Berserk"),
        AttachmentSlot.Create(n"CyberwareSlots.BoostedTendons", n"BoostedTendons"),
        AttachmentSlot.Create(n"CyberwareSlots.CapacityBooster", n"CapacityBooster"),
        AttachmentSlot.Create(n"CyberwareSlots.CatPaws", n"CatPaws"),
        AttachmentSlot.Create(n"CyberwareSlots.JenkinsTendons", n"JenkinsTendons"),
        AttachmentSlot.Create(n"CyberwareSlots.PowerGrip", n"PowerGrip"),
        AttachmentSlot.Create(n"CyberwareSlots.ReinforcedMuscles", n"ReinforcedMuscles"),
        AttachmentSlot.Create(n"CyberwareSlots.Sandevistan", n"Sandevistan"),
        AttachmentSlot.Create(n"CyberwareSlots.SmartLink", n"SmartLink")
    ];

    public static func Remappings() -> array<CyberwareRemapping> = [
        CyberwareRemapping.Create(t"Items.AdvancedKiroshiOpticsBareBase", n"KiroshiOpticsBare"),
        CyberwareRemapping.Create(t"Items.AdvancedKiroshiOpticsSensorBase", n"KiroshiOpticsSensor"),
        CyberwareRemapping.Create(t"Items.AdvancedKiroshiOpticsHunterBase", n"KiroshiOpticsSensor"),
        CyberwareRemapping.Create(t"Items.AdvancedKiroshiOpticsWallhackBase", n"KiroshiOpticsSensor"),
        CyberwareRemapping.Create(t"Items.AdvancedKiroshiOpticsCombinedBase", n"KiroshiOpticsSensor"),
        CyberwareRemapping.Create(t"Items.AdvancedKiroshiOpticsPiercingBase", n"KiroshiOpticsPiercing"),
        CyberwareRemapping.Create(t"Items.Iconic_AdvancedKiroshiOpticsBareBase", n"KiroshiOpticsCrit")
    ];
}

public class CyberwareHelper {
    public static func GetSlotRecord(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> wref<EquipSlot_Record> {
        let equipAreaID = TDBID.Create("EquipmentArea." + ToString(equipArea));
        let equipArea = TweakDBInterface.GetEquipmentAreaRecord(equipAreaID);
        return equipArea.GetEquipSlotsItem(slotIndex);
    }

    public static func GetPrereqRecord(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> wref<IPrereq_Record> {
        let equipSlot = CyberwareHelper.GetSlotRecord(equipArea, slotIndex);
        return equipSlot.UnlockPrereqRecord();
    }

    public static func GetPerkPrereqRecord(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> wref<PlayerIsNewPerkBoughtPrereq_Record> {
        let equipSlot = CyberwareHelper.GetSlotRecord(equipArea, slotIndex);
        return equipSlot.UnlockPrereqRecord() as PlayerIsNewPerkBoughtPrereq_Record;
    }

    public static func GetRequiredPerkAbility(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> gamedataNewPerkType {
        let perkPrereq = CyberwareHelper.GetPerkPrereqRecord(equipArea, slotIndex);
        return IsDefined(perkPrereq)
            ? IntEnum<gamedataNewPerkType>(Cast<Int32>(EnumValueFromString("gamedataNewPerkType", perkPrereq.PerkType())))
            : gamedataNewPerkType.Invalid;
    }

    public static func GetRequiredPerkRecord(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> wref<NewPerk_Record> {
        let perkPrereq = CyberwareHelper.GetPerkPrereqRecord(equipArea, slotIndex);
        if IsDefined(perkPrereq) {
            let perkID = TDBID.Create("NewPerks." + perkPrereq.PerkType());
            return TweakDBInterface.GetNewPerkRecord(perkID);
        } else {
            return null;
        }
    }

    public static func GetRequiredPerkType(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> gamedataNewPerkType {
        let perkRecord = CyberwareHelper.GetRequiredPerkRecord(equipArea, slotIndex);
        return IsDefined(perkRecord) ? perkRecord.Type() : gamedataNewPerkType.Invalid;

    }

    public static func GetRequiredPerkStatType(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> gamedataStatType {
        let perkRecord = CyberwareHelper.GetRequiredPerkRecord(equipArea, slotIndex);
        return IsDefined(perkRecord) ? perkRecord.Attribute().Attribute().StatType() : gamedataStatType.Invalid;
    }

    public static func GetRequiredPerkLevel(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> Int32 {
        let perkPrereq = CyberwareHelper.GetPerkPrereqRecord(equipArea, slotIndex);
        return IsDefined(perkPrereq) ? perkPrereq.Level() : 0;
    }

    public static func GetRequiredPerkMaxLevel(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> Int32 {
        let perkRecord = CyberwareHelper.GetRequiredPerkRecord(equipArea, slotIndex);
        return IsDefined(perkRecord) ? perkRecord.GetLevelsCount() : 0;
    }

    public static func IsPerkRequired(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> Bool {
        let perkPrereq = CyberwareHelper.GetPerkPrereqRecord(equipArea, slotIndex);
        return IsDefined(perkPrereq);
    }

    public static func IsUnlockRequired(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> Bool {
        let anyPrereq = CyberwareHelper.GetPrereqRecord(equipArea, slotIndex);
        return IsDefined(anyPrereq);
    }

    public static func IsCyberdeckEquipped(owner: ref<GameObject>) -> Bool {
        return GameInstance.GetStatsSystem(owner.GetGame()).GetStatBoolValue(Cast(owner.GetEntityID()), gamedataStatType.HasCyberdeck);
    }

    public static func IsCyberwareArea(equipArea: gamedataEquipmentArea) -> Bool {
        switch equipArea {
            case gamedataEquipmentArea.ArmsCW:
            case gamedataEquipmentArea.CardiovascularSystemCW:
            case gamedataEquipmentArea.EyesCW:
            case gamedataEquipmentArea.FrontalCortexCW:
            case gamedataEquipmentArea.HandsCW:
            case gamedataEquipmentArea.IntegumentarySystemCW:
            case gamedataEquipmentArea.LegsCW:
            case gamedataEquipmentArea.MusculoskeletalSystemCW:
            case gamedataEquipmentArea.NervousSystemCW:
            case gamedataEquipmentArea.SystemReplacementCW:
                return true;
        }
        return false;
    }

    public static func CreateEquipSlotRecord(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> TweakDBID {
        let equipAreaName = ToString(equipArea);
        let equipSlotName = s"EquipmentArea.\(equipAreaName)_Slot_\(slotIndex)";
        let equipSlotID = TDBID.Create(equipSlotName);

        if !IsDefined(TweakDBInterface.GetEquipSlotRecord(equipSlotID)) {
            TweakDBManager.CreateRecord(equipSlotID, n"EquipSlot");

            if Equals(equipArea, gamedataEquipmentArea.MusculoskeletalSystemCW) {
                let powerUpID = CyberwareHelper.CreatePowerUpRecord(equipArea, slotIndex);
                TweakDBManager.SetFlat(equipSlotID + t".OnInsertion", [powerUpID]);
            }

            TweakDBManager.UpdateRecord(equipSlotID);
            TweakDBManager.RegisterName(StringToName(equipSlotName));
        }

        return equipSlotID;
    }

    public static func CreateEquipSlotRecord(equipArea: gamedataEquipmentArea, slotIndex: Int32, requiredPerk: gamedataNewPerkType, requiredLevel: Int32) -> TweakDBID {
        let equipAreaName = ToString(equipArea);
        let equipSlotName = s"EquipmentArea.\(equipAreaName)_Slot_\(slotIndex)_Perk_\(requiredPerk)_\(requiredLevel)";
        let equipSlotID = TDBID.Create(equipSlotName);

        if !IsDefined(TweakDBInterface.GetEquipSlotRecord(equipSlotID)) {
            let prereqName = s"Prereqs.HasPerk_\(requiredPerk)_\(requiredLevel)";
            let prereqID = TDBID.Create(prereqName);

            if !IsDefined(TweakDBInterface.GetPrereqRecord(prereqID)) {
                TweakDBManager.CreateRecord(prereqID, n"PlayerIsNewPerkBoughtPrereq");
                TweakDBManager.SetFlat(prereqID + t".perkType", ToString(requiredPerk));
                TweakDBManager.SetFlat(prereqID + t".level", requiredLevel);
                TweakDBManager.UpdateRecord(prereqID);
                TweakDBManager.RegisterName(StringToName(prereqName));
            }

            TweakDBManager.CreateRecord(equipSlotID, n"EquipSlot");
            TweakDBManager.SetFlat(equipSlotID + t".unlockPrereqRecord", prereqID);
            TweakDBManager.SetFlat(equipSlotID + t".visibleWhenLocked", true);

            if Equals(equipArea, gamedataEquipmentArea.MusculoskeletalSystemCW) {
                let powerUpID = CyberwareHelper.CreatePowerUpRecord(equipArea, slotIndex);
                TweakDBManager.SetFlat(equipSlotID + t".OnInsertion", [powerUpID]);
            }

            TweakDBManager.UpdateRecord(equipSlotID);
            TweakDBManager.RegisterName(StringToName(equipSlotName));
        }

        return equipSlotID;
    }

    public static func CreatePowerUpRecord(equipArea: gamedataEquipmentArea, slotIndex: Int32) -> TweakDBID {
        let equipAreaName = ToString(equipArea);
        let packageName = s"EquipmentArea.\(equipAreaName)_Slot_\(slotIndex)_PowerUp";
        let packageID = TDBID.Create(packageName);

        if !IsDefined(TweakDBInterface.GetGameplayLogicPackageRecord(packageID)) {
            let effectorName = s"\(packageName)_Effector";
            let effectorID = TDBID.Create(effectorName);

            if !IsDefined(TweakDBInterface.GetEffectorRecord(effectorID)) {
                TweakDBManager.CloneRecord(effectorID, t"Effectors.PowerUpCyberwareEffector");
                TweakDBManager.SetFlat(effectorID + t".targetEquipArea", equipAreaName);
                TweakDBManager.SetFlat(effectorID + t".targetEquipSlotIndex", slotIndex);
                TweakDBManager.UpdateRecord(effectorID);
                TweakDBManager.RegisterName(StringToName(effectorName));
            }

            TweakDBManager.CreateRecord(packageID, n"GameplayLogicPackage");
            TweakDBManager.SetFlat(packageID + t".effectors", [effectorID]);
            TweakDBManager.UpdateRecord(packageID);
            TweakDBManager.RegisterName(StringToName(packageName));
        }

        return packageID;
    }
}

@if(ModuleExists("CyberwareEx.ExtendedMode"))
public func IsExtendedMode() -> Bool = true

@if(!ModuleExists("CyberwareEx.ExtendedMode"))
public func IsExtendedMode() -> Bool = false

public struct OverrideArea {
    public let areaType: gamedataEquipmentArea;
    public let defaultSlots: Int32;
    public let maxSlots: Int32;

    public static func None() -> OverrideArea = OverrideArea(gamedataEquipmentArea.Invalid, 0, 0)
    public static func IsValid(slot: OverrideArea) -> Bool = NotEquals(slot.areaType, gamedataEquipmentArea.Invalid)
    
    public static func Create(areaType: gamedataEquipmentArea, maxSlots: Int32) -> OverrideArea =
        OverrideArea(areaType, 0, maxSlots)
}

public abstract class OverrideConfig {
    public static func SlotOverrides() -> array<OverrideArea> =
        IsCustomMode()
            ? GetCustomSlotOverrides()
            : OverrideConfig.DefaultSlotOverrides()

    public static func UpgradePrice() -> Int32 =
        IsCustomMode()
            ? GetCustomUpgradePrice()
            : OverrideConfig.DefaultUpgradePrice()

    public static func ResetPrice() -> Int32 =
        IsCustomMode()
            ? GetCustomResetPrice()
            : OverrideConfig.DefaultResetPrice()

    public static func DefaultSlotOverrides() -> array<OverrideArea> = [
        OverrideArea.Create(gamedataEquipmentArea.ArmsCW, 4),
        OverrideArea.Create(gamedataEquipmentArea.CardiovascularSystemCW, 6),
        OverrideArea.Create(gamedataEquipmentArea.EyesCW, 5),
        OverrideArea.Create(gamedataEquipmentArea.FrontalCortexCW, 6),
        OverrideArea.Create(gamedataEquipmentArea.HandsCW, 4),
        OverrideArea.Create(gamedataEquipmentArea.IntegumentarySystemCW, 6),
        OverrideArea.Create(gamedataEquipmentArea.LegsCW, 4),
        OverrideArea.Create(gamedataEquipmentArea.MusculoskeletalSystemCW, 6),
        OverrideArea.Create(gamedataEquipmentArea.NervousSystemCW, 6),
        OverrideArea.Create(gamedataEquipmentArea.SystemReplacementCW, 4)
    ];

     public static func DefaultUpgradePrice() -> Int32 = 10000
     public static func DefaultResetPrice() -> Int32 = 5000
}

public class OverrideState {
    public let areaType: gamedataEquipmentArea;
    public let areaIndex: Int32;
    public let currentSlots: Int32;
    public let defaultSlots: Int32;
    public let maxSlots: Int32;
    public let isOverridable: Bool;
    public let canBuyOverride: Bool;
    public let canBuyReset: Bool;
}

public class OverrideManager {
    private let m_overrides: array<OverrideArea>;
    private let m_playerData: ref<EquipmentSystemPlayerData>;

    public func Initialize(playerData: ref<EquipmentSystemPlayerData>) {
        this.m_playerData = playerData;
        this.m_overrides = OverrideConfig.SlotOverrides();

        let i = 0;
        while i < ArraySize(this.m_overrides) {
            let areaRecord = this.m_playerData.GetEquipAreaRecordByType(this.m_overrides[i].areaType);
            this.m_overrides[i].defaultSlots = areaRecord.GetEquipSlotsCount();
            i += 1;
        }
    }

    public func GetOverrideState(areaType: gamedataEquipmentArea) -> ref<OverrideState> {
        let overrideState = new OverrideState();
        overrideState.areaType = areaType;
        overrideState.areaIndex = this.GetEquipAreaIndex(areaType);
        overrideState.currentSlots = this.GetEquipAreaNumberOfSlots(areaType);

        let overrideArea = this.GetOverrideArea(areaType);
        if OverrideArea.IsValid(overrideArea) {
            overrideState.defaultSlots = overrideArea.defaultSlots;
            overrideState.maxSlots = overrideArea.maxSlots;
            overrideState.isOverridable = true;

            let playerMoney = GameInstance.GetTransactionSystem(this.m_playerData.m_owner.GetGame())
                .GetItemQuantity(this.m_playerData.m_owner, MarketSystem.Money());

            overrideState.canBuyOverride = (playerMoney >= OverrideConfig.UpgradePrice());
            overrideState.canBuyReset = (playerMoney >= OverrideConfig.ResetPrice());
        }

        return overrideState;
    }

    public func UpgradeSlot(areaType: gamedataEquipmentArea, opt free: Bool, opt vendor: wref<GameObject>) -> Bool {
        let overrideState = this.GetOverrideState(areaType);

        if !overrideState.isOverridable || overrideState.currentSlots == overrideState.maxSlots {
            return false;
        }

        if !overrideState.canBuyOverride && !free {
            return false;
        }

        let newSlotIndex = overrideState.currentSlots;
        let equipSlotID = CyberwareHelper.CreateEquipSlotRecord(areaType, newSlotIndex);

        ArrayResize(this.m_playerData.m_equipment.equipAreas[overrideState.areaIndex].equipSlots, overrideState.currentSlots + 1);

        this.m_playerData.InitializeEquipSlotFromRecord(TweakDBInterface.GetEquipSlotRecord(equipSlotID),
            this.m_playerData.m_equipment.equipAreas[overrideState.areaIndex].equipSlots[newSlotIndex]);

        if !free {
            let transactionSystem = GameInstance.GetTransactionSystem(this.m_playerData.m_owner.GetGame());
            if IsDefined(vendor) {
                transactionSystem.TransferItem(this.m_playerData.m_owner, vendor, MarketSystem.Money(), OverrideConfig.UpgradePrice());
            } else {
                transactionSystem.RemoveItem(this.m_playerData.m_owner, MarketSystem.Money(), OverrideConfig.UpgradePrice());
            }
        }

        return true;
    }

    public func ResetSlot(areaType: gamedataEquipmentArea, opt free: Bool, opt vendor: wref<GameObject>) -> Bool {
        let overrideState = this.GetOverrideState(areaType);

        if !overrideState.isOverridable || overrideState.currentSlots == overrideState.defaultSlots {
            return false;
        }

        if !overrideState.canBuyReset && !free {
            return false;
        }

        let slotIndex = overrideState.defaultSlots + 1;
        while slotIndex <= overrideState.currentSlots {
            if ItemID.IsValid(this.m_playerData.m_equipment.equipAreas[overrideState.areaIndex].equipSlots[slotIndex].itemID) {
                this.m_playerData.UnequipItem(overrideState.areaIndex, slotIndex);
            }
            slotIndex += 1;
        }

        ArrayResize(this.m_playerData.m_equipment.equipAreas[overrideState.areaIndex].equipSlots, overrideState.defaultSlots);

        if !free {
            let transactionSystem = GameInstance.GetTransactionSystem(this.m_playerData.m_owner.GetGame());
            if IsDefined(vendor) {
                transactionSystem.TransferItem(this.m_playerData.m_owner, vendor, MarketSystem.Money(), OverrideConfig.ResetPrice());
            } else {
                transactionSystem.RemoveItem(this.m_playerData.m_owner, MarketSystem.Money(), OverrideConfig.ResetPrice());
            }
        }

        return true;
    }

    private func GetOverrideArea(areaType: gamedataEquipmentArea) -> OverrideArea {
        for slot in this.m_overrides {
            if Equals(slot.areaType, areaType) {
                return slot;
            }
        }

        return OverrideArea.None();
    }

    private func GetEquipAreaIndex(areaType: gamedataEquipmentArea) -> Int32 {
        let i = 0;
        while i < ArraySize(this.m_playerData.m_equipment.equipAreas) {
            if Equals(this.m_playerData.m_equipment.equipAreas[i].areaType, areaType) {
                return i;
            }
            i += 1;
        }
        return -1;
    }

    private func GetEquipAreaNumberOfSlots(areaType: gamedataEquipmentArea) -> Int32 {
        let i = 0;
        while i < ArraySize(this.m_playerData.m_equipment.equipAreas) {
            if Equals(this.m_playerData.m_equipment.equipAreas[i].areaType, areaType) {
                return ArraySize(this.m_playerData.m_equipment.equipAreas[i].equipSlots);
            }
            i += 1;
        }
        return -1;
    }
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
public func IsOverrideMode() -> Bool = true

@if(!ModuleExists("CyberwareEx.OverrideMode"))
public func IsOverrideMode() -> Bool = false

public class EnglishPackage extends ModLocalizationPackage {
  protected func DefineTexts() {
    this.Text("UI-CyberwareEx-NotificationRequirements", "Cyberware-EX requires:\\n- TweakXL {tweak_xl_req} or higher\\n- Codeware {codeware_req} or higher\\n\\nDetected TweakXL {tweak_xl_ver} and Codeware {codeware_ver}.\\n\\nPlease update the dependencies to use this mod.");
    this.Text("UI-CyberwareEx-NotificationConflicts", "Cyberware-EX has detected a conflicting mod.\\n\\nThe following mods may cause problems or block the functionality:\\n{conflicts}\\nPlease disable or remove conflicting mods if you wish to use Cyberware-EX.");
  }
}

public class LocalizationProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    switch language {
      case n"en-us": return new EnglishPackage();
      default: return null;
    }
  }

  public func GetFallback() -> CName {
    return n"en-us";
  }
}

class AdjustCyberwareCompatibility extends ScriptableTweak {
    protected func OnApply() {
        let attachmentSlots = CyberwareConfig.Attachments();
        let cyberwareRemappings = CyberwareConfig.Remappings();
        for record in TweakDBInterface.GetRecords(n"Item_Record") {
            let cyberwareTypeFlat = TweakDBInterface.GetFlat(record.GetID() + t".cyberwareType");
            if IsDefined(cyberwareTypeFlat) {
                let cyberwareType = FromVariant<CName>(cyberwareTypeFlat);
                let placementSlots = TweakDBInterface.GetForeignKeyArray(record.GetID() + t".placementSlots");
                if ArraySize(placementSlots) > 0 {
                    if Equals(cyberwareType, n"IconicJenkinsTendons") {
                        cyberwareType = n"JenkinsTendons";
                        TweakDBManager.SetFlat(record.GetID() + t".cyberwareType", cyberwareType);
                    }
                    for attachmentSlot in attachmentSlots {
                        if Equals(cyberwareType, attachmentSlot.cyberwareType) {
                            TweakDBManager.SetFlat(record.GetID() + t".placementSlots", [attachmentSlot.slotID]);
                            TweakDBManager.UpdateRecord(record.GetID());
                            break;
                        }
                    }
                } else {
                    for cyberwareRemapping in cyberwareRemappings {
                        let displayName = TweakDBInterface.GetLocKeyDefault(record.GetID() + t".displayName");
                        if Equals(displayName, cyberwareRemapping.displayName) {
                            TweakDBManager.SetFlat(record.GetID() + t".cyberwareType", cyberwareRemapping.cyberwareType);
                            break;
                        }
                    }
                }
            }
        }

        TweakDBManager.SetFlat(t"BaseStatusEffect.BerserkTimeDilationEffector.effectorClassName", n"");
        TweakDBManager.UpdateRecord(t"BaseStatusEffect.BerserkTimeDilationEffector");

        let chargeJumpTransitions = TweakDBInterface.GetStringArray(t"playerStateMachineLocomotion.chargeJump.transitionTo");
        let chargeJumpConditions = TweakDBInterface.GetStringArray(t"playerStateMachineLocomotion.chargeJump.transitionCondition");
        if !ArrayContains(chargeJumpTransitions, "doubleJump") {
            ArrayPush(chargeJumpTransitions, "doubleJump");
            ArrayPush(chargeJumpConditions, "");
            TweakDBManager.SetFlat(t"playerStateMachineLocomotion.chargeJump.transitionTo", chargeJumpTransitions);
            TweakDBManager.SetFlat(t"playerStateMachineLocomotion.chargeJump.transitionCondition", chargeJumpConditions);
        }
    }
}

class RegisterAttachmentSlots extends ScriptableTweak {
    protected func OnApply() {
        let attachmentSlots = CyberwareConfig.Attachments();

        for attachmentSlot in attachmentSlots {
            TweakDBManager.CreateRecord(attachmentSlot.slotID, n"AttachmentSlot_Record");
            TweakDBManager.RegisterName(attachmentSlot.slotName);
        }

        let playerEntityTemplates = [
            r"base\\characters\\entities\\player\\player_wa_fpp.ent",
            r"base\\characters\\entities\\player\\player_wa_tpp.ent",
            r"base\\characters\\entities\\player\\player_wa_tpp_cutscene.ent",
            r"base\\characters\\entities\\player\\player_wa_tpp_cutscene_no_impostor.ent",
            r"base\\characters\\entities\\player\\player_wa_tpp_reflexion.ent",
            r"base\\characters\\entities\\player\\player_ma_fpp.ent",
            r"base\\characters\\entities\\player\\player_ma_tpp.ent",
            r"base\\characters\\entities\\player\\player_ma_tpp_cutscene.ent",
            r"base\\characters\\entities\\player\\player_ma_tpp_cutscene_no_impostor.ent",
            r"base\\characters\\entities\\player\\player_ma_tpp_reflexion.ent"
        ];

        let playerDisplayName = GetLocalizedTextByKey(TweakDBInterface.GetLocKeyDefault(t"Character.Player_Puppet_Base.displayName"));

        for record in TweakDBInterface.GetRecords(n"Character_Record") {
            let character = record as Character_Record;
            if ArrayContains(playerEntityTemplates, character.EntityTemplatePath()) || Equals(GetLocalizedTextByKey(character.DisplayName()), playerDisplayName) {
                let characterSlots = TweakDBInterface.GetForeignKeyArray(character.GetID() + t".attachmentSlots");
                if ArrayContains(characterSlots, t"AttachmentSlots.SystemReplacementCW") {
                    for attachmentSlot in attachmentSlots {
                        if !ArrayContains(characterSlots, attachmentSlot.slotID) {
                            ArrayPush(characterSlots, attachmentSlot.slotID);
                        }
                    }

                    TweakDBManager.SetFlat(character.GetID() + t".attachmentSlots", characterSlots);
                    TweakDBManager.UpdateRecord(character.GetID());
                }
            }
        }
    }
}

class RegisterCyberwareSlots extends ScriptableTweak {
    protected func OnApply() {
        if !IsDefined(TweakDBInterface.GetRecord(t"EquipmentArea.SkeletonEquipSlot")) {
            TweakDBManager.CloneRecord(n"EquipmentArea.SkeletonEquipSlot", t"EquipmentArea.SimpleEquipSlot");
        }

        if IsOverrideMode() {
            return;
        }

        for expansion in CyberwareConfig.SlotExpansions() {
            let equipmentAreaID = TDBID.Create(s"EquipmentArea.\(expansion.equipmentArea)");
            let equipmentAreaSlots = TweakDBInterface.GetForeignKeyArray(equipmentAreaID + t".equipSlots");

            let defaultNumSlots = TweakDBInterface.GetIntDefault(equipmentAreaID + t".defaultNumSlots");
            if defaultNumSlots == 0 {
                defaultNumSlots = ArraySize(equipmentAreaSlots);
            } else {
                ArrayResize(equipmentAreaSlots, defaultNumSlots);
            }

            for extraSlot in expansion.extraSlots {
                let extraSlotIndex = ArraySize(equipmentAreaSlots);
                ArrayPush(equipmentAreaSlots,
                    CyberwareHelper.CreateEquipSlotRecord(
                        expansion.equipmentArea,
                        extraSlotIndex,
                        extraSlot.requiredPerk,
                        extraSlot.requiredLevel));
            }

            TweakDBManager.SetFlat(equipmentAreaID + t".defaultNumSlots", defaultNumSlots);
            TweakDBManager.SetFlat(equipmentAreaID + t".equipSlots", equipmentAreaSlots);
            TweakDBManager.UpdateRecord(equipmentAreaID);
        }
    }
}

public enum OverrideAction {
    Upgrade = 1,
    Reset = 2
}

public class OverrideConfirmationPopup {
    public static func Show(controller: ref<worlduiIGameController>, action: OverrideAction, slotState: ref<OverrideState>) -> ref<inkGameNotificationToken> {
        let title = OverrideConfirmationPopup.GetTitle(action);

        let areaLabel = OverrideConfirmationPopup.GetAreaLabel();
        let areaName = OverrideConfirmationPopup.GetAreaName(slotState);

        let slotLabel = OverrideConfirmationPopup.GetSlotLabel();
        let initialSlots = OverrideConfirmationPopup.GetInitialSlots(action, slotState);
        let finalSlots = OverrideConfirmationPopup.GetFinalSlots(action, slotState);

        let priceLabel = OverrideConfirmationPopup.GetPriceLabel();
        let actionPrice = OverrideConfirmationPopup.GetActionPrice(action);

        let message = s"\(areaLabel): \(areaName)\n"
            + s"\(slotLabel): \(initialSlots) > \(finalSlots)\n"
            + s"\(priceLabel): \(actionPrice)";

        return GenericMessageNotification.Show(controller, EnumInt(slotState.areaType), title, message, GenericMessageNotificationType.ConfirmCancel);
    }

    public static func IsConfirmed(data: ref<inkGameNotificationData>) -> Bool {
        let popupData = data as GenericMessageNotificationCloseData;
        return Equals(popupData.result, GenericMessageNotificationResult.Confirm);
    }

    public static func GetAreaType(data: ref<inkGameNotificationData>) -> gamedataEquipmentArea {
        let popupData = data as GenericMessageNotificationCloseData;
        return IntEnum<gamedataEquipmentArea>(popupData.identifier);
    }

    private static func GetTitle(action: OverrideAction) -> String {
        return s"\(OverrideConfirmationPopup.GetActionLabel(action)) \(OverrideConfirmationPopup.GetAreaLabel())";
    }

    private static func GetActionLabel(action: OverrideAction) -> String {
        return Equals(action, OverrideAction.Upgrade)
            ? GetLocalizedTextByKey(n"UI-Crafting-Upgrade")
            : GetLocalizedTextByKey(n"UI-ResourceExports-Reset");
    }


    private static func GetInitialSlots(action: OverrideAction, slotState: ref<OverrideState>) -> Int32 {
        return slotState.currentSlots;
    }

    private static func GetFinalSlots(action: OverrideAction, slotState: ref<OverrideState>) -> Int32 {
        return Equals(action, OverrideAction.Upgrade) ? slotState.currentSlots + 1 : slotState.defaultSlots;
    }

    private static func GetActionPrice(action: OverrideAction) -> Int32 {
        return Equals(action, OverrideAction.Upgrade) ? OverrideConfig.UpgradePrice() : OverrideConfig.ResetPrice();
    }

    private static func GetAreaName(slotState: ref<OverrideState>) -> String {
        let name = EnumValueToString("gamedataEquipmentArea", Cast<Int64>(EnumInt(slotState.areaType)));
        let record = TweakDBInterface.GetEquipmentAreaRecord(TDBID.Create("EquipmentArea." + name));
        let result = record.LocalizedName();
        return NotEquals(result, "") ? GetLocalizedText(result) : name;
    }

    private static func GetAreaLabel() -> String = GetLocalizedText("UI-ResourceExports-Cyberware")
    private static func GetSlotLabel() -> String = GetLocalizedText("LocKey#53485")
    private static func GetPriceLabel() -> String = GetLocalizedText("UI-ResourceExports-Price")
}

public class ConflictsPopup {
    public static func Show(controller: ref<inkGameController>) -> ref<inkGameNotificationToken> {
        let game = controller.GetPlayerControlledObject().GetGame();
        let conflicts: array<String>;
        CompatibilityManager.CheckConflicts(game, conflicts);

        let conflictStr: String;
        for conflict in conflicts {
            conflictStr += "- " + conflict + "\n";
        }
        
        let params = new inkTextParams();
        params.AddString("conflicts", conflictStr);

        return GenericMessageNotification.Show(
            controller, 
            GetLocalizedText("LocKey#11447"), 
            GetLocalizedTextByKey(n"UI-CyberwareEx-NotificationConflicts"), 
            params,
            GenericMessageNotificationType.OK
        );
    }
}

public class RequirementsPopup {
    public static func Show(controller: ref<worlduiIGameController>) -> ref<inkGameNotificationToken> {
        let params = new inkTextParams();

        params.AddString("tweak_xl_req", CompatibilityManager.RequiredTweakXL());
        params.AddString("codeware_req", CompatibilityManager.RequiredCodeware());

        params.AddString("tweak_xl_ver", TweakXL.Version());
        params.AddString("codeware_ver", Codeware.Version());

        return GenericMessageNotification.Show(
            controller, 
            GetLocalizedText("LocKey#11447"), 
            GetLocalizedTextByKey(n"UI-CyberwareEx-NotificationRequirements"), 
            params,
            GenericMessageNotificationType.OK
        );
    }
}
