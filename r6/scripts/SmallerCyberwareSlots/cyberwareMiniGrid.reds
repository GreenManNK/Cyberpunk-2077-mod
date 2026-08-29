@wrapMethod(CyberwareInventoryMiniGrid)
public final func SetupData(equipArea: gamedataEquipmentArea, const playerEquipAreaInventory: script_ref<[wref<UIInventoryItem>]>, parent: ref<IScriptable>, onRealeaseCallbackName: CName, screen: CyberwareScreenType, hasMods: Bool, displayContext: ref<ItemDisplayContextData>, opt inventoryManager: ref<InventoryDataManagerV2>, opt player: ref<PlayerPuppet>) -> Void {
  let costData: CyberwareUpgradeCostData;
  let gridListItem: wref<InventoryItemDisplayController>;
  let i: Int32;
  let itemUpgrade: ref<Item_Record>;
  let itemUpgradeQuality: gamedataQuality;
  let slotUserData: ref<SlotUserData>;
  let visibleWhenLocked: Bool;
  this.m_player = player;
  this.m_parentObject = parent;
  this.m_equipArea = equipArea;
  this.m_onRealeaseCallbackName = onRealeaseCallbackName;
  this.m_displayContext = displayContext;
  let limit: Int32 = ArraySize(Deref(playerEquipAreaInventory));
  let wrappingCount: Int32 = 6;
  if limit < wrappingCount {
    inkUniformGridRef.SetWrappingWidgetCount(this.m_gridContainer, Cast<Uint32>(limit));
  } else {
    inkUniformGridRef.SetWrappingWidgetCount(this.m_gridContainer, Cast<Uint32>(wrappingCount));
  };
  while ArraySize(this.m_gridData) > 0 {
    gridListItem = ArrayPop(this.m_gridData);
    inkCompoundRef.RemoveChild(this.m_gridContainer, gridListItem.GetRootWidget());
  };
  i = 0;
  while i < limit {
    slotUserData = new SlotUserData();
    slotUserData.item = Deref(playerEquipAreaInventory)[i];
    slotUserData.index = i;
    slotUserData.area = equipArea;
    slotUserData.isLocked = inventoryManager.IsSlotLocked(equipArea, i, visibleWhenLocked);
    slotUserData.visibleWhenLocked = visibleWhenLocked;
    slotUserData.screen = screen;
    slotUserData.isPerkRequired = this.IsEquipmentAreaRequiringPerk(equipArea) && i == limit - 1;
    slotUserData.canUpgrade = RPGManager.CanUpgradeCyberware(player, slotUserData.item.GetID(), slotUserData.item.IsEquipped(), gamedataQuality.Invalid, itemUpgradeQuality, itemUpgrade, costData);
    slotUserData.upgradeItem = itemUpgrade;
    slotUserData.upgradeItemQuality = itemUpgradeQuality;
    ItemDisplayUtils.SpawnCommonSlotAsync(this, this.m_gridContainer, n"itemDisplay", n"OnSlotSpawned", slotUserData);
    i += 1;
  };
  this.UnselectSlot();
  this.UpdateTitle(this.GetAreaHeader(equipArea));
}

@wrapMethod(CyberwareInventoryMiniGrid)
public final func UpdateData(equipArea: gamedataEquipmentArea, playerEquipAreaInventory: script_ref<[wref<UIInventoryItem>]>, opt screen: CyberwareScreenType) -> Void {
  let costData: CyberwareUpgradeCostData;
  let gridListItem: ref<InventoryItemDisplayController>;
  let i: Int32;
  let itemUpgrade: ref<Item_Record>;
  let itemUpgradeQuality: gamedataQuality;
  let limit: Int32 = ArraySize(Deref(playerEquipAreaInventory));
  let wrappingCount: Int32 = 6;
  this.m_equipArea = equipArea;
  if limit < wrappingCount {
    inkUniformGridRef.SetWrappingWidgetCount(this.m_gridContainer, Cast<Uint32>(limit));
  } else {
    inkUniformGridRef.SetWrappingWidgetCount(this.m_gridContainer, Cast<Uint32>(wrappingCount));
  };
  this.RemoveElements(limit);
  while ArraySize(this.m_gridData) < limit {
    gridListItem = ItemDisplayUtils.SpawnCommonSlotController(this, inkWidgetRef.Get(this.m_gridContainer), n"itemDisplay") as InventoryItemDisplayController;
    gridListItem.RegisterToCallback(n"OnRelease", this.m_parentObject, this.m_onRealeaseCallbackName);
    ArrayPush(this.m_gridData, gridListItem);
  };
  i = 0;
  while i < limit {
    gridListItem = this.m_gridData[i];
    gridListItem.Setup(Deref(playerEquipAreaInventory)[i], this.m_equipArea, "", i, this.m_displayContext);
    gridListItem.SetUpgradableCyberware(RPGManager.CanUpgradeCyberware(this.m_player, Deref(playerEquipAreaInventory)[i].GetID(), Deref(playerEquipAreaInventory)[i].IsEquipped(), gamedataQuality.Invalid, itemUpgradeQuality, itemUpgrade, costData));
    i += 1;
  };
  this.UnselectSlot();
}

