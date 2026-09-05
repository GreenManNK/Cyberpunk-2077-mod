module NightCityAllies.Equipment

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Util.*
import NightCityAllies.Npc.*

public struct NCAItemPartEntry {
    public let slot: TweakDBID; // AttachmentSlots.*
    public let part: TweakDBID; // part item record
    public let partName: String;
}

public class NCAEquipmentSystem extends ScriptableSystem {
    private let m_prepared: array<TweakDBID>;

    public static func PrimarySlot() -> CName = n"primary";
    public static func Primary2Slot() -> CName = n"primary2";
    public static func SecondarySlot() -> CName = n"secondary";

    public static func Slots() -> array<CName> {
        let slots: array<CName>;

        ArrayPush(slots, NCAEquipmentSystem.PrimarySlot());
        ArrayPush(slots, NCAEquipmentSystem.Primary2Slot());
        ArrayPush(slots, NCAEquipmentSystem.SecondarySlot());

        return slots;
    }

    private static func GroupOf(equipSlot: CName) -> CName {
        return Equals(equipSlot, NCAEquipmentSystem.SecondarySlot())
            ? NCAEquipmentSystem.SecondarySlot()
            : NCAEquipmentSystem.PrimarySlot();
    }

    private static func SlotsInGroup(group: CName) -> array<CName> {
        let slots: array<CName>;

        if Equals(group, NCAEquipmentSystem.SecondarySlot()) {
            ArrayPush(slots, NCAEquipmentSystem.SecondarySlot());
            return slots;
        }

        ArrayPush(slots, NCAEquipmentSystem.PrimarySlot());
        ArrayPush(slots, NCAEquipmentSystem.Primary2Slot());

        return slots;
    }

    private static func CombatArchetypeSource() -> TweakDBID = t"Character.Panam"; // TODO check more generic sources

    // Remove plot-armor
    public static func StrippedStatGroups() -> array<TweakDBID> {
        return [
            t"NPCStatPreset.VeryHighHealth"
        ];
    }

    private static func IsStrippedStatGroup(groupID: TweakDBID) -> Bool {
        let stripped: array<TweakDBID> = NCAEquipmentSystem.StrippedStatGroups();

        let i: Int32 = 0;
        while i < ArraySize(stripped) {
            if TDBID.ToNumber(stripped[i]) == TDBID.ToNumber(groupID) {
                return true;
            }

            i += 1;
        }

        return false;
    }

    private static func GivingRemovesFromPlayer() -> Bool = true;

// ============================================ Clone lifecycle ========================================================

    public func PrepareCharacter(companionId: TweakDBID) -> Bool {
        if ArrayContains(this.m_prepared, companionId) {
            return true;
        }

        if !IsDefined(TweakDBInterface.GetCharacterRecord(companionId)) {
            return false;
        }

        let character = NCARecordWrite.Clone(NCACloneName.Character(companionId), companionId);
        if !character.IsValid() {
            return false;
        }

        let record = TweakDBInterface.GetCharacterRecord(character.GetID());
        if !IsDefined(record) {
            NCA.CETLog("[equip] ERROR " + TDBID.ToStringDEBUG(character.GetID()) + " is not a character record");
            return false;
        }

        ArrayPush(this.m_prepared, companionId);

        //NCA.CETLog("[equip] prepared " + TDBID.ToStringDEBUG(companionId) + " -> " + TDBID.ToStringDEBUG(character.GetID()) + " | template " + ResRef.ToString(record.EntityTemplatePath()));

        this.ApplyCombatAbilities(companionId);
        this.ApplyStatGroups(companionId);

        // once per group
        this.RebuildGroup(companionId, NCAEquipmentSystem.PrimarySlot());
        this.RebuildGroup(companionId, NCAEquipmentSystem.SecondarySlot());

        return true;
    }

    public func GetSpawnRecordID(companionId: TweakDBID) -> TweakDBID {
        return ArrayContains(this.m_prepared, companionId) ? this.GetCloneRecordID(companionId) : companionId;
    }

    public func GetCloneRecordID(companionId: TweakDBID) -> TweakDBID {
        return NCACloneName.ToID(NCACloneName.Character(companionId));
    }

