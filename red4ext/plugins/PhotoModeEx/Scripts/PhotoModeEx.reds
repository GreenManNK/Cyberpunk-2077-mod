// PhotoModeEx 1.4.1
module PhotoModeEx

public func CountFracDigits(x: Float) -> Int32 {
    let s = FloatToString(x);
    let a = StrFindLast(s, ".");
    let b = StrLen(s) - 1;
    while Equals(StrMid(s, b, 1), "0") {
        b -= 1;
    }
    return b - a;
}
public func FormatFloat(x: Float, p: Int32) -> String {
    let s = FloatToStringPrec(x, p);
    if RoundTo(x, 0) == x {
        s += "." + ("0" * p);
    }
    return s;
}

@wrapMethod(gameuiPhotoModeMenuController)
public final func SetCurrentMenuPage(page: Uint32) {
    wrappedMethod(page);
    if page == 0u {
        inkTextRef.SetText(this.m_tabTitleText,
            GetLocalizedTextByKey(n"UI-PhotoMode-TabCamera") + " / " +
            GetLocalizedTextByKey(n"UI-Settings-Interface-CameraControls-Title"));
    }
}

@wrapMethod(PhotoModePlayerEntityComponent)
private final func FindMatchingEquipmentInEquipArea(area: gamedataEquipmentArea, typesList: array<gamedataItemType>) -> ItemID {
    if !this.customizable && Equals(area, gamedataEquipmentArea.WeaponWheel) {
        let allItems: array<wref<gameItemData>>;
        let transactionSystem = GameInstance.GetTransactionSystem(this.mainPuppet.GetGame());
        transactionSystem.GetItemList(this.GetOwner(), allItems);
        transactionSystem.GetItemList(this.mainPuppet, allItems);
        let i = 0;
        while i < ArraySize(allItems) {
            let itemID = allItems[i].GetID();
            if ItemID.IsValid(itemID) && this.IsItemOfThisType(itemID, typesList) {
                return itemID;
            }
            i += 1;
        }
    }
    return wrappedMethod(area, typesList);
}
