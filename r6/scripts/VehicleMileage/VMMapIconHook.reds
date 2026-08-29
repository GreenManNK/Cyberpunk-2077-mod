module VehicleMileage

// ---- shared: detect our mappins via the debugCaption we set in vm_gas_markers.lua ----
@addMethod(BaseMappinBaseController)
protected final func __vmIsOurFuelPin() -> Bool {
  let cap: String = this.GetMappin().GetDisplayName();      // "VM_VehicleMileage|...|..."
  let parts: array<String> = StrSplit(cap, "|");
  return ArraySize(parts) > 0 && Equals(parts[0], "VM_VehicleMileage");
}

// ---- shared: apply the fuel icon (minimap vs world/map can use slightly different scale) ----
@addMethod(BaseMappinBaseController)
protected final func __vmApplyFuelIcon(opt forMinimap: Bool) -> Void {
  if !this.__vmIsOurFuelPin() { return; }

  // Use the same atlas/part you use on the HUD fuel glyph
  let atlasPath: ResRef = r"ep1\\gameplay\\gui\\widgets\\vehicle\\sport\\v_sport2_villefort_deleon\\villefort_deleon.inkatlas";
  let partName: CName   = n"fuel";

  inkImageRef.SetAtlasResource(this.iconWidget, atlasPath);
  inkImageRef.SetTexturePart(this.iconWidget, partName);

  // Tweak down a touch on the minimap (smaller widget); world/map can be a hair larger.
  let s: Float = forMinimap ? 0.60 : 0.65;             // <- change these two numbers to taste
  inkWidgetRef.SetScale(this.iconWidget, new Vector2(s, s));
}

// ===== minimap pin =====
@wrapMethod(MinimapPOIMappinController)
protected final func UpdateIcon() -> Void {
  wrappedMethod();
  this.__vmApplyFuelIcon(true);     // minimap
}

// ===== world *floating* pin (over the pump in the game world) =====
@wrapMethod(QuestMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.__vmApplyFuelIcon(false);    // world-space
}

// ===== big 2D World Map screen =====
@wrapMethod(BaseWorldMapMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.__vmApplyFuelIcon(false);    // world-map screen
}
