module QuickhacksSortBySlotMod

public static func SortBySlotNumberDesc(arr: array<SPartSlots>) -> array<SPartSlots> {
    let j: Int32;
    let minIndex: Int32;
    let temp: SPartSlots;
    let sortedArray: array<SPartSlots> = arr;
    let i: Int32 = 0;
    let slotNumbers = GetSlotNumberArray(arr);
    while i < ArraySize(sortedArray) {
        minIndex = i;
        j = i + 1;
        while j < ArraySize(sortedArray) {
            if slotNumbers[j] > slotNumbers[minIndex] {
                minIndex = j;
            };
            j += 1;
        };
        if minIndex != i {
            temp = sortedArray[i];
            sortedArray[i] = sortedArray[minIndex];
            sortedArray[minIndex] = temp;
            let tempNum = slotNumbers[i];
            slotNumbers[i] = slotNumbers[minIndex];
            slotNumbers[minIndex] = tempNum;
        };
        i += 1;
    };
    return sortedArray;
}

public static func GetSlotNumberArray(arr: array<SPartSlots>) -> array<Int32> {
    let result: array<Int32>;
    for slot in arr {
        let str = TweakDBInterface.GetAttachmentSlotRecord(slot.slotID).EntitySlotName();
        let num = 999;
        if StrBeginsWith(str, "CyberdeckProgram") {
            if !IsBlackwallGateway(slot.installedPart) {
                num = StringToInt(StrReplace(str, "CyberdeckProgram", ""), 0);
            }
        }
        ArrayPush(result, num);
    }
    return result;
}

public static func IsBlackwallGateway(itemID: ItemID) -> Bool {
    let blackwallPrograms = [t"Items.BlackWallProgramLvl2", t"Items.BlackWallProgramLvl3", t"Items.BlackWallProgramLvl4"];
    let itemTdbid = ItemID.GetTDBID(itemID);
    for bwp in blackwallPrograms {
        if Equals(bwp, itemTdbid) {
            return true;
        }
    }
    return false;
}

@replaceMethod(RPGManager)
public final static func GetPlayerQuickHackListWithQuality(player: wref<PlayerPuppet>) -> array<PlayerQuickhackData> {
    let actions: array<wref<ObjectAction_Record>>;
    let i: Int32;
    let i1: Int32;
    let itemID: ItemID;
    let itemRecord: wref<Item_Record>;
    let parts: array<SPartSlots>;
    let quickhackData: PlayerQuickhackData;
    let quickhackDataEmpty: PlayerQuickhackData;
    let systemReplacementID: ItemID;
    let tweakItemID: TweakDBID;
    let quickhackDataArray: array<PlayerQuickhackData> = player.GetCachedQuickHackList();
    if ArraySize(quickhackDataArray) > 0 {
      return quickhackDataArray;
    };
    systemReplacementID = EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
    itemRecord = RPGManager.GetItemRecord(systemReplacementID);
    tweakItemID = itemRecord.GetID();
    if EquipmentSystem.IsCyberdeckEquipped(player) {
      itemRecord.ObjectActions(actions);
      i = 0;
      while i < ArraySize(actions) {
        if Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack) || Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) || Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.VehicleQuickHack) {
          quickhackData = quickhackDataEmpty;
          quickhackData.actionRecord = actions[i];
          quickhackData.quality = itemRecord.Quality().Value();
          ArrayPush(quickhackDataArray, quickhackData);
        };
        i += 1;
      };
      parts = ItemModificationSystem.GetAllSlots(player, systemReplacementID);
      // ====== start
      parts = SortBySlotNumberDesc(parts);
      // ====== end
      i = 0;
      while i < ArraySize(parts) {
        ArrayClear(actions);
        itemRecord = RPGManager.GetItemRecord(parts[i].installedPart);
        tweakItemID = itemRecord.GetID();
        itemID = ItemID.FromTDBID(tweakItemID);
        if IsDefined(itemRecord) {
          itemRecord.ObjectActions(actions);
          i1 = 0;
          while i1 < ArraySize(actions) {
            if Equals(actions[i1].ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack) || Equals(actions[i1].ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) || Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.VehicleQuickHack) {
              quickhackData = quickhackDataEmpty;
              quickhackData.actionRecord = actions[i1];
              quickhackData.quality = itemRecord.Quality().Value();
              quickhackData.itemID = itemID;
              ArrayPush(quickhackDataArray, quickhackData);
            };
            i1 += 1;
          };
        };
        i += 1;
      };
    };
    ArrayClear(actions);
    itemRecord = RPGManager.GetItemRecord(EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.Splinter));
    if IsDefined(itemRecord) {
      itemRecord.ObjectActions(actions);
      i = 0;
      while i < ArraySize(actions) {
        if Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack) || Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) || Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.VehicleQuickHack) {
          quickhackData = quickhackDataEmpty;
          quickhackData.actionRecord = actions[i];
          ArrayPush(quickhackDataArray, quickhackData);
        };
        i += 1;
      };
    };
    RPGManager.RemoveDuplicatedHacks(quickhackDataArray);
    PlayerPuppet.ChacheQuickHackList(player, quickhackDataArray);
    return quickhackDataArray;
}