public class COSVMappinData extends MappinScriptData {
  public let iconPart: CName;
}

@addMethod(BaseMappinBaseController)
protected final func COSV_ApplyIconOverride() -> Void {
  let mappin = this.GetMappin();
  let cosvData: wref<COSVMappinData>;

  if !IsDefined(mappin) {
    return;
  };

  cosvData = mappin.GetScriptData() as COSVMappinData;
  if !IsDefined(cosvData) {
    return;
  };

  inkImageRef.SetAtlasResource(this.iconWidget, r"cosv.inkatlas");
  inkImageRef.SetTexturePart(this.iconWidget, cosvData.iconPart);
}

@wrapMethod(BaseWorldMapMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.COSV_ApplyIconOverride();
}

@wrapMethod(QuestMappinController)
protected func UpdateIcon() -> Void {
  wrappedMethod();
  this.COSV_ApplyIconOverride();
}

@wrapMethod(MinimapPOIMappinController)
protected final func UpdateIcon() -> Void {
  wrappedMethod();
  this.COSV_ApplyIconOverride();
}