    private func ApplyCombatAbilities(companionId: TweakDBID) -> Void {
        let record = TweakDBInterface.GetCharacterRecord(companionId);
        if !IsDefined(record) {
            return;
        }

        let write = NCARecordWrite.Clone(NCACloneName.Character(companionId), companionId);
        let abilities: array<TweakDBID> = NCAEquipmentSystem.MergedCombatAbilities(record);
        write.Set("abilities", ToVariant(abilities));

        let borrowed: String = "";
        if !IsDefined(record.ArchetypeData()) {
            let source = TweakDBInterface.GetCharacterRecord(NCAEquipmentSystem.CombatArchetypeSource());
            if IsDefined(source) && IsDefined(source.ArchetypeData()) {
                write.Set("archetypeData", ToVariant(source.ArchetypeData().GetID()));
                write.Set("archetypeName", ToVariant(source.ArchetypeName()));
                borrowed = ", archetype borrowed from " + TDBID.ToStringDEBUG(NCAEquipmentSystem.CombatArchetypeSource());
            }
        }

        write.Commit();

        //NCA.CETLog("[equip] " + TDBID.ToStringDEBUG(companionId) + " abilities " + IntToString(ArraySize(abilities)) + borrowed);
    }

    private func ApplyStatGroups(companionId: TweakDBID) -> Void {
        let record = TweakDBInterface.GetCharacterRecord(companionId);
        if !IsDefined(record) {
            return;
        }

        let groups: array<wref<StatModifierGroup_Record>>;
        record.StatModifierGroups(groups);

        let kept: array<TweakDBID>;
        let changed: String = "";

        let i: Int32 = 0;
        while i < ArraySize(groups) {
            let groupID: TweakDBID = groups[i].GetID();

            if NCAEquipmentSystem.IsStrippedStatGroup(groupID) {
                changed += " -" + TDBID.ToStringDEBUG(groupID);
            } else {
                ArrayPush(kept, groupID);
            }

            i += 1;
        }

        if !IsStringValid(changed) {
            return;
        }

        let write = NCARecordWrite.Clone(NCACloneName.Character(companionId), companionId);
        write.Set("statModifierGroups", ToVariant(kept));
        write.Commit();

        //NCA.CETLog("[equip] " + TDBID.ToStringDEBUG(companionId) + " stat groups:" + changed);
    }

    private static func MergedCombatAbilities(record: wref<Character_Record>) -> array<TweakDBID> {
        let merged: array<TweakDBID>;

        let own: array<wref<GameplayAbility_Record>>;
        record.Abilities(own);

        let i: Int32 = 0;
        while i < ArraySize(own) {
            ArrayPush(merged, own[i].GetID());
            i += 1;
        }

        let group = TweakDBInterface.GetGameplayAbilityGroupRecord(t"NCAEquipment.CombatAbilities");
        if !IsDefined(group) {
            NCA.CETLog("[equip] ERROR NCAEquipment.CombatAbilities is missing - is the tweak loaded?");
            return merged;
        }

        let required: array<wref<GameplayAbility_Record>>;
        group.Abilities(required);

        i = 0;
        while i < ArraySize(required) {
            if !ArrayContains(merged, required[i].GetID()) {
                ArrayPush(merged, required[i].GetID());
            }
            i += 1;
        }

        return merged;
    }

// ============================================== Assignment ===========================================================

    public func HasWeapon(companionId: TweakDBID, equipSlot: CName) -> Bool {
        let rows: array<NCACompanionEquipment> = NCA.Persistence().GetCompanionEquipmentRows(companionId, equipSlot);

        return ArraySize(rows) > 0;
    }

    public func GiveWeapon(companionId: TweakDBID, equipSlot: CName, sourceItem: ItemID) -> Bool {
        if !ItemID.IsValid(sourceItem) || !this.PrepareCharacter(companionId) {
            return false;
        }

        let item: TweakDBID = ItemID.GetTDBID(sourceItem);
        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());
        let parts: array<NCAItemPartEntry> = this.GetInstalledParts(NCA.Player(), sourceItem);

        let sourceData: wref<gameItemData> = transactions.GetItemData(NCA.Player(), sourceItem);
        let quality: Float = IsDefined(sourceData) ? sourceData.GetStatValueByType(gamedataStatType.Quality) : 0.0;
        let upgrade: Float = IsDefined(sourceData) ? sourceData.GetStatValueByType(gamedataStatType.WasItemUpgraded) : 0.0;

        if this.HasWeapon(companionId, equipSlot) {
            this.TakeWeapon(companionId, equipSlot);
        }

        NCA.Persistence().SetCompanionEquipment(companionId, equipSlot, item, quality, upgrade);

        let i: Int32 = 0;
        while i < ArraySize(parts) {
            NCA.Persistence().AddCompanionEquipmentPart(companionId, equipSlot, parts[i].slot, parts[i].part);
            i += 1;
        }

