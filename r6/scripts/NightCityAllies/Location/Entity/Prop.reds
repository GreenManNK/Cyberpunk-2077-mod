module NightCityAllies.Location.Entity

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.*
import NightCityAllies.Event.*

public class NCAInteractionSlot {
    public let tag: CName;
    public let isOccupied: Bool;

    public static func Create(tag: CName) -> ref<NCAInteractionSlot> {
        let slot = new NCAInteractionSlot();
        slot.tag = tag;
        slot.isOccupied = false;
        return slot;
    }

    public func Occupy() -> Void {
        this.isOccupied = true;
    }

    public func Vacate() -> Void {
        this.isOccupied = false;
    }

    public func Dump() -> String {
        return "Slot: " + NameToString(this.tag) + ", Occupied: " + (this.isOccupied ? "yes" : "no");
    }
}

public class NCAInteractionPoint {
    public let type: CName;
    public let slots: array<CName>;
    public let pos: Vector4;
    public let rot: Quaternion;

    public static func Create(type: CName, slots: array<CName>, pos: Vector4, rot: Quaternion) -> ref<NCAInteractionPoint> {
        let interaction = new NCAInteractionPoint();
        interaction.type = type;
        interaction.slots = slots;
        interaction.pos = pos;
        interaction.rot = rot;
        return interaction;
    }

    public func Dump() -> String {
        return "Interaction: " + NameToString(this.type) + ", Slots: " + IntToString(ArraySize(this.slots));
    }
}

public class NCAProp {
    public let tag: CName;
    public let pos: Vector4;
    public let rot: Quaternion;
    public let slots: array<ref<NCAInteractionSlot>>;
    public let interactions: array<ref<NCAInteractionPoint>>;
    public let area: CName;

    public static func Create(tag: CName, pos: Vector4, rot: Quaternion, slots: array<ref<NCAInteractionSlot>>, interactions: array<ref<NCAInteractionPoint>>) -> ref<NCAProp> {
        let s = new NCAProp();
        s.tag = tag;
        s.pos = pos;
        s.rot = rot;
        s.slots = slots;
        s.interactions = interactions;
        return s;
    }

    public func Merge(slots: array<ref<NCAInteractionSlot>>, interactions: array<ref<NCAInteractionPoint>>) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(slots) {
            // matched by tag, so re-declaring a slot that exists does not reset whether it is taken
            if !IsDefined(this.GetSlotByTag(slots[i].tag)) {
                ArrayPush(this.slots, slots[i]);
            };
            i += 1;
        };

        i = 0;
        while i < ArraySize(interactions) {
            ArrayPush(this.interactions, interactions[i]);
            i += 1;
        };
    }

    public func Spawn() -> Void {
    }

    public func Despawn() -> Void {
    }

    public func IsInteractionPointFree(interaction: ref<NCAInteractionPoint>) -> Bool {
        // check if all slots required for this interaction are free
        let i: Int32 = 0;
        while i < ArraySize(interaction.slots) {
            let slotTag = interaction.slots[i];
            let slot = this.GetSlotByTag(slotTag);
            if !IsDefined(slot) || slot.isOccupied {
                return false;
            }
            i += 1;
        };
        return true;
    }

    // todo name: GetInteractionByIndex
    public func GetInteractionAt(index: Int32) -> ref<NCAInteractionPoint> {
        if index < 0 || index >= ArraySize(this.interactions) {
            return null;
        }
        return this.interactions[index];
    }

    public func GetInteractionIndex(interaction: ref<NCAInteractionPoint>) -> Int32 {
        let i: Int32 = 0;
        while i < ArraySize(this.interactions) {
            if this.interactions[i] == interaction {
                return i;
            }
            i += 1;
        };
        return -1;
    }

    public func OccupyInteractionPoint(interaction: ref<NCAInteractionPoint>) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(interaction.slots) {
            let slotTag = interaction.slots[i];
            let slot = this.GetSlotByTag(slotTag);
            if IsDefined(slot) {
                slot.Occupy();
            }
            i += 1;
        };
    }

    public func VacateInteractionPoint(interaction: ref<NCAInteractionPoint>) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(interaction.slots) {
            let slotTag = interaction.slots[i];
            let slot = this.GetSlotByTag(slotTag);
            if IsDefined(slot) {
                slot.Vacate();
            }
            i += 1;
        };
    }

    private func GetSlotByTag(tag: CName) -> ref<NCAInteractionSlot> {
        let i: Int32 = 0;
        while i < ArraySize(this.slots) {
            if Equals(this.slots[i].tag, tag) {
                return this.slots[i];
            }
            i += 1;
        };
        return null;
    }

    public func Dump() -> String {
        let i: Int32 = 0;
        let result = "Prop: " + NameToString(this.tag) + ", Area: " + NCAPath.AreaName(this.area) + ", Interactions: " + IntToString(ArraySize(this.interactions)) + ", Slots: " + IntToString(ArraySize(this.slots));
        result += "  -  ";
        while i < ArraySize(this.slots) {
            result += " " + this.slots[i].Dump();
            i += 1;
        };
        result += "  -  ";
        i = 0;
        while i < ArraySize(this.interactions) {
            result += " " + this.interactions[i].Dump();
            i += 1;
        };
        return result;
    }
}