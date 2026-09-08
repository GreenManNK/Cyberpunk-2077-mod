// Ket_CivilStealthKill
// Enables stealth takedowns, quickhacking, carrying, and looting on civilian NPCs
// Compatible with loot mods like Ket_CivilianDrops
// Based on concepts from Hackable and Grabbable Civilians by Xaliber13

// Enable quickhack state and loot interaction for crowd NPCs when they spawn
@wrapMethod(ScriptedPuppet)
protected cb func OnGameAttached() -> Bool {
    let result: Bool = wrappedMethod();
    
    if this.IsCrowd() {
        // Enable quickhacking for crowd NPCs
        this.UpdateQuickHackableState(true);
        // Enable looting for crowd NPCs (for compatibility with loot mods like CivilianDrops)
        this.UpdateLootInteraction();
    };
    
    return result;
}

// Enable grapple, takedown, carry, and loot interactions for crowd NPCs
@wrapMethod(ScriptedPuppet)
protected func ToggleInteractionLayers() -> Void {
    wrappedMethod();

    if this.IsCrowd() {
        if this.GetRecord().CanHaveGenericTalk() {
            this.EnableInteraction(n"GenericTalk", true);
        };
        this.EnableInteraction(n"Grapple", true);
        this.EnableInteraction(n"TakedownLayer", true);
        this.EnableInteraction(n"AerialTakedown", true);
        this.EnableInteraction(n"Loot", true);
    };
}

// Enable quickhacking for crowd NPCs and vendors
@wrapMethod(ScriptedPuppet)
public const func IsQuickHackAble() -> Bool {
    let result: Bool = wrappedMethod();

    if this.IsCrowd() {
        return true;
    };
    if this.IsVendor() {
        return true;
    };

    return result;
}

// Enable HUD registration for crowd NPCs (allows scanning/targeting)
@wrapMethod(ScriptedPuppet)
protected const func ShouldRegisterToHUD() -> Bool {
    if this.IsCrowd() {
        return true;
    };
    if this.IsVendor() {
        return true;
    };
    return wrappedMethod();
}

// Set neutral outline for civilians (not hostile red)
@wrapMethod(ScriptedPuppet)
public const func GetCurrentOutline() -> EFocusOutlineType {
    if this.IsCivilian() && !this.IsAggressive() || this.IsVendor() {
        return EFocusOutlineType.NEUTRAL;
    };
    if GameObject.IsFriendlyTowardsPlayer(this) {
        return EFocusOutlineType.FRIENDLY;
    };

    return wrappedMethod();
}