        //NCA.CETLog("[equip] " + TDBID.ToStringDEBUG(companionId) + " given " + NCA.Util().ItemName(item) + " in " + NameToString(equipSlot) + " with " + IntToString(ArraySize(parts)) + " attachments" + ", quality " + FloatToString(quality) + " upgrade " + FloatToString(upgrade));

        if NCAEquipmentSystem.GivingRemovesFromPlayer() {
            transactions.RemoveItem(NCA.Player(), sourceItem, 1);
        }

        return this.ApplyEquipment(companionId, equipSlot);
    }

    public func TakeWeapon(companionId: TweakDBID, equipSlot: CName) -> Bool {
        let rows: array<NCACompanionEquipment> = NCA.Persistence().GetCompanionEquipmentRows(companionId, equipSlot);
        if ArraySize(rows) == 0 {
            return false;
        }

        let parts: array<NCACompanionEquipmentPart> =
            NCA.Persistence().GetCompanionEquipmentParts(companionId, equipSlot);
        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());

        let restored: ItemID = ItemID.FromTDBID(rows[0].item);
        if !transactions.GiveItem(NCA.Player(), restored, 1) {
            NCA.CETLog("[equip] ERROR could not give " + TDBID.ToStringDEBUG(rows[0].item) + " back to the player");
            return false;
        }

        this.RestoreParts(NCA.Player(), restored, parts);

        let restoredData: wref<gameItemData> = transactions.GetItemData(NCA.Player(), restored);
        this.RestoreTier(restoredData, rows[0].quality, rows[0].upgrade);

        NCA.Persistence().ClearCompanionEquipment(companionId, equipSlot);

        //NCA.CETLog("[equip] " + TDBID.ToStringDEBUG(companionId) + " returned " + NCA.Util().ItemName(rows[0].item) + " with " + IntToString(ArraySize(parts)) + " attachments restored");

        return this.ApplyEquipment(companionId, equipSlot);
    }

    public func ReturnAllWeapons(companionId: TweakDBID) -> Int32 {
        let slots: array<CName> = NCAEquipmentSystem.Slots();
        let returned: Int32 = 0;

        let i: Int32 = 0;
        while i < ArraySize(slots) {
            if this.HasWeapon(companionId, slots[i]) {
                this.TakeWeapon(companionId, slots[i]);

                if !this.HasWeapon(companionId, slots[i]) {
                    returned += 1;
                }
            }

            i += 1;
        }

        if returned > 0 {
            NCA.CETLog("[equip] " + TDBID.ToStringDEBUG(companionId) + " gave up "
                + IntToString(returned) + " weapon(s) to the player");
        }

        return returned;
    }

    // (itemModificationSystem.swift:40).
    private func RestoreParts(owner: ref<GameObject>, itemID: ItemID, parts: array<NCACompanionEquipmentPart>) -> Void {
        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());
        let data: wref<gameItemData> = transactions.GetItemData(owner, itemID);

        let i: Int32 = 0;
        while i < ArraySize(parts) {
            if !NCAEquipmentSystem.IsPartFitted(data, parts[i]) {
                let partItem: ItemID = ItemID.FromTDBID(parts[i].part);
                transactions.GiveItem(owner, partItem, 1);

                if !transactions.ForcePartInSlot(owner, itemID, partItem, parts[i].attachmentSlot) {
                    NCA.CETLog("[equip] ERROR could not refit " + TDBID.ToStringDEBUG(parts[i].part)
                        + " into " + TDBID.ToStringDEBUG(parts[i].attachmentSlot));
                }
            }

            i += 1;
        }
    }

    private static func IsPartFitted(data: wref<gameItemData>, part: NCACompanionEquipmentPart) -> Bool {
        if !IsDefined(data) {
            return false;
        }

        let fitted: InnerItemData;
        data.GetItemPart(fitted, part.attachmentSlot);

        return Equals(ItemID.GetTDBID(InnerItemData.GetItemID(fitted)), part.part);
    }

    private func RestoreTier(data: wref<gameItemData>, quality: Float, upgrade: Float) -> Void {
        if !IsDefined(data) {
            return;
        }

        this.RestoreStat(data, gamedataStatType.Quality, quality);
        this.RestoreStat(data, gamedataStatType.WasItemUpgraded, upgrade);
    }

    // (stash.swift:500-517)
    private func RestoreStat(data: wref<gameItemData>, statType: gamedataStatType, recorded: Float) -> Void {
        let delta: Float = recorded - data.GetStatValueByType(statType);
        if AbsF(delta) < 0.01 {
            return;
        }

        let modifier = RPGManager.CreateStatModifier(statType, gameStatModifierType.Additive, delta);
        GameInstance.GetStatsSystem(GetGameInstance()).AddSavedModifier(data.GetStatsObjectID(), modifier);
    }

    public func SyncPuppet(companionId: TweakDBID) -> Void {
        let handle: ref<NpcHandle> = NCA.NPC().FindHandle(companionId);
        if !IsDefined(handle) || !handle.IsValid() {
            return;
        }

        let puppet: wref<ScriptedPuppet> = handle.GetEntity();
        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());

        let carried: array<wref<gameItemData>>;
        transactions.GetItemList(puppet, carried);

        let dropping: array<ItemID>;
        let i: Int32 = 0;
        while i < ArraySize(carried) {
            let itemID: ItemID = carried[i].GetID();
            if carried[i].HasTag(n"Weapon")
            && !StrContains(TDBID.ToStringDEBUG(ItemID.GetTDBID(itemID)), "fists") {
                ArrayPush(dropping, itemID);
            }
            i += 1;
        }

        i = 0;
        while i < ArraySize(dropping) {
            transactions.RemoveItem(puppet, dropping[i], 1);
            i += 1;
        }

        let given: array<TweakDBID>;
        let slots: array<CName> = NCAEquipmentSystem.Slots();

        let s: Int32 = 0;
        while s < ArraySize(slots) {
            this.GiveSlotWeapons(given, transactions, puppet, companionId, slots[s]);
            s += 1;
        }

        //NCA.CETLog("[equip] " + TDBID.ToStringDEBUG(companionId) + " puppet synced: dropped " + IntToString(ArraySize(dropping)) + ", gave " + IntToString(ArraySize(given)));
    }

    private func GiveSlotWeapons(out given: array<TweakDBID>, transactions: ref<TransactionSystem>,
                                 puppet: wref<ScriptedPuppet>, companionId: TweakDBID, equipSlot: CName) -> Void {
        let rows: array<NCACompanionEquipment> = NCA.Persistence().GetCompanionEquipmentRows(companionId, equipSlot);

        let i: Int32 = 0;
        while i < ArraySize(rows) {
            let item: TweakDBID = this.BuildWeaponRecord(companionId, rows[i]);

            if TDBID.IsValid(item) && !ArrayContains(given, item) {
                let itemID: ItemID = ItemID.FromTDBID(item);
                transactions.GiveItem(puppet, itemID, 1);

                this.RestoreTier(transactions.GetItemData(puppet, itemID), rows[i].quality, rows[i].upgrade);

                ArrayPush(given, item);
            }

            i += 1;
        }
    }

    public func ApplyEquipment(companionId: TweakDBID, equipSlot: CName) -> Bool {
        let rebuilt: Bool = this.RebuildGroup(companionId, equipSlot);
        this.SyncPuppet(companionId);

        return rebuilt;
    }

