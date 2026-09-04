module PanamDateSMS

// ---- Detect our Panam pins via debugCaption prefix ----
@addMethod(BaseMappinBaseController)
protected final func __pdIsPanamPin() -> Bool {
    let cap: String = this.GetMappin().GetDisplayName();
    let parts: array<String> = StrSplit(cap, "|");
    return ArraySize(parts) > 0 && Equals(parts[0], "PanamDate");
}

// ---- Optional: Scale the icon slightly on minimap ----
@addMethod(BaseMappinBaseController)
protected final func __pdApplyPanamIconScale(opt forMinimap: Bool) -> Void {
    if !this.__pdIsPanamPin() { return; }
    if forMinimap {
        inkWidgetRef.SetScale(this.iconWidget, new Vector2(0.85, 0.85));
    }
}

// ===== minimap POI pin =====
@wrapMethod(MinimapPOIMappinController)
protected final func UpdateIcon() -> Void {
    wrappedMethod();
    this.__pdApplyPanamIconScale(true);
}

// ===== minimap device controller =====
@wrapMethod(MinimapDeviceMappinController)
protected func Update() -> Void {
    wrappedMethod();
    this.__pdApplyPanamIconScale(true);
}

// ===== floating world pin (quest marker) =====
@wrapMethod(QuestMappinController)
protected func UpdateIcon() -> Void {
    wrappedMethod();
    this.__pdApplyPanamIconScale(false);
}

// ===== gameplay controller (tracked pins) =====
@wrapMethod(GameplayMappinController)
private func UpdateIcon() -> Void {
    wrappedMethod();
    if IsDefined(this.m_mappin) && this.__pdIsPanamPin() {
        this.__pdApplyPanamIconScale(false);
    }
}

// ===== big 2D World Map screen =====
@wrapMethod(BaseWorldMapMappinController)
protected func UpdateIcon() -> Void {
    wrappedMethod();
    this.__pdApplyPanamIconScale(false);
}

// ===== world map tooltip text (THIS IS THE KEY) =====
@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
    wrappedMethod(data, menu);
    let cap: String = Deref(data).mappin.GetDisplayName();
    let parts: array<String> = StrSplit(cap, "|");
    if ArraySize(parts) >= 3 && Equals(parts[0], "PanamDate") {
        // parts[0] = "PanamDate"
        // parts[1] = "Meet Panam"
        // parts[2] = "Panam is waiting for you"
        inkTextRef.SetText(this.m_titleText, parts[1]);
        inkTextRef.SetText(this.m_descText,  parts[2]);
    }
}