@wrapMethod(CyberwareInventoryMiniGrid)
public final func SetPosition(margin: inkMargin, duration: Float) -> Void {
  let animation: ref<inkAnimDef>;
  let marginInterpolator: ref<inkAnimMargin>;
  let wrappingCount: Int32 = 6;
  let cyberwareCountOffset: Float;
  if ArraySize(this.m_gridData) > wrappingCount {
    cyberwareCountOffset = Cast<Float>((wrappingCount) * 135);
  } else {
    cyberwareCountOffset = Cast<Float>((ArraySize(this.m_gridData)) * 135);
  };

  if this.m_marginAnimation != null {
    this.m_marginAnimation.Stop();
  };
  if this.m_isLeftAligned {
    margin.left = margin.left - 530.00 + cyberwareCountOffset;
  };
  marginInterpolator = new inkAnimMargin();
  marginInterpolator.SetDuration(duration);
  marginInterpolator.SetStartMargin(inkWidgetRef.GetMargin(this.m_parent));
  marginInterpolator.SetEndMargin(margin);
  marginInterpolator.SetType(inkanimInterpolationType.Quintic);
  marginInterpolator.SetMode(inkanimInterpolationMode.EasyInOut);
  animation = new inkAnimDef();
  animation.AddInterpolator(marginInterpolator);
  this.m_marginAnimation = inkWidgetRef.PlayAnimation(this.m_parent, animation);
  this.AnimateLabel(true);
}

@wrapMethod(CyberwareInventoryMiniGrid)
public final func SetPosition_Animation(margin: inkMargin, duration: Float, opt isReversed: Bool, opt customOffset: Float, opt interpolationMode: inkanimInterpolationMode, opt interpolationType: inkanimInterpolationType) -> Void {
  let animation: ref<inkAnimDef>;
  let marginInterpolator: ref<inkAnimMargin>;
  let targetMargin: inkMargin;
  let translationInterpolator: ref<inkAnimTranslation>;
  let transparencyInterpolator: ref<inkAnimTransparency>;
  let wrappingCount: Int32 = 6;
  let offset: Float = customOffset != 0.00 ? customOffset : 200.00;
  offset *= isReversed ? -1.00 : 1.00;
  let cyberwareCountOffset: Float;
  if ArraySize(this.m_gridData) > wrappingCount {
    cyberwareCountOffset = Cast<Float>((wrappingCount) * 135);
  } else {
    cyberwareCountOffset = Cast<Float>((ArraySize(this.m_gridData)) * 135);
  };


  if this.m_marginAnimation != null {
    this.m_marginAnimation.IsPlaying() ? this.m_marginAnimation.GotoEndAndStop() : this.m_marginAnimation.Stop();
  };
  if this.m_isLeftAligned && !isReversed {
    margin.left = margin.left - 530.00 + cyberwareCountOffset;
  };
  if isReversed {
    targetMargin = this.m_margin;
  } else {
    targetMargin = margin;
  };
  if Equals(targetMargin, inkWidgetRef.GetMargin(this.m_parent)) {
    return;
  };
  animation = new inkAnimDef();
  transparencyInterpolator = new inkAnimTransparency();
  transparencyInterpolator.SetDuration(duration / 2.00);
  transparencyInterpolator.SetStartTransparency(1.00);
  transparencyInterpolator.SetEndTransparency(0.00);
  transparencyInterpolator.SetMode(interpolationMode);
  transparencyInterpolator.SetType(interpolationType);
  animation.AddInterpolator(transparencyInterpolator);
  translationInterpolator = new inkAnimTranslation();
  translationInterpolator.SetDuration(duration / 2.00);
  translationInterpolator.SetStartTranslation(new Vector2(0.00, 0.00));
  translationInterpolator.SetEndTranslation(new Vector2(offset, 0.00));
  translationInterpolator.SetMode(interpolationMode);
  translationInterpolator.SetType(interpolationType);
  animation.AddInterpolator(translationInterpolator);
  marginInterpolator = new inkAnimMargin();
  marginInterpolator.SetDuration(0.00);
  marginInterpolator.SetStartDelay(duration / 2.00);
  marginInterpolator.SetStartMargin(inkWidgetRef.GetMargin(this.m_parent));
  marginInterpolator.SetEndMargin(targetMargin);
  animation.AddInterpolator(marginInterpolator);
  transparencyInterpolator = new inkAnimTransparency();
  transparencyInterpolator.SetDuration(duration / 2.00);
  transparencyInterpolator.SetStartDelay(duration / 2.00);
  transparencyInterpolator.SetStartTransparency(0.00);
  transparencyInterpolator.SetEndTransparency(1.00);
  transparencyInterpolator.SetMode(interpolationMode);
  transparencyInterpolator.SetType(interpolationType);
  animation.AddInterpolator(transparencyInterpolator);
  translationInterpolator = new inkAnimTranslation();
  translationInterpolator.SetDuration(duration / 2.00);
  translationInterpolator.SetStartDelay(duration / 2.00);
  translationInterpolator.SetStartTranslation(new Vector2(offset, 0.00));
  translationInterpolator.SetEndTranslation(new Vector2(0.00, 0.00));
  translationInterpolator.SetMode(interpolationMode);
  translationInterpolator.SetType(interpolationType);
  animation.AddInterpolator(translationInterpolator);
  this.m_marginAnimation = inkWidgetRef.PlayAnimation(this.m_parent, animation);
  this.AnimateLabel(true);
}