// =========================================== Record building =========================================================

    public func RebuildGroup(companionId: TweakDBID, equipSlot: CName) -> Bool {
        if !this.PrepareCharacter(companionId) {
            return false;
        }

        let group: CName = NCAEquipmentSystem.GroupOf(equipSlot);

        let write = NCARecordWrite.Clone(NCACloneName.Group(companionId, group), t"NCAEquipment.WeaponGroup");
        if !write.IsValid() {
            return false;
        }

        let items: array<TweakDBID>;
        let slots: array<CName> = NCAEquipmentSystem.SlotsInGroup(group);

        let s: Int32 = 0;
        while s < ArraySize(slots) {
            let rows: array<NCACompanionEquipment> =
                NCA.Persistence().GetCompanionEquipmentRows(companionId, slots[s]);

            let i: Int32 = 0;
            while i < ArraySize(rows) {
                let itemID: TweakDBID = this.BuildEquipmentItem(companionId, rows[i]);
                if TDBID.IsValid(itemID) {
                    ArrayPush(items, itemID);
                }
                i += 1;
            }

            s += 1;
        }

        write.Set("equipmentItems", ToVariant(items));
        let wrote: Bool = write.Commit();

        let character = NCARecordWrite.Clone(NCACloneName.Character(companionId), companionId);
        character.Set(NCAEquipmentSystem.GroupFlat(group), ToVariant(write.GetID()));

        return character.Commit() && wrote;
    }

    private static func GroupFlat(group: CName) -> String {
        return Equals(group, NCAEquipmentSystem.SecondarySlot()) ? "secondaryEquipment" : "primaryEquipment";
    }

    private func BuildEquipmentItem(companionId: TweakDBID, row: NCACompanionEquipment) -> TweakDBID {
        let none: TweakDBID;

        let write = NCARecordWrite.Clone(
            NCACloneName.Item(companionId, row.equipSlot, row.item),
            NCAEquipmentSystem.ItemTemplateFor(row.item));

        if !write.IsValid() {
            return none;
        }

        write.Set("item", ToVariant(this.BuildWeaponRecord(companionId, row)));
        write.Set("onBodySlot", ToVariant(NCAEquipmentSystem.BodySlotFor(row.item)));
        write.Commit();

        return write.GetID();
    }

    private static func ItemTemplateFor(weapon: TweakDBID) -> TweakDBID {
        let record: wref<WeaponItem_Record> = TweakDBInterface.GetWeaponItemRecord(weapon);

        return WeaponObject.IsMelee(record) ? t"NCAEquipment.MeleeItem" : t"NCAEquipment.RangedItem";
    }

    private static func BodySlotFor(weapon: TweakDBID) -> TweakDBID {
        let none: TweakDBID;

        let record = TweakDBInterface.GetItemRecord(weapon);
        if !IsDefined(record) || record.GetPlacementSlotsCount() == 0 {
            return none;
        }

        return record.GetPlacementSlotsItem(0).GetID();
    }

    private func BuildWeaponRecord(companionId: TweakDBID, row: NCACompanionEquipment) -> TweakDBID {
        let parts: array<NCACompanionEquipmentPart> =
            NCA.Persistence().GetCompanionEquipmentParts(companionId, row.equipSlot);
        let quality: TweakDBID = NCAEquipmentSystem.QualityRecordFor(row.quality);

        if ArraySize(parts) == 0 && !TDBID.IsValid(quality) {
            return row.item;
        }

        let write = NCARecordWrite.Clone(NCACloneName.Weapon(companionId, row.equipSlot, row.item), row.item);
        if !write.IsValid() {
            return row.item;
        }

        write.Set("slotPartListPreset", ToVariant(this.BuildPartPresets(companionId, row.equipSlot, parts)));

        if TDBID.IsValid(quality) {
            write.Set("quality", ToVariant(quality));
        }

        write.Commit();

        return write.GetID();
    }

    private func BuildPartPresets(companionId: TweakDBID, equipSlot: CName,
                                  parts: array<NCACompanionEquipmentPart>) -> array<TweakDBID> {
        let presets: array<TweakDBID>;

        let i: Int32 = 0;
        while i < ArraySize(parts) {
            let write = NCARecordWrite.Clone(
                NCACloneName.Part(companionId, equipSlot, parts[i].attachmentSlot),
                t"NCAEquipment.PartPreset");

            if write.IsValid() {
                write.Set("slot", ToVariant(parts[i].attachmentSlot));
                write.Set("itemPartPreset", ToVariant(parts[i].part));

                if write.Commit() {
                    ArrayPush(presets, write.GetID());
                }
            }

            i += 1;
        }

        return presets;
    }

    private static func QualityRecordFor(qualityStat: Float) -> TweakDBID {
        let none: TweakDBID;

        if qualityStat <= 0.0 {
            return none;
        }

        return TDBID.Create("Quality." + NameToString(UIItemsHelper.QualityEnumToName(RPGManager.GetItemQuality(qualityStat))));
    }

// ============================================== Read-back ============================================================

    public func GetSlotRecordID(companionId: TweakDBID, equipSlot: CName) -> TweakDBID {
        let none: TweakDBID;

        let rows: array<NCACompanionEquipment> = NCA.Persistence().GetCompanionEquipmentRows(companionId, equipSlot);
        if ArraySize(rows) == 0 {
            return none;
        }

        return this.BuildWeaponRecord(companionId, rows[0]);
    }

    public func GetInstalledParts(owner: ref<GameObject>, itemID: ItemID) -> array<NCAItemPartEntry> {
        let entries: array<NCAItemPartEntry>;

        if !IsDefined(owner) || !ItemID.IsValid(itemID) {
            return entries;
        }

        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());

        let data: wref<gameItemData> = transactions.GetItemData(owner, itemID);
        if !IsDefined(data) {
            return entries;
        }

        let slots: array<TweakDBID>;
        transactions.GetUsedSlotsOnItem(owner, itemID, slots);

        let i: Int32 = 0;
        while i < ArraySize(slots) {
            let part: InnerItemData;
            data.GetItemPart(part, slots[i]);

            let partID: TweakDBID = ItemID.GetTDBID(InnerItemData.GetItemID(part));
            if TDBID.IsValid(partID) {
                ArrayPush(entries, new NCAItemPartEntry(slots[i], partID, NCA.Util().ItemName(partID)));
            }

            i += 1;
        }

        return entries;
    }
}